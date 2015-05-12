#!/usr/bin/env lua

if #arg < 2 then
	print('Usage: '..arg[0]..'<ip> <filename>')
	return 0
end

local socket = require 'socket'

local udp = socket.udp()
udp:settimeout(1)
udp:setoption('broadcast', true)
udp:setsockname('*', 4001)

local f = io.open(arg[2])
if not f then
	print('File not exits '..arg[2])
	return
end

local function send(s)
	local l = udp:sendto(s, arg[1], 4000)
	assert(l == s:len())
end

send('FILE:S:'..arg[2])
print(udp:receivefrom(256))

for line in f:lines() do
	local s = 'FILE:C:'..line
	send(s)
	print(udp:receivefrom(256))
end

send('FILE:E:'..arg[2])
print(udp:receivefrom(256))

