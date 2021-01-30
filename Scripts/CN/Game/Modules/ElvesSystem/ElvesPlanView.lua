-- added by wyz
-- 精灵方案界面
local ElvesPlanView = class("ElvesPlanView",Window)
local ElvesPlanArray = require "Game.Modules.ElvesSystem.ElvesPlanArray"

function ElvesPlanView:ctor()
    self._packName  = "ElvesSystem"
    self._compName  = "ElvesPlanView"
    -- self._rootDepth = LayerDepth.PopWindow

    self.list_page      = false     -- 方案页签列表
    self.list_elvesSeq  = false     -- 上阵顺序列表
    self.list_elvesInfo = false     -- 精灵信息列表
    self.btn_edit       = false     -- 修改方案名按钮
    self.planIndex      = 1         -- 方案页签索引
end

function ElvesPlanView:_initUI()
    self.list_page      = self.view:getChildAutoType("list_page")
    self.list_elvesSeq  = self.view:getChildAutoType("list_elvesSeq")
    self.list_elvesInfo = self.view:getChildAutoType("list_elvesInfo")
    self.btn_edit       = self.view:getChildAutoType("btn_edit")
    self.arrayType      = self._args.arrayType   -- 精灵阵容信息
    self:setBg("elvesPlanBg.jpg")
end

function ElvesPlanView:_initEvent()
    self:ElvesPlanView_refreshPanal()
end

function ElvesPlanView:ElvesPlanView_refreshListPage(_,params)
    if params and params.id then 
        self.planIndex = params.id
    end
    local planData  = ModelManager.ElvesSystemModel.planInfo
    local ElvesData = ModelManager.ElvesSystemModel:getElvesInfoByType(1)
    self.list_page:setSelectedIndex(self.planIndex-1)
    self.list_page:setItemRenderer(function(idx,obj)
        local data  = planData[idx+1]
        local title = obj:getChildAutoType("title")
        local txt_pageNum = obj:getChildAutoType("txt_pageNum")
        txt_pageNum:setText(idx+1)
        if data.name ~= "" then
            title:setText(data.name)
        else
            title:setText(Desc["ElvesSystem_planPage"..(idx+1)])
        end
    end)
    self.list_page:setNumItems(3)

    self.list_page:removeClickListener(888)
    self.list_page:addClickListener(function()
        if self.planIndex == (self.list_page:getSelectedIndex() + 1) then return end
        self.planIndex = self.list_page:getSelectedIndex() + 1
        self.list_page:setSelectedIndex(self.planIndex-1)
        self:updateElvesPlanList()
        self:ElvesPlanView_refreshListInfo()
    end,888)
end

function ElvesPlanView:ElvesPlanView_refreshListInfo()
    local ElvesData = ModelManager.ElvesSystemModel.elvesAllData[1]
    self.list_elvesInfo:setItemRenderer(function(idx,obj)
        local index = idx + 1
        local data  = ElvesData[index]
        local enterCtrl = obj:getController("enterCtrl") -- 判断有没有上阵
        local haveCtrl  = obj:getController("haveCtrl")  -- 精灵是否已拥有
        local txt_Lv    = obj:getChildAutoType("txt_Lv") -- 精灵等级
        local txt_skillName = obj:getChildAutoType("txt_skillName") -- 技能名
        local txt_skillCD   = obj:getChildAutoType("txt_skillCD") -- 技能CD
        local txt_enerval   = obj:getChildAutoType("txt_enerval") -- 技能能量值
        local btn_skillInfo = obj:getChildAutoType("btn_skillInfo") -- 技能信息按钮
        local iconLoader    = obj:getChildAutoType("iconLoader")--:getChildAutoType("icon")    -- 精灵头像
        local url           = ItemConfiger.getItemIconByCode(data.elfId)
        iconLoader:setURL(url)


        if data.have > 0 then
            iconLoader:setGrayed(false)
            haveCtrl:setSelectedIndex(1)
        else
            iconLoader:setGrayed(true)
            haveCtrl:setSelectedIndex(0)
        end

        local enter = ModelManager.ElvesSystemModel:planJudgeById(self.planIndex,data.elfId)
        enterCtrl:setSelectedIndex(enter and 1 or 0)

        local skillInfo     = DynamicConfigData.t_skill[data.skillId]
        txt_Lv:setText("Lv." .. data.star)
        txt_skillName:setText(skillInfo.skillName)
        txt_enerval:setText(string.format(Desc.ElvesSystem_elvescostEnergy,data.costEnergy))
        txt_skillCD:setText(string.format(Desc.ElvesSystem_skillCD,data.coolDown))

        btn_skillInfo:removeClickListener(888)
        btn_skillInfo:addClickListener(function(context)
            context:stopPropagation()
            ViewManager.open("ElvesSkillTipsInfoView",{data = data})
        end,888)

        obj:removeClickListener(888)
        obj:addClickListener(function()
            if data.have == 0 then 
                RollTips.show(Desc.ElvesSystem_noElves)
                return
            end
            local enter = ModelManager.ElvesSystemModel:planJudgeById(self.planIndex,data.elfId)
            if enter then 
                RollTips.show(Desc.ElvesSystem_elvesHaveEnter)
                return 
            end
            local elvesEnterData =  ElvesSystemModel:getElvesEnterData(self.planIndex)
            if #elvesEnterData >=3 then
                RollTips.show(Desc.ElvesSystem_elvesEnterMax)
                return
            end

            ModelManager.ElvesSystemModel:setElvesEnterData(data,self.planIndex,false)
            local enter = ModelManager.ElvesSystemModel:planJudgeById(self.planIndex,data.elfId)
            enterCtrl:setSelectedIndex(enter and 1 or 0)
            local reqInfo = {
                uuid = data.uuid,
                id   = self.planIndex,
                pos  = #elvesEnterData,
            }
            RPCReq.Elf_SetPlan(reqInfo,function(data)
                printTable(8848,">>>设置精灵方案>>Elf_SetPlan>>>data>>",data)
                ModelManager.ElvesSystemModel.planInfo[self.planIndex] = data.data
            end)
            self:updateElvesPlanList()
        end,888)
        
    end)
    self.list_elvesInfo:setData(ElvesData)
end

function ElvesPlanView:ElvesPlanView_refreshPanal()
    self:ElvesPlanView_refreshListPage()
    self:ElvesPlanView_refreshListInfo()
    self:updateElvesPlanList()
    self.btn_edit:removeClickListener(888)
    self.btn_edit:addClickListener(function()
        ViewManager.open("ElvesPlanEditBoxView",{id = self.planIndex})
    end)
end

-- 更新上阵列表
function ElvesPlanView:updateElvesPlanList()
    local elvesEnterData =  ElvesSystemModel:getElvesEnterData(self.planIndex)
    self.list_elvesSeq:setItemRenderer(function(idx,obj)
        local index    = idx + 1
        local data     = elvesEnterData[index]
        local haveCtrl = obj:getController("haveCtrl")
        local txt_elvesName = obj:getChildAutoType("txt_elvesName")
        local title    = obj:getChildAutoType("title")
        local iconLoader = obj:getChildAutoType("iconLoader/icon")
        title:setText(index)
        if data then
            haveCtrl:setSelectedIndex(1)
            local url           = ItemConfiger.getItemIconByCode(data.elfId)
            iconLoader:setURL(url)
            txt_elvesName:setText(data.elfName)
        else
            haveCtrl:setSelectedIndex(0)
            iconLoader:setURL("")
        end
        obj:removeClickListener(888)
        obj:addClickListener(function()
            if data then
                local reqInfo = {
                    id = self.planIndex,
                    pos = index,
                }
                RPCReq.Elf_NextPlan(reqInfo,function(params)
                    printTable(8848,">>>精灵下阵>> Elf_NextPlan>params>>",params)
                    ModelManager.ElvesSystemModel.planInfo[self.planIndex].pos = params.data.pos
                    ModelManager.ElvesSystemModel:setElvesEnterData(data,self.planIndex,data.elfId)
                    self:updateElvesPlanList()
                    self:ElvesPlanView_refreshListInfo()
                end)
            end
        end,888)
    end)
    self.list_elvesSeq:setNumItems(3)
   -- printTable(8848,">>>elvesEnterData>>>",elvesEnterData)
end


function ElvesPlanView:_exit()
    -- 如果存在 保存阵容 
    -- 同时刷新我自己的备战界面
    local elvesEnterData =  ElvesSystemModel:getElvesEnterData(self.planIndex)
    if self.arrayType then
        local reqInfo = {
            arrayType = self.arrayType, -- 阵容类型
            planId    = self.planIndex, -- 方案id
        }
        if TableUtil.GetTableLen(ElvesSystemModel:getElvesEnterData(1)) == 0 and 
        TableUtil.GetTableLen(ElvesSystemModel:getElvesEnterData(2)) == 0 and 
        TableUtil.GetTableLen(ElvesSystemModel:getElvesEnterData(3)) == 0 then
            Dispatcher.dispatchEvent(EventType.ElvesAddTopView_refresh)
            return
        end

        local saveElvesPlan = function(params)
            print(8848,">>>>精灵阵容保存成功>>>>")
            printTable(8848,">>>精灵阵容params>>",params)
            if not ModelManager.ElvesSystemModel.arrays[params.data.arrayType] then
                ModelManager.ElvesSystemModel.arrays[params.data.arrayType] = {}
            end
            table.insert(ModelManager.ElvesSystemModel.arrays[params.data.arrayType],params.data)
            -- 刷新界面
            local data = {
                arrayType = self.arrayType,
                planId    = self.planIndex,
            }
            printTable(8848,">>>self.planIndex>>>",self.planIndex)
            ModelManager.ElvesSystemModel.planId[self.arrayType] = self.planIndex
            ModelManager.ElvesSystemModel:setMyElvesBattleReqInfo(self.arrayType,self.planIndex)
            Dispatcher.dispatchEvent(EventType.ElvesAddTopView_refresh)
        end

        local planArray = ElvesPlanArray[self.arrayType]
        if planArray then
            for k,v in pairs(planArray) do
                reqInfo = {
                    arrayType = v,
                    planId    = self.planIndex,
                }
                RPCReq.Elf_SetArraysPalnId(reqInfo,function(params)
                    if k == 1 then
                        saveElvesPlan(params)
                    end
                end)
            end
        else
            RPCReq.Elf_SetArraysPalnId(reqInfo,function(params)
                saveElvesPlan(params)
            end)
        end
    end
end

return ElvesPlanView