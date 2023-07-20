package;

import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;

class EstadoDeTroca extends MusicBeatState
{ // Obviamente eu poderia fazer algo mais geral, mas considerando que o problema era só aqui, não havia muito pra eu me preocupar na real
	
	public static var hasTrans:Bool = true;
	
	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		if (hasTrans){
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			PlayState.transInAllowed = true;

			var transImage:FlxSprite = new FlxSprite().loadGraphic(Paths.image('elpngtrans', 'preload'));
			add(transImage);
		}

		new flixel.util.FlxTimer().start(0.5, function(tmr:flixel.util.FlxTimer)
		{
			hasTrans = true;
			LoadingState.loadAndSwitchState(new PlayState());
		});
	}
}