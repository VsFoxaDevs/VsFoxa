package psychlua;

import flixel.group.FlxGroup;
import flixel.util.FlxSave;
import openfl.utils.Assets as OpenFlAssets;

class ScriptHandler
{
	public static var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	public static var globalVariables:Map<String, Dynamic> = new Map<String, Dynamic>();
	public static var resetVariables:Array<String> = [];

	#if LUA_ALLOWED
	public static var luaArray:Array<FunkinLua> = [];
	public static var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public static var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public static var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public static var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public static var modchartTexts:Map<String, FlxText> = new Map<String, FlxText>();
	public static var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	public static var modchartGroups:Map<String, FlxGroup> = new Map<String, FlxGroup>();
	// new shit!
	public static var modchartCameras:Map<String, FlxCamera> = new Map<String, FlxCamera>();
	#if VIDEOS_ALLOWED public static var modchartVideos:Map<String, FlxVideoSprite> = new Map<String, FlxVideoSprite>(); #end
	#end

	#if HSCRIPT_ALLOWED
	public static var hscriptArray:Array<HScript> = [];
	public static var instancesExclude:Array<String> = [];
	#end

	public static var camDebug:FlxCamera;
	public static var luaDebugGroup:FlxTypedGroup<DebugLuaText>;

	public static function startScripts() {
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		if(!FlxG.signals.preGameReset.has(resetGlobalVars)) FlxG.signals.preGameReset.add(resetGlobalVars);

		camDebug = new FlxCamera();
		camDebug.bgColor.alpha = 0;
		FlxG.cameras.add(camDebug, false);
		FlxG.cameras.cameraAdded.add(moveDebugCam);

		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.camera = camDebug;
		FlxG.state.add(luaDebugGroup);

		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'scripts/'))
			for (file in FileSystem.readDirectory(folder))
			{
				#if LUA_ALLOWED
				if(file.toLowerCase().endsWith('.lua'))
					new FunkinLua(folder + file);
				#end

				#if HSCRIPT_ALLOWED
				if(file.toLowerCase().endsWith('.hx'))
					initHScript(folder + file);
				#end
			}
		#end
		#end
	}

	static function resetGlobalVars() {
		for (tag in resetVariables) globalVariables.remove(tag);
		resetVariables = [];
	}

	static function moveDebugCam(cam:FlxCamera) {
		if (Std.isOfType(cam, backend.PsychCamera))
		{
			camDebug = new FlxCamera();
			camDebug.bgColor.alpha = 0;
			luaDebugGroup.camera = camDebug;
			FlxG.cameras.add(camDebug, false);
			return;
		}
		if (cam != camDebug && camDebug != null && @:privateAccess FlxG.game._nextState == null && FlxG.cameras.list.length > 1 && camDebug != FlxG.cameras.list[FlxG.cameras.list.length-1])
		{
			if(FlxG.cameras.list.contains(camDebug)) FlxG.cameras.remove(camDebug, false);
			FlxG.cameras.add(camDebug, false);
		}
	}

	public static function addTextToDebug(text:String, color:FlxColor) {
		if(luaDebugGroup == null) return;
		var newText:DebugLuaText = luaDebugGroup.recycle(DebugLuaText);
		newText.text = text;
		newText.color = color;
		newText.disableTime = 6;
		newText.alpha = 1;
		newText.setPosition(10, 8 - newText.height);

		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += newText.height + 2;
		});
		luaDebugGroup.add(newText);

		Sys.println(text);
	}

	public static function getLuaObject(tag:String, text:Bool = true):Dynamic {
		#if LUA_ALLOWED
		if(modchartSprites.exists(tag)) return modchartSprites.get(tag);
		if(text && modchartTexts.exists(tag)) return modchartTexts.get(tag);
		#if VIDEOS_ALLOWED
		if(modchartVideos.exists(tag)) return modchartVideos.get(tag);
		#end
		if(modchartCameras.exists(tag)) return modchartCameras.get(tag);
		if(modchartGroups.exists(tag)) return modchartGroups.get(tag);
		if(variables.exists(tag)) return variables.get(tag);
		#end
		return null;
	}

	public static function detatchFromTag(tag:String, text:Bool = true) {
		#if LUA_ALLOWED
		if(modchartSprites.exists(tag)) return modchartSprites.remove(tag);
		if(text && modchartTexts.exists(tag)) return modchartTexts.remove(tag);
		#if VIDEOS_ALLOWED
		if(modchartVideos.exists(tag)) return modchartVideos.remove(tag);
		#end
		if(modchartCameras.exists(tag)) return modchartCameras.remove(tag);
		if(modchartGroups.exists(tag)) return modchartGroups.remove(tag);
		if(variables.exists(tag)) return variables.remove(tag);
		#end
		return false;
	}

	#if LUA_ALLOWED
	public static function startLuasNamed(luaFile:String)
	{
		#if MODS_ALLOWED
		var luaToLoad:String = Paths.modFolders(luaFile);
		if(!FileSystem.exists(luaToLoad))
			luaToLoad = Paths.getSharedPath(luaFile);

		if(FileSystem.exists(luaToLoad))
		#elseif sys
		var luaToLoad:String = Paths.getSharedPath(luaFile);
		if(OpenFlAssets.exists(luaToLoad))
		#end
		{
			for (script in luaArray)
				if(script.scriptName == luaToLoad) return false;

			new FunkinLua(luaToLoad);
			return true;
		}
		return false;
	}
	#end

	#if HSCRIPT_ALLOWED
	public static function startHScriptsNamed(scriptFile:String)
	{
		#if MODS_ALLOWED
		var scriptToLoad:String = Paths.modFolders(scriptFile);
		if(!FileSystem.exists(scriptToLoad))
			scriptToLoad = Paths.getSharedPath(scriptFile);
		#else
		var scriptToLoad:String = Paths.getSharedPath(scriptFile);
		#end

		if(FileSystem.exists(scriptToLoad))
		{
			if (SScript.global.exists(scriptToLoad)) return false;

			initHScript(scriptToLoad);
			return true;
		}
		return false;
	}

	public static function initHScript(file:String)
	{
		try
		{
			var newScript:HScript = new HScript(null, file);
			if(newScript.parsingException != null)
			{
				addTextToDebug('ERROR ON LOADING: ${newScript.parsingException.message}', FlxColor.RED);
				newScript.destroy();
				return;
			}

			hscriptArray.push(newScript);
			if(newScript.exists('onCreate'))
			{
				var callValue = newScript.call('onCreate');
				if(!callValue.succeeded)
				{
					for (e in callValue.exceptions)
					{
						if (e != null)
						{
							var len:Int = e.message.indexOf('\n') + 1;
							if(len <= 0) len = e.message.length;
								addTextToDebug('ERROR ($file: onCreate) - ${e.message.substr(0, len)}', FlxColor.RED);
						}
					}

					newScript.destroy();
					hscriptArray.remove(newScript);
					trace('failed to initialize tea interp!!! ($file)');
				}
				else trace('initialized tea interp successfully: $file');
			}

		}
		catch(e)
		{
			var len:Int = e.message.indexOf('\n') + 1;
			if(len <= 0) len = e.message.length;
			addTextToDebug('ERROR - ' + e.message.substr(0, len), FlxColor.RED);
			var newScript:HScript = cast (SScript.global.get(file), HScript);
			if(newScript != null)
			{
				newScript.destroy();
				hscriptArray.remove(newScript);
			}
		}
	}
	#end

	public static function callOnScripts(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [FunkinLua.Function_Continue];

		var result:Dynamic = callOnLuas(funcToCall, args, ignoreStops, exclusions, excludeValues);
		if(result == null || excludeValues.contains(result)) result = callOnHScript(funcToCall, args, ignoreStops, exclusions, excludeValues);
		return result;
	}

	public static function callOnLuas(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [FunkinLua.Function_Continue];

		var arr:Array<FunkinLua> = [];
		for (script in luaArray)
		{
			if(script.closed)
			{
				arr.push(script);
				continue;
			}

			if(exclusions.contains(script.scriptName))
				continue;

			var myValue:Dynamic = script.call(funcToCall, args);
			if((myValue == FunkinLua.Function_StopLua || myValue == FunkinLua.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
			{
				returnVal = myValue;
				break;
			}

			if(myValue != null && !excludeValues.contains(myValue))
				returnVal = myValue;

			if(script.closed) arr.push(script);
		}

		if(arr.length > 0)
			for (script in arr)
				luaArray.remove(script);
		#end
		return returnVal;
	}

	public static function callOnHScript(funcToCall:String, args:Array<Dynamic> = null, ?ignoreStops:Bool = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;

		#if HSCRIPT_ALLOWED
		if(exclusions == null) exclusions = new Array();
		if(excludeValues == null) excludeValues = new Array();
		excludeValues.push(FunkinLua.Function_Continue);

		var len:Int = hscriptArray.length;
		if (len < 1)
			return returnVal;
		for(i in 0...len) {
			var script:HScript = hscriptArray[i];
			if(script == null || !script.exists(funcToCall) || exclusions.contains(script.origin))
				continue;

			var myValue:Dynamic = null;
			try {
				var callValue = script.call(funcToCall, args);
				if(!callValue.succeeded)
				{
					var e = callValue.exceptions[0];
					if(e != null)
					{
						var len:Int = e.message.indexOf('\n') + 1;
						if(len <= 0) len = e.message.length;
						addTextToDebug('ERROR (${callValue.calledFunction}) - ' + e.message.substr(0, len), FlxColor.RED);
					}
				}
				else
				{
					myValue = callValue.returnValue;
					if((myValue == FunkinLua.Function_StopHScript || myValue == FunkinLua.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
					{
						returnVal = myValue;
						break;
					}

					if(myValue != null && !excludeValues.contains(myValue))
						returnVal = myValue;
				}
			}
		}
		#end

		return returnVal;
	}

	public static function setOnScripts(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		if(exclusions == null) exclusions = [];
		setOnLuas(variable, arg, exclusions);
		setOnHScript(variable, arg, exclusions);
	}

	public static function setOnLuas(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			script.set(variable, arg);
		}
		#end
	}

	public static function setOnHScript(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if HSCRIPT_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in hscriptArray) {
			if(exclusions.contains(script.origin))
				continue;

			if(!instancesExclude.contains(variable))
				instancesExclude.push(variable);
			script.set(variable, arg);
		}
		#end
	}

	public static function destroyScripts()
	{
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		variables.clear();
		FlxG.cameras.cameraAdded.remove(moveDebugCam);

		#if LUA_ALLOWED
		#if VIDEOS_ALLOWED
		// They don't get destroyed on their own
		if(luaArray.length > 0)
			for (tag in modchartVideos.keys())
				luaArray[0].call('removeLuaVideo', [tag]);
		#end

		for (lua in luaArray)
		{
			lua.call('onDestroy', []);
			lua.stop();
		}

		luaArray = [];
		modchartTweens.clear();
		modchartSprites.clear();
		modchartTimers.clear();
		modchartSounds.clear();
		modchartTexts.clear();
		modchartSaves.clear();
		modchartGroups.clear();
		modchartCameras.clear();
		modchartVideos.clear();
		FunkinLua.customFunctions.clear();
		#end

		#if HSCRIPT_ALLOWED
		for (script in hscriptArray)
			if (script != null) {
				script.call('onDestroy');
				script.destroy();
			}

		hscriptArray = [];
		instancesExclude = [];
		#end
		#end
	}
}