---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: 圣器副本
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local RelicCopyView, Super = class("RelicCopyView", Window)
function RelicCopyView:ctor()
    self._packName = "RelicCopy"
    self._compName = "RelicCopyView"
    --GList
    self.listcopy = false
    --卡牌阶级图片显示
    self.list_diffBg = false
    self.txtcopynum = false
    self.lihuiDisplay = false
    self.img_banner = false
    self.txt_copyName = false
    self.txt_bossName = false
    self.txt_bossDesc = false
    self.list_skill = false
    self.txt_vipDesc = false
    --GButton
    self.countDownTime = {} --顶部按钮倒计时
    self.curCopyType = 1
    self.scheduler = {}
    self.aniFlag = false
end

function RelicCopyView:_refresh(  )
	for k,v in pairs(self.scheduler) do
		if self.scheduler[k] then
			Scheduler.unschedule(self.scheduler[k])
	        self.scheduler[k] = false
		end
    end
    self.aniFlag = false
    self:HallowCopy_getInfoUpdate()
end


function RelicCopyView:_initUI()
    local viewRoot = self.view
    self.list_copy = viewRoot:getChild("list_copy")
    self.txtcopynum = viewRoot:getChild("txtcopynum")
    self.list_diffBg = viewRoot:getChild("list_diffBg")
    self.img_banner = viewRoot:getChild("$img_banner")
    self.txt_copyName = viewRoot:getChild("txt_copyName")
    self.txt_bossName = viewRoot:getChild("txt_bossName")
    self.txt_bossDesc = viewRoot:getChild("txt_bossDesc")
    self.list_skill = viewRoot:getChild("list_skill")
    self.txt_addcountTime = viewRoot:getChild("txt_addcountTime")
    self.txt_vipDesc = viewRoot:getChildAutoType("txt_vipDesc");
    RelicCopyModel:getCopy()
    self:showCopyList()
    self:showRemineText()
    self:HallowCopy_UpdatecuntDown()
	
	
end

function RelicCopyView:showRemineText()
    local remainTimes, maxTimes = RelicCopyModel:getRemainTumes()
    self.txtcopynum:setText(string.format("%s/%s", remainTimes, maxTimes))
end

function RelicCopyView:showCopyList()
    local configInfo = DynamicConfigData.t_HallowCopy
    local curSele=RelicCopyModel:getCurViewSeleIdexBtn()
    self.list_copy:setItemRenderer(
        function(index, obj)
            local copyType = index + 1
            local iconUrl = string.format("%s%s.png", "Icon/relicCopy/relicCopybtnIcon_", copyType)
            obj:setIcon(iconUrl)
            local isOpen = RelicCopyModel:getCurCopyIsOpen(copyType)
            if isOpen == true then
                self:showBtncountDowm(copyType, obj)
            else
                if self.countDownTime[copyType] then
                    TimeLib.clearCountDown(self.countDownTime[copyType])
                end
                local desc = Desc["Hallow_copydesc" .. copyType]
                obj:setTitle(desc)
            end
            obj:removeClickListener(100)
            --池子里面原来的事件注销掉
            obj:addClickListener(
                function(context)
                    -- self.aniFlag = false
                    self.curCopyType = copyType
                    self:showCopyBg(copyType)
                end,
                100
            )
            if index == curSele-1 then
                self.curCopyType = copyType
                self:showCopyBg(copyType)
            end
        end
    )
    self.list_copy:setNumItems(#configInfo)
    self.list_copy:setSelectedIndex(curSele-1)

    local conf = DynamicConfigData.t_Privilige[5];
    if (conf) then
        self.txt_vipDesc:setText(string.format(Desc.Hallow_copydesc12, conf.count1));
    end
    self.view:getChildAutoType("vip"):setVisible(not PriviligeGiftModel:getGiftStatusById(5))
end

function RelicCopyView:showBtncountDowm(copyType, obj)
    local textObj = obj:getChildAutoType("title")
    local weekDay = TimeLib.getWeekDay()
    local configTime = DynamicConfigData.t_HallowOpen[weekDay]
    if configTime then
        local allTime = configTime.endTime
        local day = allTime / 24
        local zero = ((day - 1) * 24 * 60 * 60)
        local lastTime = zero + TimeLib.getDayResidueSecond()
        if lastTime > 0 then
            textObj:setText(TimeLib.GetTimeFormatDay1(lastTime, 2))
            local function onCountDown(time)
                textObj:setText(TimeLib.GetTimeFormatDay1(time, 2))
            end
            local function onEnd(...)
            end
            if self.countDownTime[copyType] then
                TimeLib.clearCountDown(self.countDownTime[copyType])
            end
            self.countDownTime[copyType] = TimeLib.newCountDown(lastTime, onCountDown, onEnd, false, false, false)
        else
            if self.countDownTime[copyType] then
                TimeLib.clearCountDown(self.countDownTime[copyType])
            end
            local desc = Desc["Hallow_copydesc" .. copyType]
            textObj:setText(desc)
        end
    end
end

function RelicCopyView:showCopyBg(copyType)
    local copy, copyDiff = RelicCopyModel:getCurCopyDiff(copyType)
    --当前按钮困难度
    local configInfo = DynamicConfigData.t_HallowCopy[copy][copyDiff]
    if not configInfo then
        return
    end
    self.list_diffBg:addEventListener(FUIEventType.Scroll,function ( ... )
		self.aniFlag = true
	end)
    self.list_diffBg:setItemRenderer(
        function(index, obj) --池子里面原来的事件注销掉
            obj:removeClickListener()
            local configItem = configInfo[index + 1]
            local txt_level = obj:getChildAutoType("txt_level")
            txt_level:setText(configItem.level)
            local txt_isFirst = obj:getChildAutoType("txt_isFirst")
            local isFirst = RelicCopyModel:getCurDiffIsFirstPass(copyType, copyDiff, index + 1)
            local curReward = {}
            if isFirst == false then
                txt_isFirst:setVisible(true)
                curReward = configItem.fightReward
            else
                txt_isFirst:setVisible(false)
                curReward = configItem.mopUpReward
            end
            local listreward = obj:getChild("list_reward")
            listreward:setItemRenderer(
                function(index, obj)
                    local itemcell = BindManager.bindItemCell(obj)
                    local award = curReward[index + 1]
                    itemcell:setData(award.code, award.amount, award.type)
                end
            )
            listreward:setNumItems(#curReward)
            local txt_fight = obj:getChildAutoType("txt_fight")
            txt_fight:setText(StringUtil.transValue(configItem.combat))
            local txt_desc = obj:getChildAutoType("txt_desc")
            txt_desc:setText(configItem.conditionDesc)
            self:showBtnState(obj, copyType, copyDiff, index + 1)
            
            local interTime = 0.05
			if not self.aniFlag then
				obj:setVisible(false)
				local tempIndex = index+1-self.list_diffBg:getFirstChildInView()
				self.scheduler[tempIndex] = Scheduler.scheduleOnce(tempIndex*interTime, function( ... )
					if obj and  (not tolua.isnull(obj)) then
						obj:setVisible(true)
						obj:getTransition("t1"):play(function( ... )
						end);
					end
				end)
			end
        end
    )
    self.list_diffBg:setVirtual()
    self.list_diffBg:setNumItems(#configInfo)
    self.aniFlag = true
    self:showBossIcon(copyType)
end

function RelicCopyView:showBossIcon(copyType)
    local copy, copyDiff = RelicCopyModel:getCurCopyDiff(copyType)
    local configInfo = DynamicConfigData.t_HallowCopy
    local copyInfo = configInfo[copy][copyDiff][1]
    self.img_banner:setScale(0.5,0.5)
    self.lihuiDisplay = BindManager.bindLihuiDisplay(self.img_banner)
    self.lihuiDisplay:setData(copyInfo.bossId)
    self.txt_copyName:setText(copyInfo.copyName)
    self.txt_bossName:setText(copyInfo.bossName)
    local raceText = {DescAuto[224], DescAuto[225], DescAuto[226], DescAuto[227], DescAuto[228]} -- [224]="魔族" -- [225]="神族" -- [226]="械族" -- [227]="兽族" -- [228]="人族"
    local desc = ""
    local replaArr = raceText[copyType]
    desc = string.format("%s%s", replaArr,Desc.Hallow_copydesc6)
    self.txt_bossDesc:setText(desc)
    local skillArr = copyInfo.skill
    self.list_skill:setItemRenderer(
        function(index, obj)
            obj:removeClickListener(100)
            --池子里面原来的事件注销掉
            obj:addClickListener(
                function(context) --点击查看技能详情
                    ViewManager.open("ItemTips", {codeType = CodeType.SKILL, id = skillArr[index + 1]})
                end,
                100
            )
            local skillCell = BindManager.bindSkillCell(obj)
            skillCell:setData(skillArr[index + 1])
        end
    )
    self.list_skill:setNumItems((#skillArr))
end

function RelicCopyView:showBtnState(obj, copyType, diffId, point)
    local btnState = RelicCopyModel:getBtnState(copyType, diffId, point)
    local btnenter = obj:getChild("btn_enter")
    local btnsweep = obj:getChild("btn_sweep")
    local btn_sweepIcon = obj:getChild("btn_sweepIcon")
    local btngray = obj:getChild("btn_gray")
    local gCtr = obj:getController("c1")
    local txt_free = obj:getChildAutoType("txt_free")
    local _, _, freeTime = RelicCopyModel:getRemainTumes()
    txt_free:setVisible(freeTime > 0)
    txt_free:setText(string.format(Desc.Hallow_copydesc7, freeTime))
    if (freeTime > 0 and btnState == 3) then
        btnState = 2;
    end
    gCtr:setSelectedIndex(btnState)
    local sweepIconObj = BindManager.bindCostButton(btn_sweepIcon)
    sweepIconObj:setCostCtrl(1)
    local limitData = DynamicConfigData.t_HallowConst[1]
    sweepIconObj:setData(limitData.buyCost[1])
    btnenter:removeClickListener(100) --池子里面原来的事件注销掉
    btnsweep:removeClickListener(100) --池子里面原来的事件注销掉
    btn_sweepIcon:removeClickListener(100) --池子里面原来的事件注销掉
    btngray:removeClickListener(100) --池子里面原来的事件注销掉
    btngray:addClickListener(
        function(context)
            RollTips.show(DescAuto[229]) -- [229]="未开启"
        end,
        100
    )
    btnenter:addClickListener(
        function(context)
            local function battleHandler(eventName)
                if eventName == "begin" then
                    local copyId = RelicCopyModel:getIdByCopyType(copyType, diffId, point)
                    RelicCopyModel:enterCopy(copyId)
                elseif eventName == "end" then
                end
            end
            local copyConfig = DynamicConfigData.t_HallowCopy[copyType][diffId][point]
            local fightId = copyConfig.fightId
            local battleArr = GameDef.BattleArrayType.HallowFairy
            if copyType == 2 then
                battleArr = GameDef.BattleArrayType.HallowDemon
            elseif copyType == 3 then
                battleArr = GameDef.BattleArrayType.HallowOrcs
            elseif copyType == 4 then
                battleArr = GameDef.BattleArrayType.HallowHuman
            elseif copyType == 5 then
                battleArr = GameDef.BattleArrayType.HallowMachinery
            end
			RelicCopyModel.lastBattleArrayType = battleArr
            Dispatcher.dispatchEvent(
                EventType.battle_requestFunc,
                battleHandler,
                {fightID = fightId, configType = battleArr}
            )
        end,
        100
    )
    btnsweep:addClickListener(
        function(context)
            local copysweepId = RelicCopyModel:getIdByCopyType(copyType, diffId, point)
            local remainTimes, maxTimes = RelicCopyModel:getlimitTime()
            if remainTimes > 0 then
                RelicCopyModel:sweepCopy(copysweepId)
            else
                self:showBuyView(copysweepId)
            end
        end,
        100
    )
    btn_sweepIcon:addClickListener(
        function(context)
            local copysweepId = RelicCopyModel:getIdByCopyType(copyType, diffId, point)
            self:showBuyView(copysweepId)
        end,
        100
    )
end

function RelicCopyView:showBuyView(copysweepId)
    local _, _, _, boughtCount = RelicCopyModel:getRemainTumes()
    local privActive = PriviligeGiftModel:getGiftStatusById(5);
    local HallowConst = DynamicConfigData.t_HallowConst[1]
    local PrivGiftConf = DynamicConfigData.t_PriviligeGift[5]
    local PrivConf = DynamicConfigData.t_Privilige[5] --PrivGiftConf.type
    local info = {}
    local amount = HallowConst.buyCost[1].amount -- 购买消耗
    local baseBuy = HallowConst.maxBuyTimes - boughtCount
    if (privActive) then
        baseBuy = PrivConf.count2 + baseBuy
    end
    local leaveDay = math.ceil(PriviligeGiftModel:getGiftLeaveTime(5) / 86400)
    local txt  = privActive and string.format(Desc.Hallow_copydesc9, amount, baseBuy, leaveDay, PrivConf.count2) or string.format(Desc.Hallow_copydesc8, amount, baseBuy, PrivConf.count2);
    
    info.text = txt--string.format(Desc.materialCopy_str10, HallowConst.buyCost[1].amount)
    info.title = Desc.materialCopy_str11
    info.yesText = Desc.materialCopy_str3
    info.noText = Desc.materialCopy_str4
    info.okText = "okText"
    info.noClose = "yes"
    info.type = "yes_no"
    info.mask = true
    info.onClose = function()
        print(5, "noClose")
    end
    info.onYes = function()
        print(5, "onYes")
        local isEnough = PlayerModel:checkCostEnough(HallowConst.buyCost[1], false)
        if baseBuy == 0 then
            RollTips.show(Desc.Hallow_copydesc10);
        elseif isEnough then
            RelicCopyModel:sweepCopy(copysweepId)
        else
            RollTips.show(Desc.Hallow_copydesc11);
        end
    end
    info.onNo = function()
        print(5, "onNo")
    end
    Alert.show(info)
end

function RelicCopyView:_initEvent(...)
    local btnHelp = self.view:getChildAutoType("btn_help")
    btnHelp:removeClickListener() --池子里面原来的事件注销掉
    btnHelp:addClickListener(
        function()
            local info = {}
            info["title"] = Desc.help_StrTitle153
            info["desc"] = Desc.help_StrDesc153
            ViewManager.open("GetPublicHelpView", info)
        end
    )

    local btn_rank = self.view:getChildAutoType("btn_rank")
    btn_rank:addClickListener(
        function()
            ViewManager.open("RelicCopyRankView", {type = GameDef.RankType.Hallow})
        end
    ) 

	local btn_hallow = self.view:getChildAutoType("btn_hallow")
    btn_hallow:addClickListener(
        function()
			--[[if ModelManager.HallowSysModel.baseSeatLv > 0 then
				ViewManager.open("HallowUpView");
			else
				ViewManager.open("HallowBaseSeatView")
			end--]]
			ModuleUtil.openModule(ModuleId.PriviligeGiftView.id)
        end
    )
end

function RelicCopyView:HallowCopy_battleEndUpdate() --挑战完后刷新
    self:showRemineText()
    self:showCopyBg(self.curCopyType)
end

function RelicCopyView:serverTime_crossDay(...) --跨天
    RelicCopyModel:getCopy()
    self:showCopyList()
    self:showRemineText()
end

function RelicCopyView:HallowCopy_getInfoUpdate() 
    self:showCopyList()
    self:showRemineText()
end

function RelicCopyView:PriviligeGift_upGiftData()
    RelicCopyModel:getCopy()
end


function RelicCopyView:HallowCopy_UpdatecuntDown(...) --倒计时
    local time = RelicCopyModel:getCountDowm()
    local remainTimes, maxTimes = RelicCopyModel:getRemainTumes()
    if time >=0  and remainTimes<maxTimes then
        if not tolua.isnull(self.txt_addcountTime) then
            self.txt_addcountTime:setVisible(true)
            self.txt_addcountTime:setText(string.format(DescAuto[230], TimeLib.formatTime(time, true, false))) -- [230]="(%s后恢复1次挑战次数)"
        end
    else
        self:showCopyBg(self.curCopyType)
        self:showRemineText()
        self.txt_addcountTime:setVisible(false)
    end
end

function RelicCopyView:_enter()
end

function RelicCopyView:_exit(...)
    for k,v in pairs(self.scheduler) do
		if self.scheduler[k] then
			Scheduler.unschedule(self.scheduler[k])
	        self.scheduler[k] = false
		end
    end
    
    if self.countDownTime then
        for key, v in pairs(self.countDownTime) do
            TimeLib.clearCountDown(v)
        end
    end
end

return RelicCopyView
