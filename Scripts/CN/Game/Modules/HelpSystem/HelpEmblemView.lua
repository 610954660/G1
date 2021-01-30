-- 帮助系统 纹章帮助
-- added by xhd

local EmblemCell = require "Game.Modules.Emblem.EmblemCell";
local HelpEmblemView, Super = class("HelpEmblemView", Window)

function HelpEmblemView:ctor()
    self._packName = "HelpSystem"
    self._compName = "HelpEmblemView"

end

function HelpEmblemView:_initUI() -- 推荐阵容
   self.detail = self.view:getChildAutoType("detail")
   self.wzList = self.view:getChildAutoType("wzList")
   self.heroList = self.view:getChildAutoType("heroList")
   self.list_suit = self.view:getChildAutoType("list_suit")
   self.list_suit:setItemRenderer(function (idx, obj)
    local txt = self.list_suit._dataTemplate[idx + 1]
    obj:getChildAutoType("desc"):setText(txt);
end)
   self.detail:setText(Desc.help_StrDesc151)
end

function HelpEmblemView:initPanel( ... )
    self.wzList:setSelectedIndex(0)
    local config = DynamicConfigData.t_EmblemSuit
    self:updateRightPanel(config[1])
end

--UI初始化
function HelpEmblemView:_initEvent(...)
    self.wzList:setItemRenderer(function(idx, obj)
        local txt_name = obj:getChildAutoType("txt_name")
        local list_suit = obj:getChildAutoType("list_suit")
        local emblemCell = obj:getChildAutoType("emblemCell")
        local emblemCellObj = BindManager.bindEmblemCell(emblemCell)
        local config  = DynamicConfigData.t_EmblemSuit[idx+1]
        local emConf = DynamicConfigData.t_Emblem;
        local tcode = 111
        for _, conf in pairs(emConf) do
            if conf.suitId == config.suitId and conf.rank ==6 then
                tcode = conf.code
                break
            end
        end 
        local d = {
            code = tcode
        }
        emblemCellObj:setData(d)
        txt_name:setText(config.suitName)
        local arr = {}
        table.insert( arr,config.suitTag2 )
        table.insert( arr,config.suitTag4 )
        list_suit:setItemRenderer(function(idx2, obj2)
           local desc = obj2:getChildAutoType("desc")
           desc:setText(arr[idx2+1])
        end)
        list_suit:setData(arr)

        obj:removeClickListener(88)
        obj:addClickListener(function()
            self:updateRightPanel(config)
        end,88)
    end)

    self.heroList:setItemRenderer(function (idx2, obj2)
        local heroID = self.heroList._dataTemplate[idx2+1]
        local heroConfig = DynamicConfigData.t_hero[heroID]
        local cardItem = obj2
        local bindCard = BindManager.bindCardCell(cardItem)
        bindCard:setData(heroID, true)
        bindCard:setLevel(-1)
        cardItem:removeClickListener()
        cardItem:addClickListener(function()
            local conf = DynamicConfigData.t_HeroTotems
            local arr = conf[heroConfig.category]
            local h = false
            for _, d in pairs(arr) do
                if (d.hero == heroID) then
                    h = d
                    break
                end
            end
            local info = {index = 1,heroId = heroID, heroList = {h}};
            ViewManager.open("HeroInfoView", info);
        end)
    end)
    local config = DynamicConfigData.t_EmblemSuit
    self.wzList:setNumItems(#config)
    self:initPanel()
end


function HelpEmblemView:getSuggestSuit(suitId)
    local emConf = DynamicConfigData.t_Emblem;
    local config = {}
    for i=1, 4 do
        for _, conf in pairs(emConf) do
            if conf.suitId == suitId then
                if conf.rank ==6 and conf.pos == i then
                    table.insert(config,conf)
                end
            end
         end 
    end
    return config
end

function HelpEmblemView:updateRightPanel(config)
    local suitId = config.suitId
    local fourConfig = self:getSuggestSuit(suitId)
    -- printTable(1,fourConfig)
    for i = 1, 4 do
        local item = self.view:getChildAutoType("emblemPanel/emblem"..i);
        if (not item.cell) then
            item.cell = EmblemCell.new(item);
        end
        local ctrl = item:getController("c2");
        ctrl:setSelectedIndex(1)
        item.cell:showFrame(false)
        item.cell:setStarType(1)
        local defaultInfo = {
            code =fourConfig[i].code,
            pos = i,
            color = 1
        }
        item.cell:setData(defaultInfo);
        item.cell:setGrayed(false);
        item.cell:setDefaultBg(i);
    end

    local conf = DynamicConfigData.t_EmblemSuit[suitId];
    local suitArr = {}
    local txt = string.format("%d件套：%s",2,conf.suitDes2)
    table.insert( suitArr,txt)
    local txt = string.format("%d件套：%s",4,conf.suitDes4)
    table.insert( suitArr,txt)
    self.list_suit:setData(suitArr)
    self.heroList:setData(config.RecommendedHero)
end

return HelpEmblemView
