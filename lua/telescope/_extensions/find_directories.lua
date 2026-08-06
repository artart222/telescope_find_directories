local actions = require("telescope.actions")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local sorters = require("telescope.sorters")
local state = require("telescope.actions.state")
local conf = require("telescope.config").values

local M = {}

-- Extension options from telescope.setup({ extensions = { find_directories = {...} } })
-- open_explorer: nil = auto-detect, false = disable, string command, or function()
local config = {
  open_explorer = nil,
}

local function command_exists(cmd)
  return vim.fn.exists(":" .. cmd) == 2
end

--- Open a file explorer after selecting a directory.
--- Honors config.open_explorer override; otherwise tries neo-tree, nvim-tree, then oil.
local function open_file_explorer()
  local override = config.open_explorer

  if override == false then
    return
  end

  if type(override) == "function" then
    override()
    return
  end

  if type(override) == "string" then
    vim.cmd(override)
    return
  end

  if command_exists("Neotree") then
    vim.cmd("Neotree reveal")
  elseif command_exists("NvimTreeOpen") then
    vim.cmd("NvimTreeOpen")
  elseif command_exists("Oil") then
    vim.cmd("Oil")
  end
end

local os = vim.loop.os_uname().sysname
local finder
if os == "Linux" then
  -- Find the name of the fd binary file in the operating system.
  if vim.fn.filereadable("/bin/fdfind") == 1 then
    finder = "fdfind"
  else
    finder = "fd"
  end
else
  finder = "fd"
end

function M.find_directories()
  pickers.new({
    prompt_title = "Find Directories",
    finder = finders.new_oneshot_job({ finder, "--type=d", "--follow", "--exclude=.git" }),
    sorter = conf.generic_sorter(),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = state.get_selected_entry(prompt_bufnr)
        vim.cmd("cd " .. selection[1])
        vim.cmd("ene")
        open_file_explorer()
      end)
      return true
    end,
  }):find()
end

return require("telescope").register_extension({
  setup = function(ext_config, _)
    if ext_config.open_explorer ~= nil then
      config.open_explorer = ext_config.open_explorer
    end
  end,
  exports = {
    find_directories = M.find_directories,
  },
})
