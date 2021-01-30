local PveStarTempleGrid  = class("PveStarTempleGrid")

function PveStarTempleGrid:ctor(params)
    self.view = params.obj
    self.index = params.index
    self.areaIndex = params.areaIndex
    self.data = false
    self.win = false
    self.layer = false
    self.isBoss = params.isBoss
    self.isFinalBoss = params.isBoss and params.areaIndex == 5
    self.questionList = false
    self.questionIndex = false
    self.hasAnswerQuestion = false
    self.skeletonNode = false
    self.nextFloorEff = false
end

function PveStarTempleGrid:init()
    self.bossName = self.view:getChildAutoType("bossName")
    self.nextFloor = self.view:getChildAutoType("nextFloor")
    self.eventIcon = self.view:getChildAutoType("eventIcon")
    self.model = self.view:getChildAutoType("model")
    self.isBossCtrl = self.view:getController("isBoss")
    self.hasEventCtrl = self.view:getController("hasEvent")
    self.isWinCtrl = self.view:getController("isWin")
    if self.isFinalBoss then
        self.model:setScale(1.1,1.1)
    else
        self.model:setScale(0.9,0.9)
    end

    self.eventIcon:setScale(0.6,0.6)
    self.view:addClickListener(function()
        self:onClick()
    end,1)
	
	Dispatcher.addEventListener(EventType.PveStarTemple_HandleArea,self)
end

function PveStarTempleGrid:clear()
    self.view = false
    self.index = false
    self.areaIndex = false
    self.data = false
    self.win = false
    self.layer = false
    self.isBoss = false
    self.isFinalBoss = false
    self.questionList = false
    self.questionIndex = false
    self.hasAnswerQuestion = false

    if self.skeletonNode then
        SpineUtil.relaseSpine(self.skeletonNode)
        self.skeletonNode = false
    end

    if self.nextFloorEff then
        SpineUtil.clearEffect(self.nextFloorEff)
        self.nextFloorEff = false
    end
	Dispatcher.removeEventListener(EventType.PveStarTemple_HandleArea,self)
end

function PveStarTempleGrid:updateData(data,win,layer)
    self.data = data or {}
    self.win = win
    self.layer = layer
    self.isBossCtrl:setSelectedIndex(self.isBoss and 1 or 0)
    self.hasEventCtrl:setSelectedIndex((data ~= nil and win and data.flag ~= 1) and 1 or 0)
    self.isWinCtrl:setSelectedIndex(win == true and 1 or 0)
    if self.areaIndex==5 then
		printTable(086,data,"data")
	end
	self.model:setTouchable(false)
    if not win then
        if self.isBoss then
            self.bossName:setText("")
            self:createSpine()
        end

        if self.nextFloorEff then
            SpineUtil.clearEffect(self.nextFloorEff)
            self.nextFloorEff = false
        end
        return
    else
        if self.skeletonNode then
            SpineUtil.relaseSpine(self.skeletonNode)
            self.skeletonNode = false
        end

        if self.isFinalBoss and not self.nextFloorEff then
            local eff = SpineMnange.createByPath("Spine/ui/pveStarTemple","xingchenshengsuo_texiao","xingchenshengsuo_texiao")
            self.nextFloor:displayObject():addChild(eff)
            eff:setAnimation(0,"animation",true)
            eff:setPosition(0.5,0.5)
            self.nextFloorEff = eff
            --self.bossName:setText("下一层")
        end
    end

    if not data then
        self.questionList = false
        self.questionIndex = false
        self.hasAnswerQuestion = false
        if self.skeletonNode then
            SpineUtil.relaseSpine(self.skeletonNode)
            self.skeletonNode = false
        end
        return
    end

    if data.flag ~= 1 and not (self.win and self.isFinalBoss) then
        print(999,"读表",self.data.eventType,self.data.eventId,self.data.onlyId)

        local config = ModelManager.PveStarTempleModel:getEventConfig(self.data.eventType,self.data.eventId,self.data.onlyId)
        self.eventIcon:setURL(PathConfiger.getStarTempleEventIcon(config.icon))
    end

    if self.data.eventType == ModelManager.PveStarTempleModel.PveStarTemple.Answer then
        self:handleEvent4()
    elseif self.data.eventType == ModelManager.PveStarTempleModel.PveStarTemple.Mall then
        self:handleEvent6()
    elseif self.data.eventType == ModelManager.PveStarTempleModel.PveStarTemple.Event then
        self:handleEvent7()
    end
end

function PveStarTempleGrid:createSpine()
    if not self.skeletonNode then
        local fightID = DynamicConfigData.t_PveStarTemplePartConfig[self.layer][self.areaIndex].monster
        local fightData = DynamicConfigData.t_fight[fightID]
        local monsterId = fightData["monsterId"..fightData.monsterStand[1]]
        local skeletonNode = SpineMnange.createSprineById(monsterId,false,1)
        self.model:displayObject():addChild(skeletonNode)
        skeletonNode:setAnimation(0, "stand", true)
        skeletonNode:setPosition(80,20)
        self.skeletonNode = skeletonNode
		self.model:setTouchable(true)
		--self.model:setHeight(300)
    end
end

function PveStarTempleGrid:onClick()
    if not self.win then
        if self.isFinalBoss or self.areaIndex==5 then
            if ModelManager.PveStarTempleModel:getRemainBossCount() > 1 then
                RollTips.show(DescAuto[202]) -- [202]="先打败其他boss才可以挑战层主"
                return
            end
        end
        if self.isBoss then
            self:handleBoss()
        else
            --RollTips.show("击败Boss后可探索该区域")	
			--if self.areaIndex==5 then
				
			--end
			
			Dispatcher.dispatchEvent(EventType.PveStarTemple_HandleArea,{index=self.index,areaIndex=self.areaIndex})
        end
        return
    elseif self.isFinalBoss  then--下一层
		if PveStarTempleModel:todayShowAler() then
			if PveStarTempleModel:checkAreaReward() then
				local info = {
					check=true,
					text=DescAuto[203], -- [203]="还有未拾取的道具,进入下一层后将不能拾取"
					type="yes_no",
					onYes= function(isSelect)
						PveStarTempleModel:saveTodayAlerConfig(isSelect)
						Dispatcher.dispatchEvent(EventType.PveStarTemple_NextLayer)
					end,
					onNo= function(isSelect)
						local nowData= TimeLib.getDay()
						PveStarTempleModel:saveTodayAlerConfig(isSelect)
					end,
				}
				Alert.show(info)
				return
			end
		end
		print(086,"今天已经勾选了不弹提示")
        Dispatcher.dispatchEvent(EventType.PveStarTemple_NextLayer)
        return
    end

    if self.data ~= nil and self.data.eventType ~= nil and self.data.flag ~= 1 then
        self["event"..self.data.eventType](self)
    end
end

function PveStarTempleGrid:PveStarTemple_HandleArea(_,params)
	--if  self.areaIndex ==5 and  self.index == params.index and  ModelManager.PveStarTempleModel:getRemainBossCount() > 1 then
		--RollTips.show("先打败其他boss才可以挑战层主")
		--return
	--end
	if self.areaIndex == params.areaIndex and self.isBoss then
		self:handleBoss()
	end
end


function PveStarTempleGrid:event1()--事件类型1
    if self.data.eventId == 5001 then
        ViewManager.open("PveStarTempleLockBoxView",{areaID = self.areaIndex,pos = self.index})
        return
    end

    Dispatcher.dispatchEvent(EventType.PveStarTemple_EevntUse,{areaID = self.areaIndex,pos = self.index})
end

function PveStarTempleGrid:event2()--事件类型2
    Dispatcher.dispatchEvent(EventType.PveStarTemple_EevntUse,{areaID = self.areaIndex,pos = self.index})
end

function PveStarTempleGrid:event3()--事件类型3
    Dispatcher.dispatchEvent(EventType.PveStarTemple_EevntUse,{areaID = self.areaIndex,pos = self.index})
end

function PveStarTempleGrid:event4()--事件类型4
    ModelManager.PveStarTempleModel:setCurrQuestionIndex(self.questionIndex)
    ModelManager.PveStarTempleModel:setCurrQuestionList(self.questionList)

    if not self.hasAnswerQuestion and self.questionIndex <= 1 then
        self.hasAnswerQuestion = true
        ViewManager.open("PveStarTempleStartAnswerView",{areaID = self.areaIndex,pos = self.index})
    else
        ViewManager.open("PveStarTempleAnswerView",{areaID = self.areaIndex,pos = self.index})
    end
end

function PveStarTempleGrid:event5()--事件类型5
	local config = ModelManager.PveStarTempleModel:getEventConfig(self.data.eventType,self.data.eventId,self.data.onlyId)
    if config.icon == 501 then--神秘人
        ViewManager.open("PveStarTempleManView",{eventID = self.data.onlyId,areaID = self.areaIndex,pos = self.index})
    elseif config.icon == 502 then--旧物队
        ViewManager.open("PveStartTempleSundriesView",{eventID = self.data.onlyId,areaID = self.areaIndex,pos = self.index})
    elseif config.icon == 503 then--对话
        ViewManager.open("PveStarTempleNpcView",{eventID = self.data.onlyId,areaID = self.areaIndex,pos = self.index})
    end
end

function PveStarTempleGrid:event6()--事件类型6
    ModelManager.PveStarTempleModel:setMysteryShop(self.data.mall)
    ViewManager.open("PveStarTempleMysteryStoreView",{isMap = true,areaID = self.areaIndex,pos = self.index})
end

function PveStarTempleGrid:event7()--事件类型7
    ViewManager.open("PveStarTempleCardView",{areaID = self.areaIndex,pos = self.index})
end

function PveStarTempleGrid:handleBoss()
    local isAllHeroDead = ModelManager.PveStarTempleModel:isAllHeroDead()

    if isAllHeroDead then
        RollTips.show(DescAuto[204]) -- [204]="已没有可以战斗的探员了"
        return
    end

    ViewManager.open("PveStarTempleFightView",{areaID = self.areaIndex})
end

function PveStarTempleGrid:handleAuto()
    local isAuto = ModelManager.PveStarTempleModel:getAuto()
    if not isAuto then
        return nil
    end

    if not self.data or self.data.flag == 1 or self.isFinalBoss then
        return nil
    end

    local config = ModelManager.PveStarTempleModel:getEventConfig(self.data.eventType,self.data.eventId)
    if not config then
        return nil
    end

    if config.autoGet and config.autoGet == 1 then
        return {areaId = self.areaIndex,pos = self.index}
    end

    return nil
end

--处理答题数据
function PveStarTempleGrid:handleEvent4()
    self.questionList = {}
    self.questionIndex = 1
    for k,v in pairs(self.data.Question) do
        table.insert(self.questionList,v)
    end

    table.sort(self.questionList,function(a,b)
        return a.QuestionId < b.QuestionId
    end)

    for i,v in ipairs(self.questionList) do
        if v.correct == 0 then
            self.questionIndex = i
            break
        end
    end
end

--处理商店数据
function PveStarTempleGrid:handleEvent6()
    ModelManager.PveStarTempleModel:addExploreShop(self.data.mall)
end

function PveStarTempleGrid:handleEvent7()
    if not self.data.onlyId or self.data.onlyId == 0 then
        return
    end

    local selectOnlyID = ModelManager.PveStarTempleModel:getCurrEventOnlyID()
    if not selectOnlyID or selectOnlyID  == 0 then
        return
    end

    local myCard = ModelManager.PveStarTempleModel:getEventConfig(self.data.eventType,nil,selectOnlyID).policyType
    --local targetCard = ModelManager.PveStarTempleModel:getEventConfig(self.data.eventType,nil,self.data.onlyId).policyType
    local result = self:cardResult(myCard,self.data.onlyId)

    print(999,"对策结果",myCard,self.data.onlyId)
    ModelManager.PveStarTempleModel:setCurrEventOnlyID(false)
    ViewManager.open("PveStarTempleCardResultView",{myCard = myCard - 1,targetCard = self.data.onlyId - 1,result = result})
end

function PveStarTempleGrid:cardResult(bet,result)
    --1火,2木,3水
    --0赢，1平，2输
    local resultDic = {
        [1] = {[1] = 1,[2] = 0,[3] = 2},
        [2] = {[1] = 2,[2] = 1,[3] = 0},
        [3] = {[1] = 0,[2] = 2,[3] = 1,}
    }

    return resultDic[bet][result]
end

return PveStarTempleGrid
