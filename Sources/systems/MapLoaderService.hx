package systems;

import math.Vector2;
import masks.Polygon;
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
import kha.Color;

import masks.*;
import carbons.*;
import graphics.TileLayerRenderer;

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
				loadObjectGroup(objects);
			default: continue;
		}

		hub.context.mapColor = Color.fromString(t.backgroundColorHex);
	}
	
	function loadObjectGroup(group:TmxObjectGroup) {
		switch (group.name) {
			case 'solid': loadSolids(group);
			case 'death': loadDeathZones(group);
			case 'jump_through': loadJumpthroughs(group);
			case 'special_obstacles': loadSpecial(group);
		}
	}

	function loadJumpthroughs(group:TmxObjectGroup) {
		for (obj in group.objects) switch(obj.objectType) {
			case TmxObjectType.OTRectangle:
				hub.carbons.jumpthroughs.push(new Hitbox(obj.x, obj.y, cast obj.width,cast obj.height));
			default: continue;
		}
	}
	
	function loadSolids(group:TmxObjectGroup) {
		for (obj in group.objects) switch(obj.objectType) {
			case TmxObjectType.OTRectangle:
				hub.carbons.solids.add(new Hitbox(obj.x, obj.y, cast obj.width,cast obj.height));
			case TmxObjectType.OTPolygon(points):
				var polygon = new Polygon(points.map(t -> new Vector2(t.x + obj.x, t.y + obj.y + 1)));
				hub.carbons.solids.add(polygon);
				hub.carbons.polygons.push(polygon);
			default: continue;
		}
	}
	
	function loadDeathZones(group:TmxObjectGroup) {
		for (obj in group.objects) switch(obj.objectType) {
			case TmxObjectType.OTRectangle:
				hub.carbons.deathZones.add(new Hitbox(obj.x, obj.y, cast obj.width,cast obj.height));
			default: continue;
		}
	}

	function loadSpecial(group:TmxObjectGroup) {
		for (obj in group.objects) switch(obj.type) {
			case "Spring": 
				hub.services.spawner.spawnSpring(obj.x, obj.y);
			case 'Checkpoint':
				hub.carbons.checkpoints.add(new Hitbox(obj.x, obj.y, cast obj.width,cast obj.height));
			default: 
				if (obj.name == 'player_start') {
					hub.services.spawner.spawnPlayer(cast obj.x, cast obj.y);
				}
		}
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