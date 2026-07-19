local autocmd = vim.api.nvim_create_autocmd

-- yank 高亮反馈
autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank({ timeout = 150 })
  end,
})

-- 外部工具改盘后自动重载 buffer（LSP 随之刷新过期诊断）；
-- checktime 在 cmdline-window 里禁止执行，需跳过
autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd.checktime()
    end
  end,
})

-- 重载时提示，避免内容"无声变化"
autocmd("FileChangedShellPost", {
  callback = function()
    vim.notify("File changed on disk, reloaded", vim.log.levels.INFO)
  end,
})

-- 辅助窗口 q 直接关闭
autocmd("FileType", {
  pattern = { "help", "qf", "checkhealth", "lspinfo" },
  callback = function(ev)
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
  end,
})
