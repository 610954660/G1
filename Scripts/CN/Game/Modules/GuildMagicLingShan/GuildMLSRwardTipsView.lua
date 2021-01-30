-- added by wyz
-- 公会 魔灵山 挑战界面奖励预览

local GuildMLSRwardTipsView = class("GuildMLSRwardTipsView",Window)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器

function GuildMLSRwardTipsView:ctor()
    self._packName = "GuildMagicLingShan"
    self._compName = "GuildMLSRwardTipsView"
    self._rootDepth = LayerDepth.PopWindow

    self.txt_title  = false     -- 标题
    self.txt_dec    = false     -- 描述
    self.list_rewardInfo = false    -- 奖励列表
    self.bossLv     = false     -- boss等级

end

function GuildMLSRwardTipsView:_initUI()
    self.txt_title  = self.view:getChildAutoType("txt_title")
    self.txt_dec    = self.view:getChildAutoType("txt_dec")
    self.list_rewardInfo = self.view:getChildAutoType("list_rewardInfo")

    self.bossLv = self._args.bossLv
end


function GuildMLSRwardTipsView:_initEvent()
    self:GuildMLSRwardTips_refreshPanal()
end

function GuildMLSRwardTipsView:GuildMLSRwardTips_refreshPanal()
    local rankRewardInfo = ModelManager.GuildMLSModel:getRankRewardInfoByLv(self.bossLv)
    -- printTable(8848,">>>rankRewardInfo>>>",rankRewardInfo)
    self.txt_title:setText(string.format(Desc.GuildMLSMain_levelRewardTitle,self.bossLv))
    self.txt_dec:setText(Desc.GuildMLSMain_levelRewardDec)
    self.list_rewardInfo:setItemRenderer(function(idx,obj)
        local index = idx + 1
        local data = rankRewardInfo[index]
        local txt_rankNum = obj:getChildAutoType("txt_rankNum")
        local boxIconLoader = obj:getChildAutoType("boxIconLoader")
        local txt_boxNum    = obj:getChildAutoType("txt_boxNum")
        local min = data.min
        local max = data.max
        local url       = ItemConfiger.getItemIconByCode(10002026, CodeType.ITEM)
        boxIconLoader:setURL(url)

        if min == max then
            txt_rankNum:setText(string.format(Desc.GuildMLSMain_rewardRankNum1,min))
        elseif min < max then
            txt_rankNum:setText(string.format(Desc.GuildMLSMain_rewardRankNum2,min,max))
        else
            txt_rankNum:setText(string.format(Desc.GuildMLSMain_rewardRankNum3,min))
        end
        txt_boxNum:setText("X" .. data.num)

    end)
    self.list_rewardInfo:setData(rankRewardInfo)

end

return GuildMLSRwardTipsView