-- oil.nvim
--
-- oil.nvim is a Neovim file explorer enabling to edit your file system like a buffer. It is a modern version of
-- netwrc, Vim's default file explorer, and my plugin of choice for file edition, as it is a powerful alternative to
-- tree-based file explorers, focusing on the current directory in a single window, instead of the whole project tree
-- in a side window. The file editing features it provides are very elegant and natural to learn, and they are usable
-- with other plugins, like Copilot.vim or code snippest, which makes creating files very simple & customizable.

return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  lazy = false, -- Required to be used as default file explorer
  keys = { { "-", function() require("oil").open() end, desc = "Open parent directory" } },
  opts = {
    win_options = { number = false, relativenumber = false }, -- Disable line-numbering in Oil buffers
    cleanup_delay_ms = 0, -- Cleanup the Oil buffer right away to avoid jumping back to it with <C-o> and <C-i>
    keymaps = {
      -- Since Oil can be used as an actual editable buffer, to edit files quickly and optionally in batch, let's not
      --  overwrite any keymap which could be useful for editing files, to still be able to use features like macros
      --  (with "q"), visual block edition (with "<C-v>") or decrementing (with "<C-x>") for instance

      -- Main actions
      ["-"] = "actions.parent",
      ["_"] = "actions.open_cwd",
      ["<CR>"] = "actions.select",
      ["<C-c>"] = "actions.close",
      ["<C-]>"] = "actions.preview",
      ["g?"] = "actions.show_help",
      ["gx"] = "actions.open_external",
      ["gX"] = {
        function() vim.cmd("silent exec '!open ' . expand('%:p')[6:]") end,
        desc = "Open the current directory in an external program",
      },

      -- Oil buffer options
      ["<localleader>l"] = { "actions.refresh", desc = "[L]oad again" },
      ["<localleader>h"] = { "actions.toggle_hidden", desc = "Toggle [H]idden files" },
      ["<localleader>d"] = {
        function() -- Function taken from Oil recipes
          DETAIL = not DETAIL
          if DETAIL then
            require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
          else
            require("oil").set_columns({ "icon" })
          end
        end,
        desc = "Toggle [D]etails",
      },
      ["<localleader>s"] = { "actions.change_sort", desc = "Change [S]ort" },
    },
    use_default_keymaps = false,
    view_options = {
      is_hidden_file = function(name, _)
        if name == "__pycache__" then -- Make Python cache files considered as hidden
          return true
        end
        return vim.startswith(name, ".") -- Default condition
      end,
      is_always_hidden = function(name, _) return name == ".." end, -- Don't show ".." when showing hidden files
    },
  },
}
