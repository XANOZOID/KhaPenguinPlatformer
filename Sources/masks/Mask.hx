package masks;

import masks.MaskCollection;
import math.Rectangle;
import math.Vector2;
import math.Projection;
import math.Extent;

// This is an abstract class.
class Mask {
    public var owner:MaskCollection = null;

    public function new() {}


    public var ownerX(get, never):Float;
    public var ownerY(get, never):Float;
    inline function get_ownerX():Float
        return owner == null? 0 : owner.originX + owner.ownerX;
    inline function get_ownerY():Float
        return owner == null? 0.0 : owner.originY + owner.ownerY;


    /*
    Pattern:
        Every mask-type should override the following collide functions.
        the "collide" function is when you want to collide a with b 
        where a tells b how to collide with it.
        The other functions are how 'a' understand to collide with b.
    */
    
    /// Override this method to tell mask-b what it's colliding with.
    public function collide(b:Mask):Bool
        throw "not implemented"; 

    /// Override this method in how it expects to collide with a hitbox.
    public function collideHitbox(o:Hitbox):Bool
        throw "not implemented";

    /// Override this method in how it expects to collide with a polygon.
    public function collidePolygon(o:Polygon):Bool
        throw "not implemented";

    /// Override this method in how it expects to collide with a masklist.
    public function collideCollection(o:MaskCollection):Bool
        throw "not implemented";

    /// Utility

    /// Override this method to define how it projects on to a specific axis.
    public function project(axis:Vector2, projection:Projection):Void
        throw "not implemented";

    // Define this method as how it would extend an Extents based on its dimensions
    public function maximize(extents:Extent):Void
        throw "not implemented";
}