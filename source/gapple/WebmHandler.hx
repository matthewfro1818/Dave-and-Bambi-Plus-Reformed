package gapple;

import flixel.FlxG;
import openfl.display.Sprite;
#if desktop
import webm.*;
#end

class WebmHandler
{
	#if desktop
	public var webm:WebmPlayer;
	public var vidPath:String = "";
	public var io:WebmIo;
	public var initialized:Bool = false;
	
	public function new()
	{
	}
	
	public function source(?vPath:String):Void
	{
		if (vPath != null && vPath.length > 0)
		{
			vidPath = vPath;
		}
	}
	
	public function makePlayer():Void
	{
		//nope
	}
	
	public function updatePlayer():Void
	{
		//nope
	}
	
	public function play():Void
	{
		if (initialized)
		{
			webm.play();
		}
	}
	
	public function stop():Void
	{
		if (initialized)
		{
			webm.stop();
		}
	}
	
	public function restart():Void
	{
		if (initialized)
		{
			//nope
		}
	}
	
	public function update(elapsed:Float)
	{
		webm.width = GlobalVideo.calc(2);
		webm.height = GlobalVideo.calc(3);
	}
	
	public var stopped:Bool = false;
	public var restarted:Bool = false;
	public var played:Bool = false;
	public var ended:Bool = false;
	public var paused:Bool = false;
	
	public function pause():Void
	{
		paused = true;
	}
	
	public function resume():Void
	{
		paused = false;
	}
	
	public function togglePause():Void
	{
		if (paused)
		{
			resume();
		} else {
			pause();
		}
	}
	
	public function clearPause():Void
	{
		paused = false;
	}
	
	public function onStop():Void
	{
		stopped = true;
	}
	
	public function onRestart():Void
	{
		restarted = true;
	}
	
	public function onPlay():Void
	{
		played = true;
	}
	
	public function onEnd():Void
	{
		trace("IT ENDED!");
		ended = true;
	}
	
	public function alpha():Void
	{
		//nope
	}
	
	public function unalpha():Void
	{
		//nope
	}
	
	public function hide():Void
	{
		//nope
	}
	
	public function show():Void
	{
		//nope
	}
	#else
	public var webm:Sprite;
	public function new()
	{
	trace("THIS IS ANDROID! or some shit...");
	}
	#end
}
