package;
import flixel.*;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxCamera;
import openfl.Lib;

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