if vim.g.loaded_nvim_game then
  return
end
vim.g.loaded_nvim_game = true

vim.api.nvim_create_user_command("NvimGame", function(opts)
  require("nvim-game").run(opts.args)
end, {
  nargs = "?",
  complete = function()
    return { "reset", "continue" }
  end,
  desc = "Start the nvim-game Vim keymap learning game",
})
