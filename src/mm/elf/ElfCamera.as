﻿package mm.elf
{
	import flash.geom.Point;
	import mm.elf.utils.SceneUtil;
	import mm.elf.vo.BaseElement;
	import mm.elf.ElfScene;
	import mm.elf.ElfCharacter;
	import mm.elf.vo.BaseElement;

	/**
	 * 场景摄像机，继承BaseElement 
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class ElfCamera extends BaseElement
	{
        private const LIMEN_RATIO:Number = 0.05;	// 阀值率
        private const TWEEN_SPEED:Number = 0.4;

        private var x_limen:int = 200;
        private var y_limen:int = 116;
        private var _scene:ElfScene;								// 当前场景
        private var _followCharacter:ElfCharacter;			// 跟随的角色对象
        private var _isLocked:Boolean = false;
        public var tileRangeXY:Point;							// 可见块范围

        public function ElfCamera(scene:ElfScene)
		{
            _scene = scene;
            updateRangeXY();
        }
		
		/**
		 * 锁定, 不移动(run)
		 */
        public function lock():void
		{
            _isLocked = true;
        }
        public function unlock():void
		{
            _isLocked = false;
        }
		
		/**
		 * 更新范围的位置 
		 */
        public function updateRangeXY():void
		{
            tileRangeXY = SceneUtil.getViewTileRangeXY(_scene);
            x_limen = _scene.sceneConfig.width * LIMEN_RATIO;
            y_limen = _scene.sceneConfig.height * LIMEN_RATIO;
        }
		
		/**
		 * 对象能被摄像机看到
		 * tile_x, tile_y是地图中点的位置
		 * tileRangXY是场景内地中点位置
		 */
        public function canSee(sceneChar:ElfCharacter):Boolean
		{
            return sceneChar.tile_x > (tile_x - tileRangeXY.x) && 
				sceneChar.tile_x < (tile_x + tileRangeXY.x) && 
				sceneChar.tile_y > (tile_y - tileRangeXY.y) && 
				sceneChar.tile_y < (tile_y + tileRangeXY.y);
        }
		
		/**
		 * 锁定某个角色
		 */
        public function lookAt(sceneChar:ElfCharacter, b:Boolean=false):void
		{
            _followCharacter = sceneChar;
            run(b);
        }
		
		/**
		 * 移动摄像机位置, 跟随玩家, 并保持在场景之内
		 * 想象成拍电影的时候，摄影机跟着主角的过程
		 * 100遍都你还是看不明白，可以转行了，不过你也可以坚持到1w遍
		 */
        public function run(b:Boolean=true):void
		{
            if (_isLocked) {						// 锁定
                return;
            }
            if (_followCharacter == null) {			// 无跟随
                return;
            }

			// 将 point 对象从显示对象的（本地）坐标转换为舞台（全局）坐标
            var dstPoint:Point = new Point(_followCharacter.pixel_x, _followCharacter.pixel_y);
            dstPoint = _scene.localToGlobal(dstPoint);		// scrollRect
			
			var halfWidth:Number = 0;
			var widthDif:Number = 0; 	// 宽度差值
			var xResult:Number = 0;		// 场景的x坐标
			var xDifAvatar:Number = 0;
			var xLimenDif:Number = 0; 
			
			// 地图宽度 > 场景宽度
            if (_scene.mapConfig.width > _scene.sceneConfig.width) {
                halfWidth = _scene.sceneConfig.width * 0.5; // 场景宽度的一半
                widthDif = _scene.sceneConfig.width - _scene.mapConfig.width; // 场景宽度-地图宽度
                
				xDifAvatar = halfWidth - dstPoint.x;	// 场景宽度一半 - 角色全局坐标x
				
                if (xDifAvatar > x_limen) {
                    xLimenDif = xDifAvatar - x_limen;
                } else {
                    if (xDifAvatar < -x_limen){
                        xLimenDif = xDifAvatar + x_limen;
                    }
                }
                xResult = _scene.x + xLimenDif;
                if (xResult < widthDif) {
                    xResult = widthDif;
                }
                if (xResult > 0){
                    xResult = 0;
                }
                xDifAvatar = xResult - _scene.x;
                if (xDifAvatar != 0) {
                    if (!b) {
                        _scene.x = _scene.x + xDifAvatar;
                    } else {
                        _scene.x = (_scene.x + (xDifAvatar * TWEEN_SPEED));
                    }
                }
				// 场景 _scene.x 真有这么复杂
            } else {
				// 场景比地图大，地图就直接显示在中间
                halfWidth = _scene.mapConfig.width * 0.5;	// 地图宽度的一半
                xResult = (_scene.sceneConfig.width - _scene.mapConfig.width) / 2;
                if (_scene.x != xResult) {
                    _scene.x = xResult;
                }
            }
			
			var halfHeight:Number = 0;
			var heightDif:Number = 0;
			var yResult:Number = 0;		// 场景的y坐标
			var yDifAvatar:Number = 0;
			var yLimenDif:Number = 0; 
			// 地图高度 > 场景高度
            if (_scene.mapConfig.height > _scene.sceneConfig.height) {
                halfHeight = _scene.sceneConfig.height * 0.5;
                heightDif = _scene.sceneConfig.height - _scene.mapConfig.height;
				
                yDifAvatar = halfHeight - dstPoint.y; // 
				
                if (yDifAvatar > y_limen) {
                    yLimenDif = yDifAvatar - y_limen;
                } else {
                    if (yDifAvatar < -y_limen) {
                        yLimenDif = (yDifAvatar + y_limen);
                    }
                }
                yResult = _scene.y + yLimenDif;
                if (yResult < heightDif) {
                    yResult = heightDif;
                }
                if (yResult > 0) {
                    yResult = 0;
                }
                yDifAvatar = yResult - _scene.y;
                if (yDifAvatar != 0) {
                    if (!b){
                        _scene.y = (_scene.y + yDifAvatar);
                    } else {
                        _scene.y = (_scene.y + (yDifAvatar * TWEEN_SPEED));
                    }
                }
            } else {
				// 场景比地图大，地图就直接显示在中间
                halfHeight = _scene.mapConfig.height * 0.5;
                yResult = (_scene.sceneConfig.height - _scene.mapConfig.height) / 2;
                if (_scene.y != yResult) {
                    _scene.y = yResult;
                }
            }
			
			// 地图或者场景的尺寸的一半做为 pixel坐标，方便计算角色位置是否在摄像机内，see canSee()
            var halfPoint:Point = new Point(halfWidth, halfHeight);
            halfPoint = _scene.globalToLocal(halfPoint);
            pixel_x = halfPoint.x;
            pixel_y = halfPoint.y;
        }
    }
}