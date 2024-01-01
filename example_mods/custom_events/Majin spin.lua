local spinCount = 0
local spinWow = 0

local called = false

function onEvent(name)
    if name == 'Majin spin' then
        if called == false then
            called = true
            spinCount = spinCount + 1
        end
    end
end
function onUpdate()
    called = false
    if spinWow ~= spinCount then
        for spinNotes = 0,7 do
            noteTweenAngle('wowSpin'..spinNotes,spinNotes,360 * spinCount,0.35,'quartOut')
            spinWow = spinCount
        end
    end
end
function onTweenCompleted(tag)
    for notesLength = 0,7 do
        if tag == 'wowSpin'..notesLength then
            spinCount = 0
            spinWow = 0
            setPropertyFromGroup('strumLineNotes', notesLength,'angle',0)
        end
    end
end