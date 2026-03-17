return {
  {
    category = "Yank & Put",
    title = "Duplicate Line",
    description = "Duplicate this import line",
    teach = { "yy", "p" },
    hint = "yy yanks the entire current line, p puts (pastes) it below",
    par = 3,
    buffer_lines = {
      'import React from "react";',
    },
    cursor_start = { 1, 0 },
    goal = {
      buffer_lines = {
        'import React from "react";',
        'import React from "react";',
      },
    },
  },
  {
    category = "Yank & Put",
    title = "Duplicate and Edit",
    description = "Duplicate the border line, then change 'border' to 'outline'",
    teach = { "yy", "p", "cw" },
    hint = "yyp duplicates the line. Then use cw to change the property name.",
    par = 14,
    buffer_lines = {
      ".card {",
      "  border: 1px solid #ccc;",
      "}",
    },
    cursor_start = { 2, 0 },
    goal = {
      buffer_lines = {
        ".card {",
        "  border: 1px solid #ccc;",
        "  outline: 1px solid #ccc;",
        "}",
      },
    },
  },
  {
    category = "Yank & Put",
    title = "Paste Above",
    description = "Copy line 1 and paste it above line 4",
    teach = { "yy", "P" },
    hint = "yy yanks the line, move down with j, then P pastes ABOVE the cursor line",
    par = 5,
    buffer_lines = {
      "#!/usr/bin/env python3",
      "",
      "import os",
      "import sys",
    },
    cursor_start = { 1, 0 },
    goal = {
      buffer_lines = {
        "#!/usr/bin/env python3",
        "",
        "import os",
        "#!/usr/bin/env python3",
        "import sys",
      },
    },
  },
  {
    category = "Yank & Put",
    title = "Yank Word and Paste",
    description = "Copy 'username' and paste it before the closing paren on line 2",
    teach = { "yiw", "p", "P" },
    hint = "yiw yanks the word under cursor. Navigate then use P to paste before cursor",
    par = 7,
    buffer_lines = {
      "const username = getUserInput();",
      'console.log("Welcome, " + );',
    },
    cursor_start = { 1, 6 },
    goal = {
      buffer_lines = {
        "const username = getUserInput();",
        'console.log("Welcome, " + username);',
      },
    },
  },
  {
    category = "Yank & Put",
    title = "Copy Function",
    description = "Duplicate the entire function signature line",
    teach = { "yy", "p" },
    hint = "yy yanks the whole line, p pastes below the current line",
    par = 3,
    buffer_lines = {
      "async function fetchUsers(endpoint, options) {",
      "  const response = await fetch(endpoint, options);",
      "  return response.json();",
      "}",
    },
    cursor_start = { 1, 0 },
    goal = {
      buffer_lines = {
        "async function fetchUsers(endpoint, options) {",
        "async function fetchUsers(endpoint, options) {",
        "  const response = await fetch(endpoint, options);",
        "  return response.json();",
        "}",
      },
    },
  },
}
