package;
import flixel.FlxG;
import flixel.FlxSprite;


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


    
    antialiasing = SaveData.antialising;
    animation.addByPrefix('transition','loading anim',24,false);

    }

    override function update(elapsed:Float){

    super.update(elapsed);

    }

}