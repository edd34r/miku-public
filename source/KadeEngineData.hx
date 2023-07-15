import flixel.input.gamepad.FlxGamepad;
import openfl.Lib;
import flixel.FlxG;

class KadeEngineData
{
    public static function initSave()
    {
        if (FlxG.save.data.weekUnlocked == null)
			FlxG.save.data.weekUnlocked = 7;

		if (FlxG.save.data.downscroll == null)
			FlxG.save.data.downscroll = false;

		if (FlxG.save.data.middlescroll == null)
			FlxG.save.data.middlescroll = false;

		if (FlxG.save.data.antialiasing == null)
			FlxG.save.data.antialiasing = true; //????????????????????????? wtf silvio

		if (FlxG.save.data.missSounds == null)
			FlxG.save.data.missSounds = true;

		if (FlxG.save.data.offset == null)
			FlxG.save.data.offset = 0;

		if (FlxG.save.data.songPosition == null)
			FlxG.save.data.songPosition = false;

		if (FlxG.save.data.fps == null)
			FlxG.save.data.fps = false;

		if (FlxG.save.data.fpsCap == null)
			FlxG.save.data.fpsCap = 60;

		if (FlxG.save.data.fpsCap > 285 || FlxG.save.data.fpsCap < 60)
			FlxG.save.data.fpsCap = 60; // baby proof so you can't hard lock ur copy of kade engine
		
		if (FlxG.save.data.scrollSpeed == null)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.accuracyMod == null)
			FlxG.save.data.accuracyMod = 1;
				
		if (FlxG.save.data.botplay == null)
			FlxG.save.data.botplay = false;

		if (FlxG.save.data.hitSound == null)
			FlxG.save.data.hitSound = 0;

		if (FlxG.save.data.hitSoundVolume == null)
			FlxG.save.data.hitSoundVolume = 0;

		if (FlxG.save.data.cpuStrums == null)
			FlxG.save.data.cpuStrums = false;
		
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		
		KeyBinds.gamepad = gamepad != null;

		Conductor.recalculateTimings();
		PlayerSettings.player1.controls.loadKeyBinds();
		KeyBinds.keyCheck();

		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
	}
}