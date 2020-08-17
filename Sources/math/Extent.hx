package math;

@:structInit final class Extent {
    public var left(default, null):Float;
    public var top(default, null):Float;
    public var right(default, null):Float;
    public var bottom(default, null):Float;

    static public function Min():Extent 
        return (new Extent(0,0,0,0)).minimized();

    static public function Max():Extent
        return (new Extent(0,0,0,0)).maximized();

    inline public function new(left, top, right, bottom) {
        this.left = left;
        this.right = right;
        this.top = top;
        this.bottom = bottom;
    }

    inline public function growTo(x, y, x2, y2) {
        left = inline Math.min(left, x);
        top = inline Math.min(y, top);
        right = inline Math.max(x2, right);
        bottom = inline Math.max(y2, bottom);
    }

    inline public function shrinkTo(x, y, x2, y2) {
        left = inline Math.max(left, x);
        top = inline Math.max(y, top);
        right = inline Math.min(x2, right);
        bottom = inline Math.min(y2, bottom);
    }

    inline public function growToExtent(other:Extent) {
        growTo(other.left, other.top, other.right, other.bottom);
    }

    inline public function shrinkToExtent(other:Extent) {
        shrinkTo(other.left, other.top, other.right, other.bottom);
    }

    inline public function maximized() {
        left =  Math.NEGATIVE_INFINITY;
        top =  Math.NEGATIVE_INFINITY;
        right =  Math.POSITIVE_INFINITY;
        bottom =  Math.POSITIVE_INFINITY;
        return this;
    }

    inline public function minimized() {
        left = Math.POSITIVE_INFINITY;
        top = Math.POSITIVE_INFINITY;
        right = Math.NEGATIVE_INFINITY;
        bottom = Math.NEGATIVE_INFINITY;
        return this;
    }
}