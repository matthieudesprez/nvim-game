return {
  {
    category = "Visual Mode",
    title = "Delete Lines",
    description = "Select lines 2-4 and delete them",
    teach = { "V", "d" },
    hint = "V selects the entire line. Use j to extend downward, then d to delete",
    par = 4,
    buffer_lines = {
      "# Production config",
      "# TODO: remove debug settings",
      "# DEBUG = true",
      "# VERBOSE = true",
      "HOST = 0.0.0.0",
      "PORT = 8080",
    },
    cursor_start = { 2, 0 },
    goal = {
      buffer_lines = {
        "# Production config",
        "HOST = 0.0.0.0",
        "PORT = 8080",
      },
    },
  },
  {
    category = "Visual Mode",
    title = "Change Selection",
    description = "Select 'error' and change it to 'warning'",
    teach = { "v", "c" },
    hint = "v starts character-wise visual selection. Move to extend, then c to change",
    par = 11,
    buffer_lines = {
      "logger.error('Connection timed out');",
    },
    cursor_start = { 1, 7 },
    goal = {
      buffer_lines = {
        "logger.warning('Connection timed out');",
      },
    },
  },
  {
    category = "Visual Mode",
    title = "Indent Lines",
    description = "Indent lines 2-3 by one level (4 spaces)",
    teach = { "V", ">" },
    hint = "V selects lines, j extends downward, > indents the selection",
    par = 4,
    buffer_lines = {
      "def greet(name):",
      "msg = f'Hello, {name}!'",
      "print(msg)",
    },
    cursor_start = { 2, 0 },
    goal = {
      buffer_lines = {
        "def greet(name):",
        "    msg = f'Hello, {name}!'",
        "    print(msg)",
      },
    },
  },
  {
    category = "Visual Mode",
    title = "Yank and Paste Lines",
    description = "Copy lines 3-5 and paste them after line 7",
    teach = { "V", "y", "p" },
    hint = "V then j to select lines, y to yank, navigate to target, p to paste below",
    par = 6,
    buffer_lines = {
      "-- Module A",
      "",
      "local function validate(input)",
      "  assert(type(input) == 'string')",
      "end",
      "",
      "-- Module B",
    },
    cursor_start = { 3, 0 },
    goal = {
      buffer_lines = {
        "-- Module A",
        "",
        "local function validate(input)",
        "  assert(type(input) == 'string')",
        "end",
        "",
        "-- Module B",
        "local function validate(input)",
        "  assert(type(input) == 'string')",
        "end",
      },
    },
  },
  {
    category = "Visual Mode",
    title = "Select and Delete",
    description = "Use visual mode with f to select through the semicolon and delete",
    teach = { "v", "f", "d" },
    hint = "v starts selection, f; extends to the semicolon, d deletes the selection",
    par = 4,
    buffer_lines = {
      "const x = 10; const y = 20;",
    },
    cursor_start = { 1, 0 },
    goal = {
      buffer_lines = {
        " const y = 20;",
      },
    },
  },
}
