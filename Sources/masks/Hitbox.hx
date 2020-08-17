package masks;

import masks.Mask;
import math.Projection;
import math.Vector2;
import math.Extent;

/** Uses parent's hitbox to determine collision.
 * This class is used internally by HaxePunk, you don't need to use this class because
 * this is the default behaviour of Entities without a Mask object.
 */
class Hitbox extends Mask {
	var _width:Int = 0;
	var _height:Int = 0;
	var _x:Float = 0;
	var _y:Float = 0;

	public function new( x:Float = 0, y:Float = 0, width:Int = 1, height:Int = 1) {
		super();
		_width = width;
		_height = height;
		_x = x;
		_y = y;
	}

	/** @private Collides against an Entity. */
	final override function collide(other:Mask):Bool {
        return other.collideHitbox(this);
	}

	/** @private Collides against a Hitbox. */
	final public override function collideHitbox(other:Hitbox):Bool {
		final px:Float = _x + ownerX,
			py:Float = _y + ownerY;

		final ox:Float = other._x + other.ownerX,
			oy:Float = other._y + other.ownerY;

		return px + _width > ox
			&& py + _height > oy
			&& px < ox + other._width
			&& py < oy + other._height;
    }
    
    final public override function collidePolygon(other:Polygon) {
        return other.collideHitbox(this);
    }

    final public override function collideCollection(other:MaskCollection) {
        return other.collideHitbox(this);
    }


	public var x(get, set):Float;
	function get_x():Float return _x;
	function set_x(value:Float):Float
	{
		if (_x == value) return value;
		_x = value;
		if (owner != null) owner.update();
		return _x;
	}

	public var y(get, set):Float;
	function get_y():Float return _y;
	function set_y(value:Float):Float
	{
		if (_y == value) return value;
		_y = value;
		if (owner != null) owner.update();
		return _y;
	}

	/**
	 * Width.
	 */
	public var width(get, set):Int;
	function get_width():Int return _width;
	function set_width(value:Int):Int
	{
		if (_width == value) return value;
		_width = value;
		if (owner != null) owner.update();
		return _width;
	}

	/**
	 * Height.
	 */
	public var height(get, set):Int;
	function get_height():Int return _height;
	function set_height(value:Int):Int
	{
		if (_height == value) return value;
		_height = value;
		if (owner != null) owner.update();
		return _height;
	}

	// @:dox(hide)
	// override public function debugDraw(camera:Camera):Void
	// {
	// 	if (parent != null)
	// 	{
	// 		Mask.drawContext.setColor(0xff0000, 0.25);
	// 		Mask.drawContext.rectFilled((parent.x - camera.x + x) * camera.screenScaleX, (parent.y - camera.y + y) * camera.screenScaleY, width * camera.screenScaleX, height * camera.screenScaleY);
	// 		Mask.drawContext.setColor(0xff0000, 0.5);
	// 		Mask.drawContext.rect((parent.x - camera.x + x) * camera.screenScaleX, (parent.y - camera.y + y) * camera.screenScaleY, width * camera.screenScaleX, height * camera.screenScaleY);
	// 	}
    // }
    
	override public function project(axis:Vector2, projection:Projection):Void {
		var px = _x;
		var py = _y;
		var cur:Float,
			max:Float = Math.NEGATIVE_INFINITY,
			min:Float = Math.POSITIVE_INFINITY;

		cur = px * axis.x + py * axis.y;
		if (cur < min)
			min = cur;
		if (cur > max)
			max = cur;

		cur = (px + _width) * axis.x + py * axis.y;
		if (cur < min)
			min = cur;
		if (cur > max)
			max = cur;

		cur = px * axis.x + (py + _height) * axis.y;
		if (cur < min)
			min = cur;
		if (cur > max)
			max = cur;

		cur = (px + _width) * axis.x + (py + _height) * axis.y;
		if (cur < min)
			min = cur;
		if (cur > max)
			max = cur;

		projection.min = min;
		projection.max = max;
    }
    
    final public override function maximize(extent:Extent) {
        extent.growTo(_x, _y, _x + _width, _y + _height);
    }
}
