function onCreate()
	makeLuaText('lyric','',screenWidth,0,screenHeight/2);
--	setTextFont('lyric','PUSAB.otf');
--	setTextBorder('lyric',5,'ffffff');
	setTextSize('lyric',40);
	setTextAlignment('lyric','center');
	setObjectCamera('lyric', 'other')
	addLuaText('lyric');
end

function onEvent(name, value1, value2)
if value2 ~= '' then
color, ssize = value2:match("([^,]+),([^,]+)")

size = ssize:gsub(" ","")
end
	if name == 'lyrics' then
		doTweenY('lyricmovething', 'lyric', screenHeight/2-size, 0.001 ,'linear')
		setTextString('lyric', value1)
		if color == '' and size == '' then
			setTextColor('lyric', 'ffffff')
			setTextSize('lyric', 40);
		else 
			setTextColor('lyric', color)
			setTextSize('lyric', size);
		end
	
		
		print('Event triggered: ', name, value1, value2);
	end
end