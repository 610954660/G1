local GuildBossEndLayerView, Super = class("GuildBossEndLayerView", Window)
local ItemCell = require "Game.UI.Global.ItemCell"

function GuildBossEndLayerView:ctor()
    self._packName = "Guild"
    self._compName = "GuildBossEndLayerView"

    self._rootDepth = LayerDepth.Window
    self.txt_limitcount = false
    self.pg_exp = false
    self.img_box = false
    self.list_reward = false
    self.com_moveItem = false
    self.img_reward=false
 
    self.curBoxIdex = 1
    self.updateTimeId = false
    self.com_moveItemPos = false
    self.animationState = false
end

function GuildBossEndLayerView:_initUI()
 
    self.txt_limitcount = self.view:getChildAutoType("txt_limitcount")
    self.pg_exp = self.view:getChildAutoType("pg_exp")
    self.img_box = self.view:getChildAutoType("img_box")
    self.img_reward = self.view:getChildAutoType("img_reward")
    self.list_reward = self.view:getChildAutoType("list_reward"):getChildAutoType("list_reward1")
    self.com_moveItem = self.view:getChildAutoType("com_moveItem")
    self:initInfo()
end

function GuildBossEndLayerView:initInfo()
    self.curBoxIdex = 1
   local info= self._args.data;
    local reward = info.reward
    local rewardList = {}
    --EquipmentModel:addDecompose(rewardList,reward)
    rewardList = CardLibModel:getReward1(reward, 1)
    local amount = 0
    for k, v in pairs(rewardList) do
        if v.type == 2 and v.code == 5 then
            amount = v.amount
        end
    end
    table.sort(
        rewardList,
        function(a, b)
            if a.type == b.type then
                if a.type == 2 then
                    return a.code < b.code
                else
                    return a.code < b.code
                end
            else
                return a.code < b.code
            end
        end
    )
    local configInfo = DynamicConfigData.t_bossReward
    local configData = configInfo[info.gamePlayType]
    self:initList(rewardList)
    printTable(11, ">>>>>>>", amount, configData, info.giftBoxNum, info.damage, rewardList)
    self:updateView(amount, configData, info.giftBoxNum, info.damage, rewardList)
end

function GuildBossEndLayerView:initList(reward)
    self.list_reward:setItemRenderer(
        function(index, obj)
            local itemcell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"))
            local award =reward[index + 1]
            itemcell:setData(award.code, award.amount, award.type)
            itemcell:setFrameVisible(false)
            obj:addClickListener(function( ... )
            	itemcell:onClickCell()
			end)
            if index <= 1 then
                obj:setVisible(true)
            else
                obj:setVisible(false)
			end
        end
    )
    self.list_reward:setNumItems(#reward)
    self.com_moveItemPos = self.com_moveItem:getPosition()
    self.com_moveItem:setVisible(false)
    self.com_moveItem:setScale(0.1, 0.1)
end

function GuildBossEndLayerView:updateView(amount, configData, num, curhit, rewardList)
    self.img_reward:setURL(PathConfiger.getItemIcon(10002004))
    self.txt_limitcount:setText("X" .. (num-1))
    local textValue=self.pg_exp:getChildAutoType('txt_value')
    self.updateTimeId =
        Scheduler.schedule(
        function()
			--if self.animationState == false then
				self.animationState=true
                local dataInfo = configData[self.curBoxIdex]
                self.pg_exp:setMin(dataInfo.damageMin)
                local maxValue=0
                if dataInfo.damageMax==-1 then
                    local last=configData[self.curBoxIdex-1]
                    self.pg_exp:setMax(last.damageMax)
                    maxValue=last.damageMax
                else
                    self.pg_exp:setMax(dataInfo.damageMax)
                    maxValue=dataInfo.damageMax
                end
                self:showItem(rewardList)
                --self:showItemMove(rewardList)
				self.img_box:setURL(PathConfiger.getItemIcon(dataInfo.rewardIcon))
				if self.curBoxIdex < num then
					printTable(9, ">>>>>>>打印的位置1231",self.curBoxIdex)
                    self.pg_exp:tweenValue(dataInfo.damageMax, 0.5)
                    textValue:setText(dataInfo.damageMax..'/'..dataInfo.damageMax)
				elseif self.curBoxIdex == num then
					printTable(9, ">>>>>>>打印的位置123132?",self.curBoxIdex)
                    self.pg_exp:tweenValue(curhit, 0.5)
                    textValue:setText(curhit..'/'..maxValue)
                    Scheduler.unschedule(self.updateTimeId)
                end
				self.curBoxIdex = self.curBoxIdex + 1
           --end
        end,
        0.5
    )
end

function GuildBossEndLayerView:showItem(rewardList)
    printTable(9, ">>>>>>>",self.curBoxIdex + 2)
    local rewardItem = rewardList[self.curBoxIdex + 2]
    if rewardItem then
        local btn0 = self.list_reward:getChildAt(self.curBoxIdex+1)
        btn0:setVisible(true)
    end
end

function GuildBossEndLayerView:showItemMove(rewardList)
    local rewardItem = rewardList[self.curBoxIdex + 2]
    if rewardItem then
        self.com_moveItem:setVisible(false)
        self.com_moveItem:setScale(0.1, 0.1)
        local itemcell = BindManager.bindItemCell(self.com_moveItem)
        local award =rewardItem
        itemcell:setData(award.code, award.amount, award.type)
		local btn0 = self.list_reward:getChildAt(self.curBoxIdex-1)
        local point = btn0:localToGlobal(btn0:getPosition())
        printTable(9, ">>>>>>>打印的位置", point.x, point.y,self.curBoxIdex)
        local pointx = self.com_moveItem:getPosition().x
        local pointy = self.com_moveItem:getPosition().y
        local a1 =
            fgui.GTween:to({x = pointx, y = pointy, z = 0.1, w = 0.1}, {x = point.x, y = point.y, z = 0.8, w = 0.8}, 1)
        a1:onUpdate(
            function(tweener)
                self.com_moveItem:setPosition(tweener:getDeltaValue():getVec2().x, tweener:getDeltaValue():getVec2().y)
                --self.com_moveItem:setScale(0.8, 0.8)
            end
        )
        a1:onComplete(
			function()
				self.animationState = false
                self.com_moveItem:setPosition(self.com_moveItemPos.x, self.com_moveItemPos.y)
                self.com_moveItem:setVisible(false)
                self.com_moveItem:setScale(0.1, 0.1)
                btn0:setVisible(true)
            end
        )
    end
end

function GuildBossEndLayerView:_initEvent(...)
end

function GuildBossEndLayerView:_exit()
	if self.updateTimeId then
		Scheduler.unschedule(self.updateTimeId)
    end
end

return GuildBossEndLayerView
