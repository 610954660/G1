--UPtips说明页面
--added by xhd
local UPTyTipsView,Super = class("UPTyTipsView",Window)
function UPTyTipsView:ctor( arg )
    self._packName = "GetCardsUpActivity"
	self._compName = "UPTyTipsView"
	self.list = false
	self._rootDepth = LayerDepth.PopWindow
	self.moduleId = arg.moduleId

end

function UPTyTipsView:_initUI( ... )
   self.list = self.view:getChildAutoType("list")
end

function UPTyTipsView:_initEvent( ... )
   local config = GetCardsUPActivityModel:getAllYJZMAllConfig(self.moduleId)
   self.list:setVirtual()
   self.list:setItemRenderer(function(idx, obj)
        if tolua.isnull(obj) then return end
		local item = obj:getChildAutoType("itemCell")
		local itemcell = BindManager.bindItemCell(item)
		local itemData = ItemsUtil.createItemData({data = config[idx+1].reward[1]})
		itemcell:setIsBig(false)
		itemcell:setItemData(itemData)
		local name =  obj:getChildAutoType("name")
		local num =  obj:getChildAutoType("num")
		local rate =  obj:getChildAutoType("rate")
		name:setText(itemcell:getItemData():getName())
		num:setText("")
		-- num:setText(itemcell:getItemData():getItemAmount())
		rate:setText(config[idx+1].rewardRate.."%")
   end)
   self.list:setData(config)
end

--initUI执行之前
function UPTyTipsView:_enter( ... )

end

--页面退出时执行
function UPTyTipsView:_exit( ... )
	print(1,"UPTyTipsView _exit")
end

return UPTyTipsView