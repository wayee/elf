﻿package mm.elf.loader
{
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	
	import com.adobe.serialization.json.JSON;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	
	import mm.elf.ElfScene;
	import mm.elf.events.ElfEvent;
	import mm.elf.events.ElfEventActionProcess;
	import mm.elf.tools.SceneCache;
	import mm.elf.tools.SceneLoader;
	import mm.elf.utils.ElfG;
	import mm.elf.utils.SceneUtil;
	import mm.elf.vo.map.MapInfo;
	import mm.elf.vo.map.MapTile;
	import mm.elf.vo.map.SceneInfo;
	import mm.wit.event.EventDispatchCenter;
	import mm.wit.loader.LoadData;
	import mm.wit.manager.LoaderManager;
	import mm.wit.utils.Fun;

	/**
	 * 地图加载器
	 * <li> 地图配置信息加载
	 * <li> 小地图加载
	 *  
	 * @author Andy Cai <huayicai@gmail.com>
	 * 
	 */
	public class MapLoader
	{
		/**
		 * 加载地图
		 * <li>根据 GlobalConfig.decode 解密压缩包中的每个文件
		 * 
		 * @param mapPicId 地图图片ID
		 * @param mapURL 配置文件URL(已经弃用，根据mapId获取)
		 * @param targetScene 目标场景
		 * @param completeHandler onComplete(mapConfig, MapTileInfo, MapSolidInfo)
		 * @param updateHandler onUpdate
		 */
		public static function loadMapConfig(mapPicId:int, targetScene:ElfScene, 
											 completeHandler:Function=null, updateHandler:Function=null):void
		{
			// 加载完成
			var newOnComplete:Function = function (event:Event):void {
				var data:String;
				if (event.target is LoadingItem) {		// BulkLoader 中的信息
					data = event.target.content;
				} else {
					data = event.target.data;
				}
				
				// 需要解密
//				if (GlobalConfig.decode != null){
//					// 获取第一个文件的内容, 通过  GlobalConfig.decode 来解密
//					data = ZZip.extractFristTextFileContent(data, GlobalConfig.decode);	
//					if (data == ""){
//						return;
//					}
//				}
				
				/**
				 * JSON 格式，建立MapConfig对象
				 * {
				 *   "id":1234, "name":"earthSceneA", "mapGridX":水平格子数, "mapGridY":垂直格子数,
				 *   "slipcovers":[{"id":123, "x":111, "y":222}, {}, ...], 
				 *   "tiles":"0,0,0,0,0,0,0,0"
				 * }
				 * 
				 * tiles中，0可通过, 1不可通过, 2可通过并遮挡
				 * 
				 */
				
				data = data.replace(/\s/g, ''); // 去掉json字符串中的所有空白
				var dataObj:Object = JSON.decode(data);
				if (!dataObj) return;
				
				var mapConfig:MapInfo = new MapInfo;
				mapConfig.mapID = dataObj.id;
				mapConfig.mapGridX = dataObj.mapGridX;	// 水平格子(块)数量 
				mapConfig.mapGridY = dataObj.mapGridY;	// 垂直格子(块)数量
				mapConfig.width = mapConfig.mapGridX * SceneInfo.TILE_WIDTH;			// 宽度
				mapConfig.height = mapConfig.mapGridY * SceneInfo.TILE_HEIGHT;		// 高度
				mapConfig.mapUrl = ElfG.getMapPath(dataObj.pic.toString()); 		// 地图路径
				mapConfig.smallMapUrl = ElfG.getSmallMapPath(dataObj.pic.toString()); 	// 小地图路径
				
				// 覆盖物
//				if (dataObj && dataObj.slipcovers) {
//					var covers:Array = dataObj.slipcovers;
//					var sourcePath:String = '';
//					var coverObj:Object;
//					if (covers && covers.length>0) {
//						for each (var cover:Object in covers) {
//							sourcePath = ElfG.getAvatarMapSlipcoverPath(cover.id);
//							coverObj = {pixelX:int(cover.x), pixelY:int(cover.y), sourcePath:sourcePath};
//							mapConfig.slipcovers.push(coverObj);
//						}
//					}
//				}
				
				// 地图位置信息
				var tileInfo:Array = String(dataObj.tiles).split(',');
				var len:int = tileInfo.length;
				var transports:Object = SceneCache.transports;			// [ mapId_x_y ] != undefined => 传送点
				var mapId:int = mapConfig.mapID;
				var mapTile:Object = {};		// [ x_y ] = MapTile
				var mapSolids:Object = {};		// [ x_y ] = isSolid
				var tileX:int;
				var tileY:int;
				var tileValue:int;
				var realTiles:Object = new Object;
				for (var i:int=1; i<=len; i++) { // [0, 0] 开始
					var tileArr:Array = SceneUtil.idToTile(i, mapConfig.mapGridX, mapConfig.mapGridY);
					tileX = tileArr[0];
					tileY = tileArr[1];
					tileValue = int(tileInfo[i-1]);
					realTiles[i] = tileInfo[i-1];
					mapTile[tileX + '_' + tileY] = new MapTile(tileX, tileY, tileValue==1, tileValue==0, tileValue==2, transports[mapId+'_'+tileX+'_'+tileY]!=undefined);
					mapSolids[tileX + '_' + tileY] = tileValue==1 ? 1 : 0; // 障碍的数据：0为可通过，1为障碍
				}
				
//				mapConfig.grid = tileInfo;
				mapConfig.mapData = {tiles:realTiles, mapGridX:dataObj.mapGridX, mapGridY:dataObj.mapGridY, id:dataObj.id, pic:dataObj.pic};
				
				if (completeHandler != null){
					// completeHandler(mapConfig, MapTileInfo, MapSolidInfo)
					completeHandler(mapConfig, mapTile, mapSolids);
				}
			}
			
			// 暂停小地图
			SceneLoader.smallMapImgLoader.pauseAll();
			SceneLoader.smallMapImgLoader.removeAll();
			
			var loadData:LoadData = new LoadData(ElfG.getMapConfigPath(mapPicId.toString()), newOnComplete, updateHandler);
			LoaderManager.load([loadData], SceneLoader.smallMapImgLoader);
		}
		
		/**
		 * 载入小地图
		 * 
		 * @event SceneEvent.PROCESS, SceneEventAction_process.LOAD_SMALL_MAP_COMPLETE 加载完成
		 * 
		 */
		public static function loadSmallMap(scene:ElfScene):void
		{
			var loadSmallMapComplete:Function = function (event:Event):void {
				var loadItem:LoadingItem = (event.target as LoadingItem);
				var smallMap:Bitmap = loadItem.content as Bitmap;
				if (smallMap) {
					smallMap.width = scene.mapConfig.width;
					smallMap.height = scene.mapConfig.height;
					scene.sceneSmallMapLayer.addChild(smallMap);		// 添加小地图显示
					var sceneEvent:ElfEvent = new ElfEvent(ElfEvent.PROCESS, ElfEventActionProcess.LOAD_SMALL_MAP_COMPLETE, smallMap.bitmapData);
					EventDispatchCenter.getInstance().dispatchEvent(sceneEvent);
				}
			}
				
			Fun.clearChildren(scene.sceneSmallMapLayer, true);		// clearup
			SceneLoader.smallMapImgLoader.pauseAll();
			SceneLoader.smallMapImgLoader.removeAll();
			
			LoaderManager.lazyLoad(loadSmallMapComplete, SceneLoader.smallMapImgLoader, false, scene.mapConfig.smallMapUrl);
		}
	}
}