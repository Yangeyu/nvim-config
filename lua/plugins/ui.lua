return {
  -- 主题：catppuccin 为主力，其余备选按需 :colorscheme 切换
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        -- 选中行只留背景：默认 rosewater 前景会盖掉条目内的语义色；
        -- custom_highlights 逐键合并，fg 必须显式置 NONE 才能去掉
        custom_highlights = function(c)
          return {
            TelescopeSelection = { fg = "NONE", bg = c.surface0, style = { "bold" } },
            -- 默认蓝色与目录名同色，未跟踪文件按惯例用绿色区分
            NvimTreeGitNew = { fg = c.green },
          }
        end,
      })
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
      -- 原 slant 版按斜线连续性放大一档（/、\ 沿 45° 延续，_ 横向延伸）
      dashboard.section.header.val = {
        "                                                    __                  ",
        "                                                   /  \\                 ",
        "      ________    ______    ________  __      ____| __ |______  ______  ",
        "     /        \\  /      \\  /        \\   |    /   /   /        `       \\ ",
        "    /   ____   \\/   __   \\/   ____   \\  |   /   /   /   ____    ____   \\",
        "   /   /   /   /         /   /   /   /  |  /   /   /   /   /   /   /   /",
        "  /   /   /   /     ____/   / __/   /   | /   /   /   /   /   /   /   / ",
        " /   /   /   /\\        /\\          /|        /   /   /   /   /   /   /  ",
        "/ __/   / __/  \\______/  \\________/ | ______/ __/ __/   / __/   / __/   ",
        "                                                                        ",
      }
      -- 图标沿用 lvim icons.ui 的码位（在本机字体下已验证可渲染）
      dashboard.section.buttons.val = {
        dashboard.button("f", "󰈞  Find File", ":Telescope find_files<CR>"),
        dashboard.button("n", "  New File", ":ene!<CR>"),
        dashboard.button("p", "  Projects", ":Telescope project<CR>"),
        dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
        dashboard.button("t", "󰊄  Find Text", ":Telescope live_grep<CR>"),
        dashboard.button("c", "  Configuration", ":Config<CR>"),
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

  -- winbar 面包屑的数据源（LspAttach 时在 lsp.lua 里显式 attach）
  { "SmiteshP/nvim-navic", lazy = true, opts = { highlight = true } },

  -- 缩进可视化：动画勾勒当前 chunk（语法不完整时变红）+ 暗色缩进线
  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      chunk = {
        enable = true,
        use_treesitter = true,
        style = {
          { fg = "#61AFEF" }, -- 正常 chunk
          { fg = "#E06C75" }, -- 语法不完整的 chunk
        },
        exclude_filetypes = { alpha = true, NvimTree = true },
      },
      indent = {
        enable = false,
        chars = { "▏" },
        exclude_filetypes = { alpha = true, NvimTree = true },
      },
    },
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
      -- 与 lvim 对齐：无客户端显示 "LSP Inactive"，否则 "[名字, 名字]"，
      -- 并把 conform 的格式化器一并列出（对应 lvim 列 null-ls 格式化器的行为）
      local function lsp_names()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients == 0 then
          return "LSP Inactive"
        end
        local names = {}
        for _, c in ipairs(clients) do
          names[#names + 1] = c.name
        end
        local ok, conform = pcall(require, "conform")
        if ok then
          for _, f in ipairs(conform.list_formatters(0)) do
            if not vim.tbl_contains(names, f.name) then
              names[#names + 1] = f.name
            end
          end
        end
        return "[" .. table.concat(names, ", ") .. "]"
      end
      require("lualine").setup({
        -- 新版 catppuccin 的 lualine 主题名为 catppuccin-nvim（跟随当前 flavour）
        -- 分隔符置空与 lvim 对齐（去掉默认的 powerline 尖角/三角）
        options = {
          theme = "catppuccin-nvim",
          globalstatus = true,
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = {
            winbar = { "NvimTree", "alpha", "toggleterm", "lazy", "mason", "qf", "help" },
          },
        },
        -- winbar 面包屑：文件名 + navic 符号路径
        winbar = {
          lualine_c = { { "filename", path = 0 }, { "navic" } },
        },
        inactive_winbar = {
          lualine_c = { { "filename", path = 0 } },
        },
        sections = {
          lualine_c = { "filename" },
          lualine_x = {
            { recording, color = { fg = "#ff5555", gui = "bold" } },
            "diagnostics",
            { lsp_names, color = { gui = "bold" } },
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
    },
    opts = {},
  },

  -- 文件树根跟随 + 按项目搜索的根解析（自研，见插件 README：根感知但绝不 :cd）
  {
    "Yangeyu/root-pin.nvim",
    -- 本地开发时切换：dir = vim.fn.expand("~/Workplace/vim-plugins/root-pin.nvim"),
    dependencies = { "nvim-tree/nvim-tree.lua" },
    keys = {
      { "<leader>e", function() require("root-pin").toggle() end, silent = true, desc = "Explorer" },
      { "<leader>tj", function() require("root-pin").reveal() end, silent = true, desc = "Focus explorer" },
    },
    opts = {},
  },

  -- 文件树
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = "nvim-tree/nvim-web-devicons",
    lazy = true, -- 由 root-pin 的键位经 require 拉起
    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
    opts = {
      -- 顶层只显示项目目录名（默认值会拼成 "~/path/.." ）
      renderer = { root_folder_label = ":t", highlight_git = "name" },
      -- 切换 buffer 时树内高亮跟随（当前根内定位；换根由 root-pin 负责）
      update_focused_file = { enable = true },
      -- 树内换根（"-" 上探等）不再联动 :cd，cwd 始终钉在项目根；
      -- 否则 getcwd 跟着漂移，"=" 的还原会失效，telescope 搜索根也会被带跑
      actions = {
        change_dir = { enable = false },
        -- 默认 exclude 含 buftype=nofile，会把 alpha 仪表盘窗口判为不可用，
        -- 导致从树里开文件时另开 split；去掉 nofile 让文件直接替换仪表盘。
        -- 其余 nofile 面板（grug-far 等）按 filetype 继续排除
        open_file = {
          -- 关掉开文件时的 view.resize()，否则它会均分所有窗口、把手动拉的树宽/窗口宽打回
          resize_window = false,
          window_picker = {
            exclude = {
              filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame", "grug-far" },
              buftype = { "terminal", "help" },
            },
          },
        },
      },
      -- "-" 上探父目录后，"=" 回到项目根目录
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        api.config.mappings.default_on_attach(bufnr)
        vim.keymap.set("n", "=", function()
          api.tree.change_root(vim.fn.getcwd())
        end, { buffer = bufnr, desc = "nvim-tree: Back to project root" })
      end,
    },
  },

  -- 终端
  {
    "akinsho/toggleterm.nvim",
    keys = {
      { "<C-\\>", desc = "Terminal float", mode = { "n", "t" } }, -- 实际映射由 open_mapping 注册，此处仅触发懒加载
      { "<leader>tv", ":ToggleTerm direction=vertical size=70<CR>", silent = true, desc = "Terminal vertical" },
      -- 与 lvim 对齐：<leader>gg 全屏展开 lazygit
      {
        "<leader>gg",
        function()
          local Terminal = require("toggleterm.terminal").Terminal
          _G.__lazygit_term = _G.__lazygit_term
            or Terminal:new({
              cmd = "lazygit",
              direction = "float",
              hidden = true,
              float_opts = {
                border = "none",
                width = function() return vim.o.columns end,
                height = function() return vim.o.lines end,
              },
            })
          _G.__lazygit_term:toggle()
        end,
        silent = true,
        desc = "Lazygit",
      },
    },
    -- <C-\> 在 normal/insert/terminal 模式均可开合浮动终端（与 lvim 一致）
    opts = { open_mapping = [[<C-\>]], direction = "float" },
  },

  -- 命令行/消息 UI
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    keys = {
      { "<Esc>", ":Noice dismiss<CR>", silent = true, desc = "Dismiss messages" },
    },
    -- hover 请求发给 buffer 上所有 server，noice 对每个空响应都会弹
    -- "No information available"（如 tailwindcss 在函数名上必空），静默掉
    opts = {
      lsp = { hover = { silent = true } },
      -- hover/签名浮窗加边框，与编辑区分界
      presets = { lsp_doc_border = true },
    },
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
      icons = { mappings = false },
      -- 列宽上限：g 组里 nvim 内置的超长描述（gx/gO 等）会把单列撑满全屏，
      -- 封顶后与 <leader> 面板一样多列排布
      layout = { width = { min = 20, max = 40 } },
      spec = {
        { "gx", desc = "Open with system handler" },
        { "gO", desc = "Document symbols" },
        { "<leader>g", group = "git" },
        { "<leader>l", group = "lsp" },
        { "<leader>N", group = "nvim" },
        { "<leader>p", group = "plugins" },
        { "<leader>s", group = "search" },
        { "<leader>S", group = "session" },
        { "<leader>t", group = "terminal/tree" },
      },
    },
  },
}
