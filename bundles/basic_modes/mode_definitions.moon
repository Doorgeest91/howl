common_auto_pairs = {
  '(': ')'
  '[': ']'
  '{': '}'
  '"': '"'
  "'": "'"
}

{
  ada:
    extensions: { 'ada', 'adb', 'ads' }
    comment_syntax: '--'
    auto_pairs: {
      '(': ')'
      '"': '"'
    }

  antlr:
    extensions: 'g'
    comment_syntax: '//'
    auto_pairs: {
      '[': ']'
      "'": "'"
    }

  awk:
    extensions: 'awk'
    shebangs: '[/ ]awk$'
    comment_syntax: '#'
    auto_pairs: common_auto_pairs

  bash:
    extensions: { 'bash', 'bashrc', 'bash_profile', 'configure', 'csh', 'sh', 'zsh' }
    shebangs: {'[/ ]sh$', '[/ ]bash$' }
    comment_syntax: '#'
    auto_pairs: common_auto_pairs

  batch:
    extensions: { 'bat', 'cmd' }
    comment_syntax: 'REM'
    auto_pairs: {
      '%': '%'
      '"': '"'
    }

  bibtex:
    extensions: 'bib'
    auto_pairs: {
      '{': '}'
      '"': '"'
    }

  caml:
    extensions: { 'caml', 'ml', 'mli', 'mll', 'mly' }
    comment_syntax: { '(*', '*)' }
    auto_pairs: {
      '"': '"'
      '(': ')'
      '[': ']'
    }

  cmake:
    extensions: { 'cmake', 'ctest' }
    patterns: { '.cmake.in$', '.ctest.in$' }
    comment_syntax: '#'
    auto_pairs: {
      '(': ')'
      '"': '"'
      '{': '}'
    }

  coffeescript:
    extensions: 'coffee'
    comment_syntax: '#'
    auto_pairs: common_auto_pairs

  csharp:
    extensions: 'cs'
    comment_syntax: '//'
    auto_pairs: common_auto_pairs

  cpp:
    extensions: { 'c', 'cc', 'cpp', 'cxx', 'c++', 'h', 'hh', 'hpp', 'hxx', 'h++' }
    comment_syntax: { '/*', '*/' }
    auto_pairs: common_auto_pairs
    parent: 'curly_mode'

  dlang:
    extensions: 'd'
    comment_syntax: '//'
    auto_pairs: common_auto_pairs
    parent: 'curly_mode'

  desktop:
    extensions: 'desktop'
    comment_syntax: '#'
    auto_pairs: {
      '[': ']'
    }

  diff:
    extensions: { 'diff', 'patch' }
    patterns: { '%.git/COMMIT_EDITMSG$' }
    auto_pairs: {
      '(': ')'
      '[': ']'
      '{': '}'
      '"': '"'
    }

  dot:
    extensions: { 'dot', 'gv' }
    comment_syntax: '//'
    auto_pairs: {
      '{': '}'
      '[': ']'
      '"': '"'
    }

  eiffel:
    extensions: { 'e', 'eif' }
    comment_syntax: '--'
    auto_pairs: common_auto_pairs

  erlang:
    extensions: { 'erl', 'hrl' }
    comment_syntax: '%'
    auto_pairs: common_auto_pairs

  fsharp:
    extensions: 'fs'
    comment_syntax: '//'
    auto_pairs: {
      '{': '}'
      '(': ')'
      '"': '"'
    }

  forth:
    extensions: { 'f', 'forth', 'frt', 'fth' }
    comment_syntax: '\\'
    auto_pairs: {
      '(': ')'
      '"': '"'
      "'": "'"
    }

  fortran:
    extensions: { 'for', 'fort', 'fpp', 'f77', 'f90', 'f95', 'f03', 'f08' }
    comment_syntax: '!'
    auto_pairs: {
      '(': ')'
      '"': '"'
      "'": "'"
    }

  gettext:
    extensions: { 'po', 'pot' }
    comment_syntax: '#'
    auto_pairs: {
      '"': '"'
    }

  gnuplot:
    extensions: { 'dem', 'plt' }
    comment_syntax: '#'
    auto_pairs: {
      '[': ']'
      '"': '"'
    }

  go:
    extensions: 'go'
    comment_syntax: '//'
    auto_pairs: common_auto_pairs
    parent: 'curly_mode'

  groovy:
    extensions: { 'groovy', 'gvy' }
    comment_syntax: '//'
    auto_pairs: common_auto_pairs
    parent: 'curly_mode'

  haskell:
    extensions: 'hs'
    comment_syntax: '--'
    auto_pairs: common_auto_pairs

  hypertext:
    extensions: { 'htm', 'html', 'shtm', 'shtml', 'xhtml' }
    comment_syntax: { '<!--', '-->' }
    auto_pairs: {
      '(': ')'
      '[': ']'
      '{': '}'
      '"': '"'
      "'": "'"
      '<': '>'
    }

  ini:
    extensions: { 'cfg', 'cnf', 'inf', 'ini', 'reg' }
    comment_syntax: ';'
    auto_pairs: {
      '[': ']'
      '"': '"'
    }

  io:
    extensions: 'io'
    comment_syntax: '//'
    auto_pairs: common_auto_pairs

  java:
    extensions: { 'java', 'bsh' }
    comment_syntax: '//'
    auto_pairs: common_auto_pairs
    parent: 'curly_mode'

  jsp:
    extensions: 'jsp'
    comment_syntax: { '<%--', '--%>' }
    auto_pairs: {
      '(': ')'
      '[': ']'
      '{': '}'
      '"': '"'
      "'": "'"
      '<': '>'
    }

  json:
    extensions: 'json'
    auto_pairs: {
      '(': ')'
      '[': ']'
      '{': '}'
      '"': '"'
    }
    parent: 'curly_mode'

  latex:
    extensions: { 'bbl', 'dtx', 'ins', 'ltx', 'tex', 'sty' }
    comment_syntax: '%'
    auto_pairs: {
      '(': ')'
      '[': ']'
      '{': '}'
      '"': '"'
    }

  makefile:
    extensions: { 'iface', 'mak' }
    patterns: { 'GNUmakefile$', 'Makefile$' }
    comment_syntax: '#'
    auto_pairs: common_auto_pairs

    keymap: {
      tab: (editor) ->
        if editor.current_context.prefix.blank
          editor\insert '\t'
        else
          false
    }

  objective_c:
    extensions: {'m', 'mm', 'objc' }
    comment_syntax: '//'
    auto_pairs: common_auto_pairs
    parent: 'curly_mode'

  pascal:
    extensions: { 'dpk', 'dpr', 'p', 'pas' }
    comment_syntax: '//'
    auto_pairs: common_auto_pairs

  perl:
    extensions: { 'al', 'perl', 'pl', 'pm', 'pod' }
    shebangs: '[/ ]perl.*$'
    comment_syntax: '#'
    auto_pairs: common_auto_pairs
    parent: 'curly_mode'

  php:
    extensions: { 'inc', 'php', 'php3', 'php4', 'phtml' }
    shebangs: '[/ ]php.*$'
    comment_syntax: '//'
    auto_pairs: {
      '(': ')'
      '[': ']'
      '{': '}'
      '"': '"'
      "'": "'"
      '<': '>'
    }
    parent: 'curly_mode'

  pike:
    extensions: { 'pike', 'pmod' }
    comment_syntax: '//'
    auto_pairs: common_auto_pairs
    parent: 'curly_mode'

  postscript:
    extensions: { 'ps', 'eps' }
    comment_syntax: '%'
    auto_pairs: {
      '(': ')'
      '[': ']'
      '<': '>'
      '{': '}'
    }

  prolog:
    extensions: 'prolog'
    comment_syntax: '%'
    auto_pairs: {
      '(': ')'
      '[': ']'
    }

  properties:
    extensions: 'properties'
    comment_syntax: '#'
    auto_pairs: {
      '"': '"'
    }

  python:
    extensions: { 'sc', 'py', 'pyw' }
    shebangs: '[/ ]python.*$'
    comment_syntax: '#'
    indent_after_patterns: {
      { ':%s*$', 'else:%s*$' }
    }
    dedent_patterns: { 'else:%s*$'}
    auto_pairs: common_auto_pairs

  rstats:
    extensions: { 'r', 'rout', 'rhistory', 'rt' }
    patterns: { 'Rout%.save$', 'Rout%.fail$' }
    comment_syntax: '#'
    auto_pairs: common_auto_pairs

  rebol:
    extensions: 'reb'
    comment_syntax: ';'
    auto_pairs: {
      '(': ')'
      '[': ']'
      '{': '}'
      '"': '"'
    }

  rails: {} -- only used for sublexing

  rhtml:
    extensions: { 'erb', 'rhtml' }
    comment_syntax: { '<%-#', '-%>' }
    auto_pairs: {
      '(': ')'
      '[': ']'
      '{': '}'
      '"': '"'
      "'": "'"
      '<': '>'
    }

  scala:
    extensions: 'scala'
    comment_syntax: '/'
    auto_pairs: common_auto_pairs
    parent: 'curly_mode'

  scheme:
    extensions: { 'sch', 'scm' }
    comment_syntax: ';'
    auto_pairs: {
      '(': ')'
      '[': ']'
      '{': '}'
      '"': '"'
    }

  smalltalk:
    extensions: { 'changes', 'st', 'sources' }
    comment_syntax: { '"', '"' }
    auto_pairs: {
      '(': ')'
      '[': ']'
      "'": "'"
    }

  sql:
    extensions: { 'sql', 'ddl' }
    comment_syntax: '--'
    auto_pairs: {
      '(': ')'
      "'": "'"
    }

  tcl:
    extensions: { 'tcl', 'tk' }
    comment_syntax: '#'
    auto_pairs: {
      '(': ')'
      '[': ']'
      '"': '"'
      '{': '}'
    }

  vala:
    extensions: 'vala'
    comment_syntax: '//'
    auto_pairs: common_auto_pairs
    parent: 'curly_mode'

  verilog:
    extensions: { 'v', 'ver' }
    comment_syntax: '//'
    auto_pairs: {
      '(': ')'
      '[': ']'
      '"': '"'
      '{': '}'
    }

  vhdl:
    extensions: { 'vh', 'vhd', 'vhdl' }
    comment_syntax: '--'
    auto_pairs: {
      '(': ')'
      "'": "'"
    }

  xml:
    extensions: { 'dtd', 'svg', 'xml', 'xsd', 'xsl', 'xslt', 'xul' }
    comment_syntax: { '<!--', '-->' }
    auto_pairs: {
        '(': ')'
        '[': ']'
        '"': '"'
        '<': '>'
      }
    indent_after_patterns: {
      '<[^/]+>%s*$'
    }
    dedent_patterns: {
      '^%s*</[^<]+>%s*$'
    }
}
