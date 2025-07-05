// File: source/states/editors/AnimationExportState.hx
package states.editors;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.display.BitmapData;
import openfl.utils.ByteArray;
import openfl.display.PNGEncoderOptions;
import openfl.geom.Rectangle;
import openfl.geom.Matrix;
import lime.utils.Assets;
import Character;
import Paths;
import sys.io.File;
import sys.FileSystem;

using StringTools;

class AnimationExportState extends FlxState {
	public var character:String;
	public var charSprite:Character;

	public function new(char:String) {
		character = char;
		super();
	}

	override public function create():Void {
		super.create();

		charSprite = new Character(0, 0, character);
		charSprite.setPosition(300, 200);
		add(charSprite);

		new FlxTimer().start(1, function(_) exportCharacterAnimations());
	}

	function exportCharacterAnimations():Void {
		var basePath:String = 'exported_frames/$character/';
		if (!FileSystem.exists(basePath)) FileSystem.createDirectory(basePath);

		for (animName in charSprite.animation.getNameList()) {
			charSprite.animation.play(animName);
			FlxG.camera.bgColor = FlxColor.TRANSPARENT;
			FlxG.camera.drawFX();

			var animDir = basePath + animName + '/';
			if (!FileSystem.exists(animDir)) FileSystem.createDirectory(animDir);

			for (i in 0...charSprite.animation.curAnim.frames.length) {
				charSprite.animation.curAnim.curFrame = i;
				FlxG.game.stage.invalidate();
				FlxG.game.stage.__render();
				var frame = charSprite.pixels;

				var outputPath = animDir + 'frame' + i + '.png';
				var bytes:ByteArray = frame.encode(frame.rect, new PNGEncoderOptions());
				File.saveBytes(outputPath, bytes);
			}
			// Optionally generate XML or metadata file
			File.saveContent(animDir + animName + '.txt', 'Exported ' + charSprite.animation.curAnim.frames.length + ' frames.');
		}

		FlxG.switchState(new CharacterEditorState());
	}
}
