local status_ok, translator = pcall(require, "nvim-translator")
if status_ok then
  translator.setup({})
  -- translator.setup({
  --   style = "float", --or vertical, horizontal, float
  --   https_proxy = "http://localhost:8118",
  --   keymap = {
  --     ["tc"] = "zh-cn",
  --     ["te"] = "en",
  --     ["ts"] = "es",
  --     ["td"] = "de",
  --     ["tk"] = "ko",
  --     ["tj"] = "ja",
  --   },
  -- })
end


--customized configuration example
--     require("nvim-translator").setup({
--       style = "float",   --or vertical, horizontal
--       https_proxy = "http://localhost:8118",
--       keymap = {
--         ["tc"] = "zh-cn",
--         ["te"] = "en",
--         ["ts"] = "es",
--         ["td"] = "de",
--         ["tk"] = "ko",
--         ["tj"] = "ja",
--       },
--     })
