local M = {}

local ui = require("nvim-game.ui")
local levels = require("nvim-game.levels")
local progress = require("nvim-game.progress")

M.state = {
  status = "idle", -- idle | menu | playing | success
  current_category = nil,
  current_puzzle_idx = 0,
  current_puzzle = nil,
  keystroke_count = 0,
  on_key_ns = nil,
  augroup = nil,
  challenge_mode = false,
  hint_revealed = false,
  random_track = nil, -- { puzzles, current_idx, results }
}

function M.open_menu()
  M.cleanup()
  M.state.status = "menu"
  local categories = levels.get_categories()
  local progress_data = progress.load()
  ui.show_menu(categories, progress_data)
end

function M.continue_game()
  local prog = progress.load()
  local categories = levels.get_categories()
  for _, cat in ipairs(categories) do
    local cat_prog = prog[cat.id]
    if not cat_prog or cat_prog.completed < cat.total then
      M.start_category(cat.id, cat_prog and cat_prog.completed + 1 or 1)
      return
    end
  end
  M.open_menu()
end

function M.start_category(category_id, start_at, opts)
  M.cleanup()
  opts = opts or {}
  M.state.challenge_mode = opts.challenge or false
  M.state.hint_revealed = false
  M.state.random_track = nil
  M.state.current_category = category_id
  M.state.current_puzzle_idx = (start_at or 1) - 1
  M.next_puzzle()
end

function M.start_random_track(count, opts)
  M.cleanup()
  opts = opts or {}
  M.state.challenge_mode = opts.challenge or false
  M.state.hint_revealed = false

  local all = levels.get_all_puzzles()
  -- Fisher-Yates shuffle
  math.randomseed(os.time() + os.clock() * 1000)
  for i = #all, 2, -1 do
    local j = math.random(i)
    all[i], all[j] = all[j], all[i]
  end

  count = math.min(count, #all)
  local selected = {}
  for i = 1, count do
    table.insert(selected, all[i])
  end

  M.state.random_track = {
    puzzles = selected,
    current_idx = 0,
    results = {},
  }
  M.next_random_puzzle()
end

function M.next_random_puzzle()
  M.cleanup()
  local track = M.state.random_track
  if not track then return end

  track.current_idx = track.current_idx + 1
  if track.current_idx > #track.puzzles then
    -- Track complete - show results
    M.state.status = "idle"
    ui.close()
    vim.defer_fn(function()
      ui.show_random_track_results(track.results)
    end, 100)
    return
  end

  local puzzle = track.puzzles[track.current_idx]
  M.state.current_puzzle = puzzle
  M.state.current_category = nil
  M.state.keystroke_count = 0
  M.state.hint_revealed = false
  M.state.status = "playing"

  local level_info = {
    completed = track.current_idx - 1,
    total = #track.puzzles,
  }

  ui.open(puzzle, level_info, M.get_render_opts())
  M.setup_autocmds()
  M.setup_keystroke_tracking()
  M.setup_game_keymaps()
end

function M.get_render_opts()
  return {
    challenge = M.state.challenge_mode,
    hint_revealed = M.state.hint_revealed,
  }
end

function M.next_puzzle()
  M.cleanup()
  M.state.current_puzzle_idx = M.state.current_puzzle_idx + 1
  local puzzle = levels.get_puzzle(
    M.state.current_category,
    M.state.current_puzzle_idx
  )

  if not puzzle then
    M.state.status = "idle"
    ui.close()
    vim.notify("[nvim-game] Category complete! Well done!", vim.log.levels.INFO)
    vim.defer_fn(function()
      M.open_menu()
    end, 600)
    return
  end

  M.state.current_puzzle = puzzle
  M.state.keystroke_count = 0
  M.state.status = "playing"

  local cat = levels.get_category_info(M.state.current_category)
  local prog = progress.load()
  local level_info = {
    completed = M.state.current_puzzle_idx - 1,
    total = cat.total,
  }

  ui.open(puzzle, level_info, M.get_render_opts())
  M.setup_autocmds()
  M.setup_keystroke_tracking()
  M.setup_game_keymaps()
end

function M.setup_autocmds()
  if M.state.augroup then
    vim.api.nvim_del_augroup_by_id(M.state.augroup)
  end

  M.state.augroup = vim.api.nvim_create_augroup("NvimGame", { clear = true })

  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = M.state.augroup,
    buffer = ui.game_buf,
    callback = function()
      if M.state.status == "playing" then
        M.validate()
      end
    end,
  })

  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = M.state.augroup,
    buffer = ui.game_buf,
    callback = function()
      if M.state.status == "playing" then
        M.validate()
        ui.render_diff(M.state.current_puzzle)
      end
    end,
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    group = M.state.augroup,
    callback = function(ev)
      local closed_win = tonumber(ev.match)
      if closed_win == ui.game_win or closed_win == ui.info_win or closed_win == ui.diff_win then
        vim.schedule(function()
          M.cleanup()
          ui.close()
          ui.close_tab()
        end)
      end
    end,
  })
end

function M.setup_keystroke_tracking()
  if M.state.on_key_ns then
    vim.on_key(nil, M.state.on_key_ns)
    M.state.on_key_ns = nil
  end

  local ns = vim.api.nvim_create_namespace("nvim_game_keys")
  M.state.on_key_ns = ns

  vim.on_key(function(key, typed)
    if M.state.status ~= "playing" then
      return
    end
    if typed and #typed > 0 then
      M.state.keystroke_count = M.state.keystroke_count + 1
      vim.schedule(function()
        if M.state.status ~= "playing" then return end
        local level_info
        if M.state.random_track then
          level_info = {
            completed = M.state.random_track.current_idx - 1,
            total = #M.state.random_track.puzzles,
          }
        else
          local cat = levels.get_category_info(M.state.current_category)
          if not cat then return end
          level_info = {
            completed = M.state.current_puzzle_idx - 1,
            total = cat.total,
          }
        end
        ui.render_info(M.state.current_puzzle, level_info, M.state.keystroke_count, M.get_render_opts())
      end)
    end
  end, ns)
end

function M.validate()
  local puzzle = M.state.current_puzzle
  if not puzzle or not puzzle.goal then
    return
  end

  local goal_met = true

  if puzzle.goal.cursor then
    if not ui.game_win or not vim.api.nvim_win_is_valid(ui.game_win) then
      return
    end
    local cursor = vim.api.nvim_win_get_cursor(ui.game_win)
    if cursor[1] ~= puzzle.goal.cursor[1] then
      goal_met = false
    elseif puzzle.goal.cursor[2] ~= nil and cursor[2] ~= puzzle.goal.cursor[2] then
      goal_met = false
    end
  end

  if puzzle.goal.buffer_lines then
    if not ui.game_buf or not vim.api.nvim_buf_is_valid(ui.game_buf) then
      return
    end
    local current_lines = vim.api.nvim_buf_get_lines(ui.game_buf, 0, -1, false)
    if #current_lines ~= #puzzle.goal.buffer_lines then
      goal_met = false
    else
      for i, line in ipairs(puzzle.goal.buffer_lines) do
        local current_normalized = current_lines[i]:gsub("\t", "    ")
        local goal_normalized = line:gsub("\t", "    ")
        if current_normalized ~= goal_normalized then
          goal_met = false
          break
        end
      end
    end
  end

  if goal_met then
    M.on_success()
  end
end

function M.on_success()
  M.state.status = "success"

  -- Stop keystroke tracking
  if M.state.on_key_ns then
    vim.on_key(nil, M.state.on_key_ns)
    M.state.on_key_ns = nil
  end

  -- Final render_info so keystroke count is up to date
  local level_info
  if M.state.random_track then
    level_info = {
      completed = M.state.random_track.current_idx - 1,
      total = #M.state.random_track.puzzles,
    }
  else
    local cat = levels.get_category_info(M.state.current_category)
    if cat then
      level_info = {
        completed = M.state.current_puzzle_idx - 1,
        total = cat.total,
      }
    end
  end
  if level_info then
    ui.render_info(M.state.current_puzzle, level_info, M.state.keystroke_count, M.get_render_opts())
  end

  local puzzle = M.state.current_puzzle
  local stars = 3
  if puzzle.par then
    local ratio = M.state.keystroke_count / puzzle.par
    if ratio > 2.5 then
      stars = 0
    elseif ratio > 1.5 then
      stars = 1
    elseif ratio > 1 then
      stars = 2
    end
  end

  local star_str = string.rep("★", stars) .. string.rep("☆", 3 - stars)
  local msg = string.format(
    "%s  %d keystrokes%s",
    star_str,
    M.state.keystroke_count,
    puzzle.par and ("  (par: " .. puzzle.par .. ")") or ""
  )

  if M.state.challenge_mode then
    local teach_str = table.concat(puzzle.teach, ", ")
    msg = msg .. "  |  Solution: " .. teach_str
    if puzzle.par then
      local diff = M.state.keystroke_count - puzzle.par
      if diff > 0 then
        msg = msg .. string.format("  (+%d over par)", diff)
      elseif diff == 0 then
        msg = msg .. "  (perfect!)"
      else
        msg = msg .. string.format("  (%d under par!)", -diff)
      end
    end
  end

  local solution_str = nil
  if puzzle.solution then
    solution_str = string.format("%s  (%d keys)", puzzle.solution, #puzzle.solution)
  end
  ui.show_success(msg, solution_str)

  -- Save progress for category-based play
  if M.state.current_category then
    progress.mark_completed(
      M.state.current_category,
      M.state.current_puzzle_idx,
      M.state.keystroke_count,
      stars
    )
  end

  -- Store result for random track
  if M.state.random_track then
    table.insert(M.state.random_track.results, {
      title = puzzle.title,
      category = puzzle.category,
      keystrokes = M.state.keystroke_count,
      par = puzzle.par,
      stars = stars,
    })
  end

  -- Make game buffer non-modifiable during transition
  if ui.game_buf and vim.api.nvim_buf_is_valid(ui.game_buf) then
    vim.api.nvim_set_option_value("modifiable", false, { buf = ui.game_buf })
  end

  -- Keymaps for next/quit
  if ui.game_buf and vim.api.nvim_buf_is_valid(ui.game_buf) then
    vim.keymap.set("n", "<CR>", function()
      if M.state.random_track then
        M.next_random_puzzle()
      else
        M.next_puzzle()
      end
    end, { buffer = ui.game_buf, noremap = true, nowait = true })

    vim.keymap.set("n", "q", function()
      M.cleanup()
      ui.close()
      vim.defer_fn(function()
        M.open_menu()
      end, 100)
    end, { buffer = ui.game_buf, noremap = true, nowait = true })
  end
end

function M.reset_puzzle()
  if M.state.status ~= "playing" then
    return
  end
  M.state.keystroke_count = 0

  -- Stop and restart tracking
  if M.state.on_key_ns then
    vim.on_key(nil, M.state.on_key_ns)
    M.state.on_key_ns = nil
  end

  ui.set_puzzle_content(M.state.current_puzzle)
  ui.render_diff(M.state.current_puzzle)

  local level_info
  if M.state.random_track then
    level_info = {
      completed = M.state.random_track.current_idx - 1,
      total = #M.state.random_track.puzzles,
    }
  else
    local cat = levels.get_category_info(M.state.current_category)
    level_info = {
      completed = M.state.current_puzzle_idx - 1,
      total = cat.total,
    }
  end
  ui.render_info(M.state.current_puzzle, level_info, 0, M.get_render_opts())

  M.setup_keystroke_tracking()
end

function M.setup_game_keymaps()
  local buf = ui.game_buf
  if not buf then return end

  vim.keymap.set("n", "<Leader>r", function()
    M.reset_puzzle()
  end, { buffer = buf, noremap = true, desc = "Reset puzzle" })

  vim.keymap.set("n", "<Leader>s", function()
    M.next_puzzle()
  end, { buffer = buf, noremap = true, desc = "Skip puzzle" })

  vim.keymap.set("n", "<Leader>h", function()
    if not M.state.challenge_mode then return end
    M.state.hint_revealed = not M.state.hint_revealed
    local level_info
    if M.state.random_track then
      level_info = {
        completed = M.state.random_track.current_idx - 1,
        total = #M.state.random_track.puzzles,
      }
    else
      local cat = levels.get_category_info(M.state.current_category)
      if not cat then return end
      level_info = {
        completed = M.state.current_puzzle_idx - 1,
        total = cat.total,
      }
    end
    ui.render_info(M.state.current_puzzle, level_info, M.state.keystroke_count, M.get_render_opts())
  end, { buffer = buf, noremap = true, desc = "Toggle hint" })

  vim.keymap.set("n", "<Esc><Esc>", function()
    M.cleanup()
    ui.close()
    ui.close_tab()
  end, { buffer = buf, noremap = true, desc = "Quit game" })
end

function M.cleanup()
  M.state.status = "idle"
  if M.state.augroup then
    pcall(vim.api.nvim_del_augroup_by_id, M.state.augroup)
    M.state.augroup = nil
  end
  if M.state.on_key_ns then
    vim.on_key(nil, M.state.on_key_ns)
    M.state.on_key_ns = nil
  end
end

return M
