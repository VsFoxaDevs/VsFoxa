package states.editors;

import backend.WeekData;

import objects.Character;

import states.MainMenuState;
import states.FreeplayState;

class MasterEditorMenu extends MusicBeatState {
	var options:Array<String> = [
		'Chart Editor',
		'Character Editor',
		'Week Editor',
		'Menu Character Editor',
		'Dialogue Editor',
		'Dialogue Portrait Editor',
		'Credits Editor',
		'Note Splash Editor'//,
		//'Stage Editor'
	];
	private var grpTexts:FlxTypedGroup<Alphabet>;
	private var directories:Array<String> = [null];

	private var curSelected = 0;
	private var curDirectory = 0;
	private var directoryTxt:FlxText;

	//private var s_editor:StageEditorState = new StageEditorState();

	override function create(){
		FlxG.camera.bgColor = FlxColor.BLACK;
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Editors Main Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set();
		bg.color = 0xFF353535;
		add(bg);

		if (ClientPrefs.data.checkerBoard)
		{
			var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
			grid.velocity.set(40, 40);
			grid.alpha = 0;
			FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
			add(grid);
		}	

		grpTexts = new FlxTypedGroup<Alphabet>();
		add(grpTexts);

		for (i in 0...options.length) {
			var leText:Alphabet = new Alphabet(90, 320, options[i], true);
			leText.itemType = 'Vertical'; //makes it a lil' cooler ig
			leText.isMenuItem = true;
			leText.targetY = i;
			grpTexts.add(leText);
			leText.snapToPosition();
		}
		
		#if MODS_ALLOWED
		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 42).makeGraphic(FlxG.width, 42, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		directoryTxt = new FlxText(textBG.x, textBG.y + 4, FlxG.width, '', 32);
		directoryTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		directoryTxt.scrollFactor.set();
		add(directoryTxt);
		
		for (folder in Mods.getModDirectories()) directories.push(folder);

		var found:Int = directories.indexOf(Mods.currentModDirectory);
		if(found > -1) curDirectory = found;
		changeDirectory();
		#end
		changeSelection();

		FlxG.mouse.visible = false;
		super.create();
	}

	override function update(elapsed:Float) {
		if (controls.UI_UP_P) changeSelection(-1);
		if (controls.UI_DOWN_P) changeSelection(1);
		#if MODS_ALLOWED
		if(controls.UI_LEFT_P) changeDirectory(-1);
		if(controls.UI_RIGHT_P) changeDirectory(1);
		#end
		if(controls.BACK) FlxG.switchState(() -> new MainMenuState());
		if(controls.ACCEPT) {
			switch(options[curSelected]) {
				case 'Chart Editor'://felt it would be cool maybe -bbpanzu
					LoadingState.loadAndSwitchState(() ->new ChartingState(), false);
				case 'Character Editor':
					LoadingState.loadAndSwitchState(() ->new CharacterEditorState(Character.DEFAULT_CHARACTER, false));
				case 'Week Editor':
					FlxG.switchState(() -> new WeekEditorState());
				case 'Credits Editor': //haoneRG made the credits editor btw lol!!!!
					LoadingState.loadAndSwitchState(() ->new CreditsEditor(), false);
				case 'Menu Character Editor':
					FlxG.switchState(() -> new MenuCharacterEditorState());
				case 'Dialogue Editor':
					LoadingState.loadAndSwitchState(() ->new DialogueEditorState(), false);
				case 'Dialogue Portrait Editor':
					LoadingState.loadAndSwitchState(() ->new DialogueCharacterEditorState(), false);
				case 'Note Splash Editor':
					FlxG.switchState(() -> new NoteSplashDebugState());
				/*case 'Stage Editor':
					LoadingState.loadAndSwitchState(() ->s_editor, true);*/
			}
			FlxG.sound.music.volume = 0;
			FreeplayState.destroyFreeplayVocals();
		}
		
		var bullShit:Int = 0;
		for (item in grpTexts.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if(item.targetY == 0) item.alpha = 1;
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected += change;
		if(curSelected < 0) curSelected = options.length - 1;
		if(curSelected >= options.length) curSelected = 0;
	}

	#if MODS_ALLOWED
	function changeDirectory(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curDirectory += change;
		if(curDirectory < 0) curDirectory = directories.length - 1;
		if(curDirectory >= directories.length) curDirectory = 0;
	
		WeekData.setDirectoryFromWeek();
		if(directories[curDirectory] == null || directories[curDirectory].length < 1) {
			directoryTxt.text = 'Editors - < No Mod Loaded >';
			//s_editor.isModFolder = false;
		}else{
			//s_editor.isModFolder = true;
			Mods.currentModDirectory = directories[curDirectory];
			directoryTxt.text = 'Editors - < Loaded Mod: ' + Mods.currentModDirectory + ' >';
		}
		directoryTxt.text = directoryTxt.text.toUpperCase();
	}
	#end
}