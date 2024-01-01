function onStepHit()
    Particle()
  end
    f = 1
  
    function Particle()
    songPos = getSongPosition()
    currentBeat = (songPos/500)
      f = f + 1
      sus = math.random(2, 1500)
      sus2 = math.random(2, 1500)
      makeLuaSprite('part' .. f, 'particles', math.random(500, 2000), 1600)
      doTweenY(sus, 'part' .. f, -900*math.tan((currentBeat+1*0.1)*math.pi), 6)
      doTweenX(sus2, 'part' .. f, -900*math.sin((currentBeat+1*0.1)*math.pi), 6)
      scaleObject('part' .. f, 0.5, 0.5);
      
      addLuaSprite('part' .. f, true)
  
      if f >= 50 then
      f = 1
      end
    end