package shaders;

import shaders.ShaderBase.EffectBase;

/*STOLE FROM DAVE AND BAMBI

I LOVE BANUUU I LOVE BANUUU
   ________
  /        \
_/__________\_
 ||  o||  o||
 |//--  --//|
  \____O___/
   |      |
   |______|
   |   |  |
   |___|__|
    
   
   
   ________
__/________\__
  || 0||0 ||
  \____w___/
  _|______|_
   |__||__|
   
   brobgonalll
*/

class GlitchEffect extends EffectBase<GlitchShader>{
    public function new(?distance:Float = 0.0) {
        super(new GlitchShader());
        shader.distance.value = [distance];
    }    
}

class GlitchShader extends ShaderBase {
    @:glFragmentSource('
    #pragma header

    uniform float distance;

    vec4 doGlitch(sampler2D channel, vec2 uv, float d)
    {
        return texture2D(channel, vec2(uv.x + d, uv.y));
    }

    void main()
    {
        vec2 uv = openfl_TextureCoordv;

        gl_FragColor = vec4(
            doGlitch(bitmap, uv, -distance),
            doGlitch(bitmap, uv, 0.0),
            doGlitch(bitmap, uv, distance)
        );
    }')

    public function new(){super();}
}