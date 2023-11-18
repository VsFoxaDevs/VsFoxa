package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class ThanksState extends MusicBeatState {
    var bg:FlxSprite;
    var grid:FlxBackdrop;
    private var colorRotation:Int = 1;
    private var colors:Array<String> = [
		'#314d7f',
		'#4e7093',
		'#70526e',
		'#594465'
    ];

	public var luaArray:Array<FunkinLua> = [];

    override function create(){
		#if desktop DiscordClient.changePresence("Thanks Menu", null); #end

		bg = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
        bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.10;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		grid = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33525252, 0x0));
		grid.velocity.set(40, 40);
		grid.alpha = 0;
		FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});

		#if debug
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"Thanks for playing Vs. Foxa 3.0!\nYou are on a Developer Build.\nIf you were given this by someone who isn't a dev/playtester,\nplease contact one of the devs at Foxacord.\n(https://discord.gg/FARpwR9K4k)"
			+ "\n\nPress Enter to continue.",
			32);
		#else
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"Thanks for playing Vs. Foxa 3.0!\nWe have worked hard on this for long, and we appreciate you playing the mod!\nAlso, if you want, you can join the official\nVS.FOXA Discord server as well.\n(https://discord.gg/FARpwR9K4k)"
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
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.4);
			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}
}