package psychlua;

import flixel.FlxObject;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;

final packageMap:Map<String, String> = [
	'CustomState' => 'psychlua.',

	'FlashingState' => 'states.',
	'TitleState' => 'states.',
	'OutdatedState' => 'states.',
	'MainMenuState' => 'states.',
	'StoryMenuState' => 'states.',
	'PlayState' => 'states.',
	'FreeplayState' => 'states.',
	'ModsMenuState' => 'states.',
	'CreditsState' => 'states.',
	'AchievementsMenuState' => 'states.',

	'OptionsState' => 'options.',
	'NoteOffsetState' => 'options.',

	'CharacterEditorState' => 'states.editors.',
	'ChartingState' => 'states.editors.',
	'DialogueCharacterEditorState' => 'states.editors.',
	'MasterEditorMenu' => 'states.editors.',
	'MenuCharacterEditorState' => 'states.editors.',
	'NoteSplashDebugState' => 'states.editors.',
	'WeekEditorState' => 'states.editors.'
];

class CustomState extends MusicBeatState
{
	public static var name:String = 'unnamed';
	public static var newName:Bool = false;
	public static var instance:CustomState;

	#if LUA_ALLOWED
	public static function implement(funk:FunkinLua)
	{
		var lua:State = funk.lua;
		Lua_helper.add_callback(lua, "switchState", function(name:String, ?args:Array<Dynamic> = null, ?load:Bool = false, ?stopMusic:Bool = false) {
			if (args == null) args = [];
			if (!name.contains('.') && packageMap.get(name) != null)
				name = packageMap.get(name) + name;

			var state:FlxState = Type.createInstance(Type.resolveClass(name), args);

			if(state != null) {
				if(load) {
					LoadingState.loadAndSwitchState(() -> state, stopMusic);
				} else {
					if (stopMusic) FlxG.sound.music.stop();
					FlxG.switchState(() -> state);
				}
			} else {
				FunkinLua.luaTrace('switchState: State "$name" doesn\'t exist!', false, false, FlxColor.RED);
			}
		});
		Lua_helper.add_callback(lua, "setSkipTransition", function(skipIn:Null<Bool>, skipOut:Null<Bool>) {
			if(skipIn != null) FlxTransitionableState.skipNextTransIn = skipIn;
			if(skipOut != null) FlxTransitionableState.skipNextTransOut = skipOut;
		});
		Lua_helper.add_callback(lua, "resetState", function() {
			FlxG.resetState();
		});
        Lua_helper.add_callback(lua, "clearStoredMemory", function() {
			Paths.clearStoredMemory();
		});
		Lua_helper.add_callback(lua, "clearStoredMemory", function() {
			Paths.clearStoredMemory();
		});
		Lua_helper.add_callback(lua, "clearUnusedMemory", function() {
			Paths.clearUnusedMemory();
		});
	}
	#end

	override function create()
	{
		instance = this;
		newName = false;

		persistentUpdate = persistentDraw = true;
		initPsychCamera();

		psychlua.ScriptHandler.startScripts();
		#if LUA_ALLOWED psychlua.ScriptHandler.startLuasNamed('states/$name.lua'); #end
		#if HSCRIPT_ALLOWED psychlua.ScriptHandler.startLuasNamed('states/$name.hx'); #end

		super.create();
		psychlua.ScriptHandler.callOnScripts('onCreatePost');
	}

	public function new(name:String)
	{
		CustomState.name = name;
		newName = true;
		super();
	}

	override function update(elapsed:Float)
	{
		psychlua.ScriptHandler.callOnScripts('onUpdate', [elapsed]);
		super.update(elapsed);
		psychlua.ScriptHandler.callOnScripts('onUpdatePost', [elapsed]);
	}

	override function destroy()
	{
		psychlua.ScriptHandler.destroyScripts();
		if(!newName) name = 'unnamed';

		super.destroy();
	}
}