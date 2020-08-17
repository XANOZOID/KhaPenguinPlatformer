package masks;

import bridge.Arrays;
import masks.Mask;
import math.MathUtil;
import math.Extent;

/**
 * A Mask that can contain multiple Masks of one or various types.
 */
class Masklist extends MaskCollection {
	var _masks:Array<Mask>;
	var _temp:Array<Mask>;
	var _count:Int;
	var _extent:Extent;

	public function new(?masks:Array<Mask>, x = 0, y = 0)
	{
		super(x, y);
		_masks = new Array<Mask>();
		_temp = new Array<Mask>();
		_count = 0;
		_extent = Extent.Min();

		if (masks != null) {
			for (m in masks) add(m);
		}
	}

	override public function collide(maskB:Mask):Bool{
		return maskB.collideCollection(this);
	}

	/** @private Collide against a Masklist. */
	override function collideCollection(other:MaskCollection):Bool {
		for (a in _masks) {
			if (a.collide(other)) { return true; }
		}
		return false;
	}

	override function collideHitbox(other:Hitbox) {
		for (a in _masks) {
			if (a.collideHitbox(other)) { return true; }
		}
		return false;
	}
	
	override function collidePolygon(other:Polygon):Bool {
		for (a in _masks) {
			if (a.collidePolygon(other)) { return true; }
		}
		return false;
	}

	/**
	 * Adds a Mask to the list.
	 * @param	mask		The Mask to add.
	 * @return	The added Mask.
	 */
	public function add(mask:Mask):Mask {
		_masks[_count++] = mask;
		mask.owner = this;
		update();
		return mask;
	}

	/**
	 * Removes the Mask from the list.
	 * @param	mask		The Mask to remove.
	 * @return	The removed Mask.
	 */
	public function remove(mask:Mask):Mask {
		if (Arrays.indexOf(_masks, mask) < 0) return mask;
		Arrays.clear(_temp);
		for (m in _masks) {
			if (m == mask) {
				mask.owner = null;
				_count--;
				update();
			}
			else _temp[_temp.length] = m;
		}
		var temp:Array<Mask> = _masks;
		_masks = _temp;
		_temp = temp;
		return mask;
	}

	/**
	 * Removes the Mask at the index.
	 * @param	index		The Mask index.
	 */
	public function removeAt(index:Int = 0)
	{
		Arrays.clear(_temp);
		var i:Int = _masks.length;
		index %= i;
		while (i-- > 0)
		{
			if (i == index)
			{
				_masks[index].owner = null;
				_count--;
				update();
			}
			else _temp[_temp.length] = _masks[index];
		}
		var temp:Array<Mask> = _masks;
		_masks = _temp;
		_temp = temp;
	}

	/**
	 * Removes all Masks from the list.
	 */
	public function removeAll() {
		for (m in _masks) m.owner = null;
		_count = 0;
		Arrays.clear(_masks);
		Arrays.clear(_temp);
		update();
	}

	/**  Gets a Mask from the list.
	 * @param	index		The Mask index.
	 * @return	The Mask at the index. */
	public function getMask(index:Int = 0):Mask {
		return _masks[index % _masks.length];
	}

	override public function update() {
		_extent.minimized();
		for (m in _masks) m.maximize(_extent);
		if (owner != null) { owner.update(); }
	}

	/**
	 * Amount of Masks in the list.
	 */
	public var count(get, null):Int;
	function get_count():Int return _count;
}
