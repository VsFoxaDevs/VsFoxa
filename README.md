# Friday Night Funkin' - Vs. Foxa / Alleyway Engine
Not a Psych fork again...

(I would appericate if you do a PR on like uh


![](https://github.com/ShadowMario/FNF-PsychEngine/blob/main/docs/img/ohno.PNG?raw=true
this, I don't have time to do it now, maybe tomorrow, but right now i'd like a bit of help to get this actually working, it would be a good idea for me :D )

Yeah, Alleyway Engine, your average Psych fork, but sometimes, it's that and not a fork at the same time, to us, it's such an experience to get this worked on, and like I said, a lot of help would get me appericated as much as you would, oh and the engine was, right now, specifically designed for Vs. Foxa (OG & SE), so when you want to make your own mod using this engine, some major changes at least may be required for. Anyways, see you there when it's finally done!

## Story
You and your girlfriend go down an alleyway, searching for the famous "Whitmore". However, a pink fox blocks your way! She seems to be trying to protect someone... And she does not want you to rap battle him! Sing 5 or more songs with her, maybe even a 6th one too? 

## Random notice
![](https://cdn.discordapp.com/attachments/1110759814256148512/1175503013083873471/image.png)

## License Summary

### Permitted Actions

You are permitted to perform the following actions:

- Download and install/play this modification.

### Required Actions

You must obtain permission to perform the following actions:

- Redistribute the unmodified engine on a website other than GameBanana, GameJolt, or GitHub.
- Use parts of this modification in another engine or mod and provide credit. (Though, there are things I just took from other engines so you may have to credit for those too.)

### Permitted Actions with Conditions

You are permitted to perform the following actions under the following conditions:

- Modify this engine and redistribute the modified engine on GameBanana, GameJolt, or GitHub, provided that you offer the same rights to others.

### Prohibited Actions

You are not allowed to perform the following actions under any circumstances:

- Use this modification or parts of this modification for commercial purposes.
- Use parts of this modification in another engine or mod without providing credit.
- Publicly distribute malicious or potentially harmful scripts that utilize this engine. 

### Additional Conditions

You agree to the following additional conditions:

- You will not modify this modification in any way that violates the license agreement.
- You will not distribute any modified versions of this mod that do not comply with the terms of this license agreement.

This license agreement is subject to change at any time, and continued use of the mod constitutes acceptance of any such changes.

***REMEMBER*: This is a *mod*. This is not the vanilla game and should be treated as a *modification*. This is not and probably will never be official, so don't get confused.**

*Do not look at the MainMenuState file, worst mistake of my life.*

Oh and right now, HTML5 ports may not work, we are not responible for them, nor do we maintain them at all.

Anyway, back to the original Psych README...

# Friday Night Funkin' - Psych Engine
Engine originally used on [Mind Games Mod](https://gamebanana.com/mods/301107), intended to be a fix for the vanilla version's many issues while keeping the casual play aspect of it. Also aiming to be an easier alternative to newbie coders.

## Installation:'

You must have [Haxe 4.2.5](https://haxe.org/download/), installed in order to move on to these next steps.

------------------

Go into your `setup` folder located in the root directory of the source code, and execute the respective script for your operating system.

`setup-unix.sh` was designed for Linux and Mac, `setup-windows.bat` was designed for (duh) Windows

For Windows users, double click the `setup-windows.bat` file, and wait until the process of installing the libraries is finished.

------------------

For Linux and Mac users, often double clicking on `setup-unix.sh` is the solution, but if not, open up a terminal on the script's folder location, and execute the following command:

`sh setup-unix.sh`

------------------


# Compiling the Mod

Now that you finished setting this up, you're now ready to compile the mod!

## Desktop Building:

Desktop building can be a bit tedious. Each different version requires a different setup.

### Linux/Mac Building:

1. Open your machine's command prompt/terminal and navigate to your root folder of the mod. [An easy guide can be found here!](https://ninjamuffin99.newgrounds.com/news/post/1090480)
2. Type `lime build mac` to build the Mac version of the mod.
3. Type `lime run mac` to run the Mac version of the mod from the command prompt/terminal. (You can also run the mod from `funkin/export/release/mac/bin`)

For Linux users, replace `mac` with `linux`.

### Windows Building:
1. Install [Visual Studio Community](https://visualstudio.microsoft.com/downloads/).
2. Open the installer and go to the individual workloads tab and download the following:
```
* C++ CMake tools for windows 
* C++ Profiling tools 
* C++ ATL for v142 build tools (x86 & x64)
* C++ MFC for v142 build tools (x86 & x64)
* C++/CLI support for v142 build tools (14.21)
* C++ Modules for v142 build tools (x64/x86)
* Clang Compiler for Windows
* MSVC v140 - VS 2015 C++ build tools (v14.00) 
* MSVC v141 - VS 2017 C++ x64/x86 build tools
* MSVC v142 - VS 2019 C++ x64/x86 build tools
* Windows 10 SDK (10.0.16299.0)
* Windows 10 SDK (10.0.17134.0)
* Windows SDK (10.0.17763.0)
```
3. Wait for the install to finish, which might take a while, this shit is 22 gigabytes so you gotta save some space if you need to.
4. Open your machine's command prompt/terminal and navigate to your root folder of the mod. [An easy guide can be found here!](https://ninjamuffin99.newgrounds.com/news/post/1090480)
5. Once everything is installed, type `lime build windows` to build the Windows version of the mod.
6. Type `lime run windows` after the mod is compiled to run the Windows version of the mod. (You can also run the mod from `funkin/export/release/windows/bin`, or type `test` instead of `build`.)

If you want to just play the mod and not compile, just use the action builds (either through just Github's Actions tab, which requires a Github account, or use nightly.link).

## Customization:

if you wish to disable things like *Lua Scripts* or *Video Cutscenes*, you can read over to `Project.xml`

inside `Project.xml`, you will find several variables to customize Vs. Foxa / Alleyway Engine to your liking

to start you off, disabling Videos should be simple, simply Delete the line `"VIDEOS_ALLOWED"` or comment it out by wrapping the line in XML-like comments, like this `<!-- YOUR_LINE_HERE -->`

same goes for *Lua & Haxe Scripts*, comment out or delete the line with `LUA_ALLOWED` and `HSCRIPT_ALLOWED`, this and other customization options are all available within the `Project.xml` file

## Credits:
* Shadow Mario - Programmer
* RiverOaken - Artist

### Special Thanks
* bbpanzu - Ex-Programmer
* Yoshubs - Ex-Programmer, we don't support them anymore.
* SqirraRNG - Crash Handler and Base code for Chart Editor's Waveform
* KadeDev - Fixed some cool stuff on Chart Editor and other PRs
* iFlicky - Composer of Psync and Tea Time, also made the Dialogue Sounds
* Keoiki - Note Splash Animations
* Smokey - Sprite Atlas Support
* SuperPowers04 - LUA JIT Fork and some Lua reworks
_____________________________________

# Features

## Attractive animated dialogue boxes:
(They were planned for the vanilla version once but was scrapped, by the way.)
![](https://user-images.githubusercontent.com/44785097/127706669-71cd5cdb-5c2a-4ecc-871b-98a276ae8070.gif)

## Mod Support
* Probably one of the main points of this engine, you can code in .lua files outside of the source code, making your own weeks without even messing with the source!
* Comes with a Mod Organizing/Disabling Menu.

## Atleast one change to every week (less Week 7):
### Week 1:
  * New Dad Left sing sprite
  * Unused stage lights are now used
  * Dad Battle has a spotlight effect for the breakdown
### Week 2:
  * Both BF and Skid & Pump do "Hey!" animations
  * Thunders does a quick light flash and zooms the camera in slightly
  * Added a quick transition/cutscene to Monster
### Week 3:
  * BF does "Hey!" during Philly Nice + that one part glows!
### Week 4:
  * Better hair physics for Mom/Boyfriend (Maybe even slightly better than Week 7's :eyes:)
  * Henchmen die during all songs. Yeah :(
### Week 5:
  * Bottom Boppers and GF does "Hey!" animations during Cocoa and Eggnog
  * On Winter Horrorland, GF bops her head slower in some parts of the song.
### Week 6:
  * On Thorns, the HUD is hidden during the cutscene
  * Also there's the Background girls being spooky during the "Hey!" parts of the Instrumental

## Cool new Chart Editor changes and countless bug fixes
![](https://github.com/ShadowMario/FNF-PsychEngine/blob/main/docs/img/chart.png?raw=true)
* You can now chart "Event" notes, which are bookmarks that trigger specific actions that usually were hardcoded on the vanilla version of the game.
* Your song's BPM can now have decimal values (Like in vanilla Week 7)
* You can manually adjust a Note's strum time if you're really going for milisecond precision
* You can change a note's type on the Editor, it comes with five example types:
  * Alt Animation: Forces an alt animation to play, useful for songs like Ugh/Stress
  * Hey: Forces a "Hey" animation instead of the base Sing animation, if Boyfriend hits this note, Girlfriend will do a "Hey!" too.
  * Hurt Notes: If Boyfriend hits this note, he plays a miss animation and loses some health.
  * GF Sing: Rather than the character hitting the note and singing, Girlfriend sings instead.
  * No Animation: Character just hits the note, no animation plays.

## Multiple editors to assist you in making your own Mod
![Screenshot_3](https://user-images.githubusercontent.com/44785097/144629914-1fe55999-2f18-4cc1-bc70-afe616d74ae5.png)
* Working both for Source code modding and Downloaded builds!

### Built-in script editor
* You can now create or edit your Lua/HScript scripts inside the Chart Editor and Character Editor.

## Story mode menu rework:
![](https://i.imgur.com/UB2EKpV.png)
* Added a different BG to every song (less Tutorial)
* All menu characters are now in individual spritesheets, makes modding it easier.

## Credits menu
![Screenshot_1](https://user-images.githubusercontent.com/44785097/144632635-f263fb22-b879-4d6b-96d6-865e9562b907.png)
* You can add a head icon, name, description and a Redirect link for when the player presses Enter while the item is currently selected.

## Awards/Achievements
* The engine comes with 16 example achievements that you can mess with and learn how it works (Check Achievements.hx and search for "checkForAchievement" on PlayState.hx).
* Supports custom awards without the need of using source code!

## Options menu:
* You can change Note colors, Rating & Audio Offset, Controls and Preferences there.
* On Preferences, you can toggle Downscroll, Middlescroll, Anti-Aliasing, Framerate, Low Quality, Note Splashes, Flashing Lights, etc.

## Other gameplay features:
* When the enemy hits a note, their strum note also glows. (Like in Vanilla Week 7!)
* Lag doesn't impact the camera movement and player icon scaling anymore.
* Some stuff based on Week 7's changes has been put in (Background colors on Freeplay, Note splashes)
* You can reset your Score on Freeplay/Story Mode by pressing Reset button.
* You can listen to a song by pressing Space or adjust Scroll Speed/Damage taken/etc. on Freeplay by pressing Control.
* You can enable "Combo Stacking" in Gameplay Options. This causes the combo sprites to just be one sprite with an animation rather than sprites spawning each note hit.
