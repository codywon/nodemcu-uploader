local ctx = {}
local cmds = {}
local wifi_reg = true

local ver = '0.1.2'

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
	else
		break
	end
end

local server = net.createServer(net.UDP)

server:on('receive', function(s, c) 
	if c:sub(1, 4) == 'CMD:' then
		local cmd = c:sub(5)
		local f, err = loadstring(cmd)
		if f then
			local r = f()
			print(r)
			return s:send(r or '')
		else
			return s:send('ERROR:'..err)
		end
	end
	if c:sub(1, 4) == 'VER:' then
		return s:send('VER:'..ver)
	end
	if c:sub(1, 5) == 'INFO:' then
		local t = { node.info() };
		return s:send('NodeMCU:'..table.concat(t, '\t'))
	end
	if c:sub(1, 7) == 'FILE:S:' then
		local f = c:sub(8)
		if f then
			file.close()
			file.open(f, 'w+')
			s:send('FILE OPENED')
			print('OPENED')
		else
			s:send('File name not provided')
			print('OPEN ERROR')
		end
		return
	end
	if c:sub(1, 7) == 'FILE:E:' then
		file.close()
		return s:send('FILE CLOSED')
	end
	if c:sub(1, 7) == 'FILE:C:' then
		file.writeline(c:sub(8))
		return s:send('+')
	end

	for cmd, f in pairs(cmds) do
		if c:sub(1, cmd:len()) == cmd then
			return f(s, c)
		end
	end
end)

print('init ver:', ver)
print('listen on port 4000')
server:listen(4000)

for i = 1, 16 do 
	local f = loadfile('task_'..i..'.lua')
	if f then
		local t = f()
		if t and type(t) == 'function' then
			t(ctx)
		end
	else
		break
	end
end

