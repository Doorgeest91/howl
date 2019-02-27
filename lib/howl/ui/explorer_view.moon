-- Copyright 2019 The Howl Developers
-- License: MIT (see LICENSE.md at the top-level directory of the distribution)

{:app, :log} = howl
{:ListWidget, :List, :ActionBuffer, :highlight, :StyledText} = howl.ui
{:Matcher} = howl.util
{:Preview} = howl.interactions.util

append = table.insert

get_display_item = (item) ->
  return item unless item.display_row
  display_item = item\display_row!
  display_item = {display_item} if type(display_item) == 'string'
  display_item.item = item
  return display_item

class ExplorerView
  new: (opts) =>
    @opts = moon.copy opts
    path = @opts.path or error 'path not provided'
    @base_prompt = @opts.prompt or ''
    @base_title = @opts.title
    if type @base_prompt.styles == 'string'
      @base_prompt = StyledText @base_prompt, 'keyword'
    @separator = @opts.separator or ''
    @editor = @opts.editor or app.editor

    @levels = [{:item} for item in *path]
    @remaining_text = ''

  init: (@command_line, opts={}) =>
    @list = List nil,
      on_selection_change: (selection) ->
        level = @levels[#@levels]
        item = if selection then selection.item or (level.item.get_item and level.item\get_item selection)
        @_preview item
    @list_widget = ListWidget @list, never_shrink: true

    if opts.max_height
      @list_widget.max_height_request = opts.max_height

    -- when auto_trim, show trim markers at end of row text if too long
    if opts.max_width and @opts.auto_trim
      @list_widget.max_width_request = opts.max_width

    @_refresh false  -- on init, the default on_text_changed event refreshes the widgets

  get_help: =>
    local_help = howl.ui.HelpContext!
    local_help\add_keys
      ctrl_r: 'Refresh view'

    level = @levels[#@levels]
    explorer_help = level.item.get_help and level.item\get_help!

    help = howl.ui.HelpContext!
    help\merge explorer_help
    help\merge local_help
    help

  _refresh: (full=true) =>
    level = @levels[#@levels]
    if level.item.display_items
      status, subitems, opts = pcall -> level.item\display_items!
      if status
        level.subitems = subitems
        if level.item.display_columns
          @list.columns = level.item\display_columns!
        @list_initial_selection = @_reset_list_widget level.subitems, opts
      else
        level.subitems = {}
        err = subitems
        error "Cannot load items at: #{level.item.display_path!}: " .. err
    else
      level.subitems = nil
      if level.item.get_value and @remaining_text.is_empty
        @remaining_text = level.item\get_value!
    @_redraw_text level, @remaining_text
    @_update_widgets! if full

    unless @list_widget_attached
      @command_line\add_widget 'explore_list', @list_widget
      @list_widget_attached = true

  _reset_list_widget: (items, opts={}) =>
    display_items = {}
    local selection

    for item in *items
      local display_item
      display_item = get_display_item item

      append display_items, display_item
      if opts.selected_item == item
        selection = display_item

    matcher = Matcher display_items, preserve_order: opts.preserve_order

    if opts.find_hidden
      inner_matcher = matcher
      matcher = (search) ->
        matches, match_opts = inner_matcher search
        return matches, match_opts if not search or search.is_blank
        item = opts.find_hidden search
        if item
          matches = moon.copy matches
          append matches, get_display_item item
        matches, match_opts

    @list.matcher = matcher
    return selection

  _redraw_text: (level, text) =>
    prompt = @base_prompt
    prompt ..= level.item\display_path! if level.item.display_path
    @command_line.prompt = prompt if prompt != @command_line.prompt
    if text != @command_line.text
      @command_line.text = text

  _update_widgets: =>
    level = @levels[#@levels]
    if level.subitems
      @list\update @remaining_text
      @list_widget\show!
      if @list_initial_selection
        @list.selection = @list_initial_selection
        @list_initial_selection = nil
    else
      howl.timer.asap -> @list_widget\hide!

    local level_title
    if level.item.display_title
      level_title = level.item\display_title!
    if @base_title or level_title
      @command_line.title = (@base_title or '') .. (level_title or '')
    else
      @command_line.title = nil

  _enter_level: (item) =>
    append @levels, {:item}
    ok, err = pcall -> @_refresh!
    unless ok
      log.error 'cannot render item: ' .. err
      error 'cannot render item', err

  _jump_to_level: (path) =>
    @levels = [{:item} for item in *path]
    @_refresh!

  _exit_level: =>
    if #@levels == 1
      @finish!
    else
      @levels[#@levels] = nil
      @_refresh!

  _preview: (item, text) =>
    unless item
      @_cancel_preview!
      return

    @preview or= Preview!

    local buf, preview
    if item.preview
      preview = item\preview text
    if preview
      if preview.text
        buf = ActionBuffer!
        buf\append preview.text
        buf.title = preview.title if preview.title
      elseif preview.file
        buf = @preview\get_buffer preview.file
      elseif preview.buffer
        buf = preview.buffer
      elseif preview.chunk
        buf = preview.chunk.buffer

    if buf
      @editor\preview buf
      if preview.chunk
        @_preview_highlight_chunk(preview.chunk)
        @_preview_popup(@editor, preview.chunk.start_pos, preview.popup) if preview.popup
    else
      @_cancel_preview!

  _preview_highlight_chunk: (chunk, popup) =>
    buffer = chunk.buffer
    line = buffer.lines\at_pos chunk.start_pos
    @editor.line_at_center = line.nr
    highlight.remove_all 'search', buffer
    highlight.remove_all 'search_secondary', buffer
    highlight.apply 'search', buffer, chunk.start_pos, chunk.end_pos - chunk.start_pos + 1

  _preview_popup: (editor, pos, popup_text) =>
    popup = howl.ui.BufferPopup ActionBuffer!
    buf = popup.buffer
    buf\append popup_text
    with popup.view
      .cursor.line = 1
      .base_x = 0

    editor\show_popup popup, {
      position: pos,
      -- keep_alive: true,
    }

  _cancel_preview: =>
    @editor\cancel_preview!

  on_text_changed: (text) =>
    level = @levels[#@levels]
    @remaining_text = text
    @command_line.notification\clear!
    @command_line.notification\hide!

    if level.subitems
      item = level.item
      if item.parse  -- quick selection of an item without pressing enter
        status, matched, opts = pcall -> item\parse text
        if not status
          @command_line.notification\error matched
          @command_line.notification\show!
          return

        if matched
          @remaining_text = opts and opts.remaining_text or ''
          if opts and opts.absolute
            @_jump_to_level matched
          else
            @_enter_level matched
          return

      @_update_widgets!

    elseif level.item.set_value
      level.item\set_value text
      @_preview level.item, text

  finish: (result) =>
    @command_line\finish result
    return true

  on_close: =>
    @_cancel_preview!

  keymap:
    enter: =>
      level = @levels[#@levels]
      if @list_widget.showing
        selection = @list.selection
        item = selection.item or (level.item.get_item and level.item\get_item selection)
        item or= selection

        @remaining_text = ''

        if item.display_items
          @_enter_level item
        elseif item.get_value
          @_enter_level item
        else
          @finish item
      elseif level.new_item
        @finish level.new_item
      elseif level.item.set_value
        @finish level.item

    binding_for:
      ['cursor-up']: =>
        @list\select_prev! if @list_widget.showing

      ['cursor-down']: =>
        @list\select_next! if @list_widget.showing

      ['cursor-page-up']: =>
        @list\prev_page! if @list_widget.showing

      ['cursor-page-down']: =>
        @list\next_page! if @list_widget.showing

    tab: => @list\select_next! if @list_widget.showing
    shift_tab: => @list\select_prev! if @list_widget.showing

    backspace: =>
      return false unless @command_line.text.is_empty
      @_exit_level!

    escape: => @finish!

    ctrl_r: => @_refresh!

    on_unhandled: (event, source, translations, self) ->
      explorer_item = @levels[#@levels].item
      selected_item = @list.selection and @list.selection.item
      return unless explorer_item
      if explorer_item and explorer_item.actions
        actions = explorer_item\actions!
        for _, action_def in pairs actions
          for keystroke in *action_def.keystrokes
            if #[t for t in *translations when t == keystroke] > 0
              return ->
                status, err = pcall -> self.fire_action self, action_def, explorer_item, selected_item
                if not status
                  error err

  fire_action: (action_def, item, selected_item) =>
    status, err = pcall -> action_def.handler item, selected_item
    unless status
      error "Cannot fire action #{action_def.name}: #{err}"
    @_refresh!
