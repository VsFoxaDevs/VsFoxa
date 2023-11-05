import states.PlayState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import objects.StrumNote;

var isPixel = false;
var settings = [

    "enablePlayer" => true, // Enables the effect on PlayerStrums
    "enableOpponent" => true, // Enables the effect on OpoonentStrums
    "offsets" => [
        "NOTE_assets" => [0, 0],
        "NOTE_assets-pixel" => [0, 0]
    ],
    "sicksOnly" => true, // if rating = "sick" then it will work (doesn't effect opponent)
    "highlight" => false, // Will only do the highlight, if true then will do the scale
    "unholy" => false // brightness increases (only for highlight)
    "speed" => 0.15, // Speed of tween
    "ease" => FlxEase.quadOut // Ease of Tween
];
function onCreatePost() isPixel = PlayState.stageUI == "pixel";
function goodNoteHit (note) {
    var rating = !settings.get("sicksOnly") ? "sick" : note.rating;
    if (!note.isSustainNote && settings.get("enablePlayer") && rating == "sick") {
        createNoteEffect(note, game.playerStrums.members[note.noteData]);
    }
}
function opponentNoteHit (note) {
    if (!note.isSustainNote && settings.get("enableOpponent")) {
        createNoteEffect(note, game.opponentStrums.members[note.noteData]);
    }
}function createNoteEffect (note, strum) {
    //var suffix = game.isPixelStage;
    var ef = new StrumNote(strum.x, strum.y, strum.noteData, note.mustPress ? 1 : 0);
    var animOffset = settings.get("offsets").exists(ef.texture + (isPixel ? "-pixel" : "")) ? settings.get("offsets").get(ef.texture + (isPixel ? "-pixel" : "")) : [0, 0];
    add(ef);
    ef.reloadNote();
    ef.rgbShader.r = strum.rgbShader.r;
    ef.rgbShader.g = strum.rgbShader.g;
    ef.rgbShader.b = strum.rgbShader.b;
    ef.alpha -= 0.3;
    ef.playAnim("confirm", true);
    ef.offset.set(ef.offset.x + animOffset[0], ef.offset.y + animOffset[1]);
    ef.cameras = [game.camHUD];
    if (!settings.get("highlight")) {
        ef.scale.set(strum.scale.x / 1.5, strum.scale.y / 1.5);
        ef.updateHitbox();
        FlxTween.tween(ef.scale, {x: strum.scale.x + 0.1, y: strum.scale.y + 0.1}, settings.get("speed") / game.playbackRate - 0.01, {ease: settings.get("ease")});
    } else
        if (settings.get("unholy")) ef.blend = 0;
    FlxTween.tween(ef, {alpha: 0}, settings.get("speed") / game.playbackRate + 0.1, {ease: settings.get("ease"), startDelay: 0.1, onComplete: function (twn) {
        ef.destroy();
    }});
}