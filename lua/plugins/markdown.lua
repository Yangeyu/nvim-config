return {
  -- markdown 标题/表格/代码块等在 buffer 内直接渲染；图片由 iterm-image.nvim 负责。
  -- 整行背景条一律不要（视觉统一）：code 块背景走官方开关；标题行背景的
  -- backgrounds 列表无法用空表覆盖（deep merge 会保留默认），故清空其高亮组
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    dependencies = "nvim-treesitter/nvim-treesitter",
    opts = {
      code = {
        disable_background = true,
        language_border = " ", -- 语言标签行默认用实心块 █ 填满整行
      },
    },
    config = function(_, opts)
      require("render-markdown").setup(opts)
      for i = 1, 6 do
        vim.api.nvim_set_hl(0, "RenderMarkdownH" .. i .. "Bg", {})
      end
    end,
  },

  -- 图片预览：自研插件，iTerm2 原生图片协议渲染
  {
    "Yangeyu/iterm-image.nvim",
    ft = "markdown",
    opts = {},
  },

  -- :JsonExpand — 把 JSON 里转义存放的 JSON 字符串就地展开并美化
  {
    "Yangeyu/json-expand.nvim",
    cmd = "JsonExpand",
  },
}
