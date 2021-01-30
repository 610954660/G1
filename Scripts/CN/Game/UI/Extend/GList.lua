--这里充当Ctor构造函数
local GListFuncs = fgui.GList
local function GListCtor(gListObj)
	if gListObj._dataProvider then
		return gListObj--表示初始化過了
	end
	gListObj._dataProvider = {}   --设置每个item的样式url数组
	gListObj._dataTemplate = {}   --绑定在虚拟列表上的每个数据
	return gListObj
end

function GListFuncs:setData(data)
	self._dataTemplate = data
	local len = #data
	self:setNumItems(len)
end

-- 在滚动结束时派发该事件。
function GListFuncs:regScrollEnd(func)
	self:addEventListener(FUIEventType.ScrollEnd,func)
end

-- 滚动事件回调
function GListFuncs:regScrollFunc(func)
	self:addEventListener(FUIEventType.Scroll,func)
end

-- item点击事件
function GListFuncs:regUnscrollItemClick(func)
	if self:isVirtual() then
		luaLog("we can not Bind ItemClick Event in VirtualList", 2)
		return
	end
	for i=0,self:getNumItems()-1 do
		self:getChildAt(i):addClickListener(function(context)
				func(i,self:getChildAt(i))
			end)
	end
end

-- 列表或者背包中某个item被其它组件拖入时的回调事件
function GListFuncs:regUnscrollItemDrop(func)
	if self:isVirtual() then
		luaLog("we can not Bind ItemDrop Event in VirtualList", 2)
		return
	end
	for i=0,self:getNumItems()-1 do
		self:getChildAt(i):addEventListener(FUIEventType.Drop,func)
	end
end


return GListCtor