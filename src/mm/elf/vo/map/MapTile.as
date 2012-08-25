package mm.elf.vo.map
{
	import mm.elf.vo.BaseElement;

	/**
	 * 地图块，继承BaseElement
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class MapTile extends BaseElement
	{
		public var isSolid:Boolean;
		public var isIsland:Boolean;
		public var isMask:Boolean;
		public var isTransport:Boolean;
		
		/**
		 * @param tileX,tileY 块坐标
		 * @param isSolid isSolid 障碍
		 * @param isIsland isIsland 通过
		 * @param isMask isMask 遮罩（遮挡表示）
		 * @param isTransport isTransport 传送点
		 */
		public function MapTile(tileX:int, tileY:int, PisSolid:Boolean=false, PisIsland:Boolean=false, PisMask:Boolean=false, PisTransport:Boolean=false)
		{
			this.tile_x = tileX;
			this.tile_y = tileY;
			this.isSolid = PisSolid;
			this.isIsland = PisIsland;
			this.isMask = PisMask;
			this.isTransport = PisTransport;
		}
	}
}