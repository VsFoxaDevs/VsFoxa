package commands;

import haxe.Json;
import sys.io.File;
import sys.io.Process;
import sys.FileSystem;

class Update {
	public static function main(args:Array<String>) {
		prettyPrint("Preparing installation...");

		// to prevent messing with currently installed libs
		if (!FileSystem.exists('.haxelib'))
			FileSystem.createDirectory('.haxelib');

		// brief explanation: first we parse a json containing the library names, data, and such
		final libs:Array<Library> = Json.parse(File.getContent('./hmm.json')).dependencies;

		// now we loop through the data we currently have
		for (data in libs) {
			// and install the libraries, based on their type
			switch (data.type) {
				case "install", "haxelib": // for libraries only available in the haxe package manager
					var version:String = data.version == null ? "" : data.version;
                    prettyPrint("Installing library...");
					Sys.command('haxelib --quiet install ${data.name} ${version}');
				case "git": // for libraries that contain git repositories
					var ref:String = data.ref == null ? "" : data.ref;
                    prettyPrint("Installing library from GitHub...");
					Sys.command('haxelib --quiet git ${data.name} ${data.url} ${data.ref}');
				default: // and finally, throw an error if the library has no type
					Sys.println('[FOXA ERROR!]: Unable to resolve library of type "${data.type}" for library "${data.name}"');
			}
        }

		var proc = new Process('haxe --version');
		proc.exitCode(true);
		var haxeVer = proc.stdout.readLine();
		if (haxeVer != "4.2.5") {
			// check for outdated haxe
			var curHaxeVer = [for(v in haxeVer.split(".")) Std.parseInt(v)];
			var requiredHaxeVer = [4, 2, 5];
			for(i in 0...requiredHaxeVer.length) {
				if (curHaxeVer[i] < requiredHaxeVer[i]) {
					prettyPrint("!! WARNING !!");
					Sys.println("Your current Haxe version is outdated.");
					Sys.println('You\'re using ${haxeVer}, while the required version is 4.2.5.');
					Sys.println('The engine may not compile with your current version of Haxe.');
					Sys.println('So, we recommend upgrading to 4.2.5.');
					break;
				} else if (curHaxeVer[i] > requiredHaxeVer[i]) {
					prettyPrint("!! WARNING !!"
					+ "\nHaxeFlixel has incompability issues with the latest version of Haxe, 4.3.0 and above, due to macros."
					+ "\nProceeding will cause compilation issues related to macros. (ex: cannot access flash package in macro)");
					Sys.println('');
					Sys.println('We recommend downgrading back to 4.2.5.');
					break;
				}
			}
		}
	}

	public static function prettyPrint(text:String) {
		var header = "══════";
		for(i in 0...(text.length-(text.lastIndexOf("\n")+1)))
			header += "═";
		Sys.println("");
		Sys.println('╔$header╗');
		Sys.println('║   $text   ║');
		Sys.println('╚$header╝');
	}
}