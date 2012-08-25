package mm.elf.helper
{
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import mm.elf.ElfCharacter;
	import mm.elf.events.ElfEvent;
	import mm.elf.events.ElfEventActionWalk;
	import mm.elf.tools.SceneCache;
	import mm.elf.utils.SceneUtil;
	import mm.elf.utils.StaticData;
	import mm.elf.utils.Transformer;
	import mm.elf.vo.map.MapTile;
	import mm.wit.event.EventDispatchCenter;
	import mm.wit.utils.Astar;

	/**
	 * 走路帮助类 
	 */
	public class WalkHelper
	{
		/**
		 * 停止走路 
		 * @param sceneChar 角色对象
		 * @param b 是否站立
		 */
		public static function stopWalk(sceneChar:ElfCharacter, b:Boolean=true):void
		{
			sceneChar.walkData.clear();
			if (sceneChar == sceneChar.scene.mainChar) {
				sceneChar.scene.hideMouseChar();
			}
			
			if (b){
				sceneChar.setStatus(StaticData.STATUS_TYPE_STAND);
			}
		}
		
		/**
		 * 反转路径 
		 * @param sceneChar
		 */
		public static function reviseWalkPath(sceneChar:ElfCharacter):void
		{
			if (sceneChar == sceneChar.scene.mainChar) { // 主角
				if (sceneChar.avatar.status == StaticData.STATUS_TYPE_WALK) { // 正在走路
					if (sceneChar.walkData.walk_targetP != null) { // 目标点不为空
						walk(sceneChar, sceneChar.walkData.walk_targetP, -1, 
							sceneChar.walkData.walk_standDis, sceneChar.walkData.walk_vars);
					} else {
						sceneChar.walkData.clear();
					}
				}
			} else {
				sceneChar.walkData.clear();
			}
		}

		/**
		 * 走路 
		 * @param sceneChar 角色对象
		 * @param targetTilePoint 目标点, tileX, tileY
		 * @param walkSpeed
		 * @param error 当前位置到目标点可接受的误差值
		 * @param walkVars 回调onWalkArrived, onWalkThrough, onWalkUnable
		 */
		public static function walk(sceneChar:ElfCharacter, targetTilePoint:Point, 
									walkSpeed:Number=-1, error:Number=0, walkVars:Object=null):void
		{
			var sceneEvent:ElfEvent;
			
			// 不可到达的点
			var mapTile:MapTile = SceneCache.mapTiles[targetTilePoint.x + "_" + targetTilePoint.y];
			if (mapTile == null) {
				if (sceneChar.isMainChar()) {
					sceneChar.scene.hideMouseChar();
					sceneEvent = new ElfEvent(ElfEvent.WALK, ElfEventActionWalk.UNABLE, [sceneChar, mapTile]);
					EventDispatchCenter.getInstance().dispatchEvent(sceneEvent);
				}
				if (walkVars != null && walkVars.onWalkUnable != null) { // “不可到达”回调
					walkVars.onWalkUnable(sceneChar, mapTile);
				}
				return;
			}
			sceneChar.walkData.clear();
			
			// 已经到达目标点
			if (sceneChar.tile_x == targetTilePoint.x && sceneChar.tile_y == targetTilePoint.y) {
				if (sceneChar == sceneChar.scene.mainChar) {
					sceneChar.scene.hideMouseChar();
					sceneEvent = new ElfEvent(ElfEvent.WALK, ElfEventActionWalk.ARRIVED, [sceneChar, mapTile]);
					EventDispatchCenter.getInstance().dispatchEvent(sceneEvent);
				}
				if (walkVars != null && walkVars.onWalkArrived != null) { // “到达”回调
					walkVars.onWalkArrived(sceneChar, mapTile);
				}
				return;
			}
			
			// 在误差范围内可算到达目标
			var pixelP:Point = new Point(mapTile.pixel_x, mapTile.pixel_y);
			var distance:Number;
			if (error != 0) {
				// 角色当前位置与目标点的直线距离的平方
				distance = (sceneChar.pixel_x - mapTile.pixel_x) * (sceneChar.pixel_x - mapTile.pixel_x) + (sceneChar.pixel_y - mapTile.pixel_y) * (sceneChar.pixel_y - mapTile.pixel_y);
				if (distance <= (error * error)) { // 距离小于一个“误差值”，可以算到达目标
					sceneChar.faceToTile(targetTilePoint.x, targetTilePoint.y); // 面向目标点
					if (sceneChar == sceneChar.scene.mainChar) {
						sceneChar.scene.hideMouseChar();
						mapTile = SceneCache.mapTiles[sceneChar.tile_x + "_" + sceneChar.tile_y];
						sceneEvent = new ElfEvent(ElfEvent.WALK, ElfEventActionWalk.ARRIVED, [sceneChar, mapTile]);
						EventDispatchCenter.getInstance().dispatchEvent(sceneEvent);
					}
					if (walkVars != null && walkVars.onWalkArrived != null) {
						walkVars.onWalkArrived(sceneChar, mapTile);
					}
					return;
				}
			}
			
			// 角色当前位置是不可到达
			var currentPosTile:MapTile = SceneCache.mapTiles[sceneChar.tile_x + "_" + sceneChar.tile_y];
			mapTile = SceneUtil.getRoundMapTile(currentPosTile, mapTile);
			if (mapTile == null) {
				sceneChar.faceToTile(targetTilePoint.x, targetTilePoint.y);
				if (sceneChar == sceneChar.scene.mainChar) {
					sceneChar.scene.hideMouseChar();
					sceneEvent = new ElfEvent(ElfEvent.WALK, ElfEventActionWalk.UNABLE, [sceneChar, mapTile]);
					EventDispatchCenter.getInstance().dispatchEvent(sceneEvent);
				}
				if (walkVars != null && walkVars.onWalkUnable != null) {
					walkVars.onWalkUnable(sceneChar, mapTile);
				}
				return;
			}
			
			
			var walkPaths:Array = [];
			var isIsland:Boolean = mapTile.isIsland;
			if (isIsland) { // 目标点是孤立的
				walkPaths = Astar.search(SceneCache.mapSolids, mapTile.tile_x, mapTile.tile_y, sceneChar.tile_x, sceneChar.tile_y);
			} else {
				walkPaths = Astar.search(SceneCache.mapSolids, sceneChar.tile_x, sceneChar.tile_y, mapTile.tile_x, mapTile.tile_y);
			}
			
			if (walkPaths == null || walkPaths.length < 2) { // 目标点就在当前位置
				sceneChar.faceToTile(targetTilePoint.x, targetTilePoint.y);
				if (sceneChar == sceneChar.scene.mainChar) {
					sceneChar.scene.hideMouseChar();
					sceneEvent = new ElfEvent(ElfEvent.WALK, ElfEventActionWalk.UNABLE, [sceneChar, mapTile]);
					EventDispatchCenter.getInstance().dispatchEvent(sceneEvent);
				}
				if (walkVars != null && walkVars.onWalkUnable != null) {
					walkVars.onWalkUnable(sceneChar, mapTile);
				}
				return;
			}
			
			if (!isIsland) { // 非孤立的
				walkPaths = walkPaths.reverse(); // 路径反转
			}
			
			var tilePoint:Array;
			var lastTilePoint:Array = walkPaths[walkPaths.length - 1];
			var pixelPoint:Point;
			if (error != 0) {
				for each (tilePoint in walkPaths) { // tilePoint[0] = tileX, tilePoint[1] = tileY
					// 转换为像素点
					pixelPoint = Transformer.transTilePoint2PixelPoint(new Point(tilePoint[0], tilePoint[1]));
					// 两点直线距离小于误差，算达到目标
					if (((pixelPoint.x - pixelP.x) * (pixelPoint.x - pixelP.x) + (pixelPoint.y - pixelP.y) * (pixelPoint.y - pixelP.y)) <= (error * error)) {
						// 删除后面的路径
						walkPaths = walkPaths.slice(0, (walkPaths.indexOf(tilePoint) + 1));
						break;
					}
				}
			} else {
				tilePoint = lastTilePoint; // tilePoint没有使用，意欲何为
			}
			walk0(sceneChar, walkPaths, targetTilePoint, walkSpeed, error, walkVars);
		}
		
		/**
		 * 这个才是真正的计算好所有走路的数据，然后更新到SceneCharacter.walkData
		 * 在WalkStep.step()及根据walkData来执行走路 
		 * @param sceneChar 场景角色
		 * @param walkPaths A* 计算后的路径数据 [[tileX, tileY], [tileX, tileY], ...]
		 * @param targetTilePoint 目标, tileX, tileY
		 * @param walkSpeed 走路速度
		 * @param error 误差
		 * @param walkVars 回调函数表 onWalkArrived/onWalkThrough
		 */
		public static function walk0(sceneChar:ElfCharacter, walkPaths:Array, 
									 targetTilePoint:Point=null, walkSpeed:Number=-1, 
									 error:Number=0, walkVars:Object=null):void
		{
			var sceneEvent:ElfEvent;
			
			if (walkPaths.length < 1) {	// < 2表示包括现在位置， < 1则不包括
				return;
			}
			var pathData:Array = walkPaths;
			sceneChar.walkData.clear();
			
			if (sceneChar == sceneChar.scene.mainChar) {
				// 碰撞处理
//				if (sceneChar.walkData.walk_pathCutter == null){
//					sceneChar.walkData.walk_pathCutter = new PathCutter(sceneChar);
//				}
//				sceneChar.walkData.walk_pathCutter.cutMovePath(pathData);
//				sceneChar.walkData.walk_pathCutter.walkNext(-1, -1);
			}
			
			// 设置走路速度
			if (walkSpeed >= 0) {
				sceneChar.setSpeed(walkSpeed);
			}
			
			// 设置目标点
			var lastPoint:Array;
			if (targetTilePoint != null) {
				sceneChar.walkData.walk_targetP = targetTilePoint;
			} else { // 没设定就使用走路路径的最后一点
				lastPoint = pathData[pathData.length - 1];
				sceneChar.walkData.walk_targetP = new Point(lastPoint[0], lastPoint[1]);
			}
			
			sceneChar.walkData.walk_standDis = error;
			sceneChar.walkData.walk_vars = walkVars;
			
			// 删除起点
//			var firstPoint:Array = pathData.shift();
//			if (sceneChar.tile_x != firstPoint[0]) {
//				sceneChar.tile_x = firstPoint[0];
//			}
//			if (sceneChar.tile_y != firstPoint[1]) {
//				sceneChar.tile_y = firstPoint[1];
//			}
			sceneChar.walkData.walk_pathArr = pathData;
			
			var lastPoint2:Array = pathData[pathData.length - 1];
			var lastPointMapTile:MapTile = SceneCache.mapTiles[lastPoint2[0] + "_" + lastPoint2[1]];
			if (sceneChar.isMainChar()) {
				sceneChar.scene.showMouseChar(lastPoint2[0], lastPoint2[1]);
				sceneEvent = new ElfEvent(ElfEvent.WALK, ElfEventActionWalk.READY, [sceneChar, lastPointMapTile, pathData]);
				EventDispatchCenter.getInstance().dispatchEvent(sceneEvent);
			}
			if (walkVars != null && walkVars.onWalkReady != null) {
				walkVars.onWalkReady(sceneChar, lastPointMapTile);
			}
		}
		
		public static function walk1(sceneChar:ElfCharacter, pathByteData:ByteArray, targetTilePoint:Point=null, walkSpeed:Number=-1, error:Number=0, walkVars:Object=null):void
		{
//			var arr:Array = PathConverter.convertToPoint(pathByteData);
//			walk0(sceneChar, arr, targetTilePoint, walkSpeed, error, walkVars);
		}
	}
}