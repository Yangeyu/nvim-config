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
    -- 勿包 root-pin.git_root：diffview 解析仓库的候选顺序本就是
    -- path 参数 → 当前 buffer 文件 → cwd（vcs/adapters/git/init.lua 的
    -- get_repo_paths），与 git_root 语义逐条一致，包了纯属冗余
    keys = {
      { "<leader>gv", ":DiffviewOpen<CR>", silent = true, desc = "Diffview" },
      { "<leader>gh", ":DiffviewFileHistory %<CR>", silent = true, desc = "File history" },
    },
    -- diffview 默认没有关闭键（q 只绑在 option/help 浮窗），只能敲 :DiffviewClose；
    -- 补 q 一键退出，与 help/qf 等辅助窗口的 q 语义一致。
    -- 仅在 diffview 的 tab 内覆盖，代价是这些窗口里不能录宏
    opts = {
      keymaps = {
        view = { { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close Diffview" } } },
        file_panel = { { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close Diffview" } } },
        file_history_panel = { { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close Diffview" } } },
      },
    },
  },
}
