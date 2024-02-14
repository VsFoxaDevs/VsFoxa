package states;

import lime.app.Promise;
import lime.app.Future;

import flixel.FlxState;

import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;

import backend.StageData;

import haxe.io.Path;

class LoadingState extends MusicBeatState
{
	inline static var MIN_TIME = 1.0;

	// TO DO: Make this easier, and uhhh fix the load screen so the game doesn't softlock at the end of the point
	
	var target:FlxState;
	public static var globeTrans:Bool = true;
	var stopMusic = false;
	var directory:String;
	var callbacks:MultiCallback;
	var targetShit:Float = 0;

	var tipTxt:FlxText;
	var tips:Array<String> = [
		"Don't spam, it won't work.",
		"psych engine port\nfatherless behavior",
		"why am i wasting my\ntime making this mod",
		"Dave and Bambi came out in September of 2021-\nWait no, I have been misinformed, shit.",
		"Null Object Reference",
		"This isn't a kids game.",
		"I wonder what ethanol tastes like.",
		"Remember, licking doorknobs is illegal on other planets.",
		"Psych Engine if it was cooler.",
		"No tip here.",
		"I miss FNF's peak.",
		"Foxa is not a furry!",
		"When is there gonna be a Foxa page in Funkipedia?",
		"ALT + Enter for free Week 8 /j",
		"Funk all the way.",
		"WhY aRe YoU jUsT rEpEaTiNg WhAt Im SaYiNg",
		"Friday Night Funkin'\nMic'd Up.",
		"before psych engine there was kade engine\nthose were the days",
		"You're currently playing Vs. Foxa.",
		"Do people actually read these?",
		"Skill issue.",
		"Cock joke.",
		"WHAT",
		"As long as there's 2 people left on the planet,\nsomeone is gonna want someone dead.",
		"His name isn't Keith.",
		"THERES HSCRIPT HERE WHAT?!?!?",
		"THERE AREN'T COUGARS IN MISSIONS",
		"Disingenuous dense motherfucker.",
		"My father is dying.\nPlease stop beatboxing.",
		"pico funny\nbig ol' bunny",
		"Joe mama",
		"Gettin freaky' on a friday night yeah",
		"This may be based off on a Psych fork,\nbut this is VS.FOXA, damn it.",
		"Worjdjhewndjaiqkkwbdjkwqodbdjwoen&:’eked&3rd!2’wonenksiwnwihqbdibejwjebdjjejwjenfjdjejejjwkwiwjnensjsiieejjsjskikdjdnnwjwiwjejdjdjwiejdbdiwjdhehhrifjdnwoqnd",
		"Oo0ooOoOOo000OOO!!!",
		"Witness the might\nof the seas!",
		"KadeDev is best.\nBut his own engine sucks though.",
		"CARAMEL ARROW SUPREMACY",
		"No, you are not getting 3.5. Get over it.",
		"I will rip your intestines out.",
		"flippity floppity",
		"i'm surprised people might actually\nbe reading this at this point",
		"potato\nwaterslide",
		"GingerBrave\nMore like",
		"Foxa hates Twilight Sparkle :D",
		"I just wanna warn you, we're always fashionably early.",
		"Please stand by.",
		"I love to smash my keyboard.",
		"Is Week 8 gonna come out anytime soon?",
		"FIRE IN THE HOLE",
		"There might be someone out there that's thinking about making a mod about you.\nKeep that in mind.",
		"Funkin' Forever.",
		"i hope you go mooseing\nand get fucked by a campfire",
		"Let her cook, damnit.",
		"WENT BACK TO FREEPLAY??",
		"Ugh",
		"Bop beep be be skdoo bep"
	];

	function new(target:FlxState, stopMusic:Bool, directory:String)
	{
		super();
		this.target = target;
		this.stopMusic = stopMusic;
		this.directory = directory;
	}

	var funkay:FlxSprite;
	var loadBar:FlxSprite;
	override function create()
	{
		flixel.addons.transition.FlxTransitionableState.skipNextTransIn = false;
		flixel.addons.transition.FlxTransitionableState.skipNextTransOut = false;
		if(!globeTrans){
			flixel.addons.transition.FlxTransitionableState.skipNextTransIn = true;
			flixel.addons.transition.FlxTransitionableState.skipNextTransOut = true;
		}
		globeTrans = true;

		var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xffcaff4d);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33525252, 0x0));
		grid.velocity.set(40, 40);
		grid.alpha = 0;
		FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(grid);
		
		funkay = new FlxSprite(0, 0).loadGraphic(Paths.getPath('images/funkay.png', IMAGE));
		funkay.setGraphicSize(0, FlxG.height);
		funkay.updateHitbox();
		add(funkay);
		funkay.antialiasing = ClientPrefs.data.antialiasing;
		funkay.scrollFactor.set();
		funkay.screenCenter();

		var bottomPanel:FlxSprite = new FlxSprite(0, FlxG.height - 100).makeGraphic(FlxG.width, 100, 0xFF000000);
		bottomPanel.alpha = 0.5;
		add(bottomPanel);

		loadBar = new FlxSprite(10, 0).makeGraphic(FlxG.width, 10, 0xffff16d2);
		loadBar.screenCenter(X);
		loadBar.active = false;
		add(loadBar);

		tipTxt = new FlxText(0, FlxG.height - 80, 1000, "", 26);
		tipTxt.scrollFactor.set();
		tipTxt.setFormat(Paths.font("vcr.ttf"), 26, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipTxt.screenCenter(X);
		add(tipTxt);

		tipTxt.text = tips[FlxG.random.int(0, tips.length - 1)];
		
		initSongsManifest().onComplete
		(
			function (lib)
			{
				callbacks = new MultiCallback(onLoad);
				var introComplete = callbacks.add("introComplete");
				/*if(PlayState.SONG != null) {
					checkLoadSong(getSongPath());
					if(PlayState.SONG.needsVoices)
						checkLoadSong(getVocalPath());
				}*/
				if(directory != null && directory.length > 0 && directory != 'shared'){
					checkLibrary('week_assets');
				}

				var fadeTime = 0.5;
				FlxG.camera.fade(FlxG.camera.bgColor, fadeTime, true);
				new FlxTimer().start(fadeTime + MIN_TIME, function(_) introComplete());
			}
		);
	}
	
	function checkLoadSong(path:String)
	{
		if(!Assets.cache.hasSound(path)){
			var library = Assets.getLibrary("songs");
			final symbolPath = path.split(":").pop();
			// @:privateAccess
			// library.types.set(symbolPath, SOUND);
			// @:privateAccess
			// library.pathGroups.set(symbolPath, [library.__cacheBreak(symbolPath)]);
			var callback = callbacks.add("song:" + path);
			Assets.loadSound(path).onComplete(function (_) { callback(); });
		}
	}
	
	function checkLibrary(library:String) {
		trace(Assets.hasLibrary(library));
		if (Assets.getLibrary(library) == null)
		{
			@:privateAccess
			if (!LimeAssets.libraryPaths.exists(library))
				throw new haxe.Exception("Missing library: " + library);

			var callback = callbacks.add("library:" + library);
			Assets.loadLibrary(library).onComplete(function (_) { callback(); });
		}
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		funkay.setGraphicSize(Std.int(0.88 * FlxG.width + 0.9 * (funkay.width - 0.88 * FlxG.width)));
		funkay.updateHitbox();
		if(controls.ACCEPT)
		{
			funkay.setGraphicSize(Std.int(funkay.width + 60));
			funkay.updateHitbox();
		}

		if(callbacks != null) {
			targetShit = FlxMath.remapToRange(callbacks.numRemaining / callbacks.length, 1, 0, 0, 1);
			loadBar.scale.x += 0.5 * (targetShit - loadBar.scale.x);
		}
	}
	
	function onLoad()
	{
		if(stopMusic && FlxG.sound.music != null) FlxG.sound.music.stop();
		
		MusicBeatState.switchState(target);
	}
	
	static function getSongPath() return Paths.inst(PlayState.SONG.song);
	
	static function getVocalPath() return Paths.voices(PlayState.SONG.song);
	
	inline static public function loadAndSwitchState(target:FlxState, stopMusic = false)
	{
		MusicBeatState.switchState(getNextState(target, stopMusic));
	}
	
	function getLoadTextShit():Array<Array<String>>
	{
		#if MODS_ALLOWED 
		var tabArray:Array<String> = Mods.mergeAllTextsNamed('data/preloaderText.txt', Paths.getSharedPath());
		#else
		var imFunniText:String = Assets.getText(Paths.txt('preloaderText'));
		var tabArray:Array<String> = imFunniText.split('\n');
		#end
		var arrayMan:Array<Array<String>> = [];

		for(i in tabArray) arrayMan.push(i.split('--'));
		return arrayMan;
	}

	static function getNextState(target:FlxState, stopMusic = false):FlxState
	{
		var directory:String = 'shared';
		var weekDir:String = StageData.forceNextDirectory;
		StageData.forceNextDirectory = null;

		if(weekDir != null && weekDir.length > 0 && weekDir != '') directory = weekDir;

		Paths.setCurrentLevel(directory);
		trace('Setting asset folder to ' + directory);

		#if LOADING_SCREEN
		var loaded:Bool = false;
		if (PlayState.SONG != null) {
			loaded = isSoundLoaded(getSongPath()) && (!PlayState.SONG.needsVoices || isSoundLoaded(getVocalPath())) && isLibraryLoaded('week_assets');
		}
		
		if(!loaded) return new LoadingState(target, stopMusic, directory);
		#end
		if(stopMusic && FlxG.sound.music != null) FlxG.sound.music.stop();
		
		return target;
	}

	#if LOADING_SCREEN
	static function isSoundLoaded(path:String):Bool
	{
		trace(path);
		return Assets.cache.hasSound(path);
	}
	
	static function isLibraryLoaded(library:String):Bool
	{
		return Assets.getLibrary(library) != null;
	}
	#end
	
	override function destroy()
	{
		super.destroy();
		
		callbacks = null;
	}
	
	static function initSongsManifest()
	{
		var id = "songs";
		var promise = new Promise<AssetLibrary>();

		var library = LimeAssets.getLibrary(id);

		if(library != null) return Future.withValue(library);

		var path = id;
		var rootPath = null;

		@:privateAccess
		var libraryPaths = LimeAssets.libraryPaths;
		if(libraryPaths.exists(id)){
			path = libraryPaths[id];
			rootPath = Path.directory(path);
		}else{
			if(StringTools.endsWith(path, ".bundle")){
				rootPath = path;
				path += "/library.json";
			}else{
				rootPath = Path.directory(path);
			}
			@:privateAccess
			path = LimeAssets.__cacheBreak(path);
		}

		AssetManifest.loadFromFile(path, rootPath).onComplete(function(manifest)
		{
			if(manifest == null){
				promise.error("Cannot parse asset manifest for library \"" + id + "\"");
				return;
			}

			var library = AssetLibrary.fromManifest(manifest);

			if(library == null) promise.error("Cannot open library \"" + id + "\"");
			else{
				@:privateAccess
				LimeAssets.libraries.set(id, library);
				library.onChange.add(LimeAssets.onChange.dispatch);
				promise.completeWith(Future.withValue(library));
			}
		}).onError(function(_)
		{
			promise.error("There is no asset library with an ID of \"" + id + "\"");
		});

		return promise.future;
	}
}

class MultiCallback
{
	public var callback:Void->Void;
	public var logId:String = null;
	public var length(default, null) = 0;
	public var numRemaining(default, null) = 0;
	
	var unfired = new Map<String, Void->Void>();
	var fired = new Array<String>();
	
	public function new (callback:Void->Void, logId:String = null)
	{
		this.callback = callback;
		this.logId = logId;
	}
	
	public function add(id = "untitled")
	{
		id = '$length:$id';
		length++;
		numRemaining++;
		var func:Void->Void = null;
		func = function ()
		{
			if(unfired.exists(id)){
				unfired.remove(id);
				fired.push(id);
				numRemaining--;
				
				if(logId != null) log('fired $id, $numRemaining remaining');
				
				if(numRemaining == 0){
					if(logId != null) log('all callbacks fired');
					callback();
				}
			}
			else log('already fired $id');
		}
		unfired[id] = func;
		return func;
	}
	
	inline function log(msg):Void
	{
		if(logId != null) trace('$logId: $msg');
	}
	
	public function getFired() return fired.copy();
	public function getUnfired() return [for (id in unfired.keys()) id];
}
