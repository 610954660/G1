---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: ljj
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local MatchPointBoard, Super = class("MatchPointBoard", BindView)

function MatchPointBoard:ctor()
    self._packName = "CardSystem"
    self._compName = "MatchPointBoard"
	self._rootDepth = LayerDepth.PopWindow
	self._isFullScreen = true
	
    self.confirm = false
    self.resetPoint = false
    self.matPointHelp = false
    self.freePoint = false
    self.btn_autoSet = false

	self.addPointClose  = false
	
	self.allotLists = {{},{},{}} --分配点数
	self.resetCost = false
	self._openVip = {0,6,8}  --三种类型的vip开放等级
	self._switchGold = {0,50000,100000}  --三种类型的vip开放等级
	self._curType = 1  --选中的类型
end

function MatchPointBoard:_initUI()
	
    self.editorList = self.view:getChildAutoType("_Glist$editorPoint")

    self.confirm = self.view:getChildAutoType("confirm")
    self.btn_switchComfirm = self.view:getChildAutoType("btn_switchComfirm")
    local resetPoint = self.view:getChildAutoType("resetPoint")
	if resetPoint then
		self.resetPoint = BindManager.bindCostButton(resetPoint)
	end
    --
    self.freePoint = self.view:getChildAutoType("freePoint")
    self.btn_autoSet = self.view:getChildAutoType("btn_autoSet")
    self.btn_type1 = self.view:getChildAutoType("btn_type1")
    self.btn_type2 = self.view:getChildAutoType("btn_type2")
    self.btn_type3 = self.view:getChildAutoType("btn_type3")

	
	self:bindEvent()
	self:_refresh()
end

--绑定事件
function MatchPointBoard:bindEvent()
	
	self.btn_type1:addClickListener(function() self:doSwitchType(1) end)
	self.btn_type2:addClickListener(function() self:doSwitchType(2) end)
	self.btn_type3:addClickListener(function() self:doSwitchType(3) end)
	
	self.confirm:addClickListener(
        function(context)
            --配点确定
            local temp = {}
            for key, value in pairs(self.allotLists[self._curType]) do
                local info = {}
                info["type"] = key
                info["num"] = value
                temp[key] = info
            end
            printTable(8, "配点>>>", temp, self.allotLists[self._curType])
            ModelManager.CardLibModel:heroAttrPointPlanSet(self._curType, self.heroInfo.uuid, temp)
        end
    )
	if self.resetPoint then
		self.resetPoint:addClickListener(
			function(context)
				local setPointNum = 0
				for _,v in pairs(self.heroInfo.attrPointPlanNew[self.heroInfo.attrPointId].points) do
					setPointNum = setPointNum + v.num
				end
				if setPointNum == 0 then
					RollTips.show(Desc.card_resetPoint3)
					return
				end
				
				
				if not ModelManager.PlayerModel:isCostEnough(self.resetCost) then
					return
				end
				
				local hintStr = ""
				if #self.resetCost == 0 then
					hintStr = Desc.card_resetPoint1
				else
					hintStr = string.format(Desc.card_resetPoint2, self.resetCost[1].amount)
				end


				local info = {}
				info.text = hintStr
				info.type = "yes_no"
				info.align = "center"
				info.mask = true
				info.onYes = function()
					--配点确定
					printTable(5, "配点重置")
					ModelManager.CardLibModel:heroAttrPointPlanReset(self._curType, self.heroInfo.uuid)	
				end
				Alert.show(info)           
			end
		)
	end


	self.btn_autoSet:addClickListener(
        function(context)
			self:autoSetPoint()
        end
    )
	self.btn_switchComfirm:addClickListener(
        function(context)
			local time = self.heroInfo.changePointNum or 0
			time = time + 1
			if time > 3 then time = 3 end
			local switchCost = DynamicConfigData.t_HeroSwitchPointCost[time].cost --{type = CodeType.MONEY, code = GameDef.MoneyType.Gold, amount = self._switchGold[time]}
			if not ModelManager.PlayerModel:isCostEnough(switchCost) then
				self:setToType(self._curType)
				return
			end
				
			local hintStr = Desc.card_matchPointGold1
			if #switchCost > 0 and switchCost[1].amount > 0 then
				hintStr = string.format(Desc.card_matchPointGold2, switchCost[1].amount, Desc["common_moneyType"..switchCost[1].code])
			end
			
			local info = {}
			info.text = hintStr
			info.type = "yes_no"
			info.align = "center"
			info.mask = true
			info.onYes = function()
				--配点确定
				printTable(5, "配点切换")
				ModelManager.CardLibModel:switchMatchPoint(self.heroInfo.uuid, self._curType)
			end
			Alert.show(info) 
        end
    )
	
	
end

function MatchPointBoard:setToType(type)
	self._curType = type
	self.view:getController("type"):setSelectedIndex(type - 1)
end

function MatchPointBoard:doSwitchType(type)
	if self._openVip[type] > ModelManager.VipModel.level then
		RollTips.show(string.format(Desc.card_matchPointVip, self._openVip[type]))
		self:setToType(self._curType)
		return
	end
	
	self._curType = type
	self.allotLists[self._curType] = {0,0,0,0,0,0} 
	self:setCardMatPoint()
end

function MatchPointBoard:cardView_matchPointSwitch(event, data)
	if self.heroInfo and data.uuid == self.heroInfo.uuid then
		self:setToType(data.type)
	end
end

--推荐加点
function MatchPointBoard:autoSetPoint()
	local freeNum = self.heroInfo.attrPointPlanNew[self.heroInfo.attrPointId].attrPointNum
	self.allotLists[self._curType] = {0,0,0,0,0,0} 
	local recompoint = self.heroInfo.heroDataConfiger.recompoint
	while freeNum > 0 do
		for i,v in ipairs(recompoint) do
			local addNum = freeNum > v and v or freeNum
			self.allotLists[self._curType][i] = self.allotLists[self._curType][i] + addNum
			freeNum = freeNum - addNum
			if freeNum == 0 then 
				break
			end
		end
	end
	self:setCardMatPoint()

    
    --是否有剩余的技能分配点
    self.freePoint:setText(0)
end

function MatchPointBoard:_refresh()
    self:setDetailsById()
end


function MatchPointBoard:cardView_updateInfo(_, data)
    self:setDetailsById()
end

--[[function MatchPointBoard:cardView_levelUpSuc(_, data)
    printTable(5, "卡牌升级请求返回yfyf", data)
    if data then
        self:cardLevelAndStep(data.hero)
    end
end--]]



--设置卡牌(英雄)详情
function MatchPointBoard:setDetailsById()
    local HeroInfo = ModelManager.CardLibModel.curCardStepInfo
    if not HeroInfo then
        return
    end
	self.heroInfo = HeroInfo
    self.heroId = HeroInfo.heroId
	self._curType = HeroInfo.attrPointId
	self.allotLists = {{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0}}
	self:setToType(self._curType)
    self:updateHeroInfo()
end

function MatchPointBoard:setData(data)
    local HeroInfo = data
    ModelManager.CardLibModel.curCardStepInfo=HeroInfo
    if not HeroInfo then
        return
    end
	self.heroInfo = HeroInfo
    self.heroId = HeroInfo.heroId
	self._curType = HeroInfo.attrPointId
	self.allotLists = {{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0}}
	self:setToType(self._curType)
    self:updateHeroInfo()
end

--更新卡牌详情信息
function MatchPointBoard:updateHeroInfo()
	for let, key in pairs(self.heroInfo.attrs) do
		if key.id<=6 then
			self.allotLists[1][key.id] = 0 --已经分配的点数列表
			self.allotLists[2][key.id] = 0 --已经分配的点数列表
			self.allotLists[3][key.id] = 0 --已经分配的点数列表
		end
	end
	
    self:setCardMatPoint()

    
    --是否有剩余的技能分配点
    self.freePoint:setText(self.heroInfo.attrPointPlanNew[self.heroInfo.attrPointId].attrPointNum)
	
end



function MatchPointBoard:setCardMatPoint()
	
	self.freePoint:setText(self.heroInfo.attrPointPlanNew[self._curType].attrPointNum)	
    local attrList = self.heroInfo.attrs
    local attrs={}
    for key, value in pairs(attrList) do
        if value.id <=6 then
            attrs[value.id]=value
        end
    end
	--self.allotLists[self._curType] = {0,0,0,0,0,0}
	--[[local plan = self.heroInfo.attrPointPlanNew[self._curType]
	for i, v in pairs(plan.points) do
        self.allotLists[self._curType][v.type] = v.num
    end--]]
	
    printTable(8, "yfyfyfyf>>>>>>>>>>>", attrs)
    local serverAddPoint = self.heroInfo.attrPointPlanNew[self._curType].points
    local attrPointAdd = DynamicConfigData.t_heroAttrPoint
	
	--self._curType = self.heroInfo.attrPointId
	--self.view:getController("type"):setSelectedIndex(self._curType - 1)
	
	local resetTimes = self.heroInfo.attrPointPlanNew[self._curType].resetPointTimes and self.heroInfo.attrPointPlanNew[self._curType].resetPointTimes or 0
	local len = #DynamicConfigData.t_HeroResetPointCost
	if resetTimes + 1 < len then
		self.resetCost = DynamicConfigData.t_HeroResetPointCost[resetTimes + 1].cost
	else
		self.resetCost = DynamicConfigData.t_HeroResetPointCost[len].cost
	end
	
	if self.resetPoint then
		if #self.resetCost == 0 then
			self.resetPoint:setData(nil)
		else
			self.resetPoint:setData(self.resetCost[1])
		end
	end
	
	self.view:getController("c1"):setSelectedIndex(self._curType == self.heroInfo.attrPointId and 0 or 1)
    self.editorList:setItemRenderer(
        function(index, obj)
            obj:removeClickListener()
            --池子里面原来的事件注销掉
            local attrName = obj:getChildAutoType("txt_attrName")
            local curAttr = obj:getChildAutoType("txt_curAttr")
            local addAttr = obj:getChildAutoType("txt_addAttr")
            local addpoint = obj:getChildAutoType("addpoint")
            local subpoint = obj:getChildAutoType("subpoint")
            local add10 = obj:getChildAutoType("btn_add10")
            local sub10 = obj:getChildAutoType("btn_sub10")
            local txt_num = obj:getChildAutoType("addValue")
            local maxBtn = obj:getChildAutoType("btn_max")
            local img = obj:getChildAutoType("n11")
			local severAdd = 0
			local value = attrs[index + 1]
            if serverAddPoint[value.id] then
                severAdd = serverAddPoint[value.id].num
            end
			
			local addValue = BindManager.bindTextInput(txt_num)
			local addNum = 0
			addValue:onInputEnd(
				function()
					local content = addValue:getText()
					if not StringUtil.isdigit(content) then content = "1" end
					local num = tonumber(content)
					local maxNum = self.heroInfo.attrPointPlanNew[self.heroInfo.attrPointId].attrPointNum - self:getCurAddPointNum() + self.allotLists[self._curType][value.id]
					
					if num >= maxNum then
						addNum = maxNum
					elseif num < 0 then
						addNum = 0
					else
						addNum = num
					end
					
					local remaining = addNum - self.allotLists[self._curType][value.id] - severAdd
					addValue:setText(addNum)
					self:allotProperty(value.id, remaining)
				end
			)
	
            
            attrName:setText(ModelManager.CardLibModel.cardAttrName[value.id])
            local addNum = (self.allotLists[self._curType][value.id]) * attrPointAdd[self.heroInfo.heroDataConfiger.pointId][value.id].attrValue
            curAttr:setText(value.value)
            if addNum > 0 then
                img:setVisible(true)
                addAttr:setText(math.floor(value.value + addNum))
                addAttr:setColor(cc.c3b(0x6a, 0xff, 0x60))
            else
                --img:setVisible(false)
                addAttr:setText("0")
                addAttr:setColor(cc.c3b(255, 255, 255))
            end
            
            addValue:setText((self.allotLists[self._curType][value.id] + severAdd))
            if self.allotLists[self._curType][value.id] + severAdd > 0 then
            	addValue:setColor(cc.c3b(0x6a, 0xff, 0x60))
            else
            	addValue:setColor(cc.c3b(255, 255, 255))
            end
            self:setbtnGrey(addpoint, 2, value.id)
            if (add10) then
                self:setbtnGrey(add10, 2, value.id)
                add10:removeClickListener()
            end
            
            self:setbtnGrey(subpoint, 1, value.id)
            if (sub10) then
                self:setbtnGrey(sub10, 1, value.id)
                sub10:removeClickListener()
            end
            addpoint:removeClickListener()
            subpoint:removeClickListener()
            maxBtn:removeClickListener()
            local remaining = self.heroInfo.attrPointPlanNew[self.heroInfo.attrPointId].attrPointNum - self:getCurAddPointNum()
            maxBtn:addClickListener(
                function(context)
					if self.view:getController("c1"):getSelectedIndex() == 1 then
						RollTips.show(Desc.card_matchPointFirst)
						return
					end
                    self:allotProperty(value.id, remaining)
                    addValue:setText(string.format("%s", self.allotLists[self._curType][value.id] + severAdd))
                end
            )
            addpoint:addClickListener(
                function(context)
					if self.view:getController("c1"):getSelectedIndex() == 1 then
						RollTips.show(Desc.card_matchPointFirst)
						return
					end
					
                    if self.heroInfo.attrPointPlanNew[self.heroInfo.attrPointId].attrPointNum == self:getCurAddPointNum() then
                        RollTips.show(Desc.card_DetailsStr3)
                    else
                        self:allotProperty(value.id, 1)
                        addValue:setText(string.format("%s", self.allotLists[self._curType][value.id] + severAdd))
                    end
                end
            )
            subpoint:addClickListener(
                function(context)
					if self.view:getController("c1"):getSelectedIndex() == 1 then
						RollTips.show(Desc.card_matchPointFirst)
						return
					end
					
                    if self.allotLists[self._curType][value.id] == 0 and severAdd == 0 then
                        RollTips.show(Desc.card_DetailsStr4)
                    elseif self.allotLists[self._curType][value.id] == 0 and severAdd > 0 then
                        RollTips.show(Desc.card_DetailsStr5)
                    else
                        self:allotProperty(value.id, -1)
                        addValue:setText(string.format("%s", self.allotLists[self._curType][value.id] + severAdd))
                    end
                end
            )
            if (add10) then
                add10:addClickListener(function ()
                    if self.view:getController("c1"):getSelectedIndex() == 1 then
                        RollTips.show(Desc.card_matchPointFirst)
                        return
                    end
                    
                    if self.heroInfo.attrPointPlanNew[self.heroInfo.attrPointId].attrPointNum == self:getCurAddPointNum() then
                        RollTips.show(Desc.card_DetailsStr3)
                    else
                        local add = math.min(remaining, 10)
                        self:allotProperty(value.id, add)
                        addValue:setText(string.format("%s", self.allotLists[self._curType][value.id] + severAdd))
                    end
                end)
            end

            if (sub10) then
                sub10:addClickListener(function ()
                    if self.view:getController("c1"):getSelectedIndex() == 1 then
                        RollTips.show(Desc.card_matchPointFirst)
                        return
                    end
    
                    if self.allotLists[self._curType][value.id] == 0 and severAdd == 0 then
                        RollTips.show(Desc.card_DetailsStr4)
                    elseif self.allotLists[self._curType][value.id] == 0 and severAdd > 0 then
                        RollTips.show(Desc.card_DetailsStr5)
                    else
                        local sub = -math.min(self.allotLists[self._curType][value.id], 10)
                        self:allotProperty(value.id, sub)
                        addValue:setText(string.format("%s", self.allotLists[self._curType][value.id] + severAdd))
                    end
                end)
            end
        end
    )
    self.editorList:setNumItems(#attrs)
end

function MatchPointBoard:setbtnGrey(obj, btnType, index)
    local isGrey = false
    if btnType == 1 and self.allotLists[self._curType][index] == 0 then
        isGrey = true
    end
    if btnType == 2 and self.heroInfo.attrPointPlanNew[self.heroInfo.attrPointId].attrPointNum == self:getCurAddPointNum() then
        isGrey = true
    end
    if obj == nil then
    else
        obj:setGrayed(isGrey)
    end
end

function MatchPointBoard:getCurAddPointNum()
    local addNum = 0
    for k, value in pairs(self.allotLists[self._curType]) do
        addNum = addNum + value
    end
    return addNum
end

function MatchPointBoard:cardView_configurationPoint(_, data)
    printTable(5, "卡牌配点返回", data)
    if data then
        
		if not tolua.isnull(self.freePoint) then
			
			self._curType = data.hero.attrPointId
			self:setCardMatPoint(data.hero)
		end
    end
end

function MatchPointBoard:cardView_starUpSuc(_, data)
    if data then
        printTable(5, "卡牌升星请求返回yfyf22", data)
       self:setDetailsById()
    end
end


function MatchPointBoard:cardView_CardAddAndDeleInfo(_, data)
    printTable(8, "卡牌属性更新")
   self:setDetailsById()
end


--设置属性分配吗面板
function MatchPointBoard:allotProperty(index, value)
    local leftPoint = self.heroInfo.attrPointPlanNew[self.heroInfo.attrPointId].attrPointNum
    if value > 0 and leftPoint > 0 and leftPoint > self:getCurAddPointNum() then
        self.allotLists[self._curType][index] = self.allotLists[self._curType][index] + value
        local remaining = self.heroInfo.attrPointPlanNew[self.heroInfo.attrPointId].attrPointNum - self:getCurAddPointNum()
        self.freePoint:setText(remaining)
    end
    if value < 0 and self.allotLists[self._curType][index] > 0 then
        self.allotLists[self._curType][index] = self.allotLists[self._curType][index] + value
        local remaining = self.heroInfo.attrPointPlanNew[self.heroInfo.attrPointId].attrPointNum - self:getCurAddPointNum()
        self.freePoint:setText(remaining)
    end
    local attrs = self.heroInfo.attrs
    self.editorList:setNumItems(#attrs)
end

--[[function MatchPointBoard:_exit()
    --ModelManager.CardLibModel:clearupStarInfo()
    if self.annimation then
        for k, value in pairs(self.annimation) do
            Scheduler.unschedule(value)
        end
    end
end
--]]
--[[function MatchPointBoard:_enter()
end--]]

return MatchPointBoard
