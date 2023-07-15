package;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.FlxTransitionSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import lime.app.Application;
import flash.display.BitmapData;
import openfl.Assets;
import flixel.FlxState;


class Transition extends FlxSprite{
    public function new(x:Float,y:Float,anim:String){

    super(x, y);
    switch (anim)
    {
        case 'in':
        frames = Paths.getSparrowAtlas('menuBG/transIn');
        case 'out':
        frames = Paths.getSparrowAtlas('menuBG/transOut');
    }

    setGraphicSize(Std.int(this.width*2));
    screenCenter(XY);


    
    antialiasing = FlxG.save.data.antialiasing;
    animation.addByPrefix('transition','loading anim',24,false);

    }

    override function update(elapsed:Float){

    super.update(elapsed);

    }

}