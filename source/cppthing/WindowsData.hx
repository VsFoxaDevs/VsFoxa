package cppthing;

#if windows
@:buildXml('
<compilerflag value="/DelayLoad:ComCtl32.dll"/>

<target id="haxe">
    <lib name="dwmapi.lib" if="windows" />
    <lib name="shell32.lib" if="windows" />
    <lib name="gdi32.lib" if="windows" />
</target>
')

@:headerCode('
#include <Windows.h>
#include <cstdio>
#include <iostream>
#include <tchar.h>
#include <dwmapi.h>
#include <winuser.h>
#include <Shlobj.h>
#include <wingdi.h>
#include <shellapi.h>
')
#elseif linux
@:headerCode("#include <stdio.h>")
#end
class WindowsData
{
	#if windows
	@:functionCode("
		unsigned long long allocatedRAM = 0;
		GetPhysicallyInstalledSystemMemory(&allocatedRAM);
		return (allocatedRAM / 1024);
	")
	#elseif linux
	@:functionCode('
		FILE *meminfo = fopen("/proc/meminfo", "r");

    	if(meminfo == NULL)
			return -1;

    	char line[256];
    	while(fgets(line, sizeof(line), meminfo))
    	{
        	int ram;
        	if(sscanf(line, "MemTotal: %d kB", &ram) == 1)
        	{
            	fclose(meminfo);
            	return (ram / 1024);
        	}
    	}

    	fclose(meminfo);
    	return -1;
	')
	#end
	public static function obtainRAM()
	{
		return 0;
	}

	// kudos to bing chatgpt thing i hate C++
    #if windows
    @:functionCode('
        HWND hwnd = GetActiveWindow();
        HMENU hmenu = GetSystemMenu(hwnd, FALSE);
        if (enable) {
            EnableMenuItem(hmenu, SC_CLOSE, MF_BYCOMMAND | MF_ENABLED);
        } else {
            EnableMenuItem(hmenu, SC_CLOSE, MF_BYCOMMAND | MF_GRAYED);
        }
    ')
    #end
    public static function setCloseButtonEnabled(enable:Bool) {
        return enable;
    }

	#if windows
	@:functionCode('
        int darkMode = mode;
        HWND window = GetActiveWindow();
        if (S_OK != DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode))) {
            DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode));
        }
        UpdateWindow(window);
    ')
	@:noCompletion
	public static function _setWindowColorMode(mode:Int) {}

	public static function setWindowColorMode(mode:WindowColorMode)
	{
		var darkMode:Int = cast(mode, Int);

		if(darkMode > 1 || darkMode < 0){
			trace("WindowColorMode Not Found...");
			return;
		}

		_setWindowColorMode(darkMode);
	}

	@:functionCode('
	HWND window = GetActiveWindow();
	SetWindowLong(window, GWL_EXSTYLE, GetWindowLong(window, GWL_EXSTYLE) ^ WS_EX_LAYERED);
	')
	@:noCompletion
	public static function _setWindowLayered() {}

	@:functionCode('
        HWND window = GetActiveWindow();

		float a = alpha;

		if (alpha > 1) {
			a = 1;
		} 
		if (alpha < 0) {
			a = 0;
		}

       	SetLayeredWindowAttributes(window, 0, (255 * (a * 100)) / 100, LWA_ALPHA);

    ')
	/**
	 * Set the whole window's opacity
	 * ! MAKE SURE TO CALL CppAPI._setWindowLayered(); BEFORE RUNNING THIS
	 * @param alpha 
	 */
	public static function setWindowAlpha(alpha:Float)
	{
		return alpha;
	}
	#end

    #if windows
    @:functionCode('
        // https://stackoverflow.com/questions/4308503/how-to-enable-visual-styles-without-a-manifest
        // dumbass windows

        TCHAR dir[MAX_PATH];
        ULONG_PTR ulpActivationCookie = FALSE;
        ACTCTX actCtx =
        {
            sizeof(actCtx),
            ACTCTX_FLAG_RESOURCE_NAME_VALID
                | ACTCTX_FLAG_SET_PROCESS_DEFAULT
                | ACTCTX_FLAG_ASSEMBLY_DIRECTORY_VALID,
            TEXT("manifesthelper.dll"), 0, 0, dir, (LPCTSTR)2
        };
        UINT cch = GetCurrentDirectory(sizeof(dir) / sizeof(*dir), (LPSTR) &dir);
        if (cch >= sizeof(dir) / sizeof(*dir)) { return FALSE; /*shouldn\'t happen*/ }
        dir[cch] = TEXT(\'\\0\');
        ActivateActCtx(CreateActCtx(&actCtx), &ulpActivationCookie);
        return ulpActivationCookie;
    ')
    #end
    public static function enableVisualStyles() {
        return false;
    }

    #if windows
    @:functionCode('
    HWND window = GetActiveWindow();
    HICON smallIcon = (HICON) LoadImage(NULL, path, IMAGE_ICON, 16, 16, LR_LOADFROMFILE);
    HICON icon = (HICON) LoadImage(NULL, path, IMAGE_ICON, 0, 0, LR_LOADFROMFILE | LR_DEFAULTSIZE);
    SendMessage(window, WM_SETICON, ICON_SMALL, (LPARAM)smallIcon);
    SendMessage(window, WM_SETICON, ICON_BIG, (LPARAM)icon);
    ')
    #end
    public static function setWindowIcon(path:String) {}
}

@:enum abstract WindowColorMode(Int)
{
	var DARK:WindowColorMode = 1;
	var LIGHT:WindowColorMode = 0;
}