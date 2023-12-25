package states;

import backend.WeekData;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;

import flixel.input.keyboard.FlxKey;
import lime.app.Application;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import states.editors.MasterEditorMenu;
import options.OptionsState;

import tjson.TJSON as Json;

using StringTools;

// this is FANUM TAX! first i GYATT your brother... now i RIZZ you! SKIBIDI my friend!
// this is FANUM TAX! first i GYATT your brother... now i RIZZ you! SKIBIDI my friend!
// this is FANUM TAX! first i GYATT your brother... now i RIZZ you! SKIBIDI my friend!
// this is FANUM TAX! first i GYATT your brother... now i RIZZ you! SKIBIDI my friend!
// this is FANUM TAX! first i GYATT your brother... now i RIZZ you! SKIBIDI my friend!
// this is FANUM TAX! first i GYATT your brother... now i RIZZ you! SKIBIDI my friend!
// this is FANUM TAX! first i GYATT your brother... now i RIZZ you! SKIBIDI my friend!
// this is FANUM TAX! first i GYATT your brother... now i RIZZ you! SKIBIDI my friend!
// this is FANUM TAX! first i GYATT your brother... now i RIZZ you! SKIBIDI my friend!
// this is FANUM TAX! first i GYATT your brother... now i RIZZ you! SKIBIDI my friend!
// this is FANUM TAX! first i GYATT your brother... now i RIZZ you! SKIBIDI my friend!

// actually dont read this, its no longer funny./.,/./,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.;.

typedef MainMenuData = {
	fridayAchieve:String,
	discordLink:String,
	checkboard:Bool,
	versionText:String
}

class MainMenuState extends MusicBeatState {
	public static var psychEngineVersion:String = '0.7.2h-foxa'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;
	private var colorRotation:Int = 1;

	public static var menuJunk:MainMenuData;

	var menuItems:FlxTypedGroup<FlxSprite>;
	
	final quotes:Array<String> = [
		#if html5
		"You're on web. Why the FUCK are you on web? You can't get even decent easter eggs, bitch."
		#elseif debug
		"You want logs on debug? I'll give you logs on debug. Out of wood, easter eggs can't display like this."
		#else
		"500+  Giftcards! (-CharlesCatYT)",
		"bro became starfire from teen titans go (-Monomouse)",
		"Hi (-ScriptedMar)",
		"vile fnf (-BambiTGA)",
		"I'm gonna stop updating Psych Engine soon. (-ShadowMario)",
		"Its already been 1 beer... (-cyborg henry)",
		"this is FANUM TAX! first i GYATT your brother... now i RIZZ you! SKIBIDI my friend! (-Foxa The Artist)",
		"sorry i may have taken a bite out of your chicken (-cyborg henry)",
		"Damn how many fnf mods are ya'll making1?!?! (-ItsToppy)",
		"Get briccedd (-cyborg henry)",
		"uninstall. (-Darkness Light)",
		"business be boomin' (-Foxa The Artist)",
		"YOUR ARGUMENT, IS NOW INVALID! (-Monomouse)",
		"when did we start playing freeze tag (-Vencerist)",
		"top 100 reasons why I won't ask foxa unless she's online (-CharlesCatYT)",
		"Lowkey smooth (-TheAnimateMan)",
		"JHJJTLKGFD WHY IS MILKY SO LOUD IN THE EXPORT (-cyborg henry)",
		"I like starting a fire (-Vencerist)"
		#end
	];

	final optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		#if MODS_ALLOWED 'mods', #end
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		'donate',
		'options'
	];

	var bgColors:Array<String> = ['#517bc4', '#eb9bee', '#eb3030', '#eb7e19'];

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	override function create() {
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Main Menu", null);
		#end

		// IGNORE THIS!!!
		menuJunk = Json.parse(Paths.getTextFromFile('images/mainmenu/mainMenuShits.json'));

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		FlxG.mouse.visible = true;

		final yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);

		final bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.active = false;
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);
		
		camFollow = new FlxObject(0, 0, 1, 1);
		//add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.active = false;
		magenta.antialiasing = ClientPrefs.data.antialiasing;
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.color = 0xFFfd719b;
		add(magenta);

		if(menuJunk.checkboard == true){
			var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33525252, 0x0));
			grid.velocity.set(40, 40);
			grid.alpha = 0;
			FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
			add(grid);
		}

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		final scale:Float = 1;

		for (i in 0...optionShit.length) {
			final offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			final menuItem:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.visible = true;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.updateHitbox();
		}

		/* foxa dance */
		var char = new FlxSprite(730, 75);
		char.frames = Paths.getSparrowAtlas('gfDanceTitle');
		char.animation.addByPrefix('idle', 'dance', 24, true);
		char.animation.play('idle');
		char.scrollFactor.set();
		char.flipX = true;
		char.screenCenter(Y);
		char.antialiasing = ClientPrefs.data.antialiasing;
		add(char);

		final versionShit1:FlxText = new FlxText(12, FlxG.height - 84, 0, 'Psych Engine v$psychEngineVersion', 12);
		versionShit1.active = false;
		versionShit1.scrollFactor.set();
		versionShit1.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit1);
		final versionShit2:FlxText = new FlxText(12, FlxG.height - 64, 0, menuJunk.versionText, 12);
		versionShit2.active = false;
		versionShit2.scrollFactor.set();
		versionShit2.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit2);
		final versionShit3:FlxText = new FlxText(12, FlxG.height - 44, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit3.active = false;
		versionShit3.scrollFactor.set();
		versionShit3.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit3);
		final versionShit4:FlxText = new FlxText(12, FlxG.height - 24, 0, quotes[Std.random(quotes.length)], 12);
		versionShit4.active = false;
		versionShit4.scrollFactor.set();
		versionShit4.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit4);

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		final leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) Achievements.unlock('friday_night_play');

		#if MODS_ALLOWED
		Achievements.reloadList();
		#end
		#end

		FlxTween.color(bg, 2, bg.color, FlxColor.fromString(bgColors[colorRotation]));

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			FlxTween.color(bg, 2, bg.color, FlxColor.fromString(bgColors[colorRotation]));
			if(colorRotation < (bgColors.length - 1)) colorRotation++;
			else colorRotation = 0;
		}, 0);

		super.create();

		FlxG.camera.follow(camFollow, null, 9);
	}

	var selectedSomethin:Bool = false;
	var colorTimer:Float = 0;

	override function update(elapsed:Float) {
		if(FlxG.sound.music.volume < 0.8){
			FlxG.sound.music.volume += 0.5 * elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}
		//FlxG.camera.followLerp = FlxMath.bound(elapsed * 9 * (FlxG.updateFramerate / 60), 0, 1);

		if (!selectedSomethin) {
			if (controls.UI_UP_P || controls.UI_DOWN_P) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(controls.UI_UP_P ? -1 : 1);
			}

			for (item in menuItems.members) {
				final itemIndex:Int = menuItems.members.indexOf(item);

				if(FlxG.mouse.overlaps(item) && curSelected != itemIndex) {
					curSelected = itemIndex;
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem();
					break;
				}
			}

			if(controls.BACK) {
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if(controls.ACCEPT || (FlxG.mouse.overlaps(menuItems.members[curSelected]) && FlxG.mouse.justPressed)) {
				if(optionShit[curSelected] == 'donate') CoolUtil.browserLoad(menuJunk.discordLink); //foxacord, it's hidden as donate, cuz foxas parents may watch the gameplay footage when released pfffft, lets hope they wont see this line of code :)
				else {
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.data.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					for (item in menuItems.members) {
						final itemIndex:Int = menuItems.members.indexOf(item);

						if(curSelected != itemIndex) {
							FlxTween.tween(item, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut, 
								onComplete: function(twn:FlxTween) item.destroy()
							});
						}else{
							FlxFlicker.flicker(item, 1, 0.06, false, false, function(flick:FlxFlicker) {
								final daChoice:String = optionShit[curSelected];

								switch (daChoice) {
									case 'story_mode': MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay': MusicBeatState.switchState(new FreeplayState());
									#if MODS_ALLOWED case 'mods': MusicBeatState.switchState(new ModsMenuState()); #end
									#if ACHIEVEMENTS_ALLOWED case 'awards': MusicBeatState.switchState(new AchievementsMenuState()); #end
									case 'credits': MusicBeatState.switchState(new CreditsState());
									case 'options':
										MusicBeatState.switchState(new OptionsState());
										OptionsState.onPlayState = false;
										if(PlayState.SONG != null){
											PlayState.SONG.arrowSkin = null;
											PlayState.SONG.splashSkin = null;
											PlayState.stageUI = 'normal';
										}
								}
							});
						}
					}
				}
			}
			#if desktop
			else if (controls.justPressed('debug_1'))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite) {
			spr.screenCenter(X);
			spr.x -= 270;
		});
	}

	function changeItem(?huh:Int = 0) {
		curSelected = FlxMath.wrap(curSelected + huh, 0, menuItems.length - 1);
		for (item in menuItems.members) {
			final itemIndex:Int = menuItems.members.indexOf(item);
			if(curSelected != itemIndex) {
				item.animation.play('idle', true);
				item.updateHitbox();
			}else{
				item.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) add = menuItems.length * 8;
				camFollow.setPosition(item.getGraphicMidpoint().x, item.getGraphicMidpoint().y - add);
				item.centerOffsets();
			}
		}
	}
}
