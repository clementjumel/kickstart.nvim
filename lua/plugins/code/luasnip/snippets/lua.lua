local ls = require("luasnip")

local c = ls.choice_node
local i = ls.insert_node
local s = ls.snippet
local t = ls.text_node

local fmt = require("luasnip.extras.fmt").fmt

return {
  s(
    "todo-comment",
    fmt("-- {c1}", {
      c1 = c(1, {
        t("TODO: "),
        t("NOTE: "),
        t("BUG: "),
        t("FIXME: "),
        t("ISSUE: "),
      }),
    })
  ),
  s("local", fmt("local {i1} = {i2}", { i1 = i(1), i2 = i(2) })),
  s("local-require", fmt([[local {i1} = require("{i2}")]], { i1 = i(1), i2 = i(2) })),
}
