local wifi_reg = true

if wifi.STATION ~= wifi.getmode() then
	wifi_reg = false
else
	local s = wifi.sta.getip()
	if not s then
		wifi_reg = false
	end
end

if not wifi_reg then
	wifi.setmode(wifi.STATION)
	wifi.sta.config("CCH-DIRK", "12345678")
	wifi.sta.connect()
end

local server = net.createServer(net.UDP)

server:on('receive', function(s, c) 
	node.output(nil)
	if c:sub(1, 4) == 'CMD:' then
		local cmd = c:sub(5)
		node.output(function(str) s:send(str) end, 1)
		node.input(cmd)
	end
	if c:sub(1, 5) == 'GPIO:' then
		local data = c:sub(6)
		local op = data:sub(1,1)
		local r = nil
		if op == 'w' then
			local i, s = data:match('w(.+):(.+)')
			if i and s then
				gpio.mode(tonumber(i), gpio.OUTPUT)
				gpio.write(tonumber(i), tonumber(s))
				r = gpio.read(i) or 'UNKONWN STATE'
			end
		elseif op == 'r' then
			local i = tonumber(data:sub(2))
			if i then
				gpio.mode(i, gpio.INPUT)
				r = gpio.read(i) or 'UNKONWN STATE'
			end
		end

		s:send(r or 'UNKNOWN')
	end
	if c:sub(1, 4) == 'ADC:' then
		local id = tonumber(c:sub(5))
		local v = adc.read(0)
		s:send(v)
	end
	if c:sub(1, 5) == 'FILE:' then
		if c:sub(6, 7) == 'S:' then
			local f = c:sub(8)
			if f then
				file.close()
				file.open(f, 'w+')
			end
		end
		if c:sub(6, 7) == 'E:' then
			file.close()
		end
		if c:sub(6, 7) == 'C:' then
			file.writeline(c:sub(8))
		end
	end
end)

print('Listen on port 6000')
server:listen(6000)
print('Start timer')
tmr.alarm(0, 1000, 1, function()
	local v = adc.read(0)
	if v > 300 then
		gpio.write(1, 0)
	else
		gpio.write(1, 1)
	end
end)
print('DONE')
