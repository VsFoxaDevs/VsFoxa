package options;

import objects.Note;
import objects.StrumNote;
import objects.Alphabet;

class VisualsUISubState extends BaseOptionsMenu
{
	var noteOptionID:Int = -1;
	var notes:FlxTypedGroup<StrumNote>;
	var notesTween:Array<FlxTween> = [];
	var noteY:Float = 90;
	public function new()
	{
		title = 'Visuals and UI';
		rpcTitle = 'Visuals & UI Settings Menu'; //for Discord Rich Presence

		// for note skins
		notes = new FlxTypedGroup<StrumNote>();
		for (i in 0...Note.colArray.length)
		{
			var note:StrumNote = new StrumNote(370 + (560 / Note.colArray.length) * i, -200, i, 0);
			note.centerOffsets();
			note.centerOrigin();
			note.playAnim('static');
			notes.add(note);
		}

		// options

		var noteSkins:Array<String> = Mods.mergeAllTextsNamed('images/noteSkins/list.txt');
		if(noteSkins.length > 0)
		{
			if(!noteSkins.contains(ClientPrefs.data.noteSkin))
				ClientPrefs.data.noteSkin = ClientPrefs.defaultData.noteSkin; //Reset to default if saved noteskin couldnt be found

			noteSkins.insert(0, ClientPrefs.defaultData.noteSkin); //Default skin always comes first
			var option:Option = new Option('Note Skins:',
				"Select your prefered Note skin.",
				'noteSkin',
				'string',
				noteSkins);
			addOption(option);
			option.onChange = onChangeNoteSkin;
			noteOptionID = optionsArray.length - 1;
		}
		
		var noteSplashes:Array<String> = Mods.mergeAllTextsNamed('images/noteSplashes/list.txt');
		if(noteSplashes.length > 0)
		{
			if(!noteSplashes.contains(ClientPrefs.data.splashSkin))
				ClientPrefs.data.splashSkin = ClientPrefs.defaultData.splashSkin; //Reset to default if saved splashskin couldnt be found

			noteSplashes.insert(0, ClientPrefs.defaultData.splashSkin); //Default skin always comes first
			var option:Option = new Option('Note Splashes:',
				"Select your prefered Note Splash variation or turn it off.",
				'splashSkin',
				'string',
				noteSplashes);
			addOption(option);
		}

		var option:Option = new Option('Note Splash Opacity',
			'How much transparent should the Note Splashes be.',
			'splashAlpha',
			'percent');
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('Botplay Sine Effect', 
		"If checked, the botplay text in-game does that one sine effect\nwhile the song is being played and when Botplay is on.", 
		'botplaySine', 
		'bool');
		addOption(option);

		var option:Option = new Option('Hide HUD',
			'If checked, hides most HUD elements.',
			'hideHud',
			'bool');
		addOption(option);

		var option:Option = new Option('Icon Colored Health Bar',
		"If unchecked, the health bar will have the colors from vanilla FNF\nrather than colors based on the icons.",
		'coloredHealthBar',
		'bool');
	    addOption(option);
		
		var option:Option = new Option('Time Bar:',
			"What should the Time Bar display?",
			'timeBarType',
			'string',
			['Time Left', 'Time Elapsed', 'Time Elapsed / Length', 'Song Name', 'Disabled']);
		addOption(option);

		var option:Option = new Option('Flashing Lights',
			"Uncheck this if you're sensitive to flashing lights!",
			'flashing',
			'bool');
		addOption(option);

		var option:Option = new Option('Enable Vignette', 
		"If checked, a vignette effect will appear and change depending on your health.", 
		'enableVignette',
		'bool');
	    addOption(option);
		
		var option:Option = new Option('Camera Zooms',
			"If unchecked, the camera won't zoom in on a beat hit.",
			'camZooms',
			'bool');
		addOption(option);

		var option:Option = new Option('In-Game Watermark',
			"If you want a watermark on the bottom left during a song,\ngo for it.",
			'showWatermark',
			'bool');
		addOption(option);

		var option:Option = new Option('Icon Watermark',
			"Uncheck this if you don't want to see that Vs.Foxa icon on the bottom right.\nThis isn't the in-game watermark you see during songs though.",
			'watermarkIcon',
			'bool');
		addOption(option);
		option.onChange = onWatermarkIcon;


		var option:Option = new Option('Score Text Zoom on Hit',
			"If unchecked, disables the Score text zooming\nevery time you hit a note.",
			'scoreZoom',
			'bool');
		addOption(option);

		var option:Option = new Option('Checkerboard Style',
			'If checked, gives most menus (if not all) a checkboard effect on top of the background.',
			'checkerBoard',
			'bool');
		addOption(option);

		var option:Option = new Option('Hide Score Text',
			'If checked, hides the info bar that is under the health bar in-game.',
			'hideScoreText',
			'bool');
		addOption(option);

		var option:Option = new Option('Health Bar Opacity',
			'How much transparent should the health bar and icons be?',
			'healthBarAlpha',
			'percent');
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('Display MS Offset Every Hit', 
		'If checked, the text with the note offset (in milliseconds) will appear near notes.',
		'showMsText', 'bool');
	    addOption(option);
		
		var option:Option = new Option('Lane Underlay Transparency', "Makes a lane show up based on your set transparency", 'laneUnderlay', 'percent');
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;

		#if !mobile
		var option:Option = new Option('FPS Counter',
			'If unchecked, hides FPS Counter.', 'showFPS', 'bool');
		addOption(option);
		option.onChange = onChangeFPSCounter;

		var option:Option = new Option('Total FPS Counter',
			'If checked, shows the Total FPS in the counter.', 'showTotalFPS', 'bool');
		addOption(option);

		var option:Option = new Option('Memory Counter',
			'If unchecked, hides the memory part of the FPS Counter.', 'memory', 'bool');
		addOption(option);

		var option:Option = new Option('Memory Peak Counter',
			'If checked, shows the maximum memory on the FPS Counter.', 'totalMemory', 'bool');
		addOption(option);

		var option:Option = new Option('Engine Version Counter',
			"If checked, shows the engine's version on the FPS Counter.", 'engineVersion', 'bool');
		addOption(option);

		#if debug
		var option:Option = new Option('Debug Info Counter',
			'If checked, shows debug info on the FPS Counter.', 'debugInfo', 'bool');
		addOption(option);
		#end

		var option:Option = new Option('Rainbow FPS',
			'If checked, gives the FPS counter a rainbow effect, like Kade Engine.', 'rainbowFPS', 'bool');
		addOption(option);

		var option:Option = new Option('Red Counter on Low FPS',
			'If checked, makes the counter red, whenever the FPS gets very low.', 'redText', 'bool');
		addOption(option);
		#end
		
		var option:Option = new Option('Pause Screen Song:',
			"What song do you prefer for the Pause Screen?",
			'pauseMusic',
			'string',
			['None', 'Breakfast', 'Ignited Grapes', 'Tea Time']);
		addOption(option);
		option.onChange = onChangePauseMusic;
		
		#if CHECK_FOR_UPDATES
		var option:Option = new Option('Check for Updates',
			'On official Psych builds, turn this on to check for updates when you start the game.',
			'checkForUpdates',
			'bool');
		addOption(option);
		#end

		#if desktop
		var option:Option = new Option('Discord Rich Presence',
			"Uncheck this to prevent accidental leaks, it will hide the Application from your \"Playing\" box on Discord",
			'discordRPC',
			'bool');
		addOption(option);
		#end

		var option:Option = new Option('Combo Stacking',
			"If unchecked, Ratings and Combo won't stack, saving on System Memory and making them easier to read",
			'comboStacking',
			'bool');
		addOption(option);

		super();
		add(notes);
	}

	override function changeSelection(change:Int = 0)
	{
		super.changeSelection(change);
		
		if(noteOptionID < 0) return;

		for (i in 0...Note.colArray.length)
		{
			var note:StrumNote = notes.members[i];
			if(notesTween[i] != null) notesTween[i].cancel();
			if(curSelected == noteOptionID)
				notesTween[i] = FlxTween.tween(note, {y: noteY}, Math.abs(note.y / (200 + noteY)) / 3, {ease: FlxEase.quadInOut});
			else
				notesTween[i] = FlxTween.tween(note, {y: -200}, Math.abs(note.y / (200 + noteY)) / 3, {ease: FlxEase.quadInOut});
		}
	}

	var changedMusic:Bool = false;
	function onChangePauseMusic()
	{
		if(ClientPrefs.data.pauseMusic == 'None')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)));

		changedMusic = true;
	}

	function onChangeNoteSkin()
	{
		notes.forEachAlive(function(note:StrumNote) {
			changeNoteSkin(note);
			note.centerOffsets();
			note.centerOrigin();
		});
	}

	function changeNoteSkin(note:StrumNote)
	{
		var skin:String = Note.defaultNoteSkin;
		var customSkin:String = skin + Note.getNoteSkinPostfix();
		if(Paths.fileExists('images/$customSkin.png', IMAGE)) skin = customSkin;

		note.texture = skin; //Load texture and anims
		note.reloadNote();
		note.playAnim('static');
	}

	override function destroy()
	{
		if(changedMusic && !OptionsState.onPlayState) FlxG.sound.playMusic(Paths.music('freakyMenu'), 1, true);
		super.destroy();
	}

	#if !mobile
	function onChangeFPSCounter()
	{
		if(Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.data.showFPS;
	}
	#end
}
