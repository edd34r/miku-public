package;

/// Code created by Rozebud for FPS Plus (thanks rozebud)
// modified by KadeDev for use in Kade Engine/Tricky

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;

using StringTools;
#if newgrounds
import io.newgrounds.NG;
#end



class KeyBindMenu extends FlxSubState
{

    var keyTextDisplay:FlxText;
    var keyWarning:FlxText;
    var warningTween:FlxTween;
    var keyText:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];
    var defaultKeys:Array<String> = ["A", "S", "W", "D", "R"];
    var defaultGpKeys:Array<String> = ["DPAD_LEFT", "DPAD_DOWN", "DPAD_UP", "DPAD_RIGHT"];
    var curSelected:Int = 0;

    var keys:Array<String> = [
        SaveData.leftBind,
        SaveData.downBind,
        SaveData.upBind,
        SaveData.rightBind];

    var tempKey:String = "";
    var blacklist:Array<String> = ["ESCAPE", "ENTER", "BACKSPACE", "SPACE", "TAB"];

    var blackBox:FlxSprite;
    var infoText:FlxText;

    var state:String = "select";

	override function create()
	{	

        for (i in 0...keys.length)
        {
            var k = keys[i];
            if (k == null)
                keys[i] = defaultKeys[i];
        }
	
		//FlxG.sound.playMusic('assets/music/configurator' + TitleState.soundExt);

		persistentUpdate = true;

        keyTextDisplay = new FlxText(-10, 0, 1280, "", 72);
		keyTextDisplay.scrollFactor.set(0, 0);
		keyTextDisplay.setFormat("VCR OSD Mono", 42, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		keyTextDisplay.borderSize = 2;
		keyTextDisplay.borderQuality = 3;

        blackBox = new FlxSprite(0,0).makeGraphic(FlxG.width,FlxG.height,FlxColor.BLACK);
        add(blackBox);

        infoText = new FlxText(-10, 580, 1280, 'Current Mode: KEYBOARD. Press TAB to switch\n(Escape to save, Backspace to leave without saving. )', 72);
		infoText.scrollFactor.set(0, 0);
		infoText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoText.borderSize = 2;
		infoText.borderQuality = 3;
        infoText.alpha = 0;
        infoText.screenCenter(FlxAxes.X);
        add(infoText);
        add(keyTextDisplay);

        blackBox.alpha = 0;
        keyTextDisplay.alpha = 0;

        FlxTween.tween(keyTextDisplay, {alpha: 1}, 1, {ease: FlxEase.expoInOut});
        FlxTween.tween(infoText, {alpha: 1}, 1.4, {ease: FlxEase.expoInOut});
        FlxTween.tween(blackBox, {alpha: 0.7}, 1, {ease: FlxEase.expoInOut});

        textUpdate();

		super.create();
	}

    var frames = 0;

	override function update(elapsed:Float)
	{
        if (frames <= 10)
            frames++;

        infoText.text = 'Current Mode: KEYBOARD. Press TAB to switch\n(Escape to save, Backspace to leave without saving. )\n${lastKey != "" ? lastKey + " is blacklisted!" : ""}';

        switch(state){

            case "select":
                if (FlxG.keys.justPressed.UP)
                {
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    changeItem(-1);
                }

                if (FlxG.keys.justPressed.DOWN)
                {
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    changeItem(1);
                }

                if (FlxG.keys.justPressed.TAB)
                {
                    textUpdate();
                }

                if (FlxG.keys.justPressed.ENTER){
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    state = "input";
                }
                else if(FlxG.keys.justPressed.ESCAPE){
                    quit();
                }
                else if (FlxG.keys.justPressed.BACKSPACE){
                    reset();
                }

            case "input":
                tempKey = keys[curSelected];
                keys[curSelected] = "?";
                textUpdate();
                state = "waiting";

            case "waiting":
                    if(FlxG.keys.justPressed.ESCAPE){
                        keys[curSelected] = tempKey;
                        state = "select";
                        FlxG.sound.play(Paths.sound('confirmMenu'));
                    }
                    else if(FlxG.keys.justPressed.ENTER){
                        addKey(defaultKeys[curSelected]);
                        save();
                        state = "select";
                    }
                    else if(FlxG.keys.justPressed.ANY){
                        addKey(FlxG.keys.getIsDown()[0].ID.toString());
                        save();
                        state = "select";
                    }

            case "exiting":


            default:
                state = "select";

        }

        if(FlxG.keys.justPressed.ANY)
			textUpdate();

		super.update(elapsed);
		
	}

    function textUpdate(){

        keyTextDisplay.text = "\n\n";

        for(i in 0...4){

            var textStart = (i == curSelected) ? "> " : "  ";
            keyTextDisplay.text += textStart + keyText[i] + ": " + ((keys[i] != keyText[i]) ? (keys[i] + " / ") : "" ) + keyText[i] + " ARROW\n";

        }

        keyTextDisplay.screenCenter();

    }

    function save(){

        SaveData.upBind = keys[2];
		SaveData.downBind = keys[1];
		SaveData.leftBind = keys[0];
		SaveData.rightBind = keys[3];
		SaveData.save();

        PlayerSettings.player1.controls.loadKeyBinds();

    }

    function reset(){

        for(i in 0...5){
            keys[i] = defaultKeys[i];
        }
        quit();

    }

    function quit(){

        state = "exiting";

        save();

        FlxTween.tween(keyTextDisplay, {alpha: 0}, 1, {ease: FlxEase.expoInOut});
        FlxTween.tween(blackBox, {alpha: 0}, 1.1, {ease: FlxEase.expoInOut, onComplete: function(flx:FlxTween){close();}});
        FlxTween.tween(infoText, {alpha: 0}, 1, {ease: FlxEase.expoInOut});
    }

    public var lastKey:String = "";

	function addKey(r:String){

        var shouldReturn:Bool = true;

        var notAllowed:Array<String> = [];

        for(x in blacklist){notAllowed.push(x);}

        trace(notAllowed);

        for(x in 0...keys.length)
            {
                var oK = keys[x];
                if(oK == r)
                    keys[x] = null;
                if (notAllowed.contains(oK))
                {
                    keys[x] = null;
                    lastKey = oK;
                    return;
                }
            }

        if (r.contains("NUMPAD"))
        {
            keys[curSelected] = null;
            lastKey = r;
            return;
        }

        lastKey = "";

        if(shouldReturn){
            keys[curSelected] = r;
            FlxG.sound.play(Paths.sound('scrollMenu'));
        }
        else{
            keys[curSelected] = tempKey;
            lastKey = r;
        }

	}

    function changeItem(_amount:Int = 0)
    {
        curSelected += _amount;
                
        if (curSelected > 3)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = 3;
    }
}
