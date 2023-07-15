package;

import flixel.group.FlxSpriteGroup;
import Song.Event;
import openfl.media.Sound;
import ui.Mobilecontrols;
import openfl.ui.KeyLocation;
import openfl.events.Event;
import haxe.EnumTools;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
#if cpp
import webm.WebmPlayer;
#end
import flixel.input.keyboard.FlxKey;
import haxe.Exception;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import flixel.system.FlxAssets;
import lime.app.Application;
import lime.media.AudioContext;
import lime.media.AudioManager;
import openfl.Lib;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
#if windows
import Discord.DiscordClient;
#end
#if windows
import Sys;
import sys.FileSystem;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;
	private static var loadedStage:String;
	public static var limparCache = false;

	public static var botplay_usado:Bool = false;

	public static var transInAllowed:Bool = false;
	var camFollowAllowed:Bool = true;

	//Custom transition stuff
	var loadOut:Transition;
	var loadIn:Transition;
	//Provavelmente só será usado no freeplay e duas vezes no modo história

	//Hitsound Stuff
	var hitsound:FlxSound;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var weekScore:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;
	var precacheList:Map<String, String> = new Map<String, String>();
	public static var seenCutscene:Bool = false;

	public static var songPosBG:FlxSprite;
	public static var songPosBar:FlxBar;

	public static var inResults:Bool = false;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	public var lyrics:FlxText = new FlxText(0,100,1280,"",37,true);
	public var lyricsArray:Array<String> = [];

	var halloweenLevel:Bool = false;

	var songLength:Float = 0;
	var kadeEngineWatermark:FlxText;

	#if windows
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	private var vocals:FlxSound;

	public var originalX:Float;

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;

	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;

	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public static var playerStrums:FlxTypedGroup<FlxSprite> = null;
	public static var cpuStrums:FlxTypedGroup<FlxSprite> = null;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;

	public var health:Float = 1; // making public because sethealth doesnt work without it

	private var combo:Int = 0;

	public static var misses:Int = 0;
	public static var campaignMisses:Int = 0;
	

	public var accuracy:Float = 0.00;

	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var songPositionBar:Float = 0;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var iconP1:HealthIcon; // making these public again because i may be stupid
	public var iconP2:HealthIcon; // what could go wrong?
	public var camHUD:FlxCamera;

	private var camGame:FlxCamera;
	public var cannotDie = false;

	public static var offsetTesting:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;
	var idleToBeat:Bool = true; // change if bf and dad would idle to the beat of the song
	var idleBeat:Int = 4; // how frequently bf and dad would play their idle animation(1 - every beat, 2 - every 2 beats and so on)

	public var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];

	var halloweenBG:FlxSprite;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;
	var songName:FlxText;
	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var fc:Bool = true;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var fiestaSalsa2:FlxSprite;
	var light1:FlxSprite;
	var fiestaSalsa:FlxSprite;
	var fiestaSalsa3:FlxSprite;
	var simpsBoppers:FlxSprite;
	var bgblack:FlxSprite;

	var perfect:FlxSprite;
	var start:FlxSprite;

	var talking:Bool = true;

	public var songScore:Int = 0;

	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	public static var daPixelZoom:Float = 6;

	public static var theFunne:Bool = true;

	var funneEffect:FlxSprite;
	var inCutscene:Bool = false;
	var usedTimeTravel:Bool = false;

	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;

	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;

	// Will decide if she's even allowed to headbang at all depending on the song
	private var allowedToHeadbang:Bool = false;

	// Per song additive offset
	public static var songOffset:Float = 0;

	// BotPlay text
	public var botPlayState:FlxText;

	public static var highestCombo:Int = 0;

	#if mobileC
	var mcontrols:Mobilecontrols; 
	#end

	private var executeModchart = false;

	// Animation common suffixes
	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	private var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

	public static var startTime = 0.0;

	var giraArray:Array<Int> = [272, 276, 336, 340, 400, 404, 464, 468, 528, 532, 592, 596, 656, 660, 720, 724, 784, 788, 848, 852, 912, 916, 976, 980, 1040, 1044, 1104, 1108,
			1424, 1428, 1488, 1492, 1552, 1556, 1616, 1620];

	// API stuff

	public function addObject(object:FlxBasic)
	{
		add(object);
	}

	public function removeObject(object:FlxBasic)
	{
		remove(object);
	}

	override public function create()
	{
		trace('loaded');
		#if desktop
		FlxG.mouse.visible = false;
		#end
		instance = this;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (!isStoryMode)
		{
			sicks = 0;
			bads = 0;
			shits = 0;
			goods = 0;
		}
		misses = 0;

		highestCombo = 0;
		repPresses = 0;
		repReleases = 0;
		inResults = false;

		PlayStateChangeables.useDownscroll = FlxG.save.data.downscroll;
		PlayStateChangeables.safeFrames = FlxG.save.data.frames;
		PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed;
		botplay_usado = PlayStateChangeables.botPlay = FlxG.save.data.botplay;
		PlayStateChangeables.optimize = FlxG.save.data.optimize;
		PlayStateChangeables.useMiddlescroll = FlxG.save.data.middlescroll;
		

		// pre lowercasing the song name (create)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();

		removedVideo = false;

		#if windows
		executeModchart = FileSystem.exists(Paths.lua(songLowercase + "/modchart"));
		if (executeModchart)
			PlayStateChangeables.optimize = false;
		#end
		#if !cpp
		executeModchart = false; // FORCE disable for non cpp targets
		#end

		//trace('Mod chart: ' + executeModchart + " - " + Paths.lua(songLowercase + "/modchart"));

		#if windows
		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = CoolUtil.difficultyFromInt(storyDifficulty);

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial', 'tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		if (SONG.eventObjects == null)
			{
				SONG.eventObjects = [new Song.Event("Init BPM",0,SONG.bpm,"BPM Change")];
			}
	

		TimingStruct.clearTimings();

		var convertedStuff:Array<Song.Event> = [];

		var currentIndex = 0;
		for (i in SONG.eventObjects)
		{
			var name = Reflect.field(i,"name");
			var type = Reflect.field(i,"type");
			var pos = Reflect.field(i,"position");
			var value = Reflect.field(i,"value");

			if (type == "BPM Change")
			{
                var beat:Float = pos;

                var endBeat:Float = Math.POSITIVE_INFINITY;

                TimingStruct.addTiming(beat,value,endBeat, 0); // offset in this case = start time since we don't have a offset
				
                if (currentIndex != 0)
                {
                    var data = TimingStruct.AllTimings[currentIndex - 1];
                    data.endBeat = beat;
                    data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
					TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
                }

				currentIndex++;
			}
			convertedStuff.push(new Song.Event(name,pos,value,type));
		}

		SONG.eventObjects = convertedStuff;

		//trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + PlayStateChangeables.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: '
		//	+ Conductor.timeScale + '\nBotPlay : ' + PlayStateChangeables.botPlay);

		// dialogue shit
		
			if(songLowercase == 'endless')
			{
				lyrics.scrollFactor.set();
				lyrics.cameras = [camHUD];
				lyricsArray = CoolUtil.coolTextFile(Paths.txt("data/endless/endlessLyrics"));
				lyrics.alignment = FlxTextAlign.CENTER;
				lyrics.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
				lyrics.borderSize = 1;
				lyrics.font = 'Funkin';
				lyrics.x += 35;
				if (PlayStateChangeables.useDownscroll)
				{
					lyrics.y += 65;
				}
				else
				{
					lyrics.y += 450;
				}
			}

		// defaults if no stage was found in chart
		var stageCheck:String = 'stage';

		if (SONG.stage == null)
		{
			switch (storyWeek)
			{
				case 1:
					if (songLowercase == 'endless')
					{
						stageCheck = 'endless';
					}
					else if (songLowercase == 'voca')
					{
						stageCheck = 'expo-two';
					}
					else
					{
						stageCheck = 'expo';
					}
				case 2:
					stageCheck = 'concert';
			}
		}
		else
		{
			stageCheck = SONG.stage;
		}

		if (!PlayStateChangeables.optimize)
		{
			switch (stageCheck)
			{
					case 'videobg':
						curStage = 'videobg';
						camFollowAllowed = false; //Não é o mais eficiente mas é o mais fácil.
						defaultCamZoom = 1.6;
						camHUD.alpha = 0;

					case 'expo':
					{
						curStage = 'expo';

						defaultCamZoom = 0.80;

						var bg2:FlxSprite = new FlxSprite(-280, -100).loadGraphic(Paths.image('expo/nightsky'));
						bg2.antialiasing = FlxG.save.data.antialiasing;
						bg2.scrollFactor.set(0.6, 0.6);
						bg2.setGraphicSize(Std.int(bg2.width * 1.1));
						bg2.active = false;
						add(bg2);

						var bg1:FlxSprite = new FlxSprite(-285, -100).loadGraphic(Paths.image('expo/backlight'));
						bg1.antialiasing = FlxG.save.data.antialiasing;
						bg1.scrollFactor.set(0.7, 0.7);
						bg1.setGraphicSize(Std.int(bg1.width * 1.1));
						bg1.active = false;
						add(bg1);

						var bg4:FlxSprite = new FlxSprite(-285, -100).loadGraphic(Paths.image('expo/concerttop'));
						bg4.antialiasing = FlxG.save.data.antialiasing;
						bg4.scrollFactor.set(0.75, 0.75);
						bg4.setGraphicSize(Std.int(bg4.width * 1.1));
						bg4.active = false;
						add(bg4);

						var bg3:FlxSprite = new FlxSprite(-420, -100).loadGraphic(Paths.image('expo/stadiumback'));
						bg3.antialiasing = FlxG.save.data.antialiasing;
						bg3.scrollFactor.set(0.8, 0.8);
						bg3.setGraphicSize(Std.int(bg3.width * 1.1));
						bg3.active = false;
						add(bg3);

						var bg5:FlxSprite = new FlxSprite(-285, -100).loadGraphic(Paths.image('expo/speakers'));
						bg5.antialiasing = FlxG.save.data.antialiasing;
						bg5.scrollFactor.set(0.9, 0.9);
						bg5.setGraphicSize(Std.int(bg5.width * 1.1));
						bg5.active = false;
						add(bg5);

						var bg:FlxSprite = new FlxSprite(-285, -100).loadGraphic(Paths.image('expo/mainstage'));
						bg.antialiasing = FlxG.save.data.antialiasing;
						bg.setGraphicSize(Std.int(bg.width * 1.1));
						bg.active = false;
						add(bg);

						fiestaSalsa2 = new FlxSprite(-295, 645);
						fiestaSalsa2.frames = Paths.getSparrowAtlas('expo/crowdbump');
						fiestaSalsa2.animation.addByPrefix('dance', "crowdbump", 24, false);
						fiestaSalsa2.animation.addByPrefix('cheer', "crowdcheer", 24, false);
						fiestaSalsa2.animation.addByPrefix('miss', "crowdmiss", 24, false);
						fiestaSalsa2.antialiasing = FlxG.save.data.antialiasing;
						fiestaSalsa2.scrollFactor.set(0.9, 0.9);
						fiestaSalsa2.setGraphicSize(Std.int(fiestaSalsa2.width * 1.5));
						fiestaSalsa2.updateHitbox();

						light1 = new FlxSprite(10, 0).loadGraphic(Paths.image('expo/chance/focus_light'));
						light1.antialiasing = FlxG.save.data.antialiasing;
						light1.scrollFactor.set(0.95, 0.95);
						light1.setGraphicSize(Std.int(light1.width * 1.60));

						fiestaSalsa = new FlxSprite(-1000, -100);
						fiestaSalsa.frames = Paths.getSparrowAtlas('expo/spotlightdance');
						fiestaSalsa.animation.addByIndices('light1', 'spotlightdance1', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13], "", 24, false);
						fiestaSalsa.animation.addByIndices('light2', 'spotlightdance1', [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26], "", 24, false);
						fiestaSalsa.antialiasing = FlxG.save.data.antialiasing;
						fiestaSalsa.scrollFactor.set(0.9, 0.9);
						fiestaSalsa.setGraphicSize(Std.int(fiestaSalsa.width * 1.30));
						fiestaSalsa.updateHitbox();

						bgblack = new FlxSprite(10, 0).loadGraphic(Paths.image('expo/chance/blacksocool'));
						bgblack.alpha = 0;
						bgblack.antialiasing = FlxG.save.data.antialiasing;
						bgblack.scrollFactor.set(0.8, 0.8);
						bgblack.setGraphicSize(Std.int(bgblack.width * 1.60));
					}
					case 'expo-two':
					{
						curStage = 'expo-two';

						defaultCamZoom = 0.80;

						var bg2:FlxSprite = new FlxSprite(-280, -100).loadGraphic(Paths.image('expo/voca/nightsky'));
						bg2.antialiasing = FlxG.save.data.antialiasing;
						bg2.scrollFactor.set(0.6, 0.6);
						bg2.setGraphicSize(Std.int(bg2.width * 1.1));
						bg2.active = false;
						add(bg2);

						var bg1:FlxSprite = new FlxSprite(-285, -100).loadGraphic(Paths.image('expo/voca/backlight'));
						bg1.antialiasing = FlxG.save.data.antialiasing;
						bg1.scrollFactor.set(0.7, 0.7);
						bg1.setGraphicSize(Std.int(bg1.width * 1.1));
						bg1.active = false;
						add(bg1);

						var bg4:FlxSprite = new FlxSprite(-285, -100).loadGraphic(Paths.image('expo/voca/concerttop'));
						bg4.antialiasing = FlxG.save.data.antialiasing;
						bg4.scrollFactor.set(0.75, 0.75);
						bg4.setGraphicSize(Std.int(bg4.width * 1.1));
						bg4.active = false;
						add(bg4);

						var bg3:FlxSprite = new FlxSprite(-420, -100).loadGraphic(Paths.image('expo/voca/stadiumback'));
						bg3.antialiasing = FlxG.save.data.antialiasing;
						bg3.scrollFactor.set(0.8, 0.8);
						bg3.setGraphicSize(Std.int(bg3.width * 1.1));
						bg3.active = false;
						add(bg3);

						var bg5:FlxSprite = new FlxSprite(-285, -100).loadGraphic(Paths.image('expo/voca/speakers'));
						bg5.antialiasing = FlxG.save.data.antialiasing;
						bg5.scrollFactor.set(0.9, 0.9);
						bg5.setGraphicSize(Std.int(bg5.width * 1.1));
						bg5.active = false;
						add(bg5);

						var bg:FlxSprite = new FlxSprite(-285, -100).loadGraphic(Paths.image('expo/voca/mainstage'));
						bg.antialiasing = FlxG.save.data.antialiasing;
						bg.setGraphicSize(Std.int(bg.width * 1.1));
						bg.active = false;
						add(bg);

						fiestaSalsa2 = new FlxSprite(-295, 665);
						fiestaSalsa2.frames = Paths.getSparrowAtlas('expo/voca/crowd');
						fiestaSalsa2.animation.addByPrefix('dance', "crowdbump", 24, false);
						fiestaSalsa2.animation.addByPrefix('cheer', "crowdcheer", 24, false);
						fiestaSalsa2.animation.addByPrefix('miss', "crowdmiss", 24, false);
						fiestaSalsa2.antialiasing = FlxG.save.data.antialiasing;
						fiestaSalsa2.scrollFactor.set(0.9, 0.9);
						fiestaSalsa2.setGraphicSize(Std.int(fiestaSalsa2.width * 1.5));
						fiestaSalsa2.updateHitbox();

						fiestaSalsa = new FlxSprite(-1000, -100);
						fiestaSalsa.frames = Paths.getSparrowAtlas('expo/spotlightdance');
						fiestaSalsa.animation.addByIndices('light1', 'spotlightdance1', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13], "", 24, false);
						fiestaSalsa.animation.addByIndices('light2', 'spotlightdance1', [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26], "", 24, false);
						fiestaSalsa.antialiasing = FlxG.save.data.antialiasing;
						fiestaSalsa.scrollFactor.set(0.9, 0.9);
						fiestaSalsa.setGraphicSize(Std.int(fiestaSalsa.width * 1.30));
						fiestaSalsa.updateHitbox();

						bgblack = new FlxSprite(10, 0).loadGraphic(Paths.image('expo/chance/blacksocool'));
						bgblack.alpha = 0;
						bgblack.antialiasing = FlxG.save.data.antialiasing;
						bgblack.scrollFactor.set(0.8, 0.8);
						bgblack.setGraphicSize(Std.int(bgblack.width * 1.60));

						light1 = new FlxSprite(10, 0).loadGraphic(Paths.image('expo/voca/hell'));
						light1.antialiasing = FlxG.save.data.antialiasing;
						light1.setGraphicSize(Std.int(light1.width * 1.60));
						light1.screenCenter();

					}
					case 'endless':
					{
						curStage = 'endless';

						defaultCamZoom = 0.80;

						var bg2:FlxSprite = new FlxSprite(-280, -100).loadGraphic(Paths.image('expo/nightsky'));
						bg2.antialiasing = FlxG.save.data.antialiasing;
						bg2.scrollFactor.set(0.6, 0.6);
						bg2.setGraphicSize(Std.int(bg2.width * 1.1));
						bg2.active = false;
						add(bg2);

						var bg1:FlxSprite = new FlxSprite(-285, -100).loadGraphic(Paths.image('expo/backlight'));
						bg1.antialiasing = FlxG.save.data.antialiasing;
						bg1.scrollFactor.set(0.7, 0.7);
						bg1.setGraphicSize(Std.int(bg1.width * 1.1));
						bg1.active = false;
						add(bg1);

						var bg4:FlxSprite = new FlxSprite(-285, -100).loadGraphic(Paths.image('expo/concerttop'));
						bg4.antialiasing = FlxG.save.data.antialiasing;
						bg4.scrollFactor.set(0.75, 0.75);
						bg4.setGraphicSize(Std.int(bg4.width * 1.1));
						bg4.active = false;
						add(bg4);

						var bg3:FlxSprite = new FlxSprite(-420, -100).loadGraphic(Paths.image('expo/stadiumback'));
						bg3.antialiasing = FlxG.save.data.antialiasing;
						bg3.scrollFactor.set(0.8, 0.8);
						bg3.setGraphicSize(Std.int(bg3.width * 1.1));
						bg3.active = false;
						add(bg3);

						var bg5:FlxSprite = new FlxSprite(-285, -100).loadGraphic(Paths.image('expo/speakers'));
						bg5.antialiasing = FlxG.save.data.antialiasing;
						bg5.scrollFactor.set(0.9, 0.9);
						bg5.setGraphicSize(Std.int(bg5.width * 1.1));
						bg5.active = false;
						add(bg5);

						var bg:FlxSprite = new FlxSprite(-285, -100).loadGraphic(Paths.image('expo/mainstage'));
						bg.antialiasing = FlxG.save.data.antialiasing;
						bg.setGraphicSize(Std.int(bg.width * 1.1));
						bg.active = false;
						add(bg);

						fiestaSalsa3 = new FlxSprite(-300, 10);
						fiestaSalsa3.frames = Paths.getSparrowAtlas('expo/chance/endless');
						fiestaSalsa3.animation.addByPrefix('deeznuts', "golf chance time", 35, false);
						fiestaSalsa3.antialiasing = FlxG.save.data.antialiasing;
						fiestaSalsa3.scrollFactor.set(0.8, 0.8);
						fiestaSalsa3.setGraphicSize(Std.int(fiestaSalsa3.width * 1.35));
						fiestaSalsa3.updateHitbox();
						add(fiestaSalsa3);

					//	fiestaSalsa2 = new FlxSprite(-270, 670);
					//	fiestaSalsa2.frames = Paths.getSparrowAtlas('expo/crowdbump');
					//	fiestaSalsa2.animation.addByPrefix('dance', "crowdbump", 24, false);
					//	fiestaSalsa2.antialiasing = FlxG.save.data.antialiasing;
					//	fiestaSalsa2.scrollFactor.set(0.85, 0.85);
					//	fiestaSalsa2.setGraphicSize(Std.int(fiestaSalsa2.width * 1.4));
					//	fiestaSalsa2.updateHitbox();

					}
					case 'concert':
					{
						curStage = 'concert';

						defaultCamZoom = 0.80;

						var bg2:FlxSprite = new FlxSprite(-280, -100).loadGraphic(Paths.image('expo/nightsky'));
						bg2.antialiasing = FlxG.save.data.antialiasing;
						bg2.scrollFactor.set(0.6, 0.6);
						bg2.setGraphicSize(Std.int(bg2.width * 1.1));
						bg2.active = false;
						add(bg2);

						var bg1:FlxSprite = new FlxSprite(-285, -100).loadGraphic(Paths.image('expo/backlight'));
						bg1.antialiasing = FlxG.save.data.antialiasing;
						bg1.scrollFactor.set(0.7, 0.7);
						bg1.setGraphicSize(Std.int(bg1.width * 1.1));
						bg1.active = false;
						add(bg1);

						var bg4:FlxSprite = new FlxSprite(-285, -100).loadGraphic(Paths.image('expo/concerttop'));
						bg4.antialiasing = FlxG.save.data.antialiasing;
						bg4.scrollFactor.set(0.75, 0.75);
						bg4.setGraphicSize(Std.int(bg4.width * 1.1));
						bg4.active = false;
						add(bg4);

						var bg3:FlxSprite = new FlxSprite(-420, -100).loadGraphic(Paths.image('expo/stadiumback'));
						bg3.antialiasing = FlxG.save.data.antialiasing;
						bg3.scrollFactor.set(0.8, 0.8);
						bg3.setGraphicSize(Std.int(bg3.width * 1.1));
						bg3.active = false;
						add(bg3);

						var bg5:FlxSprite = new FlxSprite(-285, -100).loadGraphic(Paths.image('expo/speakers'));
						bg5.antialiasing = FlxG.save.data.antialiasing;
						bg5.scrollFactor.set(0.9, 0.9);
						bg5.setGraphicSize(Std.int(bg5.width * 1.1));
						bg5.active = false;
						add(bg5);

						var bg:FlxSprite = new FlxSprite(-285, -100).loadGraphic(Paths.image('expo/mainstage'));
						bg.antialiasing = FlxG.save.data.antialiasing;
						bg.setGraphicSize(Std.int(bg.width * 1.1));
						bg.active = false;
						add(bg);

						simpsBoppers = new FlxSprite(-250, 678);
						simpsBoppers.frames = Paths.getSparrowAtlas('concert/bunch_of_simps');
						simpsBoppers.animation.addByPrefix('bop2', "Downer Crowd Bob", 24, false);
						simpsBoppers.antialiasing = FlxG.save.data.antialiasing;
						simpsBoppers.scrollFactor.set(0.85, 0.85);
						simpsBoppers.setGraphicSize(Std.int(simpsBoppers.width * 1.10));
						simpsBoppers.updateHitbox();
						add(simpsBoppers);
					}
				default:
					{
						curStage = 'stage';
						defaultCamZoom = 0.80;

						var bg2:FlxSprite = new FlxSprite(-280, -100).loadGraphic(Paths.image('expo/nightsky'));
						bg2.antialiasing = FlxG.save.data.antialiasing;
						bg2.scrollFactor.set(0.6, 0.6);
						bg2.setGraphicSize(Std.int(bg2.width * 1.1));
						bg2.active = false;
						add(bg2);

						var bg1:FlxSprite = new FlxSprite(-285, -100).loadGraphic(Paths.image('expo/backlight'));
						bg1.antialiasing = FlxG.save.data.antialiasing;
						bg1.scrollFactor.set(0.7, 0.7);
						bg1.setGraphicSize(Std.int(bg1.width * 1.1));
						bg1.active = false;
						add(bg1);

						var bg4:FlxSprite = new FlxSprite(-285, -100).loadGraphic(Paths.image('expo/concerttop'));
						bg4.antialiasing = FlxG.save.data.antialiasing;
						bg4.scrollFactor.set(0.75, 0.75);
						bg4.setGraphicSize(Std.int(bg4.width * 1.1));
						bg4.active = false;
						add(bg4);

						var bg3:FlxSprite = new FlxSprite(-420, -100).loadGraphic(Paths.image('expo/stadiumback'));
						bg3.antialiasing = FlxG.save.data.antialiasing;
						bg3.scrollFactor.set(0.8, 0.8);
						bg3.setGraphicSize(Std.int(bg3.width * 1.1));
						bg3.active = false;
						add(bg3);

						var bg5:FlxSprite = new FlxSprite(-285, -100).loadGraphic(Paths.image('expo/speakers'));
						bg5.antialiasing = FlxG.save.data.antialiasing;
						bg5.scrollFactor.set(0.9, 0.9);
						bg5.setGraphicSize(Std.int(bg5.width * 1.1));
						bg5.active = false;
						add(bg5);

						var bg:FlxSprite = new FlxSprite(-285, -100).loadGraphic(Paths.image('expo/mainstage'));
						bg.antialiasing = FlxG.save.data.antialiasing;
						bg.setGraphicSize(Std.int(bg.width * 1.1));
						bg.active = false;
						add(bg);
					}
			}
			loadedStage = curStage;
		}
		// defaults if no gf was found in chart
		var gfCheck:String = 'gf';

		if (SONG.gfVersion == null)
		{
			switch (storyWeek)
			{
				case 1:
					gfCheck = 'gf-expo';
				case 2:
					gfCheck = 'gf-expo';
			}
		}
		else
		{
			gfCheck = SONG.gfVersion;
		}

		var curGf:String = '';
		switch (gfCheck)
		{
			case 'gf-expo':
				curGf = 'gf-expo';
			case 'gf-voca':
				curGf = 'gf-voca';
			case 'carol':
				curGf = 'carol';
			case 'invisibru':
				curGf = 'invisibru';
			default:
				curGf = 'gf-expo';
		}

		gf = new Character(400, 130, curGf);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = FlxPoint.get(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'expo':
				boyfriend.x += 100;
				gf.y -= 30;
			case 'expo-two':
				boyfriend.x += 100;
				boyfriend.y -= 150;
				gf.y -= 30;
			case 'endless':
				boyfriend.x += 100;
				boyfriend.y -= 340;
			case 'stage':
				boyfriend.x += 100;
				boyfriend.y -= 340;
				dad.y += 92;
				gf.y -= 30;
		}

		if (!PlayStateChangeables.optimize)
		{
			add(gf);

			// Shitty layering but whatev it works LOL
			if (curStage != 'endless')
				add(dad);

			add(boyfriend);
			if (curStage.startsWith('expo'))
				if(FlxG.save.data.distractions){
					add(fiestaSalsa2);
					add(light1);
					add(fiestaSalsa);
					add(bgblack);
					fiestaSalsa.visible = true;
					light1.visible = true;
					bgblack.visible = true;
					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						fiestaSalsa.visible = false;
						if (curSong != 'Voca')
						{
							light1.visible = false;
						}
						bgblack.visible = false;
					});
				}
			perfect = new FlxSprite(0, 0);
			perfect.frames = Paths.getSparrowAtlas('expo/chance/Perfect');
			perfect.animation.addByPrefix('perfect', "Perfect", 24, false);
			perfect.antialiasing = FlxG.save.data.antialiasing;
			perfect.screenCenter();
			perfect.updateHitbox();
			add(perfect);
			perfect.visible = true;
			new FlxTimer().start(0.1, function(tmr:FlxTimer)
			{
				perfect.visible = false;
			});

			start = new FlxSprite(500, 0);
			start.frames = Paths.getSparrowAtlas('expo/Songs/songstart');
			start.animation.addByPrefix('Tutorial', 'Tutorial', 1, true);
			start.animation.addByPrefix('Loid', 'Loid', 1, true);
			start.animation.addByPrefix('Endurance', 'Endurance', 1, true);
			start.animation.addByPrefix('Voca', 'Voca', 1, true);
			start.animation.addByPrefix('Endless', 'Endless', 1, true);
			start.animation.addByPrefix('PoPiPo', 'PoPiPo', 1, true);
			start.animation.addByPrefix('Aishite', 'Aishite', 1, true);
			start.animation.addByPrefix('SIU', 'SIU', 1, true);
			start.animation.addByPrefix('Disappearance', 'Disappearance', 1, true);
			start.animation.addByPrefix('Secret', 'Secret', 1, true);
			start.animation.addByPrefix('Rolling', 'Rolling', 1, true);
			start.animation.addByPrefix('Dwelling', 'Dwelling', 1, true);
			start.animation.addByPrefix('Anamanaguchi', 'Anamanaguchi', 1, true);
			start.antialiasing = FlxG.save.data.antialiasing;
			start.screenCenter(Y);
			start.updateHitbox();
			add(start);
			start.visible = false;
		}

		if (curStage == 'videobg'){
			boyfriend.visible = false;
			dad.visible = false;
			gf.visible = false;
		}

		//trace('uh ' + PlayStateChangeables.safeFrames);

		//trace("SF CALC: " + Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (PlayStateChangeables.useDownscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		if (curStage != 'endless')
			generateStaticArrows(0);

		generateStaticArrows(1);

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);
		camPos.put();

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (PlayStateChangeables.useDownscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		if (curSong != 'Rolling')
			add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		if (curSong != 'Rolling')
			add(healthBar);

		// Add Kade Engine watermark
	//	kadeEngineWatermark = new FlxText(4, healthBarBG.y
	//		+ 50, 0,
	//		SONG.song
	//		+ " - "
	//		+ CoolUtil.difficultyFromInt(storyDifficulty)
	//		+ (Main.watermarks ? " | KE " + MainMenuState.kadeEngineVer : ""), 16);
	//	kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	//	kadeEngineWatermark.scrollFactor.set();
	//	add(kadeEngineWatermark);

	//	if (PlayStateChangeables.useDownscroll)
	//		kadeEngineWatermark.y = FlxG.height * 0.9 + 45;

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 20);

		scoreTxt.screenCenter(X);

		originalX = scoreTxt.x;

		scoreTxt.scrollFactor.set();

		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		if (curSong != 'Rolling')
			add(scoreTxt);

		// Literally copy-paste of the above, fu
		botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0,
			"BOTPLAY", 20);
		botPlayState.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botPlayState.scrollFactor.set();
		botPlayState.borderSize = 4;
		botPlayState.borderQuality = 2;
		botPlayState.visible = PlayStateChangeables.botPlay;
		add(botPlayState);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		if (curSong != 'Rolling')
			add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		if (curSong != 'Rolling')
			add(iconP2);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		if (curSong == 'Voca' && light1 != null)
		{
			light1.cameras = [camHUD];
		}
		perfect.cameras = [camHUD];
		start.cameras = [camHUD];
		doof.cameras = [camHUD];

	//	kadeEngineWatermark.cameras = [camHUD];

		add(lyrics);

		#if mobileC
			mcontrols = new Mobilecontrols();
			switch (mcontrols.mode)
			{
				case VIRTUALPAD_RIGHT | VIRTUALPAD_LEFT | VIRTUALPAD_CUSTOM:
					controls.setVirtualPad(mcontrols._virtualPad, FULL, NONE);
				case HITBOX:
					controls.setHitBox(mcontrols._hitbox);
				default:
			}
			trackedinputs = controls.trackedinputs;
			controls.trackedinputs = [];

			var camcontrol = new FlxCamera();
			FlxG.cameras.add(camcontrol);
			camcontrol.bgColor.alpha = 0;
			mcontrols.cameras = [camcontrol];

			mcontrols.visible = false;

			add(mcontrols);
		#end


		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode && !seenCutscene)
		{
			switch (StringTools.replace(curSong, " ", "-").toLowerCase())
			{
				case "popipo":
					defaultCamZoom = 1.1;
					FlxG.sound.play(Paths.sound('cheeringppl', 'shared'));
					camFollowAllowed = false;
					var ato:Int = 0;
					var mikuIntro:FlxSprite = new FlxSprite(dad.x, dad.y);
					dad.visible = false;
					mikuIntro.frames = Paths.getSparrowAtlas('concert/mikuintro');
					mikuIntro.animation.addByPrefix('introAnim', 'miku intro instance 1', 24, false);
					mikuIntro.animation.addByPrefix('nextAnim', 'miku bro instance 1', 24, false);
					add(mikuIntro);
					mikuIntro.animation.play('introAnim');
					mikuIntro.animation.finishCallback = function(huh:String){
						if (ato == 0){
							mikuIntro.animation.play('nextAnim');
							camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
							defaultCamZoom = 1.3;
							FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
							new FlxTimer().start(1, function(tmr:FlxTimer)
								{
									boyfriend.playAnim('hey', true);
								});
								ato = 1;
						}else{
							dad.visible = true;
							remove(mikuIntro);
							mikuIntro.kill();
							mikuIntro.destroy();
							camHUD.visible = true;
							startCountdown();
							defaultCamZoom = 0.8;
							camFollowAllowed = true;
						}
					};

				case "disappearance":
					defaultCamZoom = 1.2;
					camHUD.visible = false;
					FlxG.sound.play(Paths.sound('mikumic', 'shared'));
					boyfriend.playAnim('scared', true);
					camFollowAllowed = false;
					var mikuIntro:FlxSprite = new FlxSprite(dad.x, dad.y);
					camFollow.setPosition(dad.getMidpoint().x - 100, dad.getMidpoint().y - 100);
					FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
					dad.visible = false;
					mikuIntro.frames = Paths.getSparrowAtlas('concert/mikumadone');
					mikuIntro.animation.addByPrefix('introAnim', 'miku intro challenge 1', 24, false);
					add(mikuIntro);
					mikuIntro.animation.play('introAnim');
					mikuIntro.animation.finishCallback = function(huh:String){
							dad.visible = true;
							remove(mikuIntro);
							mikuIntro.kill();
							mikuIntro.destroy();
							camHUD.visible = true;
							startCountdown();
							defaultCamZoom = 0.8;
							camFollowAllowed = true;
					};
				default:
					startCountdown();
			}
			seenCutscene = true;
		}
		else
		{
			switch (StringTools.replace(curSong," ", "-").toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		if ((!isStoryMode || transInAllowed) && !seenCutscene){
			loadIn = new Transition(0,0,'in');
			loadIn.animation.finishCallback = function(huh:String){
			remove(loadIn);
			};
			loadIn.cameras = [camHUD];
			loadIn.scrollFactor.set(0,0);
			transInAllowed = false;
			
			add(loadIn);
			loadIn.animation.play('transition');
		}

		if (!isStoryMode || curSong.toLowerCase()=='voca' || curSong.toLowerCase()=='tutorial' || curSong.toLowerCase()=='disappearance')
		{
			loadOut = new Transition(0,0,'out');
			loadOut.visible = false;
			loadOut.scrollFactor.set(0,0);
			loadOut.cameras = [camHUD];
			add(loadOut);
		}

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		if(FlxG.save.data.hitSoundVolume > 0){
			hitsound = new FlxSound().loadEmbedded(Paths.sound('osu/' + Std.string(FlxG.save.data.hitSound), 'preload'));
			hitsound.volume = Std.int(FlxG.save.data.hitSoundVolume/10);
		}
		
		if(FlxG.save.data.missSounds){
			precacheList.set('missnote1', 'sound');
			precacheList.set('missnote2', 'sound');
			precacheList.set('missnote3', 'sound');
		}
		precacheList.set('breakfast', 'music');

		precacheList.set('alphabet', 'image');

		super.create();
		cacheCountdown();
		cachePopUpScore();

		for (key => type in precacheList)
			{
				//trace('Key $key is type $type');
				switch(type)
				{
					case 'image':
						Paths.image(key);
					case 'sound':
						Paths.sound(key);
					case 'music':
						Paths.music(key);
				}
			}


		limparCache = false;
	}

	private function cachePopUpScore()
	{
		var pixelShitPart1:String = '';
		var pixelShitPart2:String = '';

		Paths.image(pixelShitPart1 + "sick" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "good" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "bad" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "shit" + pixelShitPart2);
		
		for (i in 0...10) {
			Paths.image(pixelShitPart1 + 'num' + i + pixelShitPart2);
		}
	}

	function cacheCountdown()
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		introAssets.set('default', ['ready', 'set', 'go']);
		introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

		var introAlts:Array<String> = introAssets.get('default');
		
		for (asset in introAlts)
			Paths.image(asset);
		
		Paths.sound('intro3');
		Paths.sound('intro2');
		Paths.sound('intro1');
		Paths.sound('introGo');
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	var luaWiggles:Array<WiggleEffect> = [];

	#if windows
	public static var luaModchart:ModchartState = null;
	#end

	function three():Void
		{
			var three:FlxSprite = new FlxSprite().loadGraphic(Paths.image('three', 'shared'));
			three.scrollFactor.set();
			three.updateHitbox();
			three.screenCenter();
			three.y -= 100;
			three.alpha = 0.5;
					add(three);
					FlxTween.tween(three, {y: three.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							three.destroy();
						}
					});
		}

	function two():Void
		{
			var two:FlxSprite = new FlxSprite().loadGraphic(Paths.image('two', 'shared'));
			two.scrollFactor.set();
			two.screenCenter();
			two.y -= 100;
			two.alpha = 0.5;
					add(two);
					FlxTween.tween(two, {y: two.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							two.destroy();
						}
					});
					
		}

		function one():Void
			{
				var one:FlxSprite = new FlxSprite().loadGraphic(Paths.image('one', 'shared'));
				one.scrollFactor.set();
				one.screenCenter();
				one.y -= 100;
				one.alpha = 0.5;

						add(one);
						FlxTween.tween(one, {y: one.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								one.destroy();
							}
						});
						
			}
	
	function gofun():Void
		{
			var gofun:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gofun', 'shared'));
			gofun.scrollFactor.set();

			gofun.updateHitbox();

			gofun.screenCenter();
			gofun.y -= 100;
			gofun.alpha = 0.5;

					add(gofun);
					FlxTween.tween(gofun, {y: gofun.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							gofun.destroy();
						}
					});
		}

	function startCountdown():Void
	{
		#if mobileC
		mcontrols.visible = true;
		#end

		inCutscene = false;
		start.visible = true;
		if (curSong == 'Chug' || curSong == 'Infinite') {
			start.animation.play('Secret');
		}
		else
		start.animation.play(curSong);
		FlxTween.tween(start, {alpha: 1, x: 0}, 0.5, {ease: FlxEase.quartInOut,startDelay: 0.2});
		new FlxTimer().start(3, function(tmr:FlxTimer)
			{
				FlxTween.tween(start,{alpha:0,x:start.x + 100},0.5,{ease:FlxEase.quartInOut,
				onComplete:function(twn:FlxTween){
					remove(start);
					}
				});
			});
		

		appearStaticArrows();
		//generateStaticArrows(0);
		//generateStaticArrows(1);

		if (startTime != 0)
		{
			var toBeRemoved = [];
			for(i in 0...unspawnNotes.length)
			{
				var dunceNote:Note = unspawnNotes[i];

				if (dunceNote.strumTime - startTime <= 0)
					toBeRemoved.push(dunceNote);
				else if (dunceNote.strumTime - startTime < 3500)
				{
					notes.add(dunceNote);

					if (dunceNote.mustPress)
						dunceNote.y = (playerStrums.members[Math.floor(Math.abs(dunceNote.noteData))].y
							+ 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
								2)) - dunceNote.noteYOff;
					else
						dunceNote.y = (strumLineNotes.members[Math.floor(Math.abs(dunceNote.noteData))].y
							+ 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
								2)) - dunceNote.noteYOff;
					toBeRemoved.push(dunceNote);
				}
			}

			for(i in toBeRemoved)
				unspawnNotes.remove(i);
		}

		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		#if windows
		// pre lowercasing the song name (startCountdown)
		if (executeModchart)
		{
			luaModchart = ModchartState.createModchartState();
			luaModchart.executeState('start', [songLowercase]);
		}
		#end
		
		if (curStage == 'videobg')
			backgroundVideo("assets/videos/" + 'rolling_girl' + ".webm");

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					trace(value + " - " + curStage);
					introAlts = introAssets.get(value);
					if (curStage.contains('school'))
						altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	private function getKey(charCode:Int):String
	{
		for (key => value in FlxKey.fromStringMap)
		{
			if (charCode == value)
				return key;
		}
		return null;
	}

	var keys = [false, false, false, false];

	private function releaseInput(evt:KeyboardEvent):Void // handles releases
	{
		@:privateAccess
		var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		switch (evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}

		if (data == -1)
			return;

		keys[data] = false;
	}

	private function handleInput(evt:KeyboardEvent):Void
	{ // this actually handles press inputs

		if (PlayStateChangeables.botPlay || paused)
			return;

		// first convert it from openfl to a flixel key code
		// then use FlxKey to get the key's name based off of the FlxKey dictionary
		// this makes it work for special characters

		@:privateAccess
		var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		switch (evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}
		if (data == -1)
		{
			//trace("couldn't find a keybind with the code " + key);
			return;
		}
		if (keys[data])
		{
			//trace("ur already holding " + key);
			return;
		}

		keys[data] = true;

		var dataNotes = [];
		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && daNote.noteData == data)
				dataNotes.push(daNote);
		}); // Collect notes that can be hit

		dataNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime)); // sort by the earliest note

		if (dataNotes.length != 0)
		{
			var coolNote = null;

			for (i in dataNotes)
				if (!i.isSustainNote)
				{
					coolNote = i;
					break;
				}

			if (coolNote == null) // Note is null, which means it's probably a sustain note. Update will handle this (HOPEFULLY???)
			{
				return;
			}

			if (dataNotes.length > 1) // stacked notes or really close ones
			{
				for (i in 0...dataNotes.length)
				{
					if (i == 0) // skip the first note
						continue;

					var note = dataNotes[i];

					if (!note.isSustainNote && (note.strumTime - coolNote.strumTime) < 2)
					{
						//trace('found a stacked/really close note ' + (note.strumTime - coolNote.strumTime));
						// just fuckin remove it since it's a stacked note and shouldn't be there
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
				}
			}

			goodNoteHit(coolNote);
			var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
		}
		else if (!FlxG.save.data.ghost && songStarted)
		{
			noteMiss(data, null);
			health -= 0.10;
		}
	}

	var songStarted = false;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);

		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		if (FlxG.save.data.songPosition && curSong != 'Rolling')
		{
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x
				+ 4, songPosBG.y
				+ 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength
				- 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.song.length * 5), songPosBG.y, 0, SONG.song, 16);
			if (PlayStateChangeables.useDownscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}

		// Song check real quick
		switch (curSong)
		{
			case 'Bopeebo' | 'Philly Nice' | 'Blammed' | 'Cocoa' | 'Eggnog':
				allowedToHeadbang = true;
			default:
				allowedToHeadbang = false;
		}

		if (useVideo)
			GlobalVideo.get().resume();

		#if windows
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		FlxG.sound.music.time = startTime;
		vocals.time = startTime;
		Conductor.songPosition = startTime;
		startTime = 0;

		for(i in 0...unspawnNotes.length)
			if (unspawnNotes[i].strumTime < startTime)
				unspawnNotes.remove(unspawnNotes[i]);
	}

	var debugNum:Int = 0;

	public function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);
		var tempMusic:FlxSound = new FlxSound().loadEmbedded(Paths.inst(SONG.song));
		//Honestamente, não entendi o motivo pra carregar o inst de novo...

		// Song duration in a float, useful for the time left feature
		songLength = tempMusic.length / 1000;

		tempMusic.destroy();

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		// Per song offset check
		#if windows
		// pre lowercasing the song name (generateSong)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase)
		{
			case 'dad-battle':
				songLowercase = 'dadbattle';
			case 'philly-nice':
				songLowercase = 'philly';
		}

		var songPath = 'assets/data/' + songLowercase + '/';

		for (file in sys.FileSystem.readDirectory(songPath))
		{
			var path = haxe.io.Path.join([songPath, file]);
			if (!sys.FileSystem.isDirectory(path))
			{
				if (path.endsWith('.offset'))
				{
					//trace('Found offset file: ' + path);
					songOffset = Std.parseFloat(file.substring(0, file.indexOf('.off')));
					break;
				}
				else
				{
					//trace('Offset file not found. Creating one @: ' + songPath);
					sys.io.File.saveContent(songPath + songOffset + '.offset', '');
				}
			}
		}
		#end
		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped


		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset + songOffset;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var susLength:Float = Math.round(songNotes[2] / Conductor.stepCrochet);

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);

				if (!gottaHitNote && PlayStateChangeables.optimize)
					continue;

				swagNote.sustainLength = susLength * Conductor.stepCrochet;
				swagNote.scrollFactor.set(0, 0);
				unspawnNotes.push(swagNote);

				if (susLength > 0)
					swagNote.isParent = true;

				var type = 0;

				if(susLength > 0) {
					for (susNote in 0...Math.floor(Math.max(susLength, 2)))
					{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					sustainNote.parent = swagNote;
					swagNote.children.push(sustainNote);
					sustainNote.spotInLine = type;
					type++;
				}
			}

				swagNote.mustPress = gottaHitNote;
			}
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			// defaults if no noteStyle was found in chart
			var noteTypeCheck:String = 'normal';

			if (PlayStateChangeables.optimize && player == 0)
				continue;

			if (SONG.noteStyle == null)
			{
				switch (storyWeek)
				{
					case 6:
						noteTypeCheck = 'pixel';
				}
			}
			else
			{
				noteTypeCheck = SONG.noteStyle;
			}

			switch (noteTypeCheck)
			{
				case 'pixel':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					for (j in 0...4)
					{
						babyArrow.animation.addByPrefix(dataColor[j], 'arrow' + dataSuffix[j]);	
					}

					var lowerDir:String = dataSuffix[i].toLowerCase();

					babyArrow.animation.addByPrefix('static', 'arrow' + dataSuffix[i]);
					babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
					babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

					babyArrow.x += Note.swagWidth * i;

					babyArrow.antialiasing = FlxG.save.data.antialiasing;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.alpha = 0;
			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				//babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					cpuStrums.add(babyArrow);
					babyArrow.visible = !PlayStateChangeables.useMiddlescroll;
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 100;
			babyArrow.x += ((FlxG.width / 2) * player);

			if (curStage == 'endless' || PlayStateChangeables.useMiddlescroll)
				babyArrow.x -= 325;

			if (PlayStateChangeables.useMiddlescroll && player == 0)
				babyArrow.x -= 500;

			cpuStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets(); // CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);
		}
	}

	private function appearStaticArrows():Void
	{
		strumLineNotes.forEach(function(babyArrow:FlxSprite)
		{
			if (isStoryMode)
				babyArrow.alpha = 1;
		});
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			#if windows
			DiscordClient.changePresence("PAUSED on "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"Acc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if windows
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText
					+ " "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, true,
					songLength
					- Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

		#if windows
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	public static var songRate = 1.5;

	public var stopUpdate = false;
	public var removedVideo = false;

	public var currentBPM = 0;

	public var updateFrame = 0;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		if (updateFrame == 4)
			{
				TimingStruct.clearTimings();
	
					var currentIndex = 0;
					for (i in SONG.eventObjects)
					{
						if (i.type == "BPM Change")
						{
							var beat:Float = i.position;
	
							var endBeat:Float = Math.POSITIVE_INFINITY;
	
							TimingStruct.addTiming(beat,i.value,endBeat, 0); // offset in this case = start time since we don't have a offset
							
							if (currentIndex != 0)
							{
								var data = TimingStruct.AllTimings[currentIndex - 1];
								data.endBeat = beat;
								data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
								TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
							}
	
							currentIndex++;
						}
					}
					updateFrame++;
			}
			else if (updateFrame != 5)
				updateFrame++;
	

			var timingSeg = TimingStruct.getTimingAtTimestamp(Conductor.songPosition);
	
			if (timingSeg != null)
			{
	
				var timingSegBpm = timingSeg.bpm;
	
				if (timingSegBpm != Conductor.bpm)
				{
					//trace("BPM CHANGE to " + timingSegBpm);
					Conductor.changeBPM(timingSegBpm, false);
				}
	
			}

		var newScroll = PlayStateChangeables.scrollSpeed;

		for(i in SONG.eventObjects)
		{
			switch(i.type)
			{
				case "Scroll Speed Change":
					if (i.position < curDecimalBeat)
						newScroll = i.value;
			}
		}

		PlayStateChangeables.scrollSpeed = newScroll;
	
		if (PlayStateChangeables.botPlay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;

		if (useVideo && GlobalVideo.get() != null && !stopUpdate)
		{
			if (GlobalVideo.get().ended && !removedVideo)
			{
				remove(videoSprite);
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				removedVideo = true;
			}
		}

		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
		{
			var balls = notesHitArray.length - 1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
		}

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		super.update(elapsed);

		scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS, accuracy);

		var lengthInPx = scoreTxt.textField.length * scoreTxt.frameHeight; // bad way but does more or less a better job

		scoreTxt.x = (originalX - (lengthInPx / 2)) + 335;

		if (controls.PAUSE #if android || FlxG.android.justReleased.BACK #end && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				#if sys
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				#end
				removedVideo = true;
			}
			cannotDie = true;
			#if windows
			DiscordClient.changePresence("Chart Editor", null, null, true);
			FlxG.switchState(new ChartingState());
			#end
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if windows
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;
		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		#if debug
		if (FlxG.keys.justPressed.SIX)
		{
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				removedVideo = true;
			}

			FlxG.switchState(new AnimationDebug(SONG.player2));
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if windows
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.ZERO)
		{
			FlxG.switchState(new AnimationDebug(SONG.player1));
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if windows
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}
		
		if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future, credit: Shadow Mario#9396
			if (!usedTimeTravel && Conductor.songPosition + 10000 < FlxG.sound.music.length) 
			{
				usedTimeTravel = true;
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if(daNote.strumTime - 500 < Conductor.songPosition) {
						daNote.active = false;
						daNote.visible = false;

					
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
				for (i in 0...unspawnNotes.length) {
					var daNote:Note = unspawnNotes[0];
					if(daNote.strumTime - 500 >= Conductor.songPosition) {
						break;
					}
					unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
				}

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						usedTimeTravel = false;
					});
			}
		}
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
			/*@:privateAccess
				{
					FlxG.sound.music._channel.
			}*/
			songPositionBar = Conductor.songPosition;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && camFollowAllowed)
		{
			#if windows
			if (luaModchart != null)
				luaModchart.setVar("mustHit", PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			#end

			if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != dad.getMidpoint().x + 150)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if windows
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
				#if windows
				if (luaModchart != null)
					luaModchart.executeState('playerTwoTurn', []);
				#end
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				if(dad.curCharacter == 'miku-voca')
					camFollow.y = dad.getMidpoint().y + 35;
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if windows
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);

				#if windows
				if (luaModchart != null)
					luaModchart.executeState('playerOneTurn', []);
				#end

				switch (curStage)
				{
					case 'endless':
						camFollow.x = boyfriend.getMidpoint().y + 100;
					case 'expo-two':
						camFollow.y = boyfriend.getMidpoint().y + 75;
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}
		
		if ((curSong == 'Endurance' && curBeat > 195 && curBeat < 264) || (curSong == 'Loid' && curBeat > 493 && curBeat < 496))
		{
			camZooming = false;
		}
		else
		{
			camZooming = true;
		}

		FlxG.watch.addQuick("curBPM", Conductor.bpm);
		FlxG.watch.addQuick("Closest Note", (unspawnNotes.length != 0 ? unspawnNotes[0].strumTime - Conductor.songPosition : "No note"));

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (misses == 0 && curSong == 'Endless' && curBeat == 361)
		{
			fiestaSalsa3.animation.play('deeznuts');
		}

		if (health <= 0 && !cannotDie)
		{
			if (!usedTimeTravel) 
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if windows
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC);
				#end

				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
			else
				health = 1;
		}
		if (!inCutscene)
		{
			if (FlxG.keys.justPressed.R)
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if windows
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC);
				#end

				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			var stepHeight = (0.45 * Conductor.stepCrochet * FlxMath.roundDecimal(PlayState.SONG.speed, 2));	

			notes.forEachAlive(function(daNote:Note)
			{
				// instead of doing stupid y > FlxG.height
				// we be men and actually calculate the time :)
				if (daNote.tooLate)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				if (!daNote.modifiedByLua)
				{
					if (PlayStateChangeables.useDownscroll)
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								+ 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)) - daNote.noteYOff;
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								+ 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)) - daNote.noteYOff;
						if (daNote.isSustainNote)
						{
							daNote.y -= daNote.height - stepHeight;

							// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
							var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
								swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
						}
					}
					else
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)) + daNote.noteYOff;
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)) + daNote.noteYOff;
						if (daNote.isSustainNote)
						{
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
						}
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}
					
					// Accessing the animation name directly to play it
					var singData:Int = Std.int(Math.abs(daNote.noteData));
					dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);

					if (FlxG.save.data.cpuStrums)
					{
						cpuStrums.forEach(function(spr:FlxSprite)
						{
							if (Math.abs(daNote.noteData) == spr.ID)
							{
								spr.animation.play('confirm', true);
							}
							if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
							{
								spr.centerOffsets();
								spr.offset.x -= 13;
								spr.offset.y -= 13;
							}
							else
								spr.centerOffsets();
						});
					}

					#if windows
					if (luaModchart != null)
						luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
					#end

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.active = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
			}

				if (daNote.mustPress && !daNote.modifiedByLua)
				{
					daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
					if (daNote.sustainActive)
						daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
				}
				else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
				{
					daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
					if (daNote.sustainActive)
						daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
				}

				if (daNote.isSustainNote)
				{
					daNote.x += daNote.width / 2 + 20;
					if (PlayState.curStage.startsWith('school'))
						daNote.x -= 11;
				}

				// trace(daNote.y);
				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if (daNote.isSustainNote && daNote.wasGoodHit && Conductor.songPosition >= daNote.strumTime)
				{
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
				else if ((daNote.mustPress && !PlayStateChangeables.useDownscroll || daNote.mustPress && PlayStateChangeables.useDownscroll)
					&& daNote.mustPress
					&& daNote.strumTime - Conductor.songPosition < -(166 * Conductor.timeScale)
					&& songStarted)
				{
					if (daNote.isSustainNote && daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
					}
						else
						{
							if (!daNote.isSustainNote)
								health -= 0.10;
							vocals.volume = 0;
							if (theFunne && !daNote.isSustainNote)
								noteMiss(daNote.noteData, daNote);

							if (daNote.isParent)
							{
								health -= 0.20; // give a health punishment for failing a LN
								//trace("hold fell over at the start");
								for (i in daNote.children)
								{
									i.alpha = 0.3;
									i.sustainActive = false;
									//trace(i.alpha);
								}
							}
							else
							{
								if (!daNote.wasGoodHit
									&& daNote.isSustainNote
									&& daNote.sustainActive
									&& daNote.spotInLine != daNote.parent.children.length)
								{
									health -= 0.20; // give a health punishment for failing a LN
									//trace("hold fell over at " + daNote.spotInLine);
									for (i in daNote.parent.children)
									{
										i.alpha = 0.3;
										i.sustainActive = false;
										//trace(i.alpha);
									}
									if (daNote.parent.wasGoodHit)
										misses++;
									updateAccuracy();
								}
							}
						}

						daNote.visible = false;
						daNote.kill();
						notes.remove(daNote, true);
					}
			});
		}

		if (FlxG.save.data.cpuStrums)
		{
			cpuStrums.forEach(function(spr:FlxSprite)
			{
				if (spr.animation.finished)
				{
					spr.animation.play('static');
					spr.centerOffsets();
				}
			});
		}

		if (!inCutscene && songStarted)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function endSong():Void
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
		if (useVideo)
		{
			GlobalVideo.get().stop();
			FlxG.stage.window.onFocusOut.remove(focusOut);
			FlxG.stage.window.onFocusIn.remove(focusIn);
			PlayState.instance.remove(PlayState.instance.videoSprite);
		}

		#if mobileC
		mcontrols.visible = false;
		#end


		if (isStoryMode)
			campaignMisses = misses;

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

		seenCutscene = false;

		#if windows
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}
		#end

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.sound.music.pause();
		vocals.pause();
		if (SONG.validScore)
		{
			// adjusting the highscore song name to be compatible
			// would read original scores if we didn't change packages
			var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");
			switch (songHighscore)
			{
				case 'Dad-Battle':
					songHighscore = 'Dadbattle';
				case 'Philly-Nice':
					songHighscore = 'Philly';
			}

			#if !switch
			Highscore.saveScore(songHighscore, Math.round(songScore), storyDifficulty);
			Highscore.saveCombo(songHighscore, Ratings.GenerateLetterRank(accuracy), storyDifficulty);
			#end
		}

		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			FlxG.save.data.offset = offsetTest;
		}
		else
		{
			if (isStoryMode)
			{
				campaignScore += Math.round(songScore);

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					paused = true;

					loadOut.visible = true;
					loadOut.animation.play('transition');
					loadOut.animation.finishCallback = function(huh:String){
						if (storyWeek == 1)
							FlxG.switchState(new EndingState());
						else
							FlxG.switchState(new EstadoDeTrocaReverso());
					};

					FlxG.sound.music.stop();
					vocals.stop();
					Conductor.changeBPM(102);

					#if windows
					if (luaModchart != null)
					{
						luaModchart.die();
						luaModchart = null;
					}
					#end

					if (SONG.validScore)
					{
						#if newgrounds
						NGio.unlockMedal(60961);
						#end
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					}

				//	StoryMenuState.unlockNextWeek(storyWeek);
				}
				else
				{
					// adjusting the song name to be compatible
					var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");

					var poop:String = Highscore.formatSong(songFormat, storyDifficulty);

					//trace('LOADING NEXT SONG');
					//trace(poop);

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;

					PlayState.SONG = Song.loadFromJson(poop, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();
					
					if (curSong == 'Loid')
					{
						LoadingState.loadAndSwitchState(new CutsceneTwoState(), true);
					}
					else if (curSong == 'Endurance')
					{
						LoadingState.loadAndSwitchState(new CutsceneThreeState(), true);
					}
					else
					{
						LoadingState.loadAndSwitchState(new EstadoDeTroca());
					}
				}
			}
			else
			{
				//trace('WENT BACK TO FREEPLAY??');

				paused = true;

				FlxG.sound.music.stop();
				vocals.stop();
				loadOut.visible = true;
				loadOut.animation.play('transition');
				loadOut.animation.finishCallback = function(huh:String){
					FlxG.switchState(new EstadoDeTrocaReverso());
				};
			}
		}
	}

	var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	private function popUpScore(daNote:Note):Void
	{
		var noteDiff:Float = -(daNote.strumTime - Conductor.songPosition);
		var wife:Float = EtternaFunctions.wife3(-noteDiff, Conductor.timeScale);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;
		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		coolText.y -= 350;
		coolText.cameras = [camHUD];
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Float = 350;

		if (FlxG.save.data.accuracyMod == 1)
			totalNotesHit += wife;

		var daRating = daNote.rating;

		switch (daRating)
		{
			case 'shit':
				score = -300;
				combo = 0;
				misses++;
				health -= 0.06;
				ss = false;
				shits++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit -= 1;
			case 'bad':
				daRating = 'bad';
				score = 0;
				health -= 0.03;
				ss = false;
				bads++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.50;
			case 'good':
				daRating = 'good';
				score = 200;
				ss = false;
				goods++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.75;
			case 'sick':
				if (health < 2)
					health += 0.04;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 1;
				sicks++;
		}

		if (daRating != 'shit' || daRating != 'bad')
		{
			songScore += Math.round(score);
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));

			if (combo < 50 && curStage.startsWith('expo'))
			{
				fiestaSalsa.visible = !FlxG.save.data.distractions;			
			}
			if (combo > 50 && curStage.startsWith('expo'))
			{
				fiestaSalsa.visible = FlxG.save.data.distractions;	
			}

			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';

			if (curStage.startsWith('school'))
			{
				pixelShitPart1 = 'weeb/pixelUI/';
				pixelShitPart2 = '-pixel';
			}

			var ratingGroup:FlxSpriteGroup = new FlxSpriteGroup();
			var ratingX:Float = coolText.x - 235;
			var ratingY:Float = 50;

			if (ratingGroup.countDead() > 0) {
				rating = ratingGroup.getFirstDead();
				rating.reset(ratingY, ratingY);
			} else {
				rating = new FlxSprite();
				ratingGroup.add(rating);
			}

			rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
			rating.screenCenter();
			rating.x = ratingX;
			rating.y -= ratingY;

			if (FlxG.save.data.changedHit)
			{
				rating.x = FlxG.save.data.changedHitX;
				rating.y = FlxG.save.data.changedHitY;
			}
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);

			var msTiming = HelperFunctions.truncateFloat(noteDiff, 3);
			if (PlayStateChangeables.botPlay)
				msTiming = 0;

			if (msTiming >= 0.03 && offsetTesting)
			{
				// Remove Outliers
				hits.shift();
				hits.shift();
				hits.shift();
				hits.pop();
				hits.pop();
				hits.pop();
				hits.push(msTiming);

				var total = 0.0;

				for (i in hits)
					total += i;

				offsetTest = HelperFunctions.truncateFloat(total / hits.length, 2);
			}

			if (!PlayStateChangeables.botPlay)
				add(rating);

			if (!curStage.startsWith('school'))
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = FlxG.save.data.antialiasing;
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			}

			rating.updateHitbox();

			rating.cameras = [camHUD];

			var seperatedScore:Array<Int> = [];

			var comboSplit:Array<String> = (combo + "").split('');

			if (combo > highestCombo)
				highestCombo = combo;

			// make sure we have 3 digits to display (looks weird otherwise lol)
			if (comboSplit.length == 1)
			{
				seperatedScore.push(0);
				seperatedScore.push(0);
			}
			else if (comboSplit.length == 2)
				seperatedScore.push(0);

			for (i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}

			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScoreGroup:FlxSpriteGroup = new FlxSpriteGroup();
				var numScore:FlxSprite;
				var numScoreX:Float = rating.x + (43 * daLoop) - 50;
				var numScoreY:Float = rating.y + 100;
	
				if (numScoreGroup.countDead() > 0) {
					numScore = numScoreGroup.getFirstDead();
					numScore.reset(numScoreX, numScoreY);
				} else {
					numScore = new FlxSprite();
					numScoreGroup.add(numScore);
				}
				numScore.loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
				numScore.screenCenter();
				numScore.x = numScoreX;
				numScore.y = numScoreY;
				numScore.cameras = [camHUD];

				if (!curStage.startsWith('school'))
				{
					numScore.antialiasing = FlxG.save.data.antialiasing;
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				}
				else
				{
					numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
				}
				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);

				add(numScore);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.kill();
						numScore.alpha = 1;
					},
					startDelay: Conductor.crochet * 0.002
				});

				daLoop++;
			}
			/* 
				trace(combo);
				trace(seperatedScore);
			 */

			coolText.text = Std.string(seperatedScore);
			// add(coolText);

			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001,
				onUpdate: function(tween:FlxTween)
				{
					rating.kill();
					rating.alpha = 1;
				}
			});

			curSection += 1;
		}
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;

	// THIS FUNCTION JUST FUCKS WIT HELD NOTES AND BOTPLAY/REPLAY (also gamepad shit)

	private function keyShit():Void // I've invested in emma stocks
	{
		// control arrays, order L D R U
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		var releaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];
		#if windows
		if (luaModchart != null)
		{
			if (controls.LEFT_P)
			{
				luaModchart.executeState('keyPressed', ["left"]);
			};
			if (controls.DOWN_P)
			{
				luaModchart.executeState('keyPressed', ["down"]);
			};
			if (controls.UP_P)
			{
				luaModchart.executeState('keyPressed', ["up"]);
			};
			if (controls.RIGHT_P)
			{
				luaModchart.executeState('keyPressed', ["right"]);
			};
		};
		#end

		// Prevent player input if botplay is on
		if (PlayStateChangeables.botPlay)
		{
			holdArray = [false, false, false, false];
			pressArray = [false, false, false, false];
			releaseArray = [false, false, false, false];
		}

		// HOLDS, check for sustain notes
		if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] && daNote.sustainActive)
				{
					//trace(daNote.sustainActive);
					goodNoteHit(daNote);
				}
			});
		}

		if ((KeyBinds.gamepad && !FlxG.keys.justPressed.ANY))
		{
			// PRESSES, check for note hits
			if (pressArray.contains(true) && generatedMusic)
			{
				boyfriend.holdTimer = 0;

				var possibleNotes:Array<Note> = []; // notes that can be hit
				var directionList:Array<Int> = []; // directions that can be hit
				var dumbNotes:Array<Note> = []; // notes to kill later
				var directionsAccounted:Array<Bool> = [false, false, false, false]; // we don't want to do judgments for more than one presses

				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !directionsAccounted[daNote.noteData])
					{
						if (directionList.contains(daNote.noteData))
						{
							directionsAccounted[daNote.noteData] = true;
							for (coolNote in possibleNotes)
							{
								if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
								{ // if it's the same note twice at < 10ms distance, just delete it
									// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
									dumbNotes.push(daNote);
									break;
								}
								else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
								{ // if daNote is earlier than existing note (coolNote), replace
									possibleNotes.remove(coolNote);
									possibleNotes.push(daNote);
									break;
								}
							}
						}
						else
						{
							directionsAccounted[daNote.noteData] = true;
							possibleNotes.push(daNote);
							directionList.push(daNote.noteData);
						}
					}
				});

				for (note in dumbNotes)
				{
					FlxG.log.add("killing dumb ass note at " + note.strumTime);
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}

				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				var hit = [false,false,false,false];

				if (perfectMode)
					goodNoteHit(possibleNotes[0]);
				else if (possibleNotes.length > 0)
				{
					if (!FlxG.save.data.ghost)
					{
						for (shit in 0...pressArray.length)
						{ // if a direction is hit that shouldn't be
							if (pressArray[shit] && !directionList.contains(shit))
								noteMiss(shit, null);
						}
					}
					for (coolNote in possibleNotes)
					{
						if (pressArray[coolNote.noteData] && !hit[coolNote.noteData])
						{
							if (mashViolations != 0)
								mashViolations--;
							hit[coolNote.noteData] = true;
							scoreTxt.color = FlxColor.WHITE;
							var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
							goodNoteHit(coolNote);
						}
					}
				};
				
				if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss') && boyfriend.animation.curAnim.curFrame >= 10)
						boyfriend.dance(idleToBeat);
				}
				else if (!FlxG.save.data.ghost)
				{
					for (shit in 0...pressArray.length)
						if (pressArray[shit])
							noteMiss(shit, null);
				}
			}
		}
		notes.forEachAlive(function(daNote:Note)
		{
			if (PlayStateChangeables.useDownscroll && daNote.y > strumLine.y || !PlayStateChangeables.useDownscroll && daNote.y < strumLine.y)
			{
				// Force good note hit regardless if it's too late to hit it or not as a fail safe
				if (PlayStateChangeables.botPlay && daNote.canBeHit && daNote.mustPress || PlayStateChangeables.botPlay && daNote.tooLate && daNote.mustPress)
				{
					goodNoteHit(daNote);
					boyfriend.holdTimer = daNote.sustainLength;
				}
			}
		});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss') && boyfriend.animation.curAnim.curFrame >= 10)
				boyfriend.dance(idleToBeat);
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			if(!PlayStateChangeables.botPlay){
				if (keys[spr.ID] && spr.animation.curAnim.name != 'confirm')
					spr.animation.play('pressed');
				else if (!keys[spr.ID])
					spr.animation.play('static');
			}else if (spr.animation.finished)
			{
				spr.animation.play('static');
				spr.centerOffsets();
			}

			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	public var fuckingVolume:Float = 1;
	public var useVideo = false;

	public static var webmHandler:WebmHandler;

	public var playingDathing = false;

	public var videoSprite:FlxSprite;

	public function focusOut()
	{
		if (paused)
			return;
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.pause();
			vocals.pause();
		}

		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
	}

	public function focusIn()
	{
		// nada
	}

	public function backgroundVideo(source:String) // for background videos
	{
		#if cpp
		useVideo = true;

		FlxG.stage.window.onFocusOut.add(focusOut);
		FlxG.stage.window.onFocusIn.add(focusIn);

		var ourSource:String = "assets/videos/daWeirdVid/dontDelete.webm";
		var str1:String = "WEBM SHIT";
		webmHandler = new WebmHandler();
		webmHandler.source(ourSource);
		webmHandler.makePlayer();
		webmHandler.webm.name = str1;

		GlobalVideo.setWebm(webmHandler);

		GlobalVideo.get().source(source);
		GlobalVideo.get().clearPause();
		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().updatePlayer();
		}
		GlobalVideo.get().show();

		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().restart();
		}
		else
		{
			GlobalVideo.get().play();
		}

		var data = webmHandler.webm.bitmapData;

		videoSprite = new FlxSprite(-240, -140).loadGraphic(data);

		videoSprite.setGraphicSize(Std.int(videoSprite.width * 1.2));

		remove(gf);
		remove(boyfriend);
		remove(dad);
		add(videoSprite);
		//add(gf);
		//add(boyfriend);
		//add(dad);

		//trace('poggers');

		if (!songStarted)
			webmHandler.pause();
		else
			webmHandler.resume();
		#end
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		if (!boyfriend.stunned)
		{
			//health -= 0.2;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			if (combo > 49 && curStage.startsWith('expo'))
			{
				FlxG.sound.play(Paths.sound('Awww'));
				if (curSong != 'Voca')
				{
					fiestaSalsa2.animation.play('miss', true);
				}
			}
			combo = 0;
			misses++;

			// var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
			// var wife:Float = EtternaFunctions.wife3(noteDiff, FlxG.save.data.etternaMode ? 1 : 1.7);

			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit -= 1;

			if (daNote != null)
			{
				if (!daNote.isSustainNote)
					songScore -= 10;
			}
			else
				songScore -= 10;
			
			if(FlxG.save.data.missSounds)
				{
					FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.3, 0.5));
				}

			// Hole switch statement replaced with a single line :)
			boyfriend.playAnim('sing' + dataSuffix[direction] + 'miss', true);

			#if windows
			if (luaModchart != null)
				luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
			#end

			updateAccuracy();
		}
	}

	/*function badNoteCheck()
			{
				// just double pasting this shit cuz fuk u
				// REDO THIS SYSTEM!
				var upP = controls.UP_P;
				var rightP = controls.RIGHT_P;
				var downP = controls.DOWN_P;
				var leftP = controls.LEFT_P;

				if (leftP)
					noteMiss(0);
				if (upP)
					noteMiss(2);
				if (rightP)
					noteMiss(3);
				if (downP)
					noteMiss(1);
				updateAccuracy();
			}
	 */
	function updateAccuracy()
	{
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
	}

	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}

	var mashing:Int = 0;
	var mashViolations:Int = 0;

	var etternaModeScore:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
	{
		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));

		/* if (loadRep)
			{
				if (controlArray[note.noteData])
					goodNoteHit(note, false);
				else if (rep.replay.keyPresses.length > repPresses && !controlArray[note.noteData])
				{
					if (NearlyEquals(note.strumTime,rep.replay.keyPresses[repPresses].time, 4))
					{
						goodNoteHit(note, false);
					}
				}
		}*/

		if (controlArray[note.noteData])
		{
			goodNoteHit(note, (mashing > getKeyPresses(note)));

			/*if (mashing > getKeyPresses(note) && mashViolations <= 2)
				{
					mashViolations++;

					goodNoteHit(note, (mashing > getKeyPresses(note)));
				}
				else if (mashViolations > 2)
				{
					// this is bad but fuck you
					playerStrums.members[0].animation.play('static');
					playerStrums.members[1].animation.play('static');
					playerStrums.members[2].animation.play('static');
					playerStrums.members[3].animation.play('static');
					health -= 0.4;
					trace('mash ' + mashing);
					if (mashing != 0)
						mashing = 0;
				}
				else
					goodNoteHit(note, false); */
		}
	}

	function goodNoteHit(note:Note, resetMashViolation = true):Void
	{
		if (mashing != 0)
			mashing = 0;

		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.CalculateRating(noteDiff);

		if (note.rating == "miss")
			return;

		// add newest note to front of notesHitArray
		// the oldest notes are at the end and are removed first
		if (!note.isSustainNote)
			notesHitArray.unshift(Date.now());

		if (!resetMashViolation && mashViolations >= 1)
			mashViolations--;

		if (mashViolations < 0)
			mashViolations = 0;

		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note);
				combo += 1;
				if(FlxG.save.data.hitSoundVolume > 0)
					hitsound.play(true);
			}
			else
				totalNotesHit += 1;

			switch (note.noteData)
			{
				case 2:
					boyfriend.playAnim('singUP', true);
				case 3:
					boyfriend.playAnim('singRIGHT', true);
				case 1:
					boyfriend.playAnim('singDOWN', true);
				case 0:
					boyfriend.playAnim('singLEFT', true);
			}

			#if windows
			if (luaModchart != null)
				luaModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
			#end

			if (note.mustPress)
			{
				var array = [note.strumTime, note.sustainLength, note.noteData, noteDiff];
				if (note.isSustainNote)
					array[1] = -1;
			}

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.kill();
			notes.remove(note, true);
			note.destroy();

			updateAccuracy();
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		if (FlxG.save.data.distractions)
		{
			fastCar.x = -12600;
			fastCar.y = FlxG.random.int(140, 250);
			fastCar.velocity.x = 0;
			fastCarCanDrive = true;
		}
	}

	function fastCarDrive()
	{
		if (FlxG.save.data.distractions)
		{
			FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

			fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
			fastCarCanDrive = false;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				resetFastCar();
			});
		}
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		if (FlxG.save.data.distractions)
		{
			trainMoving = true;
			if (!trainSound.playing)
				trainSound.play(true);
		}
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (FlxG.save.data.distractions)
		{
			if (trainSound.time >= 4700)
			{
				startedMoving = true;
				gf.playAnim('hairBlow');
			}

			if (startedMoving)
			{
				phillyTrain.x -= 400;

				if (phillyTrain.x < -2000 && !trainFinishing)
				{
					phillyTrain.x = -1150;
					trainCars -= 1;

					if (trainCars <= 0)
						trainFinishing = true;
				}

				if (phillyTrain.x < -4000 && trainFinishing)
					trainReset();
			}
		}
	}

	function trainReset():Void
	{
		if (FlxG.save.data.distractions)
		{
			gf.playAnim('hairFall');
			phillyTrain.x = FlxG.width + 200;
			trainMoving = false;
			// trainSound.stop();
			// trainSound.time = 0;
			trainCars = 8;
			trainFinishing = false;
			startedMoving = false;
		}
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	var danced:Bool = false;

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if (curSong.toLowerCase() == 'infinite')
            {
                if (giraArray.contains(curStep))
                {
                    strumLineNotes.forEach(function(tospin:FlxSprite)
                    {
                        FlxTween.angle(tospin, 0, 360, 0.2, {ease: FlxEase.quintOut});
                    });
                }
				switch(curStep)
				{
					case 888:
						camFollowAllowed = false;
						camFollow.setPosition(GameDimensions.width / 2 + 200, GameDimensions.height / 4 * 3 + 100);
						FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.3}, 0.7, {ease: FlxEase.cubeInOut});
						three();
					case 891:
						FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.3}, 0.7, {ease: FlxEase.cubeInOut});
						two();
					case 896:
						FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.3}, 0.7, {ease: FlxEase.cubeInOut});
						one();
					case 899:
						camFollowAllowed = true;
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.7, {ease: FlxEase.cubeInOut});
						gofun();
				}
            }

		#if windows
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curStep', curStep);
			luaModchart.executeState('stepHit', [curStep]);
		}
		#end

		// yes this updates every step.
		// yes this is bad
		// but i'm doing it to update misses and accuracy
		#if windows
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"Acc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC, true,
			songLength
			- Conductor.songPosition);
		#end
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (PlayStateChangeables.useDownscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
		}

		#if windows
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curBeat', curBeat);
			luaModchart.executeState('beatHit', [curBeat]);
		}
		#end

		//idc
		//idk why ev doesnt like it :frown:
		//Seja lá quem fez isso, achei muy massa, então sodassi o ev.
		if (curSong.toLowerCase() == 'loid' && curBeat > 430 && curBeat < 566 && combo > 50)
			if (curBeat % 2 == 1)
				FlxG.sound.play(Paths.sound('Hey'));

		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		if (curSong=='Rolling')
			{
				switch(curBeat)
				{
					case 100:
						FlxTween.tween(camHUD, {alpha: 1}, 1, {ease: FlxEase.quadInOut});
					case 166:
						FlxTween.tween(camHUD, {alpha: 0}, 1, {ease: FlxEase.quadInOut});
					case 196:
						FlxTween.tween(camHUD, {alpha: 1}, 1, {ease: FlxEase.quadInOut});
					case 321:
						FlxTween.tween(camHUD, {alpha: 0}, 1, {ease: FlxEase.quadInOut});
					case 352:
						FlxTween.tween(camHUD, {alpha: 1}, 1, {ease: FlxEase.quadInOut});
					case 476:
						vaiDueto();
					case 602:
						for (i in 0...4)
							{
								FlxTween.tween(playerStrums.members[i], {alpha: 0}, 2.5, {ease: FlxEase.smootherStepInOut});
							}
				}
			}

		// HARDCODING FOR MILF ZOOMS!
		if (curSong == 'Loid' && curBeat >= 432 && curBeat < 492 && camZooming)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}
		else if (curSong == 'Voca' && camZooming && ((curBeat >= 116 && curBeat < 180) || (curBeat >= 244 && curBeat < 308)))
		{
			FlxG.camera.zoom += 0.020;
			camHUD.zoom += 0.05;
		}
		else if (curBeat % 4 == 0 && camZooming)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}
		
		if (curBeat % idleBeat == 0 && !boyfriend.animation.curAnim.name.startsWith("sing"))
		{
			boyfriend.dance(idleToBeat);
		}

		if (boyfriend.curCharacter.startsWith('miku') && !boyfriend.animation.curAnim.name.startsWith("sing"))
		{
			if (curBeat % 2 == 1)
				boyfriend.playAnim('danceLeft');
			if (curBeat % 2 == 0)
				boyfriend.playAnim('danceRight');
		}

		if (!dad.animation.curAnim.name.startsWith("sing") && !dad.animation.curAnim.name.startsWith("hey"))
		{
			dad.dance(idleToBeat);
		}

		if (curBeat == 494 && curSong == 'Loid')
		{
			dad.playAnim('hey', true);
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		if (curBeat > 493 && curBeat < 495 && curSong == 'Loid')
		{
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom + 0.3}, 0.2, {
				ease: FlxEase.quadInOut
			});
		}

		if (curBeat == 496 && curSong == 'Loid')
		{
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom = 0.80}, 0.2, {
				ease: FlxEase.quadInOut
			});
		}

		if (curBeat == 312 && curSong == 'Voca')
		{
			bgblack.visible = true;
			bgblack.alpha = 0;
			FlxTween.tween(bgblack, {alpha: 1}, 2.5, {ease: FlxEase.quartInOut});
		}


		if (curBeat == 198 && curSong == 'Endurance')
		{
			bgblack.visible = true;
			bgblack.alpha = 0;
			FlxTween.tween(bgblack, {alpha: 1}, 0.3, {ease: FlxEase.quartInOut});
		}

		if (curBeat == 200 && curSong == 'Endurance')
		{
			light1.visible = true;
			FlxTween.tween(bgblack, {alpha: 0}, 7.5, {ease: FlxEase.quartInOut});
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom + 0.3}, 0.2, {
				ease: FlxEase.quadInOut
			});
		}

		if (curBeat == 230 && curSong == 'Endurance')
		{
			FlxTween.tween(FlxG.camera, {zoom: 0.80}, 5.9, {
				ease: FlxEase.quadInOut
			});
		}

		if (curBeat == 264 && curSong == 'Endurance')
		{
			bgblack.visible = false;
			FlxTween.tween(light1, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut});
		}

		//i would use a flxtimer but idk

		if (curBeat == 266 && curSong == 'Endurance')
		{
			light1.visible = false;
		}

		if (combo > 50 && curBeat == 566 && curSong == 'Loid')
		{
			FlxG.sound.play(Paths.sound('Crowd'));
		}

		if (combo > 50 && curBeat == 269 && curSong == 'Endurance')
		{
			FlxG.sound.play(Paths.sound('Crowd'));
		}

		if(!botplay_usado){

		if (misses == 0 && curSong == 'Tutorial' && curBeat == 113)
		{
			perfect.visible = true;
			perfect.animation.play('perfect', true);
		}

		if (misses == 0 && curSong == 'Rolling' && curBeat == 640)
		{
			perfect.visible = true;
			perfect.animation.play('perfect', true);
		}

		if (misses == 0 && curSong == 'Loid' && curBeat == 566)
		{
			perfect.visible = true;
			perfect.animation.play('perfect', true);
		}


		if (misses == 0 && curSong == 'Endurance' && curBeat == 269)
		{
			perfect.visible = true;
			perfect.animation.play('perfect', true);
		}

		if (combo > 50 && curBeat == 312 && curSong == 'Voca')
		{
			FlxG.sound.play(Paths.sound('Crowd'));
		}

		if (misses == 0 && curSong == 'Voca' && curBeat == 324)
		{
			perfect.visible = true;
			perfect.animation.play('perfect', true);
		}

		if (misses == 0 && curSong == 'Endless' && curBeat == 361)
		{
			perfect.visible = true;
			perfect.animation.play('perfect', true);
		}

		if (misses == 0 && curSong == 'PoPiPo' && curBeat == 245)
		{
			perfect.visible = true;
			perfect.animation.play('perfect', true);
		}

		if (misses == 0 && curSong == 'Aishite' && curBeat == 135)
		{
			perfect.visible = true;
			perfect.animation.play('perfect', true);
		}

		if (misses == 0 && curSong == 'SIU' && curBeat == 263)
		{
			perfect.visible = true;
			perfect.animation.play('perfect', true);
		}

		if (misses == 0 && curSong == 'Disappearance' && curBeat == 389)
		{
			perfect.visible = true;
			perfect.animation.play('perfect', true);
		}

		if (misses == 0 && curSong == 'Rolling' && curBeat == 628)
			{
				perfect.visible = true;
				perfect.animation.play('perfect', true);
			}

		if (misses == 0 && curSong == 'Anamanaguchi' && curBeat == 175)
			{
				perfect.visible = true;
				perfect.animation.play('perfect', true);
			}

		if (misses == 0 && curSong == 'Dwelling' && curBeat == 165)
			{
				perfect.visible = true;
				perfect.animation.play('perfect', true);
			}

		}

		if (curSong == 'Endless')
		{
			if (lyricsArray[curBeat] != "") lyrics.text = lyricsArray[curBeat];
			if (lyrics.text == "-") lyrics.text = "";
		}

		switch (curStage)
		{
			case 'expo':
				if(FlxG.save.data.distractions){
					if ((curSong == 'Loid' && combo > 50 && curBeat > 566) || (combo > 50 && curBeat > 269 && curSong == 'Endurance'))
					{
						fiestaSalsa2.animation.play('cheer', true);
					} else {
						fiestaSalsa2.animation.play('dance', true);
					}
					if (curBeat % 2 == 1)
						fiestaSalsa.animation.play('light1', true);
					if (curBeat % 2 == 0)
						fiestaSalsa.animation.play('light2', true);
				}
			case 'expo-two':
				if(FlxG.save.data.distractions){
					if ((curSong == 'Voca' && combo > 50 && curBeat > 311))
					{
						fiestaSalsa2.animation.play('cheer', true);
					} else {
						fiestaSalsa2.animation.play('dance', true);
					}
					if (curBeat % 2 == 1)
						fiestaSalsa.animation.play('light1', true);
					if (curBeat % 2 == 0)
						fiestaSalsa.animation.play('light2', true);
				}

			case 'concert':
				if(FlxG.save.data.distractions){
					simpsBoppers.animation.play('bop2', true);
				}
				
			case 'school':
				if (FlxG.save.data.distractions)
				{
					bgGirls.dance();
				}

			case 'mall':
				if (FlxG.save.data.distractions)
				{
					upperBoppers.animation.play('bop', true);
					bottomBoppers.animation.play('bop', true);
					santa.animation.play('idle', true);
				}

			case 'limo':
				if (FlxG.save.data.distractions)
				{
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});

					if (FlxG.random.bool(10) && fastCarCanDrive)
						fastCarDrive();
				}
			case "philly":
				if (FlxG.save.data.distractions)
				{
					if (!trainMoving)
						trainCooldown += 1;

					if (curBeat % 4 == 0)
					{
						phillyCityLights.forEach(function(light:FlxSprite)
						{
							light.visible = false;
						});

						curLight = FlxG.random.int(0, phillyCityLights.length - 1);

						phillyCityLights.members[curLight].visible = true;
						// phillyCityLights.members[curLight].alpha = 1;
					}
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					if (FlxG.save.data.distractions)
					{
						trainCooldown = FlxG.random.int(-4, 0);
						trainStart();
					}
				}
		}
	}

	private static function vaiDueto()
	{
		if(PlayStateChangeables.useMiddlescroll)
			return; //Só pra garantir né k

		var placement:Float = (320);
		for (i in 0...4)
		{
			FlxTween.tween(playerStrums.members[i], {x: playerStrums.members[i].x - placement}, 2.5, {ease: FlxEase.smootherStepInOut});
			FlxTween.tween(cpuStrums.members[i], {x: cpuStrums.members[i].x + placement}, 2.5, {ease: FlxEase.smootherStepInOut});
		}
		cpuStrums.forEach(function(tofade:FlxSprite)
		{
			FlxTween.tween(tofade, {alpha: 0}, 1.5);
		});
	}

	var curLight:Int = 0;
}
