-- vim-tmux-navigator
--
-- Enable to use control + h/j/k/l seamlessly to navigate between neovim windows and tmux panes
-- when running neovim within tmux.

return {
  "christoomey/vim-tmux-navigator",
  cmd = { "TmuxNavigateLeft", "TmuxNavigateRight", "TmuxNavigateDown", "TmuxNavigateUp" },
  init = function()
    vim.keymap.set("n", "<C-h>", "<cmd> TmuxNavigateLeft <CR>", { desc = "Window left" })
    vim.keymap.set("n", "<C-l>", "<cmd> TmuxNavigateRight <CR>", { desc = "Window right" })
    vim.keymap.set("n", "<C-j>", "<cmd> TmuxNavigateDown <CR>", { desc = "Window down" })
    vim.keymap.set("n", "<C-k>", "<cmd> TmuxNavigateUp <CR>", { desc = "Window up" })
  end,
}
