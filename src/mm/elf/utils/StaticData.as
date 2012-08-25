package mm.elf.utils
{
	/**
	 * 各种状态静态信息
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class StaticData
	{
		/**
		 * 场景元素类型 
		 */		
		public static const CHARACTER_TYPE_PLAYER:int = 1			// 玩家
		public static const CHARACTER_TYPE_MONSTER:int = 2;			// 怪物
		public static const CHARACTER_TYPE_NPC:int = 3;				// NPC
		public static const CHARACTER_TYPE_PET:int = 4;				// 宠物/英雄
		public static const CHARACTER_TYPE_MOUNT:int = 5;			// 坐骑
		public static const CHARACTER_TYPE_BUILDING:int = 6;		// 建筑
		public static const CHARACTER_TYPE_DUMMY:int = 7;			// 傀儡（为法术特效应用的假对象） see MagicHelper
		public static const CHARACTER_TYPE_BAG:int = 8;				// 掉落包
		public static const CHARACTER_TYPE_TRANSPORT:int = 9;		// 传送点
		private static const defautCharacterDepthArr:Array = [[CHARACTER_TYPE_BAG, (-(int.MAX_VALUE) + 1)], [CHARACTER_TYPE_TRANSPORT, -(int.MAX_VALUE)]];
		public static function getCharacterDefaultDepth(characterType:int):int
		{
			var arr:Array;
			for each (arr in defautCharacterDepthArr) {
				if (arr[0] == characterType) {
					return arr[1];
				}
			}
			return 0;
		}
		
		/**
		 * 角色状态 
		 */	
		public static const STATUS_TYPE_STAND:String = "stand";					// 站立
		public static const STATUS_TYPE_STANDBY:String = "standby";				// 待机
		public static const STATUS_TYPE_WALK:String = "walk";					// 走路
		public static const STATUS_TYPE_ATTACK:String = "attack";				// 攻击
		public static const STATUS_TYPE_MAGIC_ATTACK:String = "magicAttack";	// 施法
		public static const STATUS_TYPE_INJURED:String = "injured";				// 受伤
		public static const STATUS_TYPE_DEATH:String = "death";					// 死亡
		public static const STATUS_TYPE_MEDITATE:String = "meditate";			// 打坐
//		public static const STATUS_TYPE_JUMP:String = "jump";					// 跳跃
//		public static const STATUS_TYPE_MOUNT_ATTACK:String = "mount_attack";		// 马匹攻击
		
		public static const STATUS_ATTACK_FINISH:String = 'attackFinish';
		public static const STATUS_SPELL_ATTACK_FINISH:String = 'spellAttackFinish';
		public static const STATUS_INJURED_FINISH:String = 'injuredFinish';
		public static const STATUS_SPELL_FINISH:String = 'spellEffectFinish';
		public static const STATUS_WORD_FINISH:String = 'wordFinish';
		
		
		/**
		 * 角色的角度 
		 */		
		public static const ANGEL_0:int = 0;
		public static const ANGEL_45:int = 1;
		public static const ANGEL_90:int = 2;
		public static const ANGEL_135:int = 3;
		public static const ANGEL_180:int = 4;
		public static const ANGEL_225:int = 5;
		public static const ANGEL_270:int = 6;
		public static const ANGEL_315:int = 7;
		
		/**
		 * 休息状态 
		 */
		public static var REST_TYPE_COMMON:int = 0;
		public static var REST_TYPE_SIT:int = 1;
		public static var REST_TYPE_DOUBLE_SIT:int = 2;
		
		/**
		 * 角色部件 
		 */		
		public static var PART_TYPE_BODY:String = "body";
		public static var PART_TYPE_WEAPON:String = "weapon";
//		public static var PART_TYPE_MOUNT:String = "mount";
		public static var PART_TYPE_MAGIC:String = "magic";
		public static var PART_TYPE_MAGIC_PASS:String = "magic_pass";
		public static var PART_TYPE_EFFECT:String = 'effect';
		private static const defautPartDepthArr:Array = [/*[PART_TYPE_MOUNT, -11],*/ [PART_TYPE_EFFECT, -1], [PART_TYPE_BODY, 0], [PART_TYPE_WEAPON, 21], [PART_TYPE_MAGIC, 31], [PART_TYPE_MAGIC_PASS, 30]];
		
		/**
		 * 返回类型对应的深度
		 */
		public static function getPartDefaultDepth(PartType:String):int
		{
			var arr:Array;
			for each (arr in defautPartDepthArr) {
				if (arr[0] == PartType) {
					return arr[1];
				}
			}
			return 0;
		}
		
		/**
		 * AvatarPartID 
		 */		
		
		public static const PART_ID_BLANK:String = "BLANK";
		public static const PART_ID_BORN:String = "BORN";
//		public static const PART_ID_BORN_ONMOUNT:String = "BORN_ONMOUNT";
//		public static const PART_ID_BORN_MOUNT:String = "BORN_MOUNT";
		public static const PART_ID_SHADOW:String = "SHADOW";					// 影子
		public static const PART_ID_SELECTED:String = "SELECTED";				// 选中
		public static const PART_ID_MOUSE:String = "MOUSE";						// 鼠标
		public static const PART_ID_RING:String = "RING";						// 光环
		
		/**
		 * 判断是否合法ID, 要求 非保留关键字
		 */
		public static function isValidID(id:String):Boolean
		{
			if (id == null || id == "" || !isDefaultKey(id)) {
				return false;
			}
			return true;
		}
		
		/**
		 * 保留关键字
		 */
		public static function isDefaultKey(id:String):Boolean
		{
			if (id == PART_ID_BLANK || id == PART_ID_BORN || id == PART_ID_SHADOW 
				|| id == PART_ID_SELECTED || id == PART_ID_MOUSE || id == PART_ID_RING) {
				return true;
			}
			return false;
		}
	}
}