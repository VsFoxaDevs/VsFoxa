package states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;

import objects.HealthIcon;
import objects.MusicPlayer;
import states.editors.ChartingState;

import substates.GameplayChangersSubstate;
import substates.ResetScoreSubState;

import flixel.math.FlxMath;
import flixel.ui.FlxBar;
import flixel.util.FlxStringUtil;

@:access(flixel.sound.FlxSound)

class FreeplayState extends MusicBeatState {
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var lerpSelected:Float = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = Difficulty.getDefault();

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	#if FREEPLAY_SECTIONS
	var grpSongs:FlxTypedGroup<Alphabet>;

	var iconArray:Array<HealthIcon> = [];
	#else
	private var grpSongs:FlxTypedGroup<Alphabet>;

	private var iconArray:Array<HealthIcon> = [];
	#end

	var curPlaying:Bool = false;
	
	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	var section:String = '';

	var bottomString:String;
	var bottomText:FlxText;
	var bottomBG:FlxSprite;

	var player:MusicPlayer;

	override function create() {
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop DiscordClient.changePresence("Freeplay Menu", null); #end

		#if FREEPLAY_SECTIONS
		section = FreeplaySectionState.daSection;

		var doFunnyContinue = false;
		#end
		for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);

			#if FREEPLAY_SECTIONS 
			if (leWeek.sections != null) {
				doFunnyContinue = true;
			} else doFunnyContinue = true;

			if (doFunnyContinue) {
				doFunnyContinue = false;
				continue;
			} #end

			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length){
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs) {
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3) colors = [146, 113, 253];
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		Mods.loadTopMod();

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		grid.alpha = 0;
		FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(grid);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(90, 320, songs[i].songName, true);
			songText.targetY = i;
			grpSongs.add(songText);

			songText.scaleX = Math.min(1, 980 / songText.width);
			songText.snapToPosition();

			Mods.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			
			songText.visible = songText.active = songText.isMenuItem = false;
			icon.visible = icon.active = false;

			iconArray.push(icon);
			add(icon);
		}
		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		for (i in 0...2) {
			var text:FlxText = new FlxText();
			text.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, CENTER);
			text.text = '^';
			if(i == 1) text.flipY = true;
			text.visible = false;
			add(text);
		}

		missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);
		
		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;
		lerpSelected = curSelected;

		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));

		bottomBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		bottomBG.alpha = 0.6;
		add(bottomBG);

		var leText:String = "[SPACE] - Listen to the Song / [CTRL] - Open the Modifiers Menu / [RESET] - Reset your Score / [HOLD C] - Enable Character Selector";
		bottomString = leText;
		var size:Int = 16;
		bottomText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, leText, size);
		bottomText.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, CENTER);
		bottomText.scrollFactor.set();
		add(bottomText);
		
		player = new MusicPlayer(this);
		add(player);

		changeSelection();
		updateTexts();

		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	var wasPlaying:Bool;
	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	public static var opponentVocals:FlxSound = null;
	var holdTime:Float = 0;
	var holdPitchTime:Float = 0;
	var playbackRate(default, set):Float = 1;
	var playbackRates:Map<String, String> = new Map();

	override function update(elapsed:Float) {
		if(FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;

		if(FlxG.sound.music.volume < 0.7) FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
		lerpRating = FlxMath.lerp(intendedRating, lerpRating, Math.exp(-elapsed * 12));

		if (Math.abs(lerpScore - intendedScore) <= 10) lerpScore = intendedScore;
		if(Math.abs(lerpRating - intendedRating) <= 0.01) lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if(!player.playingMusic){
			scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
			positionHighscore();

			if(songs.length > 1) {
				if(FlxG.keys.justPressed.HOME){
					curSelected = 0;
					changeSelection();
					holdTime = 0;	
				}
				else if(FlxG.keys.justPressed.END){
					curSelected = songs.length - 1;
					changeSelection();
					holdTime = 0;	
				}
				if(controls.UI_UP_P){
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if(controls.UI_DOWN_P){
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if(controls.UI_DOWN || controls.UI_UP) {
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
				}

				if(FlxG.mouse.wheel != 0) {
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
					changeSelection(-shiftMult * FlxG.mouse.wheel, false);
				}
			}

			if(controls.UI_LEFT_P){
				changeDiff(-1);
				_updateSongLastDifficulty();
			}
			else if(controls.UI_RIGHT_P){
				changeDiff(1);
				_updateSongLastDifficulty();
			}
		}

		if(controls.BACK){
			if(player.playingMusic)
			{
				FlxG.sound.music.stop();
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;
				instPlaying = -1;

				player.playingMusic = false;
				player.switchPlayMusic();

				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
				FlxTween.tween(FlxG.sound.music, {volume: 1}, 1);
			}else{
				persistentUpdate = false;
				if(colorTween != null) colorTween.cancel();
				FlxG.sound.play(Paths.sound('cancelMenu'));
				#if FREEPLAY_SECTIONS
				FlxG.switchState(() -> new FreeplaySectionState());
				#else
				FlxG.switchState(() -> new MainMenuState());
				#end
			}
		}

		if(FlxG.keys.justPressed.CONTROL && !player.playingMusic){
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}else if(FlxG.keys.justPressed.SPACE){
			if(instPlaying != curSelected && !player.playingMusic){
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;

				Mods.currentModDirectory = songs[curSelected].folder;
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				Conductor.bpm = PlayState.SONG.bpm;
				if (PlayState.SONG.needsVoices) {
					vocals = new FlxSound();
					try {
						var playerVocals:String = getVocalFromCharacter(PlayState.SONG.player1);
						var loadedVocals = Paths.voices(PlayState.SONG.song, (playerVocals != null && playerVocals.length > 0) ? playerVocals : 'Player');
						if (loadedVocals == null) loadedVocals = Paths.voices(PlayState.SONG.song);

						if (loadedVocals != null && loadedVocals.length > 0) {
							vocals.loadEmbedded(loadedVocals);
							FlxG.sound.list.add(vocals);
							vocals.persist = vocals.looped = true;
							vocals.volume = 0.8;
							vocals.play();
							vocals.pause();
						}
						else vocals = FlxDestroyUtil.destroy(vocals);
					}
					catch (e:Dynamic) {vocals = FlxDestroyUtil.destroy(vocals);}

					opponentVocals = new FlxSound();
					try {
						// trace('please work...');
						var oppVocals:String = getVocalFromCharacter(PlayState.SONG.player2);
						var loadedVocals = Paths.voices(PlayState.SONG.song, (oppVocals != null && oppVocals.length > 0) ? oppVocals : 'Opponent');

						if (loadedVocals != null && loadedVocals.length > 0) {
							opponentVocals.loadEmbedded(loadedVocals);
							FlxG.sound.list.add(opponentVocals);
							opponentVocals.persist = opponentVocals.looped = true;
							opponentVocals.volume = 0.8;
							opponentVocals.play();
							opponentVocals.pause();
							// trace('yaaay!!');
						}
						else opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
					}
					catch (e:Dynamic){opponentVocals = FlxDestroyUtil.destroy(opponentVocals);}
				}

				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.8);
				FlxG.sound.music.pause();
				instPlaying = curSelected;

				player.playingMusic = true;
				player.curTime = 0;
				player.switchPlayMusic();
				player.pauseOrResume(true);
			}
			else if (instPlaying == curSelected && player.playingMusic) player.pauseOrResume(!player.playing);
		}
		else if(controls.ACCEPT && !player.playingMusic){
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			final poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			trace(poop);

			try {
				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;

				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
				if(colorTween != null) {
					colorTween.cancel();
				}
			}
			catch(e:Dynamic)
			{
				trace('ERROR! $e');

				var errorStr:String = e.toString();
				if(errorStr.startsWith('[file_contents,assets/data/')) errorStr = 'Missing file: ' + errorStr.substring(34, errorStr.length-1); //Missing chart
				missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
				missingText.screenCenter(Y);
				missingText.visible = true;
				missingTextBG.visible = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));

				updateTexts(elapsed);
				super.update(elapsed);
				return;
			}
			if (FlxG.keys.pressed.SHIFT){
				LoadingState.loadAndSwitchState(() -> new ChartingState());
			}else{
				if (FlxG.keys.pressed.C) {
					states.CharacterSelectionState.characterFile = 'bf';
					LoadingState.loadAndSwitchState(new states.CharacterSelectionState());
				}
				else LoadingState.loadAndSwitchState(() -> new PlayState());
			}
	
			FlxG.sound.music.pause();
					
			destroyFreeplayVocals();
			#if (MODS_ALLOWED && cpp)
			DiscordClient.loadModRPC();
			#end
		}else if(controls.RESET){
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		updateTexts(elapsed);
		super.update(elapsed);
		updateIconsScale(elapsed);
	}

	function getVocalFromCharacter(char:String) {
		try {
			var path:String = Paths.getPath('characters/$char.json', TEXT, null, true);
			var character:Dynamic = #if MODS_ALLOWED Json.parse(File.getContent(path)); #else Json.parse(Assets.getText(path)); #end
			return character.vocals_file;
		}
		return null;
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) vocals.stop();
		vocals = FlxDestroyUtil.destroy(vocals);

		if(opponentVocals != null) opponentVocals.stop();
		opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
	}

	function setPlaybackRate() {
		FlxG.sound.music.pitch = playbackRate;
		if(vocals != null) vocals.pitch = playbackRate;
	}

	function changeDiff(change:Int = 0) {
		if(player.playingMusic) return;

		curDifficulty += change;

		if (curDifficulty < 0) curDifficulty = Difficulty.list.length-1;
		if (curDifficulty >= Difficulty.list.length) curDifficulty = 0;

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);

		lastDifficultyName = Difficulty.getString(curDifficulty);
		if(Difficulty.list.length > 1) diffText.text = '< ' + lastDifficultyName.toUpperCase() + ' >';
		else diffText.text = lastDifficultyName.toUpperCase();

		positionHighscore();
		missingText.visible = false;
		missingTextBG.visible = false;
	}

	function changeSelection(change:Int = 0, playSound:Bool = true) {
		if(player.playingMusic) return;

		_updateSongLastDifficulty();
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		var lastList:Array<String> = Difficulty.list;
		curSelected += change;

		if(curSelected < 0) curSelected = songs.length - 1;
		if(curSelected >= songs.length) curSelected = 0;
			
		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) colorTween.cancel();
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {colorTween = null;}
			});
		}

		var bullShit:Int = 0;

		for (i in 0...iconArray.length) iconArray[i].alpha = 0.65;

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			bullShit++;
			item.alpha = 0.65;
			if(item.targetY == curSelected) item.alpha = 1;
		}
		
		Mods.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;
		Difficulty.loadFromWeek();
		
		var savedDiff:String = songs[curSelected].lastDifficulty;
		var lastDiff:Int = Difficulty.list.indexOf(lastDifficultyName);
		if(savedDiff != null && !lastList.contains(savedDiff) && Difficulty.list.contains(savedDiff))
			curDifficulty = Math.round(Math.max(0, Difficulty.list.indexOf(savedDiff)));
		else if(lastDiff > -1) curDifficulty = lastDiff;
		else if(Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else curDifficulty = 0;

		changeDiff();
		_updateSongLastDifficulty();
	}

	inline private function _updateSongLastDifficulty() songs[curSelected].lastDifficulty = Difficulty.getString(curDifficulty);

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}

	var lastBeatHit:Int = -1;

	public dynamic function updateIconsScale(elapsed:Float)
	{
		for (i in 0...iconArray.length)
		{ 
			var icon:HealthIcon = iconArray[i];
			var mult:Float = FlxMath.lerp(1, icon.scale.x, Math.exp(-elapsed * 9 * @:privateAccess player.playbackRate));
			icon.scale.set(mult, mult);
			icon.updateHitbox();
		}
	}

	override function beatHit()
	{
		if (player.playingMusic && !player.paused) {
			var icon:HealthIcon = iconArray[curSelected];
			icon.scale.set(1.2, 1.2);
			icon.updateHitbox();
		}

		super.beatHit();
	}

	override function sectionHit()
	{
		if (PlayState.SONG.notes[curSection] != null)
			if (PlayState.SONG.notes[curSection].changeBPM) Conductor.bpm = PlayState.SONG.notes[curSection].bpm;

		super.sectionHit();
	}

	var _drawDistance:Int = 4;
	var _lastVisibles:Array<Int> = [];
	public function updateTexts(elapsed:Float = 0.0) {
		lerpSelected = FlxMath.lerp(curSelected, lerpSelected, Math.exp(-elapsed * 9.6));
		for (i in _lastVisibles){
			grpSongs.members[i].visible = grpSongs.members[i].active = false;
			iconArray[i].visible = iconArray[i].active = false;
		}
		_lastVisibles = [];

		var min:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected - _drawDistance)));
		var max:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected + _drawDistance)));
		for (i in min...max)
		{
			var item:Alphabet = grpSongs.members[i];
			item.visible = item.active = true;
			item.x = ((item.targetY - lerpSelected) * item.distancePerItem.x) + item.startPosition.x;
			item.y = ((item.targetY - lerpSelected) * 1.3 * item.distancePerItem.y) + item.startPosition.y;

			var icon:HealthIcon = iconArray[i];
			icon.visible = icon.active = true;
			_lastVisibles.push(i);
		}
	}

    override function destroy():Void {
		super.destroy();

		FlxG.autoPause = ClientPrefs.data.autoPause;
		if(!FlxG.sound.music.playing) FlxG.sound.playMusic(Paths.music('freakyMenu'));
	}	

	function set_playbackRate(value:Float):Float {
		var value = FlxMath.roundDecimal(value, 2);
		if(value > 3) value = 3;
		else if(value <= 0.05) value = 0.05;
		return playbackRate = value;
	}
}

class SongMetadata {
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var lastDifficulty:String = null;

	public function new(song:String, week:Int, songCharacter:String, color:Int) {
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Mods.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}