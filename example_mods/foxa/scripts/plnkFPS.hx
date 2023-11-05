import Main;
import backend.ClientPrefs;
import openfl.text.TextField;
import openfl.display.Sprite;
import openfl.system.System;
import openfl.text.TextFormat;
import flixel.math.FlxMath;

var cumpenis:Sprite = new Sprite();
var fpsText:TextField;
var maxMemory:Float;
var currentMemory:Float;
var outlines:Array<TextField> = [];

// https://api.haxeflixel.com/flixel/util/FlxStringUtil.html#formatBytes idk if its compiled and im too lazy to test
var units:Array<String> = ["Bytes", "kB", "MB", "GB", "TB", "PB"];
function formatBytes(bytes) {
	var curUnit = 0;
	while (bytes >= 1024 && curUnit < units.length - 1) {
		bytes /= 1024;
		curUnit++;
	}
	return FlxMath.roundDecimal(bytes, 2) + units[curUnit];
}

// flxcolor shit because psychlua.HScript.CustomFlxColor is dumb
function getRed(color:Int):Int
	return (color >> 16) & 0xff;

function getGreen(color:Int):Int
	return (color >> 8) & 0xff;

function getBlue(color:Int):Int
	return color & 0xff;

function getAlpha(color:Int):Int
	return (color >> 24) & 0xff;

// interpolate doesent exist
function interpolate(from, to, factor):Int {
	var r:Int = Std.int((getRed(to) - getRed(from)) * factor + getRed(from));
	var g:Int = Std.int((getGreen(to) - getGreen(from)) * factor + getGreen(from));
	var b:Int = Std.int((getBlue(to) - getBlue(from)) * factor + getBlue(from));
	var a:Int = Std.int((getAlpha(to) - getAlpha(from)) * factor + getAlpha(from));
	return FlxColor.fromRGB(r, g, b, a);
}

// actual code

function onCreate() {
	if (Main.fpsVar.parent != null) Main.fpsVar.parent.removeChild(Main.fpsVar); // using .parent because it doesent like FlxG.stage????
	fpsText = new TextField();
	fpsText.defaultTextFormat = new TextFormat('VCR OSD Mono', 18);
	fpsText.textColor = 0x000000;
	fpsText.width = FlxG.width;
	fpsText.selectable = fpsText.mouseEnabled = false;

	for (i in 0...8) {
		var otext:TextField = new TextField();
		otext.x = Math.sin(i) * 2;
		otext.y = Math.cos(i) * 2;

		otext.defaultTextFormat = fpsText.defaultTextFormat;
		otext.textColor = 0xFFFFFF;
		otext.width = fpsText.width;
		otext.selectable = otext.mouseEnabled = false;

		outlines.push(otext);
		cumpenis.addChild(otext);
	}

	cumpenis.x = 10;
	cumpenis.y = 10;
	cumpenis.addChild(fpsText);

	FlxG.stage.addChild(cumpenis);
	return;
}

function onUpdate(elapsed) {
	var fps = Math.floor(1 / elapsed);
	currentMemory = System.totalMemory;
	if (maxMemory < currentMemory) maxMemory = currentMemory;
	setText('FPS: ' + fps + '\nMEM: ' + formatBytes(currentMemory) + ' / ' + formatBytes(maxMemory));
	
	var mappedFPS = FlxMath.remapToRange(fps, ClientPrefs.data.framerate, ClientPrefs.data.framerate / 2, 0, 1);
	fpsText.textColor = interpolate(0xFF000000, 0xFFEC5454, FlxEase.cubeIn(mappedFPS));
	return;
}

function onDestroy() {
	FlxG.stage.removeChild(cumpenis);
	FlxG.stage.addChild(Main.fpsVar);
	return;
}

function setText(text:String) {
	fpsText.text = text;
	for (outline in outlines)
		outline.text = text;
}