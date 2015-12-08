package flixel.math;

import flixel.util.FlxPool;
import flixel.util.FlxPool.IFlxPooled;
import flixel.util.FlxStringUtil;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;

/**
 * Stores a circle.
 */
class FlxCircle implements IFlxPooled
{
	public static var flxCircle:FlxCircle = new FlxCircle();
	
	public static var pool(get, never):IFlxPool<FlxCircle>;

	private static var _pool = new FlxPool<FlxCircle>(FlxCircle);
	
	/**
	 * Recycle or create new FlxCircle.
	 * Be sure to put() them back into the pool after you're done with them!
	 * 
	 * @param	X		The X-coordinate of the point in space.
	 * @param	Y		The Y-coordinate of the point in space.
	 * @param	Radius	The Radius of the circle.
	 */
	public static inline function get(X:Float = 0, Y:Float = 0, Radius:Float = 0):FlxCircle
	{
		var circle = _pool.get().set(X, Y, Radius);
		circle._inPool = false;
		return circle;
	}
	
	/**
	 * Recycle or create a new FlxCircle which will automatically be released 
	 * to the pool when passed into a flixel function.
	 */
	public static inline function weak(X:Float = 0, Y:Float = 0, Radius:Float = 0):FlxCircle
	{
		var circle = get(X, Y, Radius);
		circle._weak = true;
		return circle;
	}

	public var x:Float;
	public var y:Float;
	public var radius:Float;
	
	/**
	 * The coordinate of the center of the circle.
	 */
	public var center(get, never):FlxPoint;
	
	/**
	 * The x coordinate of the left side of the circle.
	 */
	public var left(get, never):Float;
	
	/**
	 * The x coordinate of the right side of the circle.
	 */
	public var right(get, never):Float;
	
	/**
	 * The y coordinate of the top of the circle.
	 */
	public var top(get, never):Float;
	
	/**
	 * The y coordinate of the bottom of the circle.
	 */
	public var bottom(get, never):Float;

	/**
	 * Whether radius of this circle is equal to zero or not.
	 */
	public var isEmpty(get, null):Bool;
	
	private var _weak:Bool = false;
	private var _inPool:Bool = false;
	
	@:keep
	public function new(X:Float = 0, Y:Float = 0, Radius:Float = 0)
	{
		set(X, Y, Radius);
	}
	
	/**
	 * Add this FlxCircle to the recycling pool.
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
	 * Add this FlxCircle to the recycling pool if it's a weak reference (allocated via weak()).
	 */
	public inline function putWeak():Void
	{
		if (_weak)
		{
			put();
		}
	}
	
	/**
	 * Shortcut for setting radius.
	 * 
	 * @param	Radius	The new circle radius.
	 */
	public inline function setRadius(Radius:Float):FlxCircle
	{
		radius = Radius;
		return this;
	}
	
	/**
	 * Shortcut for setting both x and y.
	 */
	public inline function setPosition(x:Float, y:Float):FlxCircle
	{
		this.x = x;
		this.y = y;
		return this;
	}

	/**
	 * Fill this circle with the data provided.
	 * 
	 * @param	X		The X-coordinate of the point in space.
	 * @param	Y		The Y-coordinate of the point in space.
	 * @param	Radius	The Radius of the circle.
	 * @return	A reference to itself.
	 */
	public inline function set(X:Float = 0, Y:Float = 0, Radius:Float = 0):FlxCircle
	{
		x = X;
		y = Y;
		radius = Radius;
		return this;
	}

	/**
	 * Helper function, just copies the values from the specified circle.
	 * 
	 * @param	Circle	Any FlxCircle.
	 * @return	A reference to itself.
	 */
	public inline function copyFrom(Circle:FlxCircle):FlxCircle
	{
		x = Circle.x;
		y = Circle.y;
		radius = Circle.radius;
		return this;
	}
	
	/**
	 * Helper function, just copies the values from this circle to the specified circle.
	 * 
	 * @param	Circle	Any FlxCircle.
	 * @return	A reference to the altered circle parameter.
	 */
	public inline function copyTo(Circle:FlxCircle):FlxCircle
	{
		Circle.x = x;
		Circle.y = y;
		Circle.radius = radius;
		return Circle;
	}
	
	/**
	 * Checks to see if some FlxCircle object overlaps this FlxCircle object.
	 * 
	 * @param	Circle	The circle being tested.
	 * @return	Whether or not the two circles overlap.
	 */
	public inline function overlaps(Circle:FlxCircle):Bool
	{
		return FlxMath.getDistance(center, Circle.center) <= (radius + Circle.radius);
	}

	/**
	 * Returns true if this FlxCircle contains the FlxPoint
	 * 
	 * @param	Point	The FlxPoint to check
	 * @return	True if the FlxPoint is within this FlxCircle, otherwise false
	 */
	public inline function containsFlxPoint(Point:FlxPoint):Bool
	{
		return FlxMath.getDistance(center, Point) <= radius;
	}
	
	/**
	 * Add another circle to this one by filling in the 
	 * horizontal and vertical space between the two circles.
	 * 
	 * @param	Circle	The second FlxCircle to add to this one
	 * @return	The changed Circle
	 */
	public inline function union(Circle:FlxCircle):FlxCircle
	{
		var minX:Float = Math.min(left, Circle.left);
		var minY:Float = Math.min(top, Circle.top);
		var maxX:Float = Math.max(right, Circle.right);
		
		var radius:Float = (maxX - minX)/2;
		var centerX:Float = minX + radius;
		var centerY:Float = minY + radius;
		
		return set(centerX, centerY, radius);
	}

	/**
	 * Rounds x, y and radius using Math.floor()
	 */
	public inline function floor():FlxCircle
	{
		x = Math.floor(x);
		y = Math.floor(y);
		radius = Math.floor(radius);
		return this;
	}

	/**
	 * Rounds x, y and radius using Math.ceil()
	 */
	public inline function ceil():FlxCircle
	{
		x = Math.ceil(x);
		y = Math.ceil(y);
		radius = Math.ceil(radius);
		return this;
	}

	/**
	 * Rounds x, y and radius using Math.round()
	 */
	public inline function round():FlxCircle
	{
		x = Math.round(x);
		y = Math.round(y);
		radius = Math.round(radius);
		return this;
	}

	/**
	 * Calculation of bounding circle from two points
	 * 
	 * @param	point1	first point to calculate bounding circle
	 * @param	point2	second point to calculate bounding circle
	 * @return	this circle filled with the position and size of bounding circle from two specified points
	 */
	public inline function fromTwoPoints(Point1:FlxPoint, Point2:FlxPoint):FlxCircle
	{
		var minX:Float = Math.min(Point1.x, Point2.x);
		var minY:Float = Math.min(Point1.y, Point2.y);
		
		var maxX:Float = Math.max(Point1.x, Point2.x);
		
		var radius:Float = (maxX - minX)/2;
		var centerX:Float = minX + radius;
		var centerY:Float = minY + radius;
		
		return set(centerX, centerY, radius);
	}

	/**
	 * Add another point to this circle one by filling in the 
	 * horizontal and vertical space between the point and this circle.
	 * 
	 * @param	Point	point to add to this one
	 * @return	The changed FlxCircle
	 */
	public inline function unionWithPoint(Point:FlxPoint):FlxCircle
	{
		var minX:Float = Math.min(left, Point.x);
		var minY:Float = Math.min(top, Point.y);
		var maxX:Float = Math.max(right, Point.x);
		
		var radius:Float = (maxX - minX)/2;
		var centerX:Float = minX + radius;
		var centerY:Float = minY + radius;
		
		return set(centerX, centerY, radius);
	}

	public inline function offset(dx:Float, dy:Float):FlxCircle
	{
		x += dx;
		y += dy;
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
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("x", x),
			LabelValuePair.weak("y", y),
			LabelValuePair.weak("radius", radius)]);
	}

	/**
	 * Checks if this circle's properties are equal to properties of provided circle.
	 * 
	 * @param	circle	Circle to check equality to.
	 * @return	Whether both circles are equal.
	 */
	public inline function equals(circle:FlxCircle):Bool
	{
		return FlxMath.equal(x, circle.x) && FlxMath.equal(y, circle.y)
			&& FlxMath.equal(radius, circle.radius);
	}

	/**
	 * Returns the area of intersection with specified circle. 
	 * If the circles do not intersect, this method returns an empty circle.
	 * 
	 * @param	circle	Circle to check intersection againist.
	 * @return	The area of intersection of two circles.
	 */
	public function intersection(circle:FlxCircle):FlxCircle
	{
		var maxLeft:Float = Math.max(left, circle.left);
		var minRight:Float = Math.min(right, circle.right);
		if (minRight <= maxLeft) 
		{	
			return FlxCircle.get(0, 0, 0);
		}
		
		var maxTop:Float = Math.max(top, circle.top);
		var minBottom:Float = Math.min(bottom, circle.bottom);
		if (minBottom <= maxTop) 
		{	
			return FlxCircle.get(0, 0, 0);
		}
		
		var radius:Float = (minRight - maxLeft)/2;
		var centerX:Float = maxLeft + radius;
		var centerY:Float = maxTop + radius;

		return FlxCircle.get(centerX, centerY, radius);
	}

	private inline function get_center():FlxPoint
	{
		return FlxPoint.get(x, y);
	}

	private inline function get_left():Float
	{
		return x - radius;
	}
	
	private inline function get_right():Float
	{
		return x + radius;
	}
	
	private inline function get_top():Float
	{
		return y - radius;
	}
	
	private inline function get_bottom():Float
	{
		return y + radius;
	}
	
	private inline function get_isEmpty():Bool
	{
		return radius == 0;
	}
	
	private static function get_pool():IFlxPool<FlxCircle>
	{
		return _pool;
	}
}
