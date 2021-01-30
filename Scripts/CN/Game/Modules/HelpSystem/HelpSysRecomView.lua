-- 帮助系统 (我要变强)
-- added by zn

local StrongItem = require "Game.Modules.HelpSystem.StrongItem"
local HelpSysRecomView, Super = class("HelpSysRecomView", Window)

function HelpSysRecomView:ctor()
    self._packName = "HelpSystem"
    self._compName = "HelpSysRecomView"
    -- 推荐阵容
    self.list_recomTeam = false
end

function HelpSysRecomView:_initUI() -- 推荐阵容
    self.c1 = self.view:getController("c1")
    self.channel1 = self.view:getChild("channel1")
    self.channel2 = self.view:getChild("channel2")
    self.channel3 = self.view:getChild("channel3")
    self.list_herorace = self.view:getChild("list_herorace")
    self.list_school = self.view:getChild("list_school")
    self.com_herorace = self.view:getChild("com_herorace")
    self.com_recomTeam = self.view:getChild("com_recomTeam")
    self.c1:setSelectedIndex(0)
    self.list_herorace:regUnscrollItemClick(
        --种族阵容
        function(index, obj)
            local type = index + 1
            local configInfo = DynamicConfigData.t_HelpHeroRecommend[type]
            self:showHeroRaceView(configInfo)
        end
    )
    self.list_herorace:setSelectedIndex(0)
    local type = 1
    local configInfo = DynamicConfigData.t_HelpHeroRecommend[type]
    self:showHeroRaceView(configInfo)

    local configInfo2=DynamicConfigData.t_HelpHeroRecommend2
    self.list_school:setItemRenderer(
        function(idx, item)
            local type = idx + 1
            item:setTitle(configInfo2[type].typeName)
            item:removeClickListener(100)
            item:addClickListener(
                function()
                    local configInfo = DynamicConfigData.t_HelpHeroRecommend2[type]
                    self:showRecomTeam(configInfo)
                end,100
            )
        end
    )
    self.list_school:setNumItems(#configInfo2)
end

function HelpSysRecomView:showHeroRaceView(configInfo)
    local cardId = configInfo.hero
    local heroConfig = DynamicConfigData.t_hero[cardId]
    -- self.imgCategory:setURL(PathConfiger.getCardCategory(heroConfig.category))--放了卡牌图片
    local imgProfessional = self.com_herorace:getChild("img_professional")
    imgProfessional:setURL(PathConfiger.getCardProfessionalWhite(heroConfig.professional))
    local txt_name = self.com_herorace:getChild("txt_name")
    txt_name:setText(heroConfig.heroName)
    local txt_zhiye = self.com_herorace:getChild("txt_zhiye")
    txt_zhiye:setText(heroConfig.protext)
    local cardItem = self.com_herorace:getChild("cardItem")
    local bindCard = BindManager.bindCardCell(cardItem)
    bindCard:setData(cardId, true)
    bindCard:setLevel(-1)
    cardItem:removeClickListener()
    cardItem:addClickListener(function()
        local conf = DynamicConfigData.t_HeroTotems
        local arr = conf[heroConfig.category]
        local h = false
        for _, d in pairs(arr) do
            if (d.hero == cardId) then
                h = d
                break
            end
        end
        local info = {index = 1,heroId = cardId, heroList = {h}};
        ViewManager.open("HeroInfoView", info);
    end)

    local skills = configInfo.skill
    local list_skill = self.com_herorace:getChild("list_skill")
    list_skill:setItemRenderer(
        function(idx, item)
            local skillId = skills[idx + 1]
            local skillInfo = DynamicConfigData.t_skill[skillId]
            if (not item.skill) then
                item.skill = BindManager.bindSkillCell(item)
            end
            item.skill:setData(skillId)
            item:removeClickListener(100)
            item:addClickListener(
                function()
                    ViewManager.open(
                        "ItemTips",
                        {codeType = CodeType.SKILL, id = skillId, data = skillInfo, heroId = cardId}
                    )
                end,100
            )
        end
    )
    list_skill:setNumItems(#skills)
    local txt_desc = self.com_herorace:getChild("txt_desc")
    txt_desc:setText( DynamicConfigData.t_HelpDesc[configInfo.desc].desc)
    local txt_match = self.com_herorace:getChild("txt_match")
    local list_match = self.com_herorace:getChild("list_match")
    local hero = configInfo.herolist
    list_match:setItemRenderer(
        function(idx, obj)
            local heroListId = hero[idx + 1]
            local bindListCard = BindManager.bindCardCell(obj:getChild("cardItem"))
            bindListCard:setData(heroListId, true)
            bindListCard:setLevel(-1)
            obj:removeClickListener(88)
            obj:addClickListener(
                function(...)
                    local descId = configInfo.desclist[idx + 1]
                    local str = DynamicConfigData.t_HelpDesc[descId].desc
                    txt_match:setText(str)
                end,
                88
            )
            if idx == 0 then
                local descId = configInfo.desclist[idx + 1]
                local str = DynamicConfigData.t_HelpDesc[descId].desc
                txt_match:setText(str)
                obj:setSelected(true)
            else
                obj:setSelected(false)
            end
        end
    )
    list_match:setNumItems(#hero)
end

function HelpSysRecomView:showRecomTeam(configInfo)
    for i = 1, 2, 1 do
        local cardId = configInfo["hero" .. i]
        local heroConfig = DynamicConfigData.t_hero[cardId]
        local txt_zhiye = self.com_recomTeam:getChild("txt_zhiye" .. i)
        txt_zhiye:setText(heroConfig.protext)
        local cardItem = self.com_recomTeam:getChild("cardItem" .. i)
        local bindCard = BindManager.bindCardCell(cardItem)
        bindCard:setData(cardId, true)
        bindCard:setLevel(-1)
        cardItem:removeClickListener()
        cardItem:addClickListener(function()
            local conf = DynamicConfigData.t_HeroTotems
            local arr = conf[heroConfig.category]
            local h = false
            for _, d in pairs(arr) do
                if (d.hero == cardId) then
                    h = d
                    break
                end
            end
            local info = {index = 1,heroId = cardId, heroList = {h}};
            ViewManager.open("HeroInfoView", info);
        end)
        local txt_name = self.com_recomTeam:getChild("txt_name" .. i)
        txt_name:setText(heroConfig.heroName)
        local skills = configInfo["skill" .. i]
        local list_skill = self.com_recomTeam:getChild("list_skill" .. i)
        list_skill:setItemRenderer(
            function(idx, item)
                local skillId = skills[idx + 1]
                local skillInfo = DynamicConfigData.t_skill[skillId]
                if (not item.skill) then
                    item.skill = BindManager.bindSkillCell(item)
                end
                item.skill:setData(skillId)
                item:removeClickListener(100)
                item:addClickListener(
                    function()
                        ViewManager.open(
                            "ItemTips",
                            {codeType = CodeType.SKILL, id = skillId, data = skillInfo, heroId = cardId}
                        )
                    end,100
                )
            end
        )
        list_skill:setNumItems(#skills)
    end
    local txt_match = self.com_recomTeam:getChild("txt_match")
    local str = DynamicConfigData.t_HelpDesc[configInfo.desc].desc
    txt_match:setText(str)
    local list_match = self.com_recomTeam:getChild("list_match")
    local hero = configInfo.herolist
    list_match:setItemRenderer(
        function(idx, obj)
            local heroListId = hero[idx + 1]
            local bindCard = BindManager.bindCardCell(obj)
            bindCard:setData(heroListId, true)
            bindCard:setLevel(-1)
            obj:removeClickListener()
            obj:addClickListener(function()
                local conf = DynamicConfigData.t_HeroTotems
                local heroConfig = DynamicConfigData.t_hero[heroListId]
                local arr = conf[heroConfig.category]
                local h = false
                for _, d in pairs(arr) do
                    if (d.hero == heroListId) then
                        h = d
                        break
                    end
                end
                local info = {index = 1,heroId = heroListId, heroList = {h}};
                ViewManager.open("HeroInfoView", info);
            end)
        end
    )
    list_match:setNumItems(#hero)
end

--UI初始化
function HelpSysRecomView:_initEvent(...)
    self.channel1:addClickListener(
        function(...)
            self.c1:setSelectedIndex(0)
            self.list_herorace:setSelectedIndex(0)
            local type = 1
            local configInfo = DynamicConfigData.t_HelpHeroRecommend[type]
            self:showHeroRaceView(configInfo)
        end
    )

    self.channel2:addClickListener(
        function(...)
            self.c1:setSelectedIndex(1)
            self.list_school:setSelectedIndex(0)
            local type = 1
            local configInfo = DynamicConfigData.t_HelpHeroRecommend2[type]
            self:showRecomTeam(configInfo)
        end
    )

    self.channel3:addClickListener(
        function(...)
            self.c1:setSelectedIndex(2)
            self.list_recomTeam = self.view:getChild("list_recomTeam")
            self.list_recomTeam:setItemRenderer(
                function(idx, obj)
                    if (not obj.lua_script) then
                        obj.lua_script = StrongItem.new(obj, 2)
                    end
                    obj.lua_script:setIndex(idx + 1)
                end
            )
            self.list_recomTeam:setNumItems(#DynamicConfigData.t_BattleArray)
        end
    )
end

return HelpSysRecomView
