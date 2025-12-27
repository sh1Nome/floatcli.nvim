-- CLI コマンドの実行

local M = {}

--- 指定されたコマンド群を実行
---@param commands string[] 実行するコマンド配列
---@param bufnr number 実行するバッファID
---@param auto_close boolean コマンド終了時に自動で閉じるか
---@param on_exit? fun() コマンド終了時のコールバック（auto_close == true の場合に呼ぶ）
function M.execute(commands, bufnr, auto_close, on_exit)
	if not commands or #commands == 0 then
		vim.notify("No commands provided", vim.log.levels.WARN)
		return
	end

	-- 複数コマンドを && で結合して順次実行
	local cmd_string = table.concat(commands, " && ")

	-- バッファで terminal を実行
	vim.api.nvim_buf_call(bufnr, function()
		vim.cmd.terminal(cmd_string)
		-- terminal実行後、インサートモードに変更
		vim.cmd("startinsert")
		-- バッファ一覧に表示しない
		vim.api.nvim_set_option_value("buflisted", false, { buf = bufnr })
	end)

	-- auto_close が有効な場合、TermClose イベントでコールバック実行
	if auto_close and on_exit then
		vim.api.nvim_create_autocmd("TermClose", {
			buffer = bufnr,
			once = true,
			callback = on_exit,
		})
	end
end

return M
