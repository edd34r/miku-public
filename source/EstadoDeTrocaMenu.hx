package;

import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxG;
import flixel.FlxSprite;

class EstadoDeTrocaMenu extends MusicBeatState
{ // Obviamente eu poderia fazer algo mais geral, mas considerando que o problema era só aqui, não havia muito pra eu me preocupar na real
	public static var hasTrans:Bool = true;
	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		if(hasTrans){
		var transImage:FlxSprite = new FlxSprite().loadGraphic(Paths.image('elpngtrans', 'preload'));
		add(transImage);
        FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		}

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		new flixel.util.FlxTimer().start(0.5, function(tmr:flixel.util.FlxTimer)
		{
			hasTrans = true;
			FlxG.switchState(new MainMenuState());
		});
	}
}