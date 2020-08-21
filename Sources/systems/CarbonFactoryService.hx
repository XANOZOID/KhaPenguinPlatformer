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

    public function spawnSpring(x,y):Spring {
        final spring = new Spring(_hub, x, y);
        _hub.carbons.springs.push(spring);
        return spring;
    }

}