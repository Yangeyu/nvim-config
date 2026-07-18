return {
  -- 两键跳转（自用 fork）
  {
    "Yangeyu/hop.nvim",
    keys = {
      { "f", ":HopChar1<CR>", silent = true, desc = "Hop to char" },
      { "<leader>j", ":HopLineStartAC<CR>", silent = true, desc = "Hop line down" },
      { "<leader>k", ":HopLineStartBC<CR>", silent = true, desc = "Hop line up" },
    },
    config = function()
      require("hop").setup({ keys = "etovxqpdygfblzhckisuran" })
    end,
  },

  { "tpope/vim-surround", event = { "BufReadPost", "BufNewFile" } },

  -- 回车逐级扩选
  {
    "gcmt/wildfire.vim",
    event = { "BufReadPost", "BufNewFile" },
    init = function()
      vim.g.wildfire_objects = { "i'", 'i"', "i)", "i]", "i}", "ip", "it", "i>", "iw", "i`" }
    end,
  },

  { "numToStr/Comment.nvim", event = { "BufReadPost", "BufNewFile" }, opts = {} },
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

  -- mark 可视化
  {
    "chentoast/marks.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      force_write_shada = true,
      refresh_interval = 250,
      mappings = { set_next = "m,", next = "mn", preview = false, set_bookmark0 = "m0", prev = "mp" },
    },
  },

  -- 平滑滚动
  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    opts = {
      mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
    },
  },

  -- 重新打开文件回到上次位置
  {
    "ethanholz/nvim-lastplace",
    event = "BufReadPre",
    opts = {
      lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
      lastplace_ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit" },
      lastplace_open_folds = true,
    },
  },

  -- 会话恢复
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    keys = {
      { "<leader>Sc", function() require("persistence").load() end, desc = "Restore session (cwd)" },
      { "<leader>Sl", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
      { "<leader>SQ", function() require("persistence").stop() end, desc = "Quit without session" },
    },
    opts = {},
  },

  -- 对齐
  {
    "junegunn/vim-easy-align",
    keys = {
      { "<leader>a=", ":EasyAlign *=<CR>", mode = "x", silent = true, desc = "Align by =" },
      { "<leader>a,", ":EasyAlign */,/<CR>", mode = "x", silent = true, desc = "Align by ," },
    },
  },

  -- 划词翻译
  {
    "voldikss/vim-translator",
    keys = { { "f", ":TranslateW<CR>", mode = "x", silent = true, desc = "Translate selection" } },
  },

  -- 折叠体验升级：treesitter 折叠范围 + 折叠行内容预览
  {
    "kevinhwang91/nvim-ufo",
    dependencies = "kevinhwang91/promise-async",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("ufo").setup({
        provider_selector = function() return { "treesitter", "indent" } end,
      })
      vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
      vim.keymap.set("n", "zK", function()
        if not require("ufo").peekFoldedLinesUnderCursor() then
          vim.lsp.buf.hover()
        end
      end, { desc = "Peek fold / hover" })
    end,
  },
}
