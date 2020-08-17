package;

import masks.Hitbox;
import masks.Mask;
import masks.Masklist;

import format.tmx.Data.TmxObjectType;
import kha.Canvas;
import kha.Display;
import js.html.KeyframeEffect;
import kha.input.Keyboard;
// import kha.input.Mouse;
import kha.math.FastMatrix3;
import kha.Image;
import kha.graphics2.Graphics;
import kha.Assets;
import kha.Color;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.input.KeyCode;

import format.tmx.Data.TmxTile;
import format.tmx.Data.TmxChunk;
import format.tmx.Data.TmxTileLayer;
import format.tmx.Data.TmxLayer;
import format.tmx.Data.TmxMap;
import format.tmx.Data.TmxTileset;
import format.tmx.Reader;


@:structInit class Sprite {
	public final texture:Image;
	public final frameX:Int;
	public final frameY:Int;
	public final frameW:Int;
	public final frameH:Int;
	public final originX:Float;
	public final originY:Float;
	
	public function new(texture, frameX, frameY, frameW, frameH, originX:Float, originY:Float) {
		this.texture = texture;
		this.frameX = frameX;
		this.frameY = frameY;
		this.frameW = frameW;
		this.frameH = frameH;
		this.originX = originX * frameW;
		this.originY = originY * frameH;
	}

	public function draw(g2:Graphics, x:Float, y:Float) {
		g2.drawSubImage(texture, 
			x - originX, y - originY, 
			frameX, frameY, frameW, frameH);
	}

	public function drawScaled(g2:Graphics, x:Float, y:Float, scaleX:Float, scaleY:Float) {
		g2.drawScaledSubImage(
			texture, frameX, frameY, frameW, frameH,
			x - originX * scaleX, y - originY * scaleY, 
			frameW * scaleX, frameH * scaleY
		);
	}
}

@:structInit class Animation extends Sprite {
	public final frames:Int;
	public final columns:Int;
	public final separationX:Int;
	public final separationY:Int;
	public var playSpeed:Float;
	public var currentFrame:Float;
	public function new(texture, frameX, frameY, frameW, frameH, frames, originX:Float, originY:Float, columns, separationX, separationY, playSpeed) {
		super(texture, frameX, frameY, frameW, frameH, originX, originY);
		this.frames = frames;
		this.columns = columns;
		this.playSpeed = playSpeed;
		this.separationX = separationX;
		this.separationY = separationY;
	}

	override public function draw(g2:Graphics, x:Float, y:Float) {
		animate((drawFrame, xOff, yOff) -> {
			g2.drawSubImage(texture, x - originX, y - originY, 
				frameX + (frameW * xOff) + separationX * xOff, 
				frameY + (frameH * yOff) + separationY * yOff, 
				frameW, 
				frameH
			);
		});
	}
	
	override public function drawScaled(g2:Graphics, x:Float, y:Float, scaleX:Float, scaleY:Float) {
		animate((drawFrame, xOff, yOff) -> {
			g2.drawScaledSubImage(texture,
				frameX + (frameW * xOff) + separationX * xOff, 
				frameY + (frameH * yOff) + separationY * yOff, 
				frameW,
				frameH,
				x - originX * scaleX, y - originY * scaleY,
				frameW * scaleX,
				frameH * scaleY
			);
		});
	}

	inline function animate(draw:(Int, Int, Int)->Void) {
		final drawFrame = Math.floor(currentFrame);
		final xOff = drawFrame % columns;
		final yOff = Math.floor(drawFrame / columns);
		draw(drawFrame, xOff, yOff);
		currentFrame += playSpeed;
		if (currentFrame > frames) currentFrame -= frames;
	}
}
class Main {
	static var logo = ["1 1 1 1 111", "11  111 111", "1 1 1 1 1 1"];

	static function update(): Void {
	}

	static function render(frames: Array<Framebuffer>): Void {
		// As we are using only 1 window, grab the first framebuffer
		final fb = frames[0];
		// Now get the `g2` graphics object so we can draw
		final g2 = fb.g2;
		// Start drawing, and clear the framebuffer to `petrol`
		g2.begin(true, Color.fromBytes(0, 95, 106));
		// Offset all following drawing operations from the top-left a bit
		g2.pushTranslation(64, 64);
		// Fill the following rects with red
		g2.color = Color.Red;

		// Loop over the logo (Array<String>) and draw a rect for each "1"
		for (rowIndex in 0...logo.length) {
		  final row = logo[rowIndex];

		  for (colIndex in 0...row.length) {
		    switch row.charAt(colIndex) {
		      case "1": g2.fillRect(colIndex * 16, rowIndex * 16, 16, 16);
		      case _:
		    }
		  }
		}

		// Pop the pushed translation so it will not accumulate over multiple frames
		g2.popTransformation();
		// Finish the drawing operations
		g2.end();
	}

	public static function main() {
		System.start({title: "Project", width: 1024, height: 768}, function (_) {
			// Just loading everything is ok for small projects
			Assets.loadEverything(function () {
				// Avoid passing update/render directly,
				// so replacing them via code injection works
				Scheduler.addTimeTask(function () { update(); }, 0, 1 / 60);
				System.notifyOnFrames(function (frames) { render(frames); });
			});
		});
	}
}
