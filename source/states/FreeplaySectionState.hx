package states;
#if FREEPLAY_SECTIONS
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.effects.FlxFlicker;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import backend.WeekData;
import backend.CoolUtil;
import backend.ClientPrefs;
import backend.Conductor;

/**
* State used to decide which selection of songs should be loaded in `FreeplayState`.
*/
class FreeplaySectionState extends MusicBeatState
{
	public static var daSection:String = '';
	var counter:Int = 0;
	var sectionArray:Array<String> = [];

	var sectionSpr:FlxSprite;
	var sectionTxt:FlxText;

    var camGame:FlxCamera;

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	var bg:FlxSprite;
	var transitioning:Bool = false;

	override function create()
	{
		#if desktop DiscordClient.changePresence("Selecting a Freeplay Section", null); #end

		persistentUpdate = true;
		WeekData.reloadWeekFiles(false);

		var doFunnyContinue = false;

		for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			if(leWeek.hideFreeplay) continue;
			if (leWeek.sections != null) {
				var fuck:Int = 0;
				for (section in leWeek.sections) {
					if (section.toLowerCase() != sectionArray[fuck].toLowerCase())
						sectionArray.push(section);
					fuck++;
				}
			} else doFunnyContinue = true;
			if (doFunnyContinue) {
				doFunnyContinue = false;
				continue;
			}

			WeekData.setDirectoryFromWeek(leWeek);
		}
		sectionArray = CoolUtil.removeDuplicates(sectionArray);
		WeekData.reloadWeekFiles(false);

		daSection = sectionArray[0];

		camGame = new FlxCamera();

		FlxG.cameras.reset(camGame);
		FlxG.cameras.setDefaultDrawTarget(camGame, true); //new EPIC code

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set();
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		sectionSpr = new FlxSprite().loadGraphic(Paths.image('freeplaysections/' + daSection.toLowerCase()));
		sectionSpr.antialiasing = ClientPrefs.data.antialiasing;
		sectionSpr.scrollFactor.set();
		sectionSpr.screenCenter(XY);
		add(sectionSpr);

		sectionTxt = new FlxText(0, 620, 0, "", 32);
		sectionTxt.scrollFactor.set();
		sectionTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
        sectionTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		sectionTxt.screenCenter(X);
		sectionTxt.y += 620;
		add(sectionTxt);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, null, 1);

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8) {
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (!transitioning) {
			var mult:Float = FlxMath.lerp(1, bg.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
			bg.scale.set(mult, mult);
			bg.updateHitbox();
			var mult:Float = FlxMath.lerp(1, sectionSpr.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
			sectionSpr.scale.set(mult, mult);
			sectionSpr.updateHitbox();
		}

		if (controls.UI_LEFT_P && !transitioning)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			if (counter > 0)
				counter -= 1;
			else counter = sectionArray.length - 1;

            daSection = sectionArray[counter];
            sectionSpr.loadGraphic(Paths.image('freeplaysections/' + daSection.toLowerCase()));
            sectionSpr.scale.set(1.1, 1.1);
            sectionSpr.updateHitbox();
		}

		if (controls.UI_RIGHT_P && !transitioning) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
			if (counter < sectionArray.length - 1)
				counter += 1;
			else counter = 0;

            daSection = sectionArray[counter];
            sectionSpr.loadGraphic(Paths.image('freeplaysections/' + daSection.toLowerCase()));
            sectionSpr.scale.set(1.1, 1.1);
            sectionSpr.updateHitbox();
		}

		if ((controls.BACK || FlxG.mouse.justPressedRight) && !transitioning) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(() -> new MainMenuState());
		}

		if ((controls.ACCEPT || FlxG.mouse.justPressed) && !transitioning) {
			FlxG.sound.play(Paths.sound('confirmMenu'));
			transitioning = true;
			sectionTxt.visible = false;
            FlxTween.tween(sectionSpr, {'scale.x': 1.5, 'scale.y': 1.5}, 0.7, {ease: FlxEase.circOut});
			if (!ClientPrefs.data.flashing) {
				/*FlxTween.tween(sectionSpr, {'scale.x': 11, 'scale.y': 11, y: sectionSpr.y + 3000, alpha: 0 }, 0.9, { 
                    ease: FlxEase.expoIn 
                });*/
				FlxTween.tween(bg, {'scale.x': 0.003, 'scale.y': 0.003, alpha: 0}, 1.1, {
					ease: FlxEase.expoIn, onComplete: function(twn:FlxTween) {
                        FlxG.switchState(() -> new FreeplayState()); 
                    }});
			} else {
				FlxFlicker.flicker(sectionSpr, 1, 0.06, true, false, function(_)
				{
					FlxG.switchState(() -> new FreeplayState());
				});
            }
		}

		sectionTxt.text = daSection.toUpperCase();
		sectionTxt.screenCenter(X);

		if(transitioning) {
			bg.screenCenter(XY);
		} 

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		super.update(elapsed);
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}
}
#end