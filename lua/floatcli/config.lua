-- デフォルト設定の管理

local M = {}

local defaults = {
	width = 80, -- 画面幅に対するパーセンテージ（デフォルト: 80%）
	height = 80, -- 画面高さに対するパーセンテージ（デフォルト: 80%）
	border = "single",
}

local config = {}

--- ユーザー設定でデフォルト設定を上書き
---@param opts? table 設定オプション
---@param opts.width? number フロートウィンドウの幅（パーセンテージ、デフォルト: 80）
---@param opts.height? number フロートウィンドウの高さ（パーセンテージ、デフォルト: 80）
---@param opts.border? string ボーダースタイル（デフォルト: 'single'）
---@return table 結合された設定
function M.setup(opts)
	config = vim.tbl_deep_extend("force", defaults, opts or {})
	return config
end

--- 指定したキーの設定値を取得。キーが無ければ全設定を返す
---@param key? string 設定キー
---@return any 設定値または全設定テーブル
function M.get(key)
	if key then
		return config[key]
	end
	return config
end

return M
