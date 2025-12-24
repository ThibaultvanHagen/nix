require("codecompanion").setup({
  ignore_warnings = true,
  strategies = {
    chat = { adapter = "openai" },
    inline = { adapter = "openai" },
  },
})

local ok, cc_config = pcall(require, "codecompanion.config")
if ok then
  cc_config.interactions = cc_config.interactions or {}
  cc_config.interactions.chat = cc_config.interactions.chat or {}
  cc_config.interactions.chat.tools = cc_config.interactions.chat.tools or {}
  cc_config.interactions.chat.variables = cc_config.interactions.chat.variables or {}

  require("mcphub.extensions.codecompanion").setup({
    make_vars = true,
    make_slash_commands = true,
    show_result_in_chat = true,
  })
end
