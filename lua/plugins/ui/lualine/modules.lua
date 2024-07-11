local utils = require("utils")

local M = {}

M.empty = { function() return "" end }

-- Add a message in the status line when recording a macro
-- Source: https://github.com/folke/noice.nvim/wiki/Configuration-Recipes#show-recording-messages
M.macro = {
  function()
    local noice = package.loaded.noice
    if noice ~= nil then
      return noice.api.statusline.mode.get()
    end
  end,
  cond = function()
    local noice = package.loaded.noice
    if noice ~= nil then
      return noice.api.statusline.mode.has()
    end
  end,
  color = { fg = "#ff9e64" },
}

-- Display the Harpoon list index corresponding to the current buffer and the Harpoon list length, if in Harpoon list
-- This will lazy-load Harpoon as soon as a buffer is opened
M.harpoon = {
  function()
    if vim.bo.filetype ~= "oil" and utils.buffer.is_temporary() then -- Include case when no buffer is opened
      return "" -- Don't show anything for temporary buffers (just like there is no encoding)
    end

    local harpoon = require("harpoon") -- Harpoon is not loaded if no buffer/directory is opened
    for index = 1, harpoon:list():length() do
      if utils.path.get_current_buffer_path() == harpoon:list():get(index).value then
        return "H-" .. index .. "/" .. harpoon:list():length()
      end
    end

    return ""
  end,
}

-- Show the path of the directory opened with Oil instead of Oil's buffer path
M.oil = {
  function()
    local oil = package.loaded.oil
    return vim.fn.fnamemodify(oil.get_current_dir(), ":p:~:.")
  end,
}

-- Show the index & name of the ToggleTerm opened in a window instead of the ToggleTerm buffer path
M.toggleterm = {
  function()
    local terms = require("toggleterm.terminal")
    local term = terms.get(vim.b.toggle_number)
    if term == nil then
      return ""
    end
    return "Terminal " .. term.id .. ": " .. term:_display_name()
  end,
}

return M
