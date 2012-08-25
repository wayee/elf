﻿package mm.elf.graphics.avatar
{
	import flash.display.IBitmapDrawable;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	
	import mm.elf.ElfCharacter;
	import mm.elf.events.ElfEvent;
	import mm.elf.events.ElfEventActionStatus;
	import mm.elf.loader.AvatarPartLoader;
	import mm.elf.tools.SceneCache;
	import mm.elf.tools.ScenePool;
	import mm.elf.utils.StaticData;
	import mm.elf.vo.avatar.AvatarParamData;
	import mm.elf.vo.avatar.AvatarPlayCondition;
	import mm.wit.event.EventDispatchCenter;
	import mm.wit.handler.HandlerHelper;
	import mm.wit.loader.LoadData;
	import mm.wit.manager.RslLoaderManager;
	import mm.wit.pool.IPoolObject;

	/**
	 * 角色外观
	 */
	public class Avatar implements IPoolObject
	{
		public var usable:Boolean = false;
		public var sceneCharacter:ElfCharacter;					// 场景角色信息
		public var status:String = "stand";							// 当前状态
		public var logicAngle:int = 0;								// 逻辑方向, [0-7]
		public var visible:Boolean = true;							// 可见性
		public var updateNow:Boolean;								// 需要更新显示
		private var _oldData:Object;								// {visible:true} 重绘区管理
		public var playCondition:AvatarPlayCondition;				// 播放/循环方式 
		
		private var _hideAvatarPartTypes:Array;						// AvatarPartType 中枚举值, 被隐藏的部分, 可以不依赖于 avatarParts
		public var avatarParts:Array;								// [AvatarPart], 每个部分
		
		// 原始参数
		private var _bornAvatarParamData:AvatarParamData;			// 身体数据 -- 原始值
//		private var _bornOnMountAvatarParamData:AvatarParamData;	// 骑马时的身体数据 -- 原始值
//		private var _bornMountAvatarParamData:AvatarParamData;		// 马的数据 -- 原始值
		
		/**
		 * Avatar 必须关联到一个  SceneCharacter 对象, 作为后者的表观(VIEW)
		 */
		public function Avatar(sceneChar:ElfCharacter)
		{
			_hideAvatarPartTypes = [];
			avatarParts = [];
			super();
			reSet([sceneChar]);
		}
		
		/**
		 * 建立角色
		 */
		public static function createAvatar(sceneChar:ElfCharacter):Avatar
		{
			return ScenePool.avatarPool.createObj(Avatar, sceneChar) as Avatar;
		}
		/**
		 * 释放, 并循环使用
		 */
		public static function recycleAvatar(avatar:Avatar):void
		{
			ScenePool.avatarPool.disposeObj(avatar);
		}
		
		public function playTo(statusArg:String=null, logicAngleArg:int=-1, rotation:int=-1, avatarPlayCondition:AvatarPlayCondition=null):void
		{
			var part:AvatarPart;
			var event:ElfEvent;
			var oldStatus:String = this.status;
			
			// 设置 statuc, logicAngleArg, playCondition
			if (statusArg != null){
				this.status = statusArg;
			}
			if (logicAngleArg != -1) {
				this.logicAngle = logicAngleArg;
			}
			if (avatarPlayCondition != null) {
				this.playCondition = avatarPlayCondition;
			} else {
				if (this.playCondition == null) {
					this.playCondition = new AvatarPlayCondition();
				}
			}
			
			// 每个部分, 播放该动作
			for each (part in this.avatarParts) {
				part.playTo(statusArg, logicAngle, rotation, playCondition.clone());
			}
			
			// 执行  showAttack 函数
			if (sceneCharacter.showAttack != null) {
				HandlerHelper.execute(sceneCharacter.showAttack);
				sceneCharacter.showAttack = null;
			}
			
			// 如果是主对象, 并且状态变更. 发送通知消息
			if ( sceneCharacter.scene && sceneCharacter == sceneCharacter.scene.mainChar && !(oldStatus == statusArg) )
			{
				event = new ElfEvent(ElfEvent.STATUS, ElfEventActionStatus.CHANGED, [sceneCharacter, statusArg]);
				EventDispatchCenter.getInstance().dispatchEvent(event);
			}
		}
		
		/**
		 * 更新周期
		 */
		public function run(frame:int=-1):void
		{
			// 更新 visible
			if (_oldData.visible != visible) {
				_oldData.visible = visible;
				updateNow = true;
			}
			
			// 更新每个部分
			var part:AvatarPart;
			for each (part in avatarParts) {
				part.run(frame);
			}
			
			// 恢复标记
			updateNow = false;
		}
		
		/**
		 * 绘图
		 * <li> 每个部位, 进行绘制
		 */
		public function draw(bitmap:IBitmapDrawable):void
		{
			var part:AvatarPart;
			for each (part in avatarParts) {
				part.draw(bitmap);
			}
		}
		
		/**
		 * 命中测试, 检测:
		 * 	<li> !MAGIC, !MAGIC_PASS 类型的命中, 部位根据像素来判断命中
		 */
		public function hitPoint(mousePoint:Point):Boolean
		{
			var avatarPart:AvatarPart;
			for each (avatarPart in avatarParts) {
				if (avatarPart.type != StaticData.PART_TYPE_MAGIC && avatarPart.type != StaticData.PART_TYPE_MAGIC_PASS && avatarPart.hitPoint(mousePoint)) {
					return true;
				}
			}
			return false;
		}
		
		/**
		 * for each:
		 * 	<li> clearMe
		 */
		public function clearMe():void
		{
			var part:AvatarPart;
			for each (part in avatarParts) {
				part.clearMe();
			}
		}
		
		/**
		 * 获取所有部件中最大播放时间的 
		 * @return int 时间（毫秒）
		 * 
		 */
		public function getMaxTimeFromPart():int
		{
			var time:int = 0;
			
			var totalTime:int;
			var part:AvatarPart;
			if (avatarParts && avatarParts.length > 0) {
				for each (part in avatarParts) {
					if (part.currentAvatarPartStatus) {
						totalTime = part.currentAvatarPartStatus.delay * (part.currentAvatarPartStatus.frame-1);
						if (totalTime > time) {
							time = totalTime;
						}
					}
				}
			}
			
			return time;
		}
		
		/*public function getTimeFromPart():int
		{
			var time:int = 0;
			
			var part:AvatarPart;
			if (avatarParts && avatarParts.length > 0) {
				for each (part in avatarParts) {
					if (part.currentAvatarPartStatus && part.currentAvatarPartStatus.type == StaticData.STATUS_TYPE_SIT && 
						part.type == StaticData.PART_TYPE_BODY) {
						time = part.currentAvatarPartStatus.delay * (part.currentAvatarPartStatus.frame-1);
						break;
					}
				}
			}
			
			return time;
		}*/
		
		/**
		 * 清理、重置
		 */		
		public function dispose():void
		{
			usable = false;
			removeAllAvatarParts(false);
			sceneCharacter = null;
			status = StaticData.STATUS_TYPE_STAND;
			avatarParts.length = 0;
			logicAngle = 0;
			playCondition = null;
			_hideAvatarPartTypes.length = 0;
			visible = true;
			updateNow = false;
			_oldData = null;
//			_isOnMount = false;
			_bornAvatarParamData = null;
//			_bornOnMountAvatarParamData = null;
//			_bornMountAvatarParamData = null;
		}
		
		public function reSet(value:Array):void
		{
			sceneCharacter = value[0];
			_oldData = {visible:true};
			usable = true;
		}
		
		/**
		 * 设置 _bornAvatarParamData
		 */
		public function getBornAvatarParamData():AvatarParamData
		{
			return _bornAvatarParamData;
		}
		public function setBornAvatarParamData(avatarParamData:AvatarParamData):void
		{
			if (avatarParamData == null) {
				return;
			}
			avatarParamData.id_noCheckValid = StaticData.PART_ID_BORN;			// id
			avatarParamData.avatarPartType = StaticData.PART_TYPE_BODY;			// type
			avatarParamData.depth = StaticData.getPartDefaultDepth(StaticData.PART_TYPE_BODY);
			avatarParamData.useType = 1;
			avatarParamData.clearSameType = false;
			this._bornAvatarParamData = avatarParamData;
			this.updateDefaultAvatar();
		}
		
		/**
		 * 更新显示
		 */
		private function updateDefaultAvatar():void
		{
			// TODO load the avatar body
			
			// 如果 没有身体
			if (!hasTypeAvatarParts(StaticData.PART_TYPE_BODY)) {
				// 根据 _bornAvatarParamData 加载身体数据 
				if (this._bornAvatarParamData != null) {
					this.sceneCharacter.loadAvatarPart(this._bornAvatarParamData);
				} else {
					// 否则根据 blankAvatarParamData(默认空白对象) 来加载身体
					if (this.sceneCharacter.scene.blankAvatarParamData != null) {
						if (this.sceneCharacter.type != StaticData.CHARACTER_TYPE_DUMMY 
							&& this.sceneCharacter.type != StaticData.CHARACTER_TYPE_BAG) {
							this.sceneCharacter.loadAvatarPart(this.sceneCharacter.scene.blankAvatarParamData);
						}
					}
				}
			}
			else {
				// 否则, 如果有空白 
				if (this.hasIDAvatarPart(StaticData.PART_ID_BLANK)) {
					// 从 _bornAvatarParamData 加载身体
					if (this._bornAvatarParamData != null) {
						this.sceneCharacter.loadAvatarPart(this._bornAvatarParamData);
					}
				}
			}
		}
		
		/**
		 * 检查 avatarParts 中是否有特定类型
		 */
		public function hasTypeAvatarParts(partType:String):Boolean{
			var part:AvatarPart;
			for each (part in avatarParts) {
				if (part.type == partType) {
					return true;
				}
			}
			return false;
		}
		
		/**
		 * 检查 avatarParts 中是否有特定ID
		 */
		public function hasIDAvatarPart(partID:String):Boolean{
			var part:AvatarPart;
			for each (part in avatarParts) {
				if (part.id == partID) {
					return true;
				}
			}
			return false;
		}

		/**
		 * 加载部件数据 
		 * @param param
		 * 
		 */
		public function loadAvatarPart(param:AvatarParamData):void
		{
			AvatarPartLoader.loadAvatarPart(sceneCharacter, param);
		}
		
		/**
		 * 控制 部位 隐藏/显示
		 */
		public function showAvatarPart(part:AvatarPart):void
		{
			part.visible = true;
		}
		public function hideAvatarPart(part:AvatarPart):void
		{
			part.visible = true;
		}
		public function showAvatarPartsByType(partType:String):void
		{
			var part:AvatarPart;
			var index:int = this._hideAvatarPartTypes.indexOf(partType);	 
			if (index != -1) {
				this._hideAvatarPartTypes.splice(index, 1);		// 保存到 数组中, 即时部分数据未就绪, 仍可设置
			}
			for each (part in this.avatarParts) {
				if (part.type == partType) {
					part.visible = true;
				}
			}
		}
		public function hideAvatarPartsByType(partType:String):void
		{
			var part:AvatarPart;
			if (this._hideAvatarPartTypes.indexOf(partType) == -1){
				this._hideAvatarPartTypes.push(partType);
			}
			for each (part in this.avatarParts) {
				if (part.type == partType) {
					part.visible = false;
				}
			}
		}
		public function showAvatarPartByID(partID:String):void
		{
			var part:AvatarPart = this.getAvatarPartByID(partID);
			if (part != null) {
				part.visible = true;
			}
		}
		public function hideAvatarPartByID(partID:String):void
		{
			var part:AvatarPart = this.getAvatarPartByID(partID);
			if (part != null) {
				part.visible = false;
			}
		}

		/**
		 * 添加一个部位
		 */
		public function addAvatarPart(avatarPart:AvatarPart, removeExist:Boolean=false):void{
			var part:AvatarPart;
			
			// 删除同类型
			if (removeExist) {
				removeAvatarPartsByType(avatarPart.type, false);
			}
			// 已经添加, 忽略
			if (avatarParts.indexOf(avatarPart) != -1) {
				return;
			}
			// 根据 ID 删除
			if (avatarPart.id != null && avatarPart.id != "") {
				part = getAvatarPartByID(avatarPart.id);
				if (part != null) {
					removeAvatarPart(part, false, false);
				}
			}
			
			// 添加到  avatarParts
			avatarPart.visible = (_hideAvatarPartTypes.indexOf(avatarPart.type) == -1);
			avatarPart.avatar = this;
			avatarPart.needRender = true;
			avatarParts.push(avatarPart);
			avatarParts.sortOn("depth", Array.NUMERIC);
			avatarPart.onAdd();
		}
		
		/**
		 * 删除
		 */
		public function removeAvatarPart(avatarPart:AvatarPart, byType:Boolean=false, update:Boolean=true):void{
			var index:int;
			if (byType) {
				removeAvatarPartsByType(avatarPart.type);
			} else {
				index = avatarParts.indexOf(avatarPart);
				if (index == -1){
					return;
				}
				avatarPart.onRemove();
				avatarParts.splice(index, 1);
				AvatarPart.recycleAvatarPart(avatarPart);
			}
			if (update) {
				updateDefaultAvatar();
			}
		}
		
		/**
		 * 根据partID删除部件 
		 * @param partID
		 * @param update
		 * 
		 */
		public function removeAvatarPartByID(partID:String, update:Boolean=true):void
		{
			var part:AvatarPart;
			if (partID == null || partID == "") {
				return;
			}
			SceneCache.removeWaitingAvatar(sceneCharacter, partID);
			for each (part in avatarParts) {
				if (part.id == partID) {
					part.onRemove();
					avatarParts.splice(avatarParts.indexOf(part), 1);
					AvatarPart.recycleAvatarPart(part);
					break;
				}
			}
			if (update) {
				updateDefaultAvatar();
			}
		}
		public function removeAvatarPartsByType(partType:String, update:Boolean=true):void
		{
			var part:AvatarPart;
			SceneCache.removeWaitingAvatar(this.sceneCharacter, null, partType);
			for each (part in this.avatarParts) {
				if (part.type == partType) {
					part.onRemove();
					this.avatarParts.splice(this.avatarParts.indexOf(part), 1);
					AvatarPart.recycleAvatarPart(part);
				}
			}
			if (update) {
				this.updateDefaultAvatar();
			}
		}
		public function removeAllAvatarParts(update:Boolean=true):void
		{
			var part:AvatarPart;
			SceneCache.removeWaitingAvatar(this.sceneCharacter);
			for each (part in this.avatarParts) {
				part.onRemove();
				AvatarPart.recycleAvatarPart(part);
			}
			this.avatarParts.length = 0;
			if (update) {
				this.updateDefaultAvatar();
			}
		}
		
		public function getAvatarPartByID(id:String):AvatarPart
		{
			var part:AvatarPart;
			for each (part in this.avatarParts) {
				if (part.id == id) {
					return (part);
				}
			}
			return null;
		}
		public function getAvatarPartsByType(type:String):Array
		{
			var part:AvatarPart;
			var arr:Array = [];
			for each (part in this.avatarParts) {
				if (part.type == type){
					arr.push(part);
				}
			}
			return arr;
		}
	}
}