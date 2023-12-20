package;

#if android
import android.content.Context;
#end
import flixel.graphics.FlxGraphic;
import flixel.FlxGame;
import flixel.FlxState;
import haxe.io.Path;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import lime.app.Application;
import states.TitleState;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import lime.app.Application;

#if linux
import lime.graphics.Image;
#end

//crash handler stuff
#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
#end

#if linux
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('
	#define GAMEMODE_AUTO
')
#end

class Main extends Sprite
{
	var game = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		zoom: -1.0, // game state bounds
		framerate: 60, // default framerate
		skipSplash: true, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};

	public static var fpsVar:FPS;

	public static var initialState:Class<FlxState> = TitleState; // so the fps can get the state properly :)

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		// Credits to MAJigsaw77 (he's the og author for this code)
		// just for easy porting y'know, but still just get a pc damnit
		#if android
		Sys.setCwd(Path.addTrailingSlash(Context.getExternalFilesDir()));
		#elseif ios
		Sys.setCwd(lime.system.System.applicationStorageDirectory);
		#end

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();

		var timer = new haxe.Timer(1);
		timer.run = function()
		{
			coloring();
			if (fpsVar.textColor == 0) fpsVar.textColor = -4775566;
		} // needs to be done because textcolor beco
	}

	private function setupGame():Void
	{
		final stageWidth:Int = Lib.current.stage.stageWidth;
		final stageHeight:Int = Lib.current.stage.stageHeight;

		if (game.zoom == -1.0)
		{
			final ratioX:Float = stageWidth / game.width;
			final ratioY:Float = stageHeight / game.height;
			game.zoom = Math.min(ratioX, ratioY);
			game.width = Math.ceil(stageWidth / game.zoom);
			game.height = Math.ceil(stageHeight / game.zoom);
		}
	
		#if LUA_ALLOWED Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(psychlua.CallbackHandler.call)); #end
		Controls.instance = new Controls();
		ClientPrefs.loadDefaultKeys();
		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end
		#if windows CppAPI.darkMode(); #end
		addChild(new FlxGame(game.width, game.height, initialState, #if (flixel < "5.0.0") game.zoom, #end game.framerate, game.framerate, game.skipSplash, game.startFullscreen));

		#if !mobile
		fpsVar = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		if(fpsVar != null)
			fpsVar.visible = ClientPrefs.data.showFPS;
		#end

		#if linux
		var icon = Image.fromFile("icon.png");
		Lib.current.stage.window.setIcon(icon);
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end
		
		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end

		#if desktop
		DiscordClient.start();
		#end

		// shader coords fix
		FlxG.signals.gameResized.add(function (w, h) {
		     if (FlxG.cameras != null) {
			   for (cam in FlxG.cameras.list) {
				@:privateAccess
				if (cam != null && cam._filters != null)
					resetSpriteCache(cam.flashSprite);
			   }
		     }

		     if (FlxG.game != null)
			 resetSpriteCache(FlxG.game);
		});
	}

	// Chroma Effect (12 Colors)
	var array:Array<FlxColor> = [
		FlxColor.fromRGB(216, 34, 83),
		FlxColor.fromRGB(255, 38, 0),
		FlxColor.fromRGB(255, 80, 0),
		FlxColor.fromRGB(255, 147, 0),
		FlxColor.fromRGB(255, 199, 0),
		FlxColor.fromRGB(255, 255, 0),
		FlxColor.fromRGB(202, 255, 0),
		FlxColor.fromRGB(0, 255, 0),
		FlxColor.fromRGB(0, 146, 146),
		FlxColor.fromRGB(0, 0, 255),
		FlxColor.fromRGB(82, 40, 204),
		FlxColor.fromRGB(150, 33, 146)
	];
	var skippedFrames = 0;
	var currentColor = 0;

	// Event Handlers
	public function coloring():Void
	{
		// Hippity, Hoppity, your code is now my property (from KadeEngine)
		if (ClientPrefs.data.fpsRainbow)
		{
			if (currentColor >= array.length) currentColor = 0;
			currentColor = Math.round(FlxMath.lerp(0, array.length, skippedFrames / ClientPrefs.data.framerate));
			(cast(Lib.current.getChildAt(0), Main)).changeFPSColor(array[currentColor]);
			currentColor++;
			skippedFrames++;
			if (skippedFrames > ClientPrefs.data.framerate)
				skippedFrames = 0;
		}
		else
			fpsVar.textColor = FlxColor.fromRGB(255, 255, 255);
	}

	public function changeFPSColor(color:FlxColor)
	{
		fpsVar.textColor = color;
	}

		
	static function resetSpriteCache(sprite:Sprite):Void {
		@:privateAccess {
		        sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}

	static final quotes:Array<String> = [
		//"Blueballed. - gedehari",
		"bruh lmfao - CharlesCatYT",
		"We have come for your errors- GET THE FUCK OUT OF MY CODE - CharlesCatYT",
		"i hope you go mooseing and get fucked by a campfire - cyborg henry stickmin",
		"Goodbye cruel world - ShadowMario",
		"old was better - TheAnimateMan",
		"what the actual fuck - cyborg henry stickmin",
		"L - Dark",
		"fix your grammer - SLB7",
		"fuck why is it down - SLB7",
		"You did something, didn't you? - LightyStarOfficial",
		"HA! - Dark",
		"j- NOOO - Vencerist",
		"I did but error oof - Vencerist",
		"Ah bueno adios master - ShadowMario",
		"Skibidy bah mmm dada *explodes* - ShadowMario",
		"What have you done, you killed it! - crowplexus",
		"Have you checked if the variable exists? - crowplexus",
		"Have you even read the wiki before trying that? - crowplexus"
	];

	// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	// very cool person for real they don't get enough credit for their work
	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "VsFoxa_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error + "\nPlease report this error to the GitHub page: https://github.com/TheBeepSheepTeam/VsFoxa\n\n> Crash Handler written by: sqirra-rng";

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "Error!");
		DiscordClient.shutdown();
		Sys.exit(1);
	}
	#end
}
