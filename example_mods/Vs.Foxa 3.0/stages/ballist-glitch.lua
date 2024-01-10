local angleshit = 1;
local anglevar = 1;
function onCreate()
	makeAnimatedLuaSprite('bg','Execution BG-glitch',0,0)
	setLuaSpriteScrollFactor('bg', 0.9, 0.9);
	addAnimationByPrefix('bg','Execution BG-glitch','Execution BG Moving',12,true);
	addLuaSprite('bg',false)
	setGraphicSize('bg','Execution BG-glitch', 0.9, 0.9)
	
	makeAnimatedLuaSprite('bgg','BallisticFloor',-570.15, -285.45)
	setLuaSpriteScrollFactor('bgg', 1, 0.95);
	addAnimationByPrefix('bgg','BallisticFloor','Background Whitty Moving',24,true);
	addLuaSprite('bgg',false)

	makeLuaSprite('bgg','funni-effect',-410.15, -295.45)
	setLuaSpriteScrollFactor('bgg', 0.9, 0.9);
	addLuaSprite('bgg',true)

	makeAnimatedLuaSprite('bgg','FIRE-glitch',3.15, 50.45)
	setLuaSpriteScrollFactor('bgg', 0.0, 0.0);
	addAnimationByPrefix('bgg','FIRE','FIRE',15,true);
	addLuaSprite('bgg',true)
	setGraphicSize('bgg','FIRE-glitch', 0.5, 0.5)

end
