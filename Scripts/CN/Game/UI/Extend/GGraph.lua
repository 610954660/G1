--这里充当Ctor构造函数
local GGraphFuncs = fgui.GGraph

local DragDropManager=fgui.DragDropManager

require("Game.Managers.DragDropManager")
local function GGraphCtor(graphObj)
	--if graphObj.dragEnd then
		--return gLoaderObj--表示初始化過了
	--end
	--graphObj.dragEnd=false
	graphObj.dragDropManager=DragDropManager:getInstance()--GLoader替身拖拽管理类
	graphObj.dragAgent=graphObj.dragDropManager:getAgent()
	return graphObj
end

-- 替身拖动注册开始
function GGraphFuncs:toAgentDrag(context,userData,func)
	--取消掉源拖动
	context:preventDefault();
	--icon是这个对象的替身图片url，userData可以是任意数据，底层不作解析。context.data是手指的id。
	self.dragDropManager:startDrag(self, userData, context:getInput():getTouchId());
	--gLoaderObj.dragAgent():displayObject():addChild(self.skeletonNode)
	--self.dragAgent:setFill(2)--纹理填充方式：适应高度
	dragDropManager():addSingelEvent(FUIEventType.DragEnd,func)
end

--替身拖动事件必须先注册cloneDragSrart
function GGraphFuncs:cloneDragMove(func)
	--getAgent就是拿到的Gloader替身对象
	dragDropManager():addSingelEvent(FUIEventType.DragMove,func)
end

-- 组件本身被拖动的功能
function GGraphFuncs:DragStart(func)
	self:setDraggable(true)
	self:addEventListener(FUIEventType.DragStart,func);
end
-- 组件本身被拖动的功能
function GGraphFuncs:DragMove(func)
	self:GGraphFuncs(FUIEventType.DragMove,func);
end
-- 组件本身被拖动结束的功能
function GGraphFuncs:DragEnd(func)
	self:addEventListener(FUIEventType.DragEnd,func);
end
---- 组件被拖放的功能
--function GLoaderFuncs:onDrop(func)
--self:addEventListener(FUIEventType.Drop,func);
--end



----isSync: 是否同步加载。默认是异步，值为nil，只有同步时才会设置为true。
--function GLoaderFuncs:setUrl(url)
--self:setURL(url)
--end
--function GLoaderFuncs:getUrl()
--return self:getURL()
--end
return GGraphCtor
