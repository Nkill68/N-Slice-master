package objects;

import flixel.util.FlxTimer;

class ChartEditorCharacter extends FlxSprite
{

    private var curNote:Int = -1;

    public var state:ChartEditorCharacterState = Idling;

    public var isOpponent:Bool = false;
    
    public var resetAnim:Float = 0.0;

	private final ids = ["singLEFT","singDOWN","singUP","singRIGHT"];

    public function new(x:Float = 0, y:Float = 0, isOpp:Bool = false){
        super();
        frames = Paths.getSparrowAtlas('editors/chartEditorExt/EDIT');
        if(isOpp){
            animation.addByPrefix("singLEFT", "Left",12.0,false,false,false);
            animation.addByPrefix("singUP", "Up",12.0,false,false,false);
            animation.addByPrefix("singDOWN", "Down",12.0,false,false,false);
            animation.addByPrefix("singRIGHT", "Right",12.0,false,false,false);
            animation.addByPrefix("idle", "Static",12.0,false,false,false);
        }
        else{
            animation.addByPrefix("singRIGHT", "Left",12.0,false,false,false);
            animation.addByPrefix("singUP", "Up",12.0,false,false,false);
            animation.addByPrefix("singDOWN", "Down",12.0,false,false,false);
            animation.addByPrefix("singLEFT", "Right",12.0,false,false,false);
            animation.addByPrefix("idle", "Static",12.0,false,false,false);
        }
        isOpponent = isOpp;
        flipX = isOpponent;
        animation.play("idle");
    }

    public function playAnim(noteId:Int,force:Bool,reversed:Bool,frame:Int = 0)
    {
        state = Singing_note;
        var animName:String = "";
        if(noteId > 3){
            animName = ids[-4 + noteId];
        }
        else{
            animName = ids[noteId];
        }
        animation.play(animName,force,reversed,frame);
    }

    override function update(elapsed:Float){
        if(resetAnim > 0) {
            state = Singing_hold;
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				state = Idling;
				resetAnim = 0;
			}
		}
        super.update(elapsed);
        switch (state){
            case Singing_note:
                if(animation.curAnim.finished){
                    state = Idling;
                }

            case Singing_hold:
                animation.curAnim.curFrame = 0;
            
            case Idling:
                if(animation.curAnim.finished){
                    animation.play("idle");
                    animation.curAnim.resume();
                }
            
            default:
                // nothing
        }
    }
}

enum ChartEditorCharacterState
{
    Singing_note;
    Singing_hold;
    Idling;
}