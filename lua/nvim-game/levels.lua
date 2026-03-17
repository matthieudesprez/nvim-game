local M = {}

M.categories = {
  { id = "basic_motions",  name = "Basic Motions (h, j, k, l)",     module = "nvim-game.puzzles.01_basic_motions" },
  { id = "word_motions",   name = "Word Motions (w, b, e)",         module = "nvim-game.puzzles.02_word_motions" },
  { id = "line_motions",   name = "Line Motions (0, $, ^)",         module = "nvim-game.puzzles.03_line_motions" },
  { id = "find_till",      name = "Find/Till (f, F, t, T, ;, ,)",   module = "nvim-game.puzzles.04_find_till" },
  { id = "vertical_nav",   name = "Vertical Nav (gg, G, {n}G)",     module = "nvim-game.puzzles.05_vertical_nav" },
  { id = "insert_entries", name = "Insert Mode (i, a, I, A, o, O)", module = "nvim-game.puzzles.06_insert_entries" },
  { id = "operators",      name = "Operators (d, c + motions)",     module = "nvim-game.puzzles.07_operators" },
  { id = "text_objects",   name = "Text Objects (iw, aw, i\", a()", module = "nvim-game.puzzles.08_text_objects" },
  { id = "yank_put",       name = "Yank & Put (y, p, P)",           module = "nvim-game.puzzles.09_yank_put" },
  { id = "visual_mode",    name = "Visual Mode (v, V + ops)",       module = "nvim-game.puzzles.10_visual_mode" },
  { id = "dot_repeat",     name = "Dot Repeat (.)",                 module = "nvim-game.puzzles.11_dot_repeat" },
  { id = "search",         name = "Search (/, n, N, *, #)",         module = "nvim-game.puzzles.12_search" },
}

M._cache = {}

function M.get_categories()
  -- Ensure total counts are populated
  for _, cat in ipairs(M.categories) do
    if not cat.total then
      local puzzles = M._load(cat.id, cat.module)
      cat.total = #puzzles
    end
  end
  return M.categories
end

function M.get_category_info(category_id)
  for _, cat in ipairs(M.categories) do
    if cat.id == category_id then
      if not cat.total then
        local puzzles = M._load(cat.id, cat.module)
        cat.total = #puzzles
      end
      return cat
    end
  end
  return nil
end

function M.get_puzzle(category_id, index)
  local cat = M.get_category_info(category_id)
  if not cat then return nil end
  local puzzles = M._load(category_id, cat.module)
  if index > #puzzles then return nil end
  return puzzles[index]
end

function M.get_all_puzzles()
  local all = {}
  for _, cat in ipairs(M.categories) do
    local puzzles = M._load(cat.id, cat.module)
    for _, p in ipairs(puzzles) do
      table.insert(all, p)
    end
  end
  return all
end

function M._load(category_id, module_path)
  if not M._cache[category_id] then
    M._cache[category_id] = require(module_path)
  end
  return M._cache[category_id]
end

return M
