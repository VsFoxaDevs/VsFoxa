local allowCountdown = false;
local playDialogue = true;
function onStartCountdown()
	-- Block the first countdown and start a timer of 0.8 seconds to play the dialogue
	if not allowCountdown and not seenCutscene then
		allowCountdown = true;
		setProperty('inCutscene', true);
		runTimer('startDialogue', 0.8);
		playDialogue = false;
		return Function_Stop;
	end
	return Function_Continue;
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'startDialogue' then -- Timer completed, play dialogue
		startDialogue('dialogue', 'city-streets');
	end
end