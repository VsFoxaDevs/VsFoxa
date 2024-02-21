package backend;

#if android
import android.flixel.FlxVirtualPad;
import flixel.input.actions.FlxActionInput;
import flixel.util.FlxDestroyUtil;
#end
import flixel.FlxSubState;

class MusicBeatSubstate extends FlxSubState
{
	public function new()
	{
		super();
	}

	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return Controls.instance;

	override function create()
	{
		// Moves debug group to front of this substate
		if (psychlua.ScriptHandler.luaDebugGroup != null)
		{
			FlxG.state.remove(psychlua.ScriptHandler.luaDebugGroup);
			add(psychlua.ScriptHandler.luaDebugGroup);
		}

		super.create();
	}

	override function update(elapsed:Float)
	{
		//everyStep();
		if(!persistentUpdate) MusicBeatState.timePassedOnState += elapsed;
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if(curStep > 0)
				stepHit();

			if(PlayState.SONG != null)
			{
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
			}
		}

		super.update(elapsed);
	}

	#if android
	var virtualPad:FlxVirtualPad;
	var trackedinputsUI:Array<FlxActionInput> = [];

	public function addVirtualPad(DPad:FlxDPadMode, Action:FlxActionMode){
		virtualPad = new FlxVirtualPad(DPad, Action);
		add(virtualPad);

		controls.setVirtualPadUI(virtualPad, DPad, Action);
		trackedinputsUI = controls.trackedinputsUI;
		controls.trackedinputsUI = [];
	}

	public function removeVirtualPad(){
		if(trackedinputsUI != []) controls.removeFlxInput(trackedinputsUI);
		if(virtualPad != null) remove(virtualPad);
	}

	public function addPadCamera(){
		if(virtualPad != null){
			var camControls = new flixel.FlxCamera();
			FlxG.cameras.add(camControls, false);
			camControls.bgColor.alpha = 0;
			virtualPad.cameras = [camControls];
		}
	}
	#end

	private function updateSection():Void
	{
		if(stepsToDo < 1) stepsToDo = Math.round(getBeatsOnSection() * 4);
		while(curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	private function rollbackSection():Void
	{
		if(curStep < 0) return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if(stepsToDo > curStep) break;
				
				curSection++;
			}
		}

		if(curSection > lastSection) sectionHit();
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep/4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - ClientPrefs.data.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();

		if (!FlxG.state.persistentUpdate) // Prevents scripts from being called twice
		{
			psychlua.ScriptHandler.setOnScripts('curStep', curStep);
			psychlua.ScriptHandler.callOnScripts('onStepHit');
		}
	}

	public function beatHit():Void
	{
		if (!FlxG.state.persistentUpdate)
		{
			psychlua.ScriptHandler.setOnScripts('curBeat', curBeat);
			psychlua.ScriptHandler.callOnScripts('onBeatHit');
		}
	}

	public function sectionHit():Void
	{
		if (!FlxG.state.persistentUpdate)
		{
			psychlua.ScriptHandler.setOnScripts('curSection', curSection);
			psychlua.ScriptHandler.callOnScripts('onSectionHit');
		}
	}
	
	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if(PlayState.SONG != null && PlayState.SONG.notes[curSection] != null) val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}

	override function destroy()
	{
		// Moves debug group back to original state
		if (psychlua.ScriptHandler.luaDebugGroup != null)
		{
			remove(psychlua.ScriptHandler.luaDebugGroup);
			FlxG.state.add(psychlua.ScriptHandler.luaDebugGroup);
		}

		super.destroy();
	}
}
