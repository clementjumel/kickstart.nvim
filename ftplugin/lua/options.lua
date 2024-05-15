--- Look at existing formatter configuration files to determine the relevant `colorcolumn` option value.
---@return string
local function get_colorcolumn()
  local config_file_names = { ".stylua.toml", "stylua.toml" }
  local default_line_length = 120
  local line_length_pattern = "column_width = "

  local file_path = vim.fn.expand("%:p") -- Get the current file path (must be absolute to access its ancestors)
  local dir = vim.fn.fnamemodify(file_path, ":h") -- Get the parent directory

  for _ = 1, 50 do -- Virtually like a `while True`, but with a safety net
    for _, config_file_name in ipairs(config_file_names) do
      local config_file_path = dir .. "/" .. config_file_name
      if vim.fn.filereadable(config_file_path) == 1 then -- A configuration file was found
        local file = io.open(config_file_path, "r")
        if not file then -- Unable to open file
          return ""
        end

        for line in file:lines() do
          local start, end_ = string.find(line, line_length_pattern, 1, true)
          if start == 1 and end_ ~= nil then -- The target line was found and is not a comment (start == 1)
            file:close()

            local line_length = tonumber(line.sub(line, end_ + 1))
            return tostring(line_length + 1)
          end
        end

        -- A config file is found but no column_width line
        file:close()
        return tostring(default_line_length + 1)
      end
    end

    if dir == vim.env.HOME or dir == "/" then -- Stop at the home directory or root if file not in home directory
      return ""
    else
      dir = vim.fn.fnamemodify(dir, ":h") -- Change dir to its parent directory & loop again
    end
  end

  vim.notify("Config file search limit reached", vim.log.levels.WARN)
  return ""
end

-- Display a column ruler at the relevant line length
if not vim.g.disable_colorcolumn then
  vim.opt_local.colorcolumn = get_colorcolumn()
end