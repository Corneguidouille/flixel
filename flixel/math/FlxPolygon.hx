package flixel.math;

import flixel.util.FlxPool;
import flixel.util.FlxPool.IFlxPooled;
import flixel.util.FlxStringUtil;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

/**
 * Stores a polygon.
 */
class FlxPolygon implements IFlxPooled
{
	public static var flxPolygon:FlxPolygon = new FlxPolygon();
	
	public static var pool(get, never):IFlxPool<FlxPolygon>;
	
	private static var _pool = new FlxPool<FlxPolygon>(FlxPolygon);
	
	/**
	 * Recycle or create new FlxPolygon.
	 * Be sure to put() them back into the pool after you're done with them!
	 */
	public static inline function get(Points:Array<FlxPoint>):FlxPolygon
	{
		var polygon = _pool.get().set(Points);
		polygon._inPool = false;
		return polygon;
	}
	
	/**
	 * Recycle or create a new FlxPolygon which will automatically be released 
	 * to the pool when passed into a flixel function.
	 */
	public static inline function weak(Points:Array<FlxPoint>):FlxPolygon
	{
		var polygon = get(Points);
		polygon._weak = true;
		return polygon;
	}

	public var points:Array<FlxPoint>;
	
	/**
	 * The x coordinate of the left side of the polygon.
	 */
	public var left(get, never):Float;
	
	/**
	 * The x coordinate of the right side of the polygon.
	 */
	public var right(get, never):Float;
	
	/**
	 * The y coordinate of the top of the polygon.
	 */
	public var top(get, never):Float;
	
	/**
	 * The y coordinate of the bottom of the polygon.
	 */
	public var bottom(get, never):Float;
	
	/**
	 * Whether this polygon is empty or not.
	 */
	public var isEmpty(get, never):Bool;
	
	private var _x:Float;
	private var _y:Float;
	private var _width:Float;
	private var _height:Float;

	private var _weak:Bool = false;
	private var _inPool:Bool = false;
	
	@:keep
	public function new(Points:Array<FlxPoint> = null)
	{
		if (Points == null)
			Points = new Array<FlxPoint>();
		set(Points);
	}
	
	/**
	 * Add this FlxPolygon to the recycling pool.
	 */
	public inline function put():Void
	{
		if (!_inPool)
		{
			_inPool = true;
			_weak = false;
			_pool.putUnsafe(this);
		}
	}
	
	/**
	 * Add this FlxPolygon to the recycling pool if it's a weak reference (allocated via weak()).
	 */
	public inline function putWeak():Void
	{
		if (_weak)
		{
			put();
		}
	}
	
	/**
	 * Shortcut for setting both x and y.
	 */
	public inline function setPosition(x:Float, y:Float):FlxPolygon
	{
		var dx:Float = x - this._x;
		var dy:Float = y - this._y;
		
		return offset(dx, dy);
	}

	/**
	 * Fill this polygon with the data provided.
	 * 
	 * @param	Points		The array of points that fill this polygon.
	 * @return	A reference to itself.
	 */
	public inline function set(Points:Array<FlxPoint>):FlxPolygon
	{
		points = Points;

		updateBoundaries();

		return this;
	}

	/**
	 * Helper function, just copies the values from the specified polygon.
	 * 
	 * @param	Polygon	Any FlxPolygon.
	 * @return	A reference to itself.
	 */
	public inline function copyFrom(Polygon:FlxPolygon):FlxPolygon
	{
		return set(Polygon.points);
	}
	
	/**
	 * Helper function, just copies the values from this polygon to the specified polygon.
	 * 
	 * @param	Polygon	Any FlxPolygon.
	 * @return	A reference to the altered polygon parameter.
	 */
	public inline function copyTo(Polygon:FlxPolygon):FlxPolygon
	{
		Polygon.points = points;
		return Polygon;
	}
	
	/**
	 * Checks to see if some FlxPolygon object overlaps this FlxPolygon object.
	 * 
	 * @param	Polygon	The polygon being tested.
	 * @return	Whether or not the two polygons overlap.
	 */
	public inline function overlaps(Polygon:FlxPolygon):Bool
	{
		if ((right < Polygon.left) || (left > Polygon.right) || (bottom < Polygon.top) || (top > Polygon.bottom))
			return false;
		//TODO
		return false;
	}
	
	/**
	 * Returns true if this FlxPolygon contains the FlxPoint
	 * 
	 * @param	Point	The FlxPoint to check
	 * @return	True if the FlxPoint is within this FlxPolygon, otherwise false
	 */
	public inline function containsFlxPoint(Point:FlxPoint):Bool
	{
		return FlxMath.pointInFlxPolygon(Point.x, Point.y, this);
	}
	
	/**
	 * Add another rectangle to this one by filling in the 
	 * horizontal and vertical space between the two rectangles.
	 * 
	 * @param	Rect	The second FlxRect to add to this one
	 * @return	The changed FlxRect
	 */
	/*public inline function union(Rect:FlxRect):FlxRect
	{
		var minX:Float = Math.min(x, Rect.x);
		var minY:Float = Math.min(y, Rect.y);
		var maxX:Float = Math.max(right, Rect.right);
		var maxY:Float = Math.max(bottom, Rect.bottom);
		
		return set(minX, minY, maxX - minX, maxY - minY);
	}*/
	
	/**
	 * Rounds x, y of each points of the polygon using Math.floor()
	 */
	public inline function floor():FlxPolygon
	{
		for (p in points)
		{
			p.x = Math.floor(p.x);
			p.y = Math.floor(p.y);
		}

		updateBoundaries();

		return this;
	}
	
	/**
	 * Rounds x, y of each points of the polygon using Math.ceil()
	 */
	public inline function ceil():FlxPolygon
	{
		for (p in points)
		{
			p.x = Math.ceil(p.x);
			p.y = Math.ceil(p.y);
		}

		updateBoundaries();

		return this;
	}
	
	/**
	 * Rounds x, y of each points of the polygon using Math.round()
	 */
	public inline function round():FlxPolygon
	{
		for (p in points)
		{
			p.x = Math.round(p.x);
			p.y = Math.round(p.y);
		}

		updateBoundaries();

		return this;
	}
	
	public inline function offset(dx:Float, dy:Float):FlxPolygon
	{
		for (p in points)
		{
			p.x += dx;
			p.y += dy;
		}

		updateBoundaries();

		return this;
	}
	
	/**
	 * Necessary for IFlxDestroyable.
	 */
	public function destroy() {}
	
	/**
	 * Convert object to readable string name. Useful for debugging, save games, etc.
	 */
	public inline function toString():String
	{
		var string:String = "";
		for (p in points)
		{
			string += FlxStringUtil.getDebugString([
						LabelValuePair.weak("x", p.x),
						LabelValuePair.weak("y", p.y)
						]);
		}
		return string;
	}
	
	/**
	 * Checks if this polygon's properties are equal to properties of provided polygon.
	 * 
	 * @param	polygon	FlxPolygon to check equality to.
	 * @return	Whether both polygons are equal.
	 */
	public inline function equals(polygon:FlxPolygon):Bool
	{
		if (points.length != polygon.points.length)
			return false;

		var i:Int = 0;
		var size:Int = points.length;
		
		while (i < size)
		{
			var p:FlxPoint = points[i];
			
			var polygonP:FlxPoint = polygon.points[i];

			if (FlxMath.equal(p.x, polygonP.x) == false || FlxMath.equal(p.y, polygonP.y) == false)
				return false;

			++i;
		}

		return true;
	}
	
	/**
	 * Returns the area of intersection with specified rectangle. 
	 * If the rectangles do not intersect, this method returns an empty rectangle.
	 * 
	 * @param	rect	Rectangle to check intersection againist.
	 * @return	The area of intersection of two rectangles.
	 */
	/*public function intersection(rect:FlxRect):FlxRect
	{
		var x0:Float = x < rect.x ? rect.x : x;
		var x1:Float = right > rect.right ? rect.right : right;
		if (x1 <= x0) 
		{	
			return FlxRect.get(0, 0, 0, 0);
		}
		
		var y0:Float = y < rect.y ? rect.y : y;
		var y1:Float = bottom > rect.bottom ? rect.bottom : bottom;
		if (y1 <= y0) 
		{	
			return FlxRect.get(0, 0, 0, 0);
		}
		
		return FlxRect.get(x0, y0, x1 - x0, y1 - y0);
	}*/
	
	public inline function getBoundingBox():FlxRect
	{
		return FlxRect.get(_x, _y, _width, _height);
	}

	private function updateBoundaries():Void
	{	
		var minX:Float = 0;
		var maxX:Float = 0;
		var minY:Float = 0;
		var maxY:Float = 0;

		for (p in points)
		{
			if (p.x < minX)
				minX = p.x;
			else if (p.x > maxX)
				maxX = p.x;

			if (p.y < minY)
				minY = p.y;
			else if (p.y > maxY)
				maxY = p.y;
		}

		_x = minX;
		_y = minY;
		_width = maxX - minX;
		_height = maxY - minY;
	}

	private inline function get_left():Float
	{
		return _x;
	}
	
	private inline function get_right():Float
	{
		return _x + _width;
	}
	
	private inline function get_top():Float
	{
		return _y;
	}
	
	private inline function get_bottom():Float
	{
		return _y + _height;
	}
	
	private inline function get_isEmpty():Bool
	{
		return points.length == 0;
	}

	private static function get_pool():IFlxPool<FlxPolygon>
	{
		return _pool;
	}
}