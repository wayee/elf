package mm.elf.events
{
	/**
	 * 场景事件动作 - 移动类型
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class ElfEventActionWalk
	{
        public static const READY:String = "ElfEventActionWalk.READY";			// 预备
        public static const THROUGH:String = "ElfEventActionWalk.THROUGH";		// 经过
        public static const ARRIVED:String = "ElfEventActionWalk.ARRIVED";		// 到达
        public static const UNABLE:String = "ElfEventActionWalk.UNABLE";			// 失败
//        public static const JUMP_READY:String = "ElfEventActionWalk.JUMP_READY";
//        public static const JUMP_THROUGH:String = "ElfEventActionWalk.JUMP_THROUGH";
//        public static const JUMP_ARRIVED:String = "ElfEventActionWalk.JUMP_ARRIVED";
//        public static const JUMP_UNABLE:String = "ElfEventActionWalk.JUMP_UNABLE";
        public static const ON_TRANSPORT:String = "ElfEventActionWalk.ON_TRANSPORT";		// 到达传送门
        public static const SEND_PATH:String = "ElfEventActionWalk.SEND_PATH";			// 发送路径
        public static const SEND_JUMP_PATH:String = "ElfEventActionWalk.SEND_JUMP_PATH";
    }
}