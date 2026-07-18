package psychlua;

#if LUA_ALLOWED

import llua.*;

import backend.Paths;
import flixel.FlxSprite;
import states.plus.ScriptedMusicBeatState;

class StateLua
{
    public var lua:State;
    public var scriptName:String;
    public var stateName:String;

    public var state:ScriptedMusicBeatState;

    public var closed:Bool = false;

    public function new(path:String,state:ScriptedMusicBeatState,stateName:String)
    {
        this.state = state;
        this.stateName = stateName;
        this.scriptName = path;

        lua = LuaL.newstate();
        LuaL.openlibs(lua);

        registerCallbacks();

        LuaL.dofile(lua,path);
    }

    function registerCallbacks()
    {
        Lua_helper.add_callback(lua,"makeSprite",function(tag:String,image:String,x:Float=0,y:Float=0)
        {
            var spr = new FlxSprite(x,y);
            spr.frames = (Paths.getSparrowAtlas('states_assets/$stateName/$image'));

			trace(spr.frames.frames);

            state.makeSprite(tag,spr);
        });

        Lua_helper.add_callback(lua,"addSprite",function(tag:String)
        {
            state.addSprite(tag);
        });

        Lua_helper.add_callback(lua,"removeSprite",function(tag:String)
        {
            state.removeSprite(tag);
        });

		Lua_helper.add_callback(lua,"setScroll",function(tag:String,x:Float,y:Float)
        {
            state.setScroll(tag,x,y);
        });

		Lua_helper.add_callback(lua,"setPosition",function(tag:String,x:Float,y:Float)
        {
            state.setPosition(tag,x,y);
        });

		Lua_helper.add_callback(lua,"addAnimationPrefix",function(tag:String,animname:String,animxmlname:String,fps:Float = 24,looped:Bool = false,flipx:Bool = false, flipy:Bool = false)
        {
            state.addAnimPref(tag,animname,animxmlname,fps,looped,flipx,flipy);
        });

		Lua_helper.add_callback(lua,"playSpriteAnim",function(tag:String,animname:String)
        {
            state.playAnimSprite(tag,animname);
        });
    }

    public function exists(func:String):Bool
    {
        Lua.getglobal(lua,func);

        var result = Lua.isfunction(lua,-1);

        Lua.pop(lua,1);

        return result;
    }

    public function call(func:String,?args:Array<Dynamic>)
    {
        if(closed)
            return;

        if(args == null)
            args = [];

        Lua.getglobal(lua,func);

        if(!Lua.isfunction(lua,-1))
        {
            Lua.pop(lua,1);
            return;
        }

        for(arg in args)
            Convert.toLua(lua,arg);

        var status = Lua.pcall(lua,args.length,0,0);

        if(status != Lua.LUA_OK)
        {
            trace(Lua.tostring(lua,-1));
            Lua.pop(lua,1);
        }
    }

    public function set(variable:String,value:Dynamic)
    {
        if(closed)
            return;

        if(Reflect.isFunction(value))
        {
            Lua_helper.add_callback(lua,variable,value);
            return;
        }

        Convert.toLua(lua,value);
        Lua.setglobal(lua,variable);
    }

    public function stop()
    {
        if(closed)
            return;

        closed = true;

        Lua.close(lua);
        lua = null;
    }
}

#end