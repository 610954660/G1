
-- added by wyz 
-- 精灵升星
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
local ElvesUpstarView = class("ElvesUpstarView",Window)

function ElvesUpstarView:ctor()
    self._packName  = "ElvesSystem"
    self._compName  = "ElvesUpstarView"
    
    self.cardStar_old   = false     -- 当前星级
    self.cardStar_new   = false     -- 新的星级
    self.list_upStarDesc = false    -- 星级属性列表
    self.list_upStarMater = false   -- 升星所要消耗的材料
    self.btn_up         = false     
    self.btn_down       = false      
    self.btn_upStar     = false     -- 升星按钮
    self.scrollIndex    = 0
    self.scrollIndex2   = 0
    self.curStarDesc    = false
    self.nextStarDesc   = false
    self.maxStarDesc    = false
    self.maxStarDesc2   = false
    self.detailSkillCell = false
    self.skillDescContent = false
    self.list_upStarMater2 = false
    self.lvUpEffect2= false
end

function ElvesUpstarView:_initUI()
    -- self.cardStar_old       = self.view:getChildAutoType("cardStar_old")
    -- self.cardStar_new       = self.view:getChildAutoType("cardStar_new")
    self.list_upStarDesc    = self.view:getChildAutoType("list_upStarDesc")
    self.list_upStarMater   = self.view:getChildAutoType("list_upStarMater")
    self.btn_up             = self.view:getChildAutoType("btn_up")     
    self.btn_down           = self.view:getChildAutoType("btn_down")      
    self.btn_upStar         = self.view:getChildAutoType("btn_upStar")  
    self.curStarDesc        = self.view:getChildAutoType("curStarDesc")
    self.nextStarDesc       = self.view:getChildAutoType("nextStarDesc")
    self.maxStarDesc        = self.view:getChildAutoType("maxStarDesc")
    self.maxStarDesc2        = self.view:getChildAutoType("maxStarDesc2")
    self.detailSkillCell    = self.view:getChildAutoType("detailSkillCell")
    self.skillDescContent   = self.view:getChildAutoType("skillDescContent")
    self.list_upStarMater2   = self.view:getChildAutoType("list_upStarMater2")

end

function ElvesUpstarView:_initEvent()

end

function ElvesUpstarView:ElvesUpstarView_refreshPanal(_,params)
    print(8848,">>>>>>刷新升星界面>>>>>>>>>>")
    local elvesData =  params.data
    local elvesIndex = params.elvesIndex
    local cardStar_old  = self.view:getChildAutoType("cardStar_old")
    local cardStar_new  = self.view:getChildAutoType("cardStar_new")
    self.cardStar_old   = BindManager.bindCardStar(cardStar_old)
    self.cardStar_new   = BindManager.bindCardStar(cardStar_new)
    self.cardStar_old:setData(elvesData.star)
    local starData = DynamicConfigData.t_ElfStar[elvesData.elfId]
    if starData[elvesData.star + 1] then
        self.cardStar_new:setData(elvesData.star + 1)
    else
        self.cardStar_new:setData(elvesData.star)
    end

    local starMaxCtrl = self.view:getController("starMaxCtrl")
    starMaxCtrl:setSelectedIndex(0)
    if #starData == elvesData.star then
        starMaxCtrl:setSelectedIndex(1)
    end

    local stateCtrl = self.view:getController("stateCtrl")
    local state = 0
    if elvesData.star ~= #starData then
        if elvesData.star ~= #starData-1 then
            state = 0
        else
            state = 1
        end
    else
        state = 2
    end
    self.maxStarDesc:getChildAutoType("title"):setColor({r=255,g=255,b=255})
    self.maxStarDesc:getChildAutoType("txt_state"):setColor({r=255,g=255,b=255})
    if state == 2 then
        self.maxStarDesc2:getChildAutoType("title"):setColor({r=106,g=255,b=96})
        self.maxStarDesc2:getChildAutoType("txt_state"):setColor({r=106,g=255,b=96})
        self.maxStarDesc2:getChildAutoType("title"):setText(starData[#starData].desc)
        self.maxStarDesc2:getChildAutoType("txt_state"):setText(Desc.ElvesSystem_str5)
    elseif state == 1 then
        self.curStarDesc:getChildAutoType("title"):setText(starData[elvesData.star].desc)
        self.nextStarDesc:getChildAutoType("title"):setText(starData[elvesData.star+1].desc)
    elseif state == 0 then
        self.curStarDesc:getChildAutoType("title"):setText(starData[elvesData.star].desc)
        self.nextStarDesc:getChildAutoType("title"):setText(starData[elvesData.star+1].desc)
        self.maxStarDesc:getChildAutoType("title"):setText(starData[#starData].desc)
    end
    stateCtrl:setSelectedIndex(state)

    local skillCell     = BindManager.bindSkillCell(self.detailSkillCell:getChildAutoType("skillCell"))
    local txt_skillLv   = self.detailSkillCell:getChildAutoType("txt_skillLv")
    local txt_skillName = self.detailSkillCell:getChildAutoType("txt_skillName")
    local txt_num       = self.detailSkillCell:getChildAutoType("txt_num")
    local txt_CD        = self.detailSkillCell:getChildAutoType("txt_CD")

    skillCell:setData(elvesData.skillId)
    
    local skillInfo     = DynamicConfigData.t_skill[elvesData.skillId]
    txt_skillLv:setText("")
    txt_skillName:setText(skillInfo.skillName)
    txt_num:setText(elvesData.costEnergy)
    txt_CD:setText(string.format(Desc.ElvesSystem_skillCD2,elvesData.coolDown))

    self.detailSkillCell:getChildAutoType("skillCell"):removeClickListener(888)
    self.detailSkillCell:getChildAutoType("skillCell"):addClickListener(function()
        ViewManager.open("ElvesSkillTipsInfoView",{data = elvesData})
    end,888)
    local colorCfg = "[color=#6aff60]%s[/color]"
    local nextValue = starData[elvesData.star].nextValue
    local array    = {}
    array = string.split(nextValue,",")
    if nextValue ~= "" then
        self.skillDescContent:getChildAutoType("title"):setText(
            string.format(starData[elvesData.star].skillDesc,
            string.format(colorCfg,array[1]),
            string.format(colorCfg,array[2]),
            string.format(colorCfg,array[3]),
            string.format(colorCfg,array[4]),
            string.format(colorCfg,array[5])
            )
        )
    else
        self.skillDescContent:getChildAutoType("title"):setText(
            starData[elvesData.star].skillDesc
        )
    end


    self.list_upStarDesc:setVirtual()
    self.list_upStarDesc:setItemRenderer(function(idx,obj)
        local index = idx + 1
        local activateCtrl = obj:getController("activateCtrl")
        print(8848,">>>>>>index>>>>",index)
        local data  = starData[index]
        local txt_nextTips = obj:getChildAutoType("txt_nextTips")
        local txt_starLv   = obj:getChildAutoType("txt_starLv")
        local txt_desc     = obj:getChildAutoType("txt_desc")
        if (elvesData.star + 1) == data.star then
            txt_nextTips:setVisible(true)
        else
            txt_nextTips:setVisible(false)
        end
        activateCtrl:setSelectedIndex(index <= elvesData.star and 0 or 1)
        txt_starLv:setText(string.format(Desc.ElvesSystem_star,data.star))
        txt_desc:setText(data.desc)
    end)

    self.list_upStarDesc:setData(starData)

    local function doSpecialEffect( context )
        local curIndex = (self.list_upStarDesc:getFirstChildInView())%self.list_upStarDesc:getNumItems()
        if curIndex == 0 then
            self.btn_up:setVisible(false)
            self.btn_down:setVisible(true)
        elseif curIndex == self.list_upStarDesc:getNumItems() - 4 then
            self.btn_up:setVisible(true)
            self.btn_down:setVisible(false)
        else
            self.btn_up:setVisible(true)
            self.btn_down:setVisible(true)
        end
    end
    self.list_upStarDesc:addEventListener(FUIEventType.Scroll,doSpecialEffect)

    self:getScrollIndex(elvesData)
    if #starData == elvesData.star then
        self.scrollIndex = elvesData.star
    end
    print(8848,">>>self.scrollIndex>>>",self.scrollIndex)
    if self.scrollIndex <= 3 then
        -- self.list_upStarDesc:scrollToView(0,false,true)
        self.list_upStarDesc:getScrollPane():setPosY(1,false)
    elseif self.scrollIndex > 3 then
        self.list_upStarDesc:scrollToView(self.scrollIndex - 3,false,true)
    end


    local costData = false
    if starData[elvesData.star + 1] then
        costData = starData[elvesData.star + 1].cost
    else
        costData = starData[elvesData.star].cost
    end
    local canStar = true 
    self.list_upStarMater:setItemRenderer(function(idx,obj)
        local index = idx + 1
        local data = costData[index]
        local txt_num     = obj:getChildAutoType("txt_num")
        local itemCell    = BindManager.bindItemCell(obj:getChildAutoType("itemCell"))
        itemCell:setData(data.code,data.amount,data.type)
        -- itemCell.txtNum:setText('')
        local c1 = obj:getController("c1")
        local hasNum = 0  
        if data.type == CodeType.MONEY then
            hasNum = ModelManager.PlayerModel:getMoneyByType(data.code)
            itemCell:setSplitCtrl(0)
            txt_num:setText(MathUtil.toSectionStr(data.amount))
        else
            hasNum = ModelManager.PackModel:getItemsFromAllPackByCode(data.code)
            itemCell:setSplitCtrl(1)
            itemCell.view:getChildAutoType("img_category"):setVisible(false) 
            itemCell.view:getChildAutoType("img_categoryBg"):setVisible(false)
            txt_num:setText(MathUtil.toSectionStr(hasNum).."/"..MathUtil.toSectionStr(data.amount))
        end
        if canStar and hasNum < data.amount then
            canStar = false
        end
        c1:setSelectedIndex(hasNum >= data.amount and 0 or 1)
    end)
    self.list_upStarMater:setData(costData)

    self.list_upStarMater2:setItemRenderer(function(idx,obj)  
        local index = idx + 1
        local data = costData[index]
        local CostItem = BindManager.bindCostItem(obj)
        if data.type == CodeType.MONEY then 
            CostItem:setData(data.type,data.code,data.amount,true,false)
        else
            CostItem:setData(data.type,data.code,data.amount,false,false)
        end
        CostItem:setGreenColor("#6aff60")
    end)
    self.list_upStarMater2:setData(costData)


    local img_red = self.btn_upStar:getChildAutoType("img_red")
    -- RedManager.register("V_ELVES_UPSTAR"..elvesIndex..elvesData.elfId.."_UP", img_red)
    img_red:setVisible(ElvesSystemModel:checkStarRed(elvesData.elfId))

    self.btn_upStar:removeClickListener(888)
    self.btn_upStar:addClickListener(function()
        if elvesData.uuid == "" then
            RollTips.show(Desc.ElvesSystem_noElves)
            return
        end
        if not canStar then
            RollTips.show(Desc.ElvesSystem_noHasStarNum)
            return
        end
        local reqInfo = {
            uuid = elvesData.uuid
        }
        local power = elvesData.power
        RPCReq.Elf_UpdateStar(reqInfo,function(response)
            print(8848,">>>>>>>升星成功>>>>>>>>")
            -- 这里要刷新界面数据
            ModelManager.ElvesSystemModel:setUpElvesOldPower(power)
        end)
        Scheduler.scheduleOnce(0.2, function()
            if (tolua.isnull(self.view)) then
                return
            end
            if (not self.lvUpEffect2) then
                local viewInfo = ViewManager.getViewInfo("ElvesSystemBaseView")
                local elvesInfo = viewInfo.window.elvesInfo
                local parent = elvesInfo:getChildAutoType("loader_lvUpEffect")
                -- local parent = self.view:getChildAutoType("loader_lvUpEffect")
                local pos = cc.p(parent:getWidth()/2, parent:getHeight()/2)
                self.lvUpEffect2 = SpineUtil.createSpineObj(parent, pos, "ui_shengxingchenggong_up", "spine/ui/hallow", "efx_shengqizhanshi", "efx_shengqizhanshi", false)
            else
                self.lvUpEffect2:setAnimation(0, "ui_shengxingchenggong_up", false)
            end
        end)
    end,888)
end

function ElvesUpstarView:getScrollIndex(elvesData)
    local starData = DynamicConfigData.t_ElfStar[elvesData.elfId]
    for k,v in pairs(starData) do
        if v.star == (elvesData.star + 1) then
            self.scrollIndex = v.star
        end
    end
end

return ElvesUpstarView