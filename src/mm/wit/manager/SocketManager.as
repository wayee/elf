package mm.wit.manager
{
	import mm.wit.log.ZLog;
	import mm.wit.net.ZSocket;

	/**
	 * Socket 管理器 
	 * 
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
    public class SocketManager
	{
        private static var _socketArr:Array = [];

        public function SocketManager()
		{
            throw new Error('This is a static class.');
        }
		
        public static function hasSocket(event:ZSocket):Boolean
		{
            return _socketArr.indexOf(event) != -1;
        }
		
		/**
		 * 创建Socket 
		 */
        public static function creatSocket(fn:Function, host:String=null, port:int=0, head_mask:uint=127):ZSocket
		{
            var socket:ZSocket = new ZSocket(fn, host, port, head_mask);
            _socketArr.push(socket);
            ZLog.add("SocketManager.creatSocket::_socketArr.length:" + getSocketsNum());
            return socket;
        }
		
        public static function deleteSocket(socket:ZSocket):void
		{
            if (!socket) {
                return;
            }
            var index:int = _socketArr.indexOf(socket);
            if (index != -1) {
                _socketArr.splice(index, 1);
                ZLog.add("SocketManager.deleteSocket::_socketArr.length:" + getSocketsNum());
            }
            socket.close();
        }
		
        public static function getSocketsNum():int
		{
            return _socketArr.length;
        }
    }
}