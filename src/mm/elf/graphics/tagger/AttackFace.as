package mm.elf.graphics.tagger
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	import mm.elf.tools.ScenePool;
	import mm.wit.pool.IPoolObject;
	import mm.zuma.plugin.ZmFont;
	
	import xy.utils.Global;
	import xy.utils.Rsl;
	
	/**
	 * 攻击时, 血量获得/丢失, 接/交人物, 等的文字显示
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class AttackFace extends Sprite implements IPoolObject
	{
		public static const ATTACK_NORMAL:String = 'attack.normal';
		public static const ATTACK_CRITICALHIT:String = 'attack.criticalhit';
		public static const ATTACK_BEAT_BACK:String = 'attack.beat.back';
		public static const ATTACK_MISS:String = 'attack.miss';
		public static const ATTACK_BOUNCE:String = 'attack.bounce';
		public static const ATTACK_BITMAP_STRING:String = 'attack.bitmap.string';

		public static var bmdTextDict:Dictionary = new Dictionary;
		
		public static const DEFAULT_FOUNT_COLOR_RED:int = 0xFF0000;
		public static const DEFAULT_FOUNT_COLOR_BLUE:int = 0x2003199;
		public static const DEFAULT_FOUNT_COLOR_YELLOW:int = 0xFFFF00;
		public static const DEFAULT_FOUNT_COLOR_GREEN:int = 0xFF00;
		public static const DEFAULT_FOUNT_COLOR_PURPLE:int = 10040314;
		public static const DEFAULT_FOUNT_COLOR_WHITE:int = 0xFFFFFF;
		public static const DEFAULT_FOUNT_COLOR_ORANGE:int = 0xFF8A00;
		
		private var _font:ZmFont;
		private var _type:String = '';
		private var _value:String = '';
		private var _dir:int = 4;				// 运动方向
		private var _bitmap:Bitmap;
		
		
		/**
		 * 构造函数
		 * @param type 类型, 常量定义
		 * @param value 伤害值
		 * @param 
		 */
		public function AttackFace(type:String="", value:String="")
		{
			reSet([type, value]);
		}
		
		// 建立
		public static function createAttackFace(attackType:String="", 
												attackValue:String=""):AttackFace
		{
			return ScenePool.attackFacePool.createObj(AttackFace, attackType, attackValue) as AttackFace;
		}
		
		// 释放并备用
		public static function recycleAttackFace(af:AttackFace):void
		{
			ScenePool.attackFacePool.disposeObj(af);
		}
		
		public function get dir():int
		{
			return _dir;
		}
		
		public function dispose():void
		{
			_type = '';
			_value = '';
			_dir = 4;
			_font = null;
			if (_bitmap && contains(_bitmap)) removeChild(_bitmap);
			_bitmap = null;
		}
		
		public function reSet(value:Array):void
		{
			_bitmap = new Bitmap;
			addChild(_bitmap);
			
			_font = new ZmFont;
			_type = value[0];
			_value = value[1];
			
			switch (_type) {
				case ATTACK_NORMAL:
					_font.init(bmdTextDict[ATTACK_NORMAL], 16, 24, ZmFont.SET3, 96);
					_bitmap.bitmapData = _font.getLine(_value);
					break;
				case ATTACK_CRITICALHIT: // 暴击
					if (bmdTextDict[ATTACK_CRITICALHIT]) _bitmap.bitmapData = bmdTextDict[ATTACK_CRITICALHIT];
					break;
				case ATTACK_BEAT_BACK: // 反击
					if (bmdTextDict[ATTACK_BEAT_BACK]) _bitmap.bitmapData = bmdTextDict[ATTACK_BEAT_BACK];
					break;
				case ATTACK_MISS: // 闪避
					if (bmdTextDict[ATTACK_MISS]) _bitmap.bitmapData = bmdTextDict[ATTACK_MISS];
					break;
				case ATTACK_BOUNCE: // 反弹
					if (bmdTextDict[ATTACK_BOUNCE]) _bitmap.bitmapData = bmdTextDict[ATTACK_BOUNCE];
					break;
				case ATTACK_BITMAP_STRING:
					if (bmdTextDict[_value]) _bitmap.bitmapData = bmdTextDict[_value];
					break;
			}
			_bitmap.x = -_bitmap.width/2;
			_bitmap.y = -_bitmap.height/2;
		}
	}
}