#!/usr/bin/env lua

local socket = require 'socket'

local udp = socket.udp()
udp:settimeout(1)
udp:setoption('broadcast', true)
udp:sendto('CMD:node.restart()', arg[1] or "255.255.255.255", 4000)
local data, ip, port = udp:receivefrom(256)
print(data, ip, port)
