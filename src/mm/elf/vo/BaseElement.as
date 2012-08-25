package mm.elf.vo
{
	import flash.display.DisplayObjectContainer;
	
	import mm.wit.utils.Fun;
	import mm.elf.vo.ShowContainer;
	import mm.elf.vo.map.SceneInfo;
	
	/**
	 * 场景元素基类
	 * <li>子类包含: SceneCharacter, MapTile, MapZone, SceneCamera 
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class BaseElement
	{
		public var id:int = 0;
		public var name:String = "";
		
		// 尺寸, 这里的块是个可变的概念, 可以为一个 TILE, 或者为1个ZONE
		public var tile_width:Number = SceneInfo.TILE_WIDTH;			// 块尺寸
		public var tile_height:Number = SceneInfo.TILE_HEIGHT;
		protected var _tile_x:int = 0;				// 块坐标
		protected var _tile_y:int = 0;
		protected var _pixel_x:Number = 0;			// 像素坐标
		protected var _pixel_y:Number = 0;
		
		public var data:Object;						// 任意数据
		public var showContainer:ShowContainer;		// Sprite, 关联的容器, 启用时, 需要设置它的父容器
		private var _useContainer:Boolean = false;	// 是否使用容器
		
		/**
		 * 像素坐标x
		 * <li> 设置 _pixel_x/y, _tile_x/y, showContainer.x/y
		 */
		public function get pixel_x():Number
		{
			return _pixel_x;
		}
		public function set pixel_x(value:Number):void
		{
			_pixel_x = value;
			_tile_x = Math.ceil(_pixel_x / tile_width);
			if (showContainer != null && showContainer.x != _pixel_x) {
				showContainer.x = _pixel_x;				// 移动关联容器
			}
		}
		
		/**
		 * 像素坐标y
		 */
		public function get pixel_y():Number
		{
			return _pixel_y;
		}
		public function set pixel_y(value:Number):void
		{
			_pixel_y = value;
			_tile_y = Math.ceil(_pixel_y / tile_height);
			if (showContainer != null && showContainer.y != _pixel_y) {
				showContainer.y = _pixel_y;
			}
		}
		
		/**
		 * 块坐标 x
		 */
		public function get tile_x():int
		{
			return _tile_x;
		}
		public function set tile_x(value:int):void
		{
			_tile_x = value;
			_pixel_x = _tile_x * tile_width;
			if (showContainer != null && showContainer.x != _pixel_x) {
				showContainer.x = _pixel_x;				// 移动关联容器
			}
		}
		
		/**
		 * 块坐标 y
		 */
		public function get tile_y():int
		{
			return _tile_y;
		}
		public function set tile_y(value:int):void
		{
			_tile_y = value;
			_pixel_y = _tile_y * tile_height;
			if (showContainer != null && showContainer.y != _pixel_y) {
				showContainer.y = _pixel_y;
			}
		}
		
		/**
		 * 是否使用容器 
		 * @return bool
		 */
		public function get useContainer():Boolean
		{
			return _useContainer;
		}
		
		/**
		 * 启用关联容器
		 * <li> ShowContainer的坐标值和_pixel_x, _pixel_y一致
		 * 
		 * @param parent 关联容器的父容器, 如 Scene.sceneHeadLayer
		 * @param visible 可见性
		 */
		public function enableContainer(parent:DisplayObjectContainer=null, visible:Boolean=true):void
		{
			_useContainer = true;
			if (showContainer == null) {
				showContainer = new ShowContainer();
				showContainer.x = _pixel_x;
				showContainer.y = _pixel_y;
			}
			showContainer.visible = visible;
			if (parent != null) {
				parent.addChild(showContainer);
			}
		}
		
		/**
		 * 删除关联容器
		 */
		public function disableContainer():void
		{
			_useContainer = false;
			if (showContainer != null) {
				if (showContainer.parent != null) {
					showContainer.parent.removeChild(showContainer);
				}
				Fun.clearChildren(showContainer, true);
				showContainer = null;
			}
		}
	}
}