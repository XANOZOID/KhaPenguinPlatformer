package graphics;

import format.tmx.Data.TmxTile;
import format.tmx.Data.TmxChunk;
import format.tmx.Data.TmxTileLayer;

class TileLayerRenderer {
	var layer:TmxTileLayer;
	var texture:Image;

	public function new(layer, texture) {
		this.layer = layer;
		this.texture = texture;
	}

	public function draw(g2:Graphics) {
		for (chunk in layer.data.chunks) {
			var i = 0;
			for (yy in 0...chunk.height) {
				for (xx in 0...chunk.width) {
					final tile = chunk.tiles[i];
					if (tile.gid != 0) drawTile(g2, chunk, tile, xx, yy);
					i ++;
				}
			}
		}
	}

	inline function drawTile(g2:Graphics, chunk:TmxChunk, tile:TmxTile, tileX:Int, tileY:Int) {
		// final shift = 19;s
		final id = tile.gid;
		final shiftX = ((id-1) %  20);
		final shiftY:Int = Math.floor(id / 20);
		// if (tile.gid == 18) {
		// 	trace(shiftX);
		// 	trace(shiftY);
		// }
		g2.drawSubImage(texture,
			(chunk.x + tileX) * 16,
			(chunk.y + tileY) * 16,
			shiftX * 16 + shiftX, 
			shiftY * 16 + shiftY,
			16, 16
		);
	}
}