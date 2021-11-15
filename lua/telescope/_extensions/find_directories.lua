local actions = require('telescope.actions')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local sorters = require('telescope.sorters')
local state = require('telescope.actions.state')
local conf = require("telescope.config").values


return require('telescope').register_extension {
  exports = {
    all = function ()
    pickers.new {
      prompt_title = "Find Directories",
      finder = finders.new_oneshot_job { "fd", "--type=d", "--hidden", "--follow"},
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
  }
}
