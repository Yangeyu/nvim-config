return {
  {
    "stevearc/conform.nvim",
    keys = {
      {
        "<leader>lf",
        function() require("conform").format({ lsp_format = "fallback" }) end,
        desc = "Format buffer",
      },
    },
    opts = {
      -- 未列出的文件类型回落到 LSP 格式化（<leader>lf 的 lsp_format = fallback）
      formatters_by_ft = {
        vue = { "prettier" },
        go = { "goimports", "gofumpt", "golines" },
      },
    },
  },
}
