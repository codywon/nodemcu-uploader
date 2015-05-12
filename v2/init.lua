local ctx = {}
local cmds = {}
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

for i = 1, 16 do
	local f = loadfile('cmd_'..i..'.lua')
	if f then
		local t = f()
		if t.cmd then
			cmds[t.cmd..':'] = t.func
		end
	end
end

local server = net.createServer(net.UDP)

server:on('receive', function(s, c) 
	node.output(nil)
	if c:sub(1, 4) == 'CMD:' then
		local cmd = c:sub(5)
		node.output(function(str) s:send(str) end, 1)
		node.input(cmd)
		return
	end
	if c:sub(1, 7) == 'FILE:S:' then
		local f = c:sub(8)
		if f then
			file.close()
			file.open(f, 'w+')
			s:send('FILE OPENED')
		end
		return
	end
	if c:sub(1, 7) == 'FILE:E:' then
		file.close()
		s:send('FILE CLOSED')
		return
	end
	if c:sub(1, 7) == 'FILE:C:' then
		file.writeline(c:sub(8))
		s:send('+')
		return
	end

	for c, f in pairs(cmds) do
		if c:sub(1, c:len()) == c then
			return f(s, c)
		end
	end
end)

print('listen on port 4000')
server:listen(4000)

for i = 1, 16 do 
	local f = loadfile('init_'..i..'.lua')
	if f then
		local t = f()
		if t and type(t) == 'function' then
			t(ctx)
		end
	end
end

