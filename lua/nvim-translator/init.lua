-- Author: alix_an@hotmail.com
-- Description: neovim language translator plugin
--
local M = {}
M.option = {
  -- https_proxy = "",
  style = "float",  -- bottom, right or float, float is default
  https_proxy = "", -- https_proxy default is "", not use proxy

  -- keymap for virual mode default keymap, i.e selected lines in visual mode, then press tc convert to Chinese
  keymap = {
    ["tc"] = "zh-cn",
    ["te"] = "en",
    ["ts"] = "es",
    ["td"] = "de",
    ["tk"] = "ko",
    ["tj"] = "ja",
  },
  language = {
    ['af'] = 'afrikaans',
    ['sq'] = 'albanian',
    ['am'] = 'amharic',
    ['ar'] = 'arabic',
    ['hy'] = 'armenian',
    ['az'] = 'azerbaijani',
    ['eu'] = 'basque',
    ['be'] = 'belarusian',
    ['bn'] = 'bengali',
    ['bs'] = 'bosnian',
    ['bg'] = 'bulgarian',
    ['ca'] = 'catalan',
    ['ceb'] = 'cebuano',
    ['ny'] = 'chichewa',
    ['zh-cn'] = 'chinese (simplified)',
    ['zh-tw'] = 'chinese (traditional)',
    ['co'] = 'corsican',
    ['hr'] = 'croatian',
    ['cs'] = 'czech',
    ['da'] = 'danish',
    ['nl'] = 'dutch',
    ['en'] = 'english',
    ['eo'] = 'esperanto',
    ['et'] = 'estonian',
    ['tl'] = 'filipino',
    ['fi'] = 'finnish',
    ['fr'] = 'french',
    ['fy'] = 'frisian',
    ['gl'] = 'galician',
    ['ka'] = 'georgian',
    ['de'] = 'german',
    ['el'] = 'greek',
    ['gu'] = 'gujarati',
    ['ht'] = 'haitian creole',
    ['ha'] = 'hausa',
    ['haw'] = 'hawaiian',
    ['iw'] = 'hebrew',
    ['he'] = 'hebrew',
    ['hi'] = 'hindi',
    ['hmn'] = 'hmong',
    ['hu'] = 'hungarian',
    ['is'] = 'icelandic',
    ['ig'] = 'igbo',
    ['id'] = 'indonesian',
    ['ga'] = 'irish',
    ['it'] = 'italian',
    ['ja'] = 'japanese',
    ['jw'] = 'javanese',
    ['kn'] = 'kannada',
    ['kk'] = 'kazakh',
    ['km'] = 'khmer',
    ['ko'] = 'korean',
    ['ku'] = 'kurdish (kurmanji)',
    ['ky'] = 'kyrgyz',
    ['lo'] = 'lao',
    ['la'] = 'latin',
    ['lv'] = 'latvian',
    ['lt'] = 'lithuanian',
    ['lb'] = 'luxembourgish',
    ['mk'] = 'macedonian',
    ['mg'] = 'malagasy',
    ['ms'] = 'malay',
    ['ml'] = 'malayalam',
    ['mt'] = 'maltese',
    ['mi'] = 'maori',
    ['mr'] = 'marathi',
    ['mn'] = 'mongolian',
    ['my'] = 'myanmar (burmese)',
    ['ne'] = 'nepali',
    ['no'] = 'norwegian',
    ['or'] = 'odia',
    ['ps'] = 'pashto',
    ['fa'] = 'persian',
    ['pl'] = 'polish',
    ['pt'] = 'portuguese',
    ['pa'] = 'punjabi',
    ['ro'] = 'romanian',
    ['ru'] = 'russian',
    ['sm'] = 'samoan',
    ['gd'] = 'scots gaelic',
    ['sr'] = 'serbian',
    ['st'] = 'sesotho',
    ['sn'] = 'shona',
    ['sd'] = 'sindhi',
    ['si'] = 'sinhala',
    ['sk'] = 'slovak',
    ['sl'] = 'slovenian',
    ['so'] = 'somali',
    ['es'] = 'spanish',
    ['su'] = 'sundanese',
    ['sw'] = 'swahili',
    ['sv'] = 'swedish',
    ['tg'] = 'tajik',
    ['ta'] = 'tamil',
    ['te'] = 'telugu',
    ['th'] = 'thai',
    ['tr'] = 'turkish',
    ['uk'] = 'ukrainian',
    ['ur'] = 'urdu',
    ['ug'] = 'uyghur',
    ['uz'] = 'uzbek',
    ['vi'] = 'vietnamese',
    ['cy'] = 'welsh',
    ['xh'] = 'xhosa',
    ['yi'] = 'yiddish',
    ['yo'] = 'yoruba',
    ['zu'] = 'zulu',
  }
}

-- for googletrans
function M._genTransExec()
  local transExecFile = [[
import os
import sys
from googletrans import Translator
translator = Translator()
filename = sys.argv[1]
dest_lang = sys.argv[2] if len(sys.argv) > 2 else 'en'
with open(filename, 'r') as file:
    text = file.read()
    translation = translator.translate(text, dest=dest_lang)
    print(translation.text)
]]
  local tmpname = os.tmpname()
  local file = assert(io.open(tmpname, "w"))
  file:write(transExecFile)
  file:close()
  return tmpname
end

-- write array table to file
function M._writeToFile(stringTable)
  local tmpname = os.tmpname()
  local file = assert(io.open(tmpname, "w"))
  for _, line in ipairs(stringTable) do
    file:write(line .. "\n")
  end
  file:close()
  return tmpname
end

-- translate selected contents to destinate language, return a text table array
function M._containsOnlySpaceOrTab(stringTable)
  for _, str in ipairs(stringTable) do
    if not string.match(str, "^[\t ]*$") then
      return false
    end
  end
  return true
end

function M._translate_text(stringTable, dest)
  if M._containsOnlySpaceOrTab(stringTable) then
    return {}
  end

  local srcFileName = M._writeToFile(stringTable)
  -- print(vim.inspect(contents))

  local transExecFile = M._genTransExec()
  local env = ''
  if M.option.https_proxy ~= nil and M.option.https_proxy ~= '' then
    env = "export HTTPS_PROXY=" .. M.option.https_proxy .. ";"
  end

  local command = env .. "python3 " .. transExecFile .. " " .. srcFileName .. " " .. dest

  -- local handle = assert(io.popen(command))
  -- local output = handle:read("*a")
  -- handle:close()

  local file = io.popen(command)
  local lines = {}
  if file then
    for line in file:lines() do
      table.insert(lines, line)
    end
    file:close()
    os.remove(srcFileName)
    os.remove(transExecFile)
  else
    print("Translate failed")
  end

  -- -- convert text to stringTable, drop \n
  -- local lines = {}
  -- for line in string.gmatch(output, "[^\n]+") do
  --   table.insert(lines, line)
  -- end
  -- -- print(vim.inspect(lines))
  -- -- remove temp files
  -- os.remove(srcFileName)
  -- os.remove(transExecFile)
  return lines
end

-- get max width of stringTable
function M._getMaxWidth(stringTable)
  local width = 5
  for i = 1, #stringTable do
    local len = string.len(stringTable[i])
    if len > width then
      width = len + 4
    end
  end
  local maxWidth = vim.api.nvim_get_option("columns")
  if width > maxWidth then
    width = maxWidth - 1
  end
  return width
end

-- main function to translate selected visual mode lines to destinate language
function M.translateSelectedTextTo(dest_lang)
  -- Get the selected text in visual mode
  local selection = vim.fn.getline("'<", "'>")
  local translated_text = M._translate_text(selection, dest_lang)
  M._show(translated_text)
end

function M._show(text)
  if #text == 0 then
    return
  end

  if M.option.style == "float" then
    M._showAsFloat(text)
  end

  if M.option.style == "bottom" then
    M._showAtBottom(text)
  end

  if M.option.style == "right" then
    M._showAtRight(text)
  end
end

function M._showAsFloat(translated_text)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, translated_text)

  -- open float window
  local width = M._getMaxWidth(translated_text)
  local maxLines = vim.api.nvim_get_option("lines")
  local height = #translated_text
  if height > maxLines then
    height = maxLines - 3
  end

  local win_id = vim.api.nvim_open_win(bufnr, true, {
    relative = 'cursor',
    width = width,
    height = height,
    border = "single",
    row = 1,
    col = 0,
    focusable = false,
  })

  -- vim.api.nvim_win_set_option(win_id, 'cursorline', true)
  -- vim.api.nvim_win_set_option(win_id, 'cursorcolumn', true)
  -- vim.api.nvim_win_set_option(win_id, 'wrap', false)
  -- vim.api.nvim_win_set_option(win_id, 'foldenable', false)
  -- vim.api.nvim_win_set_option(win_id, 'scrolloff', 0)
  vim.api.nvim_win_set_option(win_id, 'number', false)
  --
  -- Set the buffer options
  vim.api.nvim_buf_set_option(bufnr, 'bufhidden', 'wipe')

  -- Map 'q' key to close the window
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', ':q<CR>', { noremap = true, silent = true })
  -- Map Esc to close the window
  -- vim.api.nvim_buf_set_keymap(bufnr, 'i', '<Esc>', '<C-\\><C-n>:pclose<CR>', { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Esc>', ':q<CR>', { noremap = true, silent = true })

  -- avoid ctrl-q to switch to other window
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-q>', '<Nop>', { nowait = true })
  vim.api.nvim_buf_set_keymap(bufnr, 'i', '<C-q>', '<Nop>', { nowait = true })
  vim.api.nvim_buf_set_keymap(bufnr, 't', '<C-q>', '<Nop>', { nowait = true })
end

function M._showAtBottom(translated_text)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, translated_text)

  local maxLines = vim.api.nvim_get_option("lines")
  local height = #translated_text
  if height > math.floor(maxLines / 2) then
    height = math.floor(maxLines / 2)
  end

  local split_command = string.format("belowright split | resize %d", height)
  vim.api.nvim_command(split_command)
  -- Set the buffer associated with the new window to the buffer we created earlier
  vim.api.nvim_win_set_buf(0, bufnr)
end

function M._showAtRight(translated_text)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, translated_text)

  local maxCol = vim.api.nvim_get_option("columns")
  local width = math.floor(maxCol / 2)

  local split_command = string.format("belowright vsplit | resize %d", width)
  vim.api.nvim_command(split_command)

  -- Set the buffer associated with the new window to the buffer we created earlier
  vim.api.nvim_win_set_buf(0, bufnr)
end

function M._isSupportedLanguage(lang)
  if M.option.language[lang] then
    return true
  else
    return false
  end
end

function TranslateTo(dest_lang)
  if dest_lang == nil or dest_lang == '' then
    print("Not specify destination language")
    return
  end
  if not M._isSupportedLanguage(dest_lang) then
    print(dest_lang .. " language is not supported!")
    return
  end

  -- print(vim.inspect(range))
  local last_visual_mode = vim.fn.visualmode(true)
  local lines = {}

  --if at visual mode get selected text else get all lines of current buffer
  if last_visual_mode == 'v' or last_visual_mode == 'V' then
    lines = vim.fn.getline("'<", "'>")
  else
    local current_bufnr = vim.api.nvim_get_current_buf()
    lines = vim.api.nvim_buf_get_lines(current_bufnr, 0, -1, false)
  end

  -- print("print lines", vim.inspect(lines))
  local translated_text = M._translate_text(lines, dest_lang)

  -- M._translateThenShow(lines, dest_lang)
  M._show(translated_text)
end

function M._setupKeymap()
  -- vim.api.nvim_set_keymap('v', 'tc', ':lua require("translator").translateSelectedTextTo("zh-cn")<CR>',
  --   { noremap = true, silent = true })
  -- vim.api.nvim_set_keymap('v', 'te', ':lua require("translator").translateSelectedTextTo("en")<CR>',
  --   { noremap = true, silent = true })
  local opt = { noremap = true, silent = true }
  for key, value in pairs(M.option.keymap) do
    local cmd = string.format(':lua require("translator").translateSelectedTextTo("%s")<CR>', value)
    vim.api.nvim_set_keymap('v', key, cmd, opt)
  end
  -- set command :Translate lang
  vim.cmd("command! -nargs=* -range Translate  call luaeval('TranslateTo(_A, _)', <f-args>)")
end

function M.setup(...)
  local args = { ... }
  if #args == 0 then
    -- use default values
  elseif type(args[1]) == "table" then
    -- handle setup({}) case
    local option = args[1]
    if option.https_proxy ~= nil then
      M.option.https_proxy = option.https_proxy
    end

    if option.style ~= nil then
      M.option.style = option.style
    end

    if option.keymap ~= nil then
      M.option.keymap = option.keymap
    end
    -- print(M.option)
  end
  M._setupKeymap()
end

return M
