package math;


class Standard {
    static public function clamp(val:Float, left:Float, right:Float) {
        return Math.max(left, Math.min(val, right));
    }

    static public function sign(val:Float):Int {
        return val == 0? 0
            : val > 0? 1 : -1;
    }

    static public function trunc(val:Float):Float {
        return Math.floor(Math.abs(val)) * sign(val);
    }

    static public function point(val:Float):Float {
        return Math.abs(val - trunc(val));
    }
}