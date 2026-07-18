return {
  -- 行内补全（codeium）
  {
    "Exafunction/windsurf.vim",
    event = "InsertEnter",
    config = function()
      vim.g.codeium_disable_bindings = 1
      vim.keymap.set("i", ";;", function() return vim.fn["codeium#Accept"]() end, { expr = true })
      vim.keymap.set("i", ";,", function() return vim.fn["codeium#CycleCompletions"](1) end, { expr = true })
      vim.keymap.set("i", ";l", function() return vim.fn["codeium#AcceptNextLine"]() end, { expr = true })
      vim.keymap.set("i", "<C-x>", function() return vim.fn["codeium#Clear"]() end, { expr = true })
    end,
  },

  -- 对话式 AI。API key 从环境变量读取，不入库
  {
    "olimorris/codecompanion.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
    keys = {
      { "<leader>Cc", ":CodeCompanionChat adapter=qwen<CR>", silent = true, desc = "AI chat" },
      { "<leader>Ca", ":CodeCompanionActions<CR>", mode = { "n", "v" }, silent = true, desc = "AI actions" },
    },
    opts = {
      adapters = {
        http = {
          qwen = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
              env = {
                url = "https://dashscope.aliyuncs.com",
                api_key = "DASHSCOPE_API_KEY",
                chat_url = "/compatible-mode/v1/chat/completions",
              },
              schema = { model = { default = "qwen3-max" } },
            })
          end,
        },
      },
    },
  },
}
