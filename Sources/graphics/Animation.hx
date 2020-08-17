package graphics;

import kha.Image;
import kha.graphics2.Graphics;

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