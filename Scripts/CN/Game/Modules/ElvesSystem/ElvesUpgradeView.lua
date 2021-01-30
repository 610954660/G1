
-- added by wyz 
-- 精灵升级

local ElvesUpgradeView = class("ElvesUpgradeView",Window)

function ElvesUpgradeView:ctor()
    self._packName  = "ElvesSystem"
    self._compName  = "ElvesUpgradeView"
    
    self.list_upGradeDesc = false   -- 属性列表
    self.btn_upGrade      = false   -- 升级按钮
    self.progressBar      = false   -- 阶级进度条
    self.txt_upGradeLv    = false   -- 当前阶级
    self.skillCell        = false   -- 技能按钮
    self.txt_SkillInfo    = false   -- 技能信息
    self.txt_LvOld        = false   -- 技能等级旧
    self.txt_LvNew        = false   -- 技能等级新
    self.itemCell         = false   -- 消耗品
    self.txt_consume      = false   -- 消耗数量
    self.c1Ctrl           = false   -- 升级按钮控制器
    self.elvesData        = {}
end

function ElvesUpgradeView:_initUI()
    self.list_upGradeDesc   = self.view:getChildAutoType("list_upGradeDesc")
    self.btn_upGrade        = self.view:getChildAutoType("btn_upGrade")
    self.progressBar        = self.view:getChildAutoType("progressBar")
    self.txt_upGradeLv      = self.view:getChildAutoType("txt_upGradeLv")
    self.skillCell          = self.view:getChildAutoType("skillCell")
    self.txt_SkillInfo      = self.view:getChildAutoType("txt_SkillInfo")
    self.txt_LvOld          = self.view:getChildAutoType("txt_LvOld")
    self.txt_LvNew          = self.view:getChildAutoType("txt_LvNew")
    self.itemCell           = self.view:getChildAutoType("itemCell")
    self.txt_consume        = self.view:getChildAutoType("txt_consume")
    self.skillCtrl          = self.view:getController("skillCtrl")
end

function ElvesUpgradeView:_initEvent()
    
end

function ElvesUpgradeView:ElvesUpgradeView_refreshPanal(_,params)
    -- printTable(8848,"ElvesUpgradeView_refreshPanal_params>>>>>>>>>",params)
    local elvesIndex = params.elvesIndex
    self.elvesData = params.data
    self.progressBar:setMax(100)
    local val = (self.elvesData.level % 10 == 0) and 10 or self.elvesData.level % 10
    self.progressBar:setValue(val*10)

    self.txt_upGradeLv:setText(string.format(Desc.ElvesSystem_lOrderDec,self.elvesData.stage,val))
    local ElfCfg        = DynamicConfigData.t_ElfMain[self.elvesData.elfId]
    self.list_upGradeDesc:setItemRenderer(function(idx,obj)
        local index = idx + 1
        local data = self.elvesData.attribute[index]
        local newDataAttribute = false
        if self.elvesData.level ~= #ElfCfg then
            newDataAttribute =  DynamicConfigData.t_ElfMain[self.elvesData.elfId][self.elvesData.level+1].attribute
        end
        local txt_attrName = obj:getChild("txt_attrName")
        local txt_curOld = obj:getChild("txt_curOld")
        local txt_curNew = obj:getChild("txt_curNew")
        local iconLoader = obj:getChildAutoType("loader_attrIcon")
        local maxCtrl    = obj:getController("maxCtrl")
        iconLoader:setURL(PathConfiger.getFightAttrIcon(data.type))
        txt_attrName:setText(ModelManager.CardLibModel.cardAttrName[data.type])
        txt_curOld:setText(" " .. data.value)
        if newDataAttribute then
            txt_curOld:setPivot(0,0.5,true)
            txt_curNew:setText(" " .. newDataAttribute[index].value)
            maxCtrl:setSelectedIndex(0)
        else
            txt_curOld:setPivot(1,0.5,true)
            maxCtrl:setSelectedIndex(1)
        end
        -- 还需要考虑满级的情况
        

    end)
    self.list_upGradeDesc:setData(self.elvesData.attribute)

    local itemCode      = false
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
    print(8848,">>>haveNum>>>>",haveNum)

    local img_red = self.btn_upGrade:getChildAutoType("img_red")
    -- RedManager.register("V_ELVES_UPGRADE"..elvesIndex..self.elvesData.elfId.."_UP", img_red)

    self.btn_upGrade:removeClickListener(888)
    self.btn_upGrade:addClickListener(function()
        if self.elvesData.uuid == "" then
            RollTips.show(Desc.ElvesSystem_noElves)
            return
        end
        local amount = ModelManager.PackModel:getItemsFromAllPackByCode(itemCode)
        local pack = ModelManager.PackModel:getPackByType(GameDef.BagType.Normal):getItemsByCode(itemCode)
        if amount < 1 then
            RollTips.show(Desc.ElvesSystem_noHasNum)
            return
        end
        -- local ModelManager.PackModel:getPackByType(GameDef.BagType.Elf):getItemsByCode(itemCode)
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
        RPCReq.Bag_UseItem(reqInfo,function(res)
            -- printTable(8848,">>>>reqInfo>>>",reqInfo)
            -- printTable(8848,">>>>res>>>>>",res)
            print(8848,">>>>> ".. self.elvesData.elfName.. ">>升级成功>>>>>>") 
            -- 刷新界面
            -- 弹战力提示
            -- local newPower = 
            -- local addNum = newPower - oldPower
            -- RollTips.showAddFightPoint(addNum)
        end)

    end,888)

    local skillCell     = BindManager.bindSkillCell(self.skillCell)
    self.txt_LvOld:setText("Lv." .. self.elvesData.showLevel)
    skillCell:setData(self.elvesData.skillId)
    local skillDesc = self.txt_SkillInfo:getChildAutoType("title")

    if self.elvesData.level ~= #ElfCfg then
        local newskillDesc =  DynamicConfigData.t_ElfMain[self.elvesData.elfId][self.elvesData.level+1].skillDesc
        skillDesc:setText(Desc.ElvesSystem_nextLv .. "  " .. newskillDesc)
    else
        skillDesc:setText(self.elvesData.skillDesc)
    end

    local LvMaxCtrl = self.view:getController("LvMaxCtrl")
    if  self.elvesData.level == #ElfCfg then
        LvMaxCtrl:setSelectedIndex(1)
    else
        LvMaxCtrl:setSelectedIndex(0)
    end

    self.skillCtrl:setSelectedIndex(0)
    if ElfCfg[self.elvesData.level + 1] then
        if ElfCfg[self.elvesData.level + 1].showLevel and (ElfCfg[self.elvesData.level + 1].showLevel ~= self.elvesData.showLevel) then
            self.skillCtrl:setSelectedIndex(1)
            self.txt_LvNew:setText("Lv." .. ElfCfg[self.elvesData.level + 1].showLevel)
        end
    end

    self.skillCell:removeClickListener(888)
    self.skillCell:addClickListener(function()
        ViewManager.open("ElvesSkillTipsInfoView",{data = self.elvesData})
    end,888)

    local itemCell = BindManager.bindItemCell(self.itemCell)
    itemCell:setData(itemCode,0)
    itemCell:removeAllEffect()
    itemCell:setAmountVisible(false)

    local consuCtrl = self.view:getController("consuCtrl")
    consuCtrl:setSelectedIndex(0)
    if needNum > haveNum then
        consuCtrl:setSelectedIndex(1)
    end
    self.txt_consume:setText(haveNum .. "/" .. needNum)
end

function ElvesUpgradeView:pack_item_change()
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
    self.txt_consume:setText(haveNum .. "/" .. needNum)
end



return ElvesUpgradeView