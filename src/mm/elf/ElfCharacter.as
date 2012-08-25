package mm.elf
{
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import mm.elf.graphics.avatar.Avatar;
	import mm.elf.graphics.avatar.AvatarPart;
	import mm.elf.graphics.tagger.HeadFace;
	import mm.elf.helper.MagicHelper;
	import mm.elf.helper.TaggerHelper;
	import mm.elf.helper.WalkHelper;
	import mm.elf.tools.SceneCache;
	import mm.elf.tools.ScenePool;
	import mm.elf.utils.StaticData;
	import mm.elf.utils.Transformer;
	import mm.elf.vo.BaseElement;
	import mm.elf.vo.avatar.AvatarParamData;
	import mm.elf.vo.avatar.AvatarPlayCondition;
	import mm.elf.vo.map.MapTile;
	import mm.elf.vo.walk.WalkData;
	import mm.elf.walk.WalkStep;
	import mm.wit.pool.IPoolObject;
	import mm.wit.utils.ZMath;

	/**
	 * 场景中的对象，继承自BaseElement
	 * <br> 人物、NPC、怪物、传送门、掉落包和傀儡等
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class ElfCharacter extends BaseElement implements IPoolObject
	{
        public var type:int;
		public var restStatus:int;
        public var usable:Boolean = false;
        public var visible:Boolean = true;
        public var showIndex:int = 0;
        public var updateNow:Boolean;			// 需要更新
		
		public var avatar:Avatar;				// 外观
        public var headFace:HeadFace;			// 在 SceneHeadLayer 中显示, 昵称/对话 等显示
        public var scene:ElfScene;
		
        public var oldMouseRect:Rectangle;		// 鼠标范围
        public var mouseRect:Rectangle;
        public var isMouseOn:Boolean;
        public var isSelected:Boolean;
        
        public var showAttack:Function;			// 显示攻击动画回调, see Avatar.playTo
		
		/**
		 * {
		 * visible:true,
		 * inViewDistance:false,
		 * isMouseOn:false,
		 * isSelected:false,
		 * pos:new Point()
		 * }
		 */		
//        private var _oldData:Object;			// 旧的状态数据
//        private var _walkData:WalkData;			// 移动数据
        protected var _oldData:Object;			// 旧的状态数据
        protected var _walkData:WalkData;			// 移动数据

		/**
		 * 场景对象 
		 * @param type 类型
		 * @param scene 场景
		 * @param tileX 块坐标x
		 * @param tileY 块坐标y
		 * @param showIndex 深度
		 */
        public function ElfCharacter(type:int, scene:ElfScene, tileX:int=0, tileY:int=0, showIndex:int=0)
		{
            reSet([type, scene, tileX, tileY, showIndex]);
        }
		
		/**
		 * 建立场景对象
		 * @param type 类型
		 * @param scene 场景
		 * @param tileX 块坐标x
		 * @param tileY 块坐标y
		 * @param showIndex 深度
		 */
        public static function createSceneCharacter(type:int, scene:ElfScene, tileX:int=0, 
													tileY:int=0, showIndex:int=0):ElfCharacter
		{
            return ScenePool.sceneCharacterPool.createObj(ElfCharacter, type, scene, tileX, tileY, showIndex) as ElfCharacter;
        }
		
		/**
		 * 删除场景对象并回收对象池
		 */
        public static function recycleSceneCharacter(sceneChar:ElfCharacter):void
		{
            ScenePool.sceneCharacterPool.disposeObj(sceneChar);
        }

		/**
		 * 是否在遮罩内
		 * <br> 根据 tile_x, tile_y 判断所处的 MapTile是否是遮罩
		 */
        public function get isInMask():Boolean
		{
            return ( SceneCache.mapTiles[tile_x + "_" + tile_y] != null && 
				(SceneCache.mapTiles[tile_x + "_" + tile_y] as MapTile).isMask );
        }
		
		/**
		 * 返回走路信息
		 */
        public function get walkData():WalkData
		{
            if (_walkData == null) {
                _walkData = new WalkData();
            }
            return _walkData;
        }
		
		/**
		 * 设置角色面向方向
		 * @param pixelX 像素坐标x
		 * @param pixelY 像素坐标y
		 */
        public function faceTo(pixelX:Number, pixelY:Number):void
		{
            if (pixel_x == pixelX && pixel_y == pixelY) {
                return;
            }
			
            var angle:Number = ZMath.getTwoPointsAngle(new Point(pixel_x, pixel_y), new Point(pixelX, pixelY));
			
            setAngle(angle);
        }
		
		/**
		 * 设置角色面向方向
		 * @param x 块坐标x
		 * @param y 块坐标y
		 */
        public function faceToTile(x:Number, y:Number):void
		{
            var pos:Point = Transformer.transTilePoint2PixelPoint(new Point(x, y));
            faceTo(pos.x, pos.y);
        }
		
		/**
		 * 设置面向某个对象
		 * @param sceneChar 场景对象
		 */
        public function faceToCharacter(sceneChar:ElfCharacter):void
		{
            faceTo(sceneChar.pixel_x, sceneChar.pixel_y);
        }
		
		/**
		 * 设置场景对象坐标值（像素坐标）
		 * @param x 像素坐标x
		 * @param y 像素坐标y
		 */
        public function setXY(x:Number, y:Number):void
		{
            pixel_x = x;
            pixel_y = y;
        }
		
		/**
		 * 设置场景对象坐标值（块坐标）
		 * @param tileX 块坐标x
		 * @param tileY 块坐标y
		 */
        public function setTileXY(tileX:Number, tileY:Number):void
		{
            tile_y = tileY;
            tile_x = tileX;
        }
		
		/**
		 * 反转路径 
		 * @param tileX 块坐标x
		 * @param tileY 块坐标y
		 */
        public function reviseTileXY(tileX:Number, tileY:Number):void
		{
            setTileXY(tileX, tileY);
            WalkHelper.reviseWalkPath(this);
        }
		
		/**
		 * 设置移动速度 
		 * @param walkSpeed Number 像素/秒
		 */
        public function setSpeed(walkSpeed:Number):void
		{
            walkData.walk_speed = walkSpeed;
        }
		
		/**
		 * 获取移动速度 
		 * @return Number 移动速度，像素/秒
		 */
        public function getSpeed():Number
		{
            return walkData.walk_speed;
        }
		
		/**
		 * 设置状态，see Statics
		 * @param status 状态
		 */
        public function setStatus(status:String):void
		{
            if (getStatus() == status) {
                return;
            }
            playTo(status, -1, -1);
        }
		
		/**
		 * 获取状态 
		 * @return string 状态值
		 */
        public function getStatus():String
		{
            return avatar.status;
        }
		
		/**
		 * 设置角度
		 * @param angle Number 度数degree(0-360)
		 */
        public function setAngle(angle:Number):void
		{
            var logicAngle:int = Transformer.transAngle2LogicAngle(angle);
			// 设置方向, 0-7
			setLogicAngle(logicAngle);		
        }
		
		/**
		 * 逻辑角度(方向 0-7)
		 * @param angle int 0-7 see Statics.ANGEL_*
		 */
        public function setLogicAngle(angle:int):void
		{
            if (getLogicAngle() == angle){
                return;
            }
            playTo(null, angle, -1);
        }
		
		/**
		 * 获取角度 
		 * @return int
		 */
        public function getLogicAngle():int
		{
            return avatar.logicAngle;
        }
		
		/**
		 * 角度顺序转换 
		 */
        public function get logicAnglePRI():int
		{
			var tmp:Array = [0, 1, 3, 5, 7, 6, 4, 2];
			var index:int = avatar.logicAngle>7 || avatar.logicAngle<0 ? 0 : tmp[avatar.logicAngle];
			return index;
        }
		
		/**
		 * 设置旋转角度 
		 * @param rotation 角度0-180为顺时针，反之为逆时针
		 */
        public function setRotation(rotation:Number):void
		{
            playTo(null, -1, rotation);
        }
		
		/**
		 * 播放动画
		 * @param status 动作ID, 如  stand, walk
		 * @param logicAngle 方向, 如 ANGEL_0, ANGEL_45, ANGEL_90
		 * @param rotation 旋转
		 * @param playCondition 播放条件
		 */
        public function playTo(_status:String=null, logicAngle:int=-1, rotation:int=-1, playCondition:AvatarPlayCondition=null):void
		{
            avatar.playTo(_status, logicAngle, rotation, playCondition);
        }
		
		/**
		 * 停止走路 
		 * @param b
		 */
        public function stopWalk(b:Boolean=true):void
		{
            WalkHelper.stopWalk(this, b);
        }
		
		/**
		 * 走路
		 * <br> 需要先经过寻路后获取路径数组
		 * 
		 * @param targetTilePoint 目标
		 * @param walkSpeed 速度
		 * @param error 距离误差
		 * @param walkVars 回调列表
		 */
        public function walk(targetTilePoint:Point, walkSpeed:Number=-1, error:Number=0, walkVars:Object=null):void
		{
            WalkHelper.walk(this, targetTilePoint, walkSpeed, error, walkVars);
        }
		
		/**
		 * 走路
		 * <br> 直接提供路径 
		 * 
		 * @param targetTilePoint 目标
		 * @param walkSpeed 速度
		 * @param error 距离误差
		 * @param walkVars 回调列表
		 */
        public function walk0(walkPaths:Array, targetTilePoint:Point=null, walkSpeed:Number=-1, error:Number=0, walkVars:Object=null):void
		{
            WalkHelper.walk0(this, walkPaths, targetTilePoint, walkSpeed, error, walkVars);
        }
		
		/**
		 * 走路
		 * <br> 路径信息是二进制
		 *  
		 * @param targetTilePoint 目标
		 * @param walkSpeed 速度
		 * @param error 距离误差
		 * @param walkVars 回调列表
		 */
        public function walk1(pathByteData:ByteArray, targetTilePoint:Point=null, walkSpeed:Number=-1, error:Number=0, walkVars:Object=null):void
		{
            WalkHelper.walk1(this, pathByteData, targetTilePoint, walkSpeed, error, walkVars);
        }
		
		/**
		 * 角色部件接口
		 */
		
		public function setBornAvatarParamData(avatarParamData:AvatarParamData):void
		{
			avatar.setBornAvatarParamData(avatarParamData);
		}
		public function getBornAvatarParamData():AvatarParamData
		{
			return avatar.getBornAvatarParamData();
		}
		public function hasTypeAvatarParts(partType:String):Boolean
		{
			return avatar.hasTypeAvatarParts(partType);
		}
		public function hasIDAvatarPart(partID:String):Boolean
		{
			return (avatar.hasIDAvatarPart(partID));
		}
		public function loadAvatarPart(avatarParamData:AvatarParamData=null):void
		{
			avatar.loadAvatarPart(avatarParamData);
		}
		public function showAvatarPart(part:AvatarPart):void
		{
			avatar.showAvatarPart(part);
		}
		public function hideAvatarPart(part:AvatarPart):void
		{
			avatar.hideAvatarPart(part);
		}
		public function showAvatarPartsByType(partType:String):void
		{
			avatar.showAvatarPartsByType(partType);
		}
		public function hideAvatarPartsByType(partType:String):void
		{
			avatar.hideAvatarPartsByType(partType);
		}
		public function showAvatarPartByID(partID:String):void
		{
			avatar.showAvatarPartByID(partID);
		}
		public function hideAvatarPartByID(partID:String):void
		{
			avatar.hideAvatarPartByID(partID);
		}
		public function addAvatarPart(part:AvatarPart, removeExist:Boolean=false):void
		{
			avatar.addAvatarPart(part, removeExist);
		}
		public function removeAvatarPart(part:AvatarPart, byType:Boolean=false, update:Boolean=true):void
		{
			avatar.removeAvatarPart(part, byType, update);
		}
		public function removeAllAvatarParts(update:Boolean=true):void
		{
			avatar.removeAllAvatarParts(update);
		}
		public function removeAvatarPartsByType(partType:String, update:Boolean=true):void
		{
			avatar.removeAvatarPartsByType(partType, update);
		}
		public function removeAvatarPartByID(partID:String, update:Boolean=true):void
		{
			avatar.removeAvatarPartByID(partID, update);
		}
		public function getAvatarPartsByType(partType:String):Array
		{
			return avatar.getAvatarPartsByType(partType);
		}
		public function getAvatarPartByID(partID:String):AvatarPart
		{
			return avatar.getAvatarPartByID(partID);
		}
		
		/**
		 * 法术接口
		 */
		
		public function showMagic_from1passNtoN(toArray:Array, fromApd:AvatarParamData=null, 
												toApd:AvatarParamData=null, passApd:AvatarParamData=null):void
		{
			MagicHelper.showMagic_from1passNtoN(this, toArray, fromApd, toApd, passApd);
		}
		
		public function showMagic_from1pass1toPointArea(toPoint:Point, fromApd:AvatarParamData=null, 
														toApd:AvatarParamData=null, passApd:AvatarParamData=null):void
		{
			MagicHelper.showMagic_from1pass1toPointArea(this, toPoint, fromApd, toApd, passApd);
		}
		
		public function showMagic_from1passNtoRectArea(toRectCenter:Point, toRectHalfWidth:int, 
													   toRectHalfHeight:int, showSpace:int=25, 
													   includeCenter:Boolean=true, fromApd:AvatarParamData=null, 
													   toApd:AvatarParamData=null, passApd:AvatarParamData=null):void
		{
			MagicHelper.showMagic_from1passNtoRectArea(this, toRectCenter, toRectHalfWidth, 
														toRectHalfHeight, showSpace, includeCenter, fromApd, toApd, toApd);
		}
		
		public function showMagic_from1pass1toRectArea(toRectCenter:Point, toRectHalfWidth:int, 
													   toRectHalfHeight:int, showSpace:int=25, 
													   includeCenter:Boolean=true, fromApd:AvatarParamData=null, 
													   toApd:AvatarParamData=null, passApd:AvatarParamData=null):void
		{
			MagicHelper.showMagic_from1pass1toRectArea(this, toRectCenter, toRectHalfWidth, 
														toRectHalfHeight, showSpace, includeCenter, fromApd, toApd, toApd);
		}
		
		
		/**
		 * HeadFace接口 
		 * 
		 */		
		
		public function showHeadFace(nickName:String="", 
									 nickNameColor:uint=0xFFFFFF, customTitle:String="", 
									 leftIcon:DisplayObject=null, topIcon:DisplayObject=null):void
		{
			TaggerHelper.showHeadFace(this, nickName, nickNameColor, customTitle, leftIcon, topIcon);
		}
		
		public function setHeadFaceNickNameVisible(b:Boolean):void
		{
			if (headFace == null) {
				showHeadFace();
			}
			headFace.setHeadFaceNickNameVisible(b);
		}
		
		public function setHeadFaceCustomTitleVisible(b:Boolean):void
		{
			if (headFace == null) {
				showHeadFace();
			}
			headFace.setHeadFaceCustomTitleVisible(b);
		}
		
		public function setHeadFaceLeftIcoVisible(b:Boolean):void
		{
			if (headFace == null) {
				showHeadFace();
			}
			headFace.setHeadFaceLeftIcoVisible(b);
		}
		
		public function setHeadFaceTopIcoVisible(b:Boolean):void
		{
			if (headFace == null) {
				showHeadFace();
			}
			headFace.setHeadFaceTopIcoVisible(b);
		}
		
		public function setHeadFaceBarVisible(b:Boolean):void
		{
			if (headFace == null) {
				showHeadFace();
			}
			headFace.setHeadFaceBarVisible(b);
		}
		
		public function setHeadFaceNickName(nickName:String="", nickNameColor:uint=0xFFFFFF):void
		{
			if (headFace == null) {
				showHeadFace();
			}
			headFace.setHeadFaceNickName(nickName, nickNameColor);
		}
		
		public function setHeadFaceCustomTitleHtmlText(customTitle:String=""):void
		{
			if (headFace == null) {
				showHeadFace();
			}
			headFace.setHeadFaceCustomTitleHtmlText(customTitle);
		}
		
		public function setHeadFaceLeftIco(leftIcon:DisplayObject=null):void
		{
			if (headFace == null) {
				showHeadFace();
			}
			headFace.setHeadFaceLeftIco(leftIcon);
		}
		/**头顶上的图片，都用这个*/
		public function setHeadFaceTopIco(topIcon:DisplayObject=null):void
		{
			if (headFace == null) {
				showHeadFace();
			}
			if(headFace)
				headFace.setHeadFaceTopIco(topIcon);
		}
		
		public function setHeadFaceBar(barNow:int, barTotal:int):void
		{
			if (headFace == null) {
				showHeadFace();
			}
			headFace.setHeadFaceBar(barNow, barTotal);
		}
		
		public function setHeadFaceTalkText(talkText:String="", talkTextColor:uint=0xFFFFFF, talkTimeDelay:int=8000):void
		{
			if (headFace == null) {
				showHeadFace();
			}
			headFace.setHeadFaceTalkText(talkText, talkTextColor, talkTimeDelay);
		}
		
		public function getHeadFaceNickName():String
		{
			if (headFace == null) {
				return (name);
			}
			return (headFace.nickName);
		}
		
		public function getHeadFaceNickNameColor():uint
		{
			if (headFace == null) {
				return (0);
			}
			return (headFace.nickNameColor);
		}
		
		public function showAttackFace(attackType:String="", 
									   attackValue:int=0, selfText:String="",
									   selfFontSize:uint=0, selfFontColor:uint=0):void
		{
			TaggerHelper.showAttackFace(this, attackType, attackValue, selfText, selfFontSize, selfFontColor);
		}
		
		public function getCustomFaceByName(faceName:String):DisplayObject
		{
			return TaggerHelper.getCustomFaceByName(this, faceName);
		}
		
		public function addCustomFace(face:DisplayObject):void
		{
			TaggerHelper.addCustomFace(this, face);
		}
		
		public function removeCustomFace(face:DisplayObject):void
		{
			TaggerHelper.removeCustomFace(this, face);
		}
		
		public function removeCustomFaceByName(faceName:String):void
		{
			TaggerHelper.removeCustomFaceByName(this, faceName);
		}
		
		/**
		 * 是不是主角
		 * @return bool
		 */
        public function isMainChar():Boolean
		{
            return scene != null ? this == scene.mainChar : false;
        }
		
		/**
		 * 命中测试. 测试 avatar 中每一个 avatarPart, 如果不是魔法, 则测试位图像素
		 * @param pt point 
		 * @return bool
		 */
        public function hitPoint(pt:Point):Boolean
		{
            return avatar.hitPoint(pt);
        }
		
		/**
		 * 返回是否在摄像机可视范围
		 */
        public function inViewDistance():Boolean
		{
            return scene == null || scene.sceneCamera.canSee(this);
        }
		
		/**
		 * 自我清理 
		 */
        public function clearMe():void
		{
			avatar.clearMe();
        }
		
		/**
		 * 释放资源
		 */
        public function dispose():void
		{
            usable = false;
            SceneCache.removeWaitingAvatar(this);
            Avatar.recycleAvatar(avatar);
			if (headFace != null) {
				if (headFace.parent) {
					headFace.parent.removeChild(headFace);
				}
				HeadFace.recycleHeadFace(headFace);
			}

			type = -1;
            avatar = null;
			headFace = null;
            scene = null;
            oldMouseRect = null;
            mouseRect = null;
            isSelected = false;
            isMouseOn = false;
            restStatus = StaticData.REST_TYPE_COMMON;
            _walkData = null;
            showIndex = 0;
            showAttack = null;
            visible = true;
            updateNow = false;
            _oldData = null;
            data = null;
			disableContainer();
        }
		
		/**
		 * 初始化
		 * @param value type, scene, tile_x, tile_y, showIndex
		 */
        public function reSet(value:Array):void
		{
            type = value[0];
            scene = value[1];
            tile_y = value[3]; // 设置y先，战场中需要
            tile_x = value[2];
            showIndex = value[4];
			
            avatar = Avatar.createAvatar(this);
			
            if (scene != null) {
                avatar.visible = (this == scene.mainChar) || scene.getCharAvatarVisible(type);
            }
            _oldData = {
                visible:true,
                inViewDistance:false,
                isMouseOn:false,
                isSelected:false,
                pos:new Point()
            }
            usable = true;
        }
		
		/**
		 * 移动，场景渲染时，每帧都会执行此方法
		 */
        public function runWalk():void
		{
            WalkStep.step(this);
        }
		
		
		/**
		 * Avatar 管理接口
		 * <li>加载资源
		 * <li>每帧更新
		 * <li>每帧渲染
		 */		
		
		/**
		 * 更新一帧
		 * <br> see SceneAvatarLayer.run() and SimpleAvatarSynthesis.synthesisSimpleAvatar()
		 * 
		 * @param frame int 帧数
		 */
        public function runAvatar(frame:int=-1):void
		{
			// 更新 pos
            var px:Number = Math.round(pixel_x);
            var py:Number = Math.round(pixel_y);
            if (_oldData.pos.x != px || _oldData.pos.y != py) {
                _oldData.pos.x = px;
                _oldData.pos.y = py;
                updateNow = true;
            }
			
			// 更新 isMouseOn
            if (_oldData.isMouseOn != isMouseOn) {
                _oldData.isMouseOn = isMouseOn;
                updateNow = true;
            }
			
			// 更新 visible
            if (_oldData.visible != visible) {
                _oldData.visible = visible;
                updateNow = true;
            }
			
			// 更新 inViewDistance
            var canSee:Boolean = inViewDistance();
            if (_oldData.inViewDistance != canSee){
                _oldData.inViewDistance = canSee;
                updateNow = true;
            }
			
            mouseRect = null;
			
			// 调用  avatar.run, 让它继续更新
            avatar.run(frame);
            if (mouseRect != null){
                oldMouseRect = mouseRect.clone();
            }
			
			// 恢复标记
            updateNow = false;
        }
		
		/**
		 * 绘制avatar外观
		 * @param bitmap
		 */
        public function drawAvatar(bitmap:IBitmapDrawable):void
		{
            avatar.draw(bitmap);
        }
    }
}