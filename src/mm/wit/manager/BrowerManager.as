package mm.wit.manager
{
	import flash.external.ExternalInterface;
	import flash.net.URLVariables;
	
	import mm.wit.utils.Singleton;
	
	/**
	 * 通过JS与浏览器通讯
	 * 
	 * @author flashyiyi
	 * 
	 */
	public class BrowerManager extends Singleton
	{
		[Embed(source = "BrowerManager.js",mimeType="application/octet-stream")]
		private static var jsCode:Class;
		ExternalInterface.available && ExternalInterface.call("eval",new jsCode().toString());
		
		static public function get instance():BrowerManager
		{
			return Singleton.getInstanceOrCreate(BrowerManager) as BrowerManager;
		}
		
		/**
		 * 浏览器完整地址
		 */
		public function get url():String
        {
        	return ExternalInterface.call("BrowerManager.getURL");
        }
		
        /**
         * 浏览器除去参数后的地址
         */        
        public function get baseUrl():String
        {
        	var url:String = this.url;
        	var p:int = url.indexOf("#");
        	if (p>0) {
        		return url.substr(0,p - 1);
			}
       		return url;
        }
		
        /**
         * 浏览器标题
         */        
        public function set title(v:String):void
        {
        	ExternalInterface.call("BrowerManager.setTitle",v);
        }
        public function get title():String
        {
        	return ExternalInterface.call("BrowerManager.getTitle");
        }
		
        /**
         * 浏览器地址栏参数
         */        
        public function set urlVariables(values:URLVariables):void
        {
        	var url:String = "";
        	var para:String = values.toString();
        	if (para.length>0)
        	 	url += "#" + para;
        	
        	ExternalInterface.call("BrowerManager.setUrlVariables",url);
        }
        public function get urlVariables():URLVariables
        {
        	var url:String = this.url;
        	var p:int = url.indexOf("#");
        	if (p>0)
        		return new URLVariables(url.substr(p + 1));
        	else
        		return new URLVariables();
        }

		/**
         * 加入收藏夹 
         */        
        public function addFavorite(title:String=null,url:String=null):void
        {
        	if (!url)
        		url = this.url;
        	
        	if (!title)
        		title = this.title;
        		
        	ExternalInterface.call("BrowerManager.addFavorite",url,title);
        }
		
        /**
         * 设为主页
         */        
        public function setHomePage(url:String=null):void
        {
        	if (!url)
        		url = this.url;
        		
        	ExternalInterface.call("BrowerManager.setHomePage",url);
        }

		/**
         * 设置cookie
         * 
         * @param name           cookie名称
		 * @param value          cookie值
		 * @param expires        cookie过期时间
		 * @param security       是否加密
         */
        public function setCookie(name:String, value:String, expires:Date=null, security:Boolean=false):void
        {
        	expires || (expires = new Date(new Date().time + (1000 * 86400 * 365)));
        	ExternalInterface.call("BrowerManager.setCookie",name,value,expires.time,security);
        }
        
        /**
         * 读取cookie
         * @param name	cookie名称
         */        
        public function getCookie(name:String):String
        {
        	return ExternalInterface.call("BrowerManager.getCookie",name);
        }
        
        /**
         * 在浏览器关闭时提供确认提示
         */
        public function confirmClose(text:String = "确认退出？"):void
        {
			if (text)
        		ExternalInterface.call("BrowerManager.confirmClose",text);
			else
				ExternalInterface.call("BrowerManager.confirmClose");
		}
		
		/**
		 * 弹出警示框
		 */
		public function alert(...params):void
		{
			ExternalInterface.call("alert",params.toString());
		}
		
		/**
		 * 刷新浏览器 
		 */
		public function reload():void
		{
			ExternalInterface.call("location.reload");
		}
		
		/**
		 * 消除浏览器的滚动事件干扰 
		 */
		public function disableScroll(objId:String = null):void
		{
			ExternalInterface.call("BrowerManager.disableScroll",objId);
		}
	}
}