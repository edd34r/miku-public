import flixel.FlxG;
import flixel.util.FlxSave;
import lime.app.Application;

class SaveData
{
	#if (haxe >= "4.0.0")
	public static var songOffsets:Map<String, Float> = new Map();
	public static var songScores:Map<String, Int> = new Map();
	public static var songCombos:Map<String, String> = new Map();
	public static var songAccuracies:Map<String, Float> = new Map();
	#else
	public static var songOffsets:Map<String, Float> = new Map<String, Float>();
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	public static var songCombos:Map<String, String> = new Map<String, String>();
	public static var songAccuracies:Map<String, Float> = new Map<String, Float>();
	#end

	public static var downscroll:Null<Bool> = false;
	public static var middlescroll:Null<Bool> = false;
	public static var antialising:Null<Bool> = true;
    public static var missSounds:Null<Bool> = false;
    public static var offset:Null<Float> = 0;
	public static var songPosition:Null<Bool> = false;
    public static var showFPS:Null<Bool> = false;
	public static var framerate:Null<Int> = 60;
	public static var gpu:Null<Bool> = false;
	public static var scrollSpeed:Null<Float> = 1;
    public static var botplay:Null<Bool> = false;
	public static var hitSound:Null<Int> = 0;
	public static var hitSoundVolume:Null<Float> = 0;
	public static var cpuStrums:Null<Bool> = true;
	public static var buttonsMode:Array<Dynamic> = [];
	public static var buttons:Array<Dynamic> = [];

	// Controls
	public static var upBind:String = 'W';
	public static var downBind:String = 'S';
	public static var leftBind:String = 'A';
	public static var rightBind:String = 'D';
	public static var killBind:String = 'R';

	private static var importantMap:Map<String, Array<String>> =
	[
		"flixelSound" => ["volume"]
	];

	/** Quick Function to Fix Save Files for Flixel 5
		@BeastlyGabi
	**/
	inline public static function getSavePath(folder:String = 'TeamSilver'):String
	{
		@:privateAccess
		return #if (flixel < "5.0.0") folder #else FlxG.stage.application.meta.get('company')
			+ '/'
			+ FlxSave.validate(FlxG.stage.application.meta.get('file')) #end;
	}

	public static function init()
	{
		FlxG.save.bind('Miku_V2', getSavePath());

		// https://github.com/ShadowMario/FNF-PsychEngine/pull/11633
		for (field in Type.getClassFields(SaveData))
		{
			if (Type.typeof(Reflect.field(SaveData, field)) != TFunction)
			{
				if (!importantMap.get("flixelSound").contains(field))
				{
					var defaultValue:Dynamic = Reflect.field(SaveData, field);
					var flxProp:Dynamic = Reflect.field(FlxG.save.data, field);
					Reflect.setField(SaveData, field, (flxProp != null ? flxProp : defaultValue));
				}
			}
		}

		for (flixelS in importantMap.get("flixelSound"))
		{
			var flxProp:Dynamic = Reflect.field(FlxG.save.data, flixelS);

			if (flxProp != null)
				Reflect.setField(FlxG.sound, flixelS, flxProp);
		}

		Highscore.load();
		PlayerSettings.init();
	}

	public static function save()
	{
		// ensure that we're saving (hopefully)
		if (FlxG.save.data == null)
			FlxG.save.bind('DokiTakeover', getSavePath());

		for (field in Type.getClassFields(SaveData))
		{
			if (Type.typeof(Reflect.field(SaveData, field)) != TFunction)
				Reflect.setField(FlxG.save.data, field, Reflect.field(SaveData, field));
		}

		for (flixel in importantMap.get("flixelSound"))
			Reflect.setField(FlxG.save.data, flixel, Reflect.field(FlxG.sound, flixel));

		FlxG.save.flush();
	}
}