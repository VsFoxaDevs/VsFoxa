package states.stages;

import backend.StageAssets;
import states.stages.objects.*;

/**
* usage) `new CustomStage(stageFile);`
*/
class CustomStage extends BaseStage {
    private var data:StageAssets = StageAsset.makeStageAsset();
    public function new(stageFile:StageAssets){
        super();

        this.data = stageFile;
    }

    override function create()
    {
        for (i in 0...data.sprites.length){
            if(data.sprites[i] != null){
                var spr:BGSprite = new BGSprite(data.sprites[i], data.position[i][0], data.position[i][1], data.scroll[i][0], data.scroll[i][1]);
                spr.setGraphicSize(data.sizes[i][0], data.sizes[i][1]);
                spr.updateHitbox();
                add(spr);
            }
        }

        for (i in 0...data.anim_frame.length){
            if(data.anim_frame[i] != null){
                var anim = new BGSprite(data.anim_frame[i], data.position[i][0], data.position[i][1], data.scroll[i][0], data.scroll[i][1], data.anim_n[i], data.anim_loop[i]);
                anim.setGraphicSize(data.sizes[i][0], data.sizes[i][1]);
                anim.updateHitbox();
                add(anim);
            }
        }

        super.create();
    }
}