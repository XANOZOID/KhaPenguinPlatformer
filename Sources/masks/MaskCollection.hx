package masks;

class MaskCollection extends Mask {
    public var originX:Float;
    public var originY:Float;

    public function new(originX = 0, originY = 0) {
        super();
        this.originX = originX;
        this.originY = originY;
    }

    public function update()
        throw "not implemented";

    public function getCollidingMask(other:Mask):Mask
        throw "not implemented";
}