local actions = require('telescope.actions')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local sorters = require('telescope.sorters')
local state = require('telescope.actions.state')
local conf = require("telescope.config").values

local M = {}

local os = vim.loop.os_uname().sysname
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
    pickers.new {
      prompt_title = "Find Directories",
      finder = finders.new_oneshot_job { finder, "--type=d", "--hidden", "--follow", "--exclude=.git"},
      sorter = conf.generic_sorter(),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = state.get_selected_entry(prompt_bufnr)
          vim.cmd("cd " .. selection[1])
          vim.cmd("DashboardNewFile")
          vim.cmd("NvimTreeOpen")
        end)
      return true
    end
    }:find()
end

return require('telescope').register_extension {
  exports = {
      find_directories = M.find_directories
  }
}
