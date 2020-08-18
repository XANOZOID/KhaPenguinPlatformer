package engine;

import carbons.Player;
import kha.graphics2.Graphics;
import kha.math.FastMatrix3;
import kha.Color;

final class Hub {
    public var context(default, null):HubContext;
    public var services(default, null):Services;
    public var systems(default, null):Systems;
    public var carbons(default, null):Carbons;

    var player(get, set):Player;
    function get_player() return carbons.player;
    function set_player(player) return carbons.player = player;

    public function new() {
        context = new HubContext();
        carbons = new Carbons();
        services = new Services(this);
        systems = new Systems(this);
    }

    /// Listeners
    public function onInit() {
        inline evInit();
    }

    public function onUpdate() {
        inline evUpdate();
    }

    public function onDraw(g2:Graphics) {
        inline evDraw(g2);
    }

    /// Events
    public function evInit() {

    }

    public function evUpdate() {

        player.update();
        
    }

    public function evDraw(g2:Graphics) {
        final scale = 3.5;
		g2.begin(true, Color.Black);
		
		g2.pushTransformation(FastMatrix3.scale(scale, scale));
		g2.pushTranslation( 
			Math.floor( (-player.x)*scale + 1024/2), 
			Math.floor( (-player.y)*scale + 768/2)
		);
		
		carbons.tilemapRenderer.draw(g2);
		player.draw(g2);

		g2.popTransformation();
		g2.popTransformation();
		g2.end();
    }
}