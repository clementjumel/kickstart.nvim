-- These functions must be used with the `show_condition` option in snippets, they are not suited to
-- the `condition` as they don't support the right parameters for it.

local M = {}

local function get_treesitter_node(line_to_cursor)
  -- matched_trigger is considered to be everything after the last white space (this is true as
  -- long as triggers don't have white spaces)
  -- The first capturing group in the regex captures greedily everything until a white space is
  -- found (since it's greedy, it will capture everything until the last white space)
  local _, matched_trigger = string.match(line_to_cursor, "(.*)%s(.*)$")
  if matched_trigger == nil then
    matched_trigger = ""
  end

  local _, row, col, _, _ = unpack(vim.fn.getcurpos())
  return vim.treesitter.get_node({
    pos = { row - 1, col - #matched_trigger - 1 },
  })
end

-- Condition determining wether a snippet is in actual code or not, using treesitter.
function M.is_in_code(line_to_cursor)
  local is_treesitter_parsable, node = pcall(get_treesitter_node, line_to_cursor)
  if is_treesitter_parsable then
    return node
      and not (
        node:type() == "comment"
        or node:type() == "comment_content"
        or node:type() == "string"
        or node:type() == "string_content"
      )
  else
    return false
  end
end

-- Condition determining wether a snippet is in a comment or not, using treesitter.
function M.is_in_comment(line_to_cursor)
  local is_treesitter_parsable, node = pcall(get_treesitter_node, line_to_cursor)
  if is_treesitter_parsable then
    return node and (node:type() == "comment" or node:type() == "comment_content")
  else
    return false
  end
end

return M
