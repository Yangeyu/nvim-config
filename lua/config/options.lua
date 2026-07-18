-- 编辑器本体选项：不依赖任何插件，断网裸启也完整生效

-- leader 必须先于 lazy 与一切 keymap 设置
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 内建 ftplugin 会给 markdown 强设 4 格缩进，关掉以回落到全局的 2
vim.g.markdown_recommended_style = 0

local opt = vim.opt

opt.number = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.wrap = false
opt.termguicolors = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.splitbelow = true
opt.splitright = true
opt.scrolloff = 4
opt.pumheight = 12

opt.ignorecase = true
opt.smartcase = true

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2

opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.writebackup = false

opt.updatetime = 200
opt.timeoutlen = 500 -- vim-surround 及多级键位需要的窗口时长

-- 折叠由 nvim-ufo 接管（treesitter provider）；大 foldlevel 让文件默认全展开
opt.foldenable = true
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldopen:remove("search")

opt.shortmess:append("cI")
opt.spelllang:append("cjk") -- vim 拼写检查算法不支持 CJK，跳过以免误报
