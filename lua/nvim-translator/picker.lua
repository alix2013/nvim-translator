-- Use telescope to show a select picker
local M = {}

M.select = function(select_table, select_callback)
  local actions = require "telescope.actions"
  local actions_state = require "telescope.actions.state"
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local sorters = require "telescope.sorters"
  local dropdown = require "telescope.themes".get_dropdown()

  local function enter(prompt_bufnr)
    local selected = actions_state.get_selected_entry()
    actions.close(prompt_bufnr)
    select_callback(selected[1])
  end

  -- function next_color(prompt_bufnr)
  --   actions.move_selection_next(prompt_bufnr)
  --   local selected = actions_state.get_selected_entry()
  --   local cmd = 'colorscheme ' .. selected[1]
  --   vim.cmd(cmd)
  -- end

  -- function prev_color(prompt_bufnr)
  --   actions.move_selection_previous(prompt_bufnr)
  --   local selected = actions_state.get_selected_entry()
  --   local cmd = 'colorscheme ' .. selected[1]
  --   vim.cmd(cmd)
  -- end

  -- local colors = vim.fn.getcompletion("", "color")

  -- local lang_map = require('nvim-translator').option.language
  -- local lang_list = {}
  -- for key, value in pairs(lang_map) do
  --   table.insert(lang_list, key .. " - " .. value)
  -- end

  -- vim.print(lang_list)
  local opts = {
    -- finder = finders.new_table { "gruvbox", "nordfox", "nightfox", "monokai", "tokyonight" },
    finder = finders.new_table(select_table),
    -- finder = finders.new_table(colors),
    sorter = sorters.get_generic_fuzzy_sorter({}),

    attach_mappings = function(_, map)
      map("i", "<CR>", enter)
      -- map("i", "<C-j>", next_color)
      -- map("i", "<C-k>", prev_color)
      return true
    end,

  }

  local picker = pickers.new(dropdown, opts)
  picker:find()
end

return M
