-- mod-version:2 -- lite-xl 2.0
local core = require 'core'
local common = require 'core.common'
local command = require 'core.command'
local style = require 'core.style'
local config = require 'core.config'
local RootView = require 'core.rootview'

local function merge(orig, tbl)
	if tbl == nil then return orig end
	for k, v in pairs(tbl) do
		orig[k] = v
	end

	return orig
end

local conf = merge({
	barsNumber = 12,
	workers = 180,
	hidden = false
}, config.plugins.visu)

local styl = merge({
	bars = {common.color 'rgba(255, 255, 255, 1)'}
}, style.visu)

local hidden = conf.hidden
local confFormat = [[
[general]
bars = %d

[output]
method = raw
raw_target = %s
bit_format = %s
]]

local cavaConf = confFormat:format(conf.barsNumber, '/dev/stdout', '16bit')
local tmp = core.temp_filename('cavaconf', '/tmp')
do
	local f = io.open(tmp, 'w')
	f:write(cavaConf)
	f:close()
end

local proc = process.start {'cava', '-p', tmp}

local chunkSize = 2 * conf.barsNumber
local byteFormat = 'H'
local byteMax = 65535

local function getLatestInfo()
	local data = proc:read_stdout(chunkSize)
	if data:len() < chunkSize then return nil end
	local fmt = byteFormat:rep(conf.barsNumber)
	local bars = table.pack(string.unpack(fmt, data))

	for i, b in ipairs(bars) do
		bars[i] = b / byteMax
	end

	return bars
end
local b = getLatestInfo()

for _ = 1, conf.workers do
core.add_thread(function()
	while true do
		local bn = getLatestInfo()
		if bn ~= nil then
			b = bn
		end
		coroutine.yield(0)
	end
end)
end

local rvDraw = RootView.draw
function RootView:draw(...)
	rvDraw(self, ...)
	if hidden then return end

	if core.active_view == core.command_view then return end
	local w = 10 * SCALE

	local bn = getLatestInfo()
	if bn ~= nil then
		b = bn
	end
	if b ~= nil then
		core.redraw = true
		for i = 1, conf.barsNumber do
			local h = ((b[i] * 239) + 1) * SCALE
			-- y = self.size.y - core.status_view.size.y
			renderer.draw_rect(self.size.x - (30 * i), self.size.y - core.status_view.size.y - h - (5 * SCALE), w, h, styl.bars)
			--[[
			-- dual in the middle
			renderer.draw_rect(self.size.x - (30 * i), (self.size.y / 2), w, h / 2, styl.bars)
			renderer.draw_rect(self.size.x - (30 * i), self.size.y / 2 - h / 2, w, h / 2, styl.bars)
			]]--
		end
	end
end

command.add(nil, {
	['visu:hide'] = function() hidden = true end,
	['visu:show'] = function() hidden = false end,
})
