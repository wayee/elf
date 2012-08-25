package mm.wit.cache
{
	import flash.utils.Dictionary;
	
	import mm.wit.utils.LNode;

	/**
	 * 缓存类
	 * @author Andy Cai <huayicai@gmail.com>
	 */
	public class Cache
	{
		private static var _nextId:int = 0;
		
		private var _name:String;
		private var _length:int;
		private var _maxSize:int;
		private var _head:LNode;	// 当前节点
		private var _dict:Dictionary;
		
		public function Cache(name:String="", maxSize:int=2147483647)
		{
			if (maxSize < 0){
				throw new Error("缓存个数必须为非负数");
			}
			_name = name != "" ? name : ("Cache" + _nextId++);
			_maxSize = maxSize;
			_head = null;
			_length = 0;
			_dict = new Dictionary();
		}
		
		/**
		 * 缓存是否存在 
		 */
		public function has(key:String):Boolean
		{
			return _dict[key] != null;
		}
		
		/**
		 * 检索缓存, 并增加优先级
		 */
		public function get(key:String):Object
		{
			var unit:CacheUnit = _dict[key];
			promote(unit);
			
			return unit.data;
		}
		
		/**
		 * 删除缓存 
		 */
		public function remove(key:String):void
		{
			var unit:CacheUnit = _dict[key];
			if (unit) {
				if (unit == _head) {
					_head = _head.pre;
				}
				// 链表更新
				unit.pre.next = unit.next;
				unit.next.pre = unit.pre;
				
				destroy(unit);
				_length--;
			}
		}
		
		/**
		 * 添加对象
		 */
		public function push(data:Object, key:String):void
		{
			var node:LNode;
			if (has(key)) {
				promote(_dict[key]);
				return;
			}
			
			node = new CacheUnit(data, key);
			_dict[key] = node;
			if (_length == 0) { // 第一个
				_head = node;
				_head.pre = node;
				_head.next = node;
			} else { // 链表更新（我的上就是你；我的下就是你的下；我的上的下就是我；我的下的上就是我，哈哈，越说越糊涂）
				node.pre = _head;
				node.next = _head.next;
				node.pre.next = node;
				node.next.pre = node;
				_head = node;
			}
			
			_length++;
			
			if (_length > _maxSize) { // 达到最大，把我的下删除
				node = _head.next;
				node.pre.next = node.next;
				node.next.pre = node.pre;
				destroy(node);
				_length--;
			}
		}
		
		/**
		 * 重置缓存大小 
		 */
		public function resize(index:int):void
		{
			var node:LNode;
			if (index < 0 || index == _maxSize) {
				return;
			}
			while (_length > index) {
				node = _head.next;
				node.pre.next = node.next;
				node.next.pre = node.pre;
				destroy(node);
				_length--;
			}
			_maxSize = index;
		}
		
		/**
		 * 清理 
		 */
		public function dispose():void
		{
			var tmpMax:int = _maxSize;
			resize(0);
			_maxSize = tmpMax;
		}
		
		/**
		 * 获取所有键值 
		 */
		public function getAllKeys():Array
		{
			var unit:CacheUnit;
			var arr:Array = [];
			for each (unit in _dict) {
				arr.push(unit.id);
			}
			return arr;
		}
		
		/**
		 * 获取所有值 
		 */
		public function getAllValues():Array
		{
			var unit:CacheUnit;
			var arr:Array = [];
			for each (unit in _dict) {
				arr.push(unit.data);
			}
			return arr;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function get length():int
		{
			return _length;
		}
		
		/**
		 * 增加优先级，先把unit设置到_head的下，在把_head赋值为unit
		 */		
		private function promote(unit:CacheUnit):void
		{
			if (unit == null || unit == _head) {
				return;
			}
			
			if (unit.pre == _head) {
				_head = unit;
			} else {
				unit.next.pre = unit.pre;
				unit.pre.next = unit.next;
				unit.pre = _head;
				unit.next = _head.next;
				_head.next.pre = unit;
				_head.next = unit;
				_head = unit;
			}
		}
		
		/**
		 * 销毁对象节点 
		 */
		private function destroy(node:LNode):void
		{
			delete _dict[node.id];
			(node as CacheUnit).dispose();
			node = null;
		}
	}
}