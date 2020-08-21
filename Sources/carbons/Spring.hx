package carbons;

import graphics.Animation;
import engine.Hub;
import assets.Sprites;
import masks.Hitbox;

class Spring {
    public var mask:Hitbox;
    var _sprite:Animation;
    var _hub:Hub;

    var player(get, never):Player;
    function get_player() return _hub.carbons.player;

    public function new(hub:Hub, x:Float, y:Float) {
        this.mask = new Hitbox(x, y + 10, 16, 8);
        _sprite = Sprites.obstacleSpring(0);
        _hub = hub;
        _sprite.onAnimationEnd = onSpringEndAnimation;
    }

    public function update() {
        if (mask.collideHitbox(player.mask)) {
            player.hitSpring();
            _sprite.playSpeed = 0.23;
        }
    }

    function onSpringEndAnimation(anim:Animation) {
        anim.playSpeed = 0;
    }

    public function draw(g2) {
        _sprite.draw(g2, mask.x + 8, mask.y - 10);
    }
}