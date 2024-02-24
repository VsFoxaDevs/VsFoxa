package states;

import objects.Character;
import objects.HealthIcon;

/**
    This is not from the Dave & Bambi source code, it's completely made by Delta.
    Modified by Altertoriel and CharlesCatYY. (Ported to Alleyway Engine/Psych 0.7.3)
**/

class CharacterSelectionState extends MusicBeatState {
	public static var characterData:Array<Dynamic> = [
		// ["character name", /*forms are here*/[["form 1 name", 'character json name'], ["form 2 name (can add more than just one)", 'character json name 2']]/*forms end here*/, /*hide it completely*/ true],
		["Boyfriend", [
				["Boyfriend", 'bf'],
				["Fire Boyfriend", 'FIRE BF'],
				["Boyfriend (Creation)", 'Creation BF'],
				["Boyfriend (Alt)", 'boyfriend'],
				["Boyfriend (Pixel)", 'bf-pixel'],
				["Boyfriend (Christmas)", 'bf-christmas'],
				["Boyfriend and Girlfriend", 'bf-holding-gf']
			], false],
		["Foxa", [
				["Foxa", 'foxa'],
				["Foxa (Lesson)", 'playable-foxa'],
				["Angy Foxa", 'Angy Foxa'],
				["Creation", 'creation'],
				["Creation (Colors)", 'creation-colors'],
				["Foxa (Old)", 'foxa-2'],
				["Angy Foxa (Old)", 'foxa-pissed'],
				["Creation (Old)", 'foxa-mad'],
				["TGT Foxa", 'foxa-trolled']
			], false],
		["Whitty", [["Whitty (Remixed)", 'rwhitty'], ["Whitty (Lesson)", 'Whitty-Happy']], false],
		["Updike", [["Updike", 'updike'], ["Updike (Static)", 'static-updike']], false],
	];

	var boyfriend:Character;
	var boyfriendGroup:FlxSpriteGroup;

	public static var bgMusic:String = "breakfast";
	public static var characterFile:String = 'bf';

	final BF_POS:Array<Float> = [770, 100];

	var curSelected:Int = 0;
	var curSelectedForm:Int = 0;
	var curText:FlxText;
    var curIcon:HealthIcon;
	var controlsText:FlxText;
	var entering:Bool = false;

	var previewMode:Bool = false;
	var unlocked:Bool = true;

	var camGame:FlxCamera;
	var camHUD:FlxCamera;

	override function create() {
		#if desktop DiscordClient.changePresence('Selecting a Character'); #end

		persistentUpdate = true;

		camGame = initPsychCamera();

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD, false);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		menuBG.antialiasing = ClientPrefs.data.antialiasing;
		menuBG.setGraphicSize(Std.int(menuBG.width * 2));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.scrollFactor.set();
		add(menuBG);

		camGame.scroll.set(120, 130);
		
		camGame.zoom = 0.75;
		camHUD.zoom = 0.75;

		var tutorialThing:FlxSprite = new FlxSprite(-125, -100).loadGraphic(Paths.image('charSelectGuide'));
		tutorialThing.setGraphicSize(Std.int(tutorialThing.width * 1.25));
		tutorialThing.antialiasing = true;
		add(tutorialThing);

		curText = new FlxText(0, -100, 0, characterData[curSelected][1][0][0], 50);
		curText.setFormat(Paths.font("vcr.ttf"), 50, FlxColor.WHITE, CENTER);
		curText.setBorderStyle(OUTLINE, FlxColor.BLACK, 5);
        curText.scrollFactor.set();

		controlsText = new FlxText(-125, 125, 0, 'Press P to enter preview mode.', 20);
		controlsText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		controlsText.size = 20;
        controlsText.scrollFactor.set();

		boyfriendGroup = new FlxSpriteGroup(BF_POS[0], BF_POS[1]);

		boyfriend = new Character(0, 0, "bf", true);
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
		boyfriendGroup.add(boyfriend);
		boyfriend.dance();

		add(boyfriendGroup);

		curIcon = new HealthIcon(boyfriend.healthIcon, true);
        curIcon.scrollFactor.set();
		curIcon.camera = camHUD;
		curIcon.antialiasing = true;
		curIcon.screenCenter(X).y = (curText.y + curIcon.height) - 100;

		add(curText);
		add(curIcon);
		add(controlsText);
		curText.camera = camHUD;
		controlsText.camera = camHUD;
		tutorialThing.camera = camHUD;

		curText.screenCenter(X);
		curIcon.screenCenter(X);
		changeCharacter();

		FlxG.sound.playMusic(Paths.music(bgMusic));
		Conductor.bpm = 120;
		
		super.create();
	}

	override public function beatHit() {
		super.beatHit();
		if (!entering && camGame.zoom < 1.35) camGame.zoom += 0.0075;
		if (curBeat % 2 == 0) boyfriend.dance();
	}

	function checkPreview() {
		if (previewMode) controlsText.text = "PREVIEW MODE\nPress I to play idle animation.\nPress your controls to play an animation.\n";
		else {
			controlsText.text = "Press P to enter preview mode.";
			boyfriend.playAnim('idle', true);
		}
	}

	override function update(elapsed) {
		Conductor.songPosition = FlxG.sound.music.time;
		super.update(elapsed);

		camGame.zoom = FlxMath.lerp(0.7, camGame.zoom, Math.exp(-elapsed * 3.125));

		if (FlxG.keys.justPressed.P && unlocked && !entering) {
			previewMode = !previewMode;
			checkPreview();
		}
		if (!previewMode) {
			if (controls.UI_RIGHT_P || controls.UI_LEFT_P) changeCharacter(controls.UI_RIGHT_P ? 1 : -1);
			if ((controls.UI_DOWN_P || controls.UI_UP_P) && unlocked) changeForm(controls.UI_DOWN_P ? 1 : -1);
			if (controls.ACCEPT && unlocked) acceptCharacter();
		} else if (!previewMode) {
			if (controls.UI_RIGHT_P) {
				curSelected += 1;
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (controls.UI_LEFT_P) {
				curSelected = -1;
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (curSelected < 0) curSelected = 0;
			if (curSelected >= 2) curSelected = 0;
			if (controls.ACCEPT)
			{
				FlxG.sound.music.stop();
				FlxTween.tween(camHUD, {alpha: 0}, 0.25, {ease: FlxEase.circOut});

				LoadingState.loadAndSwitchState(() -> new PlayState());
			}
		} else {
			if (controls.NOTE_LEFT_P) if (boyfriend.animOffsets.exists('singLEFT')) boyfriend.playAnim('singLEFT');
			if (controls.NOTE_DOWN_P) if (boyfriend.animOffsets.exists('singDOWN')) boyfriend.playAnim('singDOWN');
			if (controls.NOTE_UP_P) if (boyfriend.animOffsets.exists('singUP')) boyfriend.playAnim('singUP');
			if (controls.NOTE_RIGHT_P) if (boyfriend.animOffsets.exists('singRIGHT')) boyfriend.playAnim('singRIGHT');
			if (FlxG.keys.justPressed.I) boyfriend.playAnim('idle');
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(() -> new FreeplayState());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}
	}

	function changeCharacter(change:Int = 0, playSound:Bool = true) {
		if (entering) return;

		if (playSound) FlxG.sound.play(Paths.sound('scrollMenu'));
		curSelectedForm = 0;
		curSelected = FlxMath.wrap(curSelected + change, 0, characterData.length - 1);
		var unlockedChrs:Array<String> = FlxG.save.data.unlockedCharacters;
		if (unlockedChrs.contains(characterData[curSelected][0])) unlocked = true /*false*/;
		characterFile = characterData[curSelected][1][0][1];

		if (unlocked) {
			curText.text = characterData[curSelected][1][0][0];
			reloadCharacter();
		} else if (!characterData[curSelected][3]) {
			curText.text = "???";
			reloadCharacter();
		} else changeCharacter(change, false);

		curText.screenCenter(X);
	}

	function changeForm(change:Int) {
		var chrData:Array<Array<String>> = characterData[curSelected][1];
		if (!entering && chrData.length >= 2) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
			curSelectedForm = FlxMath.wrap(curSelectedForm + change, 0, chrData.length - 1);

			curText.text = chrData[curSelectedForm][0];
			characterFile = chrData[curSelectedForm][1];
			reloadCharacter();
			curText.screenCenter(X);
		}
	}

	function reloadCharacter() {
		boyfriend.destroy();
		boyfriendGroup.remove(boyfriend, true);
		boyfriend = new Character(0, 0, characterFile, true);
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
		boyfriend.dance();
		boyfriendGroup.add(boyfriend);

		curIcon.changeIcon(boyfriend.healthIcon);
		curIcon.y = (curText.y + curIcon.height) - 100;

		if (!unlocked) boyfriend.color = FlxColor.BLACK;
		curIcon.color = unlocked ? FlxColor.WHITE : FlxColor.BLACK;
	}

	function acceptCharacter() {
		if (!entering) {
			entering = true;
			if (boyfriend.animOffsets.exists('hey') && boyfriend.animation.getByName('hey') != null)
				boyfriend.playAnim('hey');
			// else boyfriend.playAnim('singUP');

			FlxG.sound.playMusic(Paths.music('gameOverEnd'));
            new FlxTimer().start(1.5, (tmr:FlxTimer) -> {
				var lastGF:String = PlayState.SONG.gfVersion;
				PlayState.SONG.gfVersion = switch (characterFile) {
					case 'bf-pixel': 'gf-pixel';
					case 'bf-christmas': 'gf-christmas';
					case 'playable-foxa': 'invisible';
					default: lastGF;
				}

				switch (PlayState.SONG.song.toLowerCase()) {
					case 'execution' | 'firestorm': PlayState.SONG.player1 = 'BF execution';
					default: PlayState.SONG.player1 = characterFile;
				}
                LoadingState.loadAndSwitchState(() -> new PlayState());
			});
		}
	}
}

class CharacterUnlockObject extends flixel.group.FlxSpriteGroup {
	public var onFinish:Void->Void = null;

	var alphaTween:FlxTween;

	public function new(name:String, ?camera:FlxCamera = null, characterIcon:String, color:FlxColor = FlxColor.BLACK) {
		super(x, y);
		ClientPrefs.saveSettings();

		var characterBG:FlxSprite = new FlxSprite(60, 50).makeGraphic(420, 120, color);
		characterBG.scrollFactor.set();

		var characterIcon:HealthIcon = new HealthIcon(characterIcon, false);
		characterIcon.animation.curAnim.curFrame = 2;
        characterIcon.setPosition(characterBG.x + 10, characterBG.y + 10);
		characterIcon.scrollFactor.set();
		characterIcon.setGraphicSize(Std.int(characterIcon.width * (2 / 3)));
		characterIcon.updateHitbox();
		characterIcon.antialiasing = ClientPrefs.data.antialiasing;

		var characterName:FlxText = new FlxText(characterIcon.x + characterIcon.width + 20, characterIcon.y + 16, 280, name, 16);
		characterName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		characterName.scrollFactor.set();

		var characterText:FlxText = new FlxText(characterName.x, characterName.y + 32, 280, "Play as this character in freeplay!", 16);
		characterText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		characterText.scrollFactor.set();

		add(characterBG);
		add(characterName);
		add(characterText);
		add(characterIcon);

		var cam:Array<FlxCamera> = @:privateAccess FlxCamera._defaultCameras;
		if (camera != null) cam = [camera];
		alpha = 0;
		characterBG.cameras = characterName.cameras = characterText.cameras = characterIcon.cameras = cam;
		alphaTween = FlxTween.tween(this, {alpha: 1}, 0.5, {
			onComplete: (twn:FlxTween) -> {
				alphaTween = FlxTween.tween(this, {alpha: 0}, 0.5, {
					startDelay: 2.5,
					onComplete: (twn:FlxTween) -> {
						alphaTween = null;
						remove(this);
						if (onFinish != null) onFinish();
					}
				});
			}
		});
	}

	override function destroy() {
		if (alphaTween != null) alphaTween.cancel();
		super.destroy();
	}
}