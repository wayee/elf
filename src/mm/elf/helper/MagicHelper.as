﻿package mm.elf.helper
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	
	import flash.geom.Point;
	
	import mm.elf.ElfScene;
	import mm.elf.ElfCharacter;
	import mm.elf.graphics.avatar.AvatarPart;
	import mm.elf.utils.StaticData;
	import mm.elf.vo.avatar.AvatarParamData;
	import mm.elf.vo.avatar.AvatarPlayCondition;
	import mm.wit.handler.HandlerHelper;
	import mm.wit.utils.ZMath;

	/**
	 * 法术助手
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class MagicHelper
	{
		/**
		 * 1对多施法
		 * @param fromSceneChar 触发角色对象
		 * @param toArray 施予对象数组
		 * @param fromApd 触发对象的特效
		 * @param toApd 施予对象的特效
		 * @param passApd 过场特效
		 * 
		 */
        public static function showMagic_from1passNtoN(fromSceneChar:ElfCharacter, 
							   toArray:Array, fromApd:AvatarParamData=null, 
							   toApd:AvatarParamData=null, passApd:AvatarParamData=null):void
		{
            var hasRun:Boolean = false;
            var showAttack:Function = null;
            var toSceneChar:ElfCharacter = null;
            showAttack = function():void
			{
                if (hasRun) {
                    return;
                }
                hasRun = true;
                showMagic(fromSceneChar, toArray, fromApd, toApd, passApd);
            };
            if (toArray.length == 1) {
                toSceneChar = toArray[0];
                fromSceneChar.faceTo(toSceneChar.pixel_x, toSceneChar.pixel_y);
            }
            if (fromSceneChar.type != StaticData.CHARACTER_TYPE_DUMMY) {
                fromSceneChar.playTo(StaticData.STATUS_TYPE_MAGIC_ATTACK, -1, -1, new AvatarPlayCondition(true));
                fromSceneChar.showAttack = showAttack;
            } else {
                showAttack();
            }
            hasRun = false;
        }
		
		/**
		 * 1对某点范围内所有角色对象施法
		 * @param fromSceneChar 触发角色对象
		 * @param toPoint 施予对象所在点
		 * @param fromApd 触发对象的特效
		 * @param toApd 施予对象的特效
		 * @param passApd 过场特效
		 * 
		 */
        public static function showMagic_from1pass1toPointArea(fromSceneChar:ElfCharacter, 
								toPoint:Point, fromApd:AvatarParamData=null, 
								toApd:AvatarParamData=null, passApd:AvatarParamData=null):void
		{
            var hasRun:Boolean = false;
            var showAttack:Function = null;
            showAttack = function():void
			{
                var scene:ElfScene = null;
                var new_onPlayComplete:Function = function(sceneChar1:ElfCharacter=null, part:AvatarPart=null):void
				{
                    scene.removeCharacter(sceneChar1);
                };
                if (hasRun) {
                    return;
                }
                hasRun = true;
                scene = fromSceneChar.scene;
                var toSceneChar:ElfCharacter = scene.createSceneCharacter(StaticData.CHARACTER_TYPE_DUMMY);
                toSceneChar.setXY(toPoint.x, toPoint.y);
                toApd = toApd || new AvatarParamData();
                toApd.extendCallBack(null, null, null, new_onPlayComplete);
                showMagic(fromSceneChar, [toSceneChar], fromApd, toApd, passApd);
            }
            fromSceneChar.faceTo(toPoint.x, toPoint.y);
            if (fromSceneChar.type != StaticData.CHARACTER_TYPE_DUMMY) {
                fromSceneChar.playTo(StaticData.STATUS_TYPE_MAGIC_ATTACK, -1, -1, new AvatarPlayCondition(true));
                fromSceneChar.showAttack = showAttack;
            } else {
                showAttack();
            }
            hasRun = false;
        }
        
		/**
		 * 1对某区域内所有角色对象施法（过场对N有效）
		 * @param fromSceneChar 触发角色对象
		 * @param toRectCenter 施予对象所在点
		 * @param toRectCenter 中心
		 * @param toRectHalfWidth 矩形宽度1/2
		 * @param toRectHalfHeight 矩形高度1/2
		 * @param showSpace 间距
		 * @param includeCenter 包括中心
		 * @param fromApd 触发对象的特效
		 * @param toApd 施予对象的特效
		 * @param passApd 过场特效
		 * 
		 */
		public static function showMagic_from1passNtoRectArea(fromSceneChar:ElfCharacter, 
								toRectCenter:Point, toRectHalfWidth:int, toRectHalfHeight:int, 
								showSpace:int=25, includeCenter:Boolean=true, fromApd:AvatarParamData=null, 
								toApd:AvatarParamData=null, passApd:AvatarParamData=null):void
		{
            var hasRun:Boolean = false;
            var showAttack:Function = null;
            showAttack = function ():void
			{
                var scene:ElfScene = null;
                var pixelX:Number = 0;
                var pixelY:Number = 0;
                var toSceneChar:ElfCharacter = null;
                var i:int = 0;
                var j:int = 0;
                var new_onPlayComplete:Function = function(sceneChar1:ElfCharacter=null, part:AvatarPart=null):void{
                    scene.removeCharacter(sceneChar1);
                }
                if (hasRun){
                    return;
                }
                hasRun = true;
                scene = fromSceneChar.scene;
                var toArr:Array = [];
                i = 0;
                while (i <= toRectHalfWidth) {
                    j = 0;
                    while (j <= toRectHalfHeight) {
                        if (i == 0 && j == 0) {
                            pixelX = toRectCenter.x;
                            pixelY = toRectCenter.y;
                            if (includeCenter) {
                                toSceneChar = scene.createSceneCharacter(StaticData.CHARACTER_TYPE_DUMMY);
                                toSceneChar.setXY(pixelX, pixelY);
                                toArr.push(toSceneChar);
                            }
                        } else {
                            if (i == 0 && j != 0) {
                                pixelX = toRectCenter.x;
                                pixelY = (toRectCenter.y + j);
                                toSceneChar = scene.createSceneCharacter(StaticData.CHARACTER_TYPE_DUMMY);
                                toSceneChar.setXY(pixelX, pixelY);
                                toArr.push(toSceneChar);
                                pixelX = toRectCenter.x;
                                pixelY = (toRectCenter.y - j);
                                toSceneChar = scene.createSceneCharacter(StaticData.CHARACTER_TYPE_DUMMY);
                                toSceneChar.setXY(pixelX, pixelY);
                                toArr.push(toSceneChar);
                            } else {
                                if (i != 0 && j == 0) {
                                    pixelX = (toRectCenter.x + i);
                                    pixelY = toRectCenter.y;
                                    toSceneChar = scene.createSceneCharacter(StaticData.CHARACTER_TYPE_DUMMY);
                                    toSceneChar.setXY(pixelX, pixelY);
                                    toArr.push(toSceneChar);
                                    pixelX = (toRectCenter.x - i);
                                    pixelY = toRectCenter.y;
                                    toSceneChar = scene.createSceneCharacter(StaticData.CHARACTER_TYPE_DUMMY);
                                    toSceneChar.setXY(pixelX, pixelY);
                                    toArr.push(toSceneChar);
                                } else {
                                    pixelX = (toRectCenter.x + i);
                                    pixelY = (toRectCenter.y + j);
                                    toSceneChar = scene.createSceneCharacter(StaticData.CHARACTER_TYPE_DUMMY);
                                    toSceneChar.setXY(pixelX, pixelY);
                                    toArr.push(toSceneChar);
                                    pixelX = (toRectCenter.x + i);
                                    pixelY = (toRectCenter.y - j);
                                    toSceneChar = scene.createSceneCharacter(StaticData.CHARACTER_TYPE_DUMMY);
                                    toSceneChar.setXY(pixelX, pixelY);
                                    toArr.push(toSceneChar);
                                    pixelX = (toRectCenter.x - i);
                                    pixelY = (toRectCenter.y + j);
                                    toSceneChar = scene.createSceneCharacter(StaticData.CHARACTER_TYPE_DUMMY);
                                    toSceneChar.setXY(pixelX, pixelY);
                                    toArr.push(toSceneChar);
                                    pixelX = (toRectCenter.x - i);
                                    pixelY = (toRectCenter.y - j);
                                    toSceneChar = scene.createSceneCharacter(StaticData.CHARACTER_TYPE_DUMMY);
                                    toSceneChar.setXY(pixelX, pixelY);
                                    toArr.push(toSceneChar);
                                }
                            }
                        }
                        j = (j + showSpace);
                    }
                    i = (i + showSpace);
                }
                toApd = toApd || new AvatarParamData();
                toApd.extendCallBack(null, null, null, new_onPlayComplete);
                showMagic(fromSceneChar, toArr, fromApd, toApd, passApd);
            }
            fromSceneChar.faceTo(toRectCenter.x, toRectCenter.y);
            if (fromSceneChar.type != StaticData.CHARACTER_TYPE_DUMMY) {
                fromSceneChar.playTo(StaticData.STATUS_TYPE_MAGIC_ATTACK, -1, -1, new AvatarPlayCondition(true));
                fromSceneChar.showAttack = showAttack;
            } else {
                showAttack();
            }
            hasRun = false;
        }
        
		/**
		 * 1对某区域内所有角色对象施法（过场只对一个有效）
		 * @param fromSceneChar 触发角色对象
		 * @param toRectCenter 施予对象所在点
		 * @param toRectCenter 中心
		 * @param toRectHalfWidth 矩形宽度1/2
		 * @param toRectHalfHeight 矩形高度1/2
		 * @param showSpace 间距
		 * @param includeCenter 包括中心
		 * @param fromApd 触发对象的特效
		 * @param toApd 施予对象的特效
		 * @param passApd 过场特效
		 * 
		 */
		public static function showMagic_from1pass1toRectArea(fromSceneChar:ElfCharacter, 
							  toRectCenter:Point, toRectHalfWidth:int, toRectHalfHeight:int, 
							  showSpace:int=25, includeCenter:Boolean=true, fromApd:AvatarParamData=null, 
							  toApd:AvatarParamData=null, passApd:AvatarParamData=null):void
		{
            var hasRun:Boolean = false;
            var showAttack:Function = null;
            showAttack = function():void
			{
                var scene:ElfScene = null;
                var toArr:Array = null;
                var pixelX:Number = 0;
                var pixelY:Number = 0;
                var toSceneChar:ElfCharacter = null;
                var centerSc:ElfCharacter = null;
                var i:int = 0;
                var j:int = 0;
                var new_onPlayComplete:Function = function(sceneChar1:ElfCharacter=null, part:AvatarPart=null):void
				{
                    scene.removeCharacter(sceneChar1);
                };
                if (hasRun) {
                    return;
                }
                hasRun = true;
                scene = fromSceneChar.scene;
                toArr = [];
                i = 0;
                while (i <= toRectHalfWidth) {
                    j = 0;
                    while (j <= toRectHalfHeight) {
                        if (i == 0 && j == 0) {
                            pixelX = toRectCenter.x;
                            pixelY = toRectCenter.y;
                            centerSc = scene.createSceneCharacter(StaticData.CHARACTER_TYPE_DUMMY);
                            centerSc.setXY(pixelX, pixelY);
                        } else {
                            if (i == 0 && j != 0) {
                                pixelX = toRectCenter.x;
                                pixelY = (toRectCenter.y + j);
                                toSceneChar = scene.createSceneCharacter(StaticData.CHARACTER_TYPE_DUMMY);
                                toSceneChar.setXY(pixelX, pixelY);
                                toArr.push(toSceneChar);
                                pixelX = toRectCenter.x;
                                pixelY = (toRectCenter.y - j);
                                toSceneChar = scene.createSceneCharacter(StaticData.CHARACTER_TYPE_DUMMY);
                                toSceneChar.setXY(pixelX, pixelY);
                                toArr.push(toSceneChar);
                            } else {
                                if (i != 0 && j == 0) {
                                    pixelX = (toRectCenter.x + i);
                                    pixelY = toRectCenter.y;
                                    toSceneChar = scene.createSceneCharacter(StaticData.CHARACTER_TYPE_DUMMY);
                                    toSceneChar.setXY(pixelX, pixelY);
                                    toArr.push(toSceneChar);
                                    pixelX = (toRectCenter.x - i);
                                    pixelY = toRectCenter.y;
                                    toSceneChar = scene.createSceneCharacter(StaticData.CHARACTER_TYPE_DUMMY);
                                    toSceneChar.setXY(pixelX, pixelY);
                                    toArr.push(toSceneChar);
                                } else {
                                    pixelX = (toRectCenter.x + i);
                                    pixelY = (toRectCenter.y + j);
                                    toSceneChar = scene.createSceneCharacter(StaticData.CHARACTER_TYPE_DUMMY);
                                    toSceneChar.setXY(pixelX, pixelY);
                                    toArr.push(toSceneChar);
                                    pixelX = (toRectCenter.x + i);
                                    pixelY = (toRectCenter.y - j);
                                    toSceneChar = scene.createSceneCharacter(StaticData.CHARACTER_TYPE_DUMMY);
                                    toSceneChar.setXY(pixelX, pixelY);
                                    toArr.push(toSceneChar);
                                    pixelX = (toRectCenter.x - i);
                                    pixelY = (toRectCenter.y + j);
                                    toSceneChar = scene.createSceneCharacter(StaticData.CHARACTER_TYPE_DUMMY);
                                    toSceneChar.setXY(pixelX, pixelY);
                                    toArr.push(toSceneChar);
                                    pixelX = (toRectCenter.x - i);
                                    pixelY = (toRectCenter.y - j);
                                    toSceneChar = scene.createSceneCharacter(StaticData.CHARACTER_TYPE_DUMMY);
                                    toSceneChar.setXY(pixelX, pixelY);
                                    toArr.push(toSceneChar);
                                }
                            }
                        }
                        j = (j + showSpace);
                    }
                    i = (i + showSpace);
                }
                toApd = toApd || new AvatarParamData();
                toApd.extendCallBack(null, null, null, new_onPlayComplete);
                if (passApd != null) {
                    var new_onPlayComplete_for_pass:Function = function (sceneChar1:ElfCharacter=null, part:AvatarPart=null):void
					{
                        var toNewArray:Array;
                        if (includeCenter) {
                            toNewArray = [centerSc].concat(toArr);
                        } else {
                            toNewArray = toArr;
                        }
                        showMagic(fromSceneChar, toNewArray, null, toApd, null);
                    }
                    passApd = new AvatarParamData();
                    passApd.extendCallBack(null, null, null, new_onPlayComplete_for_pass);
                    showMagic(fromSceneChar, [centerSc], fromApd, null, passApd);
                } else {
                    toArr.unshift(centerSc);
                    showMagic(fromSceneChar, toArr, fromApd, toApd, null);
                }
            }
            fromSceneChar.faceTo(toRectCenter.x, toRectCenter.y);
            if (fromSceneChar.type != StaticData.CHARACTER_TYPE_DUMMY) {
                fromSceneChar.playTo(StaticData.STATUS_TYPE_MAGIC_ATTACK, -1, -1, new AvatarPlayCondition(true));
                fromSceneChar.showAttack = showAttack;
            } else {
                showAttack();
            }
            hasRun = false;
        }
		
		/**
		 * 显示施法效果 
		 * @param fromSceneChar 触发角色对象
		 * @param toArray 施予对象数组
		 * @param fromApd 触发对象的特效
		 * @param toApd 施予对象的特效
		 * @param passApd 过场特效
		 * 
		 */		
        public static function showMagic(fromSceneChar:ElfCharacter, toArray:Array, 
										 fromApd:AvatarParamData=null, toApd:AvatarParamData=null, passApd:AvatarParamData=null):void
		{
            var passAndHit:Function = function(sceneChar1:ElfCharacter=null, part:AvatarPart=null):void{
                var tmpSceneChar:ElfCharacter;
                if (passApd == null){
                    for each (tmpSceneChar in toArray) {
                        if (tmpSceneChar.usable){
                            tmpSceneChar.loadAvatarPart(toApd);
                        } else {
                            if (toApd != null){
                                toApd.executeCallBack(tmpSceneChar);
                            }
                        }
                    }
                } else {
                    for each (tmpSceneChar in toArray) {
                        showTweenAvatarPart(fromSceneChar, tmpSceneChar, toApd, passApd !=null ? passApd.clone() : null);
                    }
                }
            }
            fromApd = fromApd || new AvatarParamData();
            fromApd.extendCallBack(null, passAndHit, null, null);
            fromSceneChar.loadAvatarPart(fromApd);
        }
		
        private static function showTweenAvatarPart(fromSceneChar:ElfCharacter, 
													toSceneChar:ElfCharacter, toApd:AvatarParamData, passApd:AvatarParamData):void
		{
            var scene:ElfScene = null;
            var passSc:ElfCharacter = null;
            var new_onPlayBeforeStart:Function = function (sceneChar1:ElfCharacter=null, part:AvatarPart=null):void{
                passSc.setXY(fromSceneChar.pixel_x, fromSceneChar.pixel_y);
                tweenDandao(passSc, toSceneChar, hitIt, [scene, passSc, toSceneChar, toApd]);
            };
            scene = fromSceneChar.scene;
            passSc = scene.createSceneCharacter(StaticData.CHARACTER_TYPE_DUMMY);
            passSc.setXY(fromSceneChar.pixel_x, fromSceneChar.pixel_y);
            passApd = passApd || new AvatarParamData();
            passApd.extendCallBack(new_onPlayBeforeStart);
            passSc.loadAvatarPart(passApd);
        }
		
        private static function tweenDandao(passSceneChar:ElfCharacter, 
											toSceneChar:ElfCharacter, 
											completeHandler:Function, objArr:Array=null, targetPoint:Point=null):void
		{
            var firstScPoint:Point;
            var secondScPoint:Point;
            var distance:Number;
            var realDistance:Number;
            var angle:Number;
            if (!toSceneChar.usable) {
                HandlerHelper.execute(hitIt, objArr);
                return;
            }
            targetPoint = targetPoint !=null ? targetPoint : new Point(int.MAX_VALUE, int.MIN_VALUE);
            if (targetPoint.x != toSceneChar.pixel_x || targetPoint.y != toSceneChar.pixel_y) {
                targetPoint.x = toSceneChar.pixel_x;
                targetPoint.y = toSceneChar.pixel_y;
                TweenLite.killTweensOf(passSceneChar);
                firstScPoint = new Point(passSceneChar.pixel_x, passSceneChar.pixel_y);
                secondScPoint = new Point(toSceneChar.pixel_x, toSceneChar.pixel_y);
                distance = Point.distance(firstScPoint, secondScPoint);
				realDistance = ((distance / 0.5) * 0.0007);
                angle = ZMath.getTwoPointsAngle(firstScPoint, secondScPoint);
                passSceneChar.playTo(null, -1, (angle - 90));
                TweenLite.to(passSceneChar, realDistance, {
                    pixel_x:toSceneChar.pixel_x,
                    pixel_y:toSceneChar.pixel_y,
                    ease:Linear.easeNone,
                    onUpdate:tweenDandao,
                    onUpdateParams:[passSceneChar, toSceneChar, completeHandler, objArr, targetPoint],
                    onComplete:completeHandler,
                    onCompleteParams:objArr
                });
            }
        }
		
		/**
		 * 击中法术特效 
		 * @param scene 场景对象
		 * @param passSceneChar 过场对象
		 * @param toSceneChar 目标对象
		 * @param avatarParamData 特效数据
		 * 
		 */		
        private static function hitIt(scene:ElfScene, passSceneChar:ElfCharacter, 
									  toSceneChar:ElfCharacter, 
									  avatarParamData:AvatarParamData):void
		{
            TweenLite.killTweensOf(passSceneChar);
            scene.removeCharacter(passSceneChar);
            if (!toSceneChar.usable) {
                if (avatarParamData != null){
                    avatarParamData.executeCallBack(toSceneChar);
                }
            } else {
                toSceneChar.loadAvatarPart(avatarParamData);
            }
        }
    }
}