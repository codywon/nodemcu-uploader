
return function(ctx)
	gpio.mode(1, gpio.OUTPUT)
	ctx.auto_plant = ctx.auto_plant or true
	ctx.plant = ctx.plant or { size = 50, pot_size = 50 }
	local ctrl = {
		calc = loadfile('plant.lua'),
		pump_on = function(self, sec)
			sec = sec or 5
			self.pump_close = os.time() + sec
			-- Open the pump
			gpio.write(1, gpio.HIGH)
		end,
		pump_off = function(self)
			gpio.write(1, gpio.LOW)
			pump_close = os.time() + 3600
		end,
		pump_close = os.time(),
	}
	if not ctrl.calc then print('Loading plant.lua failed') end
	print('Start timer for PLANT')

	tmr.alarm(0, 1000, 1, function()
		local now = os.time()
		if now >= ctrl.pump_close then
			ctrl:pump_off()
		end

		if ctx.auto_plant and ctx.calc then
			local soil_humi = adc.read(0)
			local air_humi = 40 
			local air_temp = 20
			-- TODO: air_humi(%) air_temp(.C)
			ctrl:calc(ctx.plant, {soil_humi=soil_humi, air_humi=air_humi, air_temp=air_temp})
		end
	end)
end
