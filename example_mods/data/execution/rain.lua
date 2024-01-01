function onCreate()
	makeAnimatedLuaSprite('rain', 'rain', 0, 9);
	setLuaSpriteScrollFactor('rain', 0.0, 0.0);
	scaleObject('rain', 0.85, 0.73);

	makeAnimatedLuaSprite('splash', 'splash', 0, 50);

	addLuaSprite('splash', false);
	addAnimationByPrefix('splash', 'loop', 'splash loop', 15, true);
	addLuaSprite('rain', true);
	addAnimationByPrefix('rain', 'loop', 'rain loop', 15, true);
end