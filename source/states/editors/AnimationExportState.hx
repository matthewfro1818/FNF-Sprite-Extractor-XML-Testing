package states.editors;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
import openfl.display.PNGEncoderOptions;
import sys.io.File;
import sys.FileSystem;

class AnimationExportState extends FlxState {
    public var character:String;
    public var charSprite:FlxSprite;

    public function new(char:String) {
        character = char;
        super();
    }

    override public function create():Void {
        super.create();

        charSprite = new FlxSprite(0, 0);
        charSprite.frames = Paths.getSparrowAtlas('characters/' + character);
        charSprite.animation.addByPrefix('idle', 'BF idle dance', 24, true); // fallback if needed
        charSprite.animation.play('idle');
        add(charSprite);

        new FlxTimer().start(1, function(_) exportCharacterAnimations());
    }

    function exportCharacterAnimations():Void {
        var basePath = 'exported_frames/$character/';
        if (!FileSystem.exists(basePath)) FileSystem.createDirectory(basePath);

        for (animName in charSprite.animation.getNameList()) {
            charSprite.animation.play(animName);
            var animDir = basePath + animName + '/';
            if (!FileSystem.exists(animDir)) FileSystem.createDirectory(animDir);

            for (i in 0...charSprite.animation.curAnim.frames.length) {
                charSprite.animation.curAnim.curFrame = i;

                // Render to BitmapData
                var bmpData = new BitmapData(Math.ceil(charSprite.width), Math.ceil(charSprite.height), true, 0x00000000);
                var mtx = new Matrix();
                mtx.translate(-charSprite.offset.x, -charSprite.offset.y);
                mtx.translate(charSprite.x, charSprite.y);
                bmpData.draw(FlxG.game, mtx);

                // Save PNG
                var path = animDir + 'frame$i.png';
                var bytes:ByteArray = bmpData.encode(bmpData.rect, new PNGEncoderOptions());
                File.saveBytes(path, bytes);
            }

            File.saveContent(animDir + animName + '.txt', 'Exported ' + charSprite.animation.curAnim.frames.length + ' frames.');
        }

        FlxG.switchState(new CharacterEditorState());
    }
}
