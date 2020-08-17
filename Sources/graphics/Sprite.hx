package graphics;

import kha.Image;
import kha.graphics2.Graphics;

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