package;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;

class UnlockScreen extends MusicBeatState
{

    var image:FlxSprite;


    public function new(isUnlocked:Bool, whichUnlocked:String)
    {

        if (whichUnlocked == 'soundtest')
        {
            if (isUnlocked)
            {
                image = new FlxSprite().loadGraphic(Paths.image('unlockscreen/Special', 'exe'));
                FlxG.save.data.soundTestUnlocked = true;
            }
            else
                image = new FlxSprite().loadGraphic(Paths.image('unlockscreen/Harder', 'exe'));
        }
        super();
    }

    override function create()
    {
        image.alpha = 0;
        image.screenCenter();
        add(image);


        new FlxTimer().start(2, function(xd:FlxTimer)
        {
            FlxTween.tween(image, {alpha: 1}, 1);
        });

        super.create();
    }

    override function update(elapsed:Float)
    {
	    #if mobile
        var jusTouched:Bool = false;

        for (touch in FlxG.touches.list)
          if (touch.justPressed)
            jusTouched = true;
        #end
    
        if (controls.ACCEPT #if mobile || jusTouched #end)
        {
            LoadingState.loadAndSwitchState(new MainMenuState());
        }

        super.update(elapsed);
    }
}