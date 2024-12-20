-- Here are defined custom actions for Telescope, used through general or spicker-specific mappings.

local M = {}

function M.smart_open_loclist(prompt_bufnr, _mode)
  local telescope_actions = require("telescope.actions")
  local trouble = require("trouble")

  telescope_actions.smart_send_to_loclist(prompt_bufnr, _mode)
  trouble.open("loclist")
end

function M.smart_open_quickfix(prompt_bufnr, _mode)
  local telescope_actions = require("telescope.actions")
  local trouble = require("trouble")

  telescope_actions.smart_send_to_qflist(prompt_bufnr, _mode)
  trouble.open("qflist")
end

function M.yank_commit_hash(prompt_bufnr)
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local selection = action_state.get_selected_entry()
  actions.close(prompt_bufnr)

  vim.fn.setreg('"', selection.value)
  vim.notify('Commit hash "' .. selection.value .. '" saved to register')
end

return M
