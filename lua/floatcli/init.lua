-- floatcli.nvim メインモジュール

local M = {}
local config = require("floatcli.config")
local window = require("floatcli.window")
local executor = require("floatcli.executor")

-- 内部状態管理
local state = {
  buf_id = nil,
  win_id = nil,
}

-- ウィンドウとバッファをクリーンアップ
local function cleanup()
  if state.win_id and vim.api.nvim_win_is_valid(state.win_id) then
    vim.api.nvim_win_close(state.win_id, true)
    state.win_id = nil
  end
  
  if state.buf_id and vim.api.nvim_buf_is_valid(state.buf_id) then
    vim.api.nvim_buf_delete(state.buf_id, { force = true })
    state.buf_id = nil
  end
  
  if vim.fn.exists("augroup floatcli") == 1 then
    vim.api.nvim_del_augroup_by_name("floatcli")
  end
end

--- ユーザー設定を初期化
---@param opts? table オプション設定（width, height, border）
function M.setup(opts)
  config.setup(opts)
end

--- フロートウィンドウでコマンドを実行
---@param opts table 実行オプション
---@param opts.commands string[] 実行するコマンド配列
---@param opts.auto_close? boolean コマンド終了時に自動で閉じるか（デフォルト: true）
function M.open(opts)
  opts = opts or {}
  local commands = opts.commands
  local auto_close = opts.auto_close ~= false
  
  if not commands or #commands == 0 then
    vim.notify("No commands specified", vim.log.levels.WARN)
    return
  end
  
  -- バッファが無い or 無効な場合は新規作成
  if not state.buf_id or not vim.api.nvim_buf_is_valid(state.buf_id) then
    state.buf_id = vim.api.nvim_create_buf(false, true)
  end
  
  -- ウィンドウが無い or 無効な場合は新規作成
  if not state.win_id or not vim.api.nvim_win_is_valid(state.win_id) then
    state.win_id = window.create(state.buf_id)
  end
  
  -- autocommand グループを作成（重複登録を防ぐ）
  vim.api.nvim_create_augroup("floatcli", { clear = true })
  
  -- 画面リサイズ時にウィンドウをリサイズ
  vim.api.nvim_create_autocmd("VimResized", {
    group = "floatcli",
    callback = function()
      if state.win_id and vim.api.nvim_win_is_valid(state.win_id) then
        window.resize(state.win_id)
      end
    end,
  })
  
  -- コマンドを実行
  executor.execute(commands, state.buf_id, auto_close, function()
    -- コマンド終了時のコールバック（auto_close == true の場合）
    cleanup()
  end)
  
  -- auto_close が無効な場合は、Enter キーでマニュアル閉じ
  if not auto_close and state.buf_id and vim.api.nvim_buf_is_valid(state.buf_id) then
    vim.keymap.set("n", "<CR>", function()
      cleanup()
    end, { buffer = state.buf_id, noremap = true, silent = true })
  end
end

--- フロートウィンドウを閉じてクリーンアップ
function M.close()
  cleanup()
end

return M
