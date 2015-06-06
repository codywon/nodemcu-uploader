
return function(ctrl, plant, env)
	-- env.air_humi env.air_temp
	if env.soil_humi > 300 then
		ctrl:pump_off()
	end
	if env.soil_humi < 200 then
		ctrl:pump_on(5)
	end
end
