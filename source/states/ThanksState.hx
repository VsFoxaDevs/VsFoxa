package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

//taken from Kade's OutdatedSubState
class ThanksState extends MusicBeatState
{
    var bg:FlxSprite;
    var grid:FlxBackdrop;
    private var colorRotation:Int = 1;
	private var colors:Array<String> = [
		'#314d7f',
		'#4e7093',
		'#70526e',
		'#594465'
	];

	override function create(){
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Thanks Menu", null);
		#end

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

		var logo:FlxSprite = new FlxSprite(FlxG.width, 0);
		logo.frames = Paths.getSparrowAtlas('logoBumpin');
		logo.scale.y = 0.3;
		logo.scale.x = 0.3;
		logo.x -= logo.frameHeight;
		logo.y -= 180;
		logo.alpha = 0.8;
		logo.antialiasing = ClientPrefs.data.antialiasing;
		
		logo.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logo.animation.play('bump');
		logo.updateHitbox();

		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"Thanks for playing Vs. Foxa Ultimate!\nYou are on a Developer Build.\nIf you were given this by someone who isn't a dev/playtester,\nplease contact one of the devs at Foxacord.\n(https://discord.gg/FARpwR9K4k)"
			+ "\n\nPress Enter to continue.",
			32);

		txt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.fromRGB(200, 200, 200), CENTER);
		txt.borderColor = FlxColor.BLACK;
		txt.borderSize = 2.4;
		txt.borderStyle = FlxTextBorderStyle.OUTLINE;
		txt.screenCenter();

        add(bg);
		add(grid);
        add(logo);
        add(txt);

		FlxTween.color(bg, 2, bg.color, FlxColor.fromString(colorShitters[colorRotation]));
		FlxTween.angle(logo, logo.angle, -10, 2, {ease: FlxEase.quartInOut});

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			FlxTween.color(bg, 2, bg.color, FlxColor.fromString(colorShitters[colorRotation]));
			if(colorRotation < (colorShitters.length - 1)) colorRotation++;
			else colorRotation = 0;
		}, 0);

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			if(logo.angle == -10) FlxTween.angle(logo, logo.angle, 10, 2, {ease: FlxEase.quartInOut});
			else FlxTween.angle(logo, logo.angle, -10, 2, {ease: FlxEase.quartInOut});
		}, 0);

		new FlxTimer().start(0.8, function(tmr:FlxTimer)
		{
			if(logo.alpha == 0.8) FlxTween.tween(logo, {alpha: 1}, 0.8, {ease: FlxEase.quartInOut});
			else FlxTween.tween(logo, {alpha: 0.8}, 0.8, {ease: FlxEase.quartInOut});
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