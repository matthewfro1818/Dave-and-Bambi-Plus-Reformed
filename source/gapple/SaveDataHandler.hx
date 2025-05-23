package gapple;

import flixel.input.gamepad.FlxGamepad;
import openfl.Lib;
import flixel.FlxG;

/**
 * handles save data initialization
*/
class SaveDataHandler
{
    public static function initSave()
    {
		if (FlxG.save.data.newspritetest == null)
			FlxG.save.data.newunfair = false;
                
	        if (FlxG.save.data.newInput == null)
			FlxG.save.data.newInput = true;

		if (FlxG.save.data.downscroll == null)
			FlxG.save.data.downscroll = false;

		if (FlxG.save.data.dfjk == null)
			FlxG.save.data.dfjk = false;

		if (FlxG.save.data.freeplayCuts == null)
			FlxG.save.data.freeplayCuts = false;

		if (FlxG.save.data.eyesores == null)
			FlxG.save.data.eyesores = true;

		if (FlxG.save.data.opponentnotes == null)
			FlxG.save.data.opponentnotes = false;

		if (FlxG.save.data.newunfair == null)
			FlxG.save.data.newunfair = true;

		if (FlxG.save.data.modchart == null)
			FlxG.save.data.modchart = true;

		if (FlxG.save.data.donoteclick == null)
			FlxG.save.data.donoteclick = false;

		if (FlxG.save.data.healthdrain == null)
			FlxG.save.data.healthdrain = false;

		if (FlxG.save.data.practicemode == null)
			FlxG.save.data.practicemode = false;

		if (FlxG.save.data.botplay == null)
			FlxG.save.data.botplay = false;

		if (FlxG.save.data.newInput != null && FlxG.save.data.lastversion == null)
			FlxG.save.data.lastversion = "pre-beta2";
		
		if (FlxG.save.data.newInput == null && FlxG.save.data.lastversion == null)
			FlxG.save.data.lastversion = "beta2";
    }
}
