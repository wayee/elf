package mm.wit.reflection
{
	import flash.display.DisplayObject;
	import flash.system.ApplicationDomain;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;

	/**
	 * 反射工具类
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class Reflection
	{
		public static function createDisplayObjectInstance(fullClassName:String, applicationDomain:ApplicationDomain=null):DisplayObject{
			return createInstance(fullClassName, applicationDomain) as DisplayObject;
		}
		
		public static function createInstance(fullClassName:String, applicationDomain:ApplicationDomain=null):*{
			var assetClass:Class = getClass(fullClassName, applicationDomain);
			if(assetClass != null){
				return new assetClass();
			}
			return null;		
		}
		
		public static function getClass(fullClassName:String, applicationDomain:ApplicationDomain=null):Class{
			if(applicationDomain == null){
				applicationDomain = ApplicationDomain.currentDomain;
			}
			var assetClass:Class = applicationDomain.getDefinition(fullClassName) as Class; // getDefinitionByName
			return assetClass;		
		}
		
		public static function getSuperclassName(o:*):String{
			return getQualifiedSuperclassName(o);
		}
		
		public static function getFullClassName(o:*):String{
			return getQualifiedClassName(o);
		}
		
		public static function getClassName(o:*):String{
			var name:String = getFullClassName(o);
			var lastI:int = name.lastIndexOf(".");
			if(lastI >= 0){
				name = name.substr(lastI+1);
			}
			return name;
		}
		
		public static function getPackageName(o:*):String{
			var name:String = getFullClassName(o);
			var lastI:int = name.lastIndexOf(".");
			if(lastI >= 0){
				return name.substring(0, lastI);
			}else{
				return "";
			}
		}
		
		public function Reflection () {
			throw new Error("Reflection class is static class only");    
		}  
	}
}
