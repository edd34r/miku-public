package;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxTimer;

class FanState extends MusicBeatState
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
		super.create();	
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		loadIn = new Transition(0,0,'in');
		loadIn.animation.finishCallback = function(huh:String){
		remove(loadIn);
		};
		loadIn.scrollFactor.set(0,0);
		super.create();	
		new FlxTimer().start(0.8, function(tmr:FlxTimer) {
			#if desktop
			video.playMP4(Paths.video('hatsunemikusouteufauhhhhhhhhh'), new MainMenuState());
			#elseif mobile
			LoadingState.loadAndSwitchState(new VideoStateLegal('assets/videos/' + 'hatsunemikusouteufauhhhhhhhhh', new MainMenuState(), true));
			#end
		});

		add(loadIn);
		loadIn.animation.play('transition');
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
	}
	
}