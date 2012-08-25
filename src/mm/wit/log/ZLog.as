package mm.wit.log
{
	import flash.text.TextField;
	
	import mm.wit.handler.HandlerThread;
	import mm.wit.manager.HandlerManager;

	/**
	 * 日志信息的显示
	 * 老大，日志信息很重要，请善用此工具
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class ZLog
	{
		private static const _logHt:HandlerThread = HandlerManager.creatNewHandlerThread();	// 线程
		
		public static var enableLog:Boolean = true;
		public static var enableTrace:Boolean = true;
		public static var enableShowInLogArea:Boolean = false;
		public static var max_log_num:Number;
		private static var _logArea:TextField;
		private static var _logNum:Number;
		
		/**
		 * 初始化
		 * @param logArea 文本控件
		 * @param max_num 最大数量
		 * @param bTrace 是否 trace 出信息
		 * @param bArea 是否添加到 area
		 */
		public static function init(logArea:TextField=null, max_num:int=1000, 
									bTrace:Boolean=true, bArea:Boolean=false):void
		{
			enableLog = true;
			max_log_num = max_num;
			enableTrace = bTrace;
			enableShowInLogArea = bArea;
			_logArea = logArea;
			if (_logArea) {
				_logArea.text = "";
			}
			_logNum = 0;
		}
		
		/**
		 * 添加一条日志 
		 * @param log * 可以是字符串或者数组
		 */
		public static function add(log:*):void
		{
			if (!enableLog) {
				return;
			}
			var logString:String = (log is Array && log.length > 0) ? log.join(" ") : log;
			if (enableTrace) {
				trace(logString);
			}
			if (enableShowInLogArea && _logArea != null) {
				// 排队执行日志输出
				_logHt.push(doAdd, [logString], 10);		// 延时10 之后??
			}
		}
		
		/**
		 * 执行添加日志 
		 * @param log * 可以是字符串或者数组
		 */
		private static function doAdd(log:*):void
		{
			var index:int;
			if (enableShowInLogArea && _logArea != null) {
				_logArea.appendText(log + "\n");
				_logNum++;
				while (_logNum > max_log_num) {
					index = _logArea.text.indexOf("\r");
					// 使用 newText 参数的内容替换 beginIndex 和 endIndex 参数指定的字符范围
					_logArea.replaceText(0, index != -1 ? index + 1 : 0, "");
					_logNum--;
				}
			}
		}
	}
}