package;

import flixel.input.gamepad.FlxGamepad;
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
import lime.net.curl.CURLCode;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.effects.FlxFlicker;
import flixel.FlxObject;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class StoryMenuState extends MusicBeatState
{
	
	var weekData:Array<Dynamic> = [
		['Tutorial'],
		['Loid', 'Endurance', 'Voca'],
		['PoPiPo', 'Aishite', 'SIU', 'Disappearance']
	];
	var curDifficulty:Int = 1;

	public static var weekUnlocked:Array<Bool> = [true, true];

	var weekCharacters:Array<Dynamic> = [
		['', '', ''],
		['', '', ''],
		['', '', '']
	];

	var weekNames:Array<String> = [
		"Learning",
		"Concert Conundrum",
		'Classics'
	];

	var curWeek:Int = 0;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultyBar:FlxSprite;
	var hard_button:FlxSprite;
	var easy_button:FlxSprite;
	var normal_button:FlxSprite;

	var titleText:FlxSprite;
	var loadOut:Transition;
	var loadIn:Transition;

	override function create()
	{
		
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		loadIn = new Transition(0,0,'in');
		loadOut = new Transition(0,0,'out');
		loadIn.animation.finishCallback = function(huh:String){
		remove(loadIn);
		};
		loadOut.alpha = 0;
		loadOut.scrollFactor.set(0,0);
		loadIn.scrollFactor.set(0,0);
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Story Mode Menu", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;


		var bg:MikuBG = new MikuBG(0,0);
		bg.scrollFactor.set(0,0);
		add(bg);

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		var circle:FlxSprite = new FlxSprite(-750, -250).loadGraphic(Paths.image('menuBG/record'));
		circle.setGraphicSize(Std.int(circle.width * 1.25));
		circle.updateHitbox();
		circle.antialiasing = FlxG.save.data.antialiasing;
		add(circle);
		FlxTween.angle(circle,circle.angle,360,20,{type:LOOPING});

		difficultyBar = new FlxSprite(500, 175);
		difficultyBar.scrollFactor.set(0,0);
		difficultyBar.loadGraphic(Paths.image('menuBG/diffs/historia/diffbar_clean'));
		difficultyBar.setGraphicSize(Std.int(difficultyBar.width * 1.4));
		difficultyBar.antialiasing = FlxG.save.data.antialiasing;
		difficultyBar.x += 200;
		difficultyBar.y += 25;
		add(difficultyBar);

		hard_button = new FlxSprite(500, 175);
		hard_button.scrollFactor.set(0,0);
		hard_button.loadGraphic(Paths.image('menuBG/diffs/historia/hard_button'));
		hard_button.setGraphicSize(Std.int(hard_button.width * 1.4));
		hard_button.antialiasing = FlxG.save.data.antialiasing;
		hard_button.y += 45;
		hard_button.x += 576;
		hard_button.updateHitbox();
		add(hard_button);

		easy_button = new FlxSprite(500, 175);
		easy_button.scrollFactor.set(0,0);
		easy_button.loadGraphic(Paths.image('menuBG/diffs/historia/easy_button'));
		easy_button.setGraphicSize(Std.int(easy_button.width * 1.4));
		easy_button.antialiasing = FlxG.save.data.antialiasing;
		easy_button.y += 45;
		easy_button.x += 181;
		easy_button.updateHitbox();
		add(easy_button);

		normal_button = new FlxSprite(500, 175);
		normal_button.scrollFactor.set(0,0);
		normal_button.loadGraphic(Paths.image('menuBG/diffs/historia/normal_button'));
		normal_button.setGraphicSize(Std.int(normal_button.width * 1.4));
		normal_button.antialiasing = FlxG.save.data.antialiasing;
		normal_button.y += 45;
		normal_button.x += 369;
		normal_button.updateHitbox();
		add(normal_button);



		titleText = new FlxSprite(435, 325);
		titleText.frames = Paths.getSparrowAtlas('menuBG/startbutton');
		titleText.animation.addByPrefix('idle', "startbutton", 24);
		titleText.animation.addByPrefix('press', "startbutton", 24, false);
		titleText.antialiasing = FlxG.save.data.antialiasing;
		titleText.animation.play('idle');
		titleText.setGraphicSize(Std.int(titleText.width * 0.65));
		add(titleText);

		var bars:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('menuBG/storymodebars'));
		bars.scrollFactor.set();
		bars.screenCenter(Y);
		bars.updateHitbox();
		bars.antialiasing = FlxG.save.data.antialiasing;
		add(bars);

		addbackButton();

		add(loadIn);
        add(loadOut);
		loadIn.animation.play('transition');

		trace("Line 165");

		changeDifficulty(1, true);

		super.create();
	}

	override function update(elapsed:Float)
	{
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

				if (gamepad != null)
				{

					if (gamepad.justPressed.DPAD_RIGHT)
					{
						changeDifficulty(1);
					}
					if (gamepad.justPressed.DPAD_LEFT)
					{
						changeDifficulty(-1);
					}
				}

				if (controls.RIGHT_P)
					changeDifficulty(1);
				if (controls.LEFT_P)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT || BSLTouchUtils.apertasimples(titleText))
			{
				selectWeek();
			}
		}

		if ((controls.BACK || _backButton.justReleased) && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			loadOut.alpha = 1;
			loadOut.animation.play('transition');
			loadOut.animation.finishCallback = function(huh:String){
				FlxG.switchState(new MainMenuState());
			};
		}

		//Touch stuff
		if (BSLTouchUtils.apertasimples(easy_button)){
			changeDifficulty(0, true);
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}else if(BSLTouchUtils.apertasimples(normal_button)){
			changeDifficulty(1, true);
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}else if(BSLTouchUtils.apertasimples(hard_button)){
			changeDifficulty(2, true);
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (weekUnlocked[curDifficulty])
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				titleText.animation.play('press');
				stopspamming = true;
			}

			PlayState.storyPlaylist = weekData[curDifficulty];
			PlayState.isStoryMode = true;
			selectedWeek = true;


			PlayState.storyDifficulty = 2; //Por padrão vai no difícil.

			// adjusting the song name to be compatible
			var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");

			var poop:String = Highscore.formatSong(songFormat, 2);
			PlayState.sicks = 0;
			PlayState.bads = 0;
			PlayState.shits = 0;
			PlayState.goods = 0;
			PlayState.campaignMisses = 0;
			PlayState.SONG = Song.loadFromJson(poop, PlayState.storyPlaylist[0]);
			PlayState.storyWeek = curDifficulty;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				if (curDifficulty == 1) //Quem diria k
				{
					loadOut.alpha = 1;
					loadOut.animation.play('transition');
					loadOut.animation.finishCallback = function(huh:String){
						LoadingState.loadAndSwitchState(new CutsceneState(), true);
					};
				}
				else
				{
					PlayState.transInAllowed = true;
					loadOut.alpha = 1;
					loadOut.animation.play('transition');
					loadOut.animation.finishCallback = function(huh:String){
						LoadingState.loadAndSwitchState(new EstadoDeTroca(), true);
					};
				}
			});
		}
	}

	function changeDifficulty(change:Int = 0, directly:Bool = false):Void
	{
		if (!directly)
            curDifficulty += change;
        else
            curDifficulty = change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		hard_button.visible = false;
		normal_button.visible = false;
		easy_button.visible = false;

		switch (curDifficulty)
		{
			case 0:
				easy_button.visible = true;
			//	sprDifficulty.offset.x = 20;
			case 1:
				normal_button.visible = true;
			//	sprDifficulty.offset.x = 70;
			case 2:
				hard_button.visible = true;
			//	sprDifficulty.offset.x = 20;
		}

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		intendedScore = Highscore.getWeekScore(curDifficulty, curDifficulty);

		#if !switch
		intendedScore = Highscore.getWeekScore(curDifficulty, curDifficulty);
		#end
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
}
