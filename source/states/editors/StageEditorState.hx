package states.editors;

import flixel.util.FlxAxes;
import backend.StageData;
import substates.Prompt;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.FlxObject;
import objects.Character;
import flixel.FlxBasic;
import lime.utils.Assets;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets.FlxGraphicAsset;
import haxe.Json;
import flixel.addons.ui.FlxUICheckBox;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import sys.FileSystem;
import backend.StageAssets;
import openfl.net.FileReference;
import openfl.events.UncaughtErrorEvent;
import openfl.Lib;
import backend.StageAssets.StageAsset;
import sys.io.File;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUITabMenu;

// god i creating this stuff for 3 fucking times
/**
* I coded this alone...
*
* So Please credit me if you want to use...
* 
* @author Lego0_77
*/

class StageEditorState extends MusicBeatState
{
    var tab:FlxUITabMenu;
    var blockType:FlxTypedGroup<FlxUIInputText>;
    var blockNum:FlxTypedGroup<FlxUINumericStepper>;
    public static var data:StageAssets = StageAsset.makeStageAsset();
    public static var data_pos:StageFile = StageData.dummy();
    public static var instance:StageEditorState;
    var stageGrp:FlxSpriteGroup;
    var currentPath:String = "assets";
    public var isModFolder:Bool = false;
    var camStage:FlxCamera;
    var camOther:FlxCamera;
    var camUI:FlxCamera;
    var curSelected:Int = 0;
    var iTxt:FlxText;
    var opponent:Character;
    var gf:Character;
    var bf:Character;
    var cont:FlxText;
    var path:String;
    var isCharacterMode:Bool = false;

    override function create()
    {
        instance = this;

        camStage = new FlxCamera();
        camUI = new FlxCamera();
        camUI.bgColor.alpha = 0;
        camOther = new FlxCamera();
        camOther.bgColor.alpha = 0;

        FlxG.cameras.reset(camStage);
        FlxG.cameras.add(camUI, false);
        FlxG.cameras.add(camOther, false);

        FlxG.cameras.setDefaultDrawTarget(camStage, true);

        CustomFadeTransition.nextCamera = camOther;

        tab = new FlxUITabMenu(null, [{name: "Data", label: "Data"}, {name: "Asset", label: "Asset"}, {name: "Animation", label: "Animation"}, {name: "Characters", label: "Characters"}], true);
        tab.resize(400, 300);
        tab.screenCenter();
        tab.x = 10;
        tab.selected_tab = 2;
        tab.cameras = [camUI];
        add(tab);

        #if MODS_ALLOWED
        // i dont know how to code mods folders
        Mods.loadTopMod();
        if (isModFolder) currentPath = Paths.mods(Mods.currentModDirectory);
        trace("Are you modding from a folder?: " + isModFolder);
        trace("Then your base path is: " + currentPath);
        #end

        FlxG.mouse.visible = true;

        blockType = new FlxTypedGroup<FlxUIInputText>();
        blockNum = new FlxTypedGroup<FlxUINumericStepper>();

        Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
        stageGrp = new FlxSpriteGroup();
        add(stageGrp);

        bf = new Character(data_pos.boyfriend[0],data_pos.boyfriend[1],"bf",true);
        bf.x += bf.positionArray[0];
        bf.y += bf.positionArray[1];
        gf = new Character(data_pos.girlfriend[0],data_pos.girlfriend[1],"gf");
        gf.x += gf.positionArray[0];
        gf.y += gf.positionArray[1];
        opponent = new Character(data_pos.opponent[0],data_pos.opponent[1],"dad",false);
        opponent.x += opponent.positionArray[0];
        opponent.y += opponent.positionArray[1];

        add(gf);
        add(bf);
        add(opponent);

        addUI("Data");
        addUI("Asset");
        addUI("Animation");
        addUI("Characters");

        path = currentPath+"/"+directoryInput.text + "/images/" + fuck.text + ".png";

        var infoTxt = new FlxText(0, FlxG.height, 0, "Press SPACE to watch how to use this!", 20);
        infoTxt.screenCenter(X);
        infoTxt.y = FlxG.height - infoTxt.height - 5;
        infoTxt.font = Paths.font("vcr.ttf");
        infoTxt.cameras = [camUI];
        add(infoTxt);

        iTxt = new FlxText(0, 10, 0, "X: 0 / Y: 0 / Width: 0 / Height: 0 / Antialiasing: false / Animated: false", 20);
        iTxt.screenCenter(X);
        iTxt.font = Paths.font("vcr.ttf");
        iTxt.cameras = [camUI];
        add(iTxt);

        var txt = "←↓↑→ Move Sprite to L | D | U | R
        Shift - Move x2 faster
        Q - Zoom Out
        E - Zoom In
        A, D - Switch to Another Sprite
        Ctrl - Move x1 by just Pressing";
        cont = new FlxText(10, tab.y + tab.height + 10, 0, txt, 15);
        cont.font = Paths.font("vcr.ttf");
        cont.alpha = 0.5;
        cont.borderStyle = OUTLINE;
        cont.borderSize = 2.5;
        cont.borderColor = FlxColor.GRAY;
        cont.cameras = [camUI];
        cont.alignment = LEFT;
        add(cont);

        super.create();
    }

    // autosave on crash.
    function onCrash(ERR:UncaughtErrorEvent)
    {
        autoSaveFile();
        trace("Autosaved name With " + Date.now().toString().replace(":", "-"));
    }

    var blockInput:Bool = false;
    var alphaShit:Array<Float> = [0.5, 0.5];
    var camZoom:Float = 1;
    var elapsed2:Float = 0;
    var curChar:String = null;
    override function update(elapsed:Float)
    {
        elapsed2 += elapsed;
        if (FlxG.mouse.overlaps(tab, camStage)) alphaShit[0] = 1; else alphaShit[0] = 0.5;
        tab.alpha = FlxMath.lerp(alphaShit[0], tab.alpha, FlxMath.bound((1 - elapsed) * 0.75, 0, 1));
        if (FlxG.mouse.overlaps(cont, camStage)) alphaShit[1] = 1; else alphaShit[1] = 0.5;
        cont.alpha = FlxMath.lerp(alphaShit[1], cont.alpha, FlxMath.bound((1 - elapsed) * 0.75, 0, 1));
        camStage.zoom = FlxMath.lerp(camZoom, camStage.zoom, FlxMath.bound((1 - elapsed) * 0.75, 0, 1));

        if (iTxt != null)
        {
            var obj = stageGrp.members[curSelected];
            if (obj != null)
            {
                iTxt.text = "X: " + obj.x + " / Y: " + obj.y + " / Width: " + obj.width + " / Height: " + obj.height + " / Antialiasing: " + obj.antialiasing + " / Zoom: " + camZoom;
            } else {
                iTxt.text = "X: N/A / Y: N/A / Width: N/A / Height: N/A / Antialiasing: N/A / Zoom: " + camZoom;
            }
            iTxt.screenCenter(X);
        }

        // you can click the sprite to active!
        for (i in 0...stageGrp.length)
        {
            var tan = stageGrp.members[i];
            if (tan != null)
            {
                if (FlxG.mouse.overlaps(tan) && FlxG.mouse.justPressed && !FlxG.mouse.overlaps(tab) && !isCharacterMode)
                {
                    curSelected = i;
                    changeSelect();
                }
            }
        }

        if (bf != null) bf.setPosition(data_pos.boyfriend[0] + bf.positionArray[0], data_pos.boyfriend[1] + bf.positionArray[1]);
        if (gf != null) gf.setPosition(data_pos.girlfriend[0] + gf.positionArray[0], data_pos.girlfriend[1] + gf.positionArray[1]);
        if (opponent != null) opponent.setPosition(data_pos.opponent[0] + opponent.positionArray[0], data_pos.opponent[1] + opponent.positionArray[1]);

        var spr = stageGrp.members[curSelected];
        if (!blockInput)
        {
            if (!isCharacterMode)
            {
                if (FlxG.keys.justPressed.A) changeSelect(-1);
                if (FlxG.keys.justPressed.D) changeSelect(1);
                if (FlxG.keys.pressed.CONTROL)
                {
                    if (FlxG.keys.justPressed.LEFT) spr.x -= 5;
                    if (FlxG.keys.justPressed.RIGHT) spr.x += 5;
                    if (FlxG.keys.justPressed.UP) spr.y -= 5;
                    if (FlxG.keys.justPressed.DOWN) spr.x += 5;
                }

                if (spr != null && !FlxG.keys.pressed.CONTROL)
                {
                    if (FlxG.keys.pressed.LEFT)
                    {
                        if (FlxG.keys.pressed.SHIFT) spr.x -= 10;
                        else spr.x -= 5;
                    }
                    if (FlxG.keys.pressed.RIGHT)
                    {
                        if (FlxG.keys.pressed.SHIFT) spr.x += 10;
                        else spr.x += 5;
                    }
                    if (FlxG.keys.pressed.UP)
                    {
                        if (FlxG.keys.pressed.SHIFT) spr.y -= 10;
                        else spr.y -= 5;
                    }
                    if (FlxG.keys.pressed.DOWN)
                    {
                        if (FlxG.keys.pressed.SHIFT) spr.y += 10;
                        else spr.y += 5;
                    }
                }
            }

            if (FlxG.keys.justPressed.Q && camZoom > 0.25)
            {
                if (FlxG.keys.pressed.SHIFT) camZoom -= 0.25;
                else camZoom -= 0.125;
                data_pos.defaultZoom = camZoom;
            }

            if (FlxG.keys.justPressed.E && camZoom < 2.5)
            {
                if (FlxG.keys.pressed.SHIFT) camZoom += 0.25;
                else camZoom += 0.125;
                data_pos.defaultZoom = camZoom;
            }

            if (controls.BACK)
            {
                Lib.current.loaderInfo.uncaughtErrorEvents.removeEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
                FlxG.sound.playMusic(Paths.music("freakyMenu"));
                FlxG.mouse.visible = false;
                Paths.setCurrentLevel(null);
                MusicBeatState.switchState(new MasterEditorMenu());
            }
        }

        if(spr != null) spr.alpha = 0.75 + Math.sin(elapsed2)*0.25;

        if(FlxG.keys.justPressed.SPACE) {trace('tutorials not out yet!');}

        if (isCharacterMode)
        {
            if (FlxG.keys.justPressed.A)
            {
                bf.color = FlxColor.WHITE;
                gf.color = FlxColor.WHITE;
                opponent.color = FlxColor.WHITE;
                if (curChar == "opponent") { curChar = "bf"; bf.color = FlxColor.BLUE; }
                else if (curChar == "bf") { curChar = "gf"; gf.color = FlxColor.BLUE; }
                else { curChar = "opponent"; opponent.color = FlxColor.BLUE; }
            }

            if (FlxG.keys.justPressed.D)
            {
                bf.color = FlxColor.WHITE;
                gf.color = FlxColor.WHITE;
                opponent.color = FlxColor.WHITE;
                if (curChar == "opponent") { curChar = "gf"; gf.color = FlxColor.BLUE; }
                else if (curChar == "bf") { curChar = "opponent"; opponent.color = FlxColor.BLUE; }
                else { curChar = "bf"; bf.color = FlxColor.BLUE; }
            }

            if (curChar != null)
            {
                var playOneshot = function (axis:FlxAxes, range:Float)
                {
                    if (curChar == "opponent") if (axis == X) data_pos.opponent[0] += range; else data_pos.opponent[1] += range;
                    if (curChar == "bf") if (axis == X) data_pos.boyfriend[0] += range; else data_pos.boyfriend[1] += range;
                    if (curChar == "gf") if (axis == X) data_pos.girlfriend[0] += range; else data_pos.girlfriend[1] += range;
                };

                if (FlxG.keys.pressed.LEFT)
                {
                    if (FlxG.keys.pressed.SHIFT) playOneshot(X, -10);
                    else if (FlxG.keys.pressed.CONTROL) playOneshot(X, -2.5);
                    else playOneshot(X, -5);
                }
                if (FlxG.keys.pressed.RIGHT)
                {
                    if (FlxG.keys.pressed.SHIFT) playOneshot(X, 10);
                    else if (FlxG.keys.pressed.CONTROL) playOneshot(X, 2.5);
                    else playOneshot(X, 5);
                }
                if (FlxG.keys.pressed.UP)
                {
                    if (FlxG.keys.pressed.SHIFT) playOneshot(Y, -10);
                    else if (FlxG.keys.pressed.CONTROL) playOneshot(Y, -2.5);
                    else playOneshot(Y, -5);
                }
                if (FlxG.keys.pressed.DOWN)
                {
                    if (FlxG.keys.pressed.SHIFT) playOneshot(Y, 10);
                    else if (FlxG.keys.pressed.CONTROL) playOneshot(Y, 2.5);
                    else playOneshot(Y, 5);
                }
            }
        }

        super.update(elapsed);
    }

    var __ref:FileReference;
    var anti:FlxUICheckBox;
    var sprXInput:FlxUINumericStepper;
    var sprYInput:FlxUINumericStepper;
    var sprSXInput:FlxUINumericStepper;
    var sprSYInput:FlxUINumericStepper;
    var fuck:FlxUIInputText;
    var directoryInput:FlxUIInputText;
    // ITS SHORT NAME OF sprScrollFactorXInput NOT SFX
    var sprSFXInput:FlxUINumericStepper;
    var sprSFYInput:FlxUINumericStepper;
    function addUI(num:String)
    {
        var ok = new FlxUI(null, tab);
        switch (num)
        {
            // yeah this is WIP, this won't change positions yet.
            case "Characters":
                ok.name = "Characters";

                // STOLEN FROM CHARTINGSTATE
                #if MODS_ALLOWED
                var directories:Array<String> = [Paths.mods('characters/'), Paths.mods(Mods.currentModDirectory + '/characters/'), Paths.getSharedPath('characters/')];
                for(mod in Mods.getGlobalMods())
                    directories.push(Paths.mods(mod + '/characters/'));
                #else
                var directories:Array<String> = [Paths.getSharedPath('characters/')];
                #end
                var tempArray:Array<String> = [];
                var characters:Array<String> = Mods.mergeAllTextsNamed('data/characterList.txt', Paths.getSharedPath());
                for (character in characters)
                {
                    if(character.trim().length > 0)
                        tempArray.push(character);
                }

                #if MODS_ALLOWED
                for (i in 0...directories.length) {
                    var directory:String = directories[i];
                    if(FileSystem.exists(directory)) {
                        for (file in FileSystem.readDirectory(directory)) {
                            var path = haxe.io.Path.join([directory, file]);
                            if (!FileSystem.isDirectory(path) && file.endsWith('.json')) {
                                var charToCheck:String = file.substr(0, file.length - 5);
                                if(charToCheck.trim().length > 0 && !charToCheck.endsWith('-dead') && !tempArray.contains(charToCheck)) {
                                    tempArray.push(charToCheck);
                                    characters.push(charToCheck);
                                }
                            }
                        }
                    }
                }
                #end
                tempArray = [];

                var hideC = new FlxUICheckBox(0, 0, null, null, "Hide Characters (only editor)");
                hideC.checked = false;
                hideC.callback = function()
                {
                    if (bf != null) bf.visible = !hideC.checked;
                    if (gf != null) gf.visible = !hideC.checked;
                    if (opponent != null) opponent.visible = !hideC.checked;
                }

                var dropdownShit:Float = 25;

                var bfDD = new FlxUIDropDownMenu(10, 25, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(name:String)
                {
                    if (bf != null) remove(bf);
                    bf = new Character(0, 0, characters[Std.parseInt(name)], true);
                    bf.visible = !hideC.checked;
                    add(bf);
                });
                bfDD.selectedLabel = "bf";
                hideC.setPosition(bfDD.x + bfDD.width + 50, bfDD.y);

                var gfDD = new FlxUIDropDownMenu(bfDD.x, bfDD.y+dropdownShit+25, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(name:String)
                {
                    if (gf != null) remove(gf);
                    gf = new Character(0, 0, characters[Std.parseInt(name)], true);
                    gf.visible = !hideC.checked;
                    add(gf);
                });
                gfDD.selectedLabel = "gf";

                var dadDD = new FlxUIDropDownMenu(gfDD.x, gfDD.y + dropdownShit + 25, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(name:String)
                {
                    if (opponent != null) remove(opponent);
                    opponent = new Character(0, 0, characters[Std.parseInt(name)], true);
                    opponent.visible = !hideC.checked;
                    add(opponent);
                });
                dadDD.selectedLabel = "dad";

                var charEdit = new FlxUICheckBox(hideC.x, hideC.y + 25 + hideC.height, null, null, "Character Edit Mode");
                charEdit.checked = false;
                charEdit.callback = function()
                {
                    isCharacterMode = charEdit.checked;
                };

                ok.add(new FlxText(bfDD.x, bfDD.y - 17, 0, "Boyfriend:"));
                ok.add(new FlxText(gfDD.x, gfDD.y - 17, 0, "Girlfriend:"));
                ok.add(new FlxText(dadDD.x, dadDD.y - 17, 0, "Opponent:"));
                ok.add(dadDD);
                ok.add(gfDD);
                ok.add(hideC);
                ok.add(bfDD);
                ok.add(charEdit);
            case "Animation":
                ok.name = "Animation";

                var animFile = new FlxUIInputText(10, 25, 150, "", 8);
                blockType.add(animFile);

                var posX = new FlxUINumericStepper(animFile.x+25+animFile.width,animFile.y,1,0,Math.NEGATIVE_INFINITY,Math.POSITIVE_INFINITY);
                blockNum.add(posX);
                var posY = new FlxUINumericStepper(posX.x+posX.width+5,posX.y,1,0,posX.min,posX.max);
                blockNum.add(posY);

                var scaleX = new FlxUINumericStepper(posX.x,posX.y+posX.height+25,0.1,0,0,Math.POSITIVE_INFINITY);
                blockNum.add(scaleX);
                var scaleY = new FlxUINumericStepper(scaleX.x+scaleX.width+5,scaleX.y,0.1,0,0,Math.POSITIVE_INFINITY);
                blockNum.add(scaleY);

                var scrollX = new FlxUINumericStepper(scaleX.x,scaleX.y+25+scaleX.height,0.1,1,0,Math.POSITIVE_INFINITY);
                blockNum.add(scrollX);
                var scrollY = new FlxUINumericStepper(scrollX.x+scrollX.width+5,scrollX.y,0.1,1,0,Math.POSITIVE_INFINITY);
                blockNum.add(scrollY);

                var anti = new FlxUICheckBox(animFile.x+animFile.width+10, animFile.y+animFile.height+25,null,null,"Antialiasing");
                var addButt = new FlxButton(animFile.x, animFile.y+animFile.height+25,"Add Sprite",function()
                {
                    var fuck = new FlxSprite(posX.value, posY.value);
                    fuck.frames = Paths.getSparrowAtlas(animFile.text);
                    fuck.antialiasing = anti.checked;
                    fuck.setGraphicSize(Std.int(scaleX.value), Std.int(scaleY.value));
                    fuck.updateHitbox();
                    fuck.scrollFactor.set(scrollX.value, scrollY.value);
                    data.antialiasing.push(anti.checked);
                    data.scroll.push([scrollX.value, scrollY.value]);
                    data.sizes.push([Std.int(scaleX.value), Std.int(scaleY.value)]);
                    data.position.push([posX.value, posY.value]);
                    data.anim_frame.push(animFile.text);
                    data.sprites.push(null);
                    fuck.cameras = [camStage];
                    stageGrp.add(fuck);
                });

                var animName = new FlxUIInputText(addButt.x,addButt.y+addButt.height+25,150,"",8);
                blockType.add(animName);

                var animLoop = new FlxUICheckBox(animName.x+animName.width+25, animName.y+25+animName.height, null, null, "Loop");
                animLoop.checked = true;

                var addAnim = new FlxButton(animName.x,animName.y+25+animName.height,"Add Animation",function()
                {
                    var spr = stageGrp.members[curSelected];
                    if (spr != null)
                    {
                        if (spr.frames != null)
                        {
                            openSubState(new Prompt("This Image Is Static,\nChange to Animated?", 0, function()
                            {
                                spr.frames = Paths.getSparrowAtlas(data.sprites[curSelected]);
                                spr.animation.addByPrefix(animName.text, animName.text, 24, animLoop.checked);
                                data.anim_frame[curSelected] = animFile.text;
                                data.anim_loop[curSelected] = [animLoop.checked];
                                data.anim_n[curSelected] = [animName.text];
                                data.sprites[curSelected] = null;
                            }, null));
                        } else {
                            spr.animation.addByPrefix(animName.text, animName.text, 24, animLoop.checked);
                            if (data.anim_n[curSelected] == null) data.anim_n.push([animName.text]);
                            else data.anim_n[curSelected].push(animName.text);
                            if (data.anim_loop[curSelected] == null) data.anim_loop.push([animLoop.checked]);
                            else data.anim_loop[curSelected].push(animLoop.checked);
                        }
                    }
                });

                var playAnim = new FlxButton(addAnim.x, addAnim.y+25+addAnim.height, "Play Animation", function()
                {
                    var spr = stageGrp.members[curSelected];
                    if (spr != null)
                    {
                        spr.animation.play(animName.text, true);
                    }
                });

                var stopAnim = new FlxButton(playAnim.x+playAnim.width+10, playAnim.y, "Stop Animation", function()
                {
                    var spr = stageGrp.members[curSelected];
                    if (spr != null)
                    {
                        spr.animation.stop();
                    }
                });

                ok.add(new FlxText(animFile.x, 10, 0, "Animation File:"));
                ok.add(new FlxText(animName.x, animName.y - 17, 0, "Animation Name:"));
                ok.add(new FlxText(posX.x, posX.y - 17, 0, "Position:"));
                ok.add(new FlxText(scaleX.x, scaleX.y - 17, 0, "Width/Height:"));
                ok.add(new FlxText(scrollX.x, scrollX.y - 17, 0, "Scrollfactor X/Y:"));
                ok.add(animLoop);
                ok.add(stopAnim);
                ok.add(playAnim);
                ok.add(animFile);
                ok.add(addAnim);
                ok.add(posX);
                ok.add(posY);
                ok.add(scaleX);
                ok.add(scaleY);
                ok.add(scrollX);
                ok.add(scrollY);
                ok.add(animName);
                ok.add(addButt);
            case "Asset":
                ok.name = "Asset";

                fuck = new FlxUIInputText(10, 25, 150, "", 8);
                blockType.add(fuck);

                anti = new FlxUICheckBox(fuck.x, fuck.y + fuck.height + 10, null, null, "Antialiasing", 100);
                anti.checked = false;

                var halfLife = Std.int(150/2);
                sprXInput = new FlxUINumericStepper(fuck.x, anti.y + 50, 1, 0, Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, 2);
                sprXInput.width = halfLife - 5;
                blockNum.add(sprXInput);
                sprYInput = new FlxUINumericStepper(sprXInput.x + sprXInput.width + 5, sprXInput.y, 1, 0, Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, 2);
                sprYInput.width = halfLife;
                blockNum.add(sprYInput);

                sprSXInput = new FlxUINumericStepper(fuck.x, sprXInput.y + 20 + sprXInput.height, 1, 0, 0, Math.POSITIVE_INFINITY);
                sprSXInput.width = halfLife - 5;
                blockNum.add(sprSXInput);
                sprSYInput = new FlxUINumericStepper(sprSXInput.x + 5 + sprSXInput.width, sprSXInput.y, 1, 0, 0, Math.POSITIVE_INFINITY);
                sprSYInput.width = halfLife;
                blockNum.add(sprSYInput);

                sprSFXInput = new FlxUINumericStepper(sprSXInput.x, sprSXInput.y + 20 + sprSXInput.height, 0.1, 0, 1, Math.POSITIVE_INFINITY, 1);
                sprSFXInput.width = halfLife - 5;
                blockNum.add(sprSFXInput);

                sprSFYInput = new FlxUINumericStepper(sprSFXInput.x + 5 + sprSFXInput.width, sprSFXInput.y, 0.1, 0, 1, Math.POSITIVE_INFINITY, 1);
                sprSFYInput.width = halfLife;
                blockNum.add(sprSFYInput);

                var addButt = new FlxButton(fuck.x, tab.height - 50, "Add Image", function()
                {
                    {
                        path = currentPath+"/"+directoryInput.text + "/images/" + fuck.text + ".png";
                        #if MODS_ALLOWED
                        var ok = new FlxSprite(sprXInput.value, sprYInput.value).loadGraphic((!isModFolder ? Paths.image(fuck.text) : Paths.modsImages(path)));
                        if (isModFolder) path = Paths.modsImages(currentPath + "/" + directoryInput.text + fuck.text);
                        #else
                        var ok = new FlxSprite(sprXInput.value, sprYInput.value).loadGraphic(Paths.image(fuck.text));
                        #end
                        ok.antialiasing = anti.checked;
                        ok.setGraphicSize(Std.int(sprSXInput.value), Std.int(sprSYInput.value));
                        ok.updateHitbox();
                        ok.scrollFactor.set(sprSFXInput.value, sprSFYInput.value);
                        ok.cameras = [camStage];
                        stageGrp.add(ok);
                        data.sprites.push(fuck.text);
                        data.antialiasing.push(anti.checked);
                        // doing sorting shit
                        data.anim_n.push([null]);
                        data.scroll.push([sprSFXInput.value, sprSFYInput.value]);
                        data.position.push([sprXInput.value, sprYInput.value]);
                        data.sizes.push([Std.int(sprSXInput.value), Std.int(sprSYInput.value)]);
                        data.anim_frame.push(null);
                        data.anim_loop.push([]);
                        trace("added image");
                        trace(path);
                    }
                });

                var updateButt = new FlxButton(addButt.x + addButt.width + 70, addButt.y, "Update Image", function()
                {
                    var target = stageGrp.members[curSelected];
                    if (target != null)
                    {
                        if (target.frames == null) // if its animated
                        {
                            // prevents if you pressed this button by accident.
                            openSubState(new Prompt("This image is animated,\nWant to change into static?", 0, function()
                            {
                                path = currentPath+"/" + directoryInput.text + "/images/" + fuck.text + ".png";
                                {
                                    target.loadGraphic((!isModFolder ? Paths.image(fuck.text) : Paths.modsImages(path)));
                                    target.setPosition(sprXInput.value, sprYInput.value);
                                    target.setGraphicSize(Std.int(sprSXInput.value), Std.int(sprSYInput.value));
                                    target.antialiasing = anti.checked;
                                    target.scrollFactor.set(sprSFXInput.value, sprSFYInput.value);

                                    data.sprites[curSelected] = fuck.text;
                                    data.antialiasing[curSelected] = anti.checked;
                                    data.position[curSelected] = [sprXInput.value, sprYInput.value];
                                    data.scroll[curSelected] = [sprSFXInput.value, sprSFYInput.value];
                                    data.sizes[curSelected] = [Std.int(sprSXInput.value), Std.int(sprSYInput.value)];

                                    data.anim_frame[curSelected] = null;
                                    data.anim_loop[curSelected] = [];
                                    data.anim_n[curSelected] = [null];
                                    trace("updated image");
                                }
                            }, null));
                        } else {
                            path = currentPath+"/"+directoryInput.text + "/images/" + fuck.text + ".png";
                            {
                                target.loadGraphic((!isModFolder ? Paths.image(fuck.text) : Paths.modsImages(path)));
                                target.setPosition(sprXInput.value, sprYInput.value);
                                target.setGraphicSize(Std.int(sprSXInput.value), Std.int(sprSYInput.value));
                                target.antialiasing = anti.checked;
                                target.scrollFactor.set(sprSFXInput.value, sprSFYInput.value);

                                data.sprites[curSelected] = fuck.text;
                                data.antialiasing[curSelected] = anti.checked;
                                data.position[curSelected] = [sprXInput.value, sprYInput.value];
                                data.scroll[curSelected] = [sprSFXInput.value, sprSFYInput.value];
                                data.sizes[curSelected] = [Std.int(sprSXInput.value), Std.int(sprSYInput.value)];
                                trace("updated image");
                            }
                        }
                    }
                });

                var removeButt = new FlxButton(updateButt.x+70+updateButt.width, updateButt.y, "Remove Image", function()
                {
                    var target = stageGrp.members[curSelected];
                    if (target != null)
                    {
                        stageGrp.remove(target, true);
                        target.destroy();
                        data.sizes.remove(data.sizes[curSelected]);
                        data.sprites.remove(data.sprites[curSelected]);
                        data.antialiasing.remove(data.antialiasing[curSelected]);
                        data.anim_frame.remove(data.anim_frame[curSelected]);
                        data.anim_loop.remove(data.anim_loop[curSelected]);
                        data.anim_n.remove(data.anim_n[curSelected]);
                        data.position.remove(data.position[curSelected]);
                        data.scroll.remove(data.scroll[curSelected]);
                        trace("removed image");
                    }
                });

                ok.add(new FlxText(fuck.x, 10, 0, "Image Name:"));
                ok.add(new FlxText(sprXInput.x, sprXInput.y - 17, 0, "Image X/Y Position:"));
                ok.add(new FlxText(sprSXInput.x, sprSXInput.y - 17, 0, "Image Width/Height:"));
                ok.add(new FlxText(sprSFXInput.x, sprSFXInput.y - 17, 0, "Image Scrollfactor X/Y"));
                ok.add(addButt);
                ok.add(fuck);
                ok.add(anti);
                ok.add(updateButt);
                ok.add(sprXInput);
                ok.add(sprYInput);
                ok.add(sprSXInput);
                ok.add(sprSYInput);
                ok.add(sprSFXInput);
                ok.add(sprSFYInput);
                ok.add(removeButt);
            case "Data":
                ok.name = "Data";

                var fileInput = new FlxUIInputText(10, 25, 150, "", 8);
                blockType.add(fileInput);

                directoryInput = new FlxUIInputText(fileInput.x, fileInput.y + fileInput.height + 25, 150, "", 8);
                directoryInput.callback = function(text:String, event:String)
                {
                    data_pos.directory = text;
                    Paths.setCurrentLevel(text);
                }
                blockType.add(directoryInput);

                var fileButt = new FlxButton(fileInput.x + fileInput.width + 25, fileInput.y, "Load Data", function()
                {
                    #if MODS_ALLOWED
                    if (FileSystem.exists((isModFolder ? Paths.mods(currentPath+"stages/exp/"+fileInput.text+".json") : currentPath+"/stages/exp/"+fileInput.text+".json")))
                    #else
                    if (FileSystem.exists(currentPath+"/stages/exp/"+fileInput.text+".json"))
                    #end
                    {
                        #if MODS_ALLOWED
                        var data = StageAsset.getStageAsset((isModFolder ? Paths.mods(currentPath+"stages/exp/"+fileInput.text+".json") : currentPath+"/stages/exp/"+fileInput.text+".json"));
                        #else
                        var data = StageAsset.getStageAsset(currentPath+"/stages/exp/"+fileInput.text+".json");
                        #end
                        trace(data);

                        for (i in 0...stageGrp.length)
                        {
                            stageGrp.remove(stageGrp.members[i], true);
                        }
                        resetStage();
                    } else {
                        Lib.application.window.alert("Failed to load\n"+fileInput.text+".json\nIs it missing?\n", "Error!");
                    }
                });

                var saveButt = new FlxButton(fileButt.x + fileButt.width + 25, fileButt.y, "Save Stage Asset Data", function()
                {
                    if (data != null)
                    {
                        __ref = new FileReference();
                        __ref.addEventListener(Event.COMPLETE, onSaveComplete);
			            __ref.addEventListener(Event.CANCEL, onSaveCancel);
			            __ref.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
                        __ref.save(Json.stringify(data, "\t").trim(), directoryInput.text.toLowerCase()+".json");
                    }
                });
                saveButt.setGraphicSize(Std.int(saveButt.width), Std.int(saveButt.height + 10));
                saveButt.updateHitbox();

                var help = new FlxButton(saveButt.x, saveButt.y + 25 + saveButt.height, "Save Stage Data", function()
                {
                    if (data_pos != null)
                    {
                        __ref = new FileReference();
                        __ref.addEventListener(Event.COMPLETE, onSaveComplete);
			            __ref.addEventListener(Event.CANCEL, onSaveCancel);
			            __ref.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
                        __ref.save(Json.stringify(data_pos, "\t").trim(), directoryInput.text.toLowerCase()+".json");
                    }
                });
                help.setGraphicSize(Std.int(help.width), Std.int(help.height + 10));
                help.updateHitbox();

                var sUI = new FlxUIInputText(directoryInput.x, directoryInput.y+25+directoryInput.height, 150, "", 8);
                sUI.callback = function(text:String, action:String)
                {
                    data_pos.stageUI = text;
                };

                var pixe = new FlxUICheckBox(sUI.x + sUI.width + 25, sUI.y, null, null, "Pixel Stage");
                pixe.checked = false;
                pixe.callback = function()
                {
                    data_pos.isPixelStage = pixe.checked;
                };

                ok.add(new FlxText(10, 10, 0, "Data File Name:"));
                ok.add(new FlxText(directoryInput.x, directoryInput.y - 17, 0, "Stage Directory:"));
                ok.add(new FlxText(sUI.x, sUI.y - 17, 0, "Stage UI:"));
                ok.add(fileInput);
                ok.add(fileButt);
                ok.add(directoryInput);
                ok.add(saveButt);
                ok.add(help);
                ok.add(sUI);
                ok.add(pixe);
        }

        for (items in blockNum) {
            @:privateAccess
			var leText:FlxUIInputText = cast (items.text_field, FlxUIInputText);
            leText.focusGained = function()
            {
                ClientPrefs.toggleVolumeKeys(false);
			    blockInput = true;
            }
            leText.focusLost = function()
            {
                ClientPrefs.toggleVolumeKeys(true);
			    blockInput = false;
            }
        }

        for (items in blockType) {
            items.focusGained = function()
            {
                ClientPrefs.toggleVolumeKeys(false);
                blockInput = true;
            }
            items.focusLost = function()
            {
                ClientPrefs.toggleVolumeKeys(true);
                blockInput = false;
            }
        }

        tab.addGroup(ok);
    }

    function changeSelect(?change:Int = 0)
    {
        curSelected += change;
        if (curSelected < 0) curSelected = stageGrp.length-1;
        if (curSelected > stageGrp.length) curSelected = 0;

        for (i in 0...stageGrp.length)
        {
            stageGrp.members[i].color = FlxColor.WHITE;
            stageGrp.members[i].alpha = 1;
        }
        if (stageGrp.members[curSelected] != null) stageGrp.members[curSelected].color = FlxColor.RED;
    }

    function onSaveComplete(e:Event) {}
    function onSaveCancel(e:Event) {}
    function onSaveError(err:IOErrorEvent)
    {
        trace("Error while saving file.");
        trace("Detailed erroroutput:\n" + err);
        Lib.application.window.alert("Error while saving file!\n" + err, "Error!");
    }
    // this still has a bug...
    function autoSaveFile()
    {
        var date = Date.now();
        var path = currentPath+"/stages/exp/"+date.toString().replace(":", "-") + ".json";
        #if MODS_ALLOWED
        path = Paths.modsJson(currentPath+"/stages/"+date.toString().replace(":", "-"));
        #end
        File.saveContent(path, Json.stringify(data, "\t"));
    }

    function resetStage()
    {
        // make static sprites first
        for (i in 0...data.sprites.length)
        {
            if (data.sprites[i] != null)
            {
                #if MODS_ALLOWED
                var ok = new FlxSprite(data.position[i][0], data.position[i][1]).loadGraphic((!isModFolder ? Paths.image(data.sprites[i]) : Paths.modsImages(path)));
                if (isModFolder) path = Paths.modsImages(data.sprites[i]);
                #else
                var ok = new FlxSprite(data.position[i][0], data.position[i][1]).loadGraphic(Paths.image(data.sprites[i]));
                #end
                ok.antialiasing = data.antialiasing[i];
                if (data.sizes[i][0] != 0 && data.sizes[i][1] != 0)
                {
                    ok.setGraphicSize(data.sizes[i][0], data.sizes[i][1]);
                    ok.updateHitbox();
                }
                ok.scrollFactor.set(data.scroll[i][0], data.scroll[i][1]);
                ok.cameras = [camStage];
                stageGrp.add(ok);
            }
        }

        // second, make the animations.
        for (i in 0...data.anim_frame.length)
        {
            if (data.anim_frame[i] != null)
            {
                var sparrow = new FlxSprite();
                sparrow.frames = Paths.getSparrowAtlas(data.anim_frame[i]);
                for (anim in 0...data.anim_n.length)
                {
                    sparrow.animation.addByPrefix(data.anim_n[curSelected][anim], data.anim_n[curSelected][anim], 24, data.anim_loop[curSelected][anim]);
                }
                sparrow.cameras = [camStage];
                stageGrp.add(sparrow);
            }
        }
    }
}