---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by:  资源找回界面
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local RetrieveView, Super = class("RetrieveView", Window)
local lastInterTime = 0.1
local maxInterTime = 0.5
function RetrieveView:ctor()
    self._packName = "Retrieve"
    self._compName = "RetrieveView"
    self.list_task = false
    self.btn_onekey = false
    self.agglutinationBind = false
    self.costType = 0 --默认为金币
    self.servserInfo = {}
    self.scheduler = {}
	self.needEffect = true
end

function RetrieveView:_refresh(  )
    --TaskModel:setAniFlagIndex( 5,false)
	for k,v in pairs(self.scheduler) do
		if self.scheduler[k] then
			Scheduler.unschedule(self.scheduler[k])
	        self.scheduler[k] = false
		end
	end
	self:RetrieveView_refreshPanal()
end

function RetrieveView:_initUI()
    local viewRoot = self.view
    self.list_task = viewRoot:getChildAutoType("list_task")
    self.btn_onekey = viewRoot:getChildAutoType("btn_onekey")
    if self.btn_onekey then
        self.agglutinationBind = BindManager.bindCostButton(self.btn_onekey)
    end
    self.gCtr1 = viewRoot:getController("c1")
    self.costType = 0
    self.gCtr1:setSelectedIndex(0)
    self.gCtr2 = viewRoot:getController("c2")
    local has = RetrieveModel:getRetrueveState()
    if has == true then
        --有奖励
        self.gCtr2:setSelectedIndex(0)
    else
        self.gCtr2:setSelectedIndex(1)
    end
    RetrieveModel:setLoginState()
    RetrieveModel:upRetrieveRed()
    self:showList()
    self:showOneykeyBtn()
end

function RetrieveView:showOneykeyBtn()
    local oneKeyInfo = RetrieveModel:getRetruveAllCost(self.costType)
    if self.agglutinationBind then
        if next(oneKeyInfo) ~= nil then
            self.btn_onekey:setVisible(true)
            self.agglutinationBind:setData(oneKeyInfo[1])
            self.agglutinationBind:setCostCtrl(1)
            
        else
            self.btn_onekey:setVisible(false)
            self.agglutinationBind:setData({type = 2, code = self.costType + 1, amount = 0})
        end
    end
end

function RetrieveView:showList()
    self.servserInfo = RetrieveModel:getRetrieveInfo()
    local temp = {}
    for key, value in pairs(self.servserInfo) do
        if #value.ids > 0 then
            value["getRewardIdex"] = 0
        else
            value["getRewardIdex"] = 1
        end
        temp[#temp + 1] = value
    end
    TableUtil.sortByMap(temp, {{key = "getRewardIdex", asc = false}, {key = "type", asc = false}})
    local configType = DynamicConfigData.t_Retrieve

    self.list_task:addEventListener(FUIEventType.Scroll,function ( ... )
		--TaskModel:setAniFlagIndex(5,true)
		self.needEffect = false
	end)
    self.list_task:setItemRenderer(
        function(index, obj)
            local serVerInfo = temp[index + 1]
            local txt_name = obj:getChildAutoType("txt_name")
            if configType[serVerInfo.type] then
                txt_name:setText(configType[serVerInfo.type][1].name)
            else
                txt_name:setText("")
            end
            local rerwardNum = #serVerInfo.ids
            local txt_desc = obj:getChildAutoType("txt_desc")
            local vipCount = rerwardNum - serVerInfo.normalTimes
            if vipCount <= 0 then
                vipCount = 0
            end
            txt_desc:setText(
                string.format(
                    DescAuto[231], -- [231]="(可找回%s次,VIP%s额外+%s次)"
                    ColorUtil.formatColorString1(rerwardNum, "#119717"),
                    serVerInfo.vipLv,
                    ColorUtil.formatColorString1(vipCount, "#119717")
                )
            )
            local rewardList = obj:getChildAutoType("$list_prop")
            local reward = RetrieveModel:getRetrueveReward(serVerInfo.ids, self.costType) --当前的奖励
            if rerwardNum == 0 then
                reward = RetrieveModel:LastgetRetrueveReward(serVerInfo.type, self.costType) --当前的奖励
            end
            rewardList:setItemRenderer(
                function(index, itemCell)
                    index = index + 1
                    itemCell = BindManager.bindItemCell(itemCell)
                    local data = reward[index]
                    itemCell:setData(data.code, data.amount, data.type)
                    if rerwardNum==0 then
                        itemCell:setIsHook(true)
                    else
                        itemCell:setIsHook(false)
                    end
                end
            )
            local c1 = obj:getController("c1")
            if rerwardNum > 0 then
                c1:setSelectedIndex(0)
                local allCost = RetrieveModel:getRetruveCost(serVerInfo.ids, self.costType) --当前的消耗
                local costItem = obj:getChildAutoType("costItem")
                local bindCost = BindManager.bindCostItem(costItem)
                bindCost:setData(allCost[1].type, allCost[1].code, allCost[1].amount, true, false)
            else
                c1:setSelectedIndex(1)
            end
            rewardList:setNumItems(#reward)
            local btn_zhaohui = obj:getChildAutoType("btn_zhaohui")
            btn_zhaohui:removeClickListener(100) --池子里面原来的事件注销掉
            btn_zhaohui:addClickListener(
                function(context)
                    ViewManager.open("RetrieveChooseView", {taskType = serVerInfo.type, costType = self.costType})
                end,
                100
            )

            local interTime = 0.1
			if self.needEffect then
				obj:setVisible(false)
				local tempIndex = index+1-self.list_task:getFirstChildInView()
				self.scheduler[tempIndex] = Scheduler.scheduleOnce(tempIndex*interTime, function( ... )
					if obj and  (not tolua.isnull(obj)) then
						obj:setVisible(true)
						obj:getTransition("t0"):play(function( ... )
						end);
					end
				end)
			end
        end
    )
    self.list_task:setNumItems(#temp)
	self.needEffect = false
end

function RetrieveView:_initEvent(...)
    local btnHelp = self.view:getChildAutoType("btn_help")
    btnHelp:removeClickListener() --池子里面原来的事件注销掉
    btnHelp:addClickListener(
        function()
            local info = {}
            info["title"] = Desc.help_StrTitle184
            info["desc"] = Desc.help_StrDesc184
            ViewManager.open("GetPublicHelpView", info)
        end
    )

    local btn_zuanshi = self.view:getChildAutoType("btn_zuanshi") --钻石
    btn_zuanshi:addClickListener(
        function()
            TaskModel:setAniFlagIndex( 5,true)
            self.costType = 1
            self:showList()
            self:showOneykeyBtn()
        end
    )
    local btn_jingbi = self.view:getChildAutoType("btn_jingbi")
    --金币
    btn_jingbi:addClickListener(
        function()
            TaskModel:setAniFlagIndex( 5,true)
            self.costType = 0
            self:showList()
            self:showOneykeyBtn()
        end
    )

    local btn_onekey = self.view:getChildAutoType("btn_onekey")
    btn_onekey:addClickListener(
        function()
            local costType = false
            local costIcon = 1
            if self.costType == 0 then
                costType = true
                costIcon = 1
            else
                costType = false
                costIcon = 2
            end
            RetrieveModel:LastsetOnekeyRetrueveReward(self.costType) --一键扫荡前端显示
            local oneKeyInfo = RetrieveModel:getRetruveAllCost(self.costType)
            local info = {}
            info.text =
                string.format(
                DescAuto[234], -- [234]="确认花费%s%s一键找回所有奖励吗"
                GMethodUtil.getRichTextMoneyImgStr(costIcon),
                MathUtil.toSectionStr(oneKeyInfo[1].amount)
            )
            info.title = DescAuto[235] -- [235]="资源找回"
            info.yesText = Desc.materialCopy_str3
            info.noText = Desc.materialCopy_str4
            info.okText = "okText"
            info.noClose = "yes"
            info.type = "yes_no"
            info.mask = true
            info.onYes = function()
                print(5, "onYes")
                local isEnough =
                    PlayerModel:checkCostEnough(
                    {type = oneKeyInfo[1].type, code = oneKeyInfo[1].code, amount = oneKeyInfo[1].amount},
                    true
                )
                if isEnough then
                    RetrieveModel:OneKeyRetrieveItem(costType)
                end
            end
            Alert.show(info)
        end
    )
end

function RetrieveView:RetrieveView_refreshPanal() --领取完后刷新
    local has = RetrieveModel:getRetrueveState()
    if has == true then --有奖励
        self.gCtr2:setSelectedIndex(0)
    else
        self.gCtr2:setSelectedIndex(1)
    end
    self:showList()
    self:showOneykeyBtn()
end

function RetrieveView:_enter()
end

function RetrieveView:_exit(...)
    for k,v in pairs(self.scheduler) do
		if self.scheduler[k] then
			Scheduler.unschedule(self.scheduler[k])
	        self.scheduler[k] = false
		end
	end
end

return RetrieveView
