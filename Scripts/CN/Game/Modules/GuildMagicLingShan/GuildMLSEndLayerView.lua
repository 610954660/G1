-- added by wyz
-- 公会 魔灵山 结算界面

local GuildMLSEndLayerView = class("GuildMLSEndLayerView",Window)

function GuildMLSEndLayerView:ctor()
    self._packName = "GuildMagicLingShan"
    self._compName = "GuildMLSEndLayerView"

    self.txt_resultTitle = false -- 本次结果标题
    self.txt_currentHurtTitle = false -- 本次伤害量
    self.txt_historyTitle   = false -- 历史贡献标题
    self.txt_totalHurtTitle = false -- 总伤害量
    self.txt_onceHurt       = false -- 单次最高
    self.txt_accTitle       = false -- 参加次数
    self.txt_currentRankTitle = false -- 当前排名
end

function GuildMLSEndLayerView:_initUI()
    self.txt_resultTitle = self.view:getChildAutoType("txt_resultTitle")
    self.txt_currentHurtTitle = self.view:getChildAutoType("txt_currentHurtTitle")
    self.txt_historyTitle = self.view:getChildAutoType("txt_historyTitle")
    self.txt_totalHurtTitle = self.view:getChildAutoType("txt_totalHurtTitle")
    self.txt_onceHurt = self.view:getChildAutoType("txt_onceHurt")
    self.txt_accTitle = self.view:getChildAutoType("txt_accTitle")
    self.txt_currentRankTitle = self.view:getChildAutoType("txt_currentRankTitle")
end

function GuildMLSEndLayerView:_initEvent()
    self:GuildMLSEndLayer_refreshPanal()
end

function GuildMLSEndLayerView:GuildMLSEndLayer_refreshPanal()
    local data = ModelManager.GuildMLSModel:gettleEndInfo()
    if not data then return end
    local reqInfo = {
        rankType = GameDef.RankType.EvilMountainBoss,
        collectionId = ModelManager.GuildMLSModel.rankBossId,
    }
    RPCReq.Rank_GetRankData(reqInfo,function(params)
        printTable(8848,">>>>>请求排行榜数据>>>>>",params)
        local rankData = params.rankData or {}
        local myRankData = params.myRankData or {}

        if tolua.isnull(self.view) then return end
        local inRank = false
        local myRank = false
        local myId = tonumber(ModelManager.PlayerModel.userid)
        for k,v in pairs(rankData) do
            if myId == v.id then
                inRank = true
                myRank = k
                break
            end
        end
        self.txt_currentRankTitle:setText(string.format(Desc.GuildMLSMain_currentRank,myRank))
    end)

    self.txt_resultTitle:setText(Desc.GuildMLSMain_resultTitle)
    self.txt_currentHurtTitle:setText(string.format(Desc.GuildMLSMain_currentHurt,data.damage))
    self.txt_historyTitle:setText(Desc.GuildMLSMain_historyTitle)
    self.txt_totalHurtTitle:setText(string.format(Desc.GuildMLSMain_totalHurt,data.totalDamage))
    self.txt_onceHurt:setText(string.format(Desc.GuildMLSMain_onceHurt,data.maxDamage))
    self.txt_accTitle:setText(string.format(Desc.GuildMLSMain_accTitle,data.count))
end


return GuildMLSEndLayerView