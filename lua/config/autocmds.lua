local autocmd = vim.api.nvim_create_autocmd

-- yank 高亮反馈
autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank({ timeout = 150 })
  end,
})

-- 外部工具（如 Claude Code）改了磁盘文件后，切回窗口/换 buffer/停顿时
-- 自动重载，重载会向 LSP 推送新内容，过期诊断随之刷新。
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
