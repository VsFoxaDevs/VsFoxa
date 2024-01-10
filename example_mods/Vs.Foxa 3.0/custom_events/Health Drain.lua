function onEvent(name, value1, value2)
    if name == 'Health Drain' then
        function opponentNoteHit(id, noteData, noteType, isSustainNote)
            local currentHealth = getProperty('health')
            
            if currentHealth > (value2 / 50) and currentHealth < (value1 / 50) then
                setProperty('health', (value2 / 50))
            elseif currentHealth > (value2 / 50) and currentHealth > (value1 / 50) then
                setProperty('health', currentHealth - (value1 / 50))
            end
        end
    end
end
