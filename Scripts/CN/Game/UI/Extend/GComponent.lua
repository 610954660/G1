--这里充当Ctor构造函数
local GComponentFuncs = getmetatable(fgui.GComponent)
local DragDropManager=fgui.DragDropManager

local function GComponentCtor(GComponentObj)
	if GComponentObj.created then
		return GComponentObj
	end
	GComponentObj._bindClass = false
	GComponentObj._bindClassPath = false
	GComponentObj.dragEnd=false
	GComponentObj.created=true
	GComponentObj.dragDropManager=DragDropManager:getInstance()--GLoader替身拖拽管理类
	return GComponentObj
end


--长按事件 func:回调 time:长按触发时间 endcall:长按结束
function GComponentFuncs:addLongPressListener(func,time,endcall)
	if not time then time = 0.5 end
	local actives = 0
	self:addEventListener(FUIEventType.TouchBegin,function(context)
			print(33,"ssssssssssssddd")
			actives = time*10
			context:captureTouch()
			local actions = cc.Sequence:create(cc.DelayTime:create(time),
				cc.CallFunc:create(function( ) if actives > 0 and func then func(context) end end))
			actions:setTag(666)
			self:displayObject():stopActionByTag(666)
			self:displayObject():runAction(actions)
		end,5330)
	
	self:addEventListener(FUIEventType.TouchMove,function(context)
			--actives = actives - 1
		end,5330)
	
	self:addEventListener(FUIEventType.TouchEnd,function(context)
			actives = 0
			if endcall then endcall() end
		end,5330)
end

function GComponentFuncs:removeLongPressListener()
	self:removeEventListener(FUIEventType.TouchEnd,5330)
	self:removeEventListener(FUIEventType.TouchMove,5330)
	self:removeEventListener(FUIEventType.TouchEnd,5330)
end

--对显示对象添加了
function GComponentFuncs:setBindClass(classPath, classObj)
	self._bindClassPath = classPath
	self._bindClass = classObj
end

function GComponentFuncs:getBindClass()
	return self._bindClass
end

function GComponentFuncs:getBindClassPath()
	return self._bindClassPath
end


-- 替身拖动注册开始
function GComponentFuncs:toAgentDrag(context,userData,func)
	--取消掉源拖动
	context:preventDefault();
	--icon是这个对象的替身图片url，userData可以是任意数据，底层不作解析。context.data是手指的id。
	self.dragDropManager:startDrag(self, userData, context:getInput():getTouchId());
	--gLoaderObj.dragAgent():displayObject():addChild(self.skeletonNode)
	--self.dragAgent:setFill(2)--纹理填充方式：适应高度
	dragDropManager():addSingelEvent(FUIEventType.DragEnd,func)
end

--替身拖动事件必须先注册cloneDragSrart
function GComponentFuncs:cloneDragMove(func)
	--getAgent就是拿到的Gloader替身对象
	dragDropManager():addSingelEvent(FUIEventType.DragMove,func)
end

-- 组件本身被拖动的功能
function GComponentFuncs:DragStart(func)
	self:setDraggable(true)
	self:addEventListener(FUIEventType.DragStart,func);
end
-- 组件本身被拖动的功能
function GComponentFuncs:DragMove(func)
	self:addEventListener(FUIEventType.DragMove,func);
end
-- 组件本身被拖动结束的功能
function GComponentFuncs:DragEnd(func)
	self:addEventListener(FUIEventType.DragEnd,func);
end



return GComponentCtor