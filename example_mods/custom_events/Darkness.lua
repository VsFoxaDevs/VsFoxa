function onCreatePost()
	makeLuaSprite('black', '', 0, 0)
	setScrollFactor('black', 0, 0)
	makeGraphic('black', 3840, 2160, '000000')
	addLuaSprite('black', false)
	setProperty('black.alpha', 0)
	screenCenter('black', 'xy')
end
function onEvent(n, v1, v2)
	if n == 'Darkness' and string.lower(v1) == 'true' then
		doTweenAlpha('blackbg', 'black', 1, v2, 'linear')
		doTweenColor('blackbgg', 'bgg', '000000', v2, 'linear')
		doTweenColor('blackbf', 'boyfriend', '000000', v2, 'linear')
		doTweenColor('blackdad', 'dad', '000000', v2, 'linear')
		doTweenColor('blackgf', 'gf', '000000', v2, 'linear')
		doTweenAlpha('blackhp', 'healthBar', 0, v2, 'linear')
		doTweenColor('blackpl', 'iconP1', '000000', v2, 'linear')
		doTweenColor('black', 'iconP2', '000000', v2, 'linear')
	end
	if n == 'Darkness' and string.lower(v1) == 'false' then
		doTweenAlpha('blackbg', 'black', 0, v2, 'linear')
		doTweenColor('blackbgg', 'bgg', 'FFFFFF', v2, 'linear')
		doTweenColor('blackbf', 'boyfriend', 'FFFFFF', v2, 'linear')
		doTweenColor('blackdad', 'dad', 'FFFFFF', v2, 'linear')
		doTweenColor('blackgf', 'gf', 'FFFFFF', v2, 'linear')
		doTweenAlpha('blackhp', 'healthBar', 1, v2, 'linear')
		doTweenColor('blackpl', 'iconP1', 'FFFFFF', v2, 'linear')
		doTweenColor('black', 'iconP2', 'FFFFFF', v2, 'linear')
	end
end