-- nvim-lint
--
-- An asynchronous linter plugin for Neovim, complementary to the built-in Language Server Protocol support. It is my
-- plugin of choice for linting, as it's very simple, easily customizable, and is very complementary with conform.nvim,
-- my formatting plugin.

local nvim_config = require("nvim_config")
local path_utils = require("path_utils")

return {
  "mfussenegger/nvim-lint",
  cond = not nvim_config.light_mode,
  dependencies = { "williamboman/mason.nvim" },
  ft = vim.tbl_keys(nvim_config.linters_by_ft),
  init = function()
    local mason_ensure_installed = {}
    for _, linters in pairs(nvim_config.linters_by_ft) do
      for _, mason_name in ipairs(linters) do
        if
          not vim.tbl_contains(mason_ensure_installed, mason_name)
          and not vim.tbl_contains(vim.g.mason_ensure_installed or {}, mason_name)
        then
          table.insert(mason_ensure_installed, mason_name)
        end
      end
    end
    vim.g.mason_ensure_installed = vim.list_extend(vim.g.mason_ensure_installed or {}, mason_ensure_installed)
  end,
  opts = {
    linters_by_ft = nvim_config.linters_by_ft,
    should_lint = function() -- Custom option to enable/disable linting
      local lint_is_disabled_by_nvim_config = (
        nvim_config.disable_lint_on_fts == "*"
        or (nvim_config.disable_lint_on_fts and vim.tbl_contains(nvim_config.disable_lint_on_fts, vim.bo.filetype))
      )
      local lint_is_disabled_by_command = vim.g.disable_lint or vim.b[vim.fn.bufnr()].disable_lint

      if
        lint_is_disabled_by_nvim_config
        or lint_is_disabled_by_command
        or (not path_utils.file_is_in_project())
        or path_utils.file_matches_tooling_blacklist_patterns()
      then
        return false
      end

      return true
    end,
  },
  config = function(_, opts)
    local lint = require("lint")

    lint.linters_by_ft = opts.linters_by_ft
    vim.api.nvim_create_autocmd({
      "BufEnter", -- Entering a buffer
      "InsertLeave", -- Leaving insert mode
      "TextChanged", -- Text is changed by pasting, deleting, etc. but not by insert mode
      "BufWritePost", -- After writing the buffer; required for some linters relying on file on disk
    }, {
      callback = function()
        if opts.should_lint() then
          lint.try_lint()
        end
      end,
    })

    -- Create command to toggle lint
    -- Used with a bang ("!"), the disable command will disable lint just for the current buffer
    vim.api.nvim_create_user_command("LintDisable", function(args)
      if args.bang then
        vim.b.disable_lint = true
      else
        vim.g.disable_lint = true
      end
    end, { desc = "Disable lint", bang = true })
    vim.api.nvim_create_user_command("LintEnable", function()
      vim.b.disable_lint = false
      vim.g.disable_lint = false
    end, { desc = "Enable lint" })
  end,
}
