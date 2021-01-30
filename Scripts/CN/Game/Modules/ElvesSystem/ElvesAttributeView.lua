
-- added by wyz 
-- 精灵属性

local ElvesAttributeView = class("ElvesAttributeView",Window)

local TimeLib = require "Game.Utils.TimeLib"
function ElvesAttributeView:ctor()
    self._packName  = "ElvesSystem"
    self._compName  = "ElvesAttributeView"
    self.txt_power  = false     -- 精灵战力
    self.txt_name   = false     -- 精灵名字
    self.txt_step   = false     -- 精灵阶级
    self.level      = false     -- 精灵等级
    self.cardStar   = false     -- 精灵星级
    self.list_attr  = false     -- 精灵属性
    self.detailSkillCell = false   -- 技能详情
    self.elvesatk   = false     -- 精灵攻击
    self.btn_upGrade = false
    self.txt_consume = false
    self.itemCell = false
    self.animate    = false
    self.animate2   = false
    self.heroQuality = false
    self.elvesData        = {}
    self.btn_goStar = false
    self.elvesIndex = 0
    self.elvesPageIndex = 0
    self.lvUpEffect2 = false
    self.timer      = false
end

function ElvesAttributeView:_initUI()
    self.txt_power = self.view:getChildAutoType("txt_power")
    self.txt_name = self.view:getChildAutoType("txt_name")
    self.txt_step = self.view:getChildAutoType("txt_step")
    self.level = self.view:getChildAutoType("level")
    local cardStar = self.view:getChildAutoType("cardStar")
    self.list_attr = self.view:getChildAutoType("list_attr")
    self.detailSkillCell = self.view:getChildAutoType("detailSkillCell")
    self.cardStar = BindManager.bindCardStar(cardStar)
    self.elvesatk = self.view:getChildAutoType("elvesatk")
    self.btn_upGrade = self.view:getChildAutoType("btn_upGrade")
    self.itemCell = self.view:getChildAutoType("itemCell")
    self.txt_consume = self.view:getChildAutoType("txt_consume")
    self.stageCtrl = self.view:getController("stageCtrl")
    local heroQuality = self.view:getChildAutoType("heroQuality")
    self.heroQuality = BindManager.bindHeroQuality(heroQuality)
    self.btn_goStar = self.view:getChildAutoType("btn_goStar")
end

function ElvesAttributeView:updateContent(elvesIndex)
    local txt_attrName = self.elvesatk:getChildAutoType("txt_attrName")
    local txt_cur   = self.elvesatk:getChildAutoType("txt_cur")
    local loader_attrIcon = self.elvesatk:getChildAutoType("loader_attrIcon")
    local txt_newNum = self.elvesatk:getChildAutoType("txt_newNum")
    local txt_skillDesc = self.detailSkillCell:getChildAutoType("txt_skillDesc")
    txt_attrName:setText(Desc.ElvesSystem_str3)
    loader_attrIcon:setURL(PathConfiger.getFightAttrIcon(2))
    
    local ElfStar = DynamicConfigData.t_ElfStar[self.elvesData.elfId]
    local skillShortDesc = ElfStar[self.elvesData.star].skillShortDesc
    txt_skillDesc:setText(skillShortDesc)

    local itemCode      = false
    local haveNum       = 0
    local needNum       = 0 
    local ElfCfg        = DynamicConfigData.t_ElfMain[self.elvesData.elfId]
    -- local stage         = ElfCfg[self.elvesData.level].stage
    local stage = self.elvesData.star

    if ElfCfg[self.elvesData.level + 1] then
        -- stage       = ElfCfg[self.elvesData.level+1].stage
        needNum     = ElfCfg[self.elvesData.level + 1].experience
        itemCode    = ElfCfg[self.elvesData.level + 1].itemCode
        haveNum     = ModelManager.PackModel:getItemsFromAllPackByCode(itemCode)  
    else
        needNum     = ElfCfg[self.elvesData.level].experience
        itemCode    = ElfCfg[self.elvesData.level].itemCode
        haveNum     = ModelManager.PackModel:getItemsFromAllPackByCode(itemCode)  
    end
    self.heroQuality:setData(self.elvesData.quality)
    local img_red = self.btn_upGrade:getChildAutoType("img_red")
    img_red:setVisible(ElvesSystemModel:checkGradeRed(self.elvesData.elfId))

    local state = 0
    if self.elvesData.level == #ElfCfg then
        state = 2
    elseif ElfCfg[self.elvesData.level + 1].stage > stage then
        state = 1
    else
        state = 0
    end 

    local ElfMainShowLevelCfg = DynamicConfigData.t_ElfMainShowLevel[self.elvesData.elfId][self.elvesData.star]
    local level = self.view:getChildAutoType("level")
    local levelMax = self.view:getChildAutoType("levelMax")
    level:setText(self.elvesData.level)
    TableUtil.sortByMap(ElfMainShowLevelCfg,{{key="level",asc="true"}})
    levelMax:setText(ElfMainShowLevelCfg[1].level)

    self.btn_goStar:removeClickListener(11)
    self.btn_goStar:addClickListener(function()  
        ViewManager.close("ElvesSystemBaseView")
        ModuleUtil.openModule(ModuleId.Elves_Upstar.id,nil,{data =self.elvesData,elvesIndex=self.elvesIndex ,elvesPageIndex = self.elvesPageIndex})
    end,11)

    self.stageCtrl:setSelectedIndex(state)
    self.btn_upGrade:removeClickListener(888)
    self.btn_upGrade:addClickListener(function()
        if self.elvesData.uuid == "" then
            RollTips.show(Desc.ElvesSystem_noElves)
            return
        end
        if ElfCfg[self.elvesData.level + 1] and ElfCfg[self.elvesData.level + 1].stage > stage then
            printTable(8848,">>>stage>>",stage)
            RollTips.show(Desc.ElvesSystem_str4)
            return
        end

        local amount = ModelManager.PackModel:getItemsFromAllPackByCode(itemCode)
        local pack = ModelManager.PackModel:getPackByType(GameDef.BagType.Normal):getItemsByCode(itemCode)
        if amount < 1 then
            RollTips.show(Desc.ElvesSystem_noHasNum)
            return
        end
        local reqInfo = {
            itemId = pack[1].__data.id,
            amount = needNum,
            bagType = GameDef.BagType.Normal,
            ex     = self.elvesData.elfId,
            strEx   = self.elvesData.uuid, 
        }
        local oldPower = self.elvesData.power
        ModelManager.ElvesSystemModel:setUpElvesOldPower(oldPower)
        if haveNum < needNum then 
            RollTips.show(Desc.ElvesSystem_noHasNum)
            return
        end
        self.animate = true
        self.animate2 = true
        local viewInfo = ViewManager.getViewInfo("ElvesSystemBaseView")
        local elvesInfo = viewInfo.window.elvesInfo
        local list_page = viewInfo.window.list_page
        elvesInfo:setTouchable(false)
        list_page:setTouchable(false)

        RPCReq.Bag_UseItem(reqInfo,function(res)
            print(8848,">>>>> ".. self.elvesData.elfName.. ">>升级成功>>>>>>") 
        end)
        if self.timer then
            Scheduler.unschedule(self.timer)
        end
        self.timer = Scheduler.scheduleOnce(1,function() 
            elvesInfo:setTouchable(true)
            list_page:setTouchable(true)
        end)

        Scheduler.scheduleOnce(0.2, function()
            if (tolua.isnull(self.view)) then
                return
            end
            if (not self.lvUpEffect2) then
                local parent = elvesInfo:getChildAutoType("loader_lvUpEffect")
                local pos = cc.p(parent:getWidth()/2, parent:getHeight()/2)
                self.lvUpEffect2 = SpineUtil.createSpineObj(parent, pos, "ui_dengjitisheng_up", "spine/ui/hallow", "efx_shengqizhanshi", "efx_shengqizhanshi", false)
            else
                self.lvUpEffect2:setAnimation(0, "ui_dengjitisheng_up", false)
            end
        end)

    end,888)

    local itemCell = BindManager.bindItemCell(self.itemCell)
    itemCell:setData(itemCode,0)
    itemCell:removeAllEffect()
    itemCell:setAmountVisible(false)
    itemCell:setNoFrame(true)

    local consuCtrl = self.view:getController("consuCtrl")
    consuCtrl:setSelectedIndex(0)
    if needNum > haveNum then
        consuCtrl:setSelectedIndex(1)
    end
    self.txt_consume:setText(needNum)

    local newDataAttribute = false
    if self.elvesData.level ~= #ElfCfg then
        newDataAttribute =  DynamicConfigData.t_ElfMain[self.elvesData.elfId][self.elvesData.level+1].elfAttkShow
    end

    local elfAttkShow = self.elvesData.elfAttkShow

    
    if newDataAttribute then
        txt_cur:setText(string.format("%s[color=#6aff60](%s)[/color]",newDataAttribute,newDataAttribute - elfAttkShow))
        txt_cur:setText(elfAttkShow)
        txt_newNum:setText("+" ..(newDataAttribute - elfAttkShow))
        if self.animate2 then
            txt_newNum:setVisible(true)
            self.elvesatk:getTransition("t0"):play(function()
                self.animate2 = false
            end)
        end
    else
        txt_cur:setText(" " .. elfAttkShow)
    end
    if self.animate2 then
        self.animate2 = false
    end
end

function ElvesAttributeView:_initEvent()

end

function ElvesAttributeView:ElvesAttributeView_refreshPanal(_,params)
    -- printTable(8848,"params",params)
    local elvesData = params.data
    self.elvesData = params.data
    local elvesIndex = params.elvesIndex
    self.elvesIndex = elvesIndex
    self.elvesPageIndex = params.elvesPageIndex
    if not elvesData then return end
    self:updateContent(elvesIndex)
    local ElfCfg = DynamicConfigData.t_ElfMain[elvesData.elfId]
    local elfSkinInfo = DynamicConfigData.t_ElfSkin[elvesData.elfId] or {}

    self.list_attr:setItemRenderer(function(idx,obj)
        local index = idx + 1
        local data = elvesData.attribute[index]
        local skinValue = 0     -- 所有皮肤的相同属性的数值
        -- 获取该精灵的所有皮肤信息
        -- 判断每一个皮肤是否都已经激活
        for i,m in pairs(elfSkinInfo) do
            local isHavaSkin = ElvesSystemModel:checkSkinById(m.skinId)
            if isHavaSkin then
                local basicAttr = m.basicAttr
                for ik,iv in pairs(basicAttr) do
                    if iv.type == data.type then
                        skinValue = skinValue + iv.value
                    end
                end
            end
        end
        local txt_attrName = obj:getChild("txt_attrName")
        local txt_cur = obj:getChild("txt_cur")
        local iconLoader = obj:getChildAutoType("loader_attrIcon")
        local txt_newNum = obj:getChildAutoType("txt_newNum")
        iconLoader:setURL(PathConfiger.getFightAttrIcon(data.type))
        txt_attrName:setText(ModelManager.CardLibModel.cardAttrName[data.type])

        local newDataAttribute = false
        if self.elvesData.level ~= #ElfCfg then
            newDataAttribute =  DynamicConfigData.t_ElfMain[self.elvesData.elfId][self.elvesData.level+1].attribute
        end
        if newDataAttribute then
            txt_cur:setText(data.value + skinValue)
            txt_newNum:setText("+" .. (newDataAttribute[index].value - (data.value + skinValue)))
            if self.animate then
                local viewInfo = ViewManager.getViewInfo("ElvesSystemBaseView")
                local list_page = viewInfo.window.list_page
                local elvesInfo = viewInfo.window.elvesInfo
                txt_newNum:setVisible(true)
                obj:getTransition("t0"):play(function()
    
                end)
            end
        else
            txt_cur:setText(" " .. (data.value + skinValue))
        end
        if index == TableUtil.GetTableLen(elvesData.attribute) and self.animate  then
            self.animate = false
        end
    end)
    self.list_attr:setData(elvesData.attribute)

    self.txt_power:setText(StringUtil.transValue(elvesData.power))
    self.txt_name:setText(elvesData.elfName)
    self.txt_step:setText(elvesData.stage)
    self.cardStar:setData(elvesData.star)

    local skillCell     = BindManager.bindSkillCell(self.detailSkillCell:getChildAutoType("skillCell"))
    local txt_skillLv   = self.detailSkillCell:getChildAutoType("txt_skillLv")
    local txt_skillName = self.detailSkillCell:getChildAutoType("txt_skillName")
    local txt_num       = self.detailSkillCell:getChildAutoType("txt_num")
    local txt_CD        = self.detailSkillCell:getChildAutoType("txt_CD")

    skillCell:setData(elvesData.skillId)
    
    local skillInfo     = DynamicConfigData.t_skill[elvesData.skillId]
    txt_skillLv:setText("Lv." .. elvesData.showLevel)
    txt_skillName:setText(skillInfo.skillName)
    txt_num:setText(elvesData.costEnergy)
    txt_CD:setText(string.format(Desc.ElvesSystem_skillCD2,elvesData.coolDown))

    self.detailSkillCell:getChildAutoType("skillCell"):removeClickListener(888)
    self.detailSkillCell:getChildAutoType("skillCell"):addClickListener(function()
        ViewManager.open("ElvesSkillTipsInfoView",{data = elvesData})
    end,888)
end

function ElvesAttributeView:pack_item_change()
    local itemCode      = false
    local ElfCfg        = DynamicConfigData.t_ElfMain[self.elvesData.elfId]
    local haveNum       = 0
    local needNum       = 0 
    if ElfCfg[self.elvesData.level + 1] then
        needNum     = ElfCfg[self.elvesData.level + 1].experience
        itemCode    = ElfCfg[self.elvesData.level + 1].itemCode
        haveNum     = ModelManager.PackModel:getItemsFromAllPackByCode(itemCode)  
    else
        needNum     = ElfCfg[self.elvesData.level].experience
        itemCode    = ElfCfg[self.elvesData.level].itemCode
        haveNum     = ModelManager.PackModel:getItemsFromAllPackByCode(itemCode)  
    end
    local consuCtrl = self.view:getController("consuCtrl")
    consuCtrl:setSelectedIndex(0)
    if needNum > haveNum then
        consuCtrl:setSelectedIndex(1)
    end
    self.txt_consume:setText(needNum)
end

function ElvesAttributeView:_exit()
    if self.timer then
        Scheduler.unschedule(self.timer)
    end
end

return ElvesAttributeView