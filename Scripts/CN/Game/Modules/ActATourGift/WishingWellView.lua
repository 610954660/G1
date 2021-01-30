-- added by xhd
-- 精灵主题活动  一番巡礼许愿池

local TimeLib = require "Game.Utils.TimeLib"
local TimeUtil = require "Game.Utils.TimeUtil"
local WishingWellView = class("WishingWellView",Window)

function WishingWellView:ctor()
	self._packName 	= "ActATourGift"
	self._compName 	= "WishingWellView"

	self.config = false
	self.serverData = false
	self.curSelect = false
	self._rootDepth  = LayerDepth.PopWindow
end



function WishingWellView:_initUI()
    --已经存在大奖选择器
	self.awardList = self.view:getChildAutoType("awardList")
	self.WishBtn = self.view:getChildAutoType("WishBtn")
	--许愿池
	self.WishBtn:addClickListener(function( ... )
		if not (self.curSelect and self.curSelect.id>0) then
			RollTips.show(Desc.activity_txt28)
			return 
		end
		local params = {}
		params.activityId = ActATourGiftModel:getActivityId( )
		params.code = self.curSelect.id
		printTable(1,params)
		params.onSuccess = function (res )
			ViewManager.close("WishingWellView")
		end
		 RPCReq.Activity_ElfHis_AddWish(params, params.onSuccess)
	end)
	
	--许愿池列表
	self.awardList:setVirtual()
	self.awardList:setItemRenderer(function(idx,obj)
		local curConfig = self.awardList._dataTemplate[idx+1]
		local statusCtrl = obj:getController("statusCtrl")
		local reward 	= curConfig.reward[1]
		local itemCell = obj:getChildAutoType("itemCell")
		local itemCellObj 	= BindManager.bindItemCell(itemCell)
		itemCellObj:setIsBig(true)
		if self.curSelect and  self.curSelect.id == curConfig.id then
			itemCellObj:setClickable(true)
		else
			itemCellObj:setClickable(false)
		end
		itemCellObj:setData(reward.code, reward.amount, reward.type)
		local itemconfig = ItemConfiger.getInfoByCode(reward.code, reward.type)
		obj:getChildAutoType("itemName"):setText(itemconfig.name)
		local hadNum = ActATourGiftModel:getLimitbyCode( curConfig.id )
		obj:getChildAutoType("num"):setText(hadNum.."/"..curConfig.limit)
		statusCtrl:setSelectedIndex(0)

		if self.serverData.wish and self.serverData.wish>0 and self.serverData.wish == curConfig.id then
			statusCtrl:setSelectedIndex(1)
		end

		if hadNum>=curConfig.limit then
			statusCtrl:setSelectedIndex(2)
		end
	end)
	self.awardList:addEventListener(FUIEventType.ClickItem,function()
		local index = self.awardList:getSelectedIndex() + 1
		self.curSelect = self.config[index]
	end)
end

function WishingWellView:_initEvent( ... )
	self:initPanel()
end

function WishingWellView:initPanel( ... )
	self.serverData = ActATourGiftModel:getData( ... )
    self.config = ActATourGiftModel:getOneChooseConfig(  )
	self.awardList:setData(self.config)
	
end



function WishingWellView:updatePanel()
	
end



function WishingWellView:_exit()

end



return WishingWellView