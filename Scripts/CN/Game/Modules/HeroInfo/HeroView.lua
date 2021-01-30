-- added by zn
-- 英雄信息
local HeroConfiger = require "Game.ConfigReaders.HeroConfiger";
local HeroView = class("HeroView", Window)

function HeroView:ctor()
    self._packName = "HeroInfo"
    self._compName = "HeroView"
    -- self._rootDepth = LayerDepth.PopWindow
    self.arrow_right = false
    self.arrow_left = false
    self.loader_hero = false
    self.skeletonNode = false
	
	self._willOpenInBattle=true --如果战斗中打开要减慢速度

    self.txt_name = false
    self.txt_power = false
    self.txt_runeLv = false

    self.loader_category = false
    self.img_uniqueWeapon = false
    self.loader_profes = false
    self.img_herobg = false
    self.img_viewbg=false
    self.cardStar = false
    self.txt_ranknum = false
    self.txt_rankName = false

    self.list_attr = false -- 属性
    self.list_skill = false -- 技能
    self.list_equip = false -- 装备
    self.list_talent = false -- 特性
    self.list_rune = false -- 符文

    self.runeBottom = false
    self.rune_skill = false
    self.rune_skillName = false
    self.rune_skillDesc = false

    self.data = self._args
end

function HeroView:_initUI()
    --self:setBg("bg_heroInfo.jpg");
    self.arrow_right = self.view:getChild("arrow_right")
    self.arrow_left = self.view:getChild("arrow_left")
    local loader_hero = self.view:getChild("loader_hero")
    self.loader_hero = BindManager.bindLihuiDisplay(loader_hero)

    self.txt_name = self.view:getChild("txt_name")
    self.txt_power = self.view:getChild("txt_power")
    self.txt_runeLv = self.view:getChild("txt_runeLv")
    self.txt_level = self.view:getChild("txt_level")

    self.list_attr = self.view:getChild("list_attr")
    self.list_skill = self.view:getChild("list_skill")
    self.list_equip = self.view:getChild("list_equip")
    self.list_talent = self.view:getChild("list_talent")
    self.list_rune = self.view:getChild("list_rune")
    self.list_jewelry = self.view:getChildAutoType("list_jewelry");
    self.list_emblem = self.view:getChildAutoType("list_emblem");
    self.list_emblemSuit = self.view:getChildAutoType("list_emblemSuit");
    self.txt_ranknum = self.view:getChild("txt_ranknum")
    self.txt_rankName = self.view:getChild("txt_rankName")

    self.runeBottom = self.view:getChild("runeBottom")
    self.rune_skill = self.view:getChild("rune_skill")
    self.rune_skillName = self.view:getChild("rune_skillName")
    self.rune_skillDesc = self.view:getChild("rune_skillDesc")

    self.loader_category = self.view:getChild("loader_category")
    self.img_uniqueWeapon = self.view:getChild("img_uniqueWeapon")
    self.loader_profes = self.view:getChild("loader_profes")
    self.img_herobg = self.view:getChild("img_herobg")
    self.img_viewbg = self.view:getChild("img_viewbg")
    local cardStar = self.view:getChild("cardStar")
    self.cardStar = BindManager.bindCardStar(cardStar)

    self.img_viewbg:setURL(PathConfiger.getBg("heroshareBg.jpg"))
    self.img_herobg:setURL(PathConfiger.getBg("heroshareBg1.png"))

    
    self:HeroView_initView()
end

function HeroView:_initEvent()
    self.arrow_right:addClickListener(
        function()
            if (HeroInfoModel:turnPage(1)) then
                HeroInfoModel:getHeroInfo()
            end
        end
    )

    self.arrow_left:addClickListener(
        function()
            if (HeroInfoModel:turnPage(0)) then
                HeroInfoModel:getHeroInfo()
            end
        end
    )

	self.img_uniqueWeapon:addClickListener(
        function()
			local data = HeroInfoModel.data
			local uniqueWeaponLevel = data.uniqueWeapon and data.uniqueWeapon.level or -1
			if uniqueWeaponLevel >= 0 then
				local heroInfo = {code = data.code, uuid = data.uuid}
				HeroConfiger.initHeroInfo(heroInfo)
				ViewManager.open("UniqueWeaponTipsView", {heroInfo = heroInfo, onlyShow = true})
			end
        end
    )
end

-- 初始化界面
function HeroView:HeroView_initView()
    if (tolua.isnull(self.view)) then
        return
    end
    self:upArrowStatus() -- 更新箭头
    self:initBaseInfo() -- 基础信息
    self:initAttrsInfo() -- 属性信息
    self:initSkillInfo() -- 技能
    self:initEquipInfo() -- 装备
    self:initTalentInfo() -- 特性
    -- self:initRuneInfo() -- 符文
    self:initRankInfo() -- 排行
    self:initJewelryInfo() -- 饰品
    self:initEmblemList() -- 纹章
end

-- 更新箭头显示状态
function HeroView:upArrowStatus()
    local allHero = HeroInfoModel.heroArray
    local idx = HeroInfoModel.showIndex
    if not allHero then
        return
    end
    local count = #allHero
    local arrowCtrl = self.view:getController("c1")
    if (count == 0 or count == 1) then
        arrowCtrl:setSelectedIndex(0)
    elseif idx == 1 then
        arrowCtrl:setSelectedIndex(2)
    elseif idx == count then
        arrowCtrl:setSelectedIndex(1)
    else
        arrowCtrl:setSelectedIndex(3)
    end
end

-- 初始化基础信息
function HeroView:initBaseInfo()
    local conf = DynamicConfigData.t_hero[HeroInfoModel.heroId]
    self.txt_name:setText(conf.heroName)
    self.txt_power:setText(StringUtil.transValue(HeroInfoModel.power))
    self.txt_level:setText(HeroInfoModel.data.level)
    self.loader_category:setIcon(PathConfiger.getCardCategory(conf.category))
	local data = HeroInfoModel.data
	local uniqueWeaponLevel = data.uniqueWeapon and data.uniqueWeapon.level or -1
    self.img_uniqueWeapon:setIcon(PathConfiger.getUniqueWeaponLevel(uniqueWeaponLevel))
    self.loader_profes:setIcon(PathConfiger.getCardProfessionalWhite(conf.professional))
    self.cardStar:setData(HeroInfoModel.data.star)

    --[[if self.skeletonNode then 
		self.skeletonNode:removeFromParent()
		self.skeletonNode = false
	end--]]
    self.loader_hero:setData(HeroInfoModel.heroId,nil,nil,HeroInfoModel.fashionId)
end

-- 初始化属性信息
function HeroView:initAttrsInfo()
    local attrs = HeroInfoModel.attrs
    local att_type = DynamicConfigData.t_hero[HeroInfoModel.heroId].attType
    local reality = {}
    for key, value in pairs(attrs) do
        if att_type == 1 and value.id ~= 4 and value.id <= 6 then
            reality[#reality + 1] = value
        elseif att_type == 2 and value.id ~= 2 and value.id <= 6 then
            reality[#reality + 1] = value
        end
    end
    self.list_attr:setItemRenderer(
        function(idx, obj)
            local txt_val = obj:getChild("txt_val")
            local txt_addPoint = obj:getChild("txt_addPoint")
            txt_val:setText(reality[idx + 1].value)
            obj:setIcon(PathConfiger.getFightAttrIcon(idx + 1))
            obj:setTitle(CardLibModel.cardAttrName[reality[idx + 1].id])
            local addPointNum = HeroInfoModel:getAttrPointList(reality[idx + 1].id)
            if addPointNum > 0 then
                txt_addPoint:setVisible(true)
                txt_addPoint:setText("(+" .. addPointNum .. ")")
            else
                txt_addPoint:setVisible(false)
            end
        end
    )
    self.list_attr:setData(reality)
end

-- 初始化技能展示
function HeroView:initSkillInfo()
    local data = HeroInfoModel.data
    if (data) then
        -- 读取技能
        local stage = data.stage or 0
        local heroId = data.code
        local stageConf = DynamicConfigData.t_heroStage[stage]
        if stageConf == nil then
            return
        end
        local skillArr = {}
        local skillLevel = stageConf.skillLevel
        for i = 1, 4 do
            local level = skillLevel[i]
            local key = "skill" .. i
            local activeSkill1 = DynamicConfigData.t_hero[heroId][key][level]
            table.insert(skillArr, activeSkill1)
        end
        -- 展示技能
        self.list_skill:setItemRenderer(
            function(idx, obj)
                obj:removeClickListener(100)
                --池子里面原来的事件注销掉
                obj:addClickListener(
                    function(context)
                        --点击查看技能详情
                        local skillInfo = DynamicConfigData.t_skill[skillArr[idx + 1]]
                        if skillInfo then
                            ViewManager.open(
                                "ItemTips",
                                {codeType = CodeType.SKILL, id = skillArr[idx + 1], heroId = heroId}
                            )
                        end
                    end,
                    100
                )
                if (not obj.skillScript) then
                    obj.skillScript = BindManager.bindSkillCell(obj)
                end
                obj.skillScript:setData(skillArr[idx + 1])
            end
        )
        self.list_skill:setNumItems(#skillArr)
    end
end

-- 显示已穿戴装备
function HeroView:initEquipInfo()
    local equip = HeroInfoModel.equipmentMap
    local tab = {}
    for k in pairs(equip) do
        table.insert(tab, equip[k])
    end
    -- printTable(1, "穿戴装备",tab);
    local ctrl = self.view:getController("equip")
    if (#tab == 0) then
        ctrl:setSelectedIndex(0)
    else
        ctrl:setSelectedIndex(1)
    end

    -- LuaLogE(1, #tab);
    self.list_equip:setItemRenderer(
        function(idx, obj)
            local data = tab[idx + 1]
            local itemcell = BindManager.bindItemCell(obj)
			--  itemcell:setIsBig(true)
             itemcell:setData(data.code,0,CodeType.ITEM)
            -- local info = EquipmentModel:getConfingByCode(data.code)
            -- local icon = EquipmentModel:getEqIconByeCode(data.code)
            -- obj:setTitle(data.code .. "\n" .. data.uuid)
            -- obj:getChildAutoType("starList/$list"):setNumItems(info.staramount or 0)
            -- obj:getChildAutoType("starBg"):setVisible((info.staramount and info.staramount > 0))
            -- obj:setIcon(icon)
            -- local frameLoader = obj:getChildAutoType("frame")
            -- frameLoader:displayObject():removeChildByTag(100)
            -- frameLoader:setURL(PathConfiger.getItemFrame(info.color, "normal"))

            -- if info.color == 5 or info.color == 6 then
            --     local skeletonNode =
            --         SpineUtil.createSpineObj(
            --         frameLoader,
            --         vertex2(frameLoader:getWidth() / 2, frameLoader:getHeight() / 2),
            --         "pingzhikuang_cheng",
            --         "Spine/ui/item",
            --         "daojupinzhikuang",
            --         "daojupinzhikuang",
            --         true
            --     )
            --     if not self._isBig then
            --         skeletonNode:setScale(0.75)
            --     end
            -- end
            -- obj:getChildAutoType("checkMark"):setVisible(false)
            -- obj:getChildAutoType("mask"):setVisible(false)
            -- obj:removeClickListener()
            -- obj:addClickListener(
            --     function(context)
            --         context:stopPropagation()
            --         local info = {
            --             eqtype = 3,
            --             node = obj,
            --             eqdata = data
            --         }
            --         EquipmentModel:setSkillData(data.uuid, data)
            --         ViewManager.open("EquipmentCompareView", info)
            --     end
            -- )
        end
    )
    self.list_equip:setNumItems(#tab)
end

-- 初始化特性技能
function HeroView:initTalentInfo()
    local skills = HeroInfoModel.passiveSkill
    local data = {}
    local ctrl = self.view:getController("talent")
    for k, d in pairs(skills) do
        if (d.skillId and d.skillId > 0) then
            table.insert(data, d)
        end
    end
    if (#data == 0) then
        ctrl:setSelectedIndex(0)
    else
        ctrl:setSelectedIndex(1)
    end
    self.list_talent:setItemRenderer(
        function(idx, obj)
            local d = data[idx + 1]
            local skillInfo = DynamicConfigData.t_passiveSkill[d.skillId]
            local passiveUrl = ModelManager.CardLibModel:getItemIconByskillId(skillInfo.icon)
            obj:setIcon(passiveUrl) --放了一张技能图片

            -- 点击事件
            obj:removeClickListener(100)
            --池子里面原来的事件注销掉
            obj:addClickListener(
                function()
                    ViewManager.open(
                        "ItemTips",
                        {codeType = CodeType.PASSIVE_SKILL, id = skillInfo.id, data = skillInfo}
                    )
                end,
                100
            )
        end
    )
    self.list_talent:setNumItems(#data)
end

function HeroView:initRuneInfo()
    -- 总等级
    local allLevel = HeroInfoModel:getAllRuneLevel()
    --self.txt_runeLv:setText(allLevel)
    self.runeBottom:setTitle(DescAuto[167]..allLevel) -- [167]="符文总等级:"
    -- 总属性
    local allAttr = HeroInfoModel:getAllRuneAttrs()
    local ctrl = self.view:getController("rune")
    if (#allAttr == 0) then
        ctrl:setSelectedIndex(0)
    else
        ctrl:setSelectedIndex(1)
    end
    self.list_rune:setVirtual()
    self.list_rune:setItemRenderer(
        function(idx, obj)
            local data = allAttr[idx + 1]
            obj:getChild("txt_desc"):setText(Desc["common_fightAttr" .. data.id])
            obj:getChild("txt_val"):setText("+ " .. GMethodUtil:getFightAttrName(data.id, data.value))
        end
    )
    self.list_rune:setNumItems(#allAttr)

    -- 符文技能
    local skills = HeroInfoModel.rune and HeroInfoModel.rune.skills
    local ctrl = self.view:getController("runeSkill")
    local skillCell = self.view:getChildAutoType("rune_skill");
    if (not skillCell.cell) then
        skillCell.cell = BindManager.bindSkillCell(skillCell);
    end
    local iconLoader = skillCell.cell.iconLoader;--self.view:getChildAutoType("rune_skill/iconLoader/iconLoader")
    if (skills and #skills > 0) then
        local skillid = skills[1]
        local conf = DynamicConfigData.t_passiveSkill[skillid]

        -- LuaLogE(skillid);
        if conf then
            local skillurl = CardLibModel:getItemIconByskillId(conf.icon)
            --printTable(1, conf)
            self.view:getChild("rune_skillName"):setText(conf.name)
            self.view:getChild("rune_skillDesc"):setText(conf.desc)
            iconLoader:setURL(skillurl)
            ctrl:setSelectedIndex(1)
        end
    else
        iconLoader:setURL("")
        ctrl:setSelectedIndex(0)
    end
end

function HeroView:initRankInfo() -- 排行
    local category = DynamicConfigData.t_hero[HeroInfoModel.heroId].category
    --local raceText = {"神族", "魔族", "兽族", "人族", "械族"}
    self.txt_rankName:setText(Desc["common_category"..category] .. DescAuto[168]) -- [168]="排名"
    local ctrl = self.view:getController("rank")
    local rank = HeroInfoModel.rank
    if not rank or rank < 1  then
        ctrl:setSelectedIndex(0)--无
    else
        ctrl:setSelectedIndex(1)--有
        self.txt_ranknum:setText(rank)
    end
    -- self.txt_ranknum:setText(1)
end

function HeroView:initJewelryInfo() -- 饰品
    local map = HeroInfoModel.data and HeroInfoModel.data.jewelryMap or {};
    local data = {};
    for _, d in pairs(map) do
        if (d.uuid) then
            table.insert(data, d);
        end
    end
    local ctrl = self.view:getController("jewelry")
    if (#data > 0) then
        self.list_jewelry:setItemRenderer(function(idx, obj)
            local d = data[idx + 1];
            if (not obj.cell) then
                obj.cell = BindManager.bindItemCell(obj);
            end
            obj.cell:setData(d.code, 1, GameDef.GameResType.Item);
            obj.cell:setClickable(false);
            obj:removeClickListener();
            obj:addClickListener(function()
                local data = {
					eqtype= 3,
					node= obj,
					pos = idx + 1,
					eqdata = d
				}
				ViewManager.open("JewelryCompareView",data)
            end)
        end)
        self.list_jewelry:setNumItems(#data);
        ctrl:setSelectedIndex(1);
    else
        ctrl:setSelectedIndex(0);
    end
end

function HeroView:initEmblemList()
    local category = DynamicConfigData.t_hero[HeroInfoModel.heroId].category
    local data = HeroInfoModel.data and HeroInfoModel.data.heraldryHero or {};
    local emblems = data and data.data or {};
    local c1 = self.view:getController("emblem");
    local c2 = self.view:getController("emblemSuit");
    if (TableUtil.GetTableLen(emblems) == 0) then
        c1:setSelectedIndex(0);
        c2:setSelectedIndex(0);
    else
        c1:setSelectedIndex(1);
        local arr = {};
        for _, d in pairs(emblems) do
            table.insert(arr, EmblemModel:__rebuildStruct(d));
        end
        self.list_emblem:setItemRenderer(function(idx, obj)
            local d = arr[idx + 1];
            if (not obj.cell) then
                obj.cell = BindManager.bindEmblemCell(obj);
            end
            obj.cell:setStarType(1);
            obj.cell:setCategoryPos(1);
            obj.cell:showFrame(false);
            obj.cell:setData(d);
            obj:removeClickListener();
            obj:addClickListener(function()
                obj.cell:showItemTips({equiped = arr, category = category});
            end)
        end)
        self.list_emblem:setNumItems(#arr);

        local suit = EmblemModel:getHeroSuitInfo(arr)
        local sConf = DynamicConfigData.t_EmblemSuit;
        local skillConf = DynamicConfigData.t_skill;
        local suitTab = {};
        for suitId, info in pairs(suit) do
            local c = sConf[suitId];
            for type, level in pairs(info) do
                local name = string.format(Desc.Emblem_suitDesc1, c.suitName, type);
                local skillId = c["suit"..type][level];
                local str = skillConf[skillId] and skillConf[skillId].showName or "";
                table.insert(suitTab, name..str);
            end
        end
        self.list_emblemSuit:setItemRenderer(function (idx, obj)
            local s = suitTab[idx + 1];
            obj:setTitle(s);
        end)
        local len = #suitTab
        self.list_emblemSuit:setNumItems(len)
        c2:setSelectedIndex(len > 0 and 1 or 0);
    end
end

function HeroView:__onExit()
	BattleModel:updateGameSpeed()
end



return HeroView
