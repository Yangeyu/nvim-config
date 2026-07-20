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

-- +/_ 调当前窗口宽度（树窗口通用；开文件不重置宽度见 ui.lua 的 resize_window）
map("n", "+", ":vertical resize +5<CR>", { desc = "Wider window", silent = true })
map("n", "_", ":vertical resize -5<CR>", { desc = "Narrower window", silent = true })

-- 包管理：<leader>p 分组，子键与 lvim 的 Plugins 组对齐
map("n", "<leader>pi", ":Lazy install<CR>", { desc = "Install", silent = true })
map("n", "<leader>ps", ":Lazy sync<CR>", { desc = "Sync", silent = true })
map("n", "<leader>pS", ":Lazy home<CR>", { desc = "Status", silent = true })
map("n", "<leader>pc", ":Lazy clean<CR>", { desc = "Clean", silent = true })
map("n", "<leader>pu", ":Lazy update<CR>", { desc = "Update", silent = true })
map("n", "<leader>pp", ":Lazy profile<CR>", { desc = "Profile", silent = true })
map("n", "<leader>pl", ":Lazy log<CR>", { desc = "Log", silent = true })
map("n", "<leader>pd", ":Lazy debug<CR>", { desc = "Debug", silent = true })

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
-- <leader>N：配置维护入口，对标 lvim 的 <leader>L 组
map("n", "<leader>Nc", function()
  vim.cmd.edit(vim.fn.stdpath("config") .. "/lua/config/keymaps.lua")
end, { desc = "Edit keymaps.lua", silent = true })
map("n", "<leader>Nf", function()
  require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Find config files", silent = true })
map("n", "<leader>Ng", function()
  require("telescope.builtin").live_grep({ cwd = vim.fn.stdpath("config") })
end, { desc = "Grep config files", silent = true })
map("n", "<leader>Nk", ":Telescope keymaps<CR>", { desc = "View keymaps", silent = true })
map("n", "<leader>Nl", function()
  vim.cmd.edit(vim.lsp.get_log_path())
end, { desc = "Open LSP logfile", silent = true })
map("n", "<leader>NL", ":edit $NVIM_LOG_FILE<CR>", { desc = "Open Neovim logfile", silent = true })
map("n", "<leader>Nu", ":Lazy update<CR>", { desc = "Update plugins", silent = true })

-- 关 buffer 不动窗口：裸 :bdelete 由 vim 自行挑替补（可能跳到 tree），
-- 这里先把窗口切到轮换 buffer（上一个浏览的），再删目标 buffer
map("n", "<leader>c", function()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].modified then
    vim.notify("Unsaved changes: :w to save or :bd! to force close", vim.log.levels.WARN)
    return
  end
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.api.nvim_win_call(win, function()
      local alt = vim.fn.bufnr("#")
      if alt > 0 and alt ~= buf and vim.bo[alt].buflisted then
        vim.cmd.buffer(alt)
      else
        vim.cmd.bprevious()
      end
    end)
  end
  vim.cmd.bdelete(buf)
end, { desc = "Close buffer", silent = true })

-- 开关底部列表窗口（对齐 lvim 的 QuickFixToggle）：
-- loclist 窗口的 quickfix 标志也是 1，须用 lclose 关，cclose 对它无效
map("n", "<C-q>", function()
  local closed = false
  for _, win in ipairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 then
      vim.api.nvim_win_call(win.winid, function()
        vim.cmd(win.loclist == 1 and "lclose" or "cclose")
      end)
      closed = true
    end
  end
  if not closed then
    vim.cmd.copen()
  end
end, { desc = "Toggle quickfix/loclist", silent = true })

map("n", "<leader>V", "ggVG", { desc = "Select all" })
map("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear highlight", silent = true })
map("n", "<leader>w", ":w<CR>", { desc = "Save", silent = true })
map("n", "<leader>q", ":q<CR>", { desc = "Quit window", silent = true })
map("n", "<leader>Q", ":qall<CR>", { desc = "Quit all", silent = true })
