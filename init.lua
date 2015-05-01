local wifi_reg = true

if wifi.STATION ~= wifi.getmode() then
	wifi_reg = false
else
	local s = wifi.sta.getip()
	if not s then
		if 0 == wifi.sta.status() then
			wifi_reg = true
		end
	end
end

if wifi_reg then
	wifi.setmode(wifi.STATION)
	wifi.sta.config("CCH-DIRK", "12345678901232")
	wifi.sta.connect()
end

local server = net.createServer(net.UDP)

server:on('receive', function(s, c) 
	local function mo (s)
		return function(str)
			uart.write(0, str)
			s:send(str)
		end
	end
	node.output(mo(s), 0)
	node.input(c)
	--node.output(nil)
end)

print('Listen on port 4000')
server:listen(4000)

