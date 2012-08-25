package mm.elf.helper
{
	import com.greensock.TweenLite;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mm.elf.ElfCharacter;
	import mm.elf.graphics.tagger.AttackFace;
	import mm.elf.graphics.tagger.HeadFace;

	/**
	 * headface助手, attackface的显示/动画
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class TaggerHelper
	{
        private static var xDis:Number = 100;
        private static var yDis:Number = 70;
        private static var xyDis:Number = ((xDis + yDis) / 2) * Math.cos(Math.PI / 4);
        private static var YDis:Number = 20;
        private static var duration:Number = 1.2;

		/**
		 * 给角色添加  headFace
		 */
        public static function showHeadFace(sceneChar:ElfCharacter, nickName:String="", 
											nickNameColor:uint=0xFFFFFF, customTitle:String="", 
											leftIcon:DisplayObject=null, topIcon:DisplayObject=null):void
		{
            var headFace:HeadFace;
            if (!sceneChar.usable) {
                return;
            }
			
			// 是主玩家, 或者该类型可见
            var containerVisible:Boolean = sceneChar == sceneChar.scene.mainChar || sceneChar.scene.getCharVisible(sceneChar.type);
			
			// 把  container 添加到 sceneHeadLayer 中
            sceneChar.enableContainer(sceneChar.scene.sceneHeadLayer, containerVisible);	
			
			// 建立 headFace
            if (sceneChar.headFace == null) {
                headFace = HeadFace.createHeadFace(nickName, nickNameColor, customTitle, leftIcon, topIcon);
                sceneChar.headFace = headFace;
                if (sceneChar.scene.getCharHeadVisible(sceneChar.type)){
                    sceneChar.showContainer.showHeadFaceContainer();	// 显示/隐藏
                } else {
                    sceneChar.showContainer.hideHeadFaceContainer();
                }
                sceneChar.showContainer.headFaceContainer.addChild(headFace);
            } else {
                headFace = sceneChar.headFace;
                headFace.reSet([nickName, nickNameColor, customTitle, leftIcon, topIcon]);
            }
            headFace.x = 0;
            var rect:Rectangle = sceneChar.mouseRect || sceneChar.oldMouseRect;
            headFace.y = rect!=null ? ((rect.y - sceneChar.pixel_y) - HeadFace.HEADFACE_SPACE) : HeadFace.DEFAULT_HEADFACE_Y;
        }
		
        private static function myEaseOut(_arg1:Number, _arg2:Number, _arg3:Number, _arg4:Number, _arg5:Number=6):Number
		{
            _arg1 = ((_arg1 / _arg4) - 1);
            return (_arg3 * (((_arg1 * _arg1) * (((_arg5 + 1) * _arg1) + _arg5)) + 1)) + _arg2;
        }
		
		/**
		 * 给角色添加  attackFace
		 */
        public static function showAttackFace(sceneChar:ElfCharacter, attackType:String="", 
											  attackValue:int=0, selfText:String="",
											  selfFontSize:uint=0, selfFontColor:uint=0):void
		{
            var attackFace:AttackFace = null;
            var onComplete:Function = null;
			
			// 播放结束后, 删除 attackFace 对象
            onComplete = function ():void{
                if (attackFace.parent){
                    attackFace.parent.removeChild(attackFace);
                }
                AttackFace.recycleAttackFace(attackFace);
            }
            if (!sceneChar.usable){
                return;
            }
			
			// 可见性标志
            var containerVisible:* = (((sceneChar == sceneChar.scene.mainChar)) || (sceneChar.scene.getCharVisible(sceneChar.type)));
            sceneChar.enableContainer(sceneChar.scene.sceneHeadLayer, containerVisible);
			
			// 建立  attackFace
//            attackFace = AttackFace.createAttackFace(attackType, attackValue, selfText, selfFontSize, selfFontColor);
			attackFace = AttackFace.createAttackFace('', '');
            var mouseRect:Rectangle = sceneChar.mouseRect || sceneChar.oldMouseRect;
            var from:Point = new Point(0, mouseRect != null ? (mouseRect.y - sceneChar.pixel_y) + YDis : (-40 + YDis));
            var to:Point = from.clone();
            var dir:int = attackFace.dir;
            if (dir == 2){
                to.x = (from.x - xDis);		// 向左
            } else {
                if (dir == 3){
                    to.x = (from.x - xyDis);		// 向左
                    to.y = (from.y - xyDis);		// 向上
                } else {
                    if (dir == 6){
                        to.x = (from.x + xDis);		// 向右
                    } else {
                        to.y = (from.y - yDis);		// 向上
                    }
                }
            }
            attackFace.x = from.x;
            attackFace.y = from.y;
			
			// 显示/隐藏
            if (sceneChar.scene.getCharAvatarVisible(sceneChar.type)){
                sceneChar.showContainer.showAttackFaceContainer();
            } else {
                sceneChar.showContainer.hideAttackFaceContainer();
            }
            sceneChar.showContainer.attackFaceContainer.addChild(attackFace);
			
			// 动画
            TweenLite.to(attackFace, duration, {
                x:to.x,
                y:to.y,
                onComplete:onComplete,
                ease:myEaseOut
            });
        }
		
		/**
		 * 获取 CustomFace
		 */
        public static function getCustomFaceByName(sceneChar:ElfCharacter, faceName:String):DisplayObject
		{
            if (!sceneChar.usable || !sceneChar.useContainer) {
                return (null);
            }
            var face:DisplayObject = sceneChar.showContainer.customFaceContainer.getChildByName(faceName);
            return face;
        }
		
		/**
		 * 添加 CustomFace
		 */
        public static function addCustomFace(sceneChar:ElfCharacter, face:DisplayObject):void
		{
            if (!sceneChar.usable) {
                return;
            }
            var isVisible:Boolean = sceneChar == sceneChar.scene.mainChar || sceneChar.scene.getCharVisible(sceneChar.type);
            sceneChar.enableContainer(sceneChar.scene.sceneHeadLayer, isVisible);
            if (sceneChar.scene.getCharAvatarVisible(sceneChar.type)) {
                sceneChar.showContainer.showCustomFaceContainer();
            } else {
                sceneChar.showContainer.hideCustomFaceContainer();
            }
            sceneChar.showContainer.customFaceContainer.addChild(face);
        }
		
		/**
		 * 删除
		 */
        public static function removeCustomFace(sceneChar:ElfCharacter, face:DisplayObject):void
		{
            if (!sceneChar.usable || !sceneChar.useContainer) {
                return;
            }
            if (face.parent) {
                face.parent.removeChild(face);
            }
        }
		
		/**
		 * 根据实例名字删除
		 */
        public static function removeCustomFaceByName(sceneChar:ElfCharacter, faceName:String):void
		{
            if (!sceneChar.usable || !sceneChar.useContainer) {
                return;
            }
            var face:DisplayObject = sceneChar.showContainer.customFaceContainer.getChildByName(faceName);
            if (face != null) {
                sceneChar.showContainer.customFaceContainer.removeChild(face);
            }
        }
    }
}