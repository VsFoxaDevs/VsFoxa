package backend;

import sys.FileSystem;
import sys.io.File;
import haxe.Json;

typedef StageAssets = {
    var anim_n:Array<Array<String>>; // the xml name
    var position:Array<Array<Float>>; // the sprite's positions.
    var sprites:Array<String>; // the static Sprites.
    var antialiasing:Array<Bool>; // the antialiasing shit
    var sizes:Array<Array<Int>>; // the sprite's width/height
    var scroll:Array<Array<Float>>; // the sprite's Scroll Factor
    var anim_frame:Array<String>; // the animation file
    var anim_loop:Array<Array<Bool>>; // the animation loop
}

class StageAsset
{
    public static function getStageAsset(name:String):StageAssets
    {
        if(!FileSystem.exists(name+".json")) return makeStageAsset();
        else return Json.parse(File.getContent(name+".json"));
    }

    public static function makeStageAsset():StageAssets
    {
        return {
            anim_n: [],
            position: [],
            sprites: [],
            sizes: [],
            antialiasing: [],
            scroll: [],
            anim_frame: [],
            anim_loop: []
        };
    }
}