return {
  {
    "saghen/blink.cmp",
    version = "1.*", -- 走预编译 fuzzy 二进制
    event = "InsertEnter",
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        dependencies = "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
          vim.keymap.set("i", "<C-E>", function() require("luasnip").change_choice(1) end,
            { desc = "Next snippet choice" })
          vim.keymap.set("i", "<C-U>", function() require("luasnip.extras.select_choice")() end,
            { desc = "Select snippet choice" })
        end,
      },
    },
    opts = {
      snippets = { preset = "luasnip" },
      keymap = {
        preset = "enter", -- 回车确认
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
      },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
    },
  },
}
