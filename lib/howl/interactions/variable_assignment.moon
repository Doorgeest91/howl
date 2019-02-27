--- Copyright 2012-2017 The Howl Developers
--- License: MIT (see LICENSE.md at the top-level directory of the distribution)

howl.interact.register
  name: 'get_variable_assignment'
  description: 'Get config variable and value selected by user'
  handler: (opts={}) ->
    howl.interact.explore
      prompt: opts.prompt
      path: {howl.explorers.ConfigExplorer howl.app.editor.buffer}
      text: opts.text
      help: opts.help
      transform_result: (result) ->
        target = result.target
        {
          var: target.def.name
          target: target.config_obj
          value: result.value
          scope_name: target.scope_layer_name
          text: target\display_path! .. target\to_s result.value
        }
