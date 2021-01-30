--Name : CooperationActivitieLimitView.lua
--Author : generated by FairyGUI
--Date : 2020-5-29
--Desc : 限时商城

local CooperationActivitieLimitView, Super = class("CooperationActivitieLimitView", Window)
local ItemCell = require "Game.UI.Global.ItemCell"
function CooperationActivitieLimitView:ctor()
    --LuaLog("CooperationActivitieLimitView ctor")
    self._packName = "CooperationActivities"
    self._compName = "CooperationActivitieLimitView"
	--self._rootDepth = LayerDepth.Window
	self.activeTag = GameDef.ActivityType.WorkTogetherShop
    self.activeInfo = {}
    self.rewardInfo = {}
    self.activityEnable = false
end

function CooperationActivitieLimitView:_initEvent()
end

function CooperationActivitieLimitView:_initVM()
    local vmRoot = self
    local viewNode = self.view
    ---Do not modify following code--------
    --{vmFields}:OperatingActivities.CooperationActivitieLimitView
    vmRoot.txt_countdowm = viewNode:getChildAutoType("$txt_countdowm")
    --list
    vmRoot.List_reward = viewNode:getChildAutoType("$list_reward")
    --text
    --{vmFieldsEnd}:OperatingActivities.CooperationActivitieLimitView
    --Do not modify above code-------------
end

function CooperationActivitieLimitView:_initUI()
    self:_initVM()
    self.activeInfo = ModelManager.ActivityModel:getActityByType(self.activeTag)
    self:showActiveTime()
    self:showRewardList()
end

function CooperationActivitieLimitView:showRewardList()
    if self.activeInfo then
        self.rewardInfo = CooperationActivitiesModel:getLimitedShopinfo(self.activeTag)
        self.List_reward:setVirtual()
        self.List_reward:setItemRenderer(
            function(index, obj)
                local itemMode = self.rewardInfo[index + 1]
                local gCtr1 = obj:getController("c1")
                local lingqu = self:getLingquState(itemMode.id, itemMode.buyLimit)
                if lingqu == true then
                    gCtr1:setSelectedIndex(1)
                else
                    gCtr1:setSelectedIndex(0)
				end
				local btn_zuanshi = obj:getChildAutoType("btn_zuanshi")	 
				local gCtr2 = obj:getController("c2")
				if itemMode.buyType==1 then--钻石
					gCtr2:setSelectedIndex(0)
					local agglutinationBind = BindManager.bindCostButton(btn_zuanshi)
					agglutinationBind:setData({type=2,code=1,amount=itemMode.price})
					agglutinationBind:setCostCtrl(2)
				else--rmb
					gCtr2:setSelectedIndex(1)
				end
                local btn = obj:getChildAutoType("btn_ordinary")
                btn:setTitle(itemMode.price .. Desc.activity_txt7)
                local txt_desc = obj:getChildAutoType("txt_desc")
                txt_desc:setText(itemMode.price .. Desc.activity_txt11)
                if itemMode.price==0 and lingqu==false then
                    local btn_imgred= btn:getChildAutoType("img_red")
                    btn_imgred:setVisible(true)
                else
                    local btn_imgred= btn:getChildAutoType("img_red")
                    btn_imgred:setVisible(false)
                end
                local count = self:getLingquCount(itemMode.id)
                local txt_xiangou = obj:getChildAutoType("txt_xiangou")
                txt_xiangou:setText(Desc.activity_txt12 .. (itemMode.buyLimit - count))
                local itemReward = itemMode.reward
                local list_reward = obj:getChildAutoType("list_reward")
                list_reward:setItemRenderer(
                    function(itemIdex, rewardObj)
                        --池子里面原来的事件注销掉
                        local itemcell1 = BindManager.bindItemCell(rewardObj)
                        local award = itemReward[itemIdex + 1]
                        itemcell1:setData(award.code, award.amount, award.type)
                    end
                )
                list_reward:setNumItems(#itemReward)
                local btn_ordinary = obj:getChildAutoType("btn_ordinary")
                btn_ordinary:removeClickListener(100)
                btn_ordinary:addClickListener(
                    function(context)
                        if self.activityEnable then
                            RollTips.show(Desc.activity_txt13)
                            return
                        end
                        if itemMode.price == 0 then
							CooperationActivitiesModel:WorkTogetherLimitTimeBuy(self.activeTag, itemMode.id)
                        else
                            ModelManager.RechargeModel:directBuy(
                                itemMode.price,
                                GameDef.StatFuncType.SFT_WorkTogether,
                                itemMode.id,
								itemMode.dec,
								nil,
								itemMode.showName1
                            )
                        end
                    end,
                    100
                )
            end
        )
        self.List_reward:setNumItems(#self.rewardInfo)
    end
end

function CooperationActivitieLimitView:getLingquState(id, time)
    local lingqu = false
	local goumaiMap= CooperationActivitiesModel:getStoreGoodsLingquList(self.activeTag)
	if goumaiMap and goumaiMap[id]  and goumaiMap[id].num>=time then
		lingqu = true    --已售罄
	end
    return lingqu
end

function CooperationActivitieLimitView:getLingquCount(id)
    local count = 0
    local lingquList = CooperationActivitiesModel:getStoreGoodsLingquList(self.activeTag)
    if not lingquList then
        return count
    end
    if lingquList[id] then
        count = lingquList[id].num
    end
    return count
end

function CooperationActivitieLimitView:showActiveTime()
    local actData = self.activeInfo
    if not actData then
        return
    end
    local actId = actData.id
    local status, addtime = ModelManager.ActivityModel:getActStatusAndLastTime(actId)
    if not addtime then
        return
    end
    if status == 2 and addtime == -1 then
        self.txt_countdowm:setText(Desc.activity_txt5)
    else
        local lastTime = addtime / 1000
        if lastTime == -1 then
            self.txt_countdowm:setText(Desc.activity_txt5)
        else
            if lastTime > 0 then
                self.txt_countdowm:setText(TimeLib.GetTimeFormatDay(lastTime, 2))
                local function onCountDown(time)
                    self.txt_countdowm:setText(TimeLib.GetTimeFormatDay(time, 2))
                end
                local function onEnd(...)
                    self.activityEnable = true
                    self.txt_countdowm:setText(Desc.activity_txt4)
                end
                if self.calltimer then
                    TimeLib.clearCountDown(self.calltimer)
                end
                self.calltimer = TimeLib.newCountDown(lastTime, onCountDown, onEnd, false, false, false)
            else
                self.txt_countdowm:setText(Desc.activity_txt4)
            end
        end
    end
end


--事件初始化
function CooperationActivitieLimitView:CooperationActivitie_Holpprefresh(...)
    self.activeInfo = ModelManager.ActivityModel:getActityByType(self.activeTag)
    if not self.activeInfo then
        return
    end
    self:showActiveTime()
	self.rewardInfo = CooperationActivitiesModel:getLimitedShopinfo(self.activeTag)
    self.List_reward:setNumItems(#self.rewardInfo)
end

function CooperationActivitieLimitView:_exit(...)
    if self.calltimer then
        TimeLib.clearCountDown(self.calltimer)
    end
end

return CooperationActivitieLimitView
