package mm.elf
{
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import mm.elf.tools.SceneCache;

	/**
	 * 场景渲染器
	 * <br> 监听每帧，进行一次渲染
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class ElfRender
	{
        public static var nowTime:int;			// 当前时间点

        private var _scene:ElfScene;
        private var _isRendering:Boolean = false;	// 是否绘制标志, 如果在加载中, 可以不绘制

        public function ElfRender(scene:ElfScene)
		{
            _scene = scene;
        }
		
		/**
		 * 开始侦听, 通过  Event.ENTER_FRAME
		 */
        public function startRender(renderNow:Boolean=false):void
		{
            if (renderNow) {
                render();
            }
			
            if ( !_isRendering ) {
                _scene.addEventListener(Event.ENTER_FRAME, render);
                _isRendering = true;
            }
        }
		
		/**
		 * 停止侦听, 删除  Event.ENTER_FRAME
		 */
        public function stopRender():void
		{
            if (_isRendering) {
                _scene.removeEventListener(Event.ENTER_FRAME, render);
                _isRendering = false;
            }
        }
		
		/**
		 * 渲染一帧
		 */
        private function render(e:Event=null):void
		{
            nowTime = getTimer();
            var charList:Array = _scene.sceneCharacters;
            
            var sceneChar:ElfCharacter;
			for each (sceneChar in charList) {
                sceneChar.runWalk();				// 人物移动
            }
			
            _scene.sceneCamera.run();				// 相机跟随 
            _scene.sceneMapLayer.run();				// 地图跟随
            _scene.sceneAvatarLayer.run();			// 绘制人物
			_scene.sceneHeadLayer.run();			// 绘制血条、昵称和称号等文本, 更新 Y 值
			
			// 自定义资源回收处理
            SceneCache.checkUninstall();
        }
    }
}