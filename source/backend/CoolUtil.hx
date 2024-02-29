package backend;

import flixel.FlxBasic;
import flixel.FlxObject;
//import flixel.util.FlxSave;

//import flixel.math.FlxPoint;

import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

enum SlideCalcMethod
{
	SIN;
	COS;
}

class CoolUtil
{
	public static function makeOutlinedGraphic(Width:Int, Height:Int, Color:Int, LineThickness:Int, OutlineColor:Int){
		var rectangle = flixel.graphics.FlxGraphic.fromRectangle(Width, Height, OutlineColor, true);
		rectangle.bitmap.fillRect(new openfl.geom.Rectangle(LineThickness, LineThickness, Width - LineThickness * 2, Height - LineThickness * 2), Color);
		return rectangle;
	};

	inline public static function scale(x:Float, l1:Float, h1:Float, l2:Float, h2:Float):Float
		return ((x - l1) * (h2 - l2) / (h1 - l1) + l2);

	inline public static function clamp(n:Float, l:Float, h:Float) {
		if(n > h) n = h;
		if(n < l) n = l;
		return n;
	}

		
	inline public static function quantize(f:Float, snap:Float){
		// changed so this actually works lol
		final m:Float = Math.fround(f * snap);
		#if debug trace(snap); #end
		return (m / snap);
	}

	public static function rotate(x:Float, y:Float, angle:Float, ?point:FlxPoint):FlxPoint
	{
		var p = point == null ? FlxPoint.weak() : point;
		return p.set((x * Math.cos(angle)) - (y * Math.sin(angle)), (x * Math.sin(angle)) + (y * Math.cos(angle)));
	}
	
	inline public static function quantizeAlpha(f:Float, interval:Float)
		return Std.int((f+interval/2)/interval)*interval;

	inline public static function capitalize(text:String)
		return text.charAt(0).toUpperCase() + text.substr(1).toLowerCase();

	inline public static function boundTo(value:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, value));
	}

	inline public static function coolTextFile(path:String):Array<String>
	{
		var daList:String = null;
		#if (sys && MODS_ALLOWED)
		var formatted:Array<String> = path.split(':'); //prevent "shared:", "preload:" and other library names on file path
		path = formatted[formatted.length-1];
		if(FileSystem.exists(path)) daList = File.getContent(path);
		#else
		if(Assets.exists(path)) daList = Assets.getText(path);
		#end
		return daList == null ? [] : listFromString(daList);
	}

	inline public static function colorFromString(color:String):FlxColor
	{
		var hideChars = ~/[\t\n\r]/;
		var color:String = hideChars.split(color).join('').trim();
		if(color.startsWith('0x')) color = color.substring(color.length - 6);

		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		if(colorNum == null) colorNum = FlxColor.fromString('#$color');
		return colorNum != null ? colorNum : FlxColor.WHITE;
	}

	inline public static function colorFromArray(colors:Array<Int>, ?defColors:Array<Int>) {
		colors = fixRGBColorArray(colors, defColors);
		return FlxColor.fromRGB(colors[0], colors[1], colors[2], colors[3]);
	}

	inline public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = string.trim().split('\n');
		for (i in 0...daList.length) daList[i] = daList[i].trim();
		return daList;
	}

	public static function formatMemory(num:UInt):String {
		var size:Float = num;
		var data = 0;
		var dataTexts = ["B", "KB", "MB", "GB", "TB"];
		while (size > 1024 && data < dataTexts.length - 1) {
			data++;
			size = size / 1024;
		}

		size = Math.round(size * 100) / 100;
		var formatSize:String = formatAccuracy(size);
		return formatSize + " " + dataTexts[data];
	}

	inline public static function removeFromString(remove:String = "", string:String = "")
		return string.replace(remove, "");
	
	public static function removeDuplicates(string:Array<String>):Array<String> {
		var tempArray:Array<String> = new Array<String>();
		var lastSeen:String = null;
		string.sort(function(str1:String, str2:String) {
		  return (str1 == str2) ? 0 : (str1 > str2) ? 1 : -1; 
		});
		for (str in string) {
		  if (str != lastSeen) {
			tempArray.push(str);
		  }
		  lastSeen = str;
		}
		return tempArray;
	}

	public static function floorDecimal(value:Float, decimals:Int):Float
	{
		if(decimals < 1) return Math.floor(value);

		var tempMult:Float = 1;
		for (i in 0...decimals) tempMult *= 10;

		final newValue:Float = Math.floor(value * tempMult);
		return newValue / tempMult;
	}
	
	inline public static function fixRGBColorArray(colors:Array<Int>, ?defColors:Array<Int>) {
		// helper function used on characters n such
		final endResult:Array<Int> = (defColors != null && defColors.length > 2) ? defColors : [255, 255, 255, 255]; // Red, Green, Blue, Alpha
		for (i in 0...endResult.length) if (colors[i] > -1) endResult[i] = colors[i];
		return endResult;
	}

	/**
	 * Pablooooooo
	 * @param amplitude 
	 * @param calcMethod 
	 * @param slowness 
	 * @param delayIndex 
	 * @param offset 
	 * @return Float
	 */
	public static function slideEffect(amplitude:Float, calcMethod:SlideCalcMethod, slowness:Float = 1, delayIndex:Float = 0, ?offset:Float):Float
	{
		if (slowness < 0) slowness = 1;
		var slider:Float = (FlxG.sound.music.time / 1000) * (Conductor.bpm / 60);

		var slideValue:Float;

		switch (calcMethod) {
			case SIN: slideValue = offset + amplitude * Math.sin(((slider + delayIndex) / slowness) * Math.PI);
			case COS: slideValue = offset + amplitude * Math.cos(((slider + delayIndex) / slowness) * Math.PI);
		}

		return slideValue;
	}

	inline public static function GCD(a, b)
		return b == 0 ? FlxMath.absInt(a) : GCD(b, a % b);

	inline public static function closest2Multiple(num:Float)
		return Math.floor(num/2)*2;

	public static function addZeros(v:String, length:Int, end:Bool = false) {
		var r = v;
		while(r.length < length)
			r = end ? r + '0': '0$r';
		return r;
	}

	public static function objectCenter(object:FlxObject, target:FlxObject, axis:FlxAxes = XY) {
		if (axis == XY || axis == X) object.x = target.x + target.width / 2 - object.width / 2;
		if (axis == XY || axis == Y) object.y = target.y + target.height / 2 - object.height / 2;
	}

	inline public static function dominantColor(sprite:flixel.FlxSprite):Int {
		final countByColor:Map<Int, Int> = [];
		for(col in 0...sprite.frameWidth) {
			for(row in 0...sprite.frameHeight) {
				final colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
				if(colorOfThisPixel != 0) {
					if(countByColor.exists(colorOfThisPixel)) countByColor[colorOfThisPixel] = countByColor[colorOfThisPixel] + 1;
					else if(countByColor[colorOfThisPixel] != 13520687 - (2*13520687)) countByColor[colorOfThisPixel] = 1;
				}
			}
		}

		var maxCount = 0;
		var maxKey:Int = 0; //after the loop this will store the max color
		countByColor[FlxColor.BLACK] = 0;
		for(key in countByColor.keys()) {
			if(countByColor[key] >= maxCount) {
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		countByColor.clear();
		return maxKey;
	}

	inline public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max) dumbArray.push(i);

		return dumbArray;
	}

	public static function setTextBorderFromString(text:FlxText, border:String) {
		text.borderStyle = switch(border.toLowerCase().trim())
		{
			case 'shadow': SHADOW;
			case 'outline': OUTLINE;
			case 'outline_fast', 'outlinefast': OUTLINE_FAST;
			default: NONE;
		}
	}

	public static function browserLoad(site:String) {
		#if linux Sys.command('/usr/bin/xdg-open', [site]); #else FlxG.openURL(site); #end
	}

	inline public static function openFolder(folder:String, absolute:Bool = false) {
		#if sys
			if(!absolute) folder =  Sys.getCwd() + '$folder';

			folder = folder.replace('/', '\\');
			if(folder.endsWith('/')) folder.substr(0, folder.length - 1);

			final command:String = #if linux '/usr/bin/xdg-open' #else 'explorer.exe' #end;
			
			Sys.command(command, [folder]);
			trace('$command $folder');
		#else
			FlxG.error("Platform is not supported for CoolUtil.openFolder");
		#end
	}

	inline public static function sortByID(i:Int, basic1:FlxBasic, basic2:FlxBasic):Int {
		return basic1.ID > basic2.ID ? -i : basic2.ID > basic1.ID ? i : 0;
	}

	/**
		Helper Function to Fix Save Files for Flixel 5
		-- EDIT: [November 29, 2023] --
		this function is used to get the save path, period.
		since newer flixel versions are being enforced anyways.
		@crowplexus
	**/
	@:access(flixel.util.FlxSave.validate)
	inline public static function getSavePath():String {
		final company:String = FlxG.stage.application.meta.get('company');
		// #if (flixel < "5.0.0") return company; #else
		return '${company}/${flixel.util.FlxSave.validate(FlxG.stage.application.meta.get('file'))}';
		// #end
	}
}
