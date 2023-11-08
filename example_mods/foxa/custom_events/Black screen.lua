-- Event notes hooks
function onEvent(name, value1, value2)
	if name == 'Black screen' then
        makeLuaSprite("black","blank_shit",0,0)
        setScrollFactor("black",0,0)
        setObjectCamera("black","hud")

        addLuaSprite("black",true)
	end
    if value1 == "off" then
        removeLuaSprite("black")
    end
end