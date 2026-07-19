return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    keys = {
      { "<leader>gj", function() require("gitsigns").nav_hunk("next") end, desc = "Next hunk" },
      { "<leader>gk", function() require("gitsigns").nav_hunk("prev") end, desc = "Prev hunk" },
      { "<leader>gp", function() require("gitsigns").preview_hunk() end, desc = "Preview hunk" },
      { "<leader>gs", function() require("gitsigns").stage_hunk() end, desc = "Stage hunk" },
      -- undo_stage_hunk 已被 gitsigns 标记 deprecated（对已 stage 的 hunk 再按 gs 同效），
      -- 但仍可用，保留以维持 lvim 肌肉记忆
      { "<leader>gu", function() require("gitsigns").undo_stage_hunk() end, desc = "Undo stage hunk" },
      { "<leader>gr", function() require("gitsigns").reset_hunk() end, desc = "Reset hunk" },
      { "<leader>gR", function() require("gitsigns").reset_buffer() end, desc = "Reset buffer" },
      { "<leader>gl", function() require("gitsigns").blame_line() end, desc = "Blame" },
      { "<leader>gL", function() require("gitsigns").blame_line({ full = true }) end, desc = "Blame line (full)" },
      { "<leader>gd", ":Gitsigns diffthis HEAD<CR>", silent = true, desc = "Git diff" },
    },
    opts = {
      attach_to_untracked = true,
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gv", ":DiffviewOpen<CR>", silent = true, desc = "Diffview" },
      { "<leader>gh", ":DiffviewFileHistory %<CR>", silent = true, desc = "File history" },
    },
  },
}
