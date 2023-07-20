package; //Furtado de um lugar secreto shhhhhhhhhhhhhhhhhhhhh

#if mobile
import flixel.addons.transition.FlxTransitionableState;
import extension.webview.WebView;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.text.FlxText;

using StringTools;

class VideoStateLegal extends MusicBeatState
{
	var changecount = 0;
	public static var androidPath:String = 'file:///android_asset/';

	public var nextState:FlxState;

	var text:FlxText;

	public function new(source:String, toTrans:FlxState, ?special:Bool = false)
	{
		super();

		if (special)
			text = new FlxText(0, 0, 0, "Isso tinha 5% de chance de aparecer\n tu é muito sortudo \n(ou muito azarado não sei kek)", 48);
		else
			text = new FlxText(0, 0, 0, "Toque para continuar", 48);
		text.screenCenter();
		text.alpha = 0;
		add(text);

			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;

		nextState = toTrans;

		// FlxG.autoPause = false;

		WebView.onClose = onClose;
		WebView.onURLChanging = onURLChanging;

		WebView.open(androidPath + source + '.html', false, null, ['http://exitme(.*)']);
	}

	public override function update(dt:Float)
	{
		if (BSLTouchUtils.justTouched() || FlxG.android.justReleased.BACK)
				onClose();

		super.update(dt);
	}

	function onClose()
	{ // not working
		text.alpha = 0;
		changecount = 0;
		// FlxG.autoPause = true;
		trace('close!');
		trace(nextState);
		FlxG.switchState(nextState);
	}

	function onURLChanging(url:String)
	{
		if (changecount == 2){ //Hacks mais sujos que o anterior k
			text.alpha = 0;
			onClose();
		}else{
			changecount++;
			text.alpha = 1;
		}
		if (url == 'http://exitme/')
			onClose(); // drity hack lol
		trace("WebView is about to open: " + url);
	}
}
#end