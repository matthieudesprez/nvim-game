return {
  {
    category = "Operators",
    title = "Delete Word",
    description = "Delete the mistyped word 'cnosle' at the start",
    teach = { "dw" },
    hint = "dw deletes from cursor to the start of the next word",
    par = 2,
    buffer_lines = {
      "cnosle console.log(message);",
    },
    cursor_start = { 1, 0 },
    goal = {
      buffer_lines = {
        "console.log(message);",
      },
    },
  },
  {
    category = "Operators",
    title = "Delete to End",
    description = "Remove everything after 'SELECT *' to simplify the query",
    teach = { "D", "d$" },
    hint = "D (or d$) deletes from cursor to end of line",
    par = 1,
    buffer_lines = {
      "SELECT * FROM users WHERE active = 1 ORDER BY created_at;",
    },
    cursor_start = { 1, 8 },
    goal = {
      buffer_lines = {
        "SELECT *",
      },
    },
  },
  {
    category = "Operators",
    title = "Change Word",
    description = "Change 'width' to 'height' in the CSS property",
    teach = { "cw" },
    hint = "cw deletes to the next word boundary and enters insert mode",
    par = 9,
    buffer_lines = {
      ".container {",
      "  max-width: 1200px;",
      "  width: 100%;",
      "}",
    },
    cursor_start = { 3, 2 },
    goal = {
      buffer_lines = {
        ".container {",
        "  max-width: 1200px;",
        "  height: 100%;",
        "}",
      },
    },
  },
  {
    category = "Operators",
    title = "Delete Line",
    description = "Delete the debug print statement on line 3",
    teach = { "dd" },
    hint = "dd deletes the entire current line",
    par = 2,
    buffer_lines = {
      "fn fibonacci(n: u64) -> u64 {",
      "    if n <= 1 { return n; }",
      '    println!("DEBUG: n = {}", n);',
      "    fibonacci(n - 1) + fibonacci(n - 2)",
      "}",
    },
    cursor_start = { 3, 0 },
    goal = {
      buffer_lines = {
        "fn fibonacci(n: u64) -> u64 {",
        "    if n <= 1 { return n; }",
        "    fibonacci(n - 1) + fibonacci(n - 2)",
        "}",
      },
    },
  },
  {
    category = "Operators",
    title = "Change to End",
    description = "Replace everything after the colon with 'localhost'",
    teach = { "C", "c$" },
    hint = "C (or c$) changes from cursor to end of line",
    par = 11,
    buffer_lines = {
      "server:",
      "  host: old-server.internal.corp",
      "  port: 3000",
    },
    cursor_start = { 2, 8 },
    goal = {
      buffer_lines = {
        "server:",
        "  host: localhost",
        "  port: 3000",
      },
    },
  },
}
