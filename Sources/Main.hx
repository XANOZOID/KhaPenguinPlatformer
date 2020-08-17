package;

import masks.Hitbox;
import masks.Mask;
import masks.Masklist;

import format.tmx.Data.TmxObjectType;
import kha.Canvas;
import kha.Display;
import js.html.KeyframeEffect;
import kha.input.Keyboard;
import kha.math.FastMatrix3;
import kha.Image;
import kha.graphics2.Graphics;
import kha.Assets;
import kha.Color;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.input.KeyCode;

import carbons.Player;
import graphics.TileLayerRenderer;

import format.tmx.Data.TmxTile;
import format.tmx.Data.TmxChunk;
import format.tmx.Data.TmxTileLayer;
import format.tmx.Data.TmxLayer;
import format.tmx.Data.TmxMap;
import format.tmx.Data.TmxTileset;
import format.tmx.Reader;

class Main {
	static var tsx:Map<String, TmxTileset>;
	static var r:Reader;
	static var tilemapRenderer:TileLayerRenderer;
	static var player:Player;
	static var solids:Masklist = new Masklist();
	
	static function getTSX(name:String):TmxTileset {
		var cached:TmxTileset = tsx.get(name);
		if (cached != null) return cached;
		var tsxData = switch(name) {
			case "tileset.tsx":Assets.blobs.Maps_tileset_tsx.toString();
			case "tset2.tsx":Assets.blobs.Maps_tset2_tsx.toString();
			default: "";
		};
		cached = r.readTSX(Xml.parse(tsxData));
		tsx.set(name, cached);
		return cached;
	}

	static function init() {
		r = new Reader();
		r = new Reader();
		r.resolveTSX = getTSX;
		tsx = new Map();
		var mapData = Assets.blobs.Maps_map1_tmx.toString();
		var t:TmxMap = r.read(Xml.parse(mapData));

		for (layer in t.layers) switch (layer) {
			case TmxLayer.LTileLayer(layerTile):
				tilemapRenderer = new TileLayerRenderer(layerTile, Assets.images.Maps_monochrome_tilemap_transparent);
			case TmxLayer.LObjectGroup(objects):
				if (objects.name == 'solid') {
					for (obj in objects.objects) {
						switch(obj.objectType) {
							case TmxObjectType.OTRectangle:
								solids.add(
									new Hitbox(obj.x, obj.y, cast obj.width,cast obj.height)
								);
							default: continue;
						}
					}
				}
			default: continue;
		}

		player = new Player();
	}

	static function update(): Void {
		player.update(cast solids);
	}

	static function render(frames: Array<Framebuffer>): Void {
		final fb = frames[0];
		final g2 = fb.g2;
		final scale = 3.5;

		// g2.begin(true, Color.fromBytes(0, 95, 106));
		g2.begin(true, Color.Black);
		
		g2.pushTransformation(FastMatrix3.scale(scale, scale));
		g2.pushTranslation( 
			Math.floor( (-player.x)*scale + 1024/2), 
			Math.floor( (-player.y)*scale + 768/2)
		);
		
		tilemapRenderer.draw(g2);
		player.draw(g2);

		// for (hb in solids) {
		// 	g2.drawRect(
		// 		hb.x, hb.y, hb.width, hb.height
		// 	);
		// }

		g2.popTransformation();
		g2.popTransformation();
		g2.end();
	}

	public static function main() {
		System.start({title: "Project", width: 1024, height: 768}, function (_) {
			Assets.loadEverything(function () {
				init();
				Scheduler.addTimeTask(function () { update(); }, 0, 1 / 60);
				System.notifyOnFrames(function (frames) { render(frames); });
			});
		});
	}
}
