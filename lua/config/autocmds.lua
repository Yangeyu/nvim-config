local autocmd = vim.api.nvim_create_autocmd

-- yank 高亮反馈
autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank({ timeout = 150 })
  end,
})

-- 外部工具改盘后自动同步全部 buffer（含后台隐藏），重载/冲突决策与通知见 config/filesync.lua
require("config.filesync").setup()

-- 辅助窗口 q 直接关闭
autocmd("FileType", {
  pattern = { "help", "qf", "checkhealth", "lspinfo" },
  callback = function(ev)
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
  end,
})
