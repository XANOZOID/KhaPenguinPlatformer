package engine;

import systems.MapLoader;

// Put systems here!
class Systems {
    var _hub:Hub;
    public var loader:MapLoader;
    
    public function new(hub) {
        _hub = hub;
        loader = new MapLoader(hub);
    }
}