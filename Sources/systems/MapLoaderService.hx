package systems;

import kha.Assets;
import engine.*;

import format.tmx.Data.TmxTile;
import format.tmx.Data.TmxChunk;
import format.tmx.Data.TmxTileLayer;
import format.tmx.Data.TmxLayer;
import format.tmx.Data.TmxMap;
import format.tmx.Data.TmxTileset;
import format.tmx.Reader;
import format.tmx.Data.TmxObjectType;
import format.tmx.Data;


import masks.*;
import graphics.TileLayerRenderer;
import carbons.Player;

class MapLoaderService {
	var tsx:Map<String, TmxTileset>;
	var r:Reader;
	var hub:Hub;

	public function new(hub) {
		this.hub = hub;
		r = new Reader();
		r.resolveTSX = getTSX;
		tsx = new Map();
	}
    
    public function load(mapData) {
		var t:TmxMap = r.read(Xml.parse(mapData));

		for (layer in t.layers) switch (layer) {
			case TmxLayer.LTileLayer(layerTile):
				hub.carbons.tilemapRenderer = 
					new TileLayerRenderer(layerTile, 
					Assets.images.Maps_monochrome_tilemap_transparent);
			case TmxLayer.LObjectGroup(objects):
				if (objects.name == 'solid') {
					for (obj in objects.objects) switch(obj.objectType) {
						case TmxObjectType.OTRectangle:
							hub.carbons.solids.add(new Hitbox(obj.x, obj.y, cast obj.width,cast obj.height));
						default: continue;
					}
				}
			default: continue;
		}
		
		hub.services.spawner.spawnPlayer(100, 100);
    }
    
	function getTSX(name:String):TmxTileset {
		var cached:TmxTileset = tsx.get(name);
		if (cached != null) return cached;
		var tsxData = switch(name) {
			case "tileset.tsx": Assets.blobs.Maps_tileset_tsx.toString();
			case "tset2.tsx": Assets.blobs.Maps_tset2_tsx.toString();
			default: "";
		};
		cached = r.readTSX(Xml.parse(tsxData));
		tsx.set(name, cached);
		return cached;
    }
}