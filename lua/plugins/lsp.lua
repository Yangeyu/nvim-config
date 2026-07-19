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
      { "b0o/schemastore.nvim", lazy = true }, -- jsonls/yamlls 的常用 schema 目录
    },
    config = function()
      -- ── 诊断外观 ──
      vim.diagnostic.config({
        virtual_text = true,
        severity_sort = true,
        float = { border = "rounded", source = true },
        -- \u{} 转义防 PUA 字形复制丢失；勿加尾随空格（telescope 列表首列会撑满）
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "\u{ea87}",
            [vim.diagnostic.severity.WARN] = "\u{ea6c}",
            [vim.diagnostic.severity.HINT] = "\u{f0336}",
            [vim.diagnostic.severity.INFO] = "\u{ea74}",
          },
        },
      })

      -- ── buffer 键位（挂载时注入）──
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          -- winbar 面包屑：server 支持 documentSymbol 才挂 navic
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client.server_capabilities.documentSymbolProvider then
            require("nvim-navic").attach(client, ev.buf)
          end
          local function bmap(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
          end
          -- 多候选时不弹 quickfix 窗口：跳过 `local foo` / `let foo: T` 这类
          -- 纯声明行，优先跳带初始化赋值（=，含 const 对象/箭头函数）或函数体
          -- （function/def/func/fn）的条目，无匹配则跳第一条；
          -- 候选仍写入 quickfix，需要时 <C-q> 打开、]q/[q 遍历
          bmap("gd", function()
            vim.lsp.buf.definition({
              on_list = function(opts)
                vim.fn.setqflist({}, " ", opts)
                local target = 1
                if #opts.items > 1 then
                  for i, item in ipairs(opts.items) do
                    local text = item.text or ""
                    if text:find("=", 1, true)
                      or text:match("%f[%a]function%f[%A]") or text:match("%f[%a]def%f[%A]")
                      or text:match("%f[%a]func%f[%A]") or text:match("%f[%a]fn%f[%A]") then
                      target = i
                      break
                    end
                  end
                end
                vim.cmd("silent cc " .. target)
              end,
            })
          end, "Goto definition")
          -- gd 的候选列表版：多候选时开 Telescope 带预览挑选，唯一候选直接跳。
          -- 原 declaration 让位：主力语言里 declaration 与 definition 同址，键位闲置
          bmap("gD", function() require("telescope.builtin").lsp_definitions({ initial_mode = "normal" }) end, "Definitions (picker)")
          bmap("gr", vim.lsp.buf.references, "References")
          bmap("gI", vim.lsp.buf.implementation, "Goto implementation")
          bmap("gl", vim.diagnostic.open_float, "Line diagnostics")
          bmap("K", vim.lsp.buf.hover, "Hover")
          bmap("<leader>la", vim.lsp.buf.code_action, "Code action")
          bmap("<leader>lr", vim.lsp.buf.rename, "Rename")
          bmap("<leader>ld", function()
            require("telescope.builtin").diagnostics(require("telescope.themes").get_ivy({ bufnr = 0, initial_mode = "normal" }))
          end, "Buffer diagnostics")
          bmap("<leader>lj", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")
          bmap("<leader>lk", function() vim.diagnostic.jump({ count = -1 }) end, "Prev diagnostic")
          bmap("<leader>lq", vim.diagnostic.setloclist, "Diagnostics to loclist")
          -- 兜底：自动重载没跟上（如新建/删文件后 server watcher 失灵）时手动一键复位
          bmap("<leader>lR", function()
            vim.cmd.checktime()
            vim.cmd.LspRestart()
          end, "Reload files & restart LSP")
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
      -- Lua：类型库静态声明（路径运行时计算，跨设备），启动只索引一次。
      -- 全部已装插件的 lua/ 都入库，配置里 require 到的插件 API 就有补全/跳转；
      -- 相比 lazydev 按 require 增量注入，静态库避免了每首开新文件时的
      -- 重索引诊断闪烁，且配置走标准推送、对 root 外的库文件 scope 也生效，
      -- 不会弹 "configure your work environment"（checkThirdParty 询问）
      local lua_library = {
        vim.env.VIMRUNTIME .. "/lua", -- vim.* 全套类型标注
        "${3rd}/luv/library", -- vim.uv
      }
      local lazy_root = vim.fn.stdpath("data") .. "/lazy"
      for name, kind in vim.fs.dir(lazy_root) do
        local lua_dir = lazy_root .. "/" .. name .. "/lua"
        if kind == "directory" and vim.uv.fs_stat(lua_dir) then
          lua_library[#lua_library + 1] = lua_dir
        end
      end
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
              checkThirdParty = "Disable",
              library = lua_library,
            },
          },
        },
      })
      -- JSON/YAML：接 schemastore（package.json、GitHub Actions 等自动校验补全）
      vim.lsp.config("jsonls", {
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      })
      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            schemaStore = { enable = false, url = "" }, -- 关内置目录，统一走 schemastore.nvim
            schemas = require("schemastore").yaml.schemas(),
          },
        },
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
