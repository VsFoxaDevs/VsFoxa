--[[
    Script by Tomongus#8871
    no credits needed actuallu it's completely free to use but credit if you want to!
]]--
camTwist = false;
function onEvent(name, value1, value2)
    if name == 'Camera Twist' then
        camTwist = true;
        intensity = value1;
        if intensity == '' then
            intensity = 0;
        end
        intensity2 = value2;
        if intensity2 == '' then
            intensity2 = 0;
        end
        if intensity2 == 0 then
            camTwist = false;
            doTweenAngle('camHUDstop', 'camHUD', 0, 1, 'sineInOut');
            doTweenAngle('camGamestop', 'camGame', 0, 1, 'sineInOut');
        end
    end
end
function onBeatHit()
    if curBeat % 1 == 0 then
        doTweenY('camHUDy', 'camHUD', -6 * intensity2, stepCrochet * 0.002, 'circInOut');
    end
    if curBeat % 1 == 2 then
        doTweenY('camHUDy', 'camHUD', 0, stepCrochet * 0.002, 'circInOut');
    end
    if camTwist then
        if curBeat % 2 == 0 then
            twistShit = 1;
        else
            twistShit = -1;
        end
        setProperty('camGame.angle', twistShit * intensity2);
        setProperty('camHUD.angle', twistShit * intensity2);
        doTweenAngle('camHUDleft', 'camHUD', twistShit * intensity, stepCrochet * 0.002, 'circInOut');
        doTweenAngle('camHUDright', 'camHUD', -twistShit * intensity, stepCrochet * 0.001, 'linear');
        doTweenAngle('camGameleft', 'camGame', twistShit * intensity, stepCrochet * 0.002, 'circInOut');
        doTweenAngle('camGameright', 'camGame', -twistShit * intensity, stepCrochet * 0.001, 'linear');
    end
end