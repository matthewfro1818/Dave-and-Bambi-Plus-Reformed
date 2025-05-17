package gapple;

class PlaySongMetadata
{
	public var songName:String = "";
	public var ExternalSong:Bool = false;
	public var ShowBadIcon:Bool = false;
	public var songCharacter:String = "";
	public var hasVocals:Bool = true;

	public function new(song:String, external:Bool, songCharacter:String, bad:Bool, vocal:Bool)
	{
		this.songName = song;
		this.ExternalSong = external;
		this.songCharacter = songCharacter;
		this.ShowBadIcon = bad;
		this.hasVocals = vocal;
	}
}
