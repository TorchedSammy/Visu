# Visu
> 📊 Audio visualizer for [Lite XL](https://lite-xl.com) 🎶

This is a little demo audio visualizer for Lite XL.
It takes a lot of CPU, so beware.

https://user-images.githubusercontent.com/38820196/162533702-f00bcd71-ced4-494d-a40c-2d84b999f79e.mp4

# Installation
But if you still want it anyway, just git clone into your plugins folder.
Requires `cava` and does not work on Windows.

# Config
There are a few options to customize Visu.
```lua
local config = require 'core.config'
local common = require 'core.common'

config.plugins.visu = {
	-- number of bars
	barsNumber = 12,
	-- color of the bars
	color = {common.color 'rgba(255, 255, 255, 1)'},
	-- number of threads to make to get visualizer info. higher the better for
	-- the visualizer, lower for general performance.
	workers = 180
}
```

# License
MIT

