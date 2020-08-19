package carbons;

import kha.graphics2.Graphics;
import kha.input.KeyCode;
import kha.input.Keyboard;
import graphics.Sprite;
import masks.*;
import assets.Sprites;
import kha.Color;
import engine.Hub;

using math.Standard;

private enum Material {
	Air;
	Ground;
}

class Player {
	static final gravity = 0.325;
	static final jumpSpeed = -6.45;
	static final runSpeed = 5.9;
	static final keyJump = KeyCode.Space;
	static final weight:Float = 1;
	static final drag:Float = .85;
	static final accelX = 0.5;
	static final acceleration:Map<Material, Float> = [
		Air => 0.55 * weight,
		Ground => 0.8 * weight
	];
	static final friction:Map<Material, Float> = [
		Air => 0.40 * drag,
		Ground => 0.89 * drag
	];

	public var x(get, set):Float;
	public var y(get, set):Float;
	public var mask:Hitbox;
	var sprite:Sprite;
	final sprWalk:Sprite;
	final sprStand:Sprite;
	final sprFall:Sprite;
	final sprJump:Sprite;
	var movekey:KeyCode = null;
	var jump = false;
	var xscale = 1;
	var velY = 0.0;
	var velX = 0.0;
	var material:Material = Air;
	var _hub:Hub;
	var running = false;

	var solids(get, never):Masklist;
	inline function get_solids() return _hub.carbons.solids;

	public function new(hub, x, y) {
		_hub = hub;
		sprStand = sprite = Sprites.playerStill();
		sprWalk = Sprites.playerWalk(0.05);
		sprFall = Sprites.playerFall();
		sprJump = Sprites.playerJump();
		mask = new Hitbox(cast x - 7, cast y - 8, 14, 11);
		
		hookInput();
	}

	function getMaterial(yOff:Int = 1) {
		y += yOff;
		final material = mask.collide(solids)? Ground : Air;
		y -= yOff;
		return material;
	}

	function collidesAt(xOff:Float, yOff:Float) {
		x += xOff;
		y += yOff;
		final collided = mask.collide(solids);
		x -= xOff;
		y -= yOff;
		return collided;
	}

	function moveVelX() {
		var moveBy:Int = Math.floor(Math.abs(velX));
		var moveDirection = velX.sign();
		while (moveBy > 0) {
			final moveInc = Math.min(1, moveBy);
			x += moveInc * moveDirection;
			if (mask.collide(solids)) {
				x -= moveDirection * moveInc;
				velX = 0;
				x = x.trunc();
				return;
			}
			moveBy -= 1;
		}
	}

	function moveVelY() {
		y += Math.floor(velY);
		var falling = velY > 0;
		while (mask.collide(solids)) {
			if (falling) {
				y = Math.floor(y-1);
				velY = 0;
			} else {
				y = Math.floor(y + 1);
			}
		}
	}

	function moveX(direction) {
		var material = getMaterial();
		xscale = direction;
		sprite = sprWalk;
		var accelX = direction * accelX * acceleration[material];
		velX += accelX;
		velX = velX.clamp(-runSpeed, runSpeed);
		moveVelX();
	}

	function noMove() {
		sprite = sprStand;
		velX -= Math.min(Math.abs(velX), accelX)*(velX.sign()) * friction[getMaterial()];
		moveVelX();
	}

	public function update() {
		switch (movekey) {
			case A: moveX(-1);
			case D: moveX(1);
			default: noMove();
		}

		velY += gravity;
		var onFloor = getMaterial() == Ground;
		if (jump) {
			if (onFloor) {
				velY = jumpSpeed * (Math.abs(velX) / (runSpeed*0.55)).clamp(0.7, 1);
				onFloor = false;
			}
		} 
		else if (!onFloor && velY < 0) {
			velY *= 0.675;
		}

		moveVelY();

		if (!onFloor) {
			if (velY > 0 ) {
				sprite = sprFall;
			} else {
				sprite = sprJump;
			}
		}
	}

	public function draw(g2:Graphics) {
		g2.color = _hub.context.mapColor;
		g2.fillRect(mask.x, mask.y, mask.width, mask.height);
		g2.color = Color.White;
		sprite.drawScaled(g2, x, y, xscale, 1);
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
				if (k == keyJump) { jump = false; }
			}
		);
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