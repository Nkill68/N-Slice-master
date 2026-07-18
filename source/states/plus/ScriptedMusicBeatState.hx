package states.plus;

import backend.MusicBeatState;
import backend.Mods;
import backend.Paths;
import mikolka.funkin.custom.NativeFileSystem;

import flixel.FlxSprite;

#if LUA_ALLOWED
import psychlua.StateLua;
#end

class ScriptedMusicBeatState extends MusicBeatState
{
    #if LUA_ALLOWED
    public var luaScript:StateLua;
    public var luaSprites:Map<String, FlxSprite> = new Map();
    #end

    override function create()
    {
        super.create();

        #if LUA_ALLOWED
        loadStateLua();
        callLua("onCreate");
        #end
    }

    override function update(elapsed:Float)
    {
        #if LUA_ALLOWED
        callLua("onUpdate", [elapsed]);
        #end

        super.update(elapsed);
    }

    override function destroy()
    {
        #if LUA_ALLOWED

        callLua("onDestroy");

        if(luaScript != null)
        {
            luaScript.stop();
            luaScript = null;
        }

        for(sprite in luaSprites)
        {
            if(sprite != null)
                sprite.destroy();
        }

        luaSprites.clear();

        #end

        super.destroy();
    }

    #if LUA_ALLOWED

    function loadStateLua()
    {
        var stateName = Type.getClassName(Type.getClass(this));
        stateName = stateName.split(".").pop();

        var luaFile = 'states/$stateName.lua';

        for(path in Mods.directoriesWithFile(Paths.getSharedPath(), luaFile))
        {
            if(NativeFileSystem.exists(path))
            {
                luaScript = new StateLua(path, this, stateName);
                trace("Loaded Lua State: " + path);
                return;
            }
        }

        trace("Lua State not found: " + stateName);
    }

    public function makeSprite(tag:String, sprite:FlxSprite)
    {
        if(luaSprites.exists(tag))
        {
            luaSprites[tag].destroy();
            luaSprites.remove(tag);
        }

        luaSprites.set(tag, sprite);
    }

    public function addSprite(tag:String)
    {
        var spr = luaSprites.get(tag);

        if(spr != null)
            add(spr);
    }

    public function removeSprite(tag:String)
    {
        var spr = luaSprites.get(tag);

        if(spr != null)
        {
            remove(spr);
            spr.destroy();
            luaSprites.remove(tag);
        }
    }

    public function addAnimPref(tag:String,name:String, prefix:String, frameRate:Float = 24.0, looped:Bool = true, flipX:Bool = false, flipY:Bool = false){
        var spr = luaSprites.get(tag);

        if(spr != null){
            spr.animation.addByPrefix(name, prefix, frameRate, looped, flipX, flipY);
        }
    }

    public function playAnimSprite(tag:String,animname:String)
    {
        var spr = luaSprites.get(tag);

        if(spr != null){
            spr.animation.play(animname);
        }
    }

    public function setScroll(tag:String,x:Float,y:Float){
        var spr = luaSprites.get(tag);

        if(spr != null)
            spr.scrollFactor.set(x,y);
    }

    public function setPosition(tag:String,x:Float,y:Float){
        var spr = luaSprites.get(tag);

        if(spr != null){
            spr.x = x;
            spr.y = y;
        }
    }

    function callLua(func:String, ?args:Array<Dynamic>)
    {
        if(luaScript == null || luaScript.closed)
            return;

        luaScript.call(func, args);
    }

    public function setLua(name:String, value:Dynamic)
    {
        if(luaScript != null)
            luaScript.set(name, value);
    }

    #end
}