return {
  {
    category = "Insert Mode",
    title = "Append at End",
    description = "Add a semicolon at the end of this statement",
    teach = { "A" },
    hint = "A enters insert mode at the END of the current line",
    par = 3,
    buffer_lines = {
      "let result = a + b",
    },
    cursor_start = { 1, 4 },
    goal = {
      buffer_lines = {
        "let result = a + b;",
      },
    },
  },
  {
    category = "Insert Mode",
    title = "Insert at Start",
    description = "Add 'export ' at the beginning of this line",
    teach = { "I" },
    hint = "I enters insert mode at the first non-blank character of the line",
    par = 9,
    buffer_lines = {
      "default function handleRequest(req) {",
    },
    cursor_start = { 1, 20 },
    goal = {
      buffer_lines = {
        "export default function handleRequest(req) {",
      },
    },
  },
  {
    category = "Insert Mode",
    title = "Open Line Below",
    description = "Add a return statement inside the function",
    teach = { "o" },
    hint = "o opens a new line BELOW the cursor and enters insert mode",
    par = 18,
    buffer_lines = {
      "function double(x) {",
      "}",
    },
    cursor_start = { 1, 0 },
    goal = {
      buffer_lines = {
        "function double(x) {",
        "  return x * 2;",
        "}",
      },
    },
  },
  {
    category = "Insert Mode",
    title = "Open Line Above",
    description = "Add a comment line above the function",
    teach = { "O" },
    hint = "O opens a new line ABOVE the cursor and enters insert mode",
    par = 34,
    buffer_lines = {
      "def calculate_tax(income, rate):",
      "    return income * rate",
    },
    cursor_start = { 1, 0 },
    goal = {
      buffer_lines = {
        "# Calculate tax for given income",
        "def calculate_tax(income, rate):",
        "    return income * rate",
      },
    },
  },
  {
    category = "Insert Mode",
    title = "Append After Cursor",
    description = "Insert a closing angle bracket after 'string'",
    teach = { "a" },
    hint = "a enters insert mode AFTER the cursor (one character to the right of i)",
    par = 3,
    buffer_lines = {
      "std::vector<std::string items;",
    },
    cursor_start = { 1, 23 },
    goal = {
      buffer_lines = {
        "std::vector<std::string> items;",
      },
    },
  },
}
