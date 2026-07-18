-- LSP：nvim 0.11 原生 vim.lsp.config/enable 体系。
-- nvim-lspconfig 提供各 server 的基础定义，vim.lsp.config() 做项目化覆盖，
-- mason 装二进制，mason-lspconfig 对「已安装的」自动 enable。
-- denols 走系统 deno（不经 mason），需手动 enable。
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
      { "folke/lazydev.nvim", ft = "lua", opts = {} }, -- 编辑本配置时的 vim.* 补全
    },
    config = function()
      -- ── 诊断外观 ──
      vim.diagnostic.config({
        virtual_text = true,
        severity_sort = true,
        float = { border = "rounded", source = true },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = " ",
            [vim.diagnostic.severity.INFO] = " ",
          },
        },
      })

      -- ── buffer 键位（挂载时注入）──
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local function bmap(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
          end
          bmap("gd", vim.lsp.buf.definition, "Goto definition")
          bmap("gD", vim.lsp.buf.declaration, "Goto declaration")
          bmap("gr", vim.lsp.buf.references, "References")
          bmap("gI", vim.lsp.buf.implementation, "Goto implementation")
          bmap("gl", vim.diagnostic.open_float, "Line diagnostics")
          bmap("K", vim.lsp.buf.hover, "Hover")
          bmap("<leader>la", vim.lsp.buf.code_action, "Code action")
          bmap("<leader>lr", vim.lsp.buf.rename, "Rename")
          bmap("<leader>lj", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")
          bmap("<leader>lk", function() vim.diagnostic.jump({ count = -1 }) end, "Prev diagnostic")
          bmap("<leader>lq", vim.diagnostic.setloclist, "Diagnostics to loclist")
        end,
      })

      -- ── 项目化覆盖 ──
      -- deno 与 node 项目分流：各以自己的 marker 为界，且都要求命中 workspace
      vim.lsp.config("denols", {
        root_markers = { "deno.json", "deno.jsonc" },
        workspace_required = true,
        settings = {
          deno = { suggest = { imports = { hosts = { ["https://deno.land"] = true } } } },
        },
      })
      vim.lsp.config("ts_ls", {
        root_markers = { "tsconfig.json" },
        workspace_required = true,
      })
      vim.lsp.config("vue_ls", {
        init_options = { vue = { hybridMode = false } },
      })
      vim.lsp.config("cssmodules_ls", {
        filetypes = { "typescriptreact", "javascriptreact" },
        init_options = { camelCase = false },
      })
      vim.lsp.config("unocss", {
        filetypes = { "vue" },
        root_markers = { "uno.config.ts" },
        workspace_required = true,
      })
      vim.lsp.config("eslint", {
        root_markers = { "eslint.config.mts", "eslint.config.js", "eslint.config.cjs" },
        workspace_required = true,
      })
      -- Python：pyright 管补全/跳转/hover，ruff 管 lint（互补，非竞争）
      -- solidity：nomicfoundation server（自定义，不依赖 lspconfig 预置名）
      vim.lsp.config("solidity_nomic", {
        cmd = { "nomicfoundation-solidity-language-server", "--stdio" },
        filetypes = { "solidity" },
        root_markers = { "hardhat.config.js", "foundry.toml", ".git" },
      })

      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls", "ts_ls", "vue_ls", "jsonls", "yamlls",
          "pyright", "ruff", "gopls", "bashls",
          "html", "cssls", "tailwindcss", "unocss", "cssmodules_ls", "eslint",
        },
        -- 已安装即自动 vim.lsp.enable，覆盖配置在上方 vim.lsp.config 中合并
        automatic_enable = true,
      })

      -- mason 之外的 server 手动 enable
      if vim.fn.executable("deno") == 1 then
        vim.lsp.enable("denols")
      end
      if vim.fn.executable("nomicfoundation-solidity-language-server") == 1 then
        vim.lsp.enable("solidity_nomic")
      end
    end,
  },
}
