# floatcli.nvim Specification

## 概要

floatcli.nvim は、Neovim のフロートウィンドウで任意の CLI ツールを実行できるプラグインです。

## ディレクトリ構造

```
floatcli.nvim/
├── lua/
│   └── floatcli/
│       ├── init.lua          # setup関数、公開API
│       ├── window.lua        # フロートウィンドウの管理
│       ├── executor.lua      # CLI実行ロジック
│       └── config.lua        # デフォルト設定
├── plugin/
│   └── floatcli.lua          # プラグインのエントリポイント
├── README.md
└── SPEC.md
```

## 主要機能

### 1. フロートウィンドウ上での CLI 実行

- 複数の CLI コマンドを順次実行可能
- nvim の `vim.opt.shell` と `vim.opt.shellcmdflag` に従う
- ウィンドウは画面の中央に固定配置
- 複数回 `open()` を呼んでも、既存ウィンドウをリセットしない（再利用）

### 2. setup 関数での設定

```lua
require('floatcli').setup({
  width = 80,           -- フロートウィンドウの幅（デフォルト: 80）
  height = 20,          -- フロートウィンドウの高さ（デフォルト: 20）
  border = 'rounded',   -- ボーダースタイル（デフォルト: 'single'）
})
```

### 3. ウィンドウの位置計算

- ターミナルサイズ変更時に自動再計算
- 常に画面中央に配置

## ユースケース

### 1. CLI コマンドの実行

```lua
-- 単一コマンド
require('floatcli').open({
  commands = { 'lazygit' },
})

-- 複数コマンドの順次実行
require('floatcli').open({
  commands = { 'echo "Running tests"', 'npm test' },
})

-- auto_close 設定を指定
require('floatcli').open({
  commands = { 'npm test' },
  auto_close = false,  -- Enterキーで手動閉じ
})
```

### 2. カスタム設定

```lua
require('floatcli').setup({
  width = 100,
  height = 30,
  border = 'double',
})
```

プラグインのグローバル設定を変更

## 実装詳細

### config.lua

デフォルト設定を管理

```lua
return {
  width = 80,
  height = 20,
  border = 'single',
}
```

### window.lua

- `calculate_geometry()` : ウィンドウの幅・高さ・位置を計算（画面中央に配置）
- `create(buf_id)` : フロートウィンドウを作成して表示
- `resize(win_id)` : フロートウィンドウをリサイズ

### executor.lua

- `execute(commands, bufnr)` : CLI コマンドを実行
- nvim の shell 設定を参照して実行
- エラーが発生した場合は `vim.notify()` で通知

### init.lua

- `setup(opts)` : 設定の初期化
- `open(commands, opts)` : CLI を実行し、フロートウィンドウを表示
  - `commands` : 実行するコマンドの配列またはテーブル
  - `opts` : `auto_close`（デフォルト: true）等の設定

## 動作フロー

1. ユーザーが `open()` を呼び出す
2. 設定に基づいてフロートウィンドウを作成
3. 指定されたコマンドをシェルで実行
4. 出力をバッファに書き込む
5. ウィンドウを表示

