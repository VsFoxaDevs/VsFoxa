package shaders;

import flixel.system.FlxAssets.FlxShader;

class ShaderBase extends FlxShader{public function new() {super();}}

class EffectBase<T> {
    public var shader(default,null):T;
    public function new(shader:T) {this.shader = shader;}
}