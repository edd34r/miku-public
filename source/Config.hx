package;

import ui.FlxVirtualPad;
import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.math.FlxPoint;

class Config {

    public static function getcontrolmode():Int {
        // load control mode num from FlxSave
		if (SaveData.buttonsMode != null) return SaveData.buttonsMode[0];
        return 0;
    }

    public static function setcontrolmode(mode:Int = 0):Int {
        // save control mode num from FlxSave
		if (SaveData.buttonsMode == null) SaveData.buttonsMode = new Array();
        SaveData.buttonsMode[0] = mode;
		SaveData.save();

        return SaveData.buttonsMode[0];
    }

    public static function savecustom(_pad:FlxVirtualPad) {
		trace("saved");

		if (SaveData.buttons == null)
		{
			SaveData.buttons = new Array();

			for (buttons in _pad)
			{
				SaveData.buttons.push(FlxPoint.get(buttons.x, buttons.y));
			}
		}else
		{
			var tempCount:Int = 0;
			for (buttons in _pad)
			{
				SaveData.buttons[tempCount] = FlxPoint.get(buttons.x, buttons.y);
				tempCount++;
			}
		}
		SaveData.save();
	}

	public static function loadcustom(_pad:FlxVirtualPad):FlxVirtualPad {
		//load pad
		if (SaveData.buttons == null) return _pad;
		var tempCount:Int = 0;

		for(buttons in _pad)
		{
			buttons.x = SaveData.buttons[tempCount].x;
			buttons.y = SaveData.buttons[tempCount].y;
			tempCount++;
		}	
        return _pad;
	}
}