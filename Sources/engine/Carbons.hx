package engine;

import masks.Polygon;
import masks.Masklist;
import graphics.TileLayerRenderer;
import carbons.Player;

class Carbons {
    // Carbons
	public var tilemapRenderer:TileLayerRenderer;
	public var player:Player;
    public var solids:Masklist = new Masklist();
    public var deathZones:Masklist = new Masklist();
    public var polygons:Array<Polygon> = [];

    // Groups... (empty)
    public function getGroupNameIterator() {
        // return iterator that points to each (within same type probs). . .
    }
    
    public function new() {}
}