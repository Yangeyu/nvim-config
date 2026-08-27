-- 主搜索键以当前文件所属项目为根（root-pin 解析，cwd 锚点不动），
-- prompt 标题带上根路径，检索范围一目了然
local function project_options(title)
  local r = require("root-pin").root()
  return { cwd = r, prompt_title = title .. ": " .. vim.fn.fnamemodify(r, ":~") }
end

local function project_picker(name, title)
  return function()
    require("telescope.builtin")[name](project_options(title))
  end
end

-- Git 项目由索引决定文件集合；被上层仓库忽略的依赖包和非 Git 项目回退文件系统。
-- check-ignore: 0=当前项目根被忽略，1=未被忽略；其他错误同样安全回退。
local function project_files()
  local opts = project_options("Files")
  local has_git_root = vim.fs.root(opts.cwd, ".git") ~= nil
  local is_git_managed = has_git_root
    and vim.system({ "git", "-C", opts.cwd, "check-ignore", "--quiet", "--", "." }):wait().code == 1

  if is_git_managed then
    opts.show_untracked = true
    opts.use_git_root = false
    require("telescope.builtin").git_files(opts)
  else
    require("telescope.builtin").find_files(opts)
  end
end

-- git picker 以当前文件所属仓库为根，与 <leader>gg 的 lazygit 同一语义
local function repo_picker(name)
  return function()
    require("telescope.builtin")[name]({ cwd = require("root-pin").git_root() })
  end
end

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-live-grep-args.nvim",
      "nvim-telescope/telescope-project.nvim",
      -- 原生 fzf sorter：大仓库排序快一个量级，并支持 fzf 过滤语法
      -- （'foo 精确、^src 前缀、.lua$ 后缀、!test 排除，空格分隔取交集）
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    cmd = "Telescope",
    keys = {
      -- 主搜索键跟随当前文件所属项目：工作项目内行为不变，
      -- 浏览依赖包/外部项目文件时即搜该项目
      { "<leader>f", project_files, silent = true, desc = "Find files" },
      { "<leader>b", ":Telescope buffers<CR>", silent = true, desc = "Buffers" },
      { "<leader>st", project_picker("live_grep", "Grep"), silent = true, desc = "Grep text" },
      {
        "<leader>sa",
        function()
          local r = require("root-pin").root()
          require("telescope").extensions.live_grep_args.live_grep_args(
            require("telescope.themes").get_ivy({ cwd = r, prompt_title = "Grep args: " .. vim.fn.fnamemodify(r, ":~") })
          )
        end,
        silent = true,
        desc = "Grep with args",
      },
      { "F", ":Telescope current_buffer_fuzzy_find theme=ivy<CR>", silent = true, desc = "Fuzzy find in buffer" },
      -- 显式以工作项目（cwd 锚点）为根：在外部项目文件里也搜整个工作项目
      { "<leader>sf", ":Telescope find_files<CR>", silent = true, desc = "Find files (workspace)" },
      { "<leader>sg", ":Telescope live_grep<CR>", silent = true, desc = "Grep (workspace)" },
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
      { "<leader>go", repo_picker("git_status"), silent = true, desc = "Open changed file" },
      { "<leader>gb", repo_picker("git_branches"), silent = true, desc = "Checkout branch" },
      { "<leader>gc", repo_picker("git_commits"), silent = true, desc = "Checkout commit" },
      { "<leader>gC", repo_picker("git_bcommits"), silent = true, desc = "Checkout commit (current file)" },
    },
    config = function()
      local t_actions = require("telescope.actions")
      require("telescope").setup({
        defaults = {
          mappings = {
            -- 对齐 lvim：C-j/C-k 切换检索历史（C-p/C-n 保持默认的移动选中项）
            i = {
              ["<C-j>"] = t_actions.cycle_history_next,
              ["<C-k>"] = t_actions.cycle_history_prev,
            },
            -- normal 模式 J/K 滚动预览窗口内容（半页）
            n = {
              ["J"] = t_actions.preview_scrolling_down,
              ["K"] = t_actions.preview_scrolling_up,
            },
          },
        },
        pickers = {
          -- 文件检索包含 .dockerignore/.env.example 等点文件，仍遵守 ignore 规则；
          -- 显式排除 .git 元数据，避免 --hidden 把对象库也纳入结果。
          find_files = {
            find_command = { "rg", "--files", "--color", "never", "--hidden", "--glob", "!.git" },
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
      require("telescope").load_extension("fzf")
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
