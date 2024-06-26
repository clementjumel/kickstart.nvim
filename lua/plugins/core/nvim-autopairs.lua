-- nvim-autopairs
--
-- nvim-autopairs is a simple, yet powerful plugin to automatically insert a closing bracket when the opening one is
-- typed, or to insert a pair of brackets when completion is triggered with a function, for instance.

return {
  "windwp/nvim-autopairs",
  event = { "InsertEnter" },
  opts = {},
}
