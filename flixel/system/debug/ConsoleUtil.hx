package flixel.system.debug;

import flixel.FlxG;
import hscript.Expr;
import hscript.Parser;

/** 
 * A set of helper functions used by the console.
 */
class ConsoleUtil
{
	// The hscript parser to make strings into haxe code.
	private static var parser:Parser;
	// The custom hscript interpreter to run the haxe code from the parser.
	public static var interp:Interp;
	
	/**
	 * Sets up the hscript parser and interpreter.
	 */
	public static function init():Void
	{
		parser = new Parser();
		parser.allowJSON = true;
		parser.allowTypes = true;
		
		interp = new Interp();
	}
	
	/**
	 * Converts the input string into its AST form to be executed.
	 * 
	 * @param	Input	The user's input command.
	 * @return	The parsed out AST.
	 */
	public static function parseCommand(Input:String):Expr
	{
		if (StringTools.endsWith(Input, ";"))
			Input = Input.substr(0, -1);
		return parser.parseString(Input);
	}
	
	/**
	 * Parses and runs the input command.
	 * 
	 * @param	Input	The user's input command.
	 * @return	Whatever the input code evaluates to.
	 */
	public static function runCommand(Input:String):Dynamic {
		return interp.expr(parseCommand(Input));
	}
	
	/**
	 * Register a new object to use in any command.
	 * 
	 * @param	ObjectAlias	The name with which you want to access the object.
	 * @param	AnyObject	The object to register.
	 */
	public static function registerObject(ObjectAlias:String, AnyObject:Dynamic):Void
	{
		if (Reflect.isObject(AnyObject))
			interp.variables.set(ObjectAlias, AnyObject);
	}
	
	/**
	 * Register a new function to use in any command.
	 * 
	 * @param 	FunctionAlias	The name with which you want to access the function.
	 * @param 	Function		The function to register.
	 */
	public static function registerFunction(FunctionAlias:String, Function:Dynamic):Void
	{
		if (Reflect.isFunction(Function))
			interp.variables.set(FunctionAlias, Function);
	}
	
	/**
	 * Shortcut to log a text with the Console LogStyle.
	 * 
	 * @param	Text	The text to log.
	 */
	public static inline function log(Text:Dynamic):Void
	{
		FlxG.log.advanced([Text], LogStyle.CONSOLE);
	}
}

/**
 * hscript doesn't use property access by default... have to make our own.
 */
private class Interp extends hscript.Interp
{
    override function get(o:Dynamic, f:String):Dynamic
	{
        if (o == null) throw hscript.Expr.Error.EInvalidAccess(f);
        return Reflect.getProperty(o, f);
    }

    override function set(o:Dynamic, f:String, v:Dynamic):Dynamic
	{
        if (o == null) throw hscript.Expr.Error.EInvalidAccess(f);
        Reflect.setProperty(o, f, v);
        return v;
    }
}