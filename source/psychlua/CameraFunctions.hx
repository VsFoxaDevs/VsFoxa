package psychlua;

class CameraFunctions
{
	public static function implement(funk:FunkinLua)
	{
		var lua = funk.lua;
		Lua_helper.add_callback(lua, "makeLuaCamera", function(tag:String, ?x:Float, ?y:Float, ?width:Int, ?height:Int, ?zoom:Float) {
			tag = tag.replace('.', '');
			LuaUtils.resetTag(tag, psychlua.ScriptHandler.modchartCameras);
			var newCam:FlxCamera = new FlxCamera(x, y, width, height, zoom);
			newCam.bgColor.alpha = 0;
			psychlua.ScriptHandler.modchartCameras.set(tag, newCam);
		});


		Lua_helper.add_callback(lua, "addLuaCamera", function(tag:String, defaultDraw:Bool = false) {
			if(psychlua.ScriptHandler.modchartCameras.exists(tag)) {
				var shit:FlxCamera = psychlua.ScriptHandler.modchartCameras.get(tag);
				FlxG.cameras.add(shit, defaultDraw);
			}
		});
		Lua_helper.add_callback(lua, "removeLuaCamera", function(tag:String, destroy:Bool = true) {
			if(!psychlua.ScriptHandler.modchartCameras.exists(tag)) {
				return;
			}

			var pee:FlxCamera = psychlua.ScriptHandler.modchartCameras.get(tag);
			if(destroy) pee.kill();

			FlxG.cameras.remove(pee, false);
			if(destroy) {
				pee.destroy();
				psychlua.ScriptHandler.modchartCameras.remove(tag);
			}
		});

		Lua_helper.add_callback(lua, "getCameraOrder", function(camera:String) {
			var cam:FlxCamera = LuaUtils.cameraFromString(camera);
			if(cam != null) return FlxG.cameras.list.indexOf(cam);
			FunkinLua.luaTrace("getCameraOrder: Default camera doesn't exist!", false, false, FlxColor.RED);
			return -1;
		});
		Lua_helper.add_callback(lua, "setCameraOrder", function(camera:String, position:Int) {
			var cam:FlxCamera = LuaUtils.cameraFromString(camera);
			if(cam != null) {
				if(FlxG.cameras.list.contains(cam)){
					var list:Array<FlxCamera> = FlxG.cameras.list.copy();
					var defaults:Array<FlxCamera> = @:privateAccess FlxG.cameras.defaults.copy();

					for(flxCam in list) FlxG.cameras.remove(flxCam, false);

					list.remove(cam);
					list.insert(position, cam);

					for(flxCam in list){
						var defaultDraw = defaults.contains(flxCam);
						FlxG.cameras.add(flxCam, defaultDraw);
					}

					return;
				}else{
					FunkinLua.luaTrace('setCameraOrder: Camera $camera isn\'t in the list yet! Use "addLuaCamera($camera)" first', false, false, FlxColor.RED);
				}
			}
			FunkinLua.luaTrace("setCameraOrder: Default camera doesn't exist!", false, false, FlxColor.RED);
		});

		Lua_helper.add_callback(lua, "cameraShake", function(camera:String, ?intensity:Float, ?duration:Float) {
			LuaUtils.cameraFromString(camera).shake(intensity, duration);
		});
		Lua_helper.add_callback(lua, "cameraFlash", function(camera:String, ?color:String, ?duration:Float, ?forced:Bool) {
			LuaUtils.cameraFromString(camera).flash(CoolUtil.colorFromString(color), duration, null, forced);
		});
		Lua_helper.add_callback(lua, "cameraFade", function(camera:String, ?color:String, ?duration:Float, ?fadeIn:Bool, ?forced:Bool) {
			LuaUtils.cameraFromString(camera).fade(CoolUtil.colorFromString(color), duration, fadeIn, null, forced);
		});
	}
}