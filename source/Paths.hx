package;

import openfl.system.System;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import openfl.display3D.textures.Texture;
import openfl.display.BitmapData;
import flash.media.Sound;
import flixel.util.FlxDestroyUtil;
import lime.media.vorbis.VorbisFile;
import lime.media.AudioBuffer;

#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#elseif java
import java.vm.Gc;
#elseif neko
import neko.vm.Gc;
#end


using StringTools;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	inline public static var VIDEO_EXT = "mp4";

	public static var localTrackedAssets:Array<String> = [];
	public static var currentTrackedTextures:Map<String, Texture> = [];
	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static var currentTrackedSounds:Map<String, Sound> = [];

	public static final extensions:Map<String, String> = ["image" => "png", "audio" => "ogg", "video" => "mp4"];

	public static var dumpExclusions:Array<String> = [];

	public static function excludeAsset(key:String):Void {
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}

	/// haya I love you for the base cache dump I took to the max
	public static function clearUnusedMemory()
	{
			// clear non local assets in the tracked assets list
			var counter:Int = 0;
			for (key in currentTrackedAssets.keys())
			{
				// if it is not currently contained within the used local assets
				if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key))
				{
					// get rid of it
					var obj = currentTrackedAssets.get(key);
					@:privateAccess
					if (obj != null)
					{
						var isTexture:Bool = currentTrackedTextures.exists(key);
						if (isTexture)
						{
							var texture = currentTrackedTextures.get(key);
							texture.dispose();
							texture = null;
							currentTrackedTextures.remove(key);
						}
						OpenFlAssets.cache.removeBitmapData(key);
						OpenFlAssets.cache.clearBitmapData(key);
						OpenFlAssets.cache.clear(key);
						FlxG.bitmap._cache.remove(key);
						obj.destroy();
						FlxDestroyUtil.dispose(obj.bitmap);
						currentTrackedAssets.remove(key);
						counter++;
					}
				}
			}
			
			// run the garbage collector for good measure lmfao
			#if (cpp || neko || java || hl)
			Gc.run(true);
			Gc.compact();
			#end
	}

	public static function clearStoredMemory(?cleanUnused:Bool = false)
	{
			// clear anything not in the tracked assets list
			var counterAssets:Int = 0;

			trace('limpando cache kek');

			@:privateAccess
			for (key in FlxG.bitmap._cache.keys())
			{
				var obj = FlxG.bitmap._cache.get(key);
				if (obj != null && !currentTrackedAssets.exists(key))
				{
					OpenFlAssets.cache.removeBitmapData(key);
					OpenFlAssets.cache.clearBitmapData(key);
					OpenFlAssets.cache.clear(key);
					FlxG.bitmap._cache.remove(key);
					obj.destroy();
					counterAssets++;
				}
			}

			#if PRELOAD_ALL
			// clear all sounds that are cached
			var counterSound:Int = 0;
			for (key in currentTrackedSounds.keys())
			{
				if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && key != null)
				{
					// trace('test: ' + dumpExclusions, key);
					OpenFlAssets.cache.removeSound(key);
					OpenFlAssets.cache.clearSounds(key);
					currentTrackedSounds.remove(key);
					counterSound++;
					// Debug.logTrace('Cleared and removed $counterSound cached sounds.');
				}
			}

			// Clear everything everything that's left
			var counterLeft:Int = 0;
			for (key in OpenFlAssets.cache.getKeys())
			{
				if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && key != null)
				{
					OpenFlAssets.cache.clear(key);
					counterLeft++;
					// Debug.logTrace('Cleared and removed $counterLeft cached leftover assets.');
				}
			}

			// flags everything to be cleared out next unused memory clear
			localTrackedAssets = [];
			openfl.Assets.cache.clear("songs");
			#end

		var cache:haxe.ds.Map<String, FlxGraphic> = cast Reflect.field(FlxG.bitmap, "_cache");
		for (key => graphic in cache)
		{
			if (key.indexOf("text") == 0 && graphic.useCount <= 0)
			{
				FlxG.bitmap.remove(graphic);
			}
		}

		FlxG.bitmap.dumpCache();
	}

	static public var currentModDirectory:String = null;
	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, ?library:String, type:AssetType = TEXT)
	{
		return getPath(file, type, library);
	}

	//Não utilizado mas preguiça né?
	inline static public function lua(key:String,?library:String)
	{
		return getPath('data/$key.lua', TEXT, library);
	}

	inline static public function luaImage(key:String, ?library:String)
	{
		return getPath('data/$key.png', IMAGE, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return returnSound('sounds', key, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function video(key:String, ?library:String)
	{
		#if desktop
		trace('assets/videos/$key.mp4');
		return getPath('videos/$key.mp4', BINARY, library);
		#elseif mobile
		trace(getPath('videos/$key', BINARY, library));
		return 'assets/videos/$key'; //Verificar se precisa adicionar o .html no final
		#end
	}

	inline static public function music(key:String, ?library:String)
	{
		return returnSound('music', key, library);
	}

	inline static public function voices(song:String):Any
	{
		#if html5
		return 'songs:assets/songs/${formatToSongPath(song)}/Voices.$SOUND_EXT';
		#else
		var songKey:String = '${formatToSongPath(song)}/Voices';
		var voices = returnSound('songs', songKey);
		return voices;
		#end	}

	inline static public function inst(song:String):Any
	{
		#if html5
		return 'songs:assets/songs/${formatToSongPath(song)}/Inst.$SOUND_EXT';
		#else
		var songKey:String = '${formatToSongPath(song)}/Inst';
		var inst = returnSound('songs', songKey);
		return inst;
		#end
	}

	inline static public function imagechecker(key:String, ?library:String):Dynamic
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function image(key:String, ?library:String):FlxGraphic {
		var returnAsset:FlxGraphic = returnGraphic(key, library);
		return returnAsset;
	}
	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function getSparrowAtlas(key:String, ?library:String, ?isCharacter:Bool = false)
	{
		if (isCharacter)
			return FlxAtlasFrames.fromSparrow(image('characters/'+key, library), file('images/characters/$key.xml', library));
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	inline static public function formatToSongPath(path:String) {
		return path.toLowerCase().replace(' ', '-');
	}
	public static function returnGraphic(key:String, ?library:String) {
		var path:String = '';

		path = getPath('images/$key.png', IMAGE, library);

		if (OpenFlAssets.exists(path, IMAGE))
		{
			if (!currentTrackedAssets.exists(key))
			{
				var bitmap:BitmapData = OpenFlAssets.getBitmapData(path, false);
				var graphic:FlxGraphic = null;

				if (FlxG.save.data.useGPU)
				{
					var texture = FlxG.stage.context3D.createTexture(bitmap.width, bitmap.height, BGRA, false, 0);
					texture.uploadFromBitmapData(bitmap);
					currentTrackedTextures.set(key, texture);
					bitmap.disposeImage();
					FlxDestroyUtil.dispose(bitmap);
					bitmap = null;
					graphic = FlxGraphic.fromBitmapData(BitmapData.fromTexture(texture), false, key);
				}
				else
					graphic = FlxGraphic.fromBitmapData(bitmap, false, key);

				graphic.persist = true;
				trace('carregando: ' + key);
				currentTrackedAssets.set(key, graphic);
			}
			/*else
				trace('Carregando do cache existente: $key');*/

			localTrackedAssets.push(key);
			return currentTrackedAssets.get(key);
		}


		FlxG.log.error('Could not find image at path $path');
		return null; //Apenas para garantir que o jooj tentará carregar do jeito normal primeiro (ou então ajuidar a descobrir qual o pilantra.)
	}

	public static function returnSound(path:String, key:String, ?library:String, stream:Bool = false) {
		var sound:Sound = null;
		var file:String = null;

		{
			// I hate this so god damn much
			var gottenPath:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);
			file = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
			trace('carregando: ' + key);
			if (path == 'songs')
				gottenPath = 'songs:' + gottenPath;
			if (currentTrackedSounds.exists(file))
			{
				localTrackedAssets.push(file);
				return currentTrackedSounds.get(file);
			}
			else if (OpenFlAssets.exists(gottenPath, SOUND))
			{
				#if lime_vorbis
				if (stream)
					sound = OpenFlAssets.getMusic(gottenPath);
				else
				#end
				sound = OpenFlAssets.getSound(gottenPath);
			}
		}

		if (sound != null)
		{
			//trace('carregando: ' + file);
			localTrackedAssets.push(file);
			currentTrackedSounds.set(file, sound);
			return sound;
		}

		FlxG.log.error('oh no its returning null NOOOO ($file)');
		return null;
	}
}