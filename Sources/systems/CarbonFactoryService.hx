package systems;

import engine.Hub;
import carbons.*;

class CarbonFactoryService {
    var _hub:Hub;

    public function new(hub) {
        _hub = hub;
    }

    public function spawnPlayer(x,y):Player {
        return _hub.carbons.player = new Player(_hub, x, y);
    }

}