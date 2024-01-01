function onEvent(name,value1,value2) -- value1 is amount, value2 is duration, wow!
    if name == "CameraZoom" then
        doTweenZoom('in','camGame',tonumber(value1),tonumber(value2),'sineInOut')
    end
end

function onTweenCompleted(name)
    if name == 'in' then
         setProperty("defaultCamZoom",getProperty('camGame.zoom')) 
    end
end