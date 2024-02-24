package states;

import cppthing.WindowsData;
import backend.WeekData;
import backend.Highscore;
#if BUTTPLUG_ALLOWED import backend.ButtplugUtils; #end
import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import states.StoryMenuState;

class StartingState extends MusicBeatState {
    public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	override public function create():Void {
		Paths.clearStoredMemory();
        
        #if BUTTPLUG_ALLOWED _setupButtPlug(100); #end

		// FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

        _loadShits();

		FlxG.mouse.visible = false;

        if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.switchState(() -> new FlashingState());
		} else {
            FlxG.switchState(() -> new TitleState());
        }
	}

	public function _loadShits() {
		_setupMods();

		FlxG.save.bind(#if STORY_EDITION 'vsfoxastory' #else 'vsfoxav3' #end, CoolUtil.getSavePath());
		ClientPrefs.loadPrefs();

		/* 
			you stupid
			no im not
			whats 9 + 10
			21
			you stupid
		*/

		// Highscore.load(); 

		if (FlxG.save.data != null && ClientPrefs.data.fullscreen) FlxG.fullscreen = ClientPrefs.data.fullscreen;
		if (FlxG.save.data.weekCompleted != null) states.StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		if (FlxG.save.data.unlockedCharacters == null) FlxG.save.data.unlockedCharacters = ["Boyfriend", "Foxa (Lesson)"];
		if (FlxG.save.data.weekCompleted != null) StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
	}

	public function _setupMods() {
		#if LUA_ALLOWED Mods.pushGlobalMods(); #end
		Mods.loadTopMod();
	}

	#if BUTTPLUG_ALLOWED public function _setupButtPlug(intensity:Int = 100) {
		ButtplugUtils.set_intensity(intensity);
		ButtplugUtils.initialise();
	}#end
}
