package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.effects.FlxFlicker;

using StringTools;

class ThanksState extends MusicBeatState {
    var bg:FlxSprite;
    var grid:FlxBackdrop;
    var colorRotation:Int = 1;
    private var colors:Array<String> = [
		'#314d7f',
		'#4e7093',
		'#70526e',
		'#594465'
    ];

	var txt:FlxText;

    override function create(){
		#if desktop DiscordClient.changePresence("Thanks Menu", null); #end

		bg = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
        bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.10;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		
		if (ClientPrefs.data.checkerBoard)
		{
			var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
			grid.velocity.set(40, 40);
			grid.alpha = 0;
			FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
			add(grid);
		}	

		#if debug
		txt = new FlxText(0, 0, FlxG.width,
			"Thanks for playing Vs. Foxa SE 3.0!\nYou are on a Developer Build.\nIf you were given this by someone who isn't a dev/playtester,\nplease contact one of the devs at Foxacord.\n(https://discord.gg/FARpwR9K4k)"
			+ "\n\nPress Enter to continue.",
			32);
		#else
		txt = new FlxText(0, 0, FlxG.width,
			"Thanks for playing Vs. Foxa SE 3.0!\nWe have worked hard on this for long, \nand we appreciate you playing the mod!"
			+ "\n\nPress Enter to continue.",
			32);
		#end

		txt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.fromRGB(200, 200, 200), CENTER);
		txt.borderColor = FlxColor.BLACK;
		txt.borderSize = 2.4;
		txt.borderStyle = FlxTextBorderStyle.OUTLINE;
		txt.screenCenter();

        add(bg);
		add(grid);
        add(txt);

        FlxTween.color(bg, 2, bg.color, FlxColor.fromString(colors[colorRotation]));

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			FlxTween.color(bg, 2, bg.color, FlxColor.fromString(colors[colorRotation]));
			if(colorRotation < (colors.length - 1)) colorRotation++;
			else colorRotation = 0;
		}, 0);

        super.create();
	}

	override function update(elapsed:Float){
        if(controls.ACCEPT || controls.BACK){
			if(!controls.BACK) {
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.4);
				FlxFlicker.flicker(txt, 1, 0.1, false, true, function(flk:FlxFlicker) {
					new FlxTimer().start(0.5, function (tmr:FlxTimer) {
						try {
							FlxG.switchState(() -> new states.SaveFileState());
						}
						catch (e:Dynamic) {
							trace('nice save file, but unfortunately- ${e}');
								FlxG.switchState(() -> new states.MainMenuState());
						}
					});
				});
			} else {
				FlxG.sound.play(Paths.sound('cancelMenu'), 0.4);
				FlxTween.tween(txt, {alpha: 0}, 1, {
					onComplete: function (twn:FlxTween) {
						try {
							FlxG.switchState(() -> new states.TitleState());
						}
						catch (e:Dynamic) {
							trace('nice argument, but unfortunately- ${e}');
								FlxG.switchState(() -> new states.MainMenuState());
						}
					}
				});
			}
		}

		super.update(elapsed);
	}
}