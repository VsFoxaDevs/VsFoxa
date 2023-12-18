package objects;

class MenuItem extends FlxSprite
{
	public var targetY:Float = 0;
	//public var flashingInt:Int = 0;

	public function new(x:Float, y:Float, weekName:String = '')
	{
		super(x, y);
		loadGraphic(Paths.image('storymenu/' + weekName));
		antialiasing = ClientPrefs.data.antialiasing;
		//trace('Test added: ' + WeekData.getWeekNumber(weekNum) + ' (' + weekNum + ')');
	}

	public var isFlashing(default, set):Bool = false;
	private var _flashingElapsed:Float = 0;
	final _flashColor = 0xFF33FFFF;
	final flashes_ps:Int = 6;

	public function set_isFlashing(value:Bool = true):Bool
	{
		isFlashing = value;
		_flashingElapsed = 0;
		color = (isFlashing) ? _flashColor : FlxColor.WHITE;
		return isFlashing;
	}
	
	/* 
	if it runs at 60fps, fake framerate will be 6
	if it runs at 144 fps, fake framerate will be like 14, and will update the graphic every 0.016666 * 3 seconds still???
	so it runs basically every so many seconds, not dependant on framerate??
	I'm still learning how math works thanks whoever is reading this lol
	*/
	
	//var fakeFramerate:Int = Math.round((1 / FlxG.elapsed) / 10);

	override function update(elapsed:Float)
		{
			super.update(elapsed);
	
			y = FlxMath.lerp(y, (targetY * 120) + 480, FlxMath.bound(elapsed * 10.2, 0, 1));
			if (isFlashing)
			{
				_flashingElapsed += elapsed;
				color = (Math.floor(_flashingElapsed * FlxG.updateFramerate * flashes_ps) % 2 == 0) ? _flashColor : FlxColor.WHITE;
			}
		}
	}