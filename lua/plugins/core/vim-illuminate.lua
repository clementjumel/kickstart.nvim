-- vim-illuminate
--
-- Vim plugin for automatically highlighting other uses of the word under the cursor using either
-- LSP, Tree-sitter, or regex matching.

local nvim_config = require("nvim_config")

return {
  "RRethy/vim-illuminate",
  cond = not nvim_config.light_mode,
  lazy = true,
  opts = {
    providers = { "lsp" }, -- Only enable LSP to decrease false positives
    min_count_to_highlight = 2, -- Don't highlight singles (which include all literals)
  },
  -- There's no setup function so we need to re-define the config function
  config = function(_, opts) require("illuminate").configure(opts) end,
}
