-- treesitter 用 master 分支（经典 configs API）：与 yati/textobjects 的成熟组合，
-- 三者版本同步于各自 master 最新（master 已冻结，组合固定不再漂移）。
-- 迁移到 main 分支重写版留待生态稳定后单独评估。
return {
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
