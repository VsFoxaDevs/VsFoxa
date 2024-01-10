package openfl.display;

import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.math.FlxMath;
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
#if flash
import openfl.Lib;
#end
#if openfl
import openfl.system.System;
#end
/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class FPS extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	/**
		The current memory usage.
	**/
	public var memoryMegas:Float = 0;
	public var memoryTotal:Float = 0;

	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;
	
	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000) {
		super();
		this.x = x;
		this.y = y;
		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat(Paths.font("vcr.ttf"), 14, color);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		currentTime = 0;
		times = [];
		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
	}

	var deltaTimeout:Float = 0.0;

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		// prevents the overlay from updating every frame, why would you need to anyways
		if (deltaTimeout > 1000) {
			deltaTimeout = 0.0;
			return;
		}

		var now:Float = haxe.Timer.stamp();
		final now:Float = haxe.Timer.stamp() * 1000;
		times.push(now);
		while (times[0] < now - 1000)
			times.shift();
		while (times[0] < now - 1000) times.shift();

		currentFPS = currentFPS < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;		
		currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;		

		if(currentFPS > ClientPrefs.data.framerate) currentFPS = ClientPrefs.data.framerate;

		updateText();
		deltaTimeout += deltaTime;
	}

	private dynamic function updateText():Void
		{
			text = 'FPS: ${currentFPS}\n';

			#if openfl
			memoryMegas = cast(System.totalMemory, UInt);
			/*if(memoryMegas > memoryTotal) memoryTotal = memoryMegas;

			text += "RAM: " + memoryMegas + " MB / " + memoryTotal + " MB";*/
			text += 'Memory: ${flixel.util.FlxStringUtil.formatBytes(memoryMegas)}';
			#end

			text += '\nAlleyway Engine (Psych 0.7.3)'; 
			#if STORY_EDITION
			text += '\nFNF Vs. Foxa 3.0: Story Edition';
			#else
			text += '\nFNF Vs. Foxa 3.0';
			#end

			if (text != null || text != '') {if(Main.fpsVar != null) Main.fpsVar.visible = true;}

			textColor = 0xFFFFFFFF;
			if(currentFPS <= ClientPrefs.data.framerate / 2) textColor = 0xFFFF0000;

			#if (gl_stats && !disable_cffi && (!html5 || !canvas))
			text += "\ntotalDC: " + Context3DStats.totalDrawCalls();
			text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
			text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
			#end
			text += "\n";
		}
}
