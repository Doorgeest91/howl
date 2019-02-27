-- Copyright 2019 The Howl Developers
-- License: MIT (see LICENSE.md at the top-level directory of the distribution)

{:config} = howl
{:StyledText, :markup} = howl.ui

append = table.insert

get_vars = ->
  defs = [def for _, def in pairs config.definitions]
  table.sort defs, (a, b) -> a.name < b.name
  return defs

stringify = (value, to_s) ->
  return to_s(value) if type(value) != 'table'
  [stringify o, to_s for o in *value]

get_help = ->
  help = howl.ui.HelpContext!
  help\add_section
    heading: 'Steps'
    text: '1. Select a variable
2. Select the scope for the variable
3. Select or type a value and press <keystroke>enter</>'
  help

class ConfigValue
  new: (@target) =>
  preview: (text) => @target\preview text
  display_row: => @target\display_row!
  display_path: => @target\display_path!
  get_value: => @target\current_value_str!
  set_value: (value) => @value = if value.is_blank then nil else value
  display_title: => "Enter value for #{@target.def.name}"
  get_help: => get_help!

class ConfigOption
  new: (@target, @option) =>
    @value = if type(@option) == 'table' then @option[1] else @target\to_s @option
    @option_row = if type(@option) == 'table' then @option else @value
  display_row: => @option_row
  preview: => @target\preview @value

class ConfigOptions
  new: (@target) => @options = [ConfigOption(@target, option) for option in *@target.options]
  display_items: =>
    current_value = @target\current_value_str!
    for option in *@options
      if option.value == current_value
        return @options, selected_item: option
    return @options
  preview: (text) => @target\preview text
  display_row: => @target\display_row!
  display_path: => @target\display_path!
  display_title: => "Select value for #{@target.def.name}"
  get_help: => get_help!

class Target
  -- Represents a (def, config, scope, layer) that uniquely
  -- identifes a variable at a specific scope/layer
  new: (@def, @scope_name, @layer, @config_obj, @description, @options) =>
    @scope_layer_name = @scope_name .. (if @layer then "[#{@layer}]" else '')
    if @layer
      @config_obj = @config_obj.for_layer @layer

  to_s: (value) =>
    return '' if value == nil
    s = @def.tostring or tostring
    return s value

  current_value: => @config_obj[@def.name]
  current_value_str: => @to_s @current_value!

  get_explorer: => if @options then ConfigOptions self else ConfigValue self

  display_row: => { @scope_layer_name, @current_value_str!, @description}
  display_path: => @def.name .. '@' .. @scope_layer_name .. '='

  preview: (text) =>
    current_value = @current_value!

    preview_value = (value) ->
      if type(value) == 'table'
        StyledText.for_table(value, {{style: 'string'}}) .. markup.howl "<comment>#{#value} items</>"
      elseif value == nil
        markup.howl '<comment>nil</>'
      else
        markup.howl "<string>#{value}</>"

    preview_text = markup.howl "<h1>#{@def.name} at #{@scope_layer_name}</>\n\n"
    long_description = "#{@def.description}\n#{@description}"
    preview_text ..= StyledText long_description, 'comment'
    preview_text ..= markup.howl '\n\n<keyword>Current value:\n</keyword>'
    preview_text ..= preview_value current_value

    if text
      preview_text ..= markup.howl '\n\n<keyword>New value:</>\n'
      if text.is_blank
        preview_text ..= markup.howl '<comment>nil</>'
      else
        new_value = if @def.convert then @def.convert(text) else text
        validate_ok, _ = pcall -> config.validate @def, new_value
        if validate_ok
          preview_text ..= preview_value new_value
        else
          preview_text ..= StyledText "Invalid value '#{new_value}' (#{@def.type_of} expected)", 'error'
    return {title: "About: #{@def.name}", text: preview_text}


get_options_for = (def) ->
  local options
  if def.options
    options = def.options
    options = options! if callable options

    table.sort options, (a, b) ->
      to_s = tostring or def.tostring
      a_str = stringify a, to_s
      b_str = stringify b, to_s
      return a_str < b_str if type(a_str) != 'table'
      return a_str[1] < b_str[1]
  options

scope_items = (def, buffer) ->
  options = get_options_for def
  items = {}
  append items, Target(def, 'global', nil, config, '', options)\get_explorer!
  return items if def.scope == 'global' or not buffer

  mode_layer = buffer.mode.config_layer
  mode_name = buffer.mode.name
  append items, Target(
    def, 'global', mode_layer, config, "For all buffers with mode #{mode_name}", options)\get_explorer!

  if buffer.file
    project = howl.Project.for_file buffer.file
    if project
      append items, Target(
        def, 'project', nil, project.config,
        "For all files under #{project.root.short_path}",
        options)\get_explorer!

      append items, Target(
        def, 'project', mode_layer, project.config,
        "For all files under #{project.root.short_path} with mode #{mode_name}", options)\get_explorer!

  append items, Target(
    def, 'buffer', nil, buffer.config,
    "For #{buffer.title} only", options)\get_explorer!

  return items

class ConfigVar
  -- lists all scopes for a single configuration variable
  new: (@def, @buffer) =>
    @scopes = scope_items @def, @buffer
  display_row: => {@def.name, @def.description}
  display_title: => "Select scope for #{@def.name}"
  preview: =>
    preview_text = markup.howl "<h1>#{@def.name}</>\n\n"
    preview_text ..= StyledText @def.description, 'comment'
    s = @def.tostring or tostring
    preview_text ..= markup.howl "\n\n<keyword>Current value:</>"
    preview_text ..= markup.howl("\n<key>global</> ") .. StyledText s(config[@def.name]), 'string'
    if not @def.global
      preview_text ..= markup.howl("\n<key>buffer</> ") .. StyledText s(@buffer.config[@def.name]), 'string'
    {text: preview_text, title: "About: #{@def.name}"}
  display_items: => @scopes
  display_columns: => {
    { style: 'key' }
    { style: 'string' }
    { style: 'comment' }
  }
  display_path: => @def.name .. '@'
  parse: (text) =>
    if text == '' and #@scopes == 1
      -- if we have only one scope (expected for global vars), auto jump to the config value as soon as this var is selected
      return @scopes[1]

    scope, remaining_text = text\match '([%w]+)=(.*)'
    return unless scope
    for scope_option in *@scopes
      scope_layer_name = scope_option.target.scope_layer_name
      if scope_layer_name == scope
        return scope_option, :remaining_text
  get_help: => get_help!

class ConfigExplorer
  -- lists all configuration variables available
  new: (@buffer) =>
  display_items: => [ConfigVar(def, @buffer) for def in *get_vars!]
  display_title: => 'Select configuration variable'
  display_columns: => {
    {'style': 'string'}, {'style': 'comment'}
  }
  parse: (text) =>
    name, remaining_text = text\match '([%w_]+)@(.*)'
    return unless name
    def = config.definitions[name]
    if def
      return ConfigVar(def, @buffer), :remaining_text
  get_help: => get_help!
