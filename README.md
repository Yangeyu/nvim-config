# nvim config

自维护的 Neovim 配置。基于 lazy.nvim,`lazy-lock.json` 入库,换机 clone 后首次启动即按锁定版本还原全部插件。

## 换机恢复

```bash
# 1. 外部依赖
brew install neovim ripgrep fd jq
# Nerd Font(图标渲染;终端主字体用 ComicShannsMono NFM):
brew install --cask font-comic-shanns-mono-nerd-font font-symbols-only-nerd-font

# 2. 配置本体
git clone https://github.com/Yangeyu/nvim-config.git ~/.config/nvim

# 3. 首次启动:lazy 按 lock 还原插件,mason 自动安装 LSP,treesitter 编译 parser
nvim
```

其余按需:`deno`(denols)、`go` 工具链(gopls/gofumpt/golines)、`node`(多数前端 LSP 的运行时)。

## 目录结构

```
init.lua              入口,仅 require
lua/config/           与插件无关的裸配置(options/keymaps/autocmds/lazy 自举)
lua/plugins/          每文件一个领域,返回 lazy spec,自动 import:
  ui                  主题/仪表盘(alpha)/状态栏/winbar面包屑(navic)/hlchunk(块勾勒+缩进线)/bufferline/文件树(root-pin根跟随)/终端/noice/which-key
  editor              hop/surround/wildfire/marks/滚动/会话/对齐/翻译/折叠(ufo)
  treesitter          treesitter(master) + textobjects + yati 缩进
  lsp                 nvim 0.11 原生 vim.lsp.config 体系 + mason + schemastore(json/yaml)
  completion          blink.cmp + LuaSnip
  format              conform(vue=prettier, go=goimports+gofumpt+golines)
  finder              telescope 全家 + grug-far
  git                 gitsigns + diffview
  markdown            render-markdown + iterm-image + json-expand
  ai                  windsurf(codeium)
after/ftplugin/       按文件类型微调的落点
```

## 约定

- 插件键位写在各自 spec 的 `keys` 字段(与插件同生共死,天然懒加载);全局键位只进 `config/keymaps.lua`。
- 新增插件 = 在对应领域文件加一段 spec;删插件 = 删那一段,无需其他登记。
- 升级是显式动作:`:Lazy update` 后提交 `lazy-lock.json`。
- `<leader>sc` 直接打开 keymaps.lua;`:Config` 在配置目录内模糊查找任意配置文件(仪表盘 `c` 同款入口)。

