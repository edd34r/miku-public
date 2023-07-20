package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class MikuBG extends FlxSpriteGroup{

	public static var tr:FlxSprite;
	public static var walked:Int = 0;

	public function new(x:Float, y:Float)
    {
    super(x,y);

    	var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG/back'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.1;
		bg.setGraphicSize(Std.int(bg.width * 1.4));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = SaveData.antialising;
		add(bg);

		/*var bgx:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG/backx'));
		bgx.scrollFactor.x = 0;
		bgx.scrollFactor.y = 0.2;
		bgx.setGraphicSize(Std.int(bgx.width * 1.4));
		bgx.updateHitbox();
		bgx.screenCenter();
		bgx.antialiasing = SaveData.antialising;
		add(bgx);
		FlxTween.tween(bgx,{x: bgx.x + 70}, 6,{ease:FlxEase.cubeOut,type:PINGPONG});

		var circle:FlxSprite = new FlxSprite(-10, 500).loadGraphic(Paths.image('menuBG/circles'));
		circle.setGraphicSize(Std.int(circle.width * 1.3));
		circle.screenCenter(Y);
		circle.scrollFactor.x = 0;
		circle.scrollFactor.y = 0.2;
		circle.updateHitbox();
		circle.antialiasing = SaveData.antialising;
		add(circle);
		FlxTween.angle(circle,circle.angle,360,20,{type:LOOPING});
		*/

        tr = new FlxSprite(-FlxG.width, 0).loadGraphic(Paths.image('menuBG/trianglesAndLines'));
		tr.antialiasing = SaveData.antialising;
		tr.screenCenter(Y);
		add(tr);

    }

	public static function updateTR()
	{
		if (tr!=null)
			{
				walked += 1;
				tr.x = walked;
				if(walked >= 0)
					walked = -FlxG.width;
			}
		
	}


}