
return function(ctx)
	gpio.mode(1, gpio.OUTPUT)
	ctx.auto_adc = ctx.auto_adc or true
	print('Start timer for reading adc and control gpio(1)')

	tmr.alarm(0, 1000, 1, function()
		if ctx.auto_adc then
			local v = adc.read(0)
			if v > 300 then
				gpio.write(1, gpio.LOW)
			else
				gpio.write(1, gpio.HIGH)
			end
		end
	end)
end
