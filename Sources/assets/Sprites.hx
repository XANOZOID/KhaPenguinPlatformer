package assets;

import kha.Assets;
import graphics.*;

class Sprites {
	static public function playerStill():Sprite 
		return playerSprite(0);
	static public function playerJump():Sprite 
		return playerSprite(4);
	static public function playerFall():Sprite 
		return playerSprite(3);

	static public function playerWalk(speed:Float):Animation return {
		texture: Assets.images.Maps_monochrome_tilemap_transparent,
		frameX: 16 + 1, frameY: 256,
		frameW: 16, frameH: 16,
		originX: 0.5, originY: 0.75,
		separationY: 1,
		separationX: 1,
		frames:  2,
		columns: 2,
		playSpeed: speed
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

	static function playerSprite(cellX):Sprite return {
		texture: Assets.images.Maps_monochrome_tilemap_transparent,
		frameX: cellX * 16 + cellX, frameY: 256,
		frameW: 16, frameH: 16,
		originX: 0.5, originY: 0.75,
	};
}