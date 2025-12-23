# floatcli.nvim

A Neovim plugin for running arbitrary CLI tools in a floating window.

![demo](demo.gif)

## Installation

Use your favorite package manager.

## Setup

```lua
require('floatcli').setup({
  width = 80,           -- Window width (percentage, default: 80)
  height = 80,          -- Window height (percentage, default: 80)
  border = 'rounded',   -- Border style (default: 'single')
})
```

## Usage

### Run a single command

```lua
require('floatcli').open({
  commands = { 'lazygit' },
})
```

### Run multiple commands sequentially

```lua
require('floatcli').open({
  commands = { 'echo "Running tests"', 'npm test' },
})
```

### Control auto-close behavior

```lua
require('floatcli').open({
  commands = { 'npm test' },
  auto_close = false,  -- Manually close with Enter
})
```

## Configuration

- `width`: Float window width as percentage of screen width (default: 80)
- `height`: Float window height as percentage of screen height (default: 80)
- `border`: Border style - 'single', 'double', 'rounded', 'solid', 'shadow', 'none' (default: 'single')

