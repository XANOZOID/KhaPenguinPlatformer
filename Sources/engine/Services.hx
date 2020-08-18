package engine;

import systems.*;

// Put services in here!
class Services {
    var _hub:Hub;
    public var loader:MapLoaderService;
    public var spawner:CarbonFactoryService;
    
    public function new(hub) {
        _hub = hub;
        loader = new MapLoaderService(hub);
        spawner = new CarbonFactoryService(hub);
    }
}