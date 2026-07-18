return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    keys = {
      { "<leader>gj", function() require("gitsigns").nav_hunk("next") end, desc = "Next hunk" },
      { "<leader>gk", function() require("gitsigns").nav_hunk("prev") end, desc = "Prev hunk" },
      { "<leader>gp", function() require("gitsigns").preview_hunk() end, desc = "Preview hunk" },
      { "<leader>gs", function() require("gitsigns").stage_hunk() end, desc = "Stage hunk" },
      { "<leader>gr", function() require("gitsigns").reset_hunk() end, desc = "Reset hunk" },
      { "<leader>gl", function() require("gitsigns").blame_line() end, desc = "Blame line" },
      { "<leader>gd", ":Gitsigns diffthis<CR>", silent = true, desc = "Diff this" },
    },
    opts = {},
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>go", ":DiffviewOpen<CR>", silent = true, desc = "Diffview" },
      { "<leader>gh", ":DiffviewFileHistory %<CR>", silent = true, desc = "File history" },
    },
  },
}
