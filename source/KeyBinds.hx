import flixel.FlxG;

class KeyBinds
{

    public static var gamepad:Bool = false;

    public static function resetBinds():Void
	{
		SaveData.upBind = "W";
		SaveData.downBind = "S";
		SaveData.leftBind = "A";
		SaveData.rightBind = "D";
		SaveData.killBind = "R";
		PlayerSettings.player1.controls.loadKeyBinds();
	}

    public static function keyCheck():Void
    {
        if (SaveData.upBind == null)
            SaveData.upBind = "W";

        if (SaveData.downBind == null)
            SaveData.downBind = "S";

        if (SaveData.leftBind == null)
            SaveData.leftBind = "A";

        if (SaveData.rightBind == null)
            SaveData.rightBind = "D";


        if (SaveData.killBind == null)
            SaveData.killBind = "R";
    }

}
