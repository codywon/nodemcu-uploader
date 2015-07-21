return {
	cmd = 'GPIO',
	func = function(skt, c)
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
	--			gpio.mode(i, gpio.INPUT)
				r = gpio.read(i) or 'UNKONWN STATE'
			end
		elseif op == 'a' then
			local t = {}
			for i = 1, 12 do
				t[i] = gpio.read(i)
			end
			r = table.concat(t, ':')
		end
		r = r or 'UNKNOWN:'..data

		skt:send('GPIO:'..data..':'..r)
	end
}
