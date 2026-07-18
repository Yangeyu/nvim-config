-- lazy.nvim 自举 + 装载 plugins/ 下全部领域文件。
-- lazy-lock.json 入库：换机 clone 后首次启动即按锁定版本还原全部插件。

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "plugins" } },
  install = { colorscheme = { "catppuccin-mocha", "habamax" } },
  checker = { enabled = false }, -- 升级是显式动作（:Lazy update），不做后台检查
  change_detection = { notify = false },
  performance = {
    rtp = {
      disabled_plugins = { "netrwPlugin", "tohtml", "tutor", "gzip", "zipPlugin", "tarPlugin" },
    },
  },
})
