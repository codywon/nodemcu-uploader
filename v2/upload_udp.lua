#!/usr/bin/env lua

if #arg < 1 then
	print('Usage: '..arg[0]..'<filename> <ip default is 255.255.255.255>')
	return 0
end

local file = arg[1]
local ip = arg[2] or '255.255.255.255'

print('FILE:', file)
print('IP:', ip)

local socket = require 'socket'

local udp = socket.udp()
udp:settimeout(1)
udp:setoption('broadcast', true)
udp:setsockname('*', 4001)

local f = io.open(file)
if not f then
	print('File not exits '..file)
	return
end

local function send(s)
	local l = udp:sendto(s, ip, 4000)
	assert(l == s:len())
end

send('INFO:')
print('R:', udp:receivefrom(256))
send('FILE:S:'..file)
print('R:', udp:receivefrom(256))

for line in f:lines() do
	local s = 'FILE:C:'..line
	send(s)
	print(udp:receivefrom(256))
end

send('FILE:E:'..file)
print(udp:receivefrom(256))

--if 'init.lua' == file then
	send('CMD:node.restart()')
	print(udp:receivefrom(256))
--end

