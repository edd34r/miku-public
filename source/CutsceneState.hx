package;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxTimer;

class CutsceneState extends MusicBeatState
{
	var _goodEnding:Bool = false;

	var zoom:Float = -1;

	var loadIn:Transition;

	#if desktop
	var video:MP4Handler = new MP4Handler();
	#end

	public function new(goodEnding:Bool = true) 
	{
		super();
		_goodEnding = goodEnding;
		
	}
	
	override public function create():Void 
	{
		trace(PlayState.storyWeek);
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		loadIn = new Transition(0,0,'in');
		loadIn.animation.finishCallback = function(huh:String){
		remove(loadIn);
		};
		loadIn.scrollFactor.set(0,0);
		super.create();	
		new FlxTimer().start(0.8, function(tmr:FlxTimer) {

		EstadoDeTroca.hasTrans = false;
		if (PlayState.storyWeek == 0)
			endIt();
		else
			if (PlayState.storyWeek == 1)
				#if desktop
				video.playMP4(Paths.video('loidcutscene'), new EstadoDeTroca());
				#elseif mobile
				LoadingState.loadAndSwitchState(new VideoStateLegal('assets/videos/' + 'loidcutscene', new EstadoDeTroca()));
				#end
		});

		add(loadIn);
		loadIn.animation.play('transition');
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
	}
	
	public function endIt(e:FlxTimer=null){
		trace("ENDING");
		FlxG.switchState(new PlayState());
	}
	
}