-- 外部改盘同步：把全部文件 buffer 与磁盘对齐（含后台隐藏 buffer）。
-- 无参 `:checktime` 对没有窗口的隐藏 buffer 不会触发 autoread 重载，
-- 外部工具（AI 助手/脚本）批量改盘后，后台 buffer 滞留旧内容，
-- LSP 拿到的是 buffer 内容而非磁盘内容，于是报出过期诊断；
-- 逐 buffer 在其上下文中 checktime 才等效于手动聚焦一遍（实测 100 buffer 全量约 3ms）。
local M = {}

-- 重载/冲突通知攒批：一轮同步涉及多文件时只弹一条
local reloaded, conflicted = {}, {}
local flush_scheduled = false

local function flush()
  flush_scheduled = false
  if #reloaded > 0 then
    vim.notify("Reloaded from disk: " .. table.concat(reloaded, ", "), vim.log.levels.INFO)
    reloaded = {}
  end
  if #conflicted > 0 then
    vim.notify(
      "Changed on disk but has unsaved edits (kept local, :e! to discard): "
        .. table.concat(conflicted, ", "),
      vim.log.levels.WARN
    )
    conflicted = {}
  end
end

-- 接管外部变更的处理决策（定义了 FileChangedShell 后 W12 提示不再弹出）：
-- 干净 buffer 直接重载；有未保存修改的保留本地内容并警告，绝不静默丢改动
local function on_file_changed(ev)
  local name = vim.fn.fnamemodify(ev.file, ":t")
  if vim.v.fcs_reason == "deleted" then
    vim.v.fcs_choice = "" -- 文件被删：保留 buffer 内容，:w 即可找回
    conflicted[#conflicted + 1] = name .. " (deleted on disk)"
  elseif vim.bo[ev.buf].modified then
    vim.v.fcs_choice = ""
    conflicted[#conflicted + 1] = name
  else
    vim.v.fcs_choice = "reload"
    reloaded[#reloaded + 1] = name
  end
  if not flush_scheduled then
    flush_scheduled = true
    vim.schedule(flush)
  end
end

local last_sync = 0

---@param opts? { force?: boolean } force 跳过节流（手动触发的 <leader>lR 用）
function M.sync(opts)
  if vim.fn.getcmdwintype() ~= "" then
    return -- cmdline-window 内禁止 checktime
  end
  local now = vim.uv.now()
  if not (opts and opts.force) and now - last_sync < 500 then
    return -- 节流：快速连续切 buffer 时 BufEnter 密集触发
  end
  last_sync = now
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if
      vim.api.nvim_buf_is_loaded(buf)
      and vim.bo[buf].buftype == ""
      and vim.api.nvim_buf_get_name(buf) ~= ""
    then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd("silent! checktime " .. buf)
      end)
    end
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup("filesync", { clear = true })
  vim.api.nvim_create_autocmd("FileChangedShell", { group = group, callback = on_file_changed })
  vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
    group = group,
    callback = function()
      M.sync()
    end,
  })
end

return M
