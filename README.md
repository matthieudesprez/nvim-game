```
░█▀█░█░█░▀█▀░█▄█░░░█▀▀░█▀█░█▄█░█▀▀░
░█░█░▀▄▀░░█░░█░█░░░█░█░█▀█░█░█░█▀▀░
░▀░▀░░▀░░▀▀▀░▀░▀░░░▀▀▀░▀░▀░▀░▀░▀▀▀░
```

**Learn Vim keymaps through puzzles!**

A Neovim plugin that teaches you Vim motions, operators, and text objects through 58 interactive puzzles across 12 progressive categories.

## Features

- **12 categories** covering the full Vim motion vocabulary — from `hjkl` basics to search with `/`, `n`, `*`
- **58 puzzles** with star ratings based on keystroke efficiency
- **Challenge Mode** — hints hidden, test what you've learned
- **Random Track** — shuffle puzzles from all categories for mixed practice
- **Progress tracking** — saved between sessions, pick up where you left off
- **Floating window UI** — plays inside Neovim, no external dependencies

## Categories

| # | Category | Keys |
|---|----------|------|
| 1 | Basic Motions | `h`, `j`, `k`, `l` |
| 2 | Word Motions | `w`, `b`, `e` |
| 3 | Line Motions | `0`, `$`, `^` |
| 4 | Find/Till | `f`, `F`, `t`, `T`, `;`, `,` |
| 5 | Vertical Nav | `gg`, `G`, `{n}G` |
| 6 | Insert Mode | `i`, `a`, `I`, `A`, `o`, `O` |
| 7 | Operators | `d`, `c` + motions |
| 8 | Text Objects | `iw`, `aw`, `i"`, `a(` |
| 9 | Yank & Put | `y`, `p`, `P` |
| 10 | Visual Mode | `v`, `V` + ops |
| 11 | Dot Repeat | `.` |
| 12 | Search | `/`, `n`, `N`, `*`, `#` |

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "matthieudesprez/nvim-game",
  cmd = "NvimGame",
  opts = {},
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "matthieudesprez/nvim-game",
  config = function()
    require("nvim-game").setup()
  end,
}
```

## Usage

```vim
:NvimGame              " Open the main menu
:NvimGame continue     " Resume from last incomplete puzzle
:NvimGame reset        " Clear all progress
```

### In-game keymaps

| Key | Action |
|-----|--------|
| `<Leader>r` | Reset current puzzle |
| `<Leader>s` | Skip puzzle |
| `<Leader>h` | Toggle hint (challenge mode) |
| `<Esc><Esc>` | Quit game |
| `<Enter>` | Next puzzle (after success) |
| `q` | Return to menu (after success) |

## Configuration

```lua
require("nvim-game").setup({
  width = 70,          -- floating window width (default: 70)
  height = 20,         -- floating window height (default: 20)
  border = "rounded",  -- border style (default: "rounded")
})
```

## How it works

Each puzzle gives you a buffer with a starting cursor position and a goal — either move the cursor to a target position, or edit the buffer to match a target. Your keystrokes are counted and rated against a par value:

| Stars | Keystrokes |
|-------|------------|
| ★★★ | <= par |
| ★★ | <= 1.5x par |
| ★ | <= 2.5x par |

Progress is saved to `stdpath('data')/nvim-game-progress.json`.

## Requirements

- Neovim >= 0.9
- No external dependencies

## License

MIT
