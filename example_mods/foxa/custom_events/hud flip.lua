function onEvent(name)
	if name == "hud flip" then
		doTweenAngle('turn1', 'camHUD', 180, 0.1, 'linear')
	end
end
