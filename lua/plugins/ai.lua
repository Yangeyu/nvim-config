return {
  -- 行内补全（codeium）
  {
    "Exafunction/windsurf.vim",
    event = "InsertEnter",
    config = function()
      vim.g.codeium_disable_bindings = 1
      vim.keymap.set("i", ";;", function() return vim.fn["codeium#Accept"]() end, { expr = true })
      vim.keymap.set("i", ";,", function() return vim.fn["codeium#CycleCompletions"](1) end, { expr = true })
      vim.keymap.set("i", ";l", function() return vim.fn["codeium#AcceptNextLine"]() end, { expr = true })
      vim.keymap.set("i", "<C-x>", function() return vim.fn["codeium#Clear"]() end, { expr = true })
    end,
  },

}
