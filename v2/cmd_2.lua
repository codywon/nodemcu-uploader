return {
	cmd = 'ADC',
	func = function(skt, c)
		local id = tonumber(c:sub(5))
		local v = adc.read(0)
		skt:send('ADC:'..v)
	end
}
