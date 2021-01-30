--Dex这个是Dex原本的MVVM的设计规划，准备上是用在unity的，所以这里打算方法函数命名会兼容C#版本。
--mvvm的
--VM主要是数据源绑定，数据一旦通过了VM来产出就会从新生成一个UI绑定的数据源。
--这个数据源可以被多个UI绑定。绑定后如果发生了数据变化，就会主动通知到对应的ui://****控件做相应的数据处理。
local VMBase = {}

local DataBindVM = {
	
}

local GComponent = fgui.GComponent
local GList = fgui.GList
local getChildAutoType = GComponent.getChildAutoType
local setItemRenderer = GList.setItemRenderer
local FGUIType = require "Dex.MVVM.FGUIType"
local extendMap = {
    [FGUIType.GList]   = require "Game.UI.Extend.GList",
    [FGUIType.GLoader] = require "Game.UI.Extend.GLoader",
	[FGUIType.GGraph] = require "Game.UI.Extend.GGraph",
	[FGUIType.GComponent] = require "Game.UI.Extend.GComponent"
}

function GComponent:getChildAutoType(assetPath)
	local obj, objType = getChildAutoType(self,assetPath)
	local func = extendMap[objType]
	if func then
		return func(obj)
	end
	return obj
end	

function GComponent:getChild(assetPath)
	local obj, objType = getChildAutoType(self,assetPath)
	local func = extendMap[objType]
	if func then
		return func(obj)
	end
	return obj
end

function GList:setItemRenderer(func)
	if tolua.isnull(self) then return end
	setItemRenderer(self,function(index,obj)
			if not tolua.isnull(obj) then
				obj:setName(index)--
			end
			func(index,obj)
	end)
end

function GList:setItemRendererByFrame(func)
	if tolua.isnull(self) then return end
	
	local doSchedule = true
	local data = {}
	if self.rendsid then
		Scheduler.unschedule(self.rendsid)
	end
	self.rendsid = Scheduler.schedule(function()
		if #data > 0 then
			func(data[1].index,data[1].obj)
			table.remove(data,1)	
		end
	end,0.03,0)
	self:addEventListener(FUIEventType.TouchBegin, function()
			doSchedule = false
			Scheduler.unschedule(self.rendsid)
		end,33)
	setItemRenderer(self,function(index,obj)
			if not tolua.isnull(obj) then
				obj:setName(index)--
				if doSchedule then
					table.insert(data,{index=index,obj=obj})
				else
					func(index,obj)
				end
			end
		end)
end

--所有的VM的对象在Ctor阶段根据绑定数据来做迭代查找。
function VMBase.Iter( gComponent, srcData)
	local children = srcData.children
	if children then
		for k,v in pairs(children) do
			gComponent.k = nil
		end
		gComponent:getChild()
	end
end

return VMBase