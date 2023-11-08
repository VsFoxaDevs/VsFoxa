import Std;
var blackJumpscare:FlxSprite;
var bfr:String;
var bfg:String;
var bfb:String;
var dadr:String;
var dadg:String;
var dadb:String;

function onCreate()
{
    blackJumpscare = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
        -FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
    blackJumpscare.scrollFactor.set();
    blackJumpscare.alpha = 0;
    game.addBehindGF(blackJumpscare);
    bfr = game.playstate.bf.healthColorArray[0];
    bfg = game.playstate.bf.healthColorArray[1];
    bfb = game.playstate.bf.healthColorArray[2];
    dadr = game.playstate.dad.healthColorArray[0];
    dadg = game.playstate.dad.healthColorArray[1];
    dadb = game.playstate.dad.healthColorArray[2];
}

function onEvent(name:String, value1:String, value2:String)
{
    var fVal2:Float = Std.parseFloat(value2);

    if (name == 'neoneffect') 
    {
        if (value1 == 'in')
        {
            FlxTween.tween(blackJumpscare, {alpha: 1}, fVal2, {ease: FlxEase.sineInOut});

            FlxTween.tween(game.boyfriend.colorTransform,  {blueOffset: bfb, redOffset: bfr, greenOffset: bfg}, fVal2, {ease: FlxEase.sineInOut});
            FlxTween.tween(game.dad.colorTransform, {blueOffset: dadb, redOffset: dadr, greenOffset: dadg}, fVal2, {ease: FlxEase.sineInOut});
            if (game.gf != null)
                FlxTween.tween(game.gf.colorTransform, {blueOffset: 255, redOffset: 255, greenOffset: 255}, fVal2, {ease: FlxEase.sineInOut});
        } else if (value1 == 'out')
        {
            FlxTween.tween(blackJumpscare, {alpha: 0}, fVal2, {ease: FlxEase.sineInOut});

            FlxTween.tween(game.boyfriend.colorTransform, {blueOffset: 0, redOffset: 0, greenOffset: 0}, fVal2, {ease: FlxEase.sineInOut});
            FlxTween.tween(game.dad.colorTransform, {blueOffset: 0, redOffset: 0, greenOffset: 0}, fVal2, {ease: FlxEase.sineInOut});
            if (game.gf != null)
                FlxTween.tween(game.gf.colorTransform, {blueOffset: 0, redOffset: 0, greenOffset: 0}, fVal2, {ease: FlxEase.sineInOut});
        }
    }
}