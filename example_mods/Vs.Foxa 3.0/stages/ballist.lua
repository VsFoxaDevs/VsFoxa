local angleshit = 1;
local anglevar = 1;
function onCreate()
	makeAnimatedLuaSprite('bg','Execution BG',0,0)
	setLuaSpriteScrollFactor('bg', 0.9, 0.9);
	addAnimationByPrefix('bg','Execution BG','Execution BG Moving',12,true);
	addLuaSprite('bg',false)
	setGraphicSize('bg','Execution BG', 0.9, 0.9)
	
	makeAnimatedLuaSprite('bgg','BallisticFloor',-570.15, -285.45)
	setLuaSpriteScrollFactor('bgg', 1, 0.95);
	addAnimationByPrefix('bgg','BallisticFloor','Background Whitty Moving',24,true);
	addLuaSprite('bgg',false)

	makeAnimatedLuaSprite('bgg','FIRE',3.15, 50.45)
	setLuaSpriteScrollFactor('bgg', 0.0, 0.0);
	addAnimationByPrefix('bgg','FIRE','FIRE',15,true);
	addLuaSprite('bgg',true)
	setGraphicSize('bgg','FIRE', 0.5, 0.5)

end