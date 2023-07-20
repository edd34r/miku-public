package;

using StringTools;
class Highscore
{
	#if (haxe >= "4.0.0")
	public static var songScores:Map<String, Int> = new Map();
	public static var songCombos:Map<String, String> = new Map();
	public static var songAccuracies:Map<String, Float> = new Map();
	#else
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	public static var songCombos:Map<String, String> = new Map<String, String>();
	public static var songAccuracies:Map<String, Float> = new Map<String, Float>();
	#end

	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);

		if (!PlayStateChangeables.botPlay)
		{
			if (songScores.exists(daSong))
			{
				if (songScores.get(daSong) < score)
					setScore(daSong, score);
			}
			else
				setScore(daSong, score);
		}
		else
			trace('Botplay/Practice or Random Mode detected, score saving is disabled.');
	}

	public static function saveCombo(song:String, combo:String, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);
		var finalCombo:String = combo.split(')')[0].replace('(', '');

		if (!PlayStateChangeables.botPlay)
		{
			if (songCombos.exists(daSong))
			{
				if (getComboInt(songCombos.get(daSong)) < getComboInt(finalCombo))
					setCombo(daSong, finalCombo);
			}
			else
				setCombo(daSong, finalCombo);
		}
	}

	public static function saveWeekScore(week:Int = 1, score:Int = 0, ?diff:Int = 0):Void
	{
		if (!PlayStateChangeables.botPlay)
		{
			var daWeek:String = formatSong('week' + week, diff);

			if (songScores.exists(daWeek))
			{
				if (songScores.get(daWeek) < score)
					setScore(daWeek, score);
			}
			else
				setScore(daWeek, score);
		}
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSongSave() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		SaveData.songScores = songScores;
		SaveData.save();
	}

	static function setCombo(song:String, combo:String):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songCombos.set(song, combo);
		SaveData.songCombos = songCombos;
		SaveData.save();
	}

	public static function formatSong(song:String, diff:Int):String
	{
		var daSong:String = song.toLowerCase();

		if (diff == 0)
			daSong += '-easy';
		else if (diff == 2)
			daSong += '-hard';

		return daSong;
	}

	public static function formatSongSave(song:String, diff:Int):String
	{
		var daSong:String = song.toLowerCase();

		if (diff == 0)
			daSong += '-easy';
		else if (diff == 2)
			daSong += '-hard';

		return daSong;
	}

	static function getComboInt(combo:String):Int
	{
		switch(combo)
		{
			case 'SDCB':
				return 1;
			case 'FC':
				return 2;
			case 'GFC':
				return 3;
			case 'MFC':
				return 4;
			default:
				return 0;
		}
	}

	public static function getScore(song:String, diff:Int):Int
	{
		if (!songScores.exists(formatSong(song, diff)))
			setScore(formatSong(song, diff), 0);

		return songScores.get(formatSong(song, diff));
	}

	public static function getCombo(song:String, diff:Int):String
	{
		if (!songCombos.exists(formatSongSave(song, diff)))
			setCombo(formatSongSave(song, diff), '');

		return songCombos.get(formatSongSave(song, diff));
	}

	public static function getWeekScore(week:Int, diff:Int):Int
	{
		if (!songScores.exists(formatSongSave('week' + week, diff)))
			setScore(formatSongSave('week' + week, diff), 0);

		return songScores.get(formatSongSave('week' + week, diff));
	}

	public static function load():Void
	{
		if (SaveData.songScores != null)
			songScores = SaveData.songScores;

		if (SaveData.songCombos != null)
			songCombos = SaveData.songCombos;
	}
}