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
      { "<leader>P", ":Telescope project<CR>", silent = true, desc = "Projects" },
      -- sc/sp 都开实时预览：上下移动即全局应用主题，Esc 还原，回车确认
      {
        "<leader>sc",
        function() require("telescope.builtin").colorscheme({ enable_preview = true }) end,
        silent = true,
        desc = "Colorscheme with preview",
      },
      { "<leader>go", ":Telescope git_status<CR>", silent = true, desc = "Open changed file" },
      { "<leader>gb", ":Telescope git_branches<CR>", silent = true, desc = "Checkout branch" },
      { "<leader>gc", ":Telescope git_commits<CR>", silent = true, desc = "Checkout commit" },
      { "<leader>gC", ":Telescope git_bcommits<CR>", silent = true, desc = "Checkout commit (current file)" },
    },
    config = function()
      local t_actions = require("telescope.actions")
      require("telescope").setup({
        defaults = {
          mappings = {
            -- normal 模式 J/K 滚动预览窗口内容（半页）
            n = {
              ["J"] = t_actions.preview_scrolling_down,
              ["K"] = t_actions.preview_scrolling_up,
            },
          },
        },
        extensions = {
          -- 项目列表自动扫描 ~/Workplace 下两层目录（含 vim-plugins/* 等子目录里的仓库）；
          -- 列表为空时回车会触发插件的 nil 索引报错，故必须保证有来源。
          -- 扫描范围外的项目在 picker 内手动添加：插入模式 <C-a> / 普通模式 c
          -- （git 仓库内取 git 根，否则取 cwd），<C-d>/d 删除，<C-v>/r 重命名；
          -- 手动添加的记录存于 ~/.local/share/nvim/telescope-projects.txt
          project = {
            base_dirs = { { path = "~/Workplace", max_depth = 2 } },
          },
        },
      })
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
