package gapple;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	
	public var charPublic:String = 'bf';

	public var noAaChars:Array<String> = [
		'dave-angey',
		'bambi-3d',
		'bf-pixel',
		'gf-pixel',
		'bambi-unfair',
		'expunged',
		'nofriend',
		'dave-festival-3d'
	];
	var char:String;
	var state:String;
	public var isPlayer:Bool;
	
	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
	}

	public function changeIcon(char:String)
	{
		if (this.char != char)
		{
			if (char != "none")
				loadGraphic(Paths.image('icons/' + char, 'preload'), true, 150, 150);
			else
				loadGraphic(Paths.image('blank', 'shared'));
			if (char != "bambi-piss-3d")
				loadGraphic(Paths.image('icons/bambi-pissboy-old', 'preload'), true, 150, 150);
			if (char != "bambi-piss-3d" && FlxG.save.data.newspritetest)
				loadGraphic(Paths.image('icons/bambi-pissboy', 'preload'), true, 150, 150);
		        if (char != "unfair-junker")
				loadGraphic(Paths.image('icons/unfair-junker', 'preload'), true, 150, 150);
			if (char != "unfair-junker" && FlxG.save.data.newspritetest)
				loadGraphic(Paths.image('icons/unfair', 'preload'), true, 150, 150);
	
			if (char != "none")
			{
				antialiasing = !noAaChars.contains(char);
				animation.add(char, [0, 1], 0, false, isPlayer);
				animation.play(char);
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		offset.set(Std.int(FlxMath.bound(width - 150, 0)), Std.int(FlxMath.bound(height - 150, 0)));

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
	public function changeState(charState:String)
	{
		switch (charState)
		{
			case 'normal':
				animation.curAnim.curFrame = 0;
			case 'losing':
				animation.curAnim.curFrame = 1;
		}
		state = charState;
	}
	public function getState()
	{
		return state;
	}
	public function getChar():String
	{
		return char;
	}
}
