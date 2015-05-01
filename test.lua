local socket = require 'socket'

local udp = socket.udp()

while true do
	local s = io.read()
	udp:sendto(s, "192.168.10.104", 4000)
	socket.sleep(1)
end
