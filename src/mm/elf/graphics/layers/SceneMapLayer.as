﻿package mm.elf.graphics.layers
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	import mm.wit.handler.HandlerThread;
	import mm.wit.loader.LoadData;
	import mm.wit.loader.RslLoader;
	import mm.wit.utils.Fun;
	import mm.wit.utils.ZMath;
	import mm.elf.vo.map.SceneInfo;
	import mm.elf.ElfScene;
	import mm.elf.vo.map.MapZone;
	import mm.elf.tools.SceneCache;
	import mm.elf.utils.SceneUtil;
	import mm.elf.utils.Transformer;
	
	/**
	 * 地图背景
	 * <li>MapZone 保存于 SceneCache.mapZones 中
	 * <br>
	 * <b>MapZone 的使用方式</b><br>
	 * <li> showContainer 中保存了实际显示的 Bitmap, 而它被添加到 this 中
	 * <b>背景图加载流程</b>
	 * <li> 加载背景图, 保存到 SceneCache.mapImgCache
	 * <li> 该缓存只被 SceneMapLayer 使用, 应内部维护
	 */
	public class SceneMapLayer extends Sprite
	{
		/*private static const MAX_ZONE_CACHE_X:int = 3;
		private static const MAX_ZONE_CACHE_Y:int = 2;
		
		private var _scene:Scene;						// 当前场景
		private var _currentCameraPos:Point;			// 当前视区/地图位置
		private var _currentMapZone:MapZone;			// 当前左上角位置的 zone
		private var _waitingLoadDatas:Object;			// 等待加载的列表, [key] = LoadData
		
		//
		public function SceneMapLayer(scene:Scene)
		{
			super();
			this._currentCameraPos = new Point(int.MAX_VALUE, int.MAX_VALUE);
			this._waitingLoadDatas = {};
			this._scene = scene;
			mouseEnabled = false;
			mouseChildren = false;
		}*/
		
		/**
		 * 清理 
		 */
		/*public function dispose():void
		{
			Fun.clearChildren(this, false, false);
			this._currentCameraPos = new Point(int.MAX_VALUE, int.MAX_VALUE);
			this._currentMapZone = null;
			this._waitingLoadDatas = {};
		}
		
		public function initMap():void
		{
//			initMapZones();
		}*/
		
		/**
		 * 初始化地图族, 建立每一个 mapZone 保存到  SceneCache.mapZones
		 * @from Scene.switchScene
		 */
		/*public function initMapZones():void
		{
			var map:Object;
			var zone_x:int;
			var zone_y:int;
			var zone:MapZone;
			var _local7:Point;
			map = {};
			var zone_width:int = (this._scene.mapConfig.mapGridX / SceneConfig.ZONE_SCALE);		// 族宽度
			var zone_height:int = (this._scene.mapConfig.mapGridY / SceneConfig.ZONE_SCALE);		// 族高度
			zone_x = 0;
			
			while (zone_x < zone_width) {
				zone_y = 0;
				while (zone_y < zone_height) {
					zone = new MapZone(this);		// 新建地图族, zone.showContainer (ShowContainer)被添加到自己的孩子中
					zone.tile_width = SceneConfig.ZONE_WIDTH;		// 设置 块 尺寸		// 在这里, 1块实际上为1区
					zone.tile_height = SceneConfig.ZONE_HEIGHT;
					zone.tile_x = zone_x;							// 块坐标
					zone.tile_y = zone_y;
					zone.showContainer.x = zone.pixel_x;			// 像素尺寸
					zone.showContainer.y = zone.pixel_y;
					map[((zone_x + "_") + zone_y)] = zone;		// [ x_y ] = MapZone
					zone_y++;
				}
				zone_x++;
			}
            SceneCache.mapZones = map;
		}*/
		
		/**
		 * 更新
		 */
		/*public function run():void
		{
			// 如果坐标未变更, 则不更新
			if (this._currentCameraPos.x == this._scene.sceneCamera.pixel_x && this._currentCameraPos.y == this._scene.sceneCamera.pixel_y) {
				return;
			}
			
			// 跟随当前视区, 计算地图位置
			this._currentCameraPos.x = this._scene.sceneCamera.pixel_x;
			this._currentCameraPos.y = this._scene.sceneCamera.pixel_y;
			
			// 检测加载新地图
			this.loadMap();
		}*/
		
		/**
		 * 加载地图 
		 */		
		/*private function loadMap():void
		{
			var _local1:MapZone;
			var loadDataList:Array;
			var loadData:LoadData;
			var distance:int;
			var point_list:Array;
			var zone_width:int;
			var zone_height:int;
			var point:Point;
			var key:String;
			var thread:HandlerThread;
			var _local15:Loader;
			var currentZones:Object = {};
			
			// 根据当前视区, 取得当前左上角的 zone 对象
			var tile_pos:Point = Transformer.transPixelPoint2TilePoint(new Point(this._scene.sceneCamera.pixel_x, this._scene.sceneCamera.pixel_y));
			var zone_pos:Point = Transformer.transTilePoint2ZonePoint(tile_pos);
			var zone:MapZone = SceneCache.mapZones[((zone_pos.x + "_") + zone_pos.y)];
			if (!zone) {
				return;
			}
			
			// 如果 zone 变更, 则进行加载处理
			if (this._currentMapZone != zone) {
				
				// 搜索视区内的所有块 point_list
				point_list = SceneUtil.findViewZonePoints(new Point(zone.tile_x, zone.tile_y), this._scene.sceneCamera.zoneRangeXY.x, this._scene.sceneCamera.zoneRangeXY.y);
				zone_width = (this._scene.mapConfig.mapGridX / SceneConfig.ZONE_SCALE);		// 地图 zone 尺寸
				zone_height = (this._scene.mapConfig.mapGridY / SceneConfig.ZONE_SCALE);
				loadDataList = [];
				for each (point in point_list) {
					if (point.x < 0 || point.x >= zone_width || point.y < 0 || point.y >= zone_height) {
						
					} else {
						key = ((point.x + "_") + point.y);					// key
						_local1 = SceneCache.currentMapZones[key];			// zone = currentMapZones
						// 如果 currentMapZones 为空, 则从 mapZones 中获取
						if (_local1 == null) {
							_local1 = SceneCache.mapZones[key];			// zone = mapZones
							currentZones[key] = _local1;				// save to currentZones
						}
							// 否则如果 currentMapZones 非空, 则删除 currentMapZones
						else {
							currentZones[key] = _local1;
							SceneCache.currentMapZones[key] = null;		// 删除该位置
							delete SceneCache.currentMapZones[key];
						}
						// 结果: currentZones[ key ] = _local1; 
						
						// 如果没有在等待队列中, 则添加到等待队列
						if (this._waitingLoadDatas[key] == null) {		// 如果某个图片加载失败, 则会被重复添加
							
							// 计算 _local1 和 zone 的距离
							distance = -(Math.round(ZMath.getDistanceSquare(_local1.pixel_x, _local1.pixel_y, zone.pixel_x, zone.pixel_y)));
							loadData = this.addMapZone(_local1, distance);		// 添加
							if (loadData) {
								loadDataList.push(loadData);
								this._waitingLoadDatas[key] = loadData;
							}
						}
					}
				}
				
				// 遍历等待队列, 按优先级排列, 然后放到 thread 中去执行
				if (loadDataList.length > 0) {
					loadDataList.sortOn(["priority"], [(Array.NUMERIC | Array.DESCENDING)]);
					thread = new Thread();
					for each (loadData in loadDataList) {
						_local15 = loadData.userData.loader;
						_local15.contentLoaderInfo.addEventListener(Event.COMPLETE, loadData.onComplete);
						_local15.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadData.onError);
						_local15.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadData.onError);
						thread.push(_local15.load, [new URLRequest(loadData.url)], 10);	// 等待10毫秒后运行
					}
				}
				
				// 删除 currentMapZones 中的 zone, 所以这里是 视野外的 zone
				for (key in SceneCache.currentMapZones) {
					_local1 = SceneCache.currentMapZones[key];
					
					// 从孩子中删除  showContainer
					if (this.contains(_local1.showContainer)){
						this.removeChild(_local1.showContainer);		// 超出视野的 zone 被删除
					}
					
					// 删除缓存
					if (Math.abs(_local1.tile_x - zone.tile_x) > (this._scene.sceneCamera.zoneRangeXY.x + MAX_ZONE_CACHE_X) 
						|| Math.abs(_local1.tile_y - zone.tile_y) > (this._scene.sceneCamera.zoneRangeXY.y + MAX_ZONE_CACHE_Y)) {
						SceneCache.mapImgCache.remove(_local1.showContainer.name);
					}
				}
				
				SceneCache.currentMapZones = currentZones;
				this._currentMapZone = zone;
			}
		}*/
		
		
		/**
		 * 添加  mapZone 加载, 如果失败, 返回  null
		 * @return LoadData
		 */
		/*private function addMapZone(zone:MapZone, distance:int):LoadData
		{
			var loadData:LoadData = null;
			var key:String = null;
			var filePath:String = null;
			var $mapZone:MapZone = zone;
			var $priority:int = distance;
			
			// 如果它的内容为空, 则加载
			if ($mapZone.showContainer.numChildren == 0) {
				key = (($mapZone.tile_x + "_") + $mapZone.tile_y);
				filePath = ((this._scene.mapConfig.zoneMapDir + key) + ".jpg");		// 全路径名
				
				// 根据 filePath 搜索缓存, 如果存在, 直接使用
				if (SceneCache.mapImgCache.has(filePath)) {
					$mapZone.showContainer.addChild((SceneCache.mapImgCache.get(filePath) as Bitmap));
				}
					// 否则, 新建加载任务
				else {
					// 加载完成
					var itemLoadComplete:Function = function (event:Event):void {
						SceneCache.mapImgCache.push(event.target.content, (event.currentTarget as LoaderInfo).url);	// 加入缓存
						$mapZone.showContainer.addChild(event.target.content);						// 显示位图
						$mapZone.showContainer.name = (event.currentTarget as LoaderInfo).url;		// url 作为 name
						_waitingLoadDatas[key] = null;		// 删除任务
						delete _waitingLoadDatas[key];
					};
					
					// 加载错误
					var itemLoadError:Function = function (event:Event):void {
						loadData.userData.retry++;		// 增加重试次数
						if (loadData.userData.retry > 3){
//							ZLog.add((("######尝试加载地图" + filePath) + "3次均失败，已经放弃加载"));
							_waitingLoadDatas[key] = null;								// 放弃加载
							delete _waitingLoadDatas[key];
						} else {
							loadData.userData.loader.load(new URLRequest(filePath));	// 继续加载
						}
					};
					
					// 构造 LoadData
					loadData = new LoadData(filePath, itemLoadComplete, null, itemLoadError, "", filePath, RslLoader.TARGET_SAME, $priority);
					loadData.userData = {
						loader:new Loader(),
						retry:0
					}
				}
			}
			
			// 添加为自己的孩子
			if ($mapZone.showContainer.parent != this){
				this.addChild($mapZone.showContainer);
			}
			return loadData;
		}*/
	}
}