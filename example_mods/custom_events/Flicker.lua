function onCreate() -- Add The Flicker

	makeAnimatedLuaSprite('BendyFlicker', 'BendyFlicker', -90, -50)
	
	-- Properties
	setScrollFactor('BendyFlicker', 0, 0)
	scaleObject('BendyFlicker', 1.5, 1.5)
	
	-- Animations
	addAnimationByPrefix('BendyFlicker', 'flick', 'flicker', 24, false)
	
end

function onEvent(name, value1, value2)
	if name == 'Flicker' then
--	runTimer('flicked', 1.5, 1)
	addLuaSprite('BendyFlicker', true)
	objectPlayAnimation('flick', true)
	end
end
	
function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'flicked' then
	setProperty('BendyFlicker.visible', false)
	end
end