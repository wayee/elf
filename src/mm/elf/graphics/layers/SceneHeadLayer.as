package mm.elf.graphics.layers
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import mm.wit.utils.Fun;
	import mm.elf.ElfScene;
	import mm.elf.ElfCharacter;
	import mm.elf.ElfRender;
	import mm.elf.graphics.tagger.HeadFace;
	
	/**
	 * 角色附加信息层
	 * <li> 昵称
	 * <li> 称号
	 * <li> 血条
	 * <li> 其他图标，对话文字等
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class SceneHeadLayer extends Sprite
	{
		private var _scene:ElfScene;
		
		public function SceneHeadLayer(scene:ElfScene)
		{
			_scene = scene;
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
		
		/**
		 * 绘制  Scene.renderCharacters 中 headFace 非空的对象 
		 * <br> 角色头上的东东
		 * <li>对话浮动文字
		 */
		public function run():void
		{
			var sceneChar:ElfCharacter;
			var mouseRect:Rectangle;
			var ypos:Number;
			var nowTime:int = ElfRender.nowTime;
			var renderCharList:Array = _scene.renderCharacters;
			
			// 遍历每个可渲染对象
			for each (sceneChar in renderCharList) {
				if (sceneChar.headFace != null) {
					mouseRect = sceneChar.mouseRect || sceneChar.oldMouseRect;
					ypos = mouseRect!=null ? ((mouseRect.y - sceneChar.pixel_y) - HeadFace.HEADFACE_SPACE) : HeadFace.DEFAULT_HEADFACE_Y;
					if (sceneChar.headFace.y != ypos) {
						sceneChar.headFace.y = ypos;		// 更新 Y 值
					}
					sceneChar.headFace.checkTalkTime();		// 检查说话过期时间
				}
			}
		}
	}
}