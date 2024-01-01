function onCreate()
	makeLuaSprite('act-2','act-2',-550,-300)
	addLuaSprite('act-2',false)
	makeLuaSprite('wallbg edgy','wallbg edgy',-550,-300)
	addLuaSprite('wallbg edgy',false)
	setProperty('wallbg edgy.visible', false)
	makeLuaSprite('light','light',450,0)
	addLuaSprite('light',false)
	setProperty('light.alpha', 0.5)
end

function onEvent(name,value1,value2)
	if name == 'Play Animation' then 
		if value1 == '2' then
			setProperty('wallbg edgy.visible', true);
			setProperty('light.visible', false)
			setProperty('wallbg.visible', false);
		end
		if value1 == '1' then
			setProperty('wallbg edgy.visible', false);
			setProperty('light.visible', true);
			setProperty('wallbg.visible', true);
		end
	end
end