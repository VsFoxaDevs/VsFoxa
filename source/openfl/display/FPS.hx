package openfl.display;

import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.math.FlxMath;
#if flash
import openfl.Lib;
#end
#if openfl
import openfl.system.System;
#end
import haxe.Int64;
import openfl.display.BlendMode;
#if (gl_stats && !disable_cffi && (!html5 || !canvas))
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
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

	public var borderSize:Int = 1;

	// border code by @raltyro and @sayofthelor, taken from psike engine mcuz i 
	@:noCompletion private final borders:Array<TextField> = new Array<TextField>();

	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;
	
	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000) {
		super();

		var border:TextField;
		for (i in 0...8) {
			borders.push(border = new TextField());
			border.selectable = false;
			border.mouseEnabled = false;
			border.autoSize = LEFT;
			border.multiline = true;
			border.width = 800;
			border.height = 70;
		}

		this.x = x;
		this.y = y;
		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat(Paths.font("vcr.ttf"), 14, color);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";
		width = 800;
		height = 70;

		currentTime = 0;
		times = [];
		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
		addEventListener(Event.REMOVED, function(_) {
			for (border in borders) this.parent.removeChild(border);
		});
		addEventListener(Event.ADDED, function(_) {
			for (border in borders) this.parent.addChildAt(border, this.parent.getChildIndex(this));
		});
	}

	@:noCompletion override function set_visible(value:Bool):Bool {
		for (border in borders) border.visible = value;
		return super.set_visible(value);
	}

	@:noCompletion override function set_defaultTextFormat(value:TextFormat):TextFormat {
		for (border in borders) {
			border.defaultTextFormat = value;
			border.textColor = 0xFF000000;
		}
		return super.set_defaultTextFormat(value);
	}

	@:noCompletion override function set_x(x:Float):Float {
		for (i in 0...8) borders[i].x = x + ([0, 3, 5].contains(i) ? borderSize : [2, 4, 7].contains(i) ? -borderSize : 0);
		return super.set_x(x);
	}

	@:noCompletion override function set_y(y:Float):Float {
		for (i in 0...8) borders[i].y = y + ([0, 1, 2].contains(i) ? borderSize : [5, 6, 7].contains(i) ? -borderSize : 0);
		return super.set_y(y);
	}

	@:noCompletion override function set_text(text:String):String {
		for (border in borders) border.text = text;
		return super.set_text(text);
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
			text = '[FPS] ${currentFPS}\n';

			#if openfl
			memoryMegas = cast(System.totalMemory, UInt);

			text += '[MEM] ${flixel.util.FlxStringUtil.formatBytes(memoryMegas)}';
			#end

			text += '\nAlleyway Engine v0.2 (PE 0.7.3)'; 
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


