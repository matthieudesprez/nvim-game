local M = {}

M.config = {
  width = 70,
  height = 20,
  border = "rounded",
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

function M.run(args)
  args = args or ""
  if args == "reset" then
    require("nvim-game.progress").reset()
    vim.notify("[nvim-game] Progress reset.", vim.log.levels.INFO)
    return
  end

  local engine = require("nvim-game.engine")
  if args == "continue" then
    engine.continue_game()
  else
    engine.open_menu()
  end
end

return M
