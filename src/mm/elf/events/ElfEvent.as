package mm.elf.events
{
	import flash.events.Event;
	
	import mm.wit.event.BaseEvent;

	/**
	 * 场景事件
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class ElfEvent extends BaseEvent
	{
        public static const INTERACTIVE:String = "ElfEvent.interactive";
        public static const WALK:String = "ElfEvent.walk";
        public static const STATUS:String = "ElfEvent.status";
        public static const PROCESS:String = "ElfEvent.process";

		/**
		 * 场景事件类 
		 * @param type 事件类型
		 * @param action 事件动作
		 * @param data 事件数据
		 * @param bubbles 是否冒泡
		 * @param cancelable 否可以阻止与事件相关联的行为
		 * 
		 */
        public function ElfEvent(type:String, action:String="", data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
            super(type, action, data, bubbles, cancelable);
        }
		
        override public function clone():Event
		{
            return new ElfEvent(type, action, data, bubbles, cancelable);
        }
		
        override public function toString():String
		{
            return "[ElfEvent]";
        }
    }
}