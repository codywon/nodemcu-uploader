#!/usr/bin/env lua

local socket = require 'socket'

local udp = socket.udp()
--udp:setsockname('*', 4000)
udp:settimeout(1)
udp:setoption('broadcast', true)

while true do
	io.write('> ')
	local s = io.read()
	udp:sendto(s, "255.255.255.255", 4000)
	local data, ip, port = udp:receivefrom(256)
	--print(data, ip, port)
	while data do
		--io.write(data)
		if data ~= '\n' and data ~= '> ' then
			print(ip, ':', data)
		end
		data, ip, port = udp:receivefrom(256)
	end
end
