package objects;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;

	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	public var canBounce:Bool = false;
	public var bopMult:Float = 1;
	private var char:String = '';
	private var defChar:String = '';

	public function new(char:String = 'bf', isPlayer:Bool = false, ?allowGPU:Bool = true)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char, allowGPU);
		scrollFactor.set();
	}
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if(sprTracker != null) setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);

		if(canBounce){
			var mult:Float = FlxMath.lerp(1, scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
			scale.set(mult, mult);
			updateHitbox();
		}
	}

	public function swapOldIcon(){
		if (isOldIcon = !isOldIcon) changeIcon('bf-old');
		else changeIcon(defChar);
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String, ?allowGPU:Bool = true){
		if (this.char != char)
		{
			var name:String = 'icons/' + char;
			if (!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; // Older versions of psych engine's support
			if (!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; // Prevents crash from missing icon

			var graphic = Paths.image(name, allowGPU);
			var ratio = graphic.width / graphic.height;
			if (ratio == 3 || ratio == 2 || ratio == 1)
				loadGraphic(graphic, true, Math.floor(graphic.width / ratio), Math.floor(graphic.height));
			else{
				trace("Invalid icon ratio for character: " + char);
				loadGraphic(Paths.image("icons/icon-face", allowGPU), true, Math.floor(graphic.width / 2), Math.floor(graphic.height));
			}

			iconOffsets[0] = (width - 150) / 2;
			iconOffsets[1] = (height - 150) / 2;
			updateHitbox();

			var anims:Array<Int> = (ratio == 3) ? [0, 1, 2] : (ratio == 1) ? [0] : [0, 1];
			animation.add(char, anims, 0, false, isPlayer);
			animation.play(char);
			this.char = char;
			if (!isOldIcon) defChar = char;

			if (char.endsWith('-pixel')) antialiasing = false;
			else
				antialiasing = ClientPrefs.data.antialiasing;
		}
	}
	override function updateHitbox(){
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function bounce(){
		if(canBounce){
			var mult:Float = 1.2;
			scale.set(mult, mult);
			updateHitbox();
		}
	}

	public function getCharacter():String{
		return char;
	}
}

// in case it breaks
/*class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';

	public function new(char:String = 'bf', isPlayer:Bool = false, ?allowGPU:Bool = true)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char, allowGPU);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(sprTracker != null) setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);

		if(canBounce){
			var mult:Float = FlxMath.lerp(1, scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
			scale.set(mult, mult);
			updateHitbox();
		}
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String, ?allowGPU:Bool = true) {
		if(this.char != char) {
			var name:String = 'icons/' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; //Older versions of psych engine's support
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon
			
			var graphic = Paths.image(name, allowGPU);
			loadGraphic(graphic, true, Math.floor(graphic.width / 2), Math.floor(graphic.height));
			iconOffsets[0] = (width - 150) / 2;
			iconOffsets[1] = (height - 150) / 2;
			updateHitbox();

			animation.add(char, [0, 1], 0, false, isPlayer);
			animation.play(char);
			this.char = char;

			if(char.endsWith('-pixel'))
				antialiasing = false;
			else
				antialiasing = ClientPrefs.data.antialiasing;
		}
	}

	public function bounce(){
		if(canBounce){
			var mult:Float = 1.2;
			scale.set(mult, mult);
			updateHitbox();
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String {
		return char;
	}
}*/
