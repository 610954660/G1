-- added by wyz
-- 公会 魔灵山 领取奖励界面

local GuildMLSTakeRewardView = class("GuildMLSTakeRewardView",Window)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器

function GuildMLSTakeRewardView:ctor()
    self._packName = "GuildMagicLingShan"
    self._compName = "GuildMLSTakeRewardView"
    self._rootDepth     = LayerDepth.PopWindow

    self.lihuiDisplay   = false 
    self.titleLoader    = false     
    self.txt_tips       = false     -- boss提示语
    self.txt_bossName   = false     -- boss名字和等级
    self.txt_closeTips  = false     -- 关闭界面提示语
    self.txt_myRank     = false     -- 我的排名
    self.txt_boxNum     = false     -- 箱子数量
    self.list_reward    = false     -- 奖励列表
    self.needEffect     = true      
    self.schedulerArr   = {}
    self.rewardData     = {}
    self.bossInfo       = {}
    self.myRank         = false
end

function GuildMLSTakeRewardView:_initUI()
    self.lihuiDisplay   = self.view:getChildAutoType("lihuiDisplay")
    self.titleLoader    = self.view:getChildAutoType("titleLoader")
    self.txt_tips       = self.view:getChildAutoType("txt_tips")
    self.txt_bossName   = self.view:getChildAutoType("txt_bossName")
    self.txt_closeTips  = self.view:getChildAutoType("txt_closeTips")
    self.txt_myRank     = self.view:getChildAutoType("txt_myRank")
    self.txt_boxNum     = self.view:getChildAutoType("txt_boxNum")
    self.list_reward    = self.view:getChildAutoType("list_reward")
end

function GuildMLSTakeRewardView:_initEvent()
    printTable(8848,">>>self._args>>",self._args)
    self.bossInfo = self._args.bossInfo
    self.myRank   = self._args.myRank
    ModelManager.GuildMLSModel:reqBossRewardInfo(self._args.id)
end

function GuildMLSTakeRewardView:GuildMLSTakeReward_refreshPanal()
    local bossCfgInfo = DynamicConfigData.t_EvilBossPara[self.bossInfo.confId]
    local monsterId = ModelManager.GuildMLSModel:getMonsterIdByBossId(self.bossInfo.confId)
    local modelId   = DynamicConfigData.t_monster[monsterId].model
    local checkFightCtrl = self.view:getController("checkFightCtrl")
    checkFightCtrl:setSelectedIndex(self.bossInfo.hp == 0 and 1 or 0)

    if self.myRank then
        self.txt_myRank:setText(string.format(Desc.GuildMLSMain_myRank,self.myRank))
    else
        self.txt_myRank:setText(Desc.GuildMLSMain_nomyRank)
    end
    -- local lihuiDisplay = BindManager.bindLihuiDisplay(self.lihuiDisplay)
    -- lihuiDisplay:setData(modelId)
    
    local bossIconLoader = self.view:getChildAutoType("bossIconLoader")
    local size = bossCfgInfo.size
    bossIconLoader:setScale(size,size)
    if bossIconLoader then
        bossIconLoader:displayObject():removeAllChildren()
    end
    SpineUtil.createModel(bossIconLoader, {x = 0, y =0}, "stand", modelId,true)

    self.txt_bossName:setText(bossCfgInfo.name .. "  " .. "LV." .. bossCfgInfo.difficulty)

    self.rewardData = self._args.rewardData
    local boxNum = 0
    self.list_reward:setItemRenderer(function(idx,obj)
        local index = idx + 1
        local item = obj:getChildAutoType("item")
        local data = self.rewardData[index]
        local checkOpenCtrl = item:getController("checkOpenCtrl")     -- 0没打开 1打开了
        local txt_title = item:getChildAutoType("txt_title")
        local boxIconLoader = item:getChildAutoType("boxIconLoader")
        local btn_open  = item:getChildAutoType("btn_open")
        local txt_num   = item:getChildAutoType("txt_num")
        local code = false
        local _itemData =  ItemsUtil.createItemData({data = {code = data.code, type = data.type}})
        if data.boxType ~= 0 then
            code = data.boxType
            -- boxNum = boxNum + 1
        else
            code = _itemData:getItemInfo().icon
        end
        local url       ="Icon/item/"..code..".png"
        boxIconLoader:setURL(url)
        checkOpenCtrl:setSelectedIndex(data.boxType == 0 and 1 or 0)
        txt_num:setText("x" .. data.amount)
        txt_title:setText(Desc["GuildMLSMain_rewardTitle"..data.rewardType])

        -- txt_title:setText(index)
        if self.needEffect then
            local effectLoader  = obj:getChildAutoType("effectLoader")
            local spine = false
            local interTime = 0.35 --0.05 * TableUtil.GetTableLen(self.rewardData)
            item:setVisible(false)
            self.schedulerArr[index] = Scheduler.scheduleOnce(index*interTime, function( ... )
                if item and  (not tolua.isnull(item)) then
                    local x1 = effectLoader:getWidth() / 2;
                    local y1 = effectLoader:getHeight() / 2;
                    spine = SpineUtil.createSpineObj(effectLoader, cc.p(x1, y1), "lingqu_texiao", "Effect/UI", "molingshan_texiao", "molingshan_texiao",false);
                    item:setVisible(true)
                    if data.boxType ~= 0 then
                        boxNum = boxNum + 1
                    end
                    self.txt_boxNum:setText(string.format(Desc.GuildMLSMain_boxNum,boxNum))
                    self.list_reward:scrollToView(index,false,false)
                    item:getTransition("t0"):play(function( ... )
                        effectLoader:displayObject():removeAllChildren()
                        spine = false
                    end);
                end
            end)
        end

        btn_open:removeClickListener(11)
        btn_open:addClickListener(function()
            local effectLoader  = obj:getChildAutoType("effectLoader")
            checkOpenCtrl:setSelectedIndex(1)
            url       = ItemConfiger.getItemIconByCode(_itemData:getItemInfo().code, CodeType.ITEM)
            boxIconLoader:setURL(url)
            item:getTransition("t0"):play(function( ... )

            end);
            local x1 = effectLoader:getWidth() / 2;
            local y1 = effectLoader:getHeight() / 2;
            local spine = SpineUtil.createSpineObj(effectLoader, cc.p(x1, y1), "lingqu_texiao", "Effect/UI", "molingshan_texiao", "molingshan_texiao",false);
            local scheduleOnce =  Scheduler.scheduleOnce(1, function()
                effectLoader:displayObject():removeAllChildren()
                spine = false
            end)
            Scheduler.unschedule(scheduleOnce)
        end,11)
    end)
    self.list_reward:setData(self.rewardData)
    self.needEffect = false
end

function GuildMLSTakeRewardView:_exit()
    for i,v in ipairs(self.schedulerArr) do
		if self.schedulerArr[i] then
        	Scheduler.unschedule(self.schedulerArr[i])
        	self.schedulerArr[i] = false
        end
    end
    if TableUtil.GetTableLen(ModelManager.GuildMLSModel.bossRewardInfo) > 0 then
        RollTips.showReward(ModelManager.GuildMLSModel.bossRewardInfo)
    end
    ModelManager.GuildMLSModel:reqSingleBossInfo(self._args.id)
    ModelManager.GuildMLSModel:reqBossListInfo()

end

return GuildMLSTakeRewardView