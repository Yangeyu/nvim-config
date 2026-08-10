-- treesitter 用 master 分支（经典 configs API）：与 yati/textobjects 的成熟组合，
-- 三者版本同步于各自 master 最新（master 已冻结，组合固定不再漂移）。
-- 迁移到 main 分支重写版留待生态稳定后单独评估。

return {
  -- AST 父级跳转 motion（自研，见插件 README：行级心智模型，[ 起点 / ] 终点）
  {
    "Yangeyu/ast-motions.nvim",
    -- 本地开发时切换：dir = vim.fn.expand("~/Workplace/vim-plugins/ast-motions.nvim"),
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    -- 用 [e/]e（enclosing）而非插件默认的 [u/]u：双手交替更顺，
    -- 且无任何原生/插件键位冲突
    keys = {
      { "[e", function() require("ast-motions").parent_start() end, mode = { "n", "x", "o" }, desc = "Parent node start" },
      { "]e", function() require("ast-motions").parent_end() end, mode = { "n", "x", "o" }, desc = "Parent node end" },
      -- 兄弟节点跳转（structural next）：多行子树视作一项；跨层用 [e 回父级后再跳。
      -- 全局 [[/]] = AST 兄弟；markdown/python 等 ftplugin 的 buffer-local
      -- 特化（跳标题/顶层 def）会按 vim 规则压过全局——视作同一动作的领域特化
      { "[[", function() require("ast-motions").sibling_prev() end, mode = { "n", "x", "o" }, desc = "Prev sibling node" },
      { "]]", function() require("ast-motions").sibling_next() end, mode = { "n", "x", "o" }, desc = "Next sibling node" },
    },
    -- 键位由本 spec 的 keys 管理（keymaps.lua 头注释的约定），插件不再自建
    opts = { keymaps = false },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "master" },
      "yioneko/nvim-yati",
    },
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "vim", "vimdoc", "query",
          "typescript", "tsx", "javascript", "jsdoc", "vue",
          "json", "jsonc", "yaml", "toml",
          "html", "css", "scss",
          "go", "gomod", "gosum", "python", "bash", "sql", "solidity",
          "markdown", "markdown_inline", "regex", "dockerfile",
          "git_rebase", "gitcommit", "diff",
        },
        highlight = { enable = true },
        -- 缩进交给 yati（JSX/TSX 下最自然），关闭内置 indent
        indent = { enable = false },
        yati = { enable = true, default_lazy = true },
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- 光标不在对象内时自动前跳到下一个
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = { ["]f"] = "@function.outer", ["]a"] = "@parameter.inner" },
            goto_previous_start = { ["[f"] = "@function.outer", ["[a"] = "@parameter.inner" },
          },
        },
      })
    end,
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      -- 自定义 7 色板（onedark 系），换主题后重建
      local function set_palette()
        vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
        vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
        vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
        vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
        vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
        vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
        vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
      end
      set_palette()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = set_palette })
      vim.g.rainbow_delimiters = {
        highlight = {
          "RainbowRed", "RainbowYellow", "RainbowBlue", "RainbowOrange",
          "RainbowGreen", "RainbowViolet", "RainbowCyan",
        },
      }
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    opts = {},
  },
}
