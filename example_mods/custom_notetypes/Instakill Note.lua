function onCreate()
    for i = 0, getProperty('unspawnNotes.length') - 1 do
        local noteType = getPropertyFromGroup('unspawnNotes', i, 'noteType')
        
        if noteType == 'Instakill Note' then
            setPropertyFromGroup('unspawnNotes', i, 'texture', 'KILLNOTE_assets')
            
            if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
                setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true)
            end
        end
    end
end

function goodNoteHit(id, _, noteType, _)
    if noteType == 'Instakill Note' then
        setProperty('health', -500)
    end
end