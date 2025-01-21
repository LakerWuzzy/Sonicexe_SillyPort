package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.events.Event;
import vlc.VlcBitmap;

// THIS IS FOR TESTING
// DONT STEAL MY CODE >:(
class MP4Handler
{
	public var finishCallback:Void->Void;
	public var stateCallback:FlxState;
	
	public var sprite:FlxSprite;

	public function new()
	{
		//FlxG.autoPause = false;
	}

	public function playMP4(path:String, ?repeat:Bool = false, ?outputTo:FlxSprite = null, ?isWindow:Bool = false, ?isFullscreen:Bool = false,
			?midSong:Bool = false):Void
	{
		if (!midSong)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.stop();
			}
		}

		VlcBitmap = new VlcBitmap();

		if (FlxG.stage.stageHeight / 9 < FlxG.stage.stageWidth / 16)
		{
			VlcBitmap.set_width(FlxG.stage.stageHeight * (16 / 9));
			VlcBitmap.set_height(FlxG.stage.stageHeight);
		}
		else
		{
			VlcBitmap.set_width(FlxG.stage.stageWidth);
			VlcBitmap.set_height(FlxG.stage.stageWidth / (16 / 9));
		}

		

		VlcBitmap.onVideoReady = onVLCVideoReady;
		VlcBitmap.onComplete = onVLCComplete;
		VlcBitmap.onError = onVLCError;

		FlxG.stage.addEventListener(Event.ENTER_FRAME, update);

		if (repeat)
			VlcBitmap.repeat = -1;
		else
			VlcBitmap.repeat = 0;

		VlcBitmap.inWindow = isWindow;
		VlcBitmap.fullscreen = isFullscreen;

		FlxG.addChildBelowMouse(VlcBitmap);
		VlcBitmap.play(checkFile(path));

		if (outputTo != null)
		{
			// lol this is bad kek
			VlcBitmap.alpha = 0;

			sprite = outputTo;
		}
	}

	function checkFile(fileName:String):String
	{
		var pDir = "";
		var appDir = "file:///" + Sys.getCwd() + "/";

		if (fileName.indexOf(":") == -1) // Not a path
			pDir = appDir;
		else if (fileName.indexOf("file://") == -1 || fileName.indexOf("http") == -1) // C:, D: etc? ..missing "file:///" ?
			pDir = "file:///";

		return pDir + fileName;
	}

	/////////////////////////////////////////////////////////////////////////////////////

	function onVLCVideoReady()
	{
		trace("video loaded!");

		if (sprite != null)
			sprite.loadGraphic(VlcBitmap.VlcBitmapData);
	}

	public function onVLCComplete()
	{
		VlcBitmap.stop();

		// Clean player, just in case! Actually no.

		FlxG.camera.fade(FlxColor.BLACK, 0, false);

		trace("Big, Big Chungus, Big Chungus!");

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			if (finishCallback != null)
			{
				finishCallback();
			}
			else if (stateCallback != null)
			{
				LoadingState.loadAndSwitchState(stateCallback);
			}

			VlcBitmap.dispose();

			if (FlxG.game.contains(VlcBitmap))
			{
				FlxG.game.removeChild(VlcBitmap);
			}
		});
	}

	public function kill()
	{
		VlcBitmap.stop();

		if (finishCallback != null)
		{
			finishCallback();
		}

		VlcBitmap.visible = false;
	}

	function onVLCError()
	{
		if (finishCallback != null)
		{
			finishCallback();
		}
		else if (stateCallback != null)
		{
			LoadingState.loadAndSwitchState(stateCallback);
		}
	}

	function update(e:Event)
	{
		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE)
		{
			if (VlcBitmap.isPlaying)
			{
				onVLCComplete();
			}
		}

		VlcBitmap.volume = FlxG.sound.volume + 0.3; // shitty volume fix. then make it louder.

		if (FlxG.sound.volume <= 0.1)
			VlcBitmap.volume = 0;
	}
}
