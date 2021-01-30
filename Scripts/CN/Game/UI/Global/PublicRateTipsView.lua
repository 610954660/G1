--UPtips说明页面
--added by wyang
local PublicRateTipsView,Super = class("PublicRateTipsView",Window)
function PublicRateTipsView:ctor( arg )
    self._packName = "UIPublic_Window"
	self._compName = "PublicRateTipsView"
	self.list = false
	self._rootDepth = LayerDepth.PopWindow
	self.data = arg
end

function PublicRateTipsView:_initUI( ... )
   self.list = self.view:getChildAutoType("list")
end

function PublicRateTipsView:_initEvent( ... )
   
   self.list:setVirtual()
   self.list:setItemRenderer(function(idx, obj)
        if tolua.isnull(obj) then return end
		local item = obj:getChildAutoType("itemCell")
		local itemcell = BindManager.bindItemCell(item)
		local itemData = ItemsUtil.createItemData({data = self.data[idx+1].reward[1]})
		itemcell:setIsBig(false)
		itemcell:setItemData(itemData)
		local name =  obj:getChildAutoType("name")
		local num =  obj:getChildAutoType("num")
		local rate =  obj:getChildAutoType("rate")
		name:setText(itemcell:getItemData():getName())
		num:setText("")
		-- num:setText(itemcell:getItemData():getItemAmount())
		rate:setText(self.data[idx+1].rewardRate.."%")
   end)
   self.list:setData(self.data)
end

--initUI执行之前
function PublicRateTipsView:_enter( ... )

end

--页面退出时执行
function PublicRateTipsView:_exit( ... )
	print(1,"PublicRateTipsView _exit")
end

return PublicRateTipsView