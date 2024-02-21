package psychlua;

import substates.GameOverSubstate;

class VideoFunctions
{
	public static function implement(funk:FunkinLua)
	{
		var lua = funk.lua;
		Lua_helper.add_callback(lua, "makeLuaVideo", function(tag:String, x:Int = 0, y:Int = 0) {
			tag = tag.replace('.', '');
			LuaUtils.resetVideoTag(tag);
			var leVid:FlxVideoSprite = new FlxVideoSprite(x, y);
			leVid.antialiasing = ClientPrefs.data.antialiasing;
			psychlua.ScriptHandler.modchartVideos.set(tag, leVid);
			leVid.active = true;
		});
		Lua_helper.add_callback(lua, "addLuaVideo", function(tag:String, front:Bool = false) {
			if(psychlua.ScriptHandler.modchartVideos.exists(tag)) {
				var shit:FlxVideoSprite = psychlua.ScriptHandler.modchartVideos.get(tag);

				if(front || LuaUtils.getTargetInstance().members.length == 0)
					LuaUtils.getTargetInstance().add(shit);
				else
				{
					if(FlxG.state == PlayState.instance)
						if(!PlayState.instance.isDead)
							FlxG.state.insert(PlayState.instance.members.indexOf(LuaUtils.getLowestCharacterGroup()), shit);
						else
							GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), shit);
					else
						LuaUtils.getTargetInstance().insert(LuaUtils.getTargetInstance().members.length, shit);
				}
			}
		});
		Lua_helper.add_callback(lua, "removeLuaVideo", function(tag:String, destroy:Bool = true) {
			if(!psychlua.ScriptHandler.modchartVideos.exists(tag)) {
				return;
			}

			var pee:FlxVideoSprite = psychlua.ScriptHandler.modchartVideos.get(tag);
			if(destroy) {
				pee.kill();
			}

			LuaUtils.getTargetInstance().remove(pee, true);
			pee.stop();
			if(destroy) {
				pee.destroy();
				psychlua.ScriptHandler.modchartVideos.remove(tag);
			}
		});

		Lua_helper.add_callback(lua, "playLuaVideo", function(tag:String, path:String, loop:Bool = false) {
			if(psychlua.ScriptHandler.modchartVideos.exists(tag)) {
				var vid:FlxVideoSprite = psychlua.ScriptHandler.modchartVideos.get(tag);
				if(path != null && path.length > 0) {
					vid.load(Paths.video(path));
					vid.play();
				}

				vid.bitmap.onOpening.add(function() {
					psychlua.ScriptHandler.callOnLuas('onVideoOpening', [tag]);
				}, true);
				vid.bitmap.onPlaying.add(function() {
					psychlua.ScriptHandler.callOnLuas('onVideoPlaying', [tag]);
				}, true);
				vid.bitmap.onStopped.add(function() {
					psychlua.ScriptHandler.callOnLuas('onVideoStopped', [tag]);
				}, true);
				vid.bitmap.onPaused.add(function() {
					psychlua.ScriptHandler.callOnLuas('onVideoPaused', [tag]);
				}, true);
				vid.bitmap.onEndReached.add(function() {
					psychlua.ScriptHandler.callOnLuas('onVideoEnd', [tag]);
				}, true);
				/*vid.bitmap.onEncounteredError.add(function() {
					psychlua.ScriptHandler.callOnLuas('onVideoError', [tag]);
				}, true);*/
			}
		});
		Lua_helper.add_callback(lua, "stopLuaVideo", function(tag:String) {
			if(psychlua.ScriptHandler.modchartVideos.exists(tag)) {
				var vid:FlxVideoSprite = psychlua.ScriptHandler.modchartVideos.get(tag);
				vid.stop();
			}
		});
		Lua_helper.add_callback(lua, "pauseLuaVideo", function(tag:String) {
			if(psychlua.ScriptHandler.modchartVideos.exists(tag)) {
				var vid:FlxVideoSprite = psychlua.ScriptHandler.modchartVideos.get(tag);
				vid.pause();
			}
		});
		Lua_helper.add_callback(lua, "resumeLuaVideo", function(tag:String) {
			if(psychlua.ScriptHandler.modchartVideos.exists(tag)) {
				var vid:FlxVideoSprite = psychlua.ScriptHandler.modchartVideos.get(tag);
				vid.resume();
			}
		});

		Lua_helper.add_callback(lua, "getVideoTime", function(tag:String) {
			if(tag != null && tag.length > 0 && psychlua.ScriptHandler.modchartVideos.exists(tag)) {
				return psychlua.ScriptHandler.modchartVideos.get(tag).bitmap.time;
			}
			return 0;
		});
		Lua_helper.add_callback(lua, "setVideoTime", function(tag:String, value:Int) {
			if(tag != null && tag.length > 0 && psychlua.ScriptHandler.modchartSounds.exists(tag)) {
				var vid:FlxVideoSprite = psychlua.ScriptHandler.modchartVideos.get(tag);
				if(vid != null) {
					var wasResumed:Bool = vid.bitmap.isPlaying;
					vid.pause();
					vid.bitmap.time = value;
					if(wasResumed) vid.resume();
				}
			}
		});
	}
}