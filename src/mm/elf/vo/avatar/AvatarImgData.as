﻿package mm.elf.vo.avatar
{
	import flash.display.BitmapData;

	/**
	 * 角色位图数据
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class AvatarImgData
	{
        public var dir07654:BitmapData;			// 正像 angle => 0 4567
        public var dir123:BitmapData;			// 镜像 angle => 123
        public var useNum:int;

        public function AvatarImgData(positive:BitmapData, negative:BitmapData=null, num:int=1)
		{
            dir07654 = positive;
            dir123 = negative;
            useNum = num;
        }
    }
}