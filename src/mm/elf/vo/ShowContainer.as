package mm.elf.vo
{
	import flash.display.Sprite;

	/**
	 * 人物附加的一些对象管理
	 * <li> 血条、昵称、称号和对话文字等
	 * <li> 攻击的文字
	 * <li> 自定义对象，如图标等
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class ShowContainer extends Sprite
	{
		private var _headFaceContainer:Sprite;
		private var _showHeadFaceContainer:Boolean = true;
		
		private var _attackFaceContainer:Sprite;
		private var _showAttackFaceContainer:Boolean = true;
		
		private var _customFaceContainer:Sprite;
		private var _showCustomFaceContainer:Boolean = true;
		
		/**
		 * 血条、昵称和称号等的容器
		 */
		public function get headFaceContainer():Sprite
		{
			if (_headFaceContainer == null) {
				_headFaceContainer = new Sprite();
				if (_showHeadFaceContainer) {
					showHeadFaceContainer();
				}
			}
			return _headFaceContainer;
		}
		
		/**
		 * 显示血条和昵称 
		 */
		public function showHeadFaceContainer():void
		{
			_showHeadFaceContainer = true;
			if (_headFaceContainer != null && _headFaceContainer.parent != this) {
				addChild(_headFaceContainer);
			}
		}

		/**
		 * 隐藏血条和昵称 
		 */
		public function hideHeadFaceContainer():void
		{
			_showHeadFaceContainer = false;
			if (_headFaceContainer != null && _headFaceContainer.parent != null) {
				_headFaceContainer.parent.removeChild(_headFaceContainer);
			}
		}
		
		/**
		 * 攻击与被攻击动画（文字）的容器
		 */
		public function get attackFaceContainer():Sprite
		{
			if (_attackFaceContainer == null) {
				_attackFaceContainer = new Sprite();
				if (_showAttackFaceContainer) {
					showAttackFaceContainer();
				}
			}
			return _attackFaceContainer;
		}
		
		/**
		 * 显示攻击文字动画 
		 */
		public function showAttackFaceContainer():void
		{
			_showAttackFaceContainer = true;
			if (_attackFaceContainer != null && _attackFaceContainer.parent != this) {
				addChild(_attackFaceContainer);
			}
		}
		
		/**
		 * 隐藏攻击文字动画 
		 */
		public function hideAttackFaceContainer():void
		{
			_showAttackFaceContainer = false;
			if (_attackFaceContainer != null && _attackFaceContainer.parent != null) {
				_attackFaceContainer.parent.removeChild(_attackFaceContainer);
			}
		}
		
		/**
		 * 自定义的显示对象的容器
		 */
		public function get customFaceContainer():Sprite
		{
			if (_customFaceContainer == null) {
				_customFaceContainer = new Sprite();
				if (_showCustomFaceContainer) {
					showCustomFaceContainer();
				}
			}
			return _customFaceContainer;
		}
		
		/**
		 * 显示自定义对象 
		 */
		public function showCustomFaceContainer():void
		{
			_showCustomFaceContainer = true;
			if (_customFaceContainer != null && _customFaceContainer.parent != this) {
				addChild(_customFaceContainer);
			}
		}
		
		/**
		 * 隐藏自定义对象 
		 */
		public function hideCustomFaceContainer():void
		{
			_showCustomFaceContainer = false;
			if (_customFaceContainer != null && _customFaceContainer.parent != null) {
				_customFaceContainer.parent.removeChild(_customFaceContainer);
			}
		}
	}
}