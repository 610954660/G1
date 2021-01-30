--Name : GetCardsUPAwardView.lua
--Author : generated by FairyGUI
--Date : 2020-9-3
--Desc : UP探员活动招募阶段奖励 xhd

local GetCardsUPAwardView,Super = class("GetCardsUPAwardView", Window)

function GetCardsUPAwardView:ctor()
	--LuaLog("GetCardsUPAwardView ctor")
	self._packName = "UpGetCardActivity"
	self._compName = "UpGetAwardView"
	self._rootDepth = LayerDepth.PopWindow
	self.actType = self._args.actType
	self.data = self._args.data
end

function GetCardsUPAwardView:_initEvent( )
	
end

function GetCardsUPAwardView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:UpGetCardActivity.GetCardsUPAwardView
		vmRoot.list = viewNode:getChildAutoType("$list")--list
	--{vmFieldsEnd}:UpGetCardActivity.GetCardsUPAwardView
	--Do not modify above code-------------
end

function GetCardsUPAwardView:_initUI( )
	self:_initVM()
	self.viewData = ActivityModel:getActityByType( self.actType )
	self.lotteryIdList = self.viewData.showContent.lotteryIdList
	self.config = GetCardsUPActivityModel:getAllConfig( self.viewData.showContent.countReward)
	self.list:setItemRenderer(function (index,obj)
		local curConfig = self.config[index+1]
		local recordMap
		if self.data.data  and self.data.data.rewardRecordMap then
			recordMap = self.data.data.rewardRecordMap
		else
			recordMap = self.data.rewardRecordMap
		end
		local curData = recordMap[index+1]
		local title = obj:getChildAutoType("n47")
		local progress = obj:getChildAutoType("progressBar")
		local itemCell = obj:getChildAutoType("itemCell")
		local btn_get =obj:getChildAutoType("btn_get")
		local statusCtrl = obj:getController("status")
		local img_red = btn_get:getChildAutoType("img_red")
		img_red:setVisible(false)
		title:setText(Desc.GetCard_Text16..curConfig.num..Desc.GetCard_Text17)
		progress:setMax(curConfig.num)
		local count = self.data.count and self.data.count or self.data.data.count
		if count>= curConfig.num then
			progress:setValue(curConfig.num)
			local flag = GetCardsUPActivityModel:checkHadGetAward(curConfig.id)
			if flag then
				statusCtrl:setSelectedIndex(2)
			else
				statusCtrl:setSelectedIndex(1)
				img_red:setVisible(true)
				btn_get:removeClickListener(33)
				btn_get:addClickListener(function( ... )
					local params = {}
	 		    params.id = curConfig.id
	 		    params.activityId = self.viewData.id
		 		params.onSuccess = function (res )
		 		end
		 		RPCReq.Activity_Farplane_GetReward(params, params.onSuccess)
				end,33)
			end
		else
			statusCtrl:setSelectedIndex(0)
			progress:setValue(count)
		end
		
		local itemcellObj = BindManager.bindItemCell(itemCell)
		itemcellObj:setIsBig(false)
		local itemData = ItemsUtil.createItemData({data = curConfig.reward[1]})
		itemcellObj:setItemData(itemData,CodeType.ITEM)
	end)
	self.list:setData(self.config)
end

function GetCardsUPAwardView:update_upgetCard( ... )
	print(1,"领取成功刷新列表")
	self.list:setData(self.config)
end

return GetCardsUPAwardView