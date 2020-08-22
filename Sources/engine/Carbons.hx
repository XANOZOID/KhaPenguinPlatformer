package engine;

import masks.Hitbox;
import masks.Polygon;
import masks.Masklist;
import graphics.TileLayerRenderer;
import carbons.*;

class Carbons {
    // Carbons
	public var tilemapRenderer:TileLayerRenderer;
	public var player:Player;
    public var solids:Masklist = new Masklist();
    public var checkpoints:Masklist = new Masklist();
    public var jumpthroughs:Array<Hitbox> = [];
    public var deathZones:Masklist = new Masklist();
    public var polygons:Array<Polygon> = [];
    public var springs:Array<Spring> = [];

    // Groups... (empty)
    public function getGroupNameIterator() {
        // return iterator that points to each (within same type probs). . .
    }
    
    public function new() {}
}