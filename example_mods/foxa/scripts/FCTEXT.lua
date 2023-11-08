function onCreate()
    makeLuaText('fctext', 'Full Combo!!', 500, 0, 540)
    setTextAlignment('fctext', 'center')
    setTextSize('fctext', 25)
    screenCenter('fctext', 'x')
    addLuaText('fctext')
end

if disableFCTxt == false then
    if misses >= 1 then
        removeLuaText('fctext', true)
    end
end