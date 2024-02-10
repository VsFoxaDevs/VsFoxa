package states;

import objects.AttachedSprite;

class CreditsState extends MusicBeatState {
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:FlxColor;
	var colorTween:FlxTween;
	var descBox:AttachedSprite;

	var offsetThing:Float = -75;

	override function create() {
		#if desktop DiscordClient.changePresence("Credits Menu", null); #end // Updating Discord Rich Presence 

		persistentUpdate = true;

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		grid.alpha = 0;
		FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(grid);
		
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		#if MODS_ALLOWED for (mod in Mods.parseList().enabled) pushModCreditsToList(mod); #end

		var defaultList:Array<Array<String>> = [ //Name - Icon name - Description - Link (Optional) - BG Color
			['Vs. Foxa Devs'],
			['Foxa The Artist',				'foxa',					'Director of Vs. Foxa\nDid most of the stuff for this mod',		 'https://www.youtube.com/channel/UCu0cMjmyVBgUXSieMwbqyjA',									 'EEABFC'],
			['Dark',				'dark',					'Charter\nDialogue Writer and Story Helper',		 'https://steamcommunity.com/id/DarknessLight1/',									 'AA00FF'],
			['CharlesCatYT',				'venusian',					'Engine Coder,\nAssistant Composer and Artist(?)',		 'https://gamebanana.com/members/2020512',									 'F3FF4A'],
			[''],
			['Vs. Foxa Contributors'],
			//['TheAnimateMan',				'animate',					'Trolled Foxa Sprites',		 'https://www.youtube.com/channel/UCwsHVR5zkvnW4U4-Uoh118w',									 'A1A1A1'],
			//['MusicBoxMan',				'face',					'Composer(?)',		 '',									 'A1A1A1'],
			//['eeveelover64',				'eeveelover',					'Supporter',		 'https://www.youtube.com/channel/UCh17ETeneDIuQD5NndCHpfA',									 'A1A1A1'],
			['GarageBandCoverGuy96',				'gbcg',					'Menu Music & Ex-Composer\n(Icon will be added later)',		 'https://www.youtube.com/channel/UCspMkVJ4GiIENSgKcoNBZYQ',									 'A1A1A1'],
			//['SugarRatio',				'sugarratio',					'Made Denotator',		 'https://twitter.com/SugarRatio',									 'A1A1A1'],
			['GsDrunkestDriver',				'gsdd',			'Buttplug Support\n(Icon will be added later)',											 'https://github.com/GsDrunkestDriver',		 'A1A1A1'],
			[''],
			['Former Foxa Mod Devs'],
			['JoerOnTheBlower',				'joer',					'Ex-Director of Vs. Foxa\nI don\'t support them.',		 '',									 'A1A1A1'],
			['FellowIdiot',				'fbiguy',					'Ex-Programmer of Vs. Foxa\n(Icon will be added later)',		 'https://twitter.com/YFIdiot',									 'A1A1A1'],
			['Monomouse',				'mono',					'Ex-Programmer of Vs. Foxa',		 '',									 'A1A1A1'],
			[''],
			['Vs. Whitty Devs'],
			['sock.clip',			'sock',				'Creator of Vs. Whitty',								 'https://www.instagram.com/sock.clip/?hl=en',			 '9DD9F3'],
			['NateAnim8',			'nateanim8',				'Project Lead of Vs. Whitty',								 'https://gamebanana.com/members/1778429',			 '800080'],
			['bb-panzu',			'bb',				'Main Coder of Vs. Whitty',								 'https://twitter.com/bbsub3',			 '3E813A'],
			['KadeDev',				'kade',				'OG Coder of Vs. Whitty',			 'https://twitter.com/kade0912',		 '669966'],
			[''],
			['Psych Engine Team'],
			['Shadow Mario',		'shadowmario',		'Main Programmer of Psych Engine',								 'https://ko-fi.com/shadowmario',		 '444444'],
			['Riveren',				'riveren',			'Main Artist/Animator of Psych Engine',							 'https://twitter.com/riverennn',		 '14967B'],
			[''],
			['Former Engine Members'],
			['shubs',				'face',					'Ex-Programmer of Psych Engine\nI don\'t support them.',		 '',									 'A1A1A1'],
			[''],
			['Engine Contributors'],
			['CrowPlexus',			'gabriela',				'Input System v3, Major Help and Other PRs',	 'https://twitter.com/crowplexus',		 'A1A1A1'],
			['Keoiki',				'keoiki',			'Note Splash Animations and Latin Alphabet',					 'https://twitter.com/Keoiki_',			 'D2D2D2'],
			['SqirraRNG',			'sqirra',			'Crash Handler and Base code for\nChart Editor\'s Waveform',	 'https://twitter.com/gedehari',		 'E1843A'],
			['EliteMasterEric',		'mastereric',		'Runtime Shaders support',										 'https://twitter.com/EliteMasterEric',	 'FFBD40'],
			['ACrazyTown', 'acrazytown', 'Optimized PNGs', 'https://twitter.com/acrazytown', 'A03E3D'],
			['sayofthelor', 'sayof', 'Border FPS Counter', 'https://github.com/sayofthelor', 'F3F3F3'],
			['Raltyro', 'raltyro', 'Wrote Patches for the Border FPS Counter', 'https://twitter.com/raltyro', 'F3F3F3'],
			//['PolybiusProxy',		'proxy',			'.MP4 Video Loader Library (hxCodec)',							 'https://twitter.com/polybiusproxy',	 'DCD294'],
			['Tahir', 'tahir', 'Implementing & maintaining SScript and other PRs', 'https://github.com/TahirKarabekiroglu','A04397'],
			['iFlicky',				'flicky',			'Composer of Psync and Tea Time\nMade the Dialogue Sounds',		 'https://twitter.com/flicky_i',		 '9E29CF'],
			['superpowers04',		'superpowers04',	'LUA JIT Fork',													 'https://twitter.com/superpowers04',	 'B957ED'],
			['Smokey',				'smokey',			'Sprite Atlas Support (Only for Week 7 Pico!)',											 'https://twitter.com/Smokey_5_',		 '483D92'],
			['CheemsAndFriends', 'face', 'Creator of FlxAnimate', 'https://twitter.com/CheemsnFriendos', 'A1A1A1'],
			[''],
			["Funkin' Crew"],
			['ninjamuffin99',		'ninjamuffin99',	"Ex-Programmer of Friday Night Funkin'",							 'https://twitter.com/ninja_muffin99',	 'CF2D2DFF800080'],
			['PhantomArcade',		'phantomarcade',	"Animator of Friday Night Funkin'",								 'https://twitter.com/PhantomArcade3K',	 'FADC45'],
			['evilsk8r',			'evilsk8r',			"Artist of Friday Night Funkin'",								 'https://twitter.com/evilsk8r',		 '5ABD4B'],
			['kawaisprite',			'kawaisprite',		"Composer of Friday Night Funkin'",								 'https://twitter.com/kawaisprite',		 '378FC7']
		];
		
		for(i in defaultList) creditsStuff.push(i);
	
		for(i in 0...creditsStuff.length) {
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(FlxG.width / 2, 300, creditsStuff[i][0], !isSelectable);
			optionText.isMenuItem = true;
			optionText.targetY = i;
			optionText.changeX = false;
			optionText.snapToPosition();
			grpOptions.add(optionText);

			if(isSelectable){
				if(creditsStuff[i][5] != null) Mods.currentModDirectory = creditsStuff[i][5];

				var str:String = 'credits/missing_icon';
				if(creditsStuff[i][1] != null && creditsStuff[i][1].length > 0){
					var fileName = 'credits/' + creditsStuff[i][1];
					if (Paths.fileExists('images/$fileName.png', IMAGE)) str = fileName;
					else if (Paths.fileExists('images/$fileName-pixel.png', IMAGE)) str = fileName + '-pixel';
				}

				var icon:AttachedSprite = new AttachedSprite(str);
				if(str.endsWith('-pixel')) icon.antialiasing = false;
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;
	
				iconArray.push(icon);
				add(icon);
				Mods.currentModDirectory = '';

				if(curSelected == -1) curSelected = i;
			}
			else optionText.alignment = CENTERED;
		}
		
		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		descBox.sprTracker = descText;
		add(descText);

		bg.color = CoolUtil.colorFromString(creditsStuff[curSelected][4]);
		intendedColor = bg.color;
		changeSelection();
		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	override function update(elapsed:Float) {
		if(FlxG.sound.music.volume < 0.7) FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		if(!quitting){
			if(creditsStuff.length > 1){
				var shiftMult:Int = 1;
				if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;

				if(upP){
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if(downP){
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if(controls.UI_DOWN || controls.UI_UP) {
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
				}
			}

			if(controls.ACCEPT && (creditsStuff[curSelected][3] == null || creditsStuff[curSelected][3].length > 4))
				CoolUtil.browserLoad(creditsStuff[curSelected][3]);
			if(controls.BACK){
				if(colorTween != null) colorTween.cancel();
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
				quitting = true;
			}
		}
		
		for (item in grpOptions.members){
            if(!item.bold){
				var lerpVal:Float = Math.exp(-elapsed * 12);
				if(item.targetY == 0){
					var lastX:Float = item.x;
					item.screenCenter(X);
					item.x = FlxMath.lerp(item.x - 70, lastX, lerpVal);
				}else item.x = FlxMath.lerp(200 + -40 * Math.abs(item.targetY), item.x, lerpVal);
			}
		}
		super.update(elapsed);
	}

	var moveTween:FlxTween = null;
	function changeSelection(change:Int = 0) {
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if(curSelected < 0) curSelected = creditsStuff.length - 1;
			if(curSelected >= creditsStuff.length) curSelected = 0;
		} while(unselectableCheck(curSelected));

		var newColor:FlxColor = CoolUtil.colorFromString(creditsStuff[curSelected][4]);
		if(newColor != intendedColor) {
			if(colorTween != null) colorTween.cancel();
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)){
				item.alpha = 0.6;
				if(item.targetY == 0) item.alpha = 1;
			}
		}

		descText.text = creditsStuff[curSelected][2];
		descText.y = FlxG.height - descText.height + offsetThing - 60;

		if(moveTween != null) moveTween.cancel();
		moveTween = FlxTween.tween(descText, {y : descText.y + 75}, 0.25, {ease: FlxEase.sineOut});

		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
	}

	#if MODS_ALLOWED
	function pushModCreditsToList(folder:String) {
		var creditsFile:String = null;
		if(folder != null && folder.trim().length > 0) creditsFile = Paths.mods(folder + '/data/credits.txt');
		else creditsFile = Paths.mods('data/credits.txt');

		if(FileSystem.exists(creditsFile)){
			var firstarray:Array<String> = File.getContent(creditsFile).split('\n');
			for(i in firstarray) {
				var arr:Array<String> = i.replace('\\n', '\n').split("::");
				if(arr.length >= 5) arr.push(folder);
				creditsStuff.push(arr);
			}
			creditsStuff.push(['']);
		}
	}
	#end

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}
