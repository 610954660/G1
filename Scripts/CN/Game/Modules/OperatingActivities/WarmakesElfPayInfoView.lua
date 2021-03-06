--Name : WarmakesElfPayInfoView.lua
--Author : generated by FairyGUI
--Date : 2020-5-29
--Desc : 

local WarmakesElfPayInfoView,Super = class("WarmakesElfPayInfoView", Window)
function WarmakesElfPayInfoView:ctor()
	--LuaLog("WarmakesElfPayInfoView ctor")
	self._packName = "OperatingActivities"
	self._compName = "WarmakesPayInfoView"
	self._rootDepth = LayerDepth.FaceWindow
	self.viewIndexTag=GameDef.ActivityType.ElfWarOrder
end

function WarmakesElfPayInfoView:_initEvent( )
	
end

function WarmakesElfPayInfoView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:OperatingActivities.WarmakesElfPayInfoView
		vmRoot.btn_play = viewNode:getChildAutoType("$btn_play")--Button
		vmRoot.list_allReward = viewNode:getChildAutoType("$list_allReward")--list
		vmRoot.list_reward = viewNode:getChildAutoType("$list_reward")--list
		vmRoot.txt_dec 	= viewNode:getChildAutoType("$txt_dec")
	--{vmFieldsEnd}:OperatingActivities.WarmakesElfPayInfoView
	--Do not modify above code-------------
end


function WarmakesElfPayInfoView:_initUI( )
	self:_initVM()
	self.viewIndexTag=self._args.actType
	local priceid=OperatingActivitiesModel:getWarmakesElfActiveRealType(self.viewIndexTag)
	local price=  DynamicConfigData.t_BpJlActive[priceid].price or 98
	self.btn_play:setTitle(price..Desc.activity_txt7)

	local exp=  DynamicConfigData.t_BpJlActive[priceid].getExp or 18000
	self.txt_dec:setText(string.format(Desc.WarmakesActive_exp,exp))

	local tableAll={}
	local tableCur={}
	local allrewardInfo={}
	local currewardInfo={}
	local configInfo=DynamicConfigData.t_BpJlActiveUp
	if self.viewIndexTag==GameDef.ActivityType.ElfWarOrder or 
	 self.viewIndexTag==GameDef.ActivityType.BoundaryWarOrder or
	 self.viewIndexTag==GameDef.ActivityType.MazeWarOrder  or 
	 self.viewIndexTag==GameDef.ActivityType.EndlessRoadWarOrder or
	 self.viewIndexTag==  GameDef.ActivityType.HallowWarOrder  or
	 self.viewIndexTag== GameDef.ActivityType.SmallElfWarOrder 
	  then
		configInfo=DynamicConfigData.t_BpJlActiveUp
	end
	local type=OperatingActivitiesModel:getWarmakesElfActiveRealType(self.viewIndexTag)
		local configInfo=configInfo[type]
		if not configInfo then
			return
		end
		local teshulingquLv=OperatingActivitiesModel.WarmakesElfActiveInfo[self.viewIndexTag].seniorRewardLv
		local curLv=OperatingActivitiesModel:getWarmakesElfActiveAddNumLevel(self.viewIndexTag,exp)
		for key, value in pairs(configInfo) do
			local limitLv=value.level
			if limitLv<=curLv and teshulingquLv<curLv then
				table.insert(tableCur,value.payReward)	
			end
			table.insert(tableAll,value.payReward)	
		end
	allrewardInfo=TableUtil:getReward(tableAll,1)
	currewardInfo=TableUtil:getReward(tableCur,1)
printTable(12,">>>>>>>>>dsfaew",allrewardInfo)
	self.list_allReward:setItemRenderer(function(index,rewardObj)
		rewardObj:removeClickListener(100)
		--池子里面原来的事件注销掉
	   local itemcell = BindManager.bindItemCell(rewardObj)
	   local award = allrewardInfo[index + 1]
	   itemcell:setData(award.code, award.amount, award.type)
	  -- itemcell:setFrameVisible(false)
	  rewardObj:addClickListener(function( ... )
		itemcell:onClickCell()
	   end,100)
	end)
	self.list_allReward:setNumItems(#allrewardInfo);


	self.list_reward:setItemRenderer(function(index,rewardObj)
		rewardObj:removeClickListener(100)
		--池子里面原来的事件注销掉
	   local itemcell = BindManager.bindItemCell(rewardObj)
	   local award =currewardInfo[index + 1]
	   itemcell:setData(award.code, award.amount, award.type)
	  -- itemcell:setFrameVisible(false)
	  rewardObj:addClickListener(function( ... )
		   itemcell:onClickCell()
	   end,100)
	end)
	self.list_reward:setNumItems(#currewardInfo);
end


--事件初始化
function WarmakesElfPayInfoView:_initEvent(...)
    self.btn_play:addClickListener(
		function(...)
			local priceid=OperatingActivitiesModel:getWarmakesElfActiveRealType(self.viewIndexTag)
			local config = DynamicConfigData.t_BpJlActive[priceid]
			if config then
				local order=GameDef.StatFuncType.SFT_ElfWarOrder
				if self.viewIndexTag==GameDef.ActivityType.ElfWarOrder then
					order=GameDef.StatFuncType.SFT_ElfWarOrder
				elseif self.viewIndexTag==GameDef.ActivityType.BoundaryWarOrder then
					order=GameDef.StatFuncType.SFT_BoundaryWarOrder
				elseif self.viewIndexTag==GameDef.ActivityType.MazeWarOrder then
					order=GameDef.StatFuncType.SFT_MazeWarOrder
				elseif self.viewIndexTag==GameDef.ActivityType.EndlessRoadWarOrder then
					order=GameDef.StatFuncType.SFT_EndlessRoadWarOrder
				elseif self.viewIndexTag==GameDef.ActivityType.HallowWarOrder then
					order=GameDef.StatFuncType.SFT_HallowWarOrder
				elseif self.viewIndexTag==GameDef.ActivityType.SmallElfWarOrder then
					order=GameDef.StatFuncType.SFT_SmallElfWarOrder
				end
				local price= config.price or 98
				ModelManager.RechargeModel:directBuy(price, order, config.moduleId, Desc.recharge_ElfWarmakes,nil,config.showName1)
			end
            -- RollTips.show("暂未开启充值")
        end
    )
end

return WarmakesElfPayInfoView