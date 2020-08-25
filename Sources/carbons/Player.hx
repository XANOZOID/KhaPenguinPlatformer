package carbons;

import js.html.rtc.SignalingState;
import masks.Mask.MaskExtension;
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
	static final jumpSpeed = -6.85;
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
	final sprWallSlide:Sprite;
	var movekey:KeyCode = null;
	var jump = false;
	var xscale = 1;
	var velY = 0.0;
	var externalVelY = 0.0;
	var velX = 0.0;
	var material:Material = Air;
	var _hub:Hub;
	var running = false;
	var spawnX:Float;
	var spawnY:Float;

	var solids(get, never):Masklist;
	inline function get_solids() return _hub.carbons.solids;

	public function new(hub, x, y) {
		_hub = hub;
		sprStand = sprite = Sprites.playerStill();
		sprWalk = Sprites.playerWalk(0.30);
		sprFall = Sprites.playerFall();
		sprJump = Sprites.playerJump();
		sprWallSlide = Sprites.playerWallSlide();
		mask = new Hitbox(cast x - 7, cast y - 8, 14, 11);
		spawnX = x;
		spawnY = y;
		
		hookInput();
	}

	function respawn() {
		velY = 0;
		velX = 0;
		x = spawnX;
		y = spawnY;
	}

	function getMaterial(yOff:Int = 1) {
		var material = vertCollidesAt(0, yOff)? Ground : Air;
		return material;
	}

	function vertCollidesAt(xOff:Float = 0, yOff:Float = 0):Bool {
		x += xOff;
		y += yOff;
		var collided = mask.collide(solids);
		if (!collided) {
			if (velY >= 0 ) {
				final res = MaskExtension.collideEach(mask, _hub.carbons.jumpthroughs);
				if (res != null) {
					if (res.y >= mask.y + mask.height - 1) {
						collided = true;
					}
				}
			}
		}
		x -= xOff;
		y -= yOff;
		return collided;
	}

	function collidesAt(xOff:Float, yOff:Float) {
		x += xOff;
		y += yOff;
		final collided = mask.collide(solids);
		x -= xOff;
		y -= yOff;
		return collided;
	}

	public function isFalling() {
		return velY > 0;
	}

	public function hitSpring() {
		externalVelY = jumpSpeed*0.25;
		velY = jumpSpeed * 1.35;
	}

	function moveVelX() {
		var moveBy = Math.abs(velX);
		var moveDirection = velX.sign();
		while (moveBy > 0) {
			final moveInc = Math.min(1, moveBy);
			final moveIncDir = moveInc * moveDirection;
			final moveIncTest = moveDirection;

			if (!collidesAt(moveIncTest, 0)) {
				x += moveIncDir;
				// We can also walk down slopes . . . 
				if (getMaterial() == Air) {
					if (collidesAt(0, 2)) {
						y += 1;
					}
				}
			}
			else if (!collidesAt(moveIncTest, -1)) {
				if (moveInc >= 1){
					x += moveIncDir;
					y -= 1;
				}
			}
			else if (collidesAt(moveIncTest, 0)) {
				velX = 0;
				x = x.trunc();
				return;			
			}
			moveBy -= 1;
		}
	}

	function moveVelY() {
		if (velY == 0) return;
		final xCheck = x.point();
		final velDir = velY.sign();
		var moveBy = Math.abs(velY);
		while (moveBy > 0) {
			final moveY = Math.min(1, moveBy) * velDir;
			if (!vertCollidesAt(-xCheck, velDir)) {
				y += velDir;
			} 
			else {
				if (velY > 0) { velY = 0; }
				y = y.trunc();
				return;
			}
			moveBy --;
		}
		velY = velY.clamp(-30, 20);
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
		if (Math.abs(velX) < 0.05)
			sprite = sprStand;
		velX -= Math.min(Math.abs(velX), accelX)*(velX.sign()) * friction[getMaterial()];
		moveVelX();
	}

	public function update() {
		switch (movekey) {
			case A:  moveX(-1);
			case D:  moveX(1);
			default: noMove();
		}

		var onFloor = vertCollidesAt(0, 1);
		var huggingWall = false;
		if (!onFloor) {
			huggingWall = (velX.sign() == xscale.sign() || velX == 0 && movekey != null) &&
				collidesAt(xscale*2, 0);
		}
		
		if (jump) {
			if (onFloor && externalVelY >= 0) {
				velY = jumpSpeed * (Math.abs(velX) / (runSpeed*0.55)).clamp(0.7, 1);
				onFloor = false;
			}
			else if (huggingWall && velY >= -0.45) {
				velX = -xscale * 3.75;
				velY = jumpSpeed * 0.735;
				xscale *= -1;
			}
		} 
		else if (!onFloor && velY < 0 && externalVelY >= 0) {
			velY *= 0.675;
		}
		
		if (!onFloor) {
			final activeGrav = huggingWall? gravity * 0.1 : gravity;
			externalVelY += gravity;
			velY += gravity;
			if (huggingWall && velY > 1.5) {
				velY = 0.65;
			}
		}
		moveVelY();

		if (!onFloor) {
			if (velY > 0 ) {
				if (huggingWall)
					sprite = sprWallSlide;
				else
					sprite = sprFall;
			} else {
				sprite = sprJump;
			}
		}

		if (_hub.carbons.deathZones.collideHitbox(mask)) {
			respawn();
		}

		handleCheckpoints();
	}

	function handleCheckpoints() {
		if (mask.collide(_hub.carbons.checkpoints)) {
			final chkpt = _hub.carbons.checkpoints.getCollidingMask(mask);
			final hbox = cast(chkpt, Hitbox);
			_hub.carbons.checkpoints.remove(chkpt);
			spawnX = hbox.x;
			spawnY = hbox.y + hbox.height - mask.height + 8;
		}
	}

	public function draw(g2:Graphics) {
		g2.color = _hub.context.mapColor;
		g2.fillRect(mask.x, mask.y - 1, mask.width + 1, mask.height);
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
					respawn();
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