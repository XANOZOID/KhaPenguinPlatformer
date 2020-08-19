package masks;

import kha.graphics2.Graphics;
import masks.Hitbox;
import math.Projection;
import math.Vector2;
import math.MathUtil;
import math.MakeConvex;

/**
 * Uses a convex polygonal structure to check for collisions.
 */
class Polygon extends Mask {
	@:dox(hide)
	public static var vertical = new Vector2(0, 1);
	@:dox(hide)
	public static var horizontal = new Vector2(1, 0);
	static var EPSILON = 0.000000001;	// used for axes comparison in removeDuplicateAxes
	static var firstProj = new Projection();
	static var secondProj = new Projection();

    /**
	 * The polygon rotates around this point when the angle is set.
	 */
	public var origin:Vector2;

	// Polygon bounding box.
	/** Left x bounding box position. */
	public var minX(default, null):Int = 0;
	/** Top y bounding box position. */
	public var minY(default, null):Int = 0;
	/** Right x bounding box position. */
	public var maxX(default, null):Int = 0;
	/** Bottom y bounding box position. */
    public var maxY(default, null):Int = 0;
    
	var _angle:Float;
	var _points:Array<Vector2>;
	var _axes:Array<Vector2>;

	/**
	 * Creates a list of convex polygonal masks based on an array of vertices defined counter-clockwise.
	 * The polygon must be simple (non-self-intersecting), but not necessarily convex.
	 * @param	points		An array of coordinates that define the polygon (must have at least 3 and defined counter-clockwise).
	 * @param	origin	 	Pivot point for rotations.
	 */
	public static function fromPoints(points:Array<Vector2>, ?origin:Vector2):Masklist
	{
		var cp = MakeConvex.run(points);
		var list = new Masklist();
		for (p in cp)
			list.add(new Polygon(p, origin));
		return list;
	}

	/**
	 * Constructor. The passed polygon must be convex.
	 * @param	points		An array of coordinates that define the polygon (must have at least 3 and be convex).
	 * @param	origin	 	Pivot point for rotations.
	 */
	public function new(points:Array<Vector2>, ?origin:Vector2) {
		super();
		if (points.length < 3) throw "The polygon needs at least 3 sides.";
		_points = points;
		this.origin = origin != null ? origin : new Vector2();
		_angle = 0;

		updateAxes();
	}

	/**
	 * Checks for collisions with an Entity.
	 */
	override function collide(other:Mask):Bool {
		var offset:Float,
			offsetX:Float = ownerX - other.ownerX,
			offsetY:Float = ownerY - other.ownerY;

		// project on the vertical axis of the hitbox/mask
		project(vertical, firstProj);
		other.project(vertical, secondProj);

		firstProj.min += offsetY;
		firstProj.max += offsetY;

		// if firstProj not overlaps secondProj
		if (!firstProj.overlaps(secondProj)) {
			return false;
		}

		// project on the horizontal axis of the hitbox/mask
		project(horizontal, firstProj);
		other.project(horizontal, secondProj);

		firstProj.min += offsetX;
		firstProj.max += offsetX;

		// if firstProj not overlaps secondProj
		if (!firstProj.overlaps(secondProj)) {
			return false;
		}

		// project hitbox/mask on polygon axes
		// for a collision to be present all projections must overlap
		for (a in _axes)
		{
			project(a, firstProj);
			other.project(a, secondProj);

			offset = offsetX * a.x + offsetY * a.y;
			firstProj.min += offset;
			firstProj.max += offset;

			// if firstProj not overlaps secondProj
			if (!firstProj.overlaps(secondProj)) {
				return false;
			}
		}
		return true;
	}

	/**
	 * Checks for collisions with a Hitbox.
	 */
	override function collideHitbox(hitbox:Hitbox):Bool
	{
		var offset:Float,
			offsetX:Float = ownerX - hitbox.ownerX,
			offsetY:Float = ownerY - hitbox.ownerY;

		// project on the vertical axis of the hitbox
		project(vertical, firstProj);
		hitbox.project(vertical, secondProj);

		firstProj.min += offsetY;
		firstProj.max += offsetY;

		// if firstProj not overlaps secondProj
		if (!firstProj.overlaps(secondProj)) {
			return false;
		}

		// project on the horizontal axis of the hitbox
		project(horizontal, firstProj);
		hitbox.project(horizontal, secondProj);

		firstProj.min += offsetX;
		firstProj.max += offsetX;

		// if firstProj not overlaps secondProj
		if (!firstProj.overlaps(secondProj)) {
			return false;
		}

		// project hitbox on polygon axes
		// for a collision to be present all projections must overlap
		for (a in _axes) {
			project(a, firstProj);
			hitbox.project(a, secondProj);

			offset = offsetX * a.x + offsetY * a.y;
			firstProj.min += offset;
			firstProj.max += offset;

			// if firstProj not overlaps secondProj
			if (!firstProj.overlaps(secondProj)) {
				return false;
			}
		}
		return true;
	}

	/**
	 * Checks for collision with a polygon.
	 */
	override public function collidePolygon(other:Polygon):Bool
	{
		var offset:Float;
		var offsetX:Float = ownerX - other.ownerX;
		var offsetY:Float = ownerY - other.ownerY;

		// project other on this polygon axes
		// for a collision to be present all projections must overlap
		for (a in _axes) {
			project(a, firstProj);
			other.project(a, secondProj);

			// shift the first info with the offset
			offset = offsetX * a.x + offsetY * a.y;
			firstProj.min += offset;
			firstProj.max += offset;

			// if firstProj not overlaps secondProj
			if (!firstProj.overlaps(secondProj)) {
				return false;
			}
		}

		// project this polygon on other polygon axes
		// for a collision to be present all projections must overlap
		for (a in other._axes) {
			project(a, firstProj);
			other.project(a, secondProj);

			// shift the first info with the offset
			offset = offsetX * a.x + offsetY * a.y;
			firstProj.min += offset;
			firstProj.max += offset;

			// if firstProj not overlaps secondProj
			if (!firstProj.overlaps(secondProj)) {
				return false;
			}
		}
		return true;
    }
    
    final override public function collideCollection(other:MaskCollection) {
        return other.collidePolygon(this);
    }

	/** Projects this polygon points on axis and returns min and max values in projection object. */
	@:dox(hide)
	override public function project(axis:Vector2, projection:Projection):Void {
		var p:Vector2 = _points[0];

		var min:Float = axis.dot(p),
			max:Float = min;

		for (i in 1..._points.length)
		{
			p = _points[i];
			var cur:Float = axis.dot(p);

			if (cur < min)
			{
				min = cur;
			}
			else if (cur > max)
			{
				max = cur;
			}
		}
		projection.min = min;
		projection.max = max;
	}

	public function debugDraw(g2:Graphics):Void {
		for (i in 1..._points.length + 1) {
			var a = i - 1, b = i % _points.length;
			g2.drawLine(
				(points[a].x),
				(points[a].y ),
				(points[b].x ),
				(points[b].y )
			);
		}

		// draw pivot
		// dc.circle((offsetX + origin.x) * scaleX, (offsetY + origin.y) * scaleY, 2);
	}

	/**
	 * Rotation angle (in degrees) of the polygon (rotates around origin point).
	 */
	public var angle(get, set):Float;
	inline function get_angle():Float return _angle;
	function set_angle(value:Float):Float
	{
		if (value != _angle)
		{
			rotate(value - _angle);
			if (owner != null) update();
		}
		return value;
	}

	/**
	 * The points representing the polygon.
	 *
	 * If you need to set a point yourself instead of passing in a new Array<Point> you need to call update()
	 * to make sure the axes update as well.
	 */
	public var points(get, set):Array<Vector2>;
	inline function get_points():Array<Vector2> return _points;
	function set_points(value:Array<Vector2>):Array<Vector2>
	{
		if (_points != value)
		{
			_points = value;
			if (owner != null) updateAxes();
		}
		return value;
	}

	/** Updates the parent's bounds for this mask. */
	public function update():Void
	{
		if (owner != null)
		{	
			project(horizontal, firstProj); // width
			var projX:Int = Math.round(firstProj.min);
			// _width = Math.round(firstProj.max - firstProj.min);
			project(vertical, secondProj); // height
			var projY:Int = Math.round(secondProj.min);
			// _height = Math.round(secondProj.max - secondProj.min);

			minX = projX;
			minY = projY;
			maxX = Math.round(minX);
			maxY = Math.round(minY);

			owner.update();
		}
	}

	/**
	 * Creates a regular polygon (edges of same length).
	 * @param	sides	The number of sides in the polygon.
	 * @param	radius	The distance that the vertices are at.
	 * @param	angle	How much the polygon is rotated (in degrees).
	 * @return	The polygon
	 */
	public static function createPolygon(sides:Int = 3, radius:Float = 100, angle:Float = 0):Polygon
	{
		if (sides < 3) throw "The polygon needs at least 3 sides.";

		// figure out the angle required for each step
		var rotationAngle:Float = (Math.PI * 2) / sides;

		// loop through and generate each point
		var points:Array<Vector2> = new Array<Vector2>();

		for (i in 0...sides)
		{
			var tempAngle:Float = Math.PI + i * rotationAngle;
			var p:Vector2 = new Vector2();
			p.x = Math.cos(tempAngle) * radius + radius;
			p.y = Math.sin(tempAngle) * radius + radius;
			points.push(p);
		}

		// return the polygon
		var poly:Polygon = new Polygon(points);
		poly.origin.x = radius;
		poly.origin.y = radius;
		poly.angle = angle;
		return poly;
	}

	/**
	 * Creates a polygon from an array were even numbers are x and odd are y
	 * @param	points	Array containing the polygon's points.
	 *
	 * @return	The polygon
	 */
	public static function createFromArray(points:Array<Float>):Polygon {
		var p:Array<Vector2> = new Array<Vector2>();

		var i:Int = 0;
		while (i < points.length)
		{
			p.push(new Vector2(points[i++], points[i++]));
		}
		return new Polygon(p);
	}

	function rotate(angleDelta:Float):Void {
		_angle += angleDelta;

		angleDelta *= MathUtil.RAD;

		var p:Vector2;

		for (i in 0..._points.length)
		{
			p = _points[i];
			var dx:Float = p.x - origin.x;
			var dy:Float = p.y - origin.y;

			var pointAngle:Float = Math.atan2(dy, dx);
			var length:Float = Math.sqrt(dx * dx + dy * dy);

			p.x = Math.cos(pointAngle + angleDelta) * length + origin.x;
			p.y = Math.sin(pointAngle + angleDelta) * length + origin.y;
		}

		for (a in _axes)
		{
			var axisAngle:Float = Math.atan2(a.y, a.x);

			a.x = Math.cos(axisAngle + angleDelta);
			a.y = Math.sin(axisAngle + angleDelta);
		}
	}

	function generateAxes():Void
	{
		_axes = new Array<Vector2>();

		var temp:Float;
		var nPoints:Int = _points.length;
		var edge:Vector2;
		var i:Int, j:Int;

		i = 0;
		j = nPoints - 1;
		while (i < nPoints)
		{
			edge = new Vector2();
			edge.x = _points[i].x - _points[j].x;
			edge.y = _points[i].y - _points[j].y;

			// get the axis which is perpendicular to the edge
			temp = edge.y;
			edge.y = -edge.x;
			edge.x = temp;
			edge.normalize(1);

			_axes.push(edge);

			j = i;
			i++;
		}
	}

	function removeDuplicateAxes():Void
	{
		var i = _axes.length - 1;
		var j = i - 1;
		while (i > 0)
		{
			// if the first vector is equal or similar to the second vector,
			// remove it from the .owner. (for example, [1, 1] and [-1, -1]
			// represent the same axis)
			if ((Math.abs(_axes[i].x - _axes[j].x) < EPSILON && Math.abs(_axes[i].y - _axes[j].y) < EPSILON)
				|| (Math.abs(_axes[j].x + _axes[i].x) < EPSILON && Math.abs(_axes[i].y + _axes[j].y) < EPSILON))	// first axis inverted
			{
				_axes.splice(i, 1);
				i--;
			}

			j--;
			if (j < 0)
			{
				i--;
				j = i - 1;
			}
		}
	}

	function updateAxes():Void
	{
		generateAxes();
		removeDuplicateAxes();
		update();
    }
    
    final public override function maximize(extents) {
        extents.growTo(minX, minY, maxX, maxY);
    }
}
