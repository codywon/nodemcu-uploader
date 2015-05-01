#!/usr/bin/env lua

if #arg < 1 then
	print('Usage: '..arg[0]..' <filename>')
	return 0
end

local serial = require 'serial'
local port = serial.new()

local function read(timeout)
	local timeout = timeout or 100
	local re = {}
	local r, data, len = port:read(256, timeout)
	while r and len > 0 do
		re[#re + 1] = data
		r, data, len = port:read(256, timeout)
	end
	if #re == 0 then
		return nil
	end
	print(table.concat(re))
	return table.concat(re)
end

port:open('/dev/ttyUSB2', {flowcontrol = 'XON_XOFF'})
read()
--[[
print('Remove previous file')
port:write('file.remove("'..arg[1]..'")')
read()
]]--
print('Open file to write')
port:write('file.open("'..arg[1]..'", "w+")\n')
read()

local f = io.open(arg[1])
if not f then
	print('File not exits '..arg[1])
	return
end

for line in f:lines() do
	local s = line:gsub('"', '\\"')
	--print(s)
	s = 'file.writeline("'..s..'")\n'
	port:write(s)
	read()
end

port:write('file.close()\n')
read()

port:write('node.restart()\n')

while true do
	read()
end
