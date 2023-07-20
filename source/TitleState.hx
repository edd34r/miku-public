package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.util.FlxTimer;
import openfl.Assets;

using StringTools;
#if windows
import Discord.DiscordClient;
#end

#if windows
import Sys;
import sys.FileSystem;
#end

#if cpp

#end


class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var loadOut:Transition;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var micu:Int = 0;
	public static var bbpanzu:Int = 0;
	var evdial:Int = 0;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	override public function create():Void
	{
		
		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		SaveData.init();
		CoolUtil.setFPSCap(SaveData.framerate);
		#if !FLX_NO_GAMEPAD
		KeyBinds.gamepad = FlxG.gamepads.lastActive != null;
		#end
		
		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		FlxG.game.focusLostFramerate = 30;

		// DEBUG BULLSHIT

		super.create();
		
		Highscore.load();

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		#else
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#end

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		loadOut = new Transition(0,0,'out');
		loadOut.alpha = 0;
		loadOut.scrollFactor.set(0,0);
	}

	var logoBl:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;

	function startIntro()
	{
		if (!initialized)
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		Conductor.changeBPM(71);
		persistentUpdate = true;

		var mikuBG:MikuBG = new MikuBG(0,0);
		add(mikuBG);
		var transparency:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('title/transparency'));
		transparency.setGraphicSize(Std.int(transparency.width * 1.4));
		transparency.updateHitbox();
		transparency.screenCenter();
		transparency.antialiasing = SaveData.antialising;
		add(transparency);

		logoBl = new FlxSprite(100, 0);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = SaveData.antialising;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		add(logoBl);

		titleText = new FlxSprite(500, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('title/start');
		titleText.animation.addByPrefix('idle', "enter", 24);
		titleText.animation.addByPrefix('press', "enter", 24);
		titleText.antialiasing = SaveData.antialising;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));	
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = SaveData.antialising;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		#if desktop
		FlxG.mouse.visible = false;
		#end

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('data/introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		if (FlxG.keys.justPressed.L)
		{
			Sys.command("start assets/data/loid/message.vbs");
		}

		var pressedEnter:Bool = controls.ACCEPT || BSLTouchUtils.justTouched();

		if (FlxG.keys.justPressed.P)
			if (bbpanzu == 0) bbpanzu = 1;
			else bbpanzu == 0;

		if (FlxG.keys.justPressed.A)
			if (bbpanzu == 1) bbpanzu = 2;
			else bbpanzu == 0;
		
		if (FlxG.keys.justPressed.N)
			if (bbpanzu == 2) bbpanzu = 3;
			else bbpanzu == 0;
			
		if (FlxG.keys.justPressed.Z)
			if (bbpanzu == 3) bbpanzu = 4;
			else bbpanzu == 0;

		if (bbpanzu == 4)
		{
			pressedEnter = true;
		}

		if (FlxG.keys.justPressed.E)
			if (evdial == 0) evdial = 1;
			else evdial == 0;

		if (FlxG.keys.justPressed.V)
			if (evdial == 1) evdial = 2;
			else evdial == 0;

		if (evdial == 2)
		{
			PlayState.SONG = Song.loadFromJson('infinite', 'infinite');
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = 1;
			PlayState.storyWeek = 1;
			FlxG.sound.play(Paths.sound('confirmMenu'));
			new FlxTimer().start(0.3, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState());
			});
		}
	

		if (pressedEnter && !transitioning && skippedIntro)
		{
			#if (!switch && newgrounds)
			NGio.unlockMedal(60960);

			// If it's Friday according to da clock
			if (Date.now().getDay() == 5)
				NGio.unlockMedal(61034);
			#end

			titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('startscreenEnter'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			//MainMenuState.firstStart = true;

			

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				add(loadOut);
				loadOut.alpha = 1;
				loadOut.animation.play('transition');
				new FlxTimer().start(1.5, function(tmr:FlxTimer)
					{
						changeState();
					});
			});
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}

		if (pressedEnter && !skippedIntro && initialized)
		{
			skipIntro();
		}

		super.update(elapsed);

		MikuBG.updateTR();
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump');
		danceLeft = !danceLeft;

		//FlxG.log.add(curBeat);

		switch (curBeat)
		{
			case 1:
				createCoolText(['miku']);
			// credTextShit.visible = true;
			case 3:
				addMoreText('mod update');
			// credTextShit.text += '\npresent...';
			// credTextShit.addText();
			case 4:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = 'From the very \nswag';
			// credTextShit.screenCenter();
			case 5:
				createCoolText(['Smokey evdial GenoX', 'BBPanzu and PaperKitty']);
			case 7:
				ngSpr.visible = true;
			// credTextShit.text += '\nNewgrounds';
			case 8:
				deleteCoolText();
				ngSpr.visible = false;
			// credTextShit.visible = false;

			// credTextShit.text = 'Shoutouts Tom Fulp';
			// credTextShit.screenCenter();
			case 9:
				createCoolText([curWacky[0]]);
			// credTextShit.visible = true;
			case 12:
				addMoreText(curWacky[1]);
			// credTextShit.text += '\nlmao';
			case 13:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = "Friday";
			// credTextShit.screenCenter();
			case 14:
				addMoreText('Friday');
			// credTextShit.visible = true;
			case 15:
				addMoreText('Night');
			// credTextShit.text += '\nNight';
			case 16:
				addMoreText('Funkin'); // credTextShit.text += '\nFunkin';

			case 17:
				skipIntro();
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
		}
	}

	function changeState()
	{
		var randomInt:Int = FlxG.random.int(0, 100);
		trace(randomInt);
		if (randomInt < 6)
			FlxG.switchState(new FanState());
		else
			FlxG.switchState(new MainMenuState()); // fail but we go anyway
	}
}
