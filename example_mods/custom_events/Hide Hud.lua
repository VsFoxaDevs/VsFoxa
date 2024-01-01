function onEvent(name,value1,value2)
	if name == 'Hide Hud' then 

		if value1 == '1' then
			setProperty('camHUD.visible', false)
		end

		if value1 == '2' then
			setProperty('camHUD.visible', true)
		end
	end
end
			