return {
  name = "luajit",
  condition = { callback = function(_) return vim.fn.executable("luajit") == 1 end },
  generator = function(_, cb)
    cb({
      {
        name = "luajit <file>",
        condition = { filetype = "lua" },
        builder = function(_)
          local path = vim.fn.expand("%:p:~:.") -- Current file path relative to cwd or HOME or absolute
          return {
            cmd = "luajit",
            args = { path },
          }
        end,
      },
    })
  end,
}
