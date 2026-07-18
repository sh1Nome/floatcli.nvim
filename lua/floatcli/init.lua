--- *floatcli*  A Neovim plugin for running arbitrary CLI tools in a floating window
---
--- MIT License Copyright (c) 2025 sh1Nome
---
---@toc

--- floatcli.nvim is a Neovim plugin for running arbitrary CLI tools in a
--- floating window.
---@tag floatcli-introduction
---@toc_entry Introduction

--- Use your favorite package manager.
---@tag floatcli-installation
---@toc_entry Installation

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

	if vim.fn.exists("#floatcli") == 1 then
		vim.api.nvim_del_augroup_by_name("floatcli")
	end
end

--- Initialize user configuration
---
---@param opts? table Configuration options
---   - width: number Float window width as percentage of screen width (default: 80)
---   - height: number Float window height as percentage of screen height (default: 80)
---   - row: number|nil Top edge position as percentage of screen height (default: nil = centered)
---   - col: number|nil Left edge position as percentage of screen width (default: nil = centered)
---   - border: string Border style. Valid values:
---     'single', 'double', 'rounded', 'solid', 'shadow', 'none' (default: 'single')
---@tag floatcli-api-setup
---@toc_entry setup()
function M.setup(opts)
	config.setup(opts)
end

--- Execute commands in a float window
---
---@param opts table Execution options
---   - commands: string[] Array of commands to execute
---   - auto_close?: boolean Automatically close the window when commands finish (default: true)
---
---@usage
--- -- Run a single command:
--- require('floatcli').open({
---   commands = { 'lazygit' },
--- })
---
--- -- Run multiple commands sequentially:
--- require('floatcli').open({
---   commands = { 'echo "Running tests"', 'npm test' },
--- })
---
--- -- Control auto-close behavior:
--- require('floatcli').open({
--- commands = { 'npm test' },
---   auto_close = false,  -- Manually close with Enter
--- })
---@tag floatcli-api-open
---@toc_entry open()
function M.open(opts)
	opts = opts or {}
	local commands = opts.commands
	local auto_close = opts.auto_close ~= false

	if not commands or #commands == 0 then
		vim.notify("No commands specified", vim.log.levels.WARN)
		return
	end

	-- バッファが新規かどうかを判定
	local is_new_buffer = not state.buf_id or not vim.api.nvim_buf_is_valid(state.buf_id)

	-- バッファが無い or 無効な場合は新規作成
	if is_new_buffer then
		state.buf_id = vim.api.nvim_create_buf(false, true)
	end

	-- ウィンドウが無い or 無効な場合は新規作成
	if not state.win_id or not vim.api.nvim_win_is_valid(state.win_id) then
		state.win_id = window.create(state.buf_id)
	end

	-- 新規バッファの場合のみ初期化処理を実行
	if is_new_buffer then
		-- autocommand グループを作成
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
		if not auto_close then
			vim.keymap.set("n", "<CR>", function()
				cleanup()
			end, { buffer = state.buf_id, noremap = true, silent = true })
		end
	end

	-- 毎回インサートモードに変更
	executor.focus(state.buf_id)
end

return M
