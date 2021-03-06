--Name : GetSpeCardsView.lua
--Author : generated by FairyGUI
--Date : 2020-6-19
--Desc : 

local GetSpeCardsView,Super = class("GetSpeCardsView", Window)

function GetSpeCardsView:ctor()
	--LuaLog("GetSpeCardsView ctor")
	self._packName = "GetCards"
	self._compName = "GetSpeCardsView"
	self._rootDepth = LayerDepth.PopWindow
	self.keyValArr = {14,13,11,12,15} --配置不对应
	self.cost = false
	self.curIndex = 0
end

function GetSpeCardsView:_initEvent( )
	
end

function GetSpeCardsView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:GetCards.GetSpeCardsView
		vmRoot.costItem = viewNode:getChildAutoType("$costItem")--
		vmRoot.costItem3 = viewNode:getChildAutoType("$costItem3")--
		vmRoot.costItem4 = viewNode:getChildAutoType("$costItem4")--
		vmRoot.list = viewNode:getChildAutoType("$list")--list
		vmRoot.costItem1 = viewNode:getChildAutoType("$costItem1")--
		vmRoot.costItem2 = viewNode:getChildAutoType("$costItem2")--
		vmRoot.btn_zh = viewNode:getChildAutoType("$btn_zh")--Button
		vmRoot.costItem5 = viewNode:getChildAutoType("$costItem5")--
	--{vmFieldsEnd}:GetCards.GetSpeCardsView
	--Do not modify above code-------------
end

function GetSpeCardsView:_initUI( )
	self:_initVM()
	RedManager.register("V_GETCARD_SPECIAL_1",self.btn_zh:getChildAutoType("img_red"))
    -- self.list:setSelectedIndex(0)
	self.list:addEventListener(FUIEventType.ClickItem,function(context)
		local index = self.list:getSelectedIndex() + 1
		self.curIndex = index
        self.costitemObj = BindManager.bindCostItem(self.costItem)
        self.cost = DynamicConfigData.t_heroLottery[self.keyValArr[index]].cost[1]
        --printTable(1,self.cost)
        self.costitemObj:setData(self.cost.type, self.cost.code, self.cost.amount, false,true,true)
	end)

    --先更新每个位置的消耗
    local num = self.list:getNumItems()
    for i=1,num do
    	local costitemObj = BindManager.bindCostItem(self["costItem"..i])
        local cost = DynamicConfigData.t_heroLottery[self.keyValArr[i]].cost[1]
        costitemObj:setData(cost.type, cost.code, cost.amount, true)
    end

    if self.list:getSelectedIndex() <=0 then
	    self.curIndex = -1
	    self.costitemObj = BindManager.bindCostItem(self.costItem)
	    local cost =  DynamicConfigData.t_heroLottery[self.keyValArr[1]].cost[1]
	    self.cost = cost
	    self.costitemObj:setData(cost.type, cost.code,0,false,true,true)
    else
    	local index = self.list:getSelectedIndex() + 1
	    self.curIndex = index
	    self.costitemObj = BindManager.bindCostItem(self.costItem)
	    local cost =  DynamicConfigData.t_heroLottery[self.keyValArr[index]].cost[1]
	    self.cost = cost
	    self.costitemObj:setData(cost.type, cost.code, cost.amount,false,true,true)
    end

    --召唤
	self.btn_zh:addClickListener(function( ... )
		if not ModuleUtil.hasModuleOpen(ModuleId.GetSpeCards.id) then
			RollTips.show(Desc.getCard_10)
			return
		end
    	-- body
    	if self.curIndex <= 0 then
    		RollTips.show(Desc.getCard_11)
    		return
    	end
    	if not ModelManager.PlayerModel:isCostEnough(self.cost, true) then
			return
		end
		if CardLibModel:isBagFull(1) then 
			RollTips.show(Desc.getCard_bagFull)
			return 
		end
		print(1,self.curIndex,self.keyValArr[self.curIndex])
		local params = {}
		params.id = self.keyValArr[self.curIndex]
 		params.onSuccess = function (res )
 		    --printTable(1,res)
 			local data = {}
 		    data.resultList = res.resultList
 		    data.id = self.keyValArr[self.curIndex]
 		    data.cost = DynamicConfigData.t_heroLottery[self.keyValArr[self.curIndex]].cost
 			ViewManager.open("GetTYSuccessView",data)
 		end
 		RPCReq.HeroLottery_LuckyDraw(params, params.onSuccess)
	end)
	if ModuleUtil.hasModuleOpen(ModuleId.GetSpeCards.id) then
		self.btn_zh:setGrayed(false)
		self.btn_zh:setTitle(Desc.getCard_13)
	else
		self.btn_zh:setGrayed(true)
		self.btn_zh:setTitle(Desc.getCard_12)
	end
end

--更新pancel
function GetSpeCardsView:updatePanel( ... )
	-- body
end



return GetSpeCardsView