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

class TileLayerRenderer {
	var layer:TmxTileLayer;
	var texture:Image;

	public function new(layer, texture) {
		this.layer = layer;
		this.texture = texture;
	}

	public function draw(g2:Graphics) {
		for (chunk in layer.data.chunks) {
			var i = 0;
			for (yy in 0...chunk.height) {
				for (xx in 0...chunk.width) {
					final tile = chunk.tiles[i];
					if (tile.gid != 0) drawTile(g2, chunk, tile, xx, yy);
					i ++;
				}
			}
		}
	}

	inline function drawTile(g2:Graphics, chunk:TmxChunk, tile:TmxTile, tileX:Int, tileY:Int) {
		final shift = 19;
		final shiftX = (tile.gid %  19) - 1;
		final shiftY:Int = Math.floor(tile.gid / shift);
		if (tile.gid == 18) {
			trace(shiftX);
			trace(shiftY);
		}
		g2.drawSubImage(texture,
			(chunk.x + tileX) * 16,
			(chunk.y + tileY) * 16,
			shiftX * 16 + shiftX, 
			shiftY * 16 + shiftY,
			16, 16
		);
	}
}

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

	static function playerSprite(cellX):Sprite return {
		texture: Assets.images.Maps_monochrome_tilemap_transparent,
		frameX: cellX * 16 + cellX, frameY: 256,
		frameW: 16, frameH: 16,
		originX: 0.5, originY: 0.75,
	};
}

class Player {
	static final gravity = 0.3;
	static final jumpSpeed = -4.5;
	static final runSpeed = 2.5;
	static final keyJump = KeyCode.Space;

	var sprite:Sprite;
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var mask:Hitbox;
	final sprWalk:Sprite;
	final sprStand:Sprite;
	final sprFall:Sprite;
	final sprJump:Sprite;

	var movekey:KeyCode = null;
	var jump = false;
	var xscale = 1;
	var velY = 0.0;

	public function new() {
		sprStand = sprite = Sprites.playerStill();
		sprWalk = Sprites.playerWalk(0.05);
		sprFall = Sprites.playerFall();
		sprJump = Sprites.playerJump();
		mask = new Hitbox(cast 100 - 7, cast 100 - 8, 14, 11);
		
		hookInput();
	}

	function hookInput() {
		Keyboard.get(0).notify(
			function onDown(k) {
				if (k == keyJump) {
					jump = true;
					return;
				}

				if (k == KeyCode.R) {
					x = 100;
					y = 100;
				}

				movekey = switch(k) {
					case KeyCode.A: KeyCode.A;
					case KeyCode.D: KeyCode.D;
					default: movekey;
				};
			},
			function onUp(k) {
				if (k == movekey) { movekey = null; }
			}
		);
	}

	public function update(solids:Masklist) {
		switch (movekey) {
			case A:
				x -= runSpeed;
				xscale = -1;
				sprite = sprWalk;
				while (mask.collide(solids))
					x ++;
			case D:
				x += runSpeed;
				xscale = 1;
				sprite = sprWalk;
				while (mask.collide(solids))
					x --;
			default:
				sprite = sprStand;
		}

		y += 1;
		var onFloor = mask.collide(solids);
		y -= 1;

		if (jump) {
			if (onFloor) {
				velY = jumpSpeed;
				onFloor = false;
			}
			jump = false;
		}


		y += Math.floor(velY);
		velY += gravity;
		var falling = velY > 0;
		while (mask.collide(solids)) {
			if (falling) {
				y = Math.floor(y-1);
			} else {
				y = Math.floor(y + 1);
			}
			velY = 0;
		}

		if (!onFloor) {
			if (velY > 0 ) {
				sprite = sprFall;
			} else {
				sprite = sprJump;
			}
		}

	}

	public function draw(g2:Graphics) {
		g2.color = Color.Black;
		g2.fillRect(mask.x, mask.y, mask.width, mask.height);
		g2.color = Color.White;
		sprite.drawScaled(g2, x, y, xscale, 1);
		// g2.drawRect(mask.x, mask.y, mask.width, mask.height);
	}

	function set_x(val:Float):Float {
		mask.x = val - 8;
		return val;
	}
	function get_x() return mask.x + 8;
	function set_y(val:Float):Float {
		mask.y = val - 8;
		return val;
	}
	function get_y() return mask.y + 8;
}

class Main {
	static var tsx:Map<String, TmxTileset>;
	static var r:Reader;
	static var tilemapRenderer:TileLayerRenderer;
	static var player:Player;
	static var solids:Masklist = new Masklist();
	
	static function getTSX(name:String):TmxTileset {
		var cached:TmxTileset = tsx.get(name);
		if (cached != null) return cached;
		var tsxData = switch(name) {
			case "tileset.tsx":Assets.blobs.Maps_tileset_tsx.toString();
			default: "";
		};
		cached = r.readTSX(Xml.parse(tsxData));
		tsx.set(name, cached);
		return cached;
	}

	static function init() {
		r = new Reader();
		r = new Reader();
		r.resolveTSX = getTSX;
		tsx = new Map();
		var mapData = Assets.blobs.Maps_map1_tmx.toString();
		var t:TmxMap = r.read(Xml.parse(mapData));

		for (layer in t.layers) switch (layer) {
			case TmxLayer.LTileLayer(layerTile):
				tilemapRenderer = new TileLayerRenderer(layerTile, Assets.images.Maps_monochrome_tilemap_transparent);
			case TmxLayer.LObjectGroup(objects):
				if (objects.name == 'solid') {
					for (obj in objects.objects) {
						switch(obj.objectType) {
							case TmxObjectType.OTRectangle:
								solids.add(
									new Hitbox(obj.x, obj.y, cast obj.width,cast obj.height)
								);
							default: continue;
						}
					}
				}
			default: continue;
		}

		player = new Player();
	}

	static function update(): Void {
		player.update(cast solids);
	}

	static function render(frames: Array<Framebuffer>): Void {
		final fb = frames[0];
		final g2 = fb.g2;
		final scale = 3.5;

		// g2.begin(true, Color.fromBytes(0, 95, 106));
		g2.begin(true, Color.Black);
		
		g2.pushTransformation(FastMatrix3.scale(scale, scale));
		g2.pushTranslation( 
			Math.floor( (-player.x)*scale + 1024/2), 
			Math.floor( (-player.y)*scale + 768/2)
		);
		
		tilemapRenderer.draw(g2);
		player.draw(g2);

		// for (hb in solids) {
		// 	g2.drawRect(
		// 		hb.x, hb.y, hb.width, hb.height
		// 	);
		// }

		g2.popTransformation();
		g2.popTransformation();
		g2.end();
	}

	public static function main() {
		System.start({title: "Project", width: 1024, height: 768}, function (_) {
			Assets.loadEverything(function () {
				init();
				Scheduler.addTimeTask(function () { update(); }, 0, 1 / 60);
				System.notifyOnFrames(function (frames) { render(frames); });
			});
		});
	}
}
