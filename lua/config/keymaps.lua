-- 全局键位：只放与插件无关的。插件键位写在各自 spec 的 keys 字段，
-- 与插件同生共死（删插件不留悬空键位），并天然获得懒加载。

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- 插入模式逃逸与行内跳动
map("i", "jj", "<Esc>", opts)
map("i", "kk", "<Esc>", opts)
map("i", ";a", "<Esc>la", opts)
map("i", ";A", "<Esc>A", opts)

-- 视觉行移动
map("n", "j", "gj", opts)
map("n", "k", "gk", opts)

-- 窗口跳转
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- 粘贴最近一次 yank（不被 delete 污染）
map({ "n", "v" }, "<leader>pp", '"0p', opts)

-- 选区直接转为搜索 / 统计选区字数
map("v", "<leader>f", 'y/<C-r>"<CR>', opts)
map("v", "<leader>c", "g<C-g>", opts)

-- 缩进后保持选区
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- :Config — 在配置目录内模糊查找，快速跳到任意配置文件
vim.api.nvim_create_user_command("Config", function()
  require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Browse nvim config files" })

map("n", "<leader>gv", "ggVG", { desc = "Select all" })
map("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear highlight", silent = true })
map("n", "<leader>w", ":w<CR>", { desc = "Save", silent = true })
map("n", "<leader>q", ":q<CR>", { desc = "Quit window", silent = true })
map("n", "<leader>Q", ":qall<CR>", { desc = "Quit all", silent = true })
