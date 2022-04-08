-- mod-version:2 -- lite-xl 2.0
local core = require 'core'
local style = require 'core.style'
local RootView = require 'core.rootview'

local barsNumber = 32
local confFormat = [[
[general]
bars = %d

[output]
method = raw
raw_target = %s
bit_format = %s
]]

local cavaConf = confFormat:format(barsNumber, '/dev/stdout', '16bit')
local tmp = core.temp_filename('cavaconf', '/tmp')

do
	local f <close> = io.open(tmp, 'w')
	f:write(cavaConf)
end
local proc = process.start {'cava', '-p', tmp}


local chunkSize = 2 * barsNumber
local byteFormat = 'H'
local byteMax = 65535

local function getLatestInfo()
	local data = proc:read_stdout(chunkSize)
	if data:len() < chunkSize then return nil end
	local fmt = byteFormat:rep(barsNumber)
	local bars = table.pack(string.unpack(fmt, data))

	for i, b in ipairs(bars) do
		bars[i] = b / byteMax
	end

	return bars
end

local rvDraw = RootView.draw
function RootView:draw(...)
	rvDraw(self, ...)

	if core.active_view == core.command_view then return end
	local w = 10 * SCALE
	local bars = getLatestInfo()
	if bars ~= nil then
		core.redraw = true
		for i = 1, barsNumber do
			core.log_quiet(tostring(bars[i]))
			local h = (bars[i] * 79) + 1 * SCALE
			renderer.draw_rect(self.size.x - (30 * i), self.size.y - core.status_view.size.y - h - (2 * SCALE), w, h, style.text)
		end
	end
end
