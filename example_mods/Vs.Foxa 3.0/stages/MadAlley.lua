local angleshit = 1;
local anglevar = 1;
function onCreate()
	makeAnimatedLuaSprite('bg','MadWall',-570.15, -285.45)
	setLuaSpriteScrollFactor('bg', 0.9, 0.9);
	addAnimationByPrefix('bg','MadWall','MadAlley Moving',24,true);
	addLuaSprite('bg',false)
	
	makeAnimatedLuaSprite('bgg','MadFloor',-570.15, -285.45)
	setLuaSpriteScrollFactor('bgg', 1, 0.95);
	addAnimationByPrefix('bgg','MadFloor','MadAlley Moving',24,true);
	addLuaSprite('bgg',false)

end
