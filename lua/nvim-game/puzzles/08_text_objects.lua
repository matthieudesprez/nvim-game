return {
  {
    category = "Text Objects",
    title = "Change Inner Word",
    description = "Change the variable name 'tmp' to 'result'",
    teach = { "ciw" },
    hint = "ciw changes the entire word under the cursor, regardless of position within it",
    par = 9,
    buffer_lines = {
      "let tmp = processInput(data);",
    },
    cursor_start = { 1, 5 },
    goal = {
      buffer_lines = {
        "let result = processInput(data);",
      },
    },
  },
  {
    category = "Text Objects",
    title = "Change Inside Quotes",
    description = "Change the string 'Hello' to 'Goodbye'",
    teach = { 'ci"' },
    hint = 'ci" changes everything INSIDE the double quotes, keeping the quotes',
    par = 11,
    buffer_lines = {
      'const greeting = "Hello";',
    },
    cursor_start = { 1, 20 },
    goal = {
      buffer_lines = {
        'const greeting = "Goodbye";',
      },
    },
  },
  {
    category = "Text Objects",
    title = "Delete Around Parens",
    description = "Delete the parenthesized condition including the parens",
    teach = { "da(" },
    hint = "da( deletes the parenthesized group AND the parentheses (a = 'around')",
    par = 3,
    buffer_lines = {
      "if (user.isAdmin()) {",
      "  grantAccess();",
      "}",
    },
    cursor_start = { 1, 10 },
    goal = {
      buffer_lines = {
        "if  {",
        "  grantAccess();",
        "}",
      },
    },
  },
  {
    category = "Text Objects",
    title = "Delete Around Word",
    description = "Delete the word 'very' including surrounding space",
    teach = { "daw" },
    hint = "daw deletes the word AND one adjacent space (a = 'around')",
    par = 3,
    buffer_lines = {
      "This is a very important message.",
    },
    cursor_start = { 1, 12 },
    goal = {
      buffer_lines = {
        "This is a important message.",
      },
    },
  },
  {
    category = "Text Objects",
    title = "Change Inside Braces",
    description = "Replace the function body with a single return",
    teach = { "ci{" },
    hint = "ci{ changes everything INSIDE the curly braces",
    par = 24,
    buffer_lines = {
      "function isEven(n) {",
      "  const remainder = n % 2;",
      "  if (remainder === 0) {",
      "    return true;",
      "  }",
      "  return false;",
      "}",
    },
    cursor_start = { 3, 0 },
    goal = {
      buffer_lines = {
        "function isEven(n) {",
        "  return n % 2 === 0;",
        "}",
      },
    },
  },
}
