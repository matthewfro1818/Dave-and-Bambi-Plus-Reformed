package gapple;

import flixel.tweens.misc.ColorTween;
import flixel.math.FlxRandom;
import openfl.net.FileFilter;
import openfl.filters.BitmapFilter;
import gapple.Shaders.PulseEffect;
import gapple.Section.SwagSection;
import gapple.Song.SwagSong;
import gapple.HealthIcon;
import gapple.HealthIcon;
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
import flash.system.System;
#if desktop
import gapple.Discord.DiscordClient;
#end

#if windows
import sys.io.File;
import sys.io.Process;
#end

using StringTools;

class PlayState extends gapple.MusicBeatState
{
	public static var mania:Int = 0;

	public static var STRUM_X = 42;

	public static var curStage:String = '';
	public static var characteroverride:String = "none";
	public static var formoverride:String = "none";
	//put the following in anywhere you load or leave playstate that isnt the character selector:
	/*
		PlayState.characteroverride = 'none';
		PlayState.formoverride = 'none';
	*/
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 0;
	public static var weekSong:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public static var practiceMode:Bool = false;
	public static var botPlay:Bool = false;
	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var camBeatSnap:Int = 4;
	public var danceBeatSnap:Int = 2;
	public var dadDanceSnap:Int = 2;

	public var camMoveAllowed:Bool = true;

	public var daveStand:Character;
	public var garrettStand:Character;
	public var hallMonitorStand:Character;
	public var playRobotStand:Character;

	public var standersGroup:FlxTypedGroup<FlxSprite>;

	var songPercent:Float = 0;

	var songLength:Float = 0;

	public var darkLevels:Array<String> = ['bambiFarmNight', 'daveHouse_night', 'unfairness', 'disabled'];
	public var sunsetLevels:Array<String> = ['bambiFarmSunset', 'daveHouse_Sunset'];

	var howManyPlayerNotes:Int = 0;
	var howManyEnemyNotes:Int = 0;

	public var stupidx:Float = 0;
	public var stupidy:Float = 0; // stupid velocities for cutscene
	public var updatevels:Bool = false;

	var scoreTxtTween:FlxTween;

	var timeTxtTween:FlxTween;

	public static var curmult:Array<Float> = [1, 1, 1, 1];

	public var curbg:FlxSprite;
	public static var screenshader:Shaders.PulseEffect = new PulseEffect();
	public var UsingNewCam:Bool = false;

	public var elapsedtime:Float = 0;

	var focusOnDadGlobal:Bool = true;

	var funnyFloatyBoys:Array<String> = ['dave-angey', 'bambi-3d', 'dave-annoyed-3d', 'dave-3d-standing-bruh-what', 'bambi-unfair', 'bambi-piss-3d', 'bandu', 'unfair-junker', 'split-dave-3d', 'badai', 'tunnel-dave', 'tunnel-bf', 'tunnel-bf-flipped', 'bandu-candy', 'bandu-origin', 'ringi', 'bambom', 'bendu', 'tunnel-shaggy'];

	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	var botText:String = "";

	private var swagSpeed:Float;

	var daveJunk:FlxSprite;
	var davePiss:FlxSprite;
	var garrettJunk:FlxSprite;
	var monitorJunk:FlxSprite;
	var robotJunk:FlxSprite;
	var diamondJunk:FlxSprite;

	var boyfriendOldIcon:String = 'bf-old';

	private var vocals:FlxSound;

	private var dad:Character;
	private var dadmirror:Character;
	private var badai:Character;
	private var swagger:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;
	private var littleIdiot:Character;

	private var altSong:SwagSong;

	private var daveExpressionSplitathon:Character;

	//dad.curCharacter == 'bambi-unfair' || dad.curCharacter == 'bambi-3d' || dad.curCharacter == 'bambi-piss-3d'

	public static var shakingChars:Array<String> = ['bambi-unfair', 'bambi-3d', 'bambi-piss-3d', 'badai', 'unfair-junker', 'tunnel-dave'];

	private var notes:FlxTypedGroup<Note>;
	private var altNotes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];
	private var altUnspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var altStrumLine:FlxSprite;
	private var curSection:Int = 0;

	//Handles the new epic mega sexy cam code that i've done
	private var camFollow:FlxPoint;
	private var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var badaiTime:Bool = false;

	private var updateTime:Bool = true;

	public var sunsetColor:FlxColor = FlxColor.fromRGB(255, 143, 178);

	private var strumLineNotes:FlxTypedGroup<Strum>;

	public var playerStrums:FlxTypedGroup<Strum>;
	public var dadStrums:FlxTypedGroup<Strum>;
	private var poopStrums:FlxTypedGroup<Strum>;

	public var idleAlt:Bool = false;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var bambiSpeak:Bool = false;
	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;

	public static var misses:Int = 0;
	public static var opponentnotecount:Int = 0;

	private var accuracy:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	public static var eyesoreson = true;

	public var bfSpazOut:Bool = false;

	private var STUPDVARIABLETHATSHOULDNTBENEEDED:FlxSprite;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var shakeCam:Bool = false;
	private var startingSong:Bool = false;

	public var TwentySixKey:Bool = false;

	public static var amogus:Int = 0;

	public var cameraSpeed:Float = 1;

	public var camZoomIntensity:Float = 1;

	private var iconP1:HealthIcon;
        private var iconP2:HealthIcon;

	private var BAMBICUTSCENEICONHURHURHUR:HealthIcon;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var notestuffs:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	var spaz:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	var fc:Bool = true;

	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;
	var extraTxt:FlxText;

	var GFScared:Bool = false;

	public static var dadChar:String = 'bf';
	public static var bfChar:String = 'bf';

	var scaryBG:FlxSprite;
	var showScary:Bool = false;

	public static var campaignScore:Int = 0;

	var poop:StupidDumbSprite;

	var defaultCamZoom:Float = 1.05;

	public static var daPixelZoom:Float = 6;

	public static var theFunne:Bool = true;

	var funneEffect:FlxSprite;
	var inCutscene:Bool = false;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;

	public static var warningNeverDone:Bool = false;

	public var thing:FlxSprite = new FlxSprite(0, 250);
	public var splitathonExpressionAdded:Bool = false;

	var timeTxt:FlxText;

	public var redTunnel:FlxSprite;

	public var daveFuckingDies:PissBoy;

	public var crazyBatch:String = "shutdown /r /t 0";

	public var backgroundSprites:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var normalDaveBG:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var canFloat:Bool = true;

	var nightColor:FlxColor = 0xFF878787;

	var swagBG:FlxSprite;
	var unswagBG:FlxSprite;

	var creditsWatermark:FlxText;
	var kadeEngineWatermark:FlxText;
	var kadeEngineWatermark2:FlxText;

	var thunderBlack:FlxSprite;
	var legs:FlxSprite;
	var shaggyT:FlxTrail;
	var legT:FlxTrail;
	var sh_r:Float = 60;

	override public function create()
	{
		practiceMode = FlxG.save.data.practicemode && !FlxG.save.data.botplay;
		botPlay = FlxG.save.data.botplay;
		theFunne = FlxG.save.data.newInput;
		unfairPart = false;
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		eyesoreson = FlxG.save.data.eyesores;

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;
		misses = 0;
		opponentnotecount = 0;

		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = CoolUtil.difficultyString();

		// To avoid having duplicate images in Discord assets
		switch (SONG.player2)
		{
			case 'og-dave' | 'og-dave-angey':
				iconRPC = 'icon_og_dave';
			case 'bambi-piss-3d':
				iconRPC = 'icon_bambi_piss_3d';
			case 'bandu' | 'bandu-candy' | 'bandu-scaredy' | 'bandu-origin':
				iconRPC = 'icon_bandu';
			case 'badai':
				iconRPC = 'icon_badai';
			case 'garrett':
				iconRPC = 'icon_garrett';
			case 'tunnel-dave':
				iconRPC = 'icon_tunnel_dave';
			case 'split-dave-3d':
				iconRPC = 'icon_split_dave_3d';
			case 'bambi-unfair' | 'unfair-junker':
				iconRPC = 'icon_unfair_junker';
		}

		detailsText = "";

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		curStage = "";
		
		if (botPlay) botText = "Bot Play - ";
		if (practiceMode) botText = "Practice Mode - ";
		// Updating Discord Rich Presence.
		#if desktop
		DiscordClient.changePresence(SONG.song,
			"\n" + botText + "Acc: "
			+ truncateFloat(accuracy, 2)
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
		FlxG.mouse.visible = false;

		FlxCamera.defaultCameras = [camGame];
		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		mania = SONG.mania;

		if (mania == 1) notestuffs = ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'];
		if (mania == 2) notestuffs = ['LEFT', 'UP', 'RIGHT', 'UP', 'LEFT', 'DOWN', 'RIGHT'];
		if (mania == 3) notestuffs = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'UP', 'LEFT', 'DOWN', 'UP', 'RIGHT'];

		theFunne = theFunne && SONG.song.toLowerCase() != 'unfairness';

		var crazyNumber:Int;
		crazyNumber = FlxG.random.int(0, 3);
		switch (crazyNumber)
		{
			case 0:
				trace("secret dick message ???");
			case 1:
				trace("welcome baldis basics crap");
			case 2:
				trace("Hi, song genie here. You're playing " + SONG.song + ", right?");
			case 3:
				eatShit("this song doesnt have dialogue idiot. if you want this retarded trace function to call itself then why dont you play a song with ACTUAL dialogue? jesus fuck");
			case 4:
				trace("suck my balls");
		}

		switch (SONG.song.toLowerCase())
		{
			case 'disruption':
				dialogue = CoolUtil.coolTextFile(Paths.txt('disruption/disruptDialogue'));
			case 'applecore':
				dialogue = CoolUtil.coolTextFile(Paths.txt('applecore/coreDialogue'));
			case 'disability':
				dialogue = CoolUtil.coolTextFile(Paths.txt('disability/disableDialogue'));
			case 'wireframe':
				dialogue = CoolUtil.coolTextFile(Paths.txt('wireframe/wireDialogue'));
			case 'algebra':
				dialogue = CoolUtil.coolTextFile(Paths.txt('algebra/algebraDialogue'));
		}

		backgroundSprites = createBackgroundSprites(SONG.song.toLowerCase());
		if (SONG.song.toLowerCase() == 'polygonized' || SONG.song.toLowerCase() == 'furiosity')
		{
			normalDaveBG = createBackgroundSprites('glitch');
			for (bgSprite in normalDaveBG)
			{
				bgSprite.alpha = 0;
			}
		}
		var gfVersion:String = 'gf';

		screenshader.waveAmplitude = 1;
		screenshader.waveFrequency = 2;
		screenshader.waveSpeed = 1;
		screenshader.shader.uTime.value[0] = new flixel.math.FlxRandom().float(-100000, 100000);
		var charoffsetx:Float = 0;
		var charoffsety:Float = 0;
		if (formoverride == "bf-pixel"
			&& (SONG.song != "Tutorial" && SONG.song != "Roses" && SONG.song != "Thorns" && SONG.song != "Senpai"))
		{
			gfVersion = 'gf-pixel';
			charoffsetx += 300;
			charoffsety += 300;
		}
		if(formoverride == "bf-christmas")
		{
			gfVersion = 'gf-christmas';
		}
		if (SONG.song.toLowerCase() == 'sugar-rush') gfVersion = 'gf-only';
		if (SONG.song.toLowerCase() == 'wheels') gfVersion = 'gf-wheels';
		gf = new Character(400 + charoffsetx, 130 + charoffsety, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		if (!(formoverride == "bf" || formoverride == "none" || formoverride == "bf-pixel" || formoverride == "bf-christmas") && SONG.song != "Tutorial")
		{
			gf.visible = false;
		}
		else if (FlxG.save.data.tristanProgress == "pending play" && isStoryMode)
		{
			gf.visible = false;
		}

		if(SONG.song.toLowerCase() == 'algebra')
		{
			gf.visible = false;
		}

		standersGroup = new FlxTypedGroup<FlxSprite>();
		add(standersGroup);

		if (SONG.song.toLowerCase() == 'algebra') {
			algebraStander('garrett', garrettStand, 500, 225); 
				algebraStander('og-dave-angey', daveStand, 250, 100); 
				algebraStander('hall-monitor', hallMonitorStand, 0, 100); 
				algebraStander('playrobot-scary', playRobotStand, 750, 100, false, true);
		}

		dad = new Character(100, 100, SONG.player2);
		if(SONG.song.toLowerCase() == 'wireframe')
		{
			badai = new Character(-1250, -1250, 'badai');
		}
		switch (SONG.song.toLowerCase())
		{
			case 'applecore' | 'sugar-rush':
				dadmirror = new Character(dad.x, dad.y, dad.curCharacter);
			default:
				dadmirror = new Character(100, 100, "dave-angey");
			
		}

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		repositionDad();

		dadmirror.y += 0;
		dadmirror.x += 150;

		dadmirror.visible = false;

		if (formoverride == "none" || formoverride == "bf")
		{
			boyfriend = new Boyfriend(770, 450, SONG.player1);
		}
		else
		{
			boyfriend = new Boyfriend(770, 450, formoverride);
		}

		switch (boyfriend.curCharacter)
		{
			case "tristan" | 'tristan-beta' | 'tristan-golden':
				boyfriend.y = 100 + 325;
				boyfriendOldIcon = 'tristan-beta';
			case 'dave' | 'dave-annoyed' | 'dave-splitathon' | 'dave-good':
				boyfriend.y = 100 + 160;
				boyfriendOldIcon = 'dave-old';
			case 'tunnel-bf':
				boyfriend.y = 100;
			case 'dave-old':
				boyfriend.y = 100 + 270;
				boyfriendOldIcon = 'dave';
			case 'bandu-scaredy':
				if (SONG.song.toLowerCase() == 'cycles')
					boyfriend.setPosition(-202, 20);
			case 'dave-angey' | 'dave-annoyed-3d' | 'dave-3d-standing-bruh-what':
				boyfriend.y = 100;
				switch(boyfriend.curCharacter)
				{
					case 'dave-angey':
						boyfriendOldIcon = 'dave-annoyed-3d';
					case 'dave-annoyed-3d':
						boyfriendOldIcon = 'dave-3d-standing-bruh-what';
					case 'dave-3d-standing-bruh-what':
						boyfriendOldIcon = 'dave-old';
				}
			case 'bambi-3d' | 'bambi-piss-3d':
				boyfriend.y = 100 + 350;
				boyfriendOldIcon = 'bambi-old';
			case 'bambi-unfair':
				boyfriend.y = 100 + 575;
				boyfriendOldIcon = 'bambi-old';
			case 'bambi' | 'bambi-old' | 'bambi-bevel' | 'what-lmao':
				boyfriend.y = 100 + 400;
				boyfriendOldIcon = 'bambi-old';
			case 'bambi-new' | 'bambi-farmer-beta':
				boyfriend.y = 100 + 450;
				boyfriendOldIcon = 'bambi-old';
			case 'bambi-splitathon':
				boyfriend.y = 100 + 400;
				boyfriendOldIcon = 'bambi-old';
			case 'bambi-angey':
				boyfriend.y = 100 + 450;
				boyfriendOldIcon = 'bambi-old';
			case 'shaggy':
				boyfriend.y = 100;
				boyfriend.x += 50;
				if (SONG.song.toLowerCase() == "algebra") boyfriend.y += 60;
				if (SONG.song.toLowerCase() == "sugar-rush") boyfriend.y += 100;
				if (SONG.song.toLowerCase() == "applecore") boyfriend.y += 140;
				boyfriendOldIcon = 'shaggy';
			case 'tunnel-shaggy':
				shaggyT = new FlxTrail(boyfriend, null, 5, 7, 0.3, 0.001);
				add(shaggyT);
	
				legT = new FlxTrail(legs, null, 5, 7, 0.3, 0.001);
				add(legT);
				add(legs);
				boyfriendOldIcon = 'shaggy';
		}

		switch (curStage) {
			case 'out':
				boyfriend.x += 300;
				boyfriend.y += 10;
				gf.x += 70;
				dad.x -= 100;
			case 'sugar':
				gf.setPosition(811, 200);
			case 'wheels':
				gfSpeed = 2;
				gf.setPosition(400, boyfriend.getMidpoint().y);
				gf.y -= gf.height / 2;
				gf.x += 190;
		}

		if(darkLevels.contains(curStage) && SONG.song.toLowerCase() != "polygonized")
		{
			dad.color = nightColor;
			gf.color = nightColor;
			boyfriend.color = nightColor;
		}

		if(sunsetLevels.contains(curStage))
		{
			dad.color = sunsetColor;
			gf.color = sunsetColor;
			boyfriend.color = sunsetColor;
		}

		add(gf);

		if (SONG.song.toLowerCase() != 'wireframe' && SONG.song.toLowerCase() != 'origin')
			add(dad);
		add(boyfriend);
		add(dadmirror);
		if (SONG.song.toLowerCase() == 'wireframe' || SONG.song.toLowerCase() == 'origin') {
			add(dad);
			if(SONG.song.toLowerCase() == 'wireframe') {
				dad.scale.set(dad.scale.x + 0.36, dad.scale.y + 0.36);
				dad.x += 65;
				dad.y += 175;
				boyfriend.y -= 190;
			}
		}
		if(badai != null)
		{
			add(badai);
			badai.visible = false;
		}

		if(curStage == 'redTunnel')
		{
			dad.x -= 150;
			dad.y -= 100;
			boyfriend.x -= 150;
			boyfriend.y -= 150;
			gf.visible = false;
		}

		if(dad.curCharacter == 'bandu-origin')
		{
			dad.x -= 250;
			dad.y -= 350;
		}

		dadChar = dad.curCharacter;
		bfChar = boyfriend.curCharacter;

		/*if(bfChar == '3d-bf')
		{
			boyfriend.y += 75;
		}*/

		if (SONG.song.toLowerCase() == 'dave-x-bambi-shipping-cute') gf.visible = false;
		if (curStage == 'house') gf.visible = false;

		if (swagger != null) add(swagger);

		if(SONG.song.toLowerCase() == "unfairness")
		{
			health = 2;
		}

		if(dadChar == 'bandu-candy' || dadChar == 'bambi-piss-3d')
		{
			dadDanceSnap = 1;
		}

		if(bfChar == 'bandu-candy' || bfChar == 'bambi-piss-3d')
		{
			danceBeatSnap = 1;
		}

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;


		Conductor.songPosition = -5000;

		thunderBlack = new FlxSprite().makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.BLACK);
		thunderBlack.screenCenter();
		thunderBlack.alpha = 0;
		add(thunderBlack);

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		var showTime:Bool = true;
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat("Comic Sans MS Bold", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if(FlxG.save.data.downscroll) timeTxt.y = FlxG.height - 44;

		add(timeTxt);

		if (SONG.song.toLowerCase() == 'applecore') {
			altStrumLine = new FlxSprite(0, -100);
		}

		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<Strum>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<Strum>();

		dadStrums = new FlxTypedGroup<Strum>();

		poopStrums = new FlxTypedGroup<Strum>();

		if ((boyfriend.curCharacter == 'shaggy' && (SONG.song.toLowerCase() == "disruption" || SONG.song.toLowerCase() == "applecore" || SONG.song.toLowerCase() == "disability" || SONG.song.toLowerCase() == "algebra" || SONG.song.toLowerCase() == "sugar-rush" || SONG.song.toLowerCase() == "origin" || SONG.song.toLowerCase() == "metallic" || SONG.song.toLowerCase() == "strawberry" || SONG.song.toLowerCase() == "old-strawberry" || SONG.song.toLowerCase() == "keyboard" || SONG.song.toLowerCase() == "wheels" || SONG.song.toLowerCase() == "sart-producer" || SONG.song.toLowerCase() == "recovered-project")) || (boyfriend.curCharacter == 'tunnel-shaggy' && SONG.song.toLowerCase() == "wireframe") || (boyfriend.curCharacter == 'matt' && SONG.song.toLowerCase() == "dave-x-bambi-shipping-cute")) {
			Main.shaggyVoice = true;
			gf.visible = false;
		}
		else 
			Main.shaggyVoice = false;

		generateSong(SONG.song);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (FlxG.save.data.downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		add(healthBar);

		var credits:String;
		switch (SONG.song.toLowerCase())
		{
			case 'supernovae':
				credits = 'Original Song made by ArchWk!';
			case 'glitch':
				credits = 'Original Song made by DeadShadow and PixelGH!';
			case 'mealie':
				credits = 'Original Song made by Alexander Cooper 19!';
			case 'unfairness':
				credits = "Ghost tapping is forced off! Screw you!";
			case 'cheating' | 'disruption':
				credits = 'Screw you!';
			case 'thunderstorm':
				credits = 'Original song made by Saruky for Vs. Shaggy!';
			case 'metallic':
				credits = 'OC created by Dragolii!';
			case 'strawberry':
				credits = 'OC created by Emiko!';
			case 'keyboard':
				credits = 'OC created by DanWiki!';
			case 'cycles':
				credits = 'Original song made by Vania for Vs. Sonic.exe!';
			case 'bambi-666-level':
				credits = 'Bambi 666 Level';
			case 'wheels':
				credits = 'this song is a joke please dont take it seriously';
			default:
				credits = '';
		}
		var randomThingy:Int = FlxG.random.int(0, 0);
		var engineName:String = 'stupid';
		switch(randomThingy)
	    {
			case 0:
				engineName = 'Golden Apple ';
		}
		var creditsText:Bool = credits != '';
		var textYPos:Float = healthBarBG.y + 30;
		if (creditsText)
		{
			textYPos = healthBarBG.y + 10;
		}
		var songName:String = SONG.song;
		if (SONG.song.toLowerCase() == 'dave-x-bambi-shipping-cute' && storyDifficulty == 1) songName = "Shaggy-x-Matt-Shipping-Power";
		// Add Kade Engine watermark
		var difficulty:Array<String> = ['', " - Extra Keys", " - 4K Mania"];
		kadeEngineWatermark = new FlxText(4, textYPos, 0,
		songName
		+ difficulty[storyDifficulty], 16);
		kadeEngineWatermark.setFormat(Paths.font("comic.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		kadeEngineWatermark.borderSize = 1.25;
		add(kadeEngineWatermark);
		kadeEngineWatermark2 = new FlxText(4, textYPos + 20, 0,
		"Extra Keys Addon v1.1", 16);
		kadeEngineWatermark2.setFormat(Paths.font("comic.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		kadeEngineWatermark2.scrollFactor.set();
		kadeEngineWatermark2.borderSize = 1.25;
		add(kadeEngineWatermark2);

		creditsWatermark = new FlxText(4, healthBarBG.y + 50, 0, credits, 16);
		creditsWatermark.setFormat(Paths.font("comic.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		creditsWatermark.scrollFactor.set();
		creditsWatermark.borderSize = 1.25;
		add(creditsWatermark);
		creditsWatermark.cameras = [camHUD];

		switch (curSong.toLowerCase())
		{
			case 'splitathon':
				preload('splitathon/Bambi_WaitWhatNow');
				preload('splitathon/Bambi_ChillingWithTheCorn');
			case 'insanity':
				preload('dave/redsky');
				preload('dave/redsky_insanity');
			case 'wireframe':
				preload('bambi/badai');
			case 'algebra':
				preload('dave/HALL_MONITOR');
				preload('dave/diamondMan');
				preload('dave/playrobot');
				preload('dave/ohshit');
				preload('dave/garrett_algebra');
				preload('dave/og_dave_angey');
			case 'recovered-project':
				preload('dave/recovered_project_2');
				preload('dave/recovered_project_3');
		}

		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 200, healthBarBG.y + 40, 0, "", 20);
		/* if (!FlxG.save.data.accuracyDisplay)
			scoreTxt.x = healthBarBG.x + healthBarBG.width / 2; */
		scoreTxt.setFormat(Paths.font("comic.ttf"), 20, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.5;
		add(scoreTxt);

		extraTxt = new FlxText(10, (FlxG.save.data.downscroll ? FlxG.height - 36 : 18), 0, "", 20);
		extraTxt.setFormat(Paths.font("comic.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		extraTxt.scrollFactor.set();
		extraTxt.borderSize = 1.5;
		extraTxt.visible = FlxG.save.data.opponentnotes;
		add(extraTxt);

		botplayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (FlxG.save.data.downscroll ? 100 : -100), 0,
		"BOTPLAY", 20);
		botplayTxt.setFormat(Paths.font("comic.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 3;
		botplayTxt.visible = botPlay;
		add(botplayTxt);

		var iconP1IsPlayer:Bool = true;
		if(SONG.song.toLowerCase() == 'wireframe')
		{
			iconP1IsPlayer = false;
		}
		
		iconP1 = new HealthIcon((formoverride == "none" || formoverride == "bf") ? SONG.player1 : formoverride, iconP1IsPlayer);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		if (FlxG.save.data.newspritetest) {
			iconP2 = new HealthIcon(SONG.player2 == "bambi" ? "bambi-stupid" : SONG.player2, false);
			iconP2.y = healthBar.y - (iconP2.height / 2);
			add(iconP2);
		}
		else {
			iconP2 = new HealthIcon(SONG.player2 == "bambi" ? "bambi-stupid" : SONG.player2, false);
			iconP2.y = healthBar.y - (iconP2.height / 2);
			add(iconP2);
		}

		thunderBlack.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		extraTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		kadeEngineWatermark.cameras = [camHUD];
		kadeEngineWatermark2.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		Note.inEditor = false;
		startingSong = true;

		if ((isStoryMode || FlxG.save.data.freeplayCuts) && boyfriend.curCharacter != "shaggy" && boyfriend.curCharacter != "tunnel-shaggy")
		{
			switch (curSong.toLowerCase())
			{
				case 'disruption' | 'applecore' | 'disability' | 'wireframe' | 'algebra':
					schoolIntro(doof);
				case 'origin':
					originCutscene();
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				case 'origin':
					originCutscene();
				default:
					startCountdown();
			}
		}

		super.create();
	}
	function createBackgroundSprites(song:String):FlxTypedGroup<FlxSprite>
	{
		var sprites:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
		switch (song)
		{
			case 'sugar-rush':
				defaultCamZoom = 0.85;
				curStage = 'sugar';

				var swag:FlxSprite = new FlxSprite(120, -35).loadGraphic(Paths.image('bambi/pissing_too'));
				swag.x -= 250;
				swag.setGraphicSize(Std.int(swag.width  * 0.521814815));
				swag.updateHitbox();
				swag.antialiasing = false;

				add(swag);
				
			case 'recovered-project':
				defaultCamZoom = 0.85;
				curStage = 'recover';
				var yea = new FlxSprite(-641, -222).loadGraphic(Paths.image('RECOVER_assets/q'));
				yea.setGraphicSize(2478);
				yea.updateHitbox();
				sprites.add(yea);
				add(yea);
			case 'applecore':
				defaultCamZoom = 0.5;
				curStage = 'POOP';
				swagger = new Character(-300, 100 - 900 - 400, 'bambi-piss-3d');
				var diff:String = "";
				switch (storyDifficulty) {
					case 1: diff = "-extrakeys";
					case 2: diff = "-mania";
				}
				altSong = Song.loadFromJson('alt-notes' + diff, 'applecore');

				scaryBG = new FlxSprite(-350, -375).loadGraphic(Paths.image('bambi/yeah'));
				scaryBG.scale.set(2, 2);
				var testshader3:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader3.waveAmplitude = 0.25;
				testshader3.waveFrequency = 10;
				testshader3.waveSpeed = 3;
				scaryBG.shader = testshader3.shader;
				scaryBG.alpha = 0.65;
				sprites.add(scaryBG);
				add(scaryBG);
				scaryBG.active = false;

				swagBG = new FlxSprite(-600, -200).loadGraphic(Paths.image('bambi/hi'));
				//swagBG.scrollFactor.set(0, 0);
				swagBG.scale.set(1.75, 1.75);
				//swagBG.updateHitbox();
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 1;
				testshader.waveSpeed = 2;
				swagBG.shader = testshader.shader;
				sprites.add(swagBG);
				add(swagBG);
				curbg = swagBG;

				unswagBG = new FlxSprite(-600, -200).loadGraphic(Paths.image('bambi/poop'));
				unswagBG.scale.set(1.75, 1.75);
				var testshader2:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader2.waveAmplitude = 0.1;
				testshader2.waveFrequency = 5;
				testshader2.waveSpeed = 2;
				unswagBG.shader = testshader2.shader;
				sprites.add(unswagBG);
				add(unswagBG);
				unswagBG.active = unswagBG.visible = false;

				littleIdiot = new Character(200, -175, 'unfair-junker');
				add(littleIdiot);
				littleIdiot.visible = false;
				poipInMahPahntsIsGud = false;

				what = new FlxTypedGroup<FlxSprite>();
				add(what);

				for (i in 0...2) {
					var pizza = new FlxSprite(FlxG.random.int(100, 1000), FlxG.random.int(100, 500));
					pizza.frames = Paths.getSparrowAtlas('bambi/pizza');
					pizza.animation.addByPrefix('idle', 'p', 12, true); // https://m.gjcdn.net/game-thumbnail/500/652229-crop175_110_1130_647-stnkjdtv-v4.jpg
					pizza.animation.play('idle');
					pizza.ID = i;
					pizza.visible = false;
					pizza.antialiasing = false;
					wow2.push([pizza.x, pizza.y, FlxG.random.int(400, 1200), FlxG.random.int(500, 700), i]);
					gasw2.push(FlxG.random.int(800, 1200));
					what.add(pizza);
				}

			case 'algebra':
				curStage = 'algebra';
				defaultCamZoom = 0.85;
				if (FlxG.save.data.modchart)
					swagSpeed = 1.6;
				else
					swagSpeed = SONG.speed;
				if (storyDifficulty == 1 && mania == 2)
					addspacestatic = false;
				var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('dave/algebraBg'));
				bg.setGraphicSize(Std.int(bg.width * 1.35), Std.int(bg.height * 1.35));
				bg.updateHitbox();
				//this is temp until good positioning gets done
				bg.screenCenter(); // no its not
				sprites.add(bg);
				add(bg);

				daveJunk = new FlxSprite(424, 122).loadGraphic(bgImg('dave'));
				davePiss = new FlxSprite(427, 94);
				davePiss.frames = Paths.getSparrowAtlas('dave/bgJunkers/davePiss');
				davePiss.animation.addByIndices('idle', 'GRR', [0], '', 0, false);
				davePiss.animation.addByPrefix('d', 'GRR', 24, false);
				davePiss.animation.play('idle');

				garrettJunk = new FlxSprite(237, 59).loadGraphic(bgImg('bitch'));
				garrettJunk.y += 45;

				monitorJunk = new FlxSprite(960, 61).loadGraphic(bgImg('rubyIsAngryRN'));
				monitorJunk.x += 275;
				monitorJunk.y += 75;

				diamondJunk = new FlxSprite(645, -16).loadGraphic(bgImg('lanceyIsGoingToMakeAFakeLeakAndPostItInGeneral'));
				diamondJunk.x += 75;

				robotJunk = new FlxSprite(-160, 225).loadGraphic(bgImg('myInternetJustWentOut'));
				robotJunk.x -= 250;
				robotJunk.y += 75;

				for (i in [diamondJunk, garrettJunk, daveJunk, davePiss, monitorJunk, robotJunk]) {
					//i.offset.set(i.getMidpoint().x - bg.getMidpoint().x, i.getMidpoint().y - bg.getMidpoint().y);
					i.scale.set(1.35, 1.35);
					//i.updateHitbox();
					//i.x += (i.getMidpoint().x - bg.getMidpoint().x) * 0.35;
					//i.y += (i.getMidpoint().y - bg.getMidpoint().y) * 0.35;
					i.visible = false;
					i.antialiasing = false;
					sprites.add(i);
					add(i);
				}
				

			case 'polygonized' | 'furiosity' | 'cheating' | 'unfairness' | 'disruption' | 'disability' | 'origin' | 'metallic' | 'strawberry' | 'keyboard' | 'ugh' | 'old-strawberry':
				defaultCamZoom = 0.9;
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/redsky'));
				bg.active = true;
	
				switch (SONG.song.toLowerCase())
				{
					case 'cheating':
						bg.loadGraphic(Paths.image('dave/cheater'));
						curStage = 'cheating';
					case 'disruption':
						gfSpeed = 2;
						bg.loadGraphic(Paths.image('dave/disruptor'));
						curStage = 'disrupt';
					case 'unfairness':
						bg.loadGraphic(Paths.image('dave/scarybg'));
						curStage = 'unfairness';
					case 'disability':
						bg.loadGraphic(Paths.image('dave/disabled'));
						curStage = 'disabled';
					case 'origin' | 'ugh':
						bg.loadGraphic(Paths.image('bambi/heaven'));
						curStage = 'origin';
					case 'metallic':
						defaultCamZoom = 0.7;
						bg.loadGraphic(Paths.image('bambi/metal'));
						bg.y -= 235;
						curStage = 'metallic';
					case 'strawberry' | 'old-strawberry':
						defaultCamZoom = 0.69;
						bg.loadGraphic(Paths.image('bambi/strawberries'));
						bg.scrollFactor.set(0, 0);
						bg.y -= 200;
						bg.x -= 100;
						curStage = 'strawberry';
					case 'keyboard':
						bg.loadGraphic(Paths.image('bambi/keyboard'));
						curStage = 'keyboard';
					default:
						bg.loadGraphic(Paths.image('dave/redsky'));
						curStage = 'daveEvilHouse';
				}
				
				sprites.add(bg);
				add(bg);

				if (SONG.song.toLowerCase() == 'disruption') {
					poop = new StupidDumbSprite(-100, -100, 'lol');
					poop.makeGraphic(Std.int(1280 * 1.4), Std.int(720 * 1.4), FlxColor.BLACK);
					poop.scrollFactor.set(0, 0);
					sprites.add(poop);
					add(poop);
				}
				// below code assumes shaders are always enabled which is bad
				// i wouldnt consider this an eyesore though
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				bg.shader = testshader.shader;
				curbg = bg;
			case 'wireframe':
				defaultCamZoom = 0.67;
				curStage = 'redTunnel';
				var stupidFuckingRedBg = new FlxSprite().makeGraphic(9999, 9999, FlxColor.fromRGB(42, 0, 0)).screenCenter();
				add(stupidFuckingRedBg);
				redTunnel = new FlxSprite(-1000, -700).loadGraphic(Paths.image('bambi/redTunnel'));
				redTunnel.setGraphicSize(Std.int(redTunnel.width * 1.15), Std.int(redTunnel.height * 1.15));
				redTunnel.updateHitbox();
				sprites.add(redTunnel);
				add(redTunnel);
				daveFuckingDies = new PissBoy(0, 0);
				daveFuckingDies.screenCenter();
				daveFuckingDies.y = 1500;
				add(daveFuckingDies);
				daveFuckingDies.visible = false;
				//god eater legs
				legs = new FlxSprite(-850, -850);
				legs.frames = Paths.getSparrowAtlas('tunnel_shaggy');
				legs.animation.addByPrefix('legs', "solo_legs", 30);
				legs.animation.play('legs');
				legs.antialiasing = true;
				legs.updateHitbox();
				legs.offset.set(legs.frameWidth / 2, 10);
				legs.alpha = 0;
			case 'wheels':
				curStage = 'wheels';

				var bg = new FlxSprite(150, 100).loadGraphic(Paths.image('dave/swag'));
				bg.scale.set(3, 3);
				bg.updateHitbox();
				bg.scale.set(4.5, 4.5);
				bg.antialiasing = false;
				add(bg);
			case 'sart-producer':
				curStage = 'sart';
				defaultCamZoom = 0.6;

				add(new FlxSprite(-1350, -1111).loadGraphic(Paths.image('sart/bg')));
			case 'cycles':
				curStage = 'house';
				defaultCamZoom = 1.05;

				add(new FlxSprite(-130, -94).loadGraphic(Paths.image('bambi/yesThatIsATransFlag')));
			case 'thunderstorm':
				curStage = 'out';
				defaultCamZoom = 0.8;

				var sky:ShaggyModMoment = new ShaggyModMoment('thunda/sky', -1204, -456, 0.15, 1, 0);
				add(sky);

				//var clouds:ShaggyModMoment = new ShaggyModMoment('thunda/clouds', -988, -260, 0.25, 1, 1);
				//add(clouds);

				var backMount:ShaggyModMoment = new ShaggyModMoment('thunda/backmount', -700, -40, 0.4, 1, 2);
				add(backMount);

				var middleMount:ShaggyModMoment = new ShaggyModMoment('thunda/middlemount', -240, 200, 0.6, 1, 3);
				add(middleMount);

				var ground:ShaggyModMoment = new ShaggyModMoment('thunda/ground', -660, 624, 1, 1, 4);
				add(ground);
			default:
				defaultCamZoom = 0.9;
				curStage = 'stage';
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				
				sprites.add(bg);
				add(bg);
	
				var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;

				sprites.add(stageFront);
				add(stageFront);
	
				var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = true;
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.active = false;
	
				sprites.add(stageCurtains);
				add(stageCurtains);
		}
		return sprites;
	}

	function schoolIntro(?dialogueBox:DialogueBox, isStart:Bool = true):Void
	{
		snapCamFollowToPos(boyfriend.getGraphicMidpoint().x - 200, dad.getGraphicMidpoint().y - 10);
		var black:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width * 5, FlxG.height * 5, FlxColor.BLACK);
		black.screenCenter();
		black.scrollFactor.set();
		add(black);

		var stupidBasics:Float = 1;
		if (isStart)
		{
			FlxTween.tween(black, {alpha: 0}, stupidBasics);
		}
		else
		{
			black.alpha = 0;
			stupidBasics = 0;
		}
		new FlxTimer().start(stupidBasics, function(fuckingSussy:FlxTimer)
		{
			if (dialogueBox != null)
			{
				add(dialogueBox);
			}
			else
			{
				startCountdown();
			}
		});
	}

	function originCutscene():Void
	{
		inCutscene = true;
		camHUD.visible = false;
		dad.alpha = 0;
		dad.canDance = false;
		focusOnDadGlobal = false;
		// focusOnChar(boyfriend);
		ZoomCam(false);
		new FlxTimer().start(1, function(suckMyGoddamnCock:FlxTimer)
		{
			if (boyfriend.curCharacter == "shaggy")
				FlxG.sound.play(Paths.sound('origin_shaggy_call'));
			else
				FlxG.sound.play(Paths.sound('origin_bf_call'));
			boyfriend.canDance = false;
			bfSpazOut = true;
			new FlxTimer().start(1.35, function(cockAndBalls:FlxTimer)
			{
				boyfriend.canDance = true;
				bfSpazOut = false;
				focusOnDadGlobal = true;
				focusOnChar(dad);
				new FlxTimer().start(0.5, function(ballsInJaws:FlxTimer)
				{
					dad.alpha = 1;
					dad.playAnim('cutscene');
					FlxG.sound.play(Paths.sound('origin_intro'));
					new FlxTimer().start(1.5, function(deezCandies:FlxTimer)
					{
						FlxG.sound.play(Paths.sound('origin_bandu_talk'));
						dad.playAnim('singUP');
						new FlxTimer().start(1.5, function(penisCockDick:FlxTimer)
						{
							dad.canDance = true;
							focusOnDadGlobal = false;
							// focusOnChar(boyfriend);
							ZoomCam(false);
							boyfriend.canDance = false;
							bfSpazOut = true;
							if (boyfriend.curCharacter == "shaggy")
								FlxG.sound.play(Paths.sound('origin_shaggy_talk'));
							else
								FlxG.sound.play(Paths.sound('origin_bf_talk'));
							new FlxTimer().start(1.5, function(buttAssAnusGluteus:FlxTimer)
							{
								boyfriend.canDance = true;
								bfSpazOut = false;
								focusOnDadGlobal = true;
								focusOnChar(dad);
								startCountdown();
							});
						});
					});
				});
			});
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;
	var noticeB:Array<FlxText> = [];
	var nShadowB:Array<FlxText> = [];

	function startCountdown():Void
	{
		inCutscene = false;

		camHUD.visible = true;

		boyfriend.canDance = true;
		dad.canDance = true;
		gf.canDance = true;

		generateStaticArrows(0);
		generateStaticArrows(1);

		var startSpeed:Float = 1;

		if (SONG.song.toLowerCase() == 'disruption') {
			startSpeed = 0.5; // WHATN THE JUNK!!!
		}

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5 * (1 / startSpeed);

		var swagCounter:Int = 0;
	
		startTimer = new FlxTimer().start(Conductor.crochet / (1000 * startSpeed), function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.dance();

			if (dad.curCharacter == 'bandu' || dad.curCharacter == 'bandu-candy') {
				// SO THEIR ANIMATIONS DONT START OFF-SYNCED
				dad.playAnim('singUP');
				dadmirror.playAnim('singUP');
				dad.dance();
				dadmirror.dance();
			}

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
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
					focusOnDadGlobal = false;
					ZoomCam(false);
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
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
					focusOnDadGlobal = true;
					ZoomCam(true);
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
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
					focusOnDadGlobal = false;
					ZoomCam(false);
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
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
					focusOnDadGlobal = true;
					ZoomCam(true);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		vocals.play();
		if (FlxG.save.data.tristanProgress == "pending play" && isStoryMode && storyWeek != 10)
		{
			FlxG.sound.music.volume = 0;
		}
		if (SONG.song.toLowerCase() == 'disruption') FlxG.sound.music.volume = 1; // WEIRD BUG!!! WTF!!!

		songLength = FlxG.sound.music.length;

		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		#if desktop
		DiscordClient.changePresence(SONG.song,
			"\n" + botText + "Acc: "
			+ truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
		FlxG.sound.music.onComplete = endSong;
	}

	var debugNum:Int = 0;
	var isFunnySong = false;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % Main.keyAmmo[mania]);
				var daNoteStyle:String = songNotes[3];

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > Main.keyAmmo[mania] - 1)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, gottaHitNote, daNoteStyle);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);
				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(SONG.speed, 2)), daNoteData, oldNote, true, gottaHitNote);
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);

						sustainNote.mustPress = gottaHitNote;

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else
				{
				}

			}
			daBeats += 1;
		}

		if (altSong != null) {
			altNotes = new FlxTypedGroup<Note>();
			isFunnySong = true;
			daBeats = 0;
			for (section in altSong.notes) {
				for (noteJunk in section.sectionNotes) {
					var swagNote:Note = new Note(noteJunk[0], Std.int(noteJunk[1] % Main.keyAmmo[mania]), null, false, false, noteJunk[3]);
					swagNote.isAlt = true;

					altUnspawnNotes.push(swagNote);

					swagNote.mustPress = false;
					swagNote.x -= 250;
				}
			}
			altUnspawnNotes.sort(sortByShit);
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

	var arrowJunks:Array<Array<Float>> = [];

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...Main.keyAmmo[mania])
		{
			// FlxG.log.add(i);
			var babyArrow:Strum = new Strum(0, strumLine.y, i);

			if (Note.CharactersWith3D.contains(dad.curCharacter) && player == 0 || Note.CharactersWith3D.contains(boyfriend.curCharacter) && player == 1)
			{
				babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets_3D');
				babyArrow.animation.addByPrefix('green', 'arrowUP');
				babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
				babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
				babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

				babyArrow.setGraphicSize(Std.int(babyArrow.width * Note.noteScale));

				var nSuf:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
				var pPre:Array<String> = ['left', 'down', 'up', 'right'];
				switch (mania)
				{
					case 1:
						nSuf = ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'];
						pPre = ['left', 'up', 'right', 'yel', 'down', 'dark'];
					case 2:
						nSuf = ['LEFT', 'UP', 'RIGHT', 'SPACE', 'LEFT', 'DOWN', 'RIGHT'];
						pPre = ['left', 'up', 'right', 'white', 'yel', 'down', 'dark'];
					case 3:
						nSuf = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'SPACE', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
						pPre = ['left', 'down', 'up', 'right', 'white', 'yel', 'violet', 'black', 'dark'];
						babyArrow.x -= Note.tooMuch;
				}
				babyArrow.x += Note.swagWidth * i;
				babyArrow.animation.addByPrefix('static', 'arrow' + nSuf[i]);
				babyArrow.animation.addByPrefix('pressed', pPre[i] + ' press', 24, false);
				babyArrow.animation.addByPrefix('confirm', pPre[i] + ' confirm', 24, false);
			}
			else
			{
				babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
				babyArrow.animation.addByPrefix('green', 'arrowUP');
				babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
				babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
				babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

				babyArrow.antialiasing = true;
				babyArrow.setGraphicSize(Std.int(babyArrow.width * Note.noteScale));

				var nSuf:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
				var pPre:Array<String> = ['left', 'down', 'up', 'right'];
				switch (mania)
				{
					case 1:
						nSuf = ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'];
						pPre = ['left', 'up', 'right', 'yel', 'down', 'dark'];
					case 2:
						nSuf = ['LEFT', 'UP', 'RIGHT', 'SPACE', 'LEFT', 'DOWN', 'RIGHT'];
						pPre = ['left', 'up', 'right', 'white', 'yel', 'down', 'dark'];
					case 3:
						nSuf = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'SPACE', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
						pPre = ['left', 'down', 'up', 'right', 'white', 'yel', 'violet', 'black', 'dark'];
						babyArrow.x -= Note.tooMuch;
				}
				babyArrow.x += Note.swagWidth * i;
				babyArrow.animation.addByPrefix('static', 'arrow' + nSuf[i]);
				babyArrow.animation.addByPrefix('pressed', pPre[i] + ' press', 24, false);
				babyArrow.animation.addByPrefix('confirm', pPre[i] + ' confirm', 24, false);

			}
			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				dadStrums.add(babyArrow);
			}

			babyArrow.playAnim('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);

			if (isFunnySong || SONG.song.toLowerCase() == 'disruption' || (SONG.song.toLowerCase() == 'algebra' && storyDifficulty == 1 && mania == 2))
			arrowJunks.push([babyArrow.x, babyArrow.y]);
			
			babyArrow.resetTrueCoords();
		}

		if (SONG.song.toLowerCase() == 'applecore') {
			swagThings = new FlxTypedGroup<Strum>();

			for (i in 0...Main.keyAmmo[mania])
			{
				// FlxG.log.add(i);
				var babyArrow:Strum = new Strum(0, altStrumLine.y, i);

				babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets_3D');
				babyArrow.animation.addByPrefix('green', 'arrowUP');
				babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
				babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
				babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

				babyArrow.setGraphicSize(Std.int(babyArrow.width * Note.noteScale));

				var nSuf:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
				var pPre:Array<String> = ['left', 'down', 'up', 'right'];
				switch (mania)
				{
					case 1:
						nSuf = ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'];
						pPre = ['left', 'up', 'right', 'yel', 'down', 'dark'];
					case 2:
						nSuf = ['LEFT', 'UP', 'RIGHT', 'SPACE', 'LEFT', 'DOWN', 'RIGHT'];
						pPre = ['left', 'up', 'right', 'white', 'yel', 'down', 'dark'];
					case 3:
						nSuf = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'SPACE', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
						pPre = ['left', 'down', 'up', 'right', 'white', 'yel', 'violet', 'black', 'dark'];
						babyArrow.x -= Note.tooMuch;
				}
				babyArrow.x += Note.swagWidth * i;
				babyArrow.animation.addByPrefix('static', 'arrow' + nSuf[i]);
				babyArrow.animation.addByPrefix('pressed', pPre[i] + ' press', 24, false);
				babyArrow.animation.addByPrefix('confirm', pPre[i] + ' confirm', 24, false);

				babyArrow.updateHitbox();

				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				babyArrow.y -= 1000;

				babyArrow.ID = i;

				poopStrums.add(babyArrow);

				babyArrow.playAnim('static');
				babyArrow.x += 50;
				babyArrow.x -= 250;

				arrowJunks.push([babyArrow.x, babyArrow.y + 1000]);
				var hi = new Strum(0, babyArrow.y, i);
				hi.ID = i;
				swagThings.add(hi);
			}

			add(poopStrums);
			/*poopStrums.forEach(function(spr:FlxSprite){
				spr.alpha = 0;
			});*/

			add(altNotes);
		}
	}

	private var swagThings:FlxTypedGroup<Strum>;

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

			#if desktop
			DiscordClient.changePresence("PAUSED on "
				+ SONG.song,
				botText + "Acc: "
				+ truncateFloat(accuracy, 2)
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

			if (startTimer.finished)
				{
					#if desktop
					DiscordClient.changePresence(SONG.song,
						"\n" + botText + "Acc: "
						+ truncateFloat(accuracy, 2)
						+ "% | Score: "
						+ songScore
						+ " | Misses: "
						+ misses, iconRPC, true,
						FlxG.sound.music.length
						- Conductor.songPosition);
					#end
				}
				else
				{
					#if desktop
					DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") ", iconRPC);
					#end
				}
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

		#if desktop
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song,
			"\n" + botText + "Acc: "
			+ truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	function truncateFloat(number:Float, precision:Int):Float
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}

	private var banduJunk:Float = 0;
	private var dadFront:Bool = false;
	private var hasJunked:Bool = false;
	private var wtfThing:Bool = false;
	private var orbit:Bool = true;
	private var poipInMahPahntsIsGud:Bool = true;
	public static var unfairPart:Bool = false;
	private var addspacestatic:Bool = true;
	private var noteJunksPlayer:Array<Float> = [0, 0, 0, 0];
	private var noteJunksDad:Array<Float> = [0, 0, 0, 0];
	private var what:FlxTypedGroup<FlxSprite>;
	private var wow2:Array<Array<Float>> = [];
	private var gasw2:Array<Float> = [];
	private var poiping:Bool = true;
	private var canPoip:Bool = true;
	private var lanceyLovesWow2:Array<Bool> = [false, false];
	private var whatDidRubyJustSay:Int = 0;
	private var likeawing:Array<Float> = [-90 + (-360 / 7) * 4, 180 + (-360 / 7) * 5, 90 + (-360 / 7) * 6, 0, -90 + (-360 / 7), (-360 / 7) * 2, 90 + (-360 / 7) * 3];

	override public function update(elapsed:Float)
	{
		elapsedtime += elapsed;
		if(bfSpazOut)
		{
			boyfriend.playAnim('sing' + spaz[FlxG.random.int(0,3)]);
		}
		dadChar = dad.curCharacter;
		bfChar = boyfriend.curCharacter;
		if(redTunnel != null)
		{
			redTunnel.angle += elapsed * 3.5;
			if (boyfriend.curCharacter == 'tunnel-shaggy') {
				/* if (curBeat < 16)
				{
					sh_r = 60;
				}
				else if (curBeat >= 640 || (curBeat >= 256 && curBeat <= 384))
				{
					if (sh_r > 60) sh_r -= 1;
				}
				else
				{
					if (sh_r < 600) sh_r += 1;
				} */
				var rotRateSh = curStep / 9.5;
				var sh_toy = -Math.sin(rotRateSh * 2) * sh_r * 0.45;
				var sh_tox = 800 -Math.cos(rotRateSh) * sh_r;
				boyfriend.x += (sh_tox - boyfriend.x) / 12;
				boyfriend.y += (sh_toy - boyfriend.y) / 12;

				if (boyfriend.animation.name == 'idle')
				{
					var pene = 0.07;
					boyfriend.angle = Math.sin(rotRateSh) * sh_r * pene / 4;

					legs.alpha = 1;
					legs.angle = Math.sin(rotRateSh) * sh_r * pene;// + Math.cos(curStep) * 5;

					legs.x = boyfriend.x + 120 + Math.cos((legs.angle + 90) * (Math.PI/180)) * 150;
					legs.y = boyfriend.y + 300 + Math.sin((legs.angle + 90) * (Math.PI/180)) * 150;
				}
				else
				{
					boyfriend.angle = 0;
					legs.alpha = 0;
				}
				legT.visible = true;
				if (legs.alpha == 0)
					legT.visible = false;
			}
		}
		banduJunk += elapsed * 2.5;
		if(badaiTime)
		{
			dad.angle += elapsed * 50;
		}
		if (curbg != null)
		{
			if (curbg.active) // only the furiosity background is active
			{
				var shad = cast(curbg.shader, Shaders.GlitchShader);
				shad.uTime.value[0] += elapsed;
			}
		}

		//dvd screensaver lookin ass
		if(daveFuckingDies != null && redTunnel != null && !daveFuckingDies.inCutscene)
		{
			FlxG.watch.addQuick("DAVE JUNK!!?!?!", [daveFuckingDies.x, daveFuckingDies.y]);
			if(daveFuckingDies.x >= (redTunnel.width - 1000) || daveFuckingDies.y >= (redTunnel.height - 1000))
			{
				daveFuckingDies.bounceAnimState = 1;
				daveFuckingDies.bounceMultiplier = FlxG.random.float(-0.75, -1.15);
				daveFuckingDies.yBullshit = FlxG.random.float(0.95, 1.05);
				daveFuckingDies.dance();
			}
			else if(daveFuckingDies.x <= (redTunnel.x + 100) || daveFuckingDies.y <= (redTunnel.y + 100))
			{
				daveFuckingDies.bounceAnimState = 2;
				daveFuckingDies.bounceMultiplier = FlxG.random.float(0.75, 1.15);
				daveFuckingDies.yBullshit = FlxG.random.float(0.95, 1.05);
				daveFuckingDies.dance();
			}
			else if(daveFuckingDies.x >= (redTunnel.width - 1150) || daveFuckingDies.y >= (redTunnel.height - 1150))
			{
				daveFuckingDies.bounceAnimState = 1;
			}
			else if(daveFuckingDies.x <= (redTunnel.x + 250) || daveFuckingDies.y <= (redTunnel.y + 250))
			{
				daveFuckingDies.bounceAnimState = 2;
			}
			else
			{
				daveFuckingDies.bounceAnimState = 0;
			}
		}

		if (SONG.song.toLowerCase() == 'applecore') {

			if (poiping) {
				what.forEach(function(spr:FlxSprite){
					spr.x += Math.abs(Math.sin(elapsed)) * gasw2[spr.ID];
					if (spr.x > 3000 && !lanceyLovesWow2[spr.ID]) {
						lanceyLovesWow2[spr.ID] = true;
						trace('whattttt ${spr.ID}');
						whatDidRubyJustSay++;
					}
				});
				if (whatDidRubyJustSay >= 2) poiping = false;
			}
			else if (canPoip) {
				trace("ON TO THE POIPIGN!!!");
				canPoip = false;
				lanceyLovesWow2 = [false, false];
				whatDidRubyJustSay = 0;
				new FlxTimer().start(FlxG.random.float(3, 6.3), function(tmr:FlxTimer){
					what.forEach(function(spr:FlxSprite){
						spr.visible = true;
						spr.x = FlxG.random.int(-2000, -3000);
						gasw2[spr.ID] = FlxG.random.int(600, 1200);
						if (spr.ID == 1) {
							trace("POIPING...");
							poiping = true;
							canPoip = true;
						}
					});
				});
			}

			what.forEach(function(spr:FlxSprite){
				var daCoords = wow2[spr.ID];

				daCoords[4] == 1 ? 
				spr.y = Math.cos(elapsedtime + spr.ID) * daCoords[3] + daCoords[1]: 
				spr.y = Math.sin(elapsedtime) * daCoords[3] + daCoords[1];

				spr.y += 45;

				var dontLookAtAmongUs:Float = Math.sin(elapsedtime * 1.5) * 0.05 + 0.95;

				spr.scale.set(dontLookAtAmongUs - 0.15, dontLookAtAmongUs - 0.15);

				if (dad.POOP) spr.angle += (Math.sin(elapsed * 2) * 0.5 + 0.5) * spr.ID == 1 ? 0.65 : -0.65;
			});

			playerStrums.forEach(function(spr:Strum){
				noteJunksPlayer[spr.ID] = spr.y;
			});
			dadStrums.forEach(function(spr:Strum){
				noteJunksDad[spr.ID] = spr.y;
			});
			if (unfairPart && FlxG.save.data.modchart) {
				swagSpeed = 1.5;
				if (mania == 1) swagSpeed = 1.3;
				if (mania == 2) swagSpeed = 1.2;
				if (mania == 3) swagSpeed = 1;
				var num:Float = 1;
				if (mania == 1) num = 1.5;
				if (mania == 2) num = 1.75;
				if (mania == 3) num = 2.25;
				if (FlxG.save.data.newunfair) {
					var ddr:Array<Int> = [3, 0, 2, 1];
					if (mania == 2) ddr = [4, 5, 6, 0, 1, 2, 3];
					playerStrums.forEach(function(spr:FlxSprite)
					{
						spr.x = FlxG.width / 2 + (Math.sin(elapsedtime + (ddr[spr.ID] / num) * (Math.PI / 2)) * 150) - 156 * Note.scales[mania] / 2;
						spr.y = FlxG.height / 2 + (Math.cos(elapsedtime + (ddr[spr.ID] / num) * (Math.PI / 2)) * 150) - 156 * Note.scales[mania] / 2;
						if (spr.ID != 3 || mania != 2) {
							spr.angle = elapsedtime * -(360 / Math.PI / 2);
							if (mania == 2) spr.angle += likeawing[spr.ID];
						}
					});
					dadStrums.forEach(function(spr:FlxSprite)
					{
						spr.x = FlxG.width / 2 + (Math.sin(elapsedtime * 2 + (ddr[spr.ID] / num) * (Math.PI / 2) + (Math.PI / 4)) * 300) - 156 * Note.scales[mania] / 2;
						spr.y = FlxG.height / 2 + (Math.cos(elapsedtime * 2 + (ddr[spr.ID] / num) * (Math.PI / 2) + (Math.PI / 4)) * 300) - 156 * Note.scales[mania] / 2;
						if (spr.ID != 3 || mania != 2) {
							spr.angle = elapsedtime * 2 * -(360 / Math.PI / 2) + 135;
							if (mania == 2) spr.angle += likeawing[spr.ID];
						}
					});
				}
				else {
					playerStrums.forEach(function(spr:FlxSprite)
					{
						spr.x = ((FlxG.width / 2) - (156 * Note.scales[mania] / 2)) + (Math.sin(elapsedtime + (spr.ID / num)) * 300);
						spr.y = ((FlxG.height / 2) - (156 * Note.scales[mania] / 2)) + (Math.cos(elapsedtime + (spr.ID / num)) * 300);
					});
					dadStrums.forEach(function(spr:FlxSprite)
					{
						spr.x = ((FlxG.width / 2) - (156 * Note.scales[mania] / 2)) + (Math.sin((elapsedtime + (spr.ID)) * 2) * 300);
						spr.y = ((FlxG.height / 2) - (156 * Note.scales[mania] / 2)) + (Math.cos((elapsedtime + (spr.ID)) * 2) * 300);
					});
				}
			}
			if (SONG.notes[Math.floor(curStep / 16)] != null) {
				if (SONG.notes[Math.floor(curStep / 16)].altAnim && !unfairPart) {
					if (FlxG.save.data.modchart) {
						var krunkThing = 60;
						if (mania == 1) krunkThing = 50;
						if (mania == 2) krunkThing = 47;
						if (mania == 3) krunkThing = 40;

						playerStrums.forEach(function(spr:Strum)
						{
							spr.x = arrowJunks[spr.ID + Main.keyAmmo[mania] * 2][0] + (Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1)) * krunkThing;
							spr.y = arrowJunks[spr.ID + Main.keyAmmo[mania] * 2][1] + Math.sin(elapsedtime - 5) * ((spr.ID % 2) == 0 ? 1 : -1) * krunkThing;
	
							spr.scale.x = Math.abs(Math.sin(elapsedtime - 5) * ((spr.ID % 2) == 0 ? 1 : -1)) / Main.keyAmmo[mania];
	
							spr.scale.y = Math.abs((Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1)) / (Main.keyAmmo[mania] / 2));
			
							spr.scale.x += 0.2;
							spr.scale.y += 0.2;
	
							spr.scale.x *= 1.5;
							spr.scale.y *= 1.5;
						});
	
						dadStrums.forEach(function(spr:Strum)
						{
							spr.x = arrowJunks[spr.ID][0] + (Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1)) * krunkThing;
							spr.y = arrowJunks[spr.ID][1] + Math.sin(elapsedtime - 5) * ((spr.ID % 2) == 0 ? 1 : -1) * krunkThing;
							
							spr.scale.x = Math.abs(Math.sin(elapsedtime - 5) * ((spr.ID % 2) == 0 ? 1 : -1)) / Main.keyAmmo[mania];
			
							spr.scale.y = Math.abs((Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1)) / (Main.keyAmmo[mania] / 2));
			
							spr.scale.x += 0.2;
							spr.scale.y += 0.2;
			
							spr.scale.x *= 1.5;
							spr.scale.y *= 1.5;
						});
	
						poopStrums.forEach(function(spr:Strum)
						{
							spr.x = arrowJunks[spr.ID + Main.keyAmmo[mania]][0] + (Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1)) * krunkThing;
							spr.y = swagThings.members[spr.ID].y + Math.sin(elapsedtime - 5) * ((spr.ID % 2) == 0 ? 1 : -1) * krunkThing;
	
							spr.scale.x = Math.abs(Math.sin(elapsedtime - 5) * ((spr.ID % 2) == 0 ? 1 : -1)) / Main.keyAmmo[mania];
	
							spr.scale.y = Math.abs((Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1)) / (Main.keyAmmo[mania] / 2));
			
							spr.scale.x += 0.2;
							spr.scale.y += 0.2;
	
							spr.scale.x *= 1.5;
							spr.scale.y *= 1.5;
						});
	
						altNotes.forEachAlive(function(spr:Note){
							spr.x = arrowJunks[(spr.noteData % Main.keyAmmo[mania]) + Main.keyAmmo[mania]][0] + (Math.sin(elapsedtime) * ((spr.noteData % 2) == 0 ? 1 : -1)) * krunkThing;
							spr.y = arrowJunks[(spr.noteData % Main.keyAmmo[mania]) + Main.keyAmmo[mania]][1] + (Math.sin(elapsedtime - 5) * ((spr.noteData % 2) == 0 ? 1 : -1)) * krunkThing - (Conductor.songPosition - spr.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed + 1, 2));
							#if debug
							if (FlxG.keys.justPressed.SPACE) {
								trace(arrowJunks[(spr.noteData % Main.keyAmmo[mania]) + Main.keyAmmo[mania]][0]);
								trace(spr.noteData);
								trace(spr.x == arrowJunks[(spr.noteData % Main.keyAmmo[mania]) + Main.keyAmmo[mania]][0] + (Math.sin(elapsedtime) * ((spr.noteData % 2) == 0 ? 1 : -1)) * krunkThing);
							}
							#end
	
							spr.scale.x = Math.abs(Math.sin(elapsedtime - 5) * ((spr.noteData % 2) == 0 ? 1 : -1)) / Main.keyAmmo[mania];
	
							spr.scale.x += 0.2;

							spr.scale.x *= 1.5;
							if (!spr.isSustainNote) {
			
								spr.scale.y = Math.abs((Math.sin(elapsedtime) * ((spr.noteData % 2) == 0 ? 1 : -1)) / (Main.keyAmmo[mania] / 2));
						
								spr.scale.y += 0.2;
				
								spr.scale.y *= 1.5;
							}
						});
					}
					else {
						poopStrums.forEach(function(spr:Strum)
						{
							spr.y = swagThings.members[spr.ID].y;
						});
					}					
				}
				if (!SONG.notes[Math.floor(curStep / 16)].altAnim && wtfThing) {
				}
			}
		}

		//welcome to 3d sinning avenue
		if(funnyFloatyBoys.contains(dad.curCharacter.toLowerCase()) && canFloat && orbit)
		{
			switch(dad.curCharacter) 
			{
				case 'bandu-candy':
					dad.x += Math.sin(elapsedtime * 50) / 9;
				case 'bandu':
					dad.x = boyfriend.getMidpoint().x + Math.sin(banduJunk) * 500 - (dad.width / 2);
					dad.y += (Math.sin(elapsedtime) * 0.2);
					dadmirror.setPosition(dad.x, dad.y);

					/*
					var deezScale =	(
						!dadFront ?
						Math.sqrt(
					boyfriend.getMidpoint().distanceTo(dad.getMidpoint()) / 500 * 0.5):
					Math.sqrt(
					(500 - boyfriend.getMidpoint().distanceTo(dad.getMidpoint())) / 500 * 0.5 + 0.5));
					dad.scale.set(deezScale, deezScale);
					dadmirror.scale.set(deezScale, deezScale);
					*/

					if ((Math.sin(banduJunk) >= 0.95 || Math.sin(banduJunk) <= -0.95) && !hasJunked){
						dadFront = !dadFront;
						hasJunked = true;
					}
					if (hasJunked && !(Math.sin(banduJunk) >= 0.95 || Math.sin(banduJunk) <= -0.95)) hasJunked = false;

					dadmirror.visible = dadFront;
					dad.visible = !dadFront;
				case 'badai':
					dad.angle += elapsed * 10;
					dad.y += (Math.sin(elapsedtime) * 0.6);
				case 'ringi':
					dad.y += (Math.sin(elapsedtime) * 0.6);
					dad.x += (Math.sin(elapsedtime) * 0.6);
				case 'bambom':
					dad.y += (Math.sin(elapsedtime) * 0.75);
					dad.x = -700 + Math.sin(elapsedtime) * 425;
				case 'tunnel-dave':
					dad.y -= (Math.sin(elapsedtime) * 0.6);
				default:
					dad.y += (Math.sin(elapsedtime) * 0.6);
			}
		}
		if(badai != null)
		{
			switch(badai.curCharacter) 
			{
				case 'bandu':
					badai.x = boyfriend.getMidpoint().x + Math.sin(banduJunk) * 500 - (dad.width / 2);
					badai.y += (Math.sin(elapsedtime) * 0.2);
					dadmirror.setPosition(dad.x, dad.y);

					/*
					var deezScale =	(
						!dadFront ?
						Math.sqrt(
					boyfriend.getMidpoint().distanceTo(dad.getMidpoint()) / 500 * 0.5):
					Math.sqrt(
					(500 - boyfriend.getMidpoint().distanceTo(dad.getMidpoint())) / 500 * 0.5 + 0.5));
					dad.scale.set(deezScale, deezScale);
					dadmirror.scale.set(deezScale, deezScale);
					*/

					if ((Math.sin(banduJunk) >= 0.95 || Math.sin(banduJunk) <= -0.95) && !hasJunked){
						dadFront = !dadFront;
						hasJunked = true;
					}
					if (hasJunked && !(Math.sin(banduJunk) >= 0.95 || Math.sin(banduJunk) <= -0.95)) hasJunked = false;

					dadmirror.visible = dadFront;
					badai.visible = !dadFront;
				case 'badai':
					badai.angle = Math.sin(elapsedtime) * 15;
					badai.x += Math.sin(elapsedtime) * 0.6;
					badai.y += (Math.sin(elapsedtime) * 0.6);
				default:
					badai.y += (Math.sin(elapsedtime) * 0.6);
			}
		}
		if (littleIdiot != null) {
			if(funnyFloatyBoys.contains(littleIdiot.curCharacter.toLowerCase()) && canFloat && poipInMahPahntsIsGud)
			{
				littleIdiot.y += (Math.sin(elapsedtime) * 0.75);
				littleIdiot.x = 200 + Math.sin(elapsedtime) * 425;
			}
		}
		if (swagger != null) {
			if(funnyFloatyBoys.contains(swagger.curCharacter.toLowerCase()) && canFloat)
			{
				swagger.y += (Math.sin(elapsedtime) * 0.6);
			}
		}
		if(funnyFloatyBoys.contains(boyfriend.curCharacter.toLowerCase()) && canFloat)
		{
			switch(boyfriend.curCharacter)
			{
				case 'ringi':
					boyfriend.y += (Math.sin(elapsedtime) * 0.6);
					boyfriend.x += (Math.sin(elapsedtime) * 0.6);
				case 'bambom':
					boyfriend.y += (Math.sin(elapsedtime) * 0.75);
					boyfriend.x = 200 + Math.sin(elapsedtime) * 425;
				default:
					boyfriend.y += (Math.sin(elapsedtime) * 0.6);
			}
		}
		/*if(funnyFloatyBoys.contains(dadmirror.curCharacter.toLowerCase()))
		{
			dadmirror.y += (Math.sin(elapsedtime) * 0.6);
		}*/
		if(funnyFloatyBoys.contains(gf.curCharacter.toLowerCase()) && canFloat)
		{
			gf.y += (Math.sin(elapsedtime) * 0.6);
		}

		if (SONG.song.toLowerCase() == 'cheating') // fuck you
		{
			playerStrums.forEach(function(spr:Strum)
			{
				spr.x += Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1);
				spr.x -= Math.sin(elapsedtime) * 1.5;
			});
			dadStrums.forEach(function(spr:Strum)
			{
				spr.x -= Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1);
				spr.x += Math.sin(elapsedtime) * 1.5;
			});
		}

		if(SONG.song.toLowerCase() == 'disability' && FlxG.save.data.modchart)
		{
			playerStrums.forEach(function(spr:Strum)
			{
				spr.angle += (Math.sin(elapsedtime * 2.5) + 1) * 5;
			});
			dadStrums.forEach(function(spr:Strum)
			{
				spr.angle += (Math.sin(elapsedtime * 2.5) + 1) * 5;
			});
			for(note in notes)
			{
				if(note.mustPress)
				{
					if (!note.isSustainNote)
						note.angle = playerStrums.members[note.noteData].angle;
				}
				else
				{
					if (!note.isSustainNote)
						note.angle = dadStrums.members[note.noteData].angle;
				}
			}
		}

		if (SONG.song.toLowerCase() == 'algebra' && storyDifficulty == 1 && mania == 2) {
			playerStrums.forEach(function(spr:FlxSprite)
			{
				spr.x = arrowJunks[spr.ID + Main.keyAmmo[mania]][0] + (!addspacestatic ? 
					(spr.ID == 3 ? 1000 : 
					(spr.ID < 3 ? 38.5 : 
					(spr.ID > 3 ? -38.5 : 0))) : 0);
			});
			dadStrums.forEach(function(spr:Strum)
			{
				spr.x = arrowJunks[spr.ID][0] + (!addspacestatic ? 
					(spr.ID == 3 ? 1000 : 
					(spr.ID < 3 ? 38.5 : 
					(spr.ID > 3 ? -38.5 : 0))) : 0);
			});
			notes.forEachAlive(function(spr:Note){
				if (spr.mustPress) {
					spr.x = arrowJunks[spr.noteData + Main.keyAmmo[mania]][0] + (!addspacestatic ? 
						(spr.noteData == 3 ? 1000 : 
						(spr.noteData < 3 ? 38.5 : 
						(spr.noteData > 3 ? -38.5 : 0))) : 0);
				}
				else {
					spr.x = arrowJunks[spr.noteData][0] + (!addspacestatic ? 
						(spr.noteData == 3 ? 1000 : 
						(spr.noteData < 3 ? 38.5 : 
						(spr.noteData > 3 ? -38.5 : 0))) : 0);
				}
				if (spr.isSustainNote) {
					spr.x -= spr.width / 2;
					spr.x += 156 * Note.scales[mania] / 2;
				}
			});
		}
		if (SONG.song.toLowerCase() == 'disruption') // deez all day
		{
			var krunkThing = 60;
			if (mania == 1) krunkThing = 50;
			if (mania == 2) krunkThing = 47;
			if (mania == 3) krunkThing = 40;

			poop.alpha = Math.sin(elapsedtime) / 2.5 + 0.4;

			if (FlxG.save.data.modchart) {
				playerStrums.forEach(function(spr:FlxSprite)
				{
					spr.x = arrowJunks[spr.ID + Main.keyAmmo[mania]][0] + (Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1)) * krunkThing;
					spr.y = arrowJunks[spr.ID + Main.keyAmmo[mania]][1] + Math.sin(elapsedtime - 5) * ((spr.ID % 2) == 0 ? 1 : -1) * krunkThing;
	
					spr.scale.x = Math.abs(Math.sin(elapsedtime - 5) * ((spr.ID % 2) == 0 ? 1 : -1)) / Main.keyAmmo[mania];
	
					spr.scale.y = Math.abs((Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1)) / (Main.keyAmmo[mania] / 2));
	
					spr.scale.x += 0.2;
					spr.scale.y += 0.2;
	
					spr.scale.x *= 1.5;
					spr.scale.y *= 1.5;
				});
				dadStrums.forEach(function(spr:Strum)
				{
					spr.x = arrowJunks[spr.ID][0] + (Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1)) * krunkThing;
					spr.y = arrowJunks[spr.ID][1] + Math.sin(elapsedtime - 5) * ((spr.ID % 2) == 0 ? 1 : -1) * krunkThing;
					
					spr.scale.x = Math.abs(Math.sin(elapsedtime - 5) * ((spr.ID % 2) == 0 ? 1 : -1)) / Main.keyAmmo[mania];
	
					spr.scale.y = Math.abs((Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1)) / (Main.keyAmmo[mania] / 2));
	
					spr.scale.x += 0.2;
					spr.scale.y += 0.2;
	
					spr.scale.x *= 1.5;
					spr.scale.y *= 1.5;
				});
			}
		}

		FlxG.watch.addQuick("WHAT", Conductor.songPosition);
			
		FlxG.camera.setFilters([new ShaderFilter(screenshader.shader)]); // this is very stupid but doesn't effect memory all that much so
		if (shakeCam && eyesoreson)
		{
			// var shad = cast(FlxG.camera.screen.shader,Shaders.PulseShader);
			FlxG.camera.shake(0.015, 0.015);
		}
		screenshader.shader.uTime.value[0] += elapsed;
		if (shakeCam && eyesoreson)
		{
			screenshader.shader.uampmul.value[0] = 1;
		}
		else
		{
			screenshader.shader.uampmul.value[0] -= (elapsed / 2);
		}
		screenshader.Enabled = shakeCam && eyesoreson;

		if (FlxG.keys.justPressed.NINE && iconP1.charPublic != 'bandu-origin')
		{
			if (iconP1.animation.curAnim.name == boyfriendOldIcon)
			{
				var isBF:Bool = formoverride == 'bf' || formoverride == 'none';
				iconP1.animation.play(isBF ? SONG.player1 : formoverride);
			}
			else
			{
				iconP1.animation.play(boyfriendOldIcon);
			}
		}
		var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);
		if((!inCutscene && camMoveAllowed) || (SONG.song.toLowerCase() == 'origin' && inCutscene))
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		super.update(elapsed);

		if (health > 2)
			health = 2;

		if (health < 0)
			health = 0;

		scoreTxt.text = "Score:" + songScore + " | Misses:" + misses + " | Combo:" + combo + " | Health:" + Math.floor(health * 500) / 10 + "%" + " | Accuracy:" + truncateFloat(accuracy, 2) + "% ";
		extraTxt.text = "Opponent Notes Count: " + opponentnotecount;

		if(botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;
			trace('PAULSCODE ' + paused);

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			PlayState.characteroverride = 'none';
			PlayState.formoverride = 'none';
			FlxG.switchState(new ChartingState());
			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.centerOffsets();
		iconP2.centerOffsets();

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if(iconP1.charPublic != 'bandu-origin') {
			healthBar.percent < 20 ?
				iconP1.animation.curAnim.curFrame = 1:
				iconP1.animation.curAnim.curFrame = 0;
		}

		if(iconP2.charPublic != 'bandu-origin') {
			healthBar.percent > 80 ?
				iconP2.animation.curAnim.curFrame = 1:
				iconP2.animation.curAnim.curFrame = 0;
		}

		//iconP2.animation.curAnim.curFrame = 0;
				

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		if (FlxG.keys.justPressed.EIGHT)
		{
			PlayState.characteroverride = 'none';
			PlayState.formoverride = 'none';
			FlxG.switchState(new AnimationDebug(dad.curCharacter));
		}
		if (FlxG.keys.justPressed.TWO)
		{
			PlayState.characteroverride = 'none';
			PlayState.formoverride = 'none';
			FlxG.switchState(new AnimationDebug(boyfriend.curCharacter));
		}
		if (FlxG.keys.justPressed.THREE)
		{
			PlayState.characteroverride = 'none';
			PlayState.formoverride = 'none';
			FlxG.switchState(new AnimationDebug(gf.curCharacter));
		}
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

				if(updateTime) 
				{
					var curTime:Float = Conductor.songPosition;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if(secondsTotal < 0) secondsTotal = 0;
					
					timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong.toLowerCase() == 'furiosity')
		{
			switch (curBeat)
			{
				case 127:
					camZooming = true;
				case 159:
					camZooming = false;
				case 191:
					camZooming = true;
				case 223:
					camZooming = false;
			}
		}

		if (health <= 0 && !botPlay && !practiceMode)
		{
			if(!perfectMode)
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;
	
				vocals.stop();
				FlxG.sound.music.stop();
	
				screenshader.shader.uampmul.value[0] = 0;
				screenshader.Enabled = false;
			}

			if(shakeCam)
			{
				FlxG.save.data.unlockedcharacters[7] = true;
			}

			if (!shakeCam)
			{
				if(!perfectMode)
				{
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition()
						.y, formoverride == "bf" || formoverride == "none" ? SONG.player1 : formoverride));

						#if desktop
						DiscordClient.changePresence("GAME OVER -- "
						+ SONG.song
						+ " ("
						+ storyDifficultyText
						+ ") ",
						"\n" + botText + "Acc: "
						+ truncateFloat(accuracy, 2)
						+ "% | Score: "
						+ songScore
						+ " | Misses: "
						+ misses, iconRPC);
						#end
				}
			}
			else
			{
				if (isStoryMode)
				{
					switch (SONG.song.toLowerCase())
					{
						case 'blocked' | 'corn-theft' | 'maze':
							FlxG.openURL("https://www.youtube.com/watch?v=eTJOdgDzD64");
							System.exit(0);
						default:
							PlayState.characteroverride = 'none';
							PlayState.formoverride = 'none';
							FlxG.switchState(new EndingState('rtxx_ending', 'badEnding'));
					}
				}
				else
				{
					if(!perfectMode)
					{
						openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition()
							.y, formoverride == "bf" || formoverride == "none" ? SONG.player1 : formoverride));

							#if desktop
							DiscordClient.changePresence("GAME OVER - "
							+ SONG.song,
							"\n" + botText + "Acc: "
							+ truncateFloat(accuracy, 2)
							+ "% | Score: "
							+ songScore
							+ " | Misses: "
							+ misses, iconRPC);
							#end
					}
				}
			}

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < (unfairPart && FlxG.save.data.modchart ? 15000 : 1500))
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);
				dunceNote.finishedGenerating = true;

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (altUnspawnNotes[0] != null)
		{
			if (altUnspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = altUnspawnNotes[0];
				altNotes.add(dunceNote);
				dunceNote.finishedGenerating = true;

				var index:Int = altUnspawnNotes.indexOf(dunceNote);
				altUnspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			if (isFunnySong) {
				altNotes.forEachAlive(function(daNote:Note)
				{
					// daNote.y = (altStrumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal((SONG.speed + 1) * 1, 2)));

					if (daNote.wasGoodHit)
					{
						swagger.playAnim('sing' + notestuffs[Math.round(Math.abs(daNote.noteData)) % Main.keyAmmo[mania]], true);
						swagger.holdTimer = 0;
						
						FlxG.camera.shake(0.0075, 0.1);
						camHUD.shake(0.0045, 0.1);

						if (storyDifficulty == 1) health -=  0.02 / 4.2;
						else health -=  0.02 / 2.65;

						var time:Float = 0.15;
						if(daNote.isSustainNote && !daNote.animation.curAnim.name.endsWith('end')) {
							time += 0.15;
						}
						poopStrums.forEach(function(sprite:Strum)
						{
							if (Math.abs(Math.round(Math.abs(daNote.noteData)) % Main.keyAmmo[mania]) == sprite.ID)
							{
								sprite.playAnim('confirm', true);
								sprite.resetAnim = time;
							}
						});

						if (!daNote.isSustainNote) opponentnotecount += 1;

						if (SONG.needsVoices)
							vocals.volume = 1;

						if (!daNote.isSustainNote)
						{
							daNote.kill();
							altNotes.remove(daNote, true);
							daNote.destroy();
						}
					}
				});
			}
			var newUnfairModChart:Bool = SONG.song.toLowerCase() == 'applecore' && unfairPart && FlxG.save.data.modchart && FlxG.save.data.newunfair;
			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			notes.forEachAlive(function(daNote:Note)
			{
				var songSpeed:Float = SONG.speed;
				if (SONG.song.toLowerCase() == 'algebra') songSpeed = swagSpeed;

				var notesScroll:Float = FlxG.save.data.downscroll ? -0.45 : 0.45;
	
				if (FlxG.save.data.modchart) {
					if (unfairPart) {
						var num:Float = 1;
						if (mania == 1) num = 1.5;
						if (mania == 2) num = 1.75;
						if (mania == 3) num = 2.25;
						if (FlxG.save.data.newunfair) {
							var ddr:Array<Int> = [3, 0, 2, 1];
							if (mania == 2) ddr = [4, 5, 6, 0, 1, 2, 3];
							if(daNote.mustPress)
							{
								daNote.x = playerStrums.members[daNote.noteData].x + Math.sin(elapsedtime + (ddr[daNote.noteData] / num) * (Math.PI / 2)) * (Conductor.songPosition - daNote.strumTime) * (-0.45 * FlxMath.roundDecimal(swagSpeed * daNote.localSpreadX, 2));
								daNote.y = playerStrums.members[daNote.noteData].y + Math.cos(elapsedtime + (ddr[daNote.noteData] / num) * (Math.PI / 2)) * (Conductor.songPosition - daNote.strumTime) * (-0.45 * FlxMath.roundDecimal(swagSpeed * daNote.localSpreadY, 2));
								daNote.angle = playerStrums.members[daNote.noteData].angle;
							}
							else
							{
								daNote.x = dadStrums.members[daNote.noteData].x + Math.sin(elapsedtime * 2 + (ddr[daNote.noteData] / num) * (Math.PI / 2) + (Math.PI / 4)) * (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(swagSpeed * daNote.localSpreadX, 2));
								daNote.y = dadStrums.members[daNote.noteData].y + Math.cos(elapsedtime * 2 + (ddr[daNote.noteData] / num) * (Math.PI / 2) + (Math.PI / 4)) * (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(swagSpeed * daNote.localSpreadY, 2));
								daNote.angle = dadStrums.members[daNote.noteData].angle;
							}
							if (daNote.isSustainNote) {
								if (mania == 0) daNote.angle += daNote.noteData == 0 || daNote.noteData == 3 ? 90 : 0;
								if (mania == 2) {
									if (daNote.noteData == 3) daNote.angle = elapsedtime * (daNote.mustPress ? 1 : 2) * -(360 / Math.PI / 2) + (daNote.mustPress ? 0 : 135) + likeawing[daNote.noteData];
									daNote.angle += daNote.noteData == 0 || daNote.noteData == 2 || daNote.noteData == 4 || daNote.noteData == 6 ? 90 : 0;
								}
								daNote.x -= daNote.width / 2;
								daNote.x -= daNote.height / 2;
								daNote.x += 156 * Note.scales[mania] / 2;
								daNote.x += 156 * Note.scales[mania] / 2;
							}
						}
						else {
							if(daNote.mustPress)
							{
								daNote.x = playerStrums.members[daNote.noteData].x;
								daNote.y = playerStrums.members[daNote.noteData].y - (Conductor.songPosition - daNote.strumTime) * (notesScroll * FlxMath.roundDecimal(swagSpeed * daNote.LocalScrollSpeed, 2));
							}
							else
							{
								daNote.x = dadStrums.members[daNote.noteData].x;
								daNote.y = dadStrums.members[daNote.noteData].y - (Conductor.songPosition - daNote.strumTime) * (notesScroll * FlxMath.roundDecimal(swagSpeed * daNote.LocalScrollSpeed, 2));
							}
							if (daNote.isSustainNote) {
								daNote.x -= daNote.width / 2;
								daNote.x += 156 * Note.scales[mania] / 2;
							}
						}
					}
					else if ((SONG.song.toLowerCase() == 'applecore' && SONG.notes[Math.floor(curStep / 16)] != null && SONG.notes[Math.floor(curStep / 16)].altAnim) || SONG.song.toLowerCase() == 'disruption') {
						var krunkThing = 60;
						if (mania == 1) krunkThing = 50;
						if (mania == 2) krunkThing = 47;
						if (mania == 3) krunkThing = 40;
						if (daNote.mustPress) {
							daNote.x = playerStrums.members[daNote.noteData].x;
							daNote.y = playerStrums.members[daNote.noteData].y - (Conductor.songPosition - daNote.strumTime) * (notesScroll * FlxMath.roundDecimal(songSpeed, 2));
							
							daNote.scale.x = playerStrums.members[daNote.noteData].scale.x;
							if (!daNote.isSustainNote) daNote.scale.y = playerStrums.members[daNote.noteData].scale.y;
						}
						else {
							daNote.x = dadStrums.members[daNote.noteData].x;
							daNote.y = dadStrums.members[daNote.noteData].y - (Conductor.songPosition - daNote.strumTime) * (notesScroll * FlxMath.roundDecimal(songSpeed, 2));
							
							daNote.scale.x = dadStrums.members[daNote.noteData].scale.x;
							if (!daNote.isSustainNote) daNote.scale.y = dadStrums.members[daNote.noteData].scale.y;
						}
						if (daNote.isSustainNote) {
							daNote.x -= daNote.width / 2;
							daNote.x += 156 * Note.scales[mania] / 2;
						}
					}
					else daNote.y = strumLine.y - (Conductor.songPosition - daNote.strumTime) * (notesScroll * FlxMath.roundDecimal(songSpeed, 2));
				}
				else daNote.y = strumLine.y - (Conductor.songPosition - daNote.strumTime) * (notesScroll * FlxMath.roundDecimal(songSpeed, 2));

				if (FlxG.save.data.downscroll && daNote.isSustainNote && !newUnfairModChart)
				{
					if (daNote.animation.curAnim.name.endsWith('end')) {
						daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
						daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
						daNote.y -= 19;
					} 
					daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
					daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent)
				{
					if (SONG.song != 'Tutorial')
					camZooming = true;

					var altAnim:String = "";
					var healthtolower:Float = 0.02;

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
						{
							if (SONG.song.toLowerCase() != "cheating")
							{
								altAnim = '-alt';
								if(SONG.song.toLowerCase() == 'sugar-rush')
								{
									//idleAlt = true;
								}
							}
							else
							{
								healthtolower = 0.005;
							}
						}
						else
						{
							if(SONG.song.toLowerCase() == 'sugar-rush')
								idleAlt = false;
						}
					}

					//'LEFT', 'DOWN', 'UP', 'RIGHT'
					var fuckingDumbassBullshitFuckYou:String;
					fuckingDumbassBullshitFuckYou = notestuffs[Math.round(Math.abs(daNote.noteData)) % Main.keyAmmo[mania]];
					if(dad.nativelyPlayable)
					{
						switch(notestuffs[Math.round(Math.abs(daNote.noteData)) % Main.keyAmmo[mania]])
						{
							case 'LEFT':
								fuckingDumbassBullshitFuckYou = 'RIGHT';
							case 'RIGHT':
								fuckingDumbassBullshitFuckYou = 'LEFT';
						}
					}
					if(shakingChars.contains(dad.curCharacter))
					{
						FlxG.camera.shake(0.0075, 0.1);
						camHUD.shake(0.0045, 0.1);
					}
					(SONG.song.toLowerCase() == 'applecore' && !SONG.notes[Math.floor(curStep / 16)].altAnim && !wtfThing && dad.POOP) ? { // hi
						if (littleIdiot != null) littleIdiot.playAnim('sing' + fuckingDumbassBullshitFuckYou + altAnim, true); 
						littleIdiot.holdTimer = 0;}: {
							if(badaiTime)
							{
								badai.holdTimer = 0;
								badai.playAnim('sing' + fuckingDumbassBullshitFuckYou + altAnim, true);
							}
							dad.playAnim('sing' + fuckingDumbassBullshitFuckYou + altAnim, true);
							dadmirror.playAnim('sing' + fuckingDumbassBullshitFuckYou + altAnim, true);
							dad.holdTimer = 0;
							dadmirror.holdTimer = 0;
						}

					var time:Float = 0.15;
					if(daNote.isSustainNote && !daNote.animation.curAnim.name.endsWith('end')) {
						time += 0.15;
					}
					StrumPlayAnim(true, Std.int(Math.abs(daNote.noteData)) % Main.keyAmmo[mania], time);
					daNote.hitByOpponent = true;
					if (!daNote.isSustainNote) opponentnotecount += 1;

					if (UsingNewCam)
					{
						focusOnDadGlobal = true;
						if(camMoveAllowed)
							ZoomCam(true);
					}

					switch (SONG.song.toLowerCase())
					{
						case 'applecore':
							if (unfairPart) health -= healthtolower / 12;
						case 'disruption':
							if (!daNote.animation.curAnim.name.endsWith('end')) {
								if (bambiSpeak) {
									if (storyDifficulty == 1) health -= healthtolower / 4.35;
									else if (storyDifficulty == 2) health -= healthtolower / 5.1;
								}
								else health -= healthtolower / 2.65;
							}
						default:
							if (FlxG.save.data.healthdrain && health > 0.2)
							{
								if (!daNote.isSustainNote)
									health -= 0.01725;
								else
									health -= 0.003;
								if (health < 0.2)
									health = 0.2;
							}
					}

					if (SONG.needsVoices)
						vocals.volume = 1;

					if (!daNote.isSustainNote || (daNote.isSustainNote && newUnfairModChart))
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				}

				if(daNote.mustPress && botPlay) {
					if(daNote.isSustainNote) {
						if(daNote.canBeHit) {
							goodNoteHit(daNote);
						}
					} else if(daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress)) {
						goodNoteHit(daNote);
					}
				}

				var strumY:Float = playerStrums.members[daNote.noteData].y;
				if(!daNote.mustPress) strumY = dadStrums.members[daNote.noteData].y;

				var center:Float = strumY + Note.swagWidth / 2;
				if(daNote.isSustainNote && !newUnfairModChart && (daNote.mustPress || (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit)))))
				{
					if (FlxG.save.data.downscroll)
					{
						if(daNote.y - daNote.scale.y + daNote.height >= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
					else
					{
						if (daNote.y + daNote.scale.y <= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (center - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
				}

				if (Conductor.songPosition > 350 / SONG.speed + daNote.strumTime)
				{
					if(daNote.mustPress && daNote.finishedGenerating && !botPlay && (daNote.tooLate || !daNote.wasGoodHit))
					{
						noteMiss(daNote.noteData);
						health -= 0.075;
						//trace("miss note");
						vocals.volume = 0;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		if(camMoveAllowed && !inCutscene)
			ZoomCam(focusOnDadGlobal);

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function ZoomCam(focusondad:Bool):Void
	{
		var bfplaying:Bool = false;
		if (focusondad)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (!bfplaying)
				{
					if (daNote.mustPress)
					{
						bfplaying = true;
					}
				}
			});
			if (UsingNewCam && bfplaying)
			{
				return;
			}
		}
		if (focusondad)
		{
			focusOnChar(badaiTime ? badai : dad);

			if (SONG.song.toLowerCase() == 'tutorial')
			{
				tweenCamIn();
			}
		}

		if (!focusondad)
		{
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

			if (SONG.song.toLowerCase() == 'applecore')
			{
				defaultCamZoom = 0.5;
				if (boyfriend.curCharacter == 'shaggy') camFollow.y += 70;
			}

			if (boyfriend.curCharacter == 'shaggy')
			{
				camFollow.x += -100;
				camFollow.y += 50;
			}

			if (boyfriend.curCharacter == 'bandu-scaredy') camFollow.x += 350;

			if (SONG.song.toLowerCase() == 'tutorial')
			{
				FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
			}
		}
	}

	public static var xtraSong:Bool = false;

	function focusOnChar(char:Character) {
		camFollow.set(char.getMidpoint().x + 150, char.getMidpoint().y - 100);
		// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

		switch (char.curCharacter)
		{
			case 'bandu':
				char.POOP ? {
				!SONG.notes[Math.floor(curStep / 16)].altAnim ? {
				camFollow.set(littleIdiot.getMidpoint().x, littleIdiot.getMidpoint().y - 300);
				defaultCamZoom = 0.35;
				} :
					camFollow.set(swagger.getMidpoint().x + 150, swagger.getMidpoint().y - 100);
			} : {
				if (boyfriend.curCharacter == 'shaggy') camFollow.set(boyfriend.getMidpoint().x - 200, boyfriend.getMidpoint().y + 20);
				else camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			}
			case 'bandu-candy':
				camFollow.set(char.getMidpoint().x + 175, char.getMidpoint().y - 85);

			case 'bambom':
				camFollow.y += 100;

			case 'RECOVERED_PROJECT_2' | 'RECOVERED_PROJECT_3':
				camFollow.x += 300;
				camFollow.y += 320;
			case 'sart-producer':
				camFollow.x -= 100;
			case 'sart-producer-night':
				camFollow.y += 250;
				camFollow.x -= 425;
			case 'dave-wheels':
				camFollow.y -= 150;
			case 'garrett':
				camFollow.y -= 70;
			case 'hall-monitor':
				camFollow.x -= 200;
				camFollow.y -= 230;
			case 'playrobot':
				camFollow.x -= 160;
				camFollow.y -= 10;
			case 'playrobot-crazy':
				camFollow.x -= 160;
				camFollow.y -= 10;
			case 'rshaggy':
				camFollow.y = dad.getMidpoint().y - 100;
				camFollow.x = dad.getMidpoint().x + 200;
		}
	}

	function endSong():Void
	{
		inCutscene = false;
		canPause = false;
		updateTime = false;

		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore && !botPlay && !practiceMode)
		{
			trace("score is valid");
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty, characteroverride == "none"
				|| characteroverride == "bf" ? "bf" : characteroverride);
			#end
		}

		if (curSong.toLowerCase() == 'bonus-song')
		{
			FlxG.save.data.unlockedcharacters[3] = true;
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			FlxG.save.flush();

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				switch (curSong.toLowerCase())
				{
					default:
						FlxG.switchState(new PlayMenuState());
				}
				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore && !botPlay && !practiceMode)
				{
					NGio.unlockMedal(60961);
					Highscore.saveWeekScore(storyWeek, campaignScore,
						storyDifficulty, characteroverride == "none" || characteroverride == "bf" ? "bf" : characteroverride);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{	
				switch (SONG.song.toLowerCase())
				{
					default:
						nextSong();
				}
			}
		}
		else if (xtraSong) {
			FlxG.switchState(new ExtraSongState());
		}
		else
		{
			if(FlxG.save.data.freeplayCuts && boyfriend.curCharacter != "shaggy")
			{
				switch (SONG.song.toLowerCase())
				{
					default:
						FlxG.switchState(new PlayMenuState());
				}
			}
			else
			{
				FlxG.switchState(new PlayMenuState());
			}
		}
	}

	function ughWhyDoesThisHaveToFuckingExist() 
	{
		FlxG.switchState(new PlayMenuState());
	}

	var endingSong:Bool = false;

	function nextSong()
	{
		var difficulty:String = "";

		if (storyDifficulty == 0)
			difficulty = '-easy';

		if (storyDifficulty == 2)
			difficulty = '-hard';

		if (storyDifficulty == 3)
			difficulty = '-unnerf';

		trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		
		prevCamFollow = camFollow;
		prevCamFollowPos = camFollowPos;

		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
		FlxG.sound.music.stop();
		
		switch (curSong.toLowerCase())
		{
			case 'corn-theft':
				LoadingState.loadAndSwitchState(new VideoState('assets/videos/mazeecutscenee.webm', new PlayState()), false);
			default:
				LoadingState.loadAndSwitchState(new PlayState());
		}
	}
	private function popUpScore(strumtime:Float, notedata:Int):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (!botPlay) {
			if (noteDiff > Conductor.safeZoneOffset * 2)
			{
				daRating = 'shit';
				ss = false;
				totalNotesHit += 0;
				shits++;
			}
			else if (noteDiff < Conductor.safeZoneOffset * -2)
			{
				daRating = 'shit';
				ss = false;
				totalNotesHit += 0;
				shits++;
			}
			else if (noteDiff > Conductor.safeZoneOffset * 0.5)
			{
				daRating = 'bad';
				ss = false;
				totalNotesHit += 0.5;
				bads++;
			}
			else if (noteDiff > Conductor.safeZoneOffset * 0.25)
			{
				daRating = 'good';
				ss = false;
				totalNotesHit += 0.75;
				goods++;
			}
		}
		if (daRating == 'sick')
		{
			totalNotesHit += 1;
			sicks++;
		}
		switch (notedata)
		{
			case 2:
				score = cast(FlxMath.roundDecimal(cast(score, Float) * curmult[2], 0), Int);
			case 3:
				score = cast(FlxMath.roundDecimal(cast(score, Float) * curmult[1], 0), Int);
			case 1:
				score = cast(FlxMath.roundDecimal(cast(score, Float) * curmult[3], 0), Int);
			case 0:
				score = cast(FlxMath.roundDecimal(cast(score, Float) * curmult[0], 0), Int);
		}

		songScore += score;

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		*/

		if(scoreTxtTween != null) 
		{
			scoreTxtTween.cancel();
		}

		scoreTxt.scale.x = 1.1;
		scoreTxt.scale.y = 1.1;
		scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
			onComplete: function(twn:FlxTween) {
				scoreTxtTween = null;
			}
		});

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.cameras = [camHUD];
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.cameras = [camHUD];
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;


		comboSpr.velocity.x += FlxG.random.int(1, 10);
		insert(members.indexOf(strumLineNotes), rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.cameras = [camHUD];
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = true;
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

			//if (combo >= 10 || combo == 0)
				insert(members.indexOf(strumLineNotes), numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
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
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;

	var l1Hold:Bool = false;
	var uHold:Bool = false;
	var r1Hold:Bool = false;
	var l2Hold:Bool = false;
	var dHold:Bool = false;
	var r2Hold:Bool = false;

	var a0Hold:Bool = false;
	var a1Hold:Bool = false;
	var a2Hold:Bool = false;
	var a3Hold:Bool = false;
	var a4Hold:Bool = false;
	var a5Hold:Bool = false;
	var a6Hold:Bool = false;

	var n0Hold:Bool = false;
	var n1Hold:Bool = false;
	var n2Hold:Bool = false;
	var n3Hold:Bool = false;
	var n4Hold:Bool = false;
	var n5Hold:Bool = false;
	var n6Hold:Bool = false;
	var n7Hold:Bool = false;
	var n8Hold:Bool = false;

	var reachBeat:Float;

	private function keyShit():Void
	{
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		var l1 = controls.L1;
		var u = controls.U1;
		var r1 = controls.R1;
		var l2 = controls.L2;
		var d = controls.D1;
		var r2 = controls.R2;

		var l1P = controls.L1_P;
		var uP = controls.U1_P;
		var r1P = controls.R1_P;
		var l2P = controls.L2_P;
		var dP = controls.D1_P;
		var r2P = controls.R2_P;

		var l1R = controls.L1_R;
		var uR = controls.U1_R;
		var r1R = controls.R1_R;
		var l2R = controls.L2_R;
		var dR = controls.D1_R;
		var r2R = controls.R2_R;


		var a0 = controls.A0;
		var a1 = controls.A1;
		var a2 = controls.A2;
		var a3 = controls.A3;
		var a4 = controls.A4;
		var a5 = controls.A5;
		var a6 = controls.A6;

		var a0P = controls.A0_P;
		var a1P = controls.A1_P;
		var a2P = controls.A2_P;
		var a3P = controls.A3_P;
		var a4P = controls.A4_P;
		var a5P = controls.A5_P;
		var a6P = controls.A6_P;

		var a0R = controls.A0_R;
		var a1R = controls.A1_R;
		var a2R = controls.A2_R;
		var a3R = controls.A3_R;
		var a4R = controls.A4_R;
		var a5R = controls.A5_R;
		var a6R = controls.A6_R;

		var n0 = controls.N0;
		var n1 = controls.N1;
		var n2 = controls.N2;
		var n3 = controls.N3;
		var n4 = controls.N4;
		var n5 = controls.N5;
		var n6 = controls.N6;
		var n7 = controls.N7;
		var n8 = controls.N8;

		var n0P = controls.N0_P;
		var n1P = controls.N1_P;
		var n2P = controls.N2_P;
		var n3P = controls.N3_P;
		var n4P = controls.N4_P;
		var n5P = controls.N5_P;
		var n6P = controls.N6_P;
		var n7P = controls.N7_P;
		var n8P = controls.N8_P;

		var n0R = controls.N0_R;
		var n1R = controls.N1_R;
		var n2R = controls.N2_R;
		var n3R = controls.N3_R;
		var n4R = controls.N4_R;
		var n5R = controls.N5_R;
		var n6R = controls.N6_R;
		var n7R = controls.N7_R;
		var n8R = controls.N8_R;

		if (botPlay)
		{
			up = false; //UP;
			right = false; //RIGHT;
			down = false; //DOWN;
			left = false; //LEFT;
	
			upP = false; //UP_P;
			rightP = false; //RIGHT_P;
			downP = false; //DOWN_P;
			leftP = false; //LEFT_P;
	
			upR = false; //UP_R;
			rightR = false; //RIGHT_R;
			downR = false; //DOWN_R;
			leftR = false; //LEFT_R;

			l1 = false; //L1;
			u = false; //U1;
			r1 = false; //R1;
			l2 = false; //L2;
			d = false; //D1;
			r2 = false; //R2;
	
			l1P = false; //L1_P;
			uP = false; //U1_P;
			r1P = false; //R1_P;
			l2P = false; //L2_P;
			dP = false; //D1_P;
			r2P = false; //R2_P;
	
			l1R = false; //L1_R;
			uR = false; //U1_R;
			r1R = false; //R1_R;
			l2R = false; //L2_R;
			dR = false; //D1_R;
			r2R = false; //R2_R;
	
	
			a0 = false; //a0;
			a1 = false; //a1;
			a2 = false; //a2;
			a3 = false; //a3;
			a4 = false; //a4;
			a5 = false; //a5;
			a6 = false; //a6;
	
			a0P = false; //a0_P;
			a1P = false; //a1_P;
			a2P = false; //a2_P;
			a3P = false; //a3_P;
			a4P = false; //a4_P;
			a5P = false; //a5_P;
			a6P = false; //a6_P;
	
			a0R = false; //a0_R;
			a1R = false; //a1_R;
			a2R = false; //a2_R;
			a3R = false; //a3_R;
			a4R = false; //a4_R;
			a5R = false; //a5_R;
			a6R = false; //a6_R;

			n0 = false; //N0;
			n1 = false; //N1;
			n2 = false; //N2;
			n3 = false; //N3;
			n4 = false; //N4;
			n5 = false; //N5;
			n6 = false; //N6;
			n7 = false; //N7;
			n8 = false; //N8;
	
			n0P = false; //N0_P;
			n1P = false; //N1_P;
			n2P = false; //N2_P;
			n3P = false; //N3_P;
			n4P = false; //N4_P;
			n5P = false; //N5_P;
			n6P = false; //N6_P;
			n7P = false; //N7_P;
			n8P = false; //N8_P;
	
			n0R = false; //N0_R;
			n1R = false; //N1_R;
			n2R = false; //N2_R;
			n3R = false; //N3_R;
			n4R = false; //N4_R;
			n5R = false; //N5_R;
			n6R = false; //N6_R;
			n7R = false; //N7_R;
			n8R = false; //N8_R;
		}
		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

		// FlxG.watch.addQuick('asdfa', upP);
		var ankey = (upP || rightP || downP || leftP);
		if (mania == 1)
		{ 
			ankey = (l1P || uP || r1P || l2P || dP || r2P);
			controlArray = [l1P, uP, r1P, l2P, dP, r2P];
		}
		else if (mania == 2)
		{
			ankey = (a0P || a1P || a2P || a3P || a4P || a5P || a6P);
			controlArray = [a0P, a1P, a2P, a3P, a4P, a5P, a6P];
		}
		else if (mania == 3)
		{
			ankey = (n0P || n1P || n2P || n3P || n4P || n5P || n6P || n7P || n8P);
			controlArray = [n0P, n1P, n2P, n3P, n4P, n5P, n6P, n7P, n8P];
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (ankey && !boyfriend.stunned && generatedMusic)
		{
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote && daNote.finishedGenerating)
				{
					possibleNotes.push(daNote);
				}
			});

			possibleNotes.sort((a, b) -> Std.int(a.noteData - b.noteData)); //sorting twice is necessary as far as i know
			haxe.ds.ArraySort.sort(possibleNotes, function(a, b):Int {
				var notetypecompare:Int = Std.int(a.noteData - b.noteData);

				if (notetypecompare == 0)
				{
					return Std.int(a.strumTime - b.strumTime);
				}
				return notetypecompare;
			});

			var canMiss:Bool = true;

			if (possibleNotes.length > 0)
			{
				var daNote = possibleNotes[0];

				if (perfectMode)
					noteCheck(true, daNote);

				// Jump notes
				var lasthitnote:Int = -1;
				var lasthitnotetime:Float = -1;

				for (note in possibleNotes) 
				{
					if (controlArray[note.noteData % Main.keyAmmo[mania]])
					{
						if (lasthitnotetime > Conductor.songPosition - Conductor.safeZoneOffset
							&& lasthitnotetime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.2)) //reduce the past allowed barrier just so notes close together that aren't jacks dont cause missed inputs
						{
							if ((note.noteData % Main.keyAmmo[mania]) == (lasthitnote % Main.keyAmmo[mania]))
							{
								continue; //the jacks are too close together
							}
						}
						lasthitnote = note.noteData;
						lasthitnotetime = note.strumTime;
						goodNoteHit(note);
						canMiss = false;
					}
				}
			}
			if (!theFunne && canMiss)
			{
				if (a3P && !addspacestatic) return;
				badNoteCheck(null);
			}
		}

		var condition = up || right || down || left;
		if (mania == 1)
		{
			condition = l1 || u || r1 || l2 || d || r2;
		}
		else if (mania == 2)
		{
			condition = a0 || a1 || a2 || a3 || a4 || a5 || a6;
		}
		else if (mania == 3)
		{
			condition = n0 || n1 || n2 || n3 || n4 || n5 || n6 || n7 || n8;
		}
		if (condition && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
				{
					if (mania == 0)
					{
						switch (daNote.noteData)
						{
							// NOTES YOU ARE HOLDING
							case 2:
								if (up || upHold)
									goodNoteHit(daNote);
							case 3:
								if (right || rightHold)
									goodNoteHit(daNote);
							case 1:
								if (down || downHold)
									goodNoteHit(daNote);
							case 0:
								if (left || leftHold)
									goodNoteHit(daNote);
						}
					}
					else if (mania == 1)
					{
						switch (daNote.noteData)
						{
							// NOTES YOU ARE HOLDING
							case 0:
								if (l1 || l1Hold)
									goodNoteHit(daNote);
							case 1:
								if (u || uHold)
									goodNoteHit(daNote);
							case 2:
								if (r1 || r1Hold)
									goodNoteHit(daNote);
							case 3:
								if (l2 || l2Hold)
									goodNoteHit(daNote);
							case 4:
								if (d || dHold)
									goodNoteHit(daNote);
							case 5:
								if (r2 || r2Hold)
									goodNoteHit(daNote);
						}
					}
					else if (mania == 2)
					{
						switch (daNote.noteData)
						{
							// NOTES YOU ARE HOLDING
							case 0: if (a0 || a0Hold) goodNoteHit(daNote);
							case 1: if (a1 || a1Hold) goodNoteHit(daNote);
							case 2: if (a2 || a2Hold) goodNoteHit(daNote);
							case 3: if (a3 || a3Hold) goodNoteHit(daNote);
							case 4: if (a4 || a4Hold) goodNoteHit(daNote);
							case 5: if (a5 || a5Hold) goodNoteHit(daNote);
							case 6: if (a6 || a6Hold) goodNoteHit(daNote);
						}
					}
					else
					{
						switch (daNote.noteData)
						{
							// NOTES YOU ARE HOLDING
							case 0: if (n0 || n0Hold) goodNoteHit(daNote);
							case 1: if (n1 || n1Hold) goodNoteHit(daNote);
							case 2: if (n2 || n2Hold) goodNoteHit(daNote);
							case 3: if (n3 || n3Hold) goodNoteHit(daNote);
							case 4: if (n4 || n4Hold) goodNoteHit(daNote);
							case 5: if (n5 || n5Hold) goodNoteHit(daNote);
							case 6: if (n6 || n6Hold) goodNoteHit(daNote);
							case 7: if (n7 || n7Hold) goodNoteHit(daNote);
							case 8: if (n8 || n8Hold) goodNoteHit(daNote);
						}
					}
				}
			});
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !condition)
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
			}
		}

		playerStrums.forEach(function(spr:Strum)
		{
			if (mania == 0)
			{
				switch (spr.ID)
				{
					case 2:
						if (upP && spr.animation.curAnim.name != 'confirm')
						{
							spr.playAnim('pressed');
							trace('play');
						}
						if (upR)
						{
							spr.playAnim('static');
						}
					case 3:
						if (rightP && spr.animation.curAnim.name != 'confirm')
						{
							spr.playAnim('pressed');
						}
						if (rightR)
						{
							spr.playAnim('static');
						}
					case 1:
						if (downP && spr.animation.curAnim.name != 'confirm')
						{
							spr.playAnim('pressed');
						}
						if (downR)
						{
							spr.playAnim('static');
						}
					case 0:
						if (leftP && spr.animation.curAnim.name != 'confirm')
						{
							spr.playAnim('pressed');
						}
						if (leftR)
						{
							spr.playAnim('static');
						}
				}
			}
			else if (mania == 1)
			{
				switch (spr.ID)
				{
					case 0:
						if (l1P && spr.animation.curAnim.name != 'confirm')
						{
							spr.playAnim('pressed');
							trace('play');
						}
						if (l1R)
						{
							spr.playAnim('static');
						}
					case 1:
						if (uP && spr.animation.curAnim.name != 'confirm')
						{
							spr.playAnim('pressed');
						}
						if (uR)
						{
							spr.playAnim('static');
						}
					case 2:
						if (r1P && spr.animation.curAnim.name != 'confirm')
						{
							spr.playAnim('pressed');
						}
						if (r1R)
						{
							spr.playAnim('static');
						}
					case 3:
						if (l2P && spr.animation.curAnim.name != 'confirm')
						{
							spr.playAnim('pressed');
						}
						if (l2R)
						{
							spr.playAnim('static');
						}
					case 4:
						if (dP && spr.animation.curAnim.name != 'confirm')
						{
							spr.playAnim('pressed');
						}
						if (dR)
						{
							spr.playAnim('static');
						}
					case 5:
						if (r2P && spr.animation.curAnim.name != 'confirm')
						{
							spr.playAnim('pressed');
						}
						if (r2R)
						{
							spr.playAnim('static');
						}
				}
			}
			else if (mania == 2)
			{
				switch (spr.ID)
				{
					case 0:
						if (a0P && spr.animation.curAnim.name != 'confirm')
						{
							spr.playAnim('pressed');
						}
						if (a0R) spr.playAnim('static');
					case 1:
						if (a1P && spr.animation.curAnim.name != 'confirm')
						{
							spr.playAnim('pressed');
						}
						if (a1R) spr.playAnim('static');
					case 2:
						if (a2P && spr.animation.curAnim.name != 'confirm')
						{
							spr.playAnim('pressed');
						}
						if (a2R) spr.playAnim('static');
					case 3:
						if (a3P && spr.animation.curAnim.name != 'confirm')
						{
							spr.playAnim('pressed');
						}
						if (a3R) spr.playAnim('static');
					case 4:
						if (a4P && spr.animation.curAnim.name != 'confirm')
						{
							spr.playAnim('pressed');
						}
						if (a4R) spr.playAnim('static');
					case 5:
						if (a5P && spr.animation.curAnim.name != 'confirm')
						{
							spr.playAnim('pressed');
						}
						if (a5R) spr.playAnim('static');
					case 6:
						if (a6P && spr.animation.curAnim.name != 'confirm')
						{
							spr.playAnim('pressed');
						}
						if (a6R) spr.playAnim('static');
				}
			}
			else if (mania == 3)
			{
				switch (spr.ID)
				{
					case 0:
						if (n0P && spr.animation.curAnim.name != 'confirm')
						{
							spr.playAnim('pressed');
						}
						if (n0R) spr.playAnim('static');
					case 1:
						if (n1P && spr.animation.curAnim.name != 'confirm')
						{
							spr.playAnim('pressed');
						}
						if (n1R) spr.playAnim('static');
					case 2:
						if (n2P && spr.animation.curAnim.name != 'confirm')
						{
							spr.playAnim('pressed');
						}
						if (n2R) spr.playAnim('static');
					case 3:
						if (n3P && spr.animation.curAnim.name != 'confirm')
						{
							spr.playAnim('pressed');
						}
						if (n3R) spr.playAnim('static');
					case 4:
						if (n4P && spr.animation.curAnim.name != 'confirm')
						{
							spr.playAnim('pressed');
						}
						if (n4R) spr.playAnim('static');
					case 5:
						if (n5P && spr.animation.curAnim.name != 'confirm')
						{
							spr.playAnim('pressed');
						}
						if (n5R) spr.playAnim('static');
					case 6:
						if (n6P && spr.animation.curAnim.name != 'confirm')
						{
							spr.playAnim('pressed');
						}
						if (n6R) spr.playAnim('static');
					case 7:
						if (n7P && spr.animation.curAnim.name != 'confirm')
						{
							spr.playAnim('pressed');
						}
						if (n7R) spr.playAnim('static');
					case 8:
						if (n8P && spr.animation.curAnim.name != 'confirm')
						{
							spr.playAnim('pressed');
						}
						if (n8R) spr.playAnim('static');
				}
			}

			/* if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school') && (SONG.song.toLowerCase() != 'disability'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else if (SONG.song.toLowerCase() != 'disability')
				spr.centerOffsets();
			else
				spr.smartCenterOffsets(); */
		});
	}

	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			health -= 0.04;
			//trace("note miss");
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;
			misses++;

			songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');
			if (boyfriend.animation.getByName("singLEFTmiss") != null)
			{
				//'LEFT', 'DOWN', 'UP', 'RIGHT'
				var fuckingDumbassBullshitFuckYou:String;
				fuckingDumbassBullshitFuckYou = notestuffs[Math.round(Math.abs(direction)) % Main.keyAmmo[mania]];
				if(!boyfriend.nativelyPlayable)
				{
					switch(notestuffs[Math.round(Math.abs(direction)) % Main.keyAmmo[mania]])
					{
						case 'LEFT':
							fuckingDumbassBullshitFuckYou = 'RIGHT';
						case 'RIGHT':
							fuckingDumbassBullshitFuckYou = 'LEFT';
					}
				}
				boyfriend.playAnim('sing' + fuckingDumbassBullshitFuckYou + "miss", true);
			}
			else
			{
				boyfriend.color = 0xFF000084;
				//'LEFT', 'DOWN', 'UP', 'RIGHT'
				var fuckingDumbassBullshitFuckYou:String;
				fuckingDumbassBullshitFuckYou = notestuffs[Math.round(Math.abs(direction)) % Main.keyAmmo[mania]];
				if(!boyfriend.nativelyPlayable)
				{
					switch(notestuffs[Math.round(Math.abs(direction)) % Main.keyAmmo[mania]])
					{
						case 'LEFT':
							fuckingDumbassBullshitFuckYou = 'RIGHT';
						case 'RIGHT':
							fuckingDumbassBullshitFuckYou = 'LEFT';
					}
				}
				boyfriend.playAnim('sing' + fuckingDumbassBullshitFuckYou, true);
			}

			updateAccuracy();
		}
	}

	function badNoteCheck(note:Note = null)
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		if (note != null)
		{
			if(note.mustPress && note.finishedGenerating)
			{
				noteMiss(note.noteData);
			}
			return;
		}
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var l1P = controls.L1_P;
		var uP = controls.U1_P;
		var r1P = controls.R1_P;
		var l2P = controls.L2_P;
		var dP = controls.D1_P;
		var r2P = controls.R2_P;

		var a0P = controls.A0_P;
		var a1P = controls.A1_P;
		var a2P = controls.A2_P;
		var a3P = controls.A3_P;
		var a4P = controls.A4_P;
		var a5P = controls.A5_P;
		var a6P = controls.A6_P;

		var n0P = controls.N0_P;
		var n1P = controls.N1_P;
		var n2P = controls.N2_P;
		var n3P = controls.N3_P;
		var n4P = controls.N4_P;
		var n5P = controls.N5_P;
		var n6P = controls.N6_P;
		var n7P = controls.N7_P;
		var n8P = controls.N8_P;
		
		if (mania == 0)
		{
			if (leftP)
				noteMiss(0);
			if (upP)
				noteMiss(2);
			if (rightP)
				noteMiss(3);
			if (downP)
				noteMiss(1);
		}
		else if (mania == 1)
		{
			if (l1P)
				noteMiss(0);
			else if (uP)
				noteMiss(1);
			else if (r1P)
				noteMiss(2);
			else if (l2P)
				noteMiss(3);
			else if (dP)
				noteMiss(4);
			else if (r2P)
				noteMiss(5);
		}
		else if (mania == 2)
		{
			if (a0P) noteMiss(0);
			if (a1P) noteMiss(1);
			if (a2P) noteMiss(2);
			if (a3P) noteMiss(3);
			if (a4P) noteMiss(4);
			if (a5P) noteMiss(5);
			if (a6P) noteMiss(6);
		}
		else
		{
			if (n0P) noteMiss(0);
			if (n1P) noteMiss(1);
			if (n2P) noteMiss(2);
			if (n3P) noteMiss(3);
			if (n4P) noteMiss(4);
			if (n5P) noteMiss(5);
			if (n6P) noteMiss(6);
			if (n7P) noteMiss(7);
			if (n8P) noteMiss(8);
		}
		updateAccuracy();
	}

	function updateAccuracy()
	{
		if (misses > 0 || accuracy < 96)
			fc = false;
		else
			fc = true;
		totalPlayed += 1;
		accuracy = totalNotesHit / totalPlayed * 100;
	}

	function noteCheck(keyP:Bool, note:Note):Void // sorry lol
	{
		if (keyP)
		{
			goodNoteHit(note);
		}
		else if (!theFunne)
		{
			badNoteCheck(note);
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				combo += 1;
				popUpScore(note.strumTime, note.noteData);
				if (FlxG.save.data.donoteclick)
				{
					FlxG.sound.play(Paths.sound('note_click'));
				}
				updateAccuracy();
			}

			if (!note.isSustainNote)
				health += 0.023;
			else
				health += 0.004;

			if (darkLevels.contains(curStage) && SONG.song.toLowerCase() != "polygonized")
			{
				boyfriend.color = nightColor;
			}
			else if(sunsetLevels.contains(curStage))
			{
				boyfriend.color = sunsetColor;
			}
			else
			{
				boyfriend.color = FlxColor.WHITE;
			}

			//'LEFT', 'DOWN', 'UP', 'RIGHT'
			var fuckingDumbassBullshitFuckYou:String;
			fuckingDumbassBullshitFuckYou = notestuffs[Math.round(Math.abs(note.noteData)) % Main.keyAmmo[mania]];
			if(!boyfriend.nativelyPlayable)
			{
				switch(notestuffs[Math.round(Math.abs(note.noteData)) % Main.keyAmmo[mania]])
				{
					case 'LEFT':
						fuckingDumbassBullshitFuckYou = 'RIGHT';
					case 'RIGHT':
						fuckingDumbassBullshitFuckYou = 'LEFT';
				}
			}
			if(shakingChars.contains(dad.curCharacter))
			{
				FlxG.camera.shake(0.0075, 0.1);
				camHUD.shake(0.0045, 0.1);
			}
			boyfriend.playAnim('sing' + fuckingDumbassBullshitFuckYou, true);
			if (UsingNewCam)
			{
				focusOnDadGlobal = false;
				if(camMoveAllowed)
					ZoomCam(false);
			}

			if(botPlay) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % Main.keyAmmo[mania], time);
			} else {
				playerStrums.forEach(function(spr:Strum)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.playAnim('confirm', true);
					}
				});
			}

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (!note.isSustainNote || (note.isSustainNote && unfairPart))
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}

			if(botPlay) {
				boyfriend.holdTimer = 0;
				var targetHold:Float = Conductor.stepCrochet * 0.001 * 4;
				if(boyfriend.holdTimer + 0.2 > targetHold) {
					boyfriend.holdTimer = targetHold - 0.2;
				}
			}
		}
	}

	override function stepHit()
	{
		super.stepHit();

		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}

		#if desktop
		DiscordClient.changePresence(SONG.song,
			botText + "Acc: "
			+ truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC, true,
			FlxG.sound.music.length
			- Conductor.songPosition);
		#end
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var cool:Int = 0;

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:Strum = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}
		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if(curBeat % camBeatSnap == 0)
		{
			if(timeTxtTween != null) 
			{
				timeTxtTween.cancel();
			}

			timeTxt.scale.x = 1.075;
			timeTxt.scale.y = 1.075;
			timeTxtTween = FlxTween.tween(timeTxt.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
					timeTxtTween = null;
				}
			});
		}

		if (!UsingNewCam)
		{
			if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
			{
				if (curBeat % 4 == 0)
				{
					// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
				}

				if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
				{
					focusOnDadGlobal = true;
					if(camMoveAllowed)
						ZoomCam(true);
				}

				if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
				{
					focusOnDadGlobal = false;
					if(camMoveAllowed)
						ZoomCam(false);
				}
			}
		}
		if(curBeat % danceBeatSnap == 0 && daveFuckingDies != null)
		{
			daveFuckingDies.dance();
		}
		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);
		}
		/*
		if (dad.curCharacter == 'bandu')  {
			krunkity = dadmirror.animation.finished && dad.animation.finished;
		}*/
		if (dad.animation.finished)
		{
			switch (SONG.song.toLowerCase())
			{
				case 'tutorial':
					dad.dance(idleAlt);
					dadmirror.dance(idleAlt);
				case 'disruption':
					if (curBeat % gfSpeed == 0 && dad.holdTimer <= 0) {
						dad.dance(idleAlt);
						dadmirror.dance(idleAlt);
					}
				case 'applecore':
					if (dad.holdTimer <= 0 && curBeat % dadDanceSnap == 0)
						!wtfThing ? dad.dance(dad.POOP) : dad.playAnim('idle-alt', true); // i hate everything
					if (dadmirror.holdTimer <= 0 && curBeat % dadDanceSnap == 0)
						!wtfThing ? dadmirror.dance(dad.POOP) : dadmirror.playAnim('idle-alt', true); // sutpid
				default:
					if (dad.holdTimer <= 0 && curBeat % dadDanceSnap == 0)
						dad.dance(idleAlt);
					if (dadmirror.holdTimer <= 0 && curBeat % dadDanceSnap == 0)
						dadmirror.dance(idleAlt);
			}
		}
		if(badai != null)
		{
			if ((badai.animation.finished || badai.animation.curAnim.name == 'idle') && badai.holdTimer <= 0 && curBeat % dadDanceSnap == 0)
				badai.dance(idleAlt);
		}
		if (swagger != null) {
			if (swagger.holdTimer <= 0 && curBeat % 1 == 0 && swagger.animation.finished)
				swagger.dance();
		}
		if (littleIdiot != null) {
			if (littleIdiot.animation.finished && littleIdiot.holdTimer <= 0 && curBeat % dadDanceSnap == 0) littleIdiot.dance();
		}

		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		if (camZooming && FlxG.camera.zoom < (1.35 * camZoomIntensity) && curBeat % camBeatSnap == 0)
		{
			FlxG.camera.zoom += (0.015 * camZoomIntensity);
			camHUD.zoom += (0.03 * camZoomIntensity);
		}
		switch (curSong.toLowerCase())
		{
			case 'disruption':
				switch(curBeat)
				{
					case 288 | 416:
						if (storyDifficulty != 0) bambiSpeak = !bambiSpeak;
				}
			case 'algebra':
				switch(curBeat)
				{
					case 288 | 452 | 464 | 1352 | 1566 | 1694:
						gfSpeed = 2;
					case 460 | 1452 | 1598 | 1868:
						gfSpeed = 1;
					//STANDER POSITIONING IS INCOMPLETE, FIX LATER
					case 160:
						if (FlxG.save.data.modchart)
							swagSpeed = SONG.speed - 0.5;
						if (storyDifficulty == 1 && mania == 2)
							addspacestatic = true;
						//GARRETT TURN 1!!
						swapDad('garrett');
						algebraStander('og-dave', daveStand, 250, 100);
						daveJunk.visible = true;
						if(iconP2.animation.getByName(dad.curCharacter) != null)
							iconP2.animation.play(dad.curCharacter);
					case 416: // 
						gfSpeed = 1;
						//HAPPY DAVE TURN 2!!
						swapDad('og-dave');
						daveJunk.visible = false;
						garrettJunk.visible = true;
						if (FlxG.save.data.modchart)
							swagSpeed = SONG.speed - 0.3;
						if (storyDifficulty == 1 && mania == 2)
							addspacestatic = false;
						for(member in standersGroup.members)
						{
							member.destroy();
						}
						algebraStander('garrett', garrettStand, 500, 225);
						if(iconP2.animation.getByName(dad.curCharacter) != null)
							iconP2.animation.play(dad.curCharacter);
					case 536:
						//GARRETT TURN 2
						swapDad('garrett');
						davePiss.visible = true;
						garrettJunk.visible = false;
						if (storyDifficulty == 1 && mania == 2)
							addspacestatic = true;
						for(member in standersGroup.members)
						{
							member.destroy();
						}
						algebraStander('og-dave-angey', daveStand, 250, 100);
						if(iconP2.animation.getByName(dad.curCharacter) != null)
							iconP2.animation.play(dad.curCharacter);
					case 552:
						//ANGEY DAVE TURN 1!!
						swapDad('og-dave-angey');
						davePiss.visible = false;
						garrettJunk.visible = true;
						for(member in standersGroup.members)
						{
							member.destroy();
						}
						algebraStander('garrett', garrettStand, 500, 225, true);
						if(iconP2.animation.getByName(dad.curCharacter) != null)
							iconP2.animation.play(dad.curCharacter);
					case 696:
						//HALL MONITOR TURN
						//UNCOMMENT THIS WHEN HALL MONITOR SPRITES ARE DONE AND IN
						swapDad('hall-monitor');
						davePiss.visible = true;
						diamondJunk.visible = true;
						if (storyDifficulty == 1 && mania == 2)
							addspacestatic = false;
						if (FlxG.save.data.modchart)
							swagSpeed = 2;
						for(member in standersGroup.members)
						{
							member.destroy();
						}
						algebraStander('garrett', garrettStand, 500, 225, true);
						algebraStander('og-dave-angey', daveStand, 250, 100);
						if(iconP2.animation.getByName(dad.curCharacter) != null)
							iconP2.animation.play(dad.curCharacter);
					case 1344:
						gfSpeed = 4;
						//DIAMOND MAN TURN
						swapDad('diamond-man');
						monitorJunk.visible = true;
						diamondJunk.visible = false;
						if (storyDifficulty == 1 && mania == 2)
							addspacestatic = true;
						if (FlxG.save.data.modchart)
							swagSpeed = SONG.speed;
						for(member in standersGroup.members)
						{
							member.destroy();
						}
						algebraStander('garrett', garrettStand, 500, 225, true);
						//UNCOMMENT THIS WHEN HALL MONITOR SPRITES ARE DONE AND IN
						algebraStander('hall-monitor', hallMonitorStand, 0, 100);
						algebraStander('og-dave-angey', daveStand, 250, 100);
						if(iconP2.animation.getByName(dad.curCharacter) != null)
							iconP2.animation.play(dad.curCharacter);
					case 1696:
						//PLAYROBOT TURN
						swapDad('playrobot');
						if (FlxG.save.data.modchart)
							swagSpeed = 1.6;
						if (storyDifficulty == 1 && mania == 2)
							addspacestatic = false;
						if(iconP2.animation.getByName(dad.curCharacter) != null)
							iconP2.animation.play(dad.curCharacter);
					case 1852:
						gfSpeed = 4;
						FlxTween.tween(davePiss, {x: davePiss.x - 250}, 0.5, {ease:FlxEase.quadOut});
						davePiss.animation.play('d');
					case 1856:
						gfSpeed = 2;
						//SCARY PLAYROBOT TURN
						swapDad('playrobot-crazy');
						swagSpeed = SONG.speed;
						if (storyDifficulty == 1 && mania == 2)
							addspacestatic = true;
						if(iconP2.animation.getByName(dad.curCharacter) != null)
							iconP2.animation.play(dad.curCharacter);
					case 1996:
						//ANGEY DAVE TURN 2!!
						swapDad('og-dave-angey');
						robotJunk.visible = true;
						davePiss.visible = false;
						for(member in standersGroup.members)
						{
							member.destroy();
						}
						algebraStander('playrobot-scary', playRobotStand, 750, 100, false, true);
						algebraStander('garrett', garrettStand, 500, 225, true);
						//UNCOMMENT THIS WHEN HALL MONITOR SPRITES ARE DONE AND IN
						algebraStander('hall-monitor', hallMonitorStand, 0, 100);
						if(iconP2.animation.getByName(dad.curCharacter) != null)
							iconP2.animation.play(dad.curCharacter);
					case 2140:
						if (FlxG.save.data.modchart)
							swagSpeed = SONG.speed + 0.9;
					
				}
			case 'sugar-rush':
				switch(curBeat)
				{
					case 32 | 76 | 334:
						camBeatSnap = 1;
					case 29 | 72 | 268:
						camBeatSnap = 2;
					case 64 | 140 | 300 | 400:
						camBeatSnap = 4;
					case 172:
						FlxTween.tween(thunderBlack, {alpha: 0.35}, Conductor.stepCrochet / 500);
					case 204:
						FlxTween.tween(thunderBlack, {alpha: 0}, Conductor.stepCrochet / 500);
						camBeatSnap = 1;
				}
			case 'thunderstorm':
				switch(curBeat)
				{
					case 272 | 304:
						FlxTween.tween(thunderBlack, {alpha: 0.35}, Conductor.stepCrochet / 500);
					case 300 | 332:
						FlxTween.tween(thunderBlack, {alpha: 0}, Conductor.stepCrochet / 500);
				}
			case 'applecore':
				switch(curBeat) {
					case 160 | 436 | 684:
						gfSpeed = 2;
					case 240:
						gfSpeed = 1;
					case 223:
						wtfThing = true;
						what.forEach(function(spr:FlxSprite){
							spr.frames = Paths.getSparrowAtlas('bambi/minion');
							spr.animation.addByPrefix('hi', 'poip', 12, true);
							spr.animation.play('hi');
						});
						creditsWatermark.text = 'Screw you!';
						kadeEngineWatermark.y -= 20;
						kadeEngineWatermark2.y -= 20;
						camHUD.flash(FlxColor.WHITE, 1);
						
						iconRPC = 'icon_the_two_dunkers';
						if (FlxG.save.data.newspritetest) {
						iconP2.loadGraphic(Paths.image('icons/the-two-dunkers', 'preload'), true, 150, 150);
						}
					        else {
						iconP2.loadGraphic(Paths.image('icons/junkers', 'preload'), true, 150, 150);
						}
						dad.playAnim('NOOMYPHONES', true);
						dadmirror.playAnim('NOOMYPHONES', true);
						dad.POOP = true; // WORK WORK WOKR< WOKRMKIEPATNOLIKSEHGO:"IKSJRHDLG"H
						dadmirror.POOP = true; // :))))))))))
						poopStrums.visible = true; // ??????
						new FlxTimer().start(3.5, function(deez:FlxTimer){
							swagThings.forEach(function(spr:Strum){
								FlxTween.tween(spr, {y: spr.y + 1010}, 1.2, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * spr.ID)});
							});	
							poopStrums.forEach(function(spr:Strum){
								FlxTween.tween(spr, {alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * spr.ID)});
							});
							FlxTween.tween(swagger, {y: swagger.y + 1000}, 1.05, {ease:FlxEase.cubeInOut});
						});
						unswagBG.active = unswagBG.visible = true;
						curbg =  unswagBG;
						swagBG.visible = swagBG.active = false;
					case 636:
						unfairPart = true;
						gfSpeed = 1;
						playerStrums.forEach(function(spr:Strum){
							spr.scale.set(Note.scales[mania], Note.scales[mania]);
						});
						dadStrums.forEach(function(spr:Strum){
							spr.scale.set(Note.scales[mania], Note.scales[mania]);
						});
						what.forEach(function(spr:FlxSprite){
							spr.alpha = 0;
						});
						gfSpeed = 1;
						wtfThing = false;
						var dumbStupid = new FlxSprite().loadGraphic(Paths.image('bambi/poop'));
						dumbStupid.scrollFactor.set();
						dumbStupid.screenCenter();
						littleIdiot.alpha = 0;
						littleIdiot.visible = true;
						add(dumbStupid);
						dumbStupid.cameras = [camHUD];
						dumbStupid.color = FlxColor.BLACK;
						health = 2;
						if (FlxG.save.data.modchart) {
							theFunne = false;
							creditsWatermark.text = "Ghost tapping is forced off! Screw you!";
						}
						else creditsWatermark.text = "You wanted normal gameplay!? Screw you!";
						poopStrums.visible = false;
						FlxTween.tween(dumbStupid, {alpha: 1}, 0.2, {onComplete: function(twn:FlxTween){
							scaryBG.active = true;
							curbg = scaryBG;
							unswagBG.visible = unswagBG.active = false;
							FlxTween.tween(dumbStupid, {alpha: 0}, 1.2, {onComplete: function(twn:FlxTween){
								trace('hi'); // i actually forgot what i was going to put here
							}});
						}});
					case 231:
						vocals.volume = 1;
					case 659:
						FlxTween.tween(littleIdiot, {alpha: 1}, 1.4, {ease: FlxEase.circOut});
					case 667:
						FlxTween.tween(littleIdiot, {"scale.x": littleIdiot.scale.x + 2.1, "scale.y": littleIdiot.scale.y + 2.1}, 1.35, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween){
							iconP2.animation.play('bambi-unfair');
							orbit = false;
							dad.visible = dadmirror.visible = swagger.visible = false;
							var derez = new FlxSprite(dad.getMidpoint().x, dad.getMidpoint().y).loadGraphic(Paths.image('bambi/monkey_guy'));
							derez.setPosition(derez.x - derez.width / 2, derez.y - derez.height / 2);
							derez.antialiasing = false;
							add(derez);
							var deez = new FlxSprite(swagger.getMidpoint().x, swagger.getMidpoint().y).loadGraphic(Paths.image('bambi/monkey_person'));
							deez.setPosition(deez.x - deez.width / 2, deez.y - deez.height / 2);
							deez.antialiasing = false;
							add(deez);
							var swagsnd = new FlxSound().loadEmbedded(Paths.sound('suck'));
							swagsnd.play(true);
							var whatthejunk = new FlxSound().loadEmbedded(Paths.sound('suckEnd'));
							littleIdiot.playAnim('inhale');
							littleIdiot.animation.finishCallback = function(d:String) {
								swagsnd.stop();
								whatthejunk.play(true);
								littleIdiot.animation.finishCallback = null;
							};
							new FlxTimer().start(0.2, function(tmr:FlxTimer){
								FlxTween.tween(deez, {"scale.x": 0.1, "scale.y": 0.1, x: littleIdiot.getMidpoint().x - deez.width / 2, y: littleIdiot.getMidpoint().y - deez.width / 2 - 400}, 0.65, {ease: FlxEase.quadIn});
								FlxTween.angle(deez, 0, 360, 0.65, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween) deez.kill()});

								FlxTween.tween(derez, {"scale.x": 0.1, "scale.y": 0.1, x: littleIdiot.getMidpoint().x - derez.width / 2 - 100, y: littleIdiot.getMidpoint().y - derez.width / 2 - 500}, 0.65, {ease: FlxEase.quadIn});
								FlxTween.angle(derez, 0, 360, 0.65, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween) derez.kill()});

								new FlxTimer().start(1, function(tmr:FlxTimer){ poipInMahPahntsIsGud = true; iconRPC = 'icon_unfair_junker';});
							});
						}});
				}
			case 'recovered-project':
				switch (curBeat) {
					case 256:
						swapDad('RECOVERED_PROJECT_2');
					case 480:
						thunderBlack.alpha = 1;
						swapDad("RECOVERED_PROJECT_3");
					case 484:
						FlxTween.tween(thunderBlack, {alpha: 0}, 1);
				}
			case 'wireframe':
				FlxG.camera.shake(0.005, Conductor.crochet / 1000);
				switch(curBeat)
				{
					case 254:
						badai.visible = true;
						new FlxTimer().start((Conductor.crochet / 1000) * 0.5, function(tmr:FlxTimer){
							FlxTween.tween(badai, {x: -300, y: 100}, (Conductor.crochet / 1000) * 1.5, {ease: FlxEase.cubeIn});
						});
						//FlxTween.tween(dad, {x: 1500, y: 1500}, Conductor.crochet / 1000, {ease: FlxEase.cubeIn});
					case 256:
						creditsWatermark.text = 'Screw you!';
						kadeEngineWatermark.y -= 20;
						kadeEngineWatermark2.y -= 20;
						dad.visible = false;
						var baldiBasic:FlxSprite = new FlxSprite(dad.x, dad.y);
						baldiBasic.frames = daveFuckingDies.frames;
						baldiBasic.animation.addByPrefix('HI', 'IDLE', 24, false);
						baldiBasic.animation.play("HI");
						baldiBasic.x = dad.getMidpoint().x - baldiBasic.width / 2;
						baldiBasic.y = dad.getMidpoint().y - baldiBasic.height / 2;
						add(baldiBasic);
						FlxTween.tween(baldiBasic, {x: baldiBasic.x + 100, y: baldiBasic.y + 500}, 0.15, {ease:FlxEase.cubeOut, onComplete: function(twn:FlxTween){
							baldiBasic.kill();
							remove(baldiBasic);
							baldiBasic.destroy();
						}});
						//this transition was lazy and dumb lets do it better
						FlxG.camera.flash(FlxColor.WHITE, 1);/*
						remove(dad);
						//badai time
						dad = new Character(-300, 100, 'badai', false);
						add(dad);
						iconP2.animation.play('badai', true);
						daveFuckingDies.visible = true;*/
						camMoveAllowed = false;
						badaiTime = true;
						//boyfriend.canDance = false;
						//boyfriend.playAnim('turn', true);
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							camMoveAllowed = true;
							var position = boyfriend.getPosition();
							var width = boyfriend.width;
							/*
							remove(boyfriend);
							boyfriend = new Boyfriend(position.x, position.y, 'tunnel-bf-flipped');
							add(boyfriend);
							*/
							//boyfriendOldIcon = 'bf-old-flipped';
							//iconP1.animation.play('tunnel-bf-flipped');
							iconP2.animation.play('badai');
							iconRPC = 'icon_badai';
							daveFuckingDies.visible = true;
							FlxTween.tween(daveFuckingDies, {y: -300}, 2.5, {ease: FlxEase.cubeInOut});
							new FlxTimer().start(2.5, function(tmr:FlxTimer)
							{
								daveFuckingDies.inCutscene = false;
							});
						});
				}
			case 'disability':
				if (storyDifficulty != 2) {
					switch(curBeat) {
						case 176 | 224 | 364 | 384:
							gfSpeed = 2;
						case 208 | 256 | 372 | 392:
							gfSpeed = 1;
					}
				}
			case 'ugh':
				switch(curBeat) {
					case 15 | 111 | 131 | 135 | 207:
						dad.playAnim('singFUCK', true);
				}
		}

		if (shakeCam)
		{
			gf.playAnim('scared', true);
		}

		//health icon bounce but epic
		if (curBeat % gfSpeed == 0) {
			curBeat % (gfSpeed * 2) == 0 ? {
				iconP1.scale.set(1.1, 0.8);
				iconP2.scale.set(1.1, 1.3);

				FlxTween.angle(iconP1, -15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
				FlxTween.angle(iconP2, 15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
			} : {
				iconP1.scale.set(1.1, 1.3);
				iconP2.scale.set(1.1, 0.8);

				FlxTween.angle(iconP2, -15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
				FlxTween.angle(iconP1, 15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
			}

			FlxTween.tween(iconP1, {'scale.x': 1, 'scale.y': 1}, Conductor.crochet / 1250 * gfSpeed, {ease: FlxEase.quadOut});
			FlxTween.tween(iconP2, {'scale.x': 1, 'scale.y': 1}, Conductor.crochet / 1250 * gfSpeed, {ease: FlxEase.quadOut});

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}

		if(curBeat % danceBeatSnap == 0)
		{
			if(iconP1.charPublic == 'bandu-origin')
			{
				iconP1.animation.play(iconP1.charPublic, true);
			}
			if(iconP2.charPublic == 'bandu-origin')
			{
				iconP2.animation.play(iconP2.charPublic, true);
			}
		}

		if (curBeat % gfSpeed == 0)
		{
			if (!shakeCam)
			{
				gf.dance();
			}
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing") && boyfriend.canDance && curBeat % danceBeatSnap == 0)
		{
			boyfriend.dance();
			if (darkLevels.contains(curStage) && SONG.song.toLowerCase() != "polygonized")
			{
				boyfriend.color = nightColor;
			}
			else if(sunsetLevels.contains(curStage))
			{
				boyfriend.color = sunsetColor;
			}
			else
			{
				boyfriend.color = FlxColor.WHITE;
			}
		}

		if (curBeat % 8 == 7 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf') // fixed your stupid fucking code ninjamuffin this is literally the easiest shit to fix like come on seriously why are you so dumb
		{
			dad.playAnim('cheer', true);
			boyfriend.playAnim('hey', true);
		}
	}

	function eatShit(ass:String):Void
	{
		if (dialogue[0] == null)
		{
			trace(ass);
		}
		else
		{
			trace(dialogue[0]);
		}
	}

	function swapDad(char:String, x:Float = 100, y:Float = 100, flash:Bool = true)
	{
		if(dad != null)
			remove(dad);
			trace('remove dad');
		dad = new Character(x, y, char, false);
		trace('set dad');
		repositionDad();
		trace('repositioned dad');
		add(dad);
		trace('added dad');
		if(flash)
			FlxG.camera.flash(FlxColor.WHITE, 1, null, true);
			trace('flashed');
	}

	function repositionDad() {
		switch (dad.curCharacter)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					tweenCamIn();
				}
			case "tristan" | 'tristan-beta':
				dad.y += 325;
				dad.x += 100;
			case 'dave' | 'dave-annoyed' | 'dave-splitathon':
				{
					dad.y += 160;
					dad.x += 250;
				}
			case 'dave-old':
				{
					dad.y += 270;
					dad.x += 150;
				}
			case 'dave-angey' | 'dave-annoyed-3d' | 'dave-3d-standing-bruh-what':
				{
					dad.y += 0;
					dad.x += 150;
				}
			case 'bambi-3d' | 'bambi-piss-3d':
				{
					dad.y -= 250;
					dad.x -= 185;
				}
			case 'ringi':
				dad.y -= 475;
				dad.x -= 455;
			case 'bambom':
				dad.y -= 375;
				dad.x -= 500;
			case 'bendu':
				dad.y += 50;
				dad.x += 10;
			case 'bambi-unfair':
				{
					dad.y += 100;
				}
			case 'bambi' | 'bambi-old' | 'bambi-bevel' | 'what-lmao' | 'bambi-good':
				{
					dad.y += 400;
				}
			case 'bambi-new' | 'bambi-farmer-beta':
				{
					dad.y += 450;
					dad.x += 200;
				}
			case 'dave-wheels':
				dad.x += 100;
				dad.y += 300;
			case 'bambi-splitathon':
				{
					dad.x += 175;
					dad.y += 400;
				}
			case 'dave-png':
				dad.x += 81;
				dad.y += 108;
			case 'bambi-angey':
				dad.y += 450;
				dad.x += 100;
			case 'bandu-scaredy':
				dad.setPosition(-202, 20);
			case 'sart-producer-night':
				dad.setPosition(732, 83);
				dad.y -= 200;
			case 'RECOVERED_PROJECT':
				dad.setPosition(-307, 10);
			case 'RECOVERED_PROJECT_2' | 'RECOVERED_PROJECT_3':
				dad.setPosition(-607, -310);
			case 'sart-producer':
				dad.x -= 750;
				dad.y -= 360;
			case 'garrett':
				dad.y += 65;
			case 'diamond-man':
				dad.y += 25;
			case 'og-dave':
				dad.x -= 190;
			case 'og-dave-angey':
				dad.x -= 222;
				dad.y -= 64;
			case 'hall-monitor':
				dad.x += 45;
				dad.y += 185;
			case 'playrobot':
				dad.y += 265;
				dad.x += 150;
			case 'playrobot-crazy':
				dad.y += 365;
				dad.x += 165;
		}
	}
	
	function algebraStander(char:String, physChar:Character, x:Float = 100, y:Float = 100, startScared:Bool = false, idleAsStand:Bool = false)
	{
		return;
		if(physChar != null)
		{
			if(standersGroup.members.contains(physChar))
				standersGroup.remove(physChar);
				trace('remove physstander from group');
			remove(physChar);
			trace('remove physstander entirely');
		}
		physChar = new Character(x, y, char, false);
		trace('new physstander');
		standersGroup.add(physChar);
		trace('physstander in group');
		if(startScared)
		{
			physChar.playAnim('scared', true);
			trace('scaredy');
			new FlxTimer().start(Conductor.crochet / 1000, function(dick:FlxTimer){
				physChar.playAnim('stand', true);
				trace('standy');
			});
		}
		else
		{
			if(idleAsStand)
				physChar.playAnim('idle', true);
			else
				physChar.playAnim('stand', true);
			trace('standy');
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	function bgImg(Path:String) {
		return Paths.image('dave/bgJunkers/$Path');
	}

	public function preload(graphic:String) //preload assets
	{
		if (boyfriend != null)
		{
			boyfriend.stunned = true;
		}
		var newthing:FlxSprite = new FlxSprite(9000,-9000).loadGraphic(Paths.image(graphic));
		add(newthing);
		remove(newthing);
		if (boyfriend != null)
		{
			boyfriend.stunned = false;
		}
	}
}
