--Date :2021-01-28
--Author : added by xhd
--Desc : 新英雄皮肤售卖概率说明

local ActNewHeroTipsView,Super = class("ActNewHeroTipsView",Window)
function ActNewHeroTipsView:ctor( arg )
    self._packName = "GetCardsYjActivity"
	self._compName = "GCTyTipsView"
	self.list = false
	self._rootDepth = LayerDepth.PopWindow
	self.moduleId = arg.moduleId
end

function ActNewHeroTipsView:_initUI( ... )
   self.list = self.view:getChildAutoType("list")
end

function ActNewHeroTipsView:_initEvent( ... )
   local config = ActNewHeroPrayModel:getAllYJZMAllConfig(self.moduleId)
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
function ActNewHeroTipsView:_enter( ... )

end

--页面退出时执行
function ActNewHeroTipsView:_exit( ... )
	print(1,"ActNewHeroTipsView _exit")
end

return ActNewHeroTipsView
