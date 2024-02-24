#if !macro
// Discord API
#if desktop
import backend.Discord;
#end

// Psych/Alleyway
#if LUA_ALLOWED
import llua.*;
import llua.Lua;
import psychlua.*;
import psychlua.FunkinLua;
#end

// FlxAnimate
#if flxanimate
import flxanimate.*;
#end

#if ACHIEVEMENTS_ALLOWED
import backend.Achievements;
#end

// Sys
#if sys
import sys.*;
import sys.io.*;
#elseif js
import js.html.*;
#end

// math stuff
import math.*;
import math.Vector3;
import math.VectorHelpers;

// HaxeUI
import haxe.ui.*;
import haxe.ui.components.*;
import haxe.ui.containers.*;
import haxe.ui.containers.windows.*;
import haxe.ui.core.*;
import haxe.ui.events.*;
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
import states.StartingState;
import states.FreeplayState;
import states.SaveFileState;
import states.CreditsState;
import states.MainMenuState;
import states.CharacterSelectionState;

// Flixel
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

// HxVLC
#if VIDEOS_ALLOWED
import hxvlc.flixel.*;
import hxvlc.flixel.FlxVideo;
import hxvlc.openfl.*;
#end

import flixel.FlxBasic;
import flixel.util.FlxAxes;

import substates.ScriptEditorSubstate;
import states.editors.ChartingState;

// CPP
#if (cpp && windows)
import cppthing.CppApi;
#end

using StringTools;
#end
