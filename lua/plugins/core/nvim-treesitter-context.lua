-- nvim-treesitter-context
--
-- A simple plugin to show code context using treesitter. I don't use this by default, but it can be very handy when
-- exploring large unknown files.

return {
  "nvim-treesitter/nvim-treesitter-context",
  event = { "BufNewFile", "BufReadPre" },
  opts = {
    enable = false, -- Disable by default, can be enabled by the option Hydra
  },
  config = function(_, opts)
    local treesitter_context = require("treesitter-context")

    treesitter_context.setup(opts)

    vim.keymap.set("n", "gp", function()
      if treesitter_context.enabled() then -- When treesitter-context is not enabled, the keymap doesn't work well
        treesitter_context.go_to_context()
      end
    end, { desc = "Go to context parent node" })
  end,
}
