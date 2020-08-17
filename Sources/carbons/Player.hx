package carbons;

import kha.graphics2.Graphics;
import kha.input.KeyCode;
import kha.input.Keyboard;
import graphics.Sprite;
import masks.*;
import assets.Sprites;
import kha.Color;

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