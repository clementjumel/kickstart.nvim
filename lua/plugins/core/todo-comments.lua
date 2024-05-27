-- todo-comments
--
-- todo-comments is a plugin to highlight and search for todo comments like TODO, HACK, BUG in the code base. It is
-- very convenient to document directly in the code the next steps to do, or to document long-term issues left for
-- the future, like unresolved bugs or performance issues. Besides, it works very nicely with other plugins, like
-- Telescope or Trouble, to navigate between todo-comments, or code snippets (e.g. Luasnip), to define custom
-- todo-comment snippets to blazingly-fast add them to the code.

return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = { "BufNewFile", "BufReadPre" },
  keys = {
    {
      "<leader>ft",
      function()
        if package.loaded.telescope == nil then -- Lazy load telescope if needed
          require("telescope")
        end
        vim.cmd("TodoTelescope previewer=false")
      end,
      desc = "[F]ind: [T]odo-comments",
    },
  },
  opts = {
    -- Include hidden files when searching for todo comments
    search = { args = { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--hidden" } },
  },
  config = function(_, opts)
    local tdc = require("todo-comments")

    local utils = require("utils")

    tdc.setup(opts)

    utils.keymap.set_move_pair({ "[t", "]t" }, {
      tdc.jump_next,
      tdc.jump_prev,
    }, { { desc = "Next todo-comment" }, { desc = "Previous todo-comment" } })
  end,
}
