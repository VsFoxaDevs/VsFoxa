package flx3d;

import away3d.entities.SegmentSet;
import away3d.cameras.Camera3D;
import away3d.entities.TextureProjector;
import away3d.primitives.SkyBox;
import away3d.lights.LightBase;
import away3d.containers.ObjectContainer3D;
import away3d.library.Asset3DLibraryBundle;
import away3d.events.LoaderEvent;
import away3d.loaders.AssetLoader;
import away3d.loaders.misc.AssetLoaderToken;
import flixel.FlxG;
import flx3d.Flx3DUtil;
import away3d.library.assets.Asset3DType;
import away3d.library.Asset3DLibrary;
import away3d.events.Asset3DEvent;
import away3d.loaders.parsers.*;
import away3d.utils.Cast;
import away3d.materials.TextureMaterial;
import haxe.io.Path;
import away3d.loaders.misc.AssetLoaderContext;
import openfl.Assets;
import away3d.entities.Mesh;
import away3d.loaders.Loader3D;

// FlxView3D with helpers for easier updating

class Flx3DView extends FlxView3D {
    private static var __3DIDS:Int = 0;

    var meshes:Array<Mesh> = [];
    public function new(x:Float = 0, y:Float = 0, width:Int = -1, height:Int = -1) {
        if (!Flx3DUtil.is3DAvailable())
            throw "[Flx3DView] 3D is not available on this platform. Stages in use: " + Flx3DUtil.getTotal3D() + ", Max stages allowed: " + FlxG.stage.stage3Ds.length + ".";
        super(x, y, width, height);
        __cur3DStageID = __3DIDS++;
    }

	public function addModel(assetPath:String, callback:Asset3DEvent->Void, ?texturePath:String, smoothTexture:Bool = true) {

        var model = Assets.getBytes(assetPath);
        if (model == null)
            throw 'Model at ${assetPath} was not found.';

        var context = new AssetLoaderContext();
        var noExt = Path.withoutExtension(assetPath);
        trace(noExt);
        context.mapUrlToData('${Path.withoutDirectory(noExt)}.mtl', '$noExt.mtl');

        var material:TextureMaterial = null;
        if (texturePath != null)
            material = new TextureMaterial(Cast.bitmapTexture(texturePath), smoothTexture);

        return loadData(model, context, switch(Path.extension(assetPath).toLowerCase()) {
            case "dae": new DAEParser();
            case "md2": new MD2Parser();
            case "md5": new MD5MeshParser();
            case "awd": new AWDParser();
            default:    new OBJParser();
        }, (event:Asset3DEvent) -> {
            if (event.asset != null && event.asset.assetType == Asset3DType.MESH) {
                var mesh:Mesh = cast(event.asset, Mesh);
                if (material != null)
                    mesh.material = material;
                meshes.push(mesh);
            }
            callback(event);
        });
	}



    private var __cur3DStageID:Int;
    private var _loaders:Map<Asset3DLibraryBundle, AssetLoaderToken> = [];

    private function loadData(data:Dynamic, context:AssetLoaderContext, parser:ParserBase, onAssetCallback:Asset3DEvent->Void):AssetLoaderToken {
        var token:AssetLoaderToken;

        var lib:Asset3DLibraryBundle;
        lib = Asset3DLibraryBundle.getInstance('Flx3DView-${__cur3DStageID}');
        token = lib.loadData(data, context, null, parser);

        token.addEventListener(Asset3DEvent.ASSET_COMPLETE, (event:Asset3DEvent) -> {
            // ! Taken from Loader3D https://github.com/openfl/away3d/blob/master/away3d/loaders/Loader3D.hx#L207-L232
            if (event.type == Asset3DEvent.ASSET_COMPLETE) {
                var obj:ObjectContainer3D = null;
                switch (event.asset.assetType) {
                    case Asset3DType.LIGHT:
                        obj = #if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end(event.asset, LightBase) ? cast event.asset : null;
                    case Asset3DType.CONTAINER:
                        obj = #if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end(event.asset, ObjectContainer3D) ? cast event.asset : null;
                    case Asset3DType.MESH:
                        obj = #if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end(event.asset, Mesh) ? cast event.asset : null;
                    case Asset3DType.SKYBOX:
                        obj = #if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end(event.asset, SkyBox) ? cast event.asset : null;
                    case Asset3DType.TEXTURE_PROJECTOR:
                        obj = #if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end(event.asset, TextureProjector) ? cast event.asset : null;
                    case Asset3DType.CAMERA:
                        obj = #if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end(event.asset, Camera3D) ? cast event.asset : null;
                    case Asset3DType.SEGMENT_SET:
                        obj = #if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end(event.asset, SegmentSet) ? cast event.asset : null;
                }
                if (obj != null && obj.parent == null)
                    view.scene.addChild(obj);
            }

            if (onAssetCallback != null)
                onAssetCallback(event);
        });

        token.addEventListener(LoaderEvent.RESOURCE_COMPLETE, (_) -> {
            trace("Loader Finished...");

        });

        _loaders.set(lib,token);

        return token;
    }

    override function destroy() {
        if (meshes != null)
            for(mesh in meshes)
                mesh.dispose();

        var bundle = Asset3DLibraryBundle.getInstance('Flx3DView-${__cur3DStageID}');
        bundle.stopAllLoadingSessions();
        @:privateAccess {
            if (bundle._loadingSessions != null) {
                for(load in bundle._loadingSessions) {
                    load.dispose();
                }
            }
            Asset3DLibrary._instances.remove('Flx3DView-${__cur3DStageID}');
        }

        super.destroy();
    }

    public inline function addChild(c)
        view.scene.addChild(c);
}