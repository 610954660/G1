local PataEndLayer,Super = class("PataEndLayer", View)
local ItemCell = require "Game.UI.Global.ItemCell"
--爬塔奖励展示（通关和扫荡）
function PataEndLayer:ctor()
	LuaLogE("PataEndLayer ctor")
	self._packName = "Pata"
	self._compName = "PataEndLayer"

	self._rootDepth = LayerDepth.Window

	self.win = false
	self.lose = false
	self.rewardList = false
	self.bg = false
	self.btnNext = false
	self.btnCancle = false
end

function PataEndLayer:_initUI()
	LuaLogE("PataEndLayer _initUI")

	self.bg = self.view:getChildAutoType("bg")
	self.win = self.view:getChildAutoType("win")
	self.lose = self.view:getChildAutoType("lose")
	self.rewardList =  self.view:getChildAutoType("rewardList")
	self.btnNext =  self.view:getChildAutoType("btn_next")
	self.btnCancle =  self.view:getChildAutoType("btn_cancle")

	self:updateView()
end

function PataEndLayer:updateView()
	local isSuccess = ModelManager.PataModel:getSuccess()
	local floor = ModelManager.PataModel:getCurFloor()
	local playType = ModelManager.PataModel:getPlayType()
	self.win:setVisible(isSuccess)
	self.lose:setVisible(not isSuccess)
	self.bg:addClickListener(function ( ... )
		ViewManager.close("PataEndLayer")
	end)
	self.btnNext:addClickListener(function( ... )
		ViewManager.close("PataEndLayer")
		--TODO next excute
	end)
	self.btnCancle:addClickListener(function( ... )
		ViewManager.close("PataEndLayer")
	end)
	if isSuccess then
		if playType ==0 then playType = 2000 end
		local cfg_tower = DynamicConfigData.t_tower[ playType ]
		local floorInfo = cfg_tower[ floor-1 ] or DT  -- ? 需要测试下。
		local rewardPre = floorInfo.rewardPre
		if self._args and self._args.type == 2 then
			local cfg_drop = DynamicConfigData.t_drop[ floorInfo.cleanReward ]
			if cfg_drop then
				rewardPre = cfg_drop.item1
			end
		end
		self.rewardList:setItemRenderer(function(index,obj)
				local itemcell = BindManager.bindItemCell(obj)
				local itemData = ItemsUtil.createItemData({data = rewardPre[index + 1]})
				itemcell:setItemData(itemData)
				-- obj:addClickListener(function( ... )
				-- 	itemcell:onClickCell()
				-- end)
			end
		)
		self.rewardList:setData(rewardPre)
	end
end




function PataEndLayer:_initEvent( ... )

end

function PataEndLayer:_exit()
	Dispatcher.dispatchEvent(EventType.pata_showNext)
end

return PataEndLayer
