local M = {}

M.ns = vim.api.nvim_create_namespace("nvim_game")

M.info_buf = nil
M.info_win = nil
M.game_buf = nil
M.game_win = nil
M.diff_buf = nil
M.diff_win = nil
M.game_tab = nil

local highlights = {
  NvimGameTitle     = { fg = "#f9e2af", bold = true },
  NvimGameCategory  = { fg = "#89b4fa", italic = true },
  NvimGameGoal      = { fg = "#a6e3a1" },
  NvimGameHint      = { fg = "#fab387", italic = true },
  NvimGameProgress  = { fg = "#74c7ec" },
  NvimGameSuccess   = { fg = "#a6e3a1", bold = true },
  NvimGameError     = { fg = "#f38ba8", bold = true },
  NvimGameKeystroke = { fg = "#cba6f7", bold = true },
  NvimGameTarget    = { bg = "#45475a" },
  NvimGameSeparator = { fg = "#585b70" },
  NvimGameDim       = { fg = "#6c7086" },
  NvimGameStar      = { fg = "#f9e2af", bold = true },
  NvimGameDiffMatch  = { fg = "#6c7086" },
  NvimGameDiffAdd    = { fg = "#a6e3a1", bg = "#1a3a2a" },
  NvimGameDiffRemove = { fg = "#f38ba8", bg = "#3a1a2a" },
  NvimGameDiffChange = { fg = "#f9e2af", bg = "#3a3a1a" },
}

function M.setup_highlights()
  for name, val in pairs(highlights) do
    vim.api.nvim_set_hl(0, name, val)
  end
end

function M.ensure_tab()
  if M.game_tab and vim.api.nvim_tabpage_is_valid(M.game_tab) then
    if vim.api.nvim_get_current_tabpage() ~= M.game_tab then
      vim.api.nvim_set_current_tabpage(M.game_tab)
    end
    return
  end
  vim.cmd("tabnew")
  M.game_tab = vim.api.nvim_get_current_tabpage()
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
  vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_set_option_value("number", false, { win = win })
  vim.api.nvim_set_option_value("relativenumber", false, { win = win })
  vim.api.nvim_set_option_value("signcolumn", "no", { win = win })
end

function M.close_tab()
  if M.game_tab and vim.api.nvim_tabpage_is_valid(M.game_tab) then
    pcall(vim.api.nvim_set_current_tabpage, M.game_tab)
    pcall(vim.cmd, "tabclose")
  end
  M.game_tab = nil
end

function M.open(puzzle, level_info, render_opts)
  M.setup_highlights()
  M.ensure_tab()
  M.close()

  local config = require("nvim-game").config
  local width = config.width
  local total_height = config.height
  local info_height = 8
  local game_height = total_height - info_height - 1

  local editor_width = vim.o.columns
  local editor_height = vim.o.lines

  -- Check if we need a diff panel (buffer-edit puzzles with enough screen width)
  local has_diff = puzzle.goal and puzzle.goal.buffer_lines and not puzzle.goal.cursor
  local diff_width = 40
  local gap = 2
  if has_diff then
    local available = editor_width - width - gap - 4 -- subtract borders
    if available >= 20 then
      diff_width = math.min(diff_width, available)
    else
      has_diff = false
    end
  end

  local col
  if has_diff then
    col = math.floor((editor_width - (width + gap + diff_width)) / 2)
  else
    col = math.floor((editor_width - width) / 2)
  end
  local row = math.floor((editor_height - total_height) / 2)

  -- Info panel (non-editable, top)
  M.info_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("modifiable", false, { buf = M.info_buf })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = M.info_buf })

  M.info_win = vim.api.nvim_open_win(M.info_buf, false, {
    relative = "editor",
    width = width,
    height = info_height,
    col = col,
    row = row,
    style = "minimal",
    border = config.border,
    title = " nvim-game ",
    title_pos = "center",
    zindex = 50,
  })

  -- Game buffer (editable, bottom)
  M.game_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = M.game_buf })
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = M.game_buf })
  vim.api.nvim_set_option_value("swapfile", false, { buf = M.game_buf })
  vim.api.nvim_set_option_value("expandtab", true, { buf = M.game_buf })
  vim.api.nvim_set_option_value("shiftwidth", 4, { buf = M.game_buf })
  vim.api.nvim_set_option_value("tabstop", 4, { buf = M.game_buf })
  vim.api.nvim_set_option_value("softtabstop", 4, { buf = M.game_buf })

  M.game_win = vim.api.nvim_open_win(M.game_buf, true, {
    relative = "editor",
    width = width,
    height = game_height,
    col = col,
    row = row + info_height + 1,
    style = "minimal",
    border = config.border,
    title = " puzzle ",
    title_pos = "center",
    zindex = 50,
  })

  -- Goal panel (right side, buffer-edit puzzles only)
  if has_diff then
    M.diff_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = M.diff_buf })
    vim.api.nvim_set_option_value("modifiable", false, { buf = M.diff_buf })

    M.diff_win = vim.api.nvim_open_win(M.diff_buf, false, {
      relative = "editor",
      width = diff_width,
      height = game_height,
      col = col + width + gap,
      row = row + info_height + 1,
      border = config.border,
      title = " goal ",
      title_pos = "center",
      zindex = 50,
      focusable = false,
    })

    -- Make it look like a normal text buffer
    vim.api.nvim_set_option_value("number", true, { win = M.diff_win })
    vim.api.nvim_set_option_value("relativenumber", false, { win = M.diff_win })
    vim.api.nvim_set_option_value("signcolumn", "no", { win = M.diff_win })
    vim.api.nvim_set_option_value("foldcolumn", "0", { win = M.diff_win })
    vim.api.nvim_set_option_value("wrap", false, { win = M.diff_win })
    vim.api.nvim_set_option_value("cursorline", false, { win = M.diff_win })
  end

  vim.api.nvim_set_current_win(M.game_win)

  M.set_puzzle_content(puzzle)
  M.render_info(puzzle, level_info, 0, render_opts)
  if has_diff then
    M.render_diff(puzzle)
  end
end

function M.set_puzzle_content(puzzle)
  if not M.game_buf or not vim.api.nvim_buf_is_valid(M.game_buf) then
    return
  end

  vim.api.nvim_set_option_value("modifiable", true, { buf = M.game_buf })
  vim.api.nvim_buf_set_lines(M.game_buf, 0, -1, false, puzzle.buffer_lines)

  -- Clear old extmarks
  vim.api.nvim_buf_clear_namespace(M.game_buf, M.ns, 0, -1)

  -- Position cursor
  if M.game_win and vim.api.nvim_win_is_valid(M.game_win) then
    vim.api.nvim_win_set_cursor(M.game_win, puzzle.cursor_start)
  end

  -- Show target cursor position
  if puzzle.goal and puzzle.goal.cursor then
    local target_row = puzzle.goal.cursor[1] - 1
    local target_col = puzzle.goal.cursor[2]
    local line = puzzle.buffer_lines[puzzle.goal.cursor[1]] or ""
    if target_col ~= nil and target_col < #line then
      local end_col = math.min(target_col + 1, #line)
      vim.api.nvim_buf_set_extmark(M.game_buf, M.ns, target_row, target_col, {
        end_col = end_col,
        hl_group = "NvimGameTarget",
        priority = 100,
      })
    end
    vim.api.nvim_buf_set_extmark(M.game_buf, M.ns, target_row, 0, {
      virt_text = { { " goal", "NvimGameGoal" } },
      virt_text_pos = "eol",
      priority = 100,
    })
  end

  -- Show inline target for buffer-edit puzzles without diff panel
  if puzzle.goal and puzzle.goal.buffer_lines and not puzzle.goal.cursor and not M.diff_win then
    local target_text = table.concat(puzzle.goal.buffer_lines, " | ")
    if #target_text > 60 then
      target_text = target_text:sub(1, 57) .. "..."
    end
    local last_line = #puzzle.buffer_lines - 1
    vim.api.nvim_buf_set_extmark(M.game_buf, M.ns, last_line, 0, {
      virt_lines = {
        { { string.rep("-", 40), "NvimGameSeparator" } },
        { { "Target: " .. target_text, "NvimGameGoal" } },
      },
    })
  end
end

function M.render_diff(puzzle)
  if not M.diff_buf or not vim.api.nvim_buf_is_valid(M.diff_buf) then
    return
  end
  if not puzzle.goal or not puzzle.goal.buffer_lines then
    return
  end

  local goal_lines = puzzle.goal.buffer_lines

  vim.api.nvim_set_option_value("modifiable", true, { buf = M.diff_buf })
  vim.api.nvim_buf_set_lines(M.diff_buf, 0, -1, false, goal_lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = M.diff_buf })
end

function M.render_info(puzzle, level_info, keystroke_count, opts)
  if not M.info_buf or not vim.api.nvim_buf_is_valid(M.info_buf) then
    return
  end

  opts = opts or {}
  vim.api.nvim_set_option_value("modifiable", true, { buf = M.info_buf })

  local completed = level_info.completed or 0
  local total = level_info.total or 1
  local bar_width = 20
  local filled = math.floor((completed / total) * bar_width)
  local bar = string.rep("█", filled) .. string.rep("░", bar_width - filled)

  local teach_str, hint_str
  if opts.challenge and not opts.hint_revealed then
    teach_str = "???"
    hint_str = "Press <Leader>h to reveal"
  else
    teach_str = table.concat(puzzle.teach, ", ")
    hint_str = puzzle.hint or ""
  end

  local title = puzzle.category .. " - " .. puzzle.title
  if opts.challenge then
    title = title .. "  [Challenge]"
  end

  local lines = {
    " " .. title,
    "",
    " Goal: " .. puzzle.description,
    " Keys: " .. teach_str,
    " Hint: " .. hint_str,
    "",
    " [" .. bar .. "] " .. completed .. "/" .. total
        .. "  |  Keystrokes: " .. keystroke_count
        .. (puzzle.par and ("  |  Par: " .. puzzle.par) or ""),
    " <Leader>r reset  |  <Leader>s skip  |  <Esc><Esc> quit",
  }

  vim.api.nvim_buf_set_lines(M.info_buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = M.info_buf })

  -- Highlights
  vim.api.nvim_buf_clear_namespace(M.info_buf, M.ns, 0, -1)
  vim.api.nvim_buf_set_extmark(M.info_buf, M.ns, 0, 0, {
    end_row = 0, end_col = #lines[1], hl_group = "NvimGameTitle",
  })
  vim.api.nvim_buf_set_extmark(M.info_buf, M.ns, 2, 0, {
    end_row = 2, end_col = #lines[3], hl_group = "NvimGameGoal",
  })
  vim.api.nvim_buf_set_extmark(M.info_buf, M.ns, 3, 0, {
    end_row = 3, end_col = #lines[4], hl_group = "NvimGameKeystroke",
  })
  vim.api.nvim_buf_set_extmark(M.info_buf, M.ns, 4, 0, {
    end_row = 4, end_col = #lines[5], hl_group = "NvimGameHint",
  })
  vim.api.nvim_buf_set_extmark(M.info_buf, M.ns, 6, 0, {
    end_row = 6, end_col = #lines[7], hl_group = "NvimGameProgress",
  })
  vim.api.nvim_buf_set_extmark(M.info_buf, M.ns, 7, 0, {
    end_row = 7, end_col = #lines[8], hl_group = "NvimGameDim",
  })
end

function M.show_success(message, solution)
  if not M.info_buf or not vim.api.nvim_buf_is_valid(M.info_buf) then
    return
  end
  vim.api.nvim_set_option_value("modifiable", true, { buf = M.info_buf })
  local msg = " " .. (message or "Correct! Well done!")
  local hint_line = " Press <Enter> for next puzzle  |  q to return to menu"

  local lines = { msg }
  local solution_line = nil
  if solution then
    solution_line = " Optimal: " .. solution
    table.insert(lines, solution_line)
  end
  table.insert(lines, hint_line)
  while #lines < 8 do
    table.insert(lines, "")
  end

  vim.api.nvim_buf_set_lines(M.info_buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = M.info_buf })

  vim.api.nvim_buf_clear_namespace(M.info_buf, M.ns, 0, -1)
  vim.api.nvim_buf_set_extmark(M.info_buf, M.ns, 0, 0, {
    end_row = 0, end_col = #msg, hl_group = "NvimGameSuccess",
  })
  local hint_row = 1
  if solution_line then
    vim.api.nvim_buf_set_extmark(M.info_buf, M.ns, 1, 0, {
      end_row = 1, end_col = #solution_line, hl_group = "NvimGameKeystroke",
    })
    hint_row = 2
  end
  vim.api.nvim_buf_set_extmark(M.info_buf, M.ns, hint_row, 0, {
    end_row = hint_row, end_col = #hint_line, hl_group = "NvimGameDim",
  })
end

function M.show_random_track_results(results)
  M.setup_highlights()
  M.ensure_tab()
  M.close()

  local config = require("nvim-game").config
  local width = config.width
  local height = math.min(#results + 10, vim.o.lines - 4)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = config.border,
    title = " Random Track Results ",
    title_pos = "center",
  })

  local total_keystrokes = 0
  local total_stars = 0
  for _, r in ipairs(results) do
    total_keystrokes = total_keystrokes + r.keystrokes
    total_stars = total_stars + r.stars
  end

  local lines = {
    "",
    "   Random Track Complete!",
    string.format("   %d puzzles  |  %d total keystrokes  |  %s",
      #results, total_keystrokes,
      string.rep("★", math.floor(total_stars / #results)) ..
      string.rep("☆", 3 - math.floor(total_stars / #results))),
    "",
  }

  for i, r in ipairs(results) do
    local star_str = string.rep("★", r.stars) .. string.rep("☆", 3 - r.stars)
    local par_str = r.par and string.format("  (par: %d)", r.par) or ""
    local line = string.format("   %2d. %s  %d keys%s  %s",
      i, star_str, r.keystrokes, par_str, r.title)
    table.insert(lines, line)
  end

  table.insert(lines, "")
  table.insert(lines, "   Press q to return to menu")

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

  -- Highlights
  vim.api.nvim_buf_set_extmark(buf, M.ns, 1, 0, {
    end_row = 1, end_col = #lines[2], hl_group = "NvimGameSuccess",
  })
  vim.api.nvim_buf_set_extmark(buf, M.ns, 2, 0, {
    end_row = 2, end_col = #lines[3], hl_group = "NvimGameProgress",
  })
  for i = 1, #results do
    local line_idx = 3 + i
    vim.api.nvim_buf_set_extmark(buf, M.ns, line_idx, 0, {
      end_row = line_idx, end_col = #lines[line_idx + 1], hl_group = "NvimGameCategory",
    })
  end

  vim.keymap.set("n", "q", function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    require("nvim-game.engine").open_menu()
  end, { buffer = buf, noremap = true, nowait = true })

  vim.keymap.set("n", "<Esc>", function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    require("nvim-game.engine").open_menu()
  end, { buffer = buf, noremap = true, nowait = true })
end

function M.show_menu(categories, progress_data)
  M.setup_highlights()
  M.ensure_tab()
  M.close()

  local config = require("nvim-game").config
  local width = config.width
  local height = config.height + 6
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local menu_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = menu_buf })

  local menu_win = vim.api.nvim_open_win(menu_buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = config.border,
    title = " nvim-game ",
    title_pos = "center",
  })

  local lines = {
    "",
    "   ░█▀█░█░█░▀█▀░█▄█░░░█▀▀░█▀█░█▄█░█▀▀░",
    "   ░█░█░▀▄▀░░█░░█░█░░░█░█░█▀█░█░█░█▀▀░",
    "   ░▀░▀░░▀░░▀▀▀░▀░▀░░░▀▀▀░▀░▀░▀░▀░▀▀▀░",
    "",
    "   Learn Vim keymaps through puzzles!",
    "",
  }

  -- Category entries
  for i, cat in ipairs(categories) do
    local prog = progress_data[cat.id] or { completed = 0, total = cat.total }
    local status
    if prog.completed >= cat.total then
      status = "  ★ done"
    elseif prog.completed > 0 then
      status = string.format("  %d/%d", prog.completed, cat.total)
    else
      status = ""
    end
    local prefix = i < 10 and " " or ""
    local line = string.format("   %s%s. %-40s%s", prefix, tostring(i), cat.name, status)
    table.insert(lines, line)
  end

  table.insert(lines, "")
  table.insert(lines, "   [C] Challenge Mode  |  [R] Random Track")
  table.insert(lines, "")
  table.insert(lines, "   Press number to select  |  q to quit")

  vim.api.nvim_buf_set_lines(menu_buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = menu_buf })

  -- Highlights for title
  for row_idx = 1, 3 do
    vim.api.nvim_buf_set_extmark(menu_buf, M.ns, row_idx, 0, {
      end_row = row_idx, end_col = #lines[row_idx + 1], hl_group = "NvimGameTitle",
    })
  end
  vim.api.nvim_buf_set_extmark(menu_buf, M.ns, 5, 0, {
    end_row = 5, end_col = #lines[6], hl_group = "NvimGameGoal",
  })

  -- Highlight category lines
  for i, _ in ipairs(categories) do
    local line_idx = 6 + i
    vim.api.nvim_buf_set_extmark(menu_buf, M.ns, line_idx, 0, {
      end_row = line_idx, end_col = #lines[line_idx + 1], hl_group = "NvimGameCategory",
    })
  end

  -- Highlight challenge/random line
  local mode_line_idx = 7 + #categories + 1
  if mode_line_idx < #lines then
    vim.api.nvim_buf_set_extmark(menu_buf, M.ns, mode_line_idx, 0, {
      end_row = mode_line_idx, end_col = #lines[mode_line_idx + 1], hl_group = "NvimGameTitle",
    })
  end

  -- Keymaps: numbers to select, q to quit
  for i, cat in ipairs(categories) do
    local key = tostring(i)
    -- For categories > 9, we need letter keys or different approach
    if i <= 9 then
      vim.keymap.set("n", key, function()
        M.close()
        require("nvim-game.engine").start_category(cat.id)
      end, { buffer = menu_buf, noremap = true, nowait = true })
    end
  end

  -- Handle two-digit selection for categories 10+
  if #categories >= 10 then
    vim.keymap.set("n", "1", function()
      -- Wait briefly for second digit
      local ok, char = pcall(vim.fn.getcharstr)
      if ok and char:match("%d") then
        local num = tonumber("1" .. char)
        if num and num <= #categories then
          M.close()
          require("nvim-game.engine").start_category(categories[num].id)
          return
        end
      end
      -- Just "1" -> category 1
      M.close()
      require("nvim-game.engine").start_category(categories[1].id)
    end, { buffer = menu_buf, noremap = true, nowait = true })
  end

  vim.keymap.set("n", "c", function()
    local cat_names = {}
    for _, cat in ipairs(categories) do
      table.insert(cat_names, cat.name)
    end
    M.close()
    vim.ui.select(cat_names, { prompt = "Challenge Mode - Select category:" }, function(_, idx)
      if idx then
        require("nvim-game.engine").start_category(categories[idx].id, 1, { challenge = true })
      end
    end)
  end, { buffer = menu_buf, noremap = true, nowait = true })

  vim.keymap.set("n", "r", function()
    M.close()
    vim.ui.input({ prompt = "Number of puzzles (max 58): " }, function(input)
      if not input then return end
      local count = tonumber(input)
      if not count or count < 1 then
        vim.notify("[nvim-game] Invalid number", vim.log.levels.WARN)
        return
      end
      require("nvim-game.engine").start_random_track(count)
    end)
  end, { buffer = menu_buf, noremap = true, nowait = true })

  vim.keymap.set("n", "q", function()
    M.close()
    M.close_tab()
  end, { buffer = menu_buf, noremap = true, nowait = true })

  vim.keymap.set("n", "<Esc>", function()
    M.close()
    M.close_tab()
  end, { buffer = menu_buf, noremap = true, nowait = true })

  M.info_buf = menu_buf
  M.info_win = menu_win
  M.game_buf = nil
  M.game_win = nil
end

function M.close()
  local wins = { M.info_win, M.game_win, M.diff_win }
  for _, win in ipairs(wins) do
    if win and vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  M.info_win = nil
  M.game_win = nil
  M.info_buf = nil
  M.game_buf = nil
  M.diff_win = nil
  M.diff_buf = nil
end

return M
