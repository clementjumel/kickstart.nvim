-- Here are defined custom wrappers around Telescope builtin pickers. It is where I implement custom options or logic
-- for each picker I use & want to customize.

local visual_mode = require("visual_mode")

local M = {}

--- Finalize the options for the `find_files` picker. This function adds all the relevant not-persisted options to
--- the persisted ones.
---@param opts table The persisted options.
---@return table _ The finalized options.
local function find_files_finalize_opts(opts)
  if not opts._include_all_files then
    opts.prompt_title = "Find Files"
    opts.find_command = { "fd", "--type", "f", "--color", "never", "--hidden" }
  else
    opts.prompt_title = "Find Files (all)"
    opts.find_command = { "fd", "--type", "f", "--color", "never", "--hidden", "--no-ignore" }
  end

  if opts.cwd then
    -- Make the path more user-friendly (relative to the cwd if in the cwd, otherwise relative to the home directory
    --  with a "~" prefix if in the home directory, otherwise absolute)
    local cwd = vim.fn.fnamemodify(opts.cwd, ":p:~:.")
    if cwd == "" then -- Case `cwd` is actually the cwd
      cwd = "./"
    end
    opts.prompt_title = opts.prompt_title .. " - " .. cwd
  end

  return opts
end

--- Get the base options for the `find_files` picker.
---@return table _ The `find_files` base options.
local function find_files_get_base_opts()
  local function toggle_all_files(prompt_bufnr, _)
    -- Persisted options
    local opts = vim.g.telescope_last_opts
    opts._include_all_files = not opts._include_all_files
    vim.g.telescope_last_opts = opts

    -- Not persisted options
    opts = find_files_finalize_opts(opts)
    local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
    opts.default_text = current_picker:_get_prompt()
    require("telescope.actions").close(prompt_bufnr)

    require("telescope.builtin").find_files(opts)
  end

  local opts = {
    attach_mappings = function(_, map)
      map({ "i", "n" }, "<C-\\>", toggle_all_files)
      return true -- Enable default mappings
    end,
    _include_all_files = false,
  }

  if vim.bo.filetype == "oil" then
    opts.cwd = require("oil").get_current_dir()
  end
  if visual_mode.is_on() then
    local text = visual_mode.get_text()
    -- Replace punctuation marks by spaces, to support searching from module names, like "plugins.core"
    opts.default_text = string.gsub(text, "%p", " ")
  end

  return opts
end

function M.find_files()
  local opts = find_files_get_base_opts()
  vim.g.telescope_last_opts = opts -- Persist the options to be able to change them later

  opts = find_files_finalize_opts(opts)
  require("telescope.builtin").find_files(opts)
end

--- Finalize the options for the `find_directories` custom picker. This function adds all the relevant not-persisted
--- options to the persisted ones.
---@param opts table The persisted options.
---@return table _ The finalized options.
local function find_directories_finalize_opts(opts)
  local custom_make_entry = require("plugins.core.telescope.make_entry")
  local previewers = require("telescope.previewers")

  if not opts._include_all_files then
    opts.prompt_title = "Find Directories"
    opts.find_command = { "fd", "--type", "d", "--color", "never", "--hidden" }
    -- Previewers can't be saved to state so let's work around this by creating them here
    opts.previewer = previewers.new_termopen_previewer({
      get_command = function(entry, _)
        return {
          "eza",
          "-a1",
          "--color=always",
          "--icons=always",
          "--group-directories-first",
          entry.path,
        }
      end,
    })
    -- To support directory icons, use a custom entry maker (which needs to have accessed to the picker options)
    opts.entry_maker = custom_make_entry.gen_from_dir(opts)
  else
    opts.prompt_title = "Find Directories (all)"
    opts.find_command = { "fd", "--type", "d", "--color", "never", "--hidden", "--no-ignore" }
    -- Previewers can't be saved to state so let's work around this by creating them here
    opts.previewer = previewers.new_termopen_previewer({
      get_command = function(entry, _)
        return {
          "eza",
          "-a1",
          "--color=always",
          "--icons=always",
          "--group-directories-first",
          entry.path,
        }
      end,
    })
    -- To support directory icons, use a custom entry maker (which needs to have accessed to the picker options)
    opts.entry_maker = custom_make_entry.gen_from_dir(opts)
  end

  if opts.cwd then
    -- Make the path more user-friendly (relative to the cwd if in the cwd, otherwise relative to the home directory
    --  with a "~" prefix if in the home directory, otherwise absolute)
    local cwd = vim.fn.fnamemodify(opts.cwd, ":p:~:.")
    if cwd == "" then -- Case `cwd` is actually the cwd
      cwd = "./"
    end
    opts.prompt_title = opts.prompt_title .. " - " .. cwd
  end

  return opts
end

--- Get the base options for the `find_directories` custom picker.
---@return table _ The `find_directories` base options.
local function find_directories_get_base_opts()
  local function toggle_all_files(prompt_bufnr, _)
    -- Persisted options
    local opts = vim.g.telescope_last_opts
    opts._include_all_files = not opts._include_all_files
    vim.g.telescope_last_opts = opts

    -- Not persisted options
    opts = find_directories_finalize_opts(opts)
    local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
    opts.default_text = current_picker:_get_prompt()
    require("telescope.actions").close(prompt_bufnr)

    require("telescope.builtin").find_files(opts)
  end

  local opts = {
    attach_mappings = function(_, map)
      map({ "i", "n" }, "<C-\\>", toggle_all_files)
      return true -- Enable default mappings
    end,
    _include_all_files = false,
  }

  if vim.bo.filetype == "oil" then
    opts.cwd = require("oil").get_current_dir()
  end
  if visual_mode.is_on() then
    local text = visual_mode.get_text()
    -- Replace punctuation marks by spaces, to support searching from module names, like "plugins.core"
    opts.default_text = string.gsub(text, "%p", " ")
  end

  return opts
end

function M.find_directories()
  local opts = find_directories_get_base_opts()
  vim.g.telescope_last_opts = opts -- Persist the options to be able to change them later

  opts = find_directories_finalize_opts(opts)
  require("telescope.builtin").find_files(opts)
end

--- Finalize the options for the `live_grep` picker. This function adds all the relevant not-persisted options to the
--- persisted ones.
---@param opts table The persisted options.
---@return table _ The finalized options.
local function live_grep_finalize_opts(opts)
  opts.prompt_title = "Find by Grep"

  if opts.vimgrep_arguments and vim.tbl_contains(opts.vimgrep_arguments, "--fixed-strings") then
    opts.prompt_title = opts.prompt_title .. " - fixed-strings"
  end

  if not opts._include_all_files then
    opts.additional_args = { "--hidden" }
  else
    opts.prompt_title = opts.prompt_title .. " (all)"
    opts.additional_args = { "--hidden", "--no-ignore" }
  end

  if opts.cwd then
    -- Make the path more user-friendly (relative to the cwd if in the cwd, otherwise relative to the home directory
    --  with a "~" prefix if in the home directory, otherwise absolute)
    local cwd = vim.fn.fnamemodify(opts.cwd, ":p:~:.")
    if cwd == "" then -- Case `cwd` is actually the cwd
      cwd = "./"
    end
    opts.prompt_title = opts.prompt_title .. " - " .. cwd
  end

  return opts
end

--- Get the base options for the `live_grep` picker.
---@return table _ The `live_grep` base options.
local function live_grep_get_base_opts()
  local function toggle_all_files(prompt_bufnr, _)
    -- Persisted options
    local opts = vim.g.telescope_last_opts
    opts._include_all_files = not opts._include_all_files
    vim.g.telescope_last_opts = opts

    -- Not persisted options
    opts = live_grep_finalize_opts(opts)
    local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
    opts.default_text = current_picker:_get_prompt()
    require("telescope.actions").close(prompt_bufnr)

    require("telescope.builtin").live_grep(opts)
  end

  local opts = {
    layout_strategy = "vertical",
    attach_mappings = function(_, map)
      map({ "i", "n" }, "<C-\\>", toggle_all_files)
      return true -- Enable default mappings
    end,
    _include_all_files = false,
  }

  if vim.bo.filetype == "oil" then
    opts.cwd = require("oil").get_current_dir()
  end
  if visual_mode.is_on() then
    opts.default_text = visual_mode.get_text()
    opts.vimgrep_arguments = {
      -- Default values
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      -- New values
      "--fixed-strings",
    }
  end

  return opts
end

function M.live_grep()
  local telescope_opts = live_grep_get_base_opts()
  vim.g.telescope_last_opts = telescope_opts -- Persist the options to be able to change them later

  telescope_opts = live_grep_finalize_opts(telescope_opts)
  require("telescope.builtin").live_grep(telescope_opts)
end

function M.old_files()
  local opts = {
    tiebreak = function(current, existing, _) return current.index < existing.index end, -- Sort by recency
    prompt_title = "Find Old files",
  }
  if visual_mode.is_on() then
    local text = visual_mode.get_text()
    -- Replace punctuation marks by spaces, to support searching from module names, like "plugins.core"
    opts.default_text = string.gsub(text, "%p", " ")
  end
  require("telescope.builtin").oldfiles(opts)
end

function M.recent_files() -- Similar to M.oldfiles but restricted to cwd
  local opts = {
    tiebreak = function(current, existing, _) return current.index < existing.index end, -- Sort by recency
    prompt_title = "Find Recent Files",
    cwd_only = true,
  }
  if visual_mode.is_on() then
    local text = visual_mode.get_text()
    -- Replace punctuation marks by spaces, to support searching from module names, like "plugins.core"
    opts.default_text = string.gsub(text, "%p", " ")
  end
  require("telescope.builtin").oldfiles(opts)
end

function M.current_buffer_fuzzy_find()
  local opts = {
    prompt_title = "Find in Buffer",
    layout_strategy = "vertical",
  }
  if visual_mode.is_on() then
    opts.default_text = visual_mode.get_text()
  end
  require("telescope.builtin").current_buffer_fuzzy_find(opts)
end

function M.commands()
  require("telescope.builtin").commands({
    prompt_title = "Find Commands",
    layout_strategy = "vertical",
  })
end

function M.keymaps()
  require("telescope.builtin").keymaps({
    prompt_title = "Find Keymaps",
    layout_strategy = "vertical",
  })
end

function M.vim_options()
  require("telescope.builtin").vim_options({
    prompt_title = "Find Vim Options",
    layout_strategy = "vertical",
  })
end

function M.help_tags()
  require("telescope.builtin").help_tags({
    prompt_title = "Find Help",
    layout_strategy = "vertical",
    previewer = false,
  })
end

function M.man_pages()
  local opts = {
    prompt_title = "Find Man Pages",
    layout_strategy = "vertical",
    previewer = false,
  }
  if visual_mode.is_on() then
    opts.default_text = visual_mode.get_text()
  end
  require("telescope.builtin").man_pages(opts)
end

function M.buffers()
  require("telescope.builtin").buffers(require("telescope.themes").get_dropdown({
    prompt_title = "Buffer Switcher",
    initial_mode = "normal",
    preview = { hide_on_startup = true },
    ignore_current_buffer = true, -- When current buffer is included & last used is selected, search doesn't work well
    sort_lastused = true, -- Sort current & last used buffer at the top & select the last used
    sort_mru = true, -- Sort all buffers after the last used
    attach_mappings = function(_, map)
      map({ "n" }, "<BS>", require("telescope.actions").delete_buffer)
      return true -- Enable default mappings
    end,
  }))
end

function M.resume() require("telescope.builtin").resume({}) end

function M.command_history()
  require("telescope.builtin").command_history(require("telescope.themes").get_dropdown({
    previewer = false,
    tiebreak = function(current, existing, _) return current.index < existing.index end, -- Sort by recency
    filter_fn = function(cmd) return string.len(cmd) >= 4 end, -- Filter out short commands like "w", "q", "wq", "wqa"
    attach_mappings = function(_, map) -- Use <C-CR> instead of <C-e> to edit the command
      map({ "i", "n" }, "<M-CR>", require("telescope.actions").edit_command_line)
      return true -- Enable default mappings
    end,
  }))
end

function M.search_history()
  require("telescope.builtin").search_history(require("telescope.themes").get_dropdown({
    previewer = false,
    tiebreak = function(current, existing, _) return current.index < existing.index end, -- Sort by recency
    attach_mappings = function(_, map) -- Use <C-CR> instead of <C-e> to edit the search
      map({ "i", "n" }, "<M-CR>", require("telescope.actions").edit_search_line)
      return true -- Enable default mappings
    end,
  }))
end

function M.git_status()
  require("telescope.builtin").git_status({
    prompt_title = "Git Status",
    layout_config = { preview_width = 0.6 },
    git_icons = {
      added = "+",
      changed = "~",
      copied = ">",
      deleted = "-",
      renamed = "➡",
      unmerged = "‡",
      untracked = "",
    },
    attach_mappings = function(_, map)
      -- Override the <Tab> keymap to disable the stage/unstage feature of the picker
      map({ "i", "n" }, "<Tab>", require("telescope.actions").move_selection_next)
      return true -- Enable default mappings
    end,
  })
end

function M.git_branches()
  require("telescope.builtin").git_branches({
    layout_strategy = "vertical",
    attach_mappings = function(_, map) -- Re-implement some default keymaps to remove their overwrite
      map({ "i", "n" }, "<C-d>", require("telescope.actions").close)
      return true -- Enable default mappings
    end,
  })
end

function M.git_commits()
  require("telescope.builtin").git_commits({
    prompt_title = "Git Log",
    tiebreak = function(current, existing, _) return current.index < existing.index end, -- Sort by recency
    attach_mappings = function(_, _)
      local actions = require("telescope.actions")
      local custom_actions = require("plugins.core.telescope.actions")
      actions.select_default:replace(custom_actions.yank_commit_hash) -- Replace the default action (checkout to commit)
      return true -- Enable default mappings
    end,
  })
end

function M.git_bcommits()
  require("telescope.builtin").git_bcommits({
    prompt_title = "Buffer Commits",
    tiebreak = function(current, existing, _) return current.index < existing.index end, -- Sort by recency
    attach_mappings = function(_, _)
      local actions = require("telescope.actions")
      local custom_actions = require("plugins.core.telescope.actions")
      actions.select_default:replace(custom_actions.yank_commit_hash) -- Replace the default action (checkout to commit)
      return true -- Enable default mappings
    end,
  })
end

function M.git_bcommits_range()
  require("telescope.builtin").git_bcommits_range({
    prompt_title = "Selection Commits",
    tiebreak = function(current, existing, _) return current.index < existing.index end, -- Sort by recency
    attach_mappings = function(_, _)
      local actions = require("telescope.actions")
      local custom_actions = require("plugins.core.telescope.actions")
      actions.select_default:replace(custom_actions.yank_commit_hash) -- Replace the default action (checkout to commit)
      return true -- Enable default mappings
    end,
  })
end

function M.lsp_document_symbols()
  local opts = {
    prompt_title = "Find Symbols",
    layout_config = { preview_width = 0.6 },
  }
  if visual_mode.is_on() then
    opts.default_text = visual_mode.get_text()
  end
  require("telescope.builtin").lsp_document_symbols(opts)
end

function M.lsp_workspace_symbols()
  local opts = {
    prompt_title = "Find Workspace Symbols",
    layout_config = { preview_width = 0.5 },
  }
  if visual_mode.is_on() then
    opts.default_text = visual_mode.get_text()
  end
  require("telescope.builtin").lsp_dynamic_workspace_symbols(opts)
end

return M
