package assets;

import kha.Assets;
import graphics.*;

class Sprites {
	static public function playerStill():Sprite 
		return playerSprite(0, 0, .79);
	static public function playerJump():Sprite 
		return playerSprite(3, 3);
	static public function playerFall():Sprite 
		return playerSprite(3, 5);
	static public function playerWallSlide():Sprite
		return playerSprite(2, 3);

	static public function playerWalk(speed:Float):Animation return {
		texture: Assets.images.penguin,
		frameX: 0, frameY: 16 * 2,
		frameW: 16, frameH: 16,
		originX: 0.5, originY: 0.79,
		separationY: 0,
		separationX: 0,
		frames:  6,
		columns: 3,
		playSpeed: speed
	};

	static function playerSprite(cellY, cellX, ogY = 0.75):Sprite return {
		texture: Assets.images.penguin,
		frameX: cellX * 16, 
		frameY: cellY * 16,
		frameW: 16, frameH: 16,
		originX: 0.5, originY: ogY,
	};

	static public function obstacleSpring(speed:Float):Animation return {
		texture: Assets.images.Maps_monochrome_tilemap_transparent,
		frameX: 51, frameY: 136,
		frameW: 16, frameH: 16,
		originX: 0.5, originY: 0,
		separationY: 0, separationX: 1,
		frames: 3,
		columns: 3,
		playSpeed: speed
	}
}