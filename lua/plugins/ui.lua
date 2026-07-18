return {
  -- 主题：catppuccin 为主力，其余备选按需 :colorscheme 切换
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },
  { "ayu-theme/ayu-vim", lazy = true },
  { "nyoom-engineering/oxocarbon.nvim", lazy = true },
  { "EdenEast/nightfox.nvim", lazy = true },
  { "rebelot/kanagawa.nvim", lazy = true },
  { "rose-pine/neovim", name = "rose-pine", lazy = true },
  { "ellisonleao/gruvbox.nvim", lazy = true },

  -- 启动仪表盘（无参启动时显示；<leader>; 随时唤出）
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    keys = { { "<leader>;", ":Alpha<CR>", silent = true, desc = "Dashboard" } },
    config = function()
      local dashboard = require("alpha.themes.dashboard")
      dashboard.section.header.val = {
        "                                                     ",
        "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
        "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
        "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
        "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
        "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
        "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
        "                                                     ",
      }
      dashboard.section.buttons.val = {
        dashboard.button("f", "󰈞  Find File", ":Telescope find_files<CR>"),
        dashboard.button("n", "  New File", ":ene!<CR>"),
        dashboard.button("p", "  Projects", ":Telescope project<CR>"),
        dashboard.button("r", "󰄉  Recent files", ":Telescope oldfiles<CR>"),
        dashboard.button("t", "󰊄  Find Text", ":Telescope live_grep<CR>"),
        dashboard.button("c", "  Configuration", ":Config<CR>"),
        dashboard.button("q", "󰅖  Quit", ":qa<CR>"),
      }
      require("alpha").setup(dashboard.config)
      -- 懒加载到此处时 VimEnter 已过，alpha 自身的 autostart autocmd 不会再触发；
      -- 手动 start(true)，是否该显示（有参启动/stdin 等跳过）由其内置守卫判断
      require("alpha").start(true)
      -- 插件就绪后再填 footer（启动统计此时才有数据）
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
          local stats = require("lazy").stats()
          dashboard.section.footer.val =
            string.format("⚡ %d plugins loaded in %.0f ms", stats.loaded, stats.startuptime)
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },

  -- 状态栏：含宏录制指示器（录制期间常驻 "● REC @寄存器"）
  {
    "nvim-lualine/lualine.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    config = function()
      local function recording()
        local reg = vim.fn.reg_recording()
        return reg == "" and "" or ("● REC @" .. reg)
      end
      local function lsp_names()
        local names = {}
        for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
          names[#names + 1] = c.name
        end
        return table.concat(names, ",")
      end
      require("lualine").setup({
        options = { theme = "catppuccin", globalstatus = true },
        sections = {
          lualine_c = { "filename" },
          lualine_x = {
            { recording, color = { fg = "#ff5555", gui = "bold" } },
            "diagnostics",
            { lsp_names, icon = "" },
            "filetype",
          },
        },
      })
      -- 录制开始/结束不会触发 statusline 重绘，需手动刷新；
      -- RecordingLeave 时寄存器尚未清空，延迟刷新指示器才会消失
      vim.api.nvim_create_autocmd("RecordingEnter", {
        callback = function() require("lualine").refresh() end,
      })
      vim.api.nvim_create_autocmd("RecordingLeave", {
        callback = function()
          vim.defer_fn(function() require("lualine").refresh() end, 50)
        end,
      })
    end,
  },

  -- buffer 标签页
  {
    "akinsho/bufferline.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    keys = {
      { "<S-l>", ":BufferLineCycleNext<CR>", silent = true, desc = "Next buffer" },
      { "<S-h>", ":BufferLineCyclePrev<CR>", silent = true, desc = "Prev buffer" },
      { "<C-p>", ":BufferLineMovePrev<CR>", silent = true, desc = "Move buffer left" },
      { "<C-n>", ":BufferLineMoveNext<CR>", silent = true, desc = "Move buffer right" },
      { "<leader>c", ":bdelete<CR>", silent = true, desc = "Close buffer" },
    },
    opts = {},
  },

  -- 文件树
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = "nvim-tree/nvim-web-devicons",
    keys = {
      { "<leader>e", ":NvimTreeToggle<CR>", silent = true, desc = "Explorer" },
      { "<leader>tj", ":NvimTreeFocus<CR>", silent = true, desc = "Focus explorer" },
    },
    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
    opts = {},
  },

  -- 终端
  {
    "akinsho/toggleterm.nvim",
    keys = {
      { "<leader>tt", ":ToggleTerm direction=float<CR>", silent = true, desc = "Terminal float" },
      { "<leader>tv", ":ToggleTerm direction=vertical size=70<CR>", silent = true, desc = "Terminal vertical" },
    },
    opts = { open_mapping = false },
  },

  -- 命令行/消息 UI
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    keys = {
      { "<Esc>", ":Noice dismiss<CR>", silent = true, desc = "Dismiss messages" },
    },
    opts = {},
  },

  -- 光标拖影
  {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    opts = {
      stiffness = 0.8,
      trailing_stiffness = 0.6,
      stiffness_insert_mode = 0.7,
      trailing_stiffness_insert_mode = 0.7,
      damping = 0.95,
      damping_insert_mode = 0.95,
      distance_stop_animating = 0.5,
      hide_target_hack = true,
      never_draw_over_target = true,
    },
  },

  -- 颜色值内联着色（#RRGGBB / rgb() / hsl()）
  {
    "norcalli/nvim-colorizer.lua",
    ft = { "css", "scss", "html", "javascript", "typescript", "vue" },
    config = function()
      require("colorizer").setup({ "css", "scss", "html", "javascript", "typescript", "vue" }, {
        RGB = true, RRGGBB = true, RRGGBBAA = true,
        rgb_fn = true, hsl_fn = true, css = true, css_fn = true,
      })
    end,
  },

  -- 同词高亮
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("illuminate").configure({ providers = { "lsp", "regex" } })
    end,
  },

  -- 专注模式
  {
    "folke/zen-mode.nvim",
    keys = { { "<leader>z", ":ZenMode<CR>", silent = true, desc = "Zen mode" } },
    opts = {
      window = {
        width = 0.75,
        options = { number = false, relativenumber = false, signcolumn = "no", foldcolumn = "0" },
      },
      plugins = { tmux = { enabled = false } },
    },
  },

  -- 键位提示与分组标签
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>g", group = "git" },
        { "<leader>l", group = "lsp" },
        { "<leader>s", group = "search" },
        { "<leader>S", group = "session" },
        { "<leader>t", group = "terminal/tree" },
        { "<leader>C", group = "ai" },
      },
    },
  },
}
