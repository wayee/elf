package mm.elf.graphics.layers
{
	import flash.display.Sprite;
	import mm.wit.utils.Fun;
	import mm.elf.ElfScene;

	/**
	 * 小地图层
	 *  <li> 显示小地图
	 * 	<li> mouseEnabled = false;
	 * 	<li> mouseChildren = false;
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class SceneSmallMapLayer extends Sprite
	{
        private var _scene:ElfScene;

        public function SceneSmallMapLayer(scene:ElfScene)
		{
            this._scene = scene;
            mouseEnabled = false;
            mouseChildren = false;
        }
        
		/**
		 * 释放资源 
		 */
		public function dispose():void
		{
            Fun.clearChildren(this, false, false);
        }
    }
}