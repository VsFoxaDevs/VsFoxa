scoreName = "Score"
missesName = "Misses"
ratingNames = "Rating"
function onCreate()
    makeLuaText('cornerMark', ('FNF Vs. Foxa 3.0'), 1275, 0, 5)
  setTextAlignment('cornerMark', 'RIGHT')
  setTextSize('cornerMark', 18)
  if not getPropertyFromClass('backend.ClientPrefs', 'data.hideHud') then 
  addLuaText('cornerMark') 
end
end
function onUpdate()
    if not getProperty('ratingName') == '?' then
        setProperty('scoreTxt.text', scoreName .. ': ' .. getProperty('songScore') .. ' // ' .. missesName .. ': ' .. getProperty('songMisses') .. ' //  Accuracy: ' .. floorInDecimal(rating*100, 2) .. ' // ' .. ratingNames .. ': ' .. getProperty('ratingName') .. ' (' .. round(getProperty('ratingPercent') * 100, 2) .. '%) - ' .. getProperty('ratingFC'))
    end
    if getProperty('ratingName') == '?' then
        setProperty('scoreTxt.text', scoreName .. ': ' .. getProperty('songScore') .. ' // ' .. missesName .. ': ' .. getProperty('songMisses') .. ' // Accurarcy: ? // ' .. ratingNames .. ': ' .. getProperty('ratingName'))
    end
end
function round(x, n) --https://stackoverflow.com/questions/18313171/lua-rounding-numbers-and-then-truncate
    n = math.pow(10, n or 0)
    x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
end
function math.lerp(a,b,t)
    return(b-a) * t + a;
end
function math.remapToRange(value,start1,stop1,start2,stop2)
    return start2 + (stop2 - start2) * ((value - start1)/(stop1 - start1))
end
function floorInDecimal(number, decimals)
    return math.floor(number * (10^decimals)) / (10^decimals)
end
