local autocmd = vim.api.nvim_create_autocmd

-- yank 高亮反馈
autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank({ timeout = 150 })
  end,
})

-- 辅助窗口 q 直接关闭
autocmd("FileType", {
  pattern = { "help", "qf", "checkhealth", "lspinfo" },
  callback = function(ev)
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
  end,
})
