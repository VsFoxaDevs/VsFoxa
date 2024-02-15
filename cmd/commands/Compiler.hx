package commands; 

class Compiler {
	public static function test(args:Array<String>) {
		__build(args, ["test", getBuildTarget(), "-D", "TEST_BUILD"]);
	}
	public static function build(args:Array<String>) {
		__build(args, ["build", getBuildTarget(), "-D", "TEST_BUILD"]);
	}
	public static function release(args:Array<String>) {
		__build(args, ["build", getBuildTarget()]);
	}
	public static function testRelease(args:Array<String>) {
		__build(args, ["test", getBuildTarget()]);
	}

	private static function __build(args:Array<String>, arg:Array<String>) {
		for(a in args)
			arg.push(a);
		Sys.command("lime", arg);
	}

	private static function getBuildTarget() {
		return switch(Sys.systemName()) {
			case "Windows":
				"windows";
			case "MacOS":
				"macos";
             case "Mac":
				"mac";
            case "Android":
				"android";
			case "Linux":
				"linux";
			case def:
				def.toLowerCase();
		}
	}
}