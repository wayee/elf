package mm.elf.vo.map
{
	import flash.display.DisplayObjectContainer;
	
	import mm.elf.vo.BaseElement;

	/**
	 * 地图族
	 * <br>zone.showContainer (ShowContainer)被添加到自己的孩子中
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class MapZone extends BaseElement
	{
		public function MapZone(mapLayer:DisplayObjectContainer)
		{
			enableContainer(mapLayer);
		}
	}
} 
