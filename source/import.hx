#if !macro
//Discord API
#if desktop
import backend.Discord;
#end

//Psych
#if LUA_ALLOWED
import llua.*;
import llua.Lua;
import psychlua.*;
import psychlua.FunkinLua;
#end

#if flxanimate
import flxanimate.*;
#end

#if ACHIEVEMENTS_ALLOWED
import backend.Achievements;
#end

#if sys
import sys.*;
import sys.io.*;
#elseif js
import js.html.*;
#end

import math.*;
import math.Vector3;
import math.VectorHelpers;
//import extraflixel.FlxSprite3D;

import backend.Paths;
import backend.Controls;
import backend.CoolUtil;
import backend.MusicBeatState;
import backend.MusicBeatSubstate;
import backend.CustomFadeTransition;
import backend.ClientPrefs;
import backend.Conductor;
import backend.BaseStage;
import backend.Difficulty;
import backend.Mods;

import objects.Alphabet;
import objects.BGSprite;

import states.PlayState;
import states.LoadingState;

//Flixel
#if (flixel >= "5.3.0")
import flixel.sound.FlxSound;
#else
import flixel.system.FlxSound;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

#if VIDEOS_ALLOWED
import hxvlc.flixel.*;
import hxvlc.flixel.FlxVideo;
import hxvlc.openfl.*;
#end

import flixel.FlxBasic;
import flixel.util.FlxAxes;

import states.editors.ChartingState;

#if (cpp && windows)
import cppthing.CppApi;
#end

using StringTools;
#end
