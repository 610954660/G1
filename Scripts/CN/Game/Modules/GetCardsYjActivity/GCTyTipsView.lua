--异界招募说明页面
--added by xhd
local GCTyTipsView,Super = class("GCTyTipsView",Window)
function GCTyTipsView:ctor( arg )
    self._packName = "GetCardsYjActivity"
	self._compName = "GCTyTipsView"
	self.list = false
	self._rootDepth = LayerDepth.PopWindow
	self.moduleId = arg.moduleId
end

function GCTyTipsView:_initUI( ... )
   self.list = self.view:getChildAutoType("list")
end

function GCTyTipsView:_initEvent( ... )
   local config = GetCardsYjActivityModel:getAllYJZMAllConfig(self.moduleId)
   self.list:setVirtual()
   self.list:setItemRenderer(function(idx, obj)
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
function GCTyTipsView:_enter( ... )

end

--页面退出时执行
function GCTyTipsView:_exit( ... )
	print(1,"GCTyTipsView _exit")
end

return GCTyTipsView