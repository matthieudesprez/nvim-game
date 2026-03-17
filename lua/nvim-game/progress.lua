local M = {}

local progress_file = vim.fn.stdpath("data") .. "/nvim-game-progress.json"

function M.load()
  local f = io.open(progress_file, "r")
  if not f then
    return {}
  end
  local content = f:read("*a")
  f:close()
  if content == "" then
    return {}
  end
  local ok, data = pcall(vim.fn.json_decode, content)
  if not ok then
    return {}
  end
  return data
end

function M.save(data)
  local encoded = vim.fn.json_encode(data)
  local f = io.open(progress_file, "w")
  if not f then
    vim.notify("[nvim-game] Could not save progress", vim.log.levels.WARN)
    return
  end
  f:write(encoded)
  f:close()
end

function M.mark_completed(category_id, puzzle_index, keystrokes, stars)
  local data = M.load()
  if not data[category_id] then
    data[category_id] = { completed = 0, puzzles = {} }
  end

  local cat = data[category_id]
  local puzzle_key = tostring(puzzle_index)
  local existing = cat.puzzles[puzzle_key]

  if not existing or keystrokes < (existing.best_keystrokes or math.huge) then
    cat.puzzles[puzzle_key] = {
      best_keystrokes = keystrokes,
      stars = stars,
    }
  end

  if puzzle_index > cat.completed then
    cat.completed = puzzle_index
  end

  M.save(data)
end

function M.reset()
  os.remove(progress_file)
  vim.notify("[nvim-game] Progress reset.", vim.log.levels.INFO)
end

return M
