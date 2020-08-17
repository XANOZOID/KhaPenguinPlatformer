package bridge;

class Arrays {
    
    /**
	 * Empties an array of its' contents
	 * @param array filled array
	 */
	public static inline function clear<T>(array:Array<T>){
    #if cpp
        // splice causes Array allocation, so prefer pop for most arrays
        if (array.length > 256) array.splice(0, array.length);
        else while (array.length > 0) array.pop();
    #else
       untyped array.length = 0;
    #end
    }

	/**
	 * Optimized version of Lambda.indexOf for Array on dynamic platforms (Lambda.indexOf is less performant on those targets).
	 *
	 * @param	arr		The array to look into.
	 * @param	param	The value to look for.
	 * @return	Returns the index of the first element [v] within Array [arr].
	 * This function uses operator [==] to check for equality.
	 * If [v] does not exist in [arr], the result is -1.
	 **/
    public static inline function indexOf<T>(arr:Array<T>, v:T):Int {
    #if (haxe_ver >= 3.1)
        return arr.indexOf(v);
    #elseif js
        return untyped arr.indexOf(v);
    #else
        return std.Lambda.indexOf(arr, v);
    #end
    }
}