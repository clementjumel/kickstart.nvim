-- undotree
--
-- The undo history visualizer for VIM.

return {
  "mbbill/undotree",
  keys = {
    {
      "<leader>U",
      function() vim.cmd("UndotreeToggle") end,
      desc = "[U]ndo tree menu",
    },
  },
  config = function()
    vim.g.undotree_WindowLayout = 3 -- Window on the right of the screen
    vim.g.undotree_SetFocusWhenToggle = 1
  end,
}
