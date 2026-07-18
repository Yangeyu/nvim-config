return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-live-grep-args.nvim",
      "nvim-telescope/telescope-project.nvim",
    },
    cmd = "Telescope",
    keys = {
      { "<leader>f", ":Telescope find_files<CR>", silent = true, desc = "Find files" },
      { "<leader>b", ":Telescope buffers<CR>", silent = true, desc = "Buffers" },
      { "<leader>st", ":Telescope live_grep<CR>", silent = true, desc = "Grep text" },
      { "<leader>sa", ":Telescope live_grep_args theme=ivy<CR>", silent = true, desc = "Grep with args" },
      { "F", ":Telescope current_buffer_fuzzy_find theme=ivy<CR>", silent = true, desc = "Fuzzy find in buffer" },
      -- 以当前文件所属项目为根搜索（看依赖包时即搜该包；项目内等同 <leader>f / <leader>st）
      {
        "<leader>sf",
        function()
          local r = require("root-pin").root()
          require("telescope.builtin").find_files({ cwd = r, prompt_title = "Files: " .. vim.fn.fnamemodify(r, ":~") })
        end,
        silent = true,
        desc = "Find files (file's project)",
      },
      {
        "<leader>sg",
        function()
          local r = require("root-pin").root()
          require("telescope.builtin").live_grep({ cwd = r, prompt_title = "Grep: " .. vim.fn.fnamemodify(r, ":~") })
        end,
        silent = true,
        desc = "Grep (file's project)",
      },
      { "<leader>sr", ":Telescope oldfiles<CR>", silent = true, desc = "Recent files" },
      { "<leader>sh", ":Telescope help_tags<CR>", silent = true, desc = "Help" },
      { "<leader>sk", ":Telescope keymaps<CR>", silent = true, desc = "Keymaps" },
      { "<leader>sp", ":Telescope project<CR>", silent = true, desc = "Projects" },
    },
    config = function()
      require("telescope").setup({})
      require("telescope").load_extension("live_grep_args")
      require("telescope").load_extension("project")
    end,
  },

  -- 项目级搜索替换：可编辑面板 + ripgrep 全语法 + 实时预览
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    opts = {},
  },
}
