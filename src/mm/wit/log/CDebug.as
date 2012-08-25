package mm.wit.log
{
	import flash.external.ExternalInterface;
	import flash.utils.describeType;
	
	/**
	 * 谁用谁知道，还等什么？ Laughing Gor 居然终身监禁 了，期待续集
	 * 辅助类，提供了调试相关的扩展
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */	
	public final class CDebug
	{
		public static var DEBUG:Boolean = false;
		
		public static function print_r(o:Object):String
		{
			var str:String = '';
			trace('   =object start');
			for (var val:* in o) {
				trace('   [' + typeof(o[val]) + '] ' + val + ' => ' + o[val]);
				str += '   [' + typeof(o[val]) + '] ' + val + ' => ' + o[val];
				if (typeof(o[val]) == 'object') {
					print_r(o[val]);
				}
			}
			trace('   =object end');
			return str;
		}
		
		public static function get isBrower():Boolean
		{
			return ExternalInterface.available;
		}
		
		public static function getString(obj:Object):String
		{
			return convertToString(obj);
		}
		
		private static function convertToString( value:* ):String 
		{
			if ( value is String ) {
				return escapeString( value as String );
				
			} else if ( value is Number ) {
				return isFinite( value as Number) ? value.toString() : "null";
				
			} else if ( value is Boolean ) {
				return value ? "true" : "false";
				
			} else if ( value is Array ) {
				return arrayToString( value as Array );
				
			} else if ( value is Object && value != null ) {
				return objectToString( value );
			}
			return "null";
		}
		
		private static function escapeString( str:String ):String 
		{
			var s:String = "";
			var ch:String;
			var len:Number = str.length;
			for ( var i:int = 0; i < len; i++ ) {
				
				ch = str.charAt( i );
				switch ( ch ) {
					
					case '"':	// quotation mark
						s += "\\\"";
						break;
					
					//case '/':	// solidus
					//	s += "\\/";
					//	break;
					
					case '\\':	// reverse solidus
						s += "\\\\";
						break;
					
					case '\b':	// bell
						s += "\\b";
						break;
					
					case '\f':	// form feed
						s += "\\f";
						break;
					
					case '\n':	// newline
						s += "\\n";
						break;
					
					case '\r':	// carriage return
						s += "\\r";
						break;
					
					case '\t':	// horizontal tab
						s += "\\t";
						break;
					
					default:	// everything else
						if ( ch < ' ' ) {
							var hexCode:String = ch.charCodeAt( 0 ).toString( 16 );
							var zeroPad:String = hexCode.length == 2 ? "00" : "000";
							s += "\\u" + zeroPad + hexCode;
						} else {
							s += ch;
						}
				}	// end switch
				
			}	// end for loop
			
			return  s;
		}
		
		private static function arrayToString( a:Array ):String
		{
			var s:String = "";
			for ( var i:int = 0; i < a.length; i++ ) {
				if ( s.length > 0 ) {
					s += ","
				}
				s += convertToString( a[i] );	
			}
			return "[" + s + "]";
		}
		
		private static function objectToString( o:Object ):String
		{
			var s:String = "";
			var classInfo:XML = describeType( o );
			if ( classInfo.@name.toString() == "Object" )
			{
				var value:Object;
				for ( var key:String in o )
				{
					value = o[key];
					if ( value is Function )
					{
						continue;
					}
					if ( s.length > 0 ) {
						s += " | "
					}
					
					s += escapeString( key ) + " = " + convertToString( value );
				}
			}
			else // o is a class instance
			{
				for each ( var v:XML in classInfo..*.( name() == "variable" || name() == "accessor" ) )
				{
					if ( s.length > 0 ) {
						s += " | "
					}
					
					s += escapeString( v.@name.toString() ) + " = " 
						+ convertToString( o[ v.@name ] );
				}
				
			}
			
			return "{" + s + "}\n";
		}
		
		public function CDebug()
		{    
			throw new Error("CDebug class is static class only");    
		}  
	}
}