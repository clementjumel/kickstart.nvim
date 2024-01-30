-- These functions must be used with the `show_condition` option in snippets, they are not suited to
-- the `condition` as they don't support the right parameters for it.

local cond_obj = require("luasnip.extras.conditions")

local utils = require("utils")

local M = {}

local function is_treesitter_parsable()
  local is_treesitter_parsable_, _ = pcall(vim.treesitter.get_node)
  return is_treesitter_parsable_
end
M.is_treesitter_parsable = cond_obj.make_condition(is_treesitter_parsable)

-- A matched trigger is considered to be everything after the last white space or punctuation mark
-- in the line before cursor (this is true as long as the matched trigger doesn't have white spaces
-- or punctuation marks itself, which is a good assumption as `nvim-cmp` doesn't take them into
-- account when completing).
local matched_trigger_separator_pattern = "[%s%p]"
-- In the following pattern, the first capturing group captures greedily everything until a
-- separator is found (since it's greedy, it will capture everything until the last occurence)
local matched_trigger_pattern = "(.*)" .. matched_trigger_separator_pattern .. "(.*)$"

local function get_treesitter_node(line_to_cursor)
  local _, matched_trigger = string.match(line_to_cursor, matched_trigger_pattern)
  if matched_trigger == nil then
    matched_trigger = ""
  end

  local _, row, col, _, _ = unpack(vim.fn.getcurpos())
  return vim.treesitter.get_node({
    pos = { row - 1, col - #matched_trigger - 1 },
  })
end

local treesitter_node_type_class = {
  "class_definition",
}
local treesitter_node_types_comment = {
  "comment",
  "comment_content",
}
local treesitter_node_type_function = {
  "function_definition",
}
local treesitter_node_types_string = {
  "string",
  "string_start",
  "string_content",
}

local function tresitter_check_node_type(line_to_cursor, treesitter_node_types, opts)
  opts = opts or {}
  local check_exclusion = opts.check_exclusion or false
  local not_parsable_return = opts.not_parsable_return or false
  local not_node_return = opts.not_node_return or false

  local is_treesitter_parsable_, node = pcall(get_treesitter_node, line_to_cursor)
  if not is_treesitter_parsable_ then
    return not_parsable_return
  end

  if not node then -- E.g. very beginning of the buffer
    return not_node_return
  end

  for _, treesitter_node_type in ipairs(treesitter_node_types) do
    if node:type() == treesitter_node_type then
      return not check_exclusion
    end
  end

  return check_exclusion
end

-- Condition determining wether a snippet is in a class or not, using treesitter.
local function is_in_class(line_to_cursor)
  return tresitter_check_node_type(line_to_cursor, treesitter_node_type_class)
end
M.is_in_class = cond_obj.make_condition(is_in_class)

-- Condition determining wether a snippet is in a comment or not, using treesitter.
local function is_in_comment(line_to_cursor)
  return tresitter_check_node_type(line_to_cursor, treesitter_node_types_comment)
end
M.is_in_comment = cond_obj.make_condition(is_in_comment)

-- Condition determining wether a snippet is in a function or not, using treesitter.
local function is_in_function(line_to_cursor)
  return tresitter_check_node_type(line_to_cursor, treesitter_node_type_function)
end
M.is_in_function = cond_obj.make_condition(is_in_function)

-- Condition determining wether a snippet is in actual code or not, using treesitter.
local function is_in_code(line_to_cursor)
  local treesitter_node_types_comment_and_string =
    utils.table.concat_arrays({ treesitter_node_types_comment, treesitter_node_types_string })
  return tresitter_check_node_type(line_to_cursor, treesitter_node_types_comment_and_string, {
    check_exclusion = true,
    not_node_return = true, -- Return true at the very beginning of the buffer
  })
end
M.is_in_code = cond_obj.make_condition(is_in_code)

-- Condition determining wether a snippet is at the beginning of a line or not.
local function line_begin(line_to_cursor)
  local before_matched_trigger, _ = string.match(line_to_cursor, matched_trigger_pattern)
  if before_matched_trigger == nil then
    before_matched_trigger = ""
  end

  return string.match(before_matched_trigger, "^%s*$") ~= nil
end
M.line_begin = cond_obj.make_condition(line_begin)

return M