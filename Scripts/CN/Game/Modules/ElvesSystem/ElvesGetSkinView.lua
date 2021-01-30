-- added by wyz
-- 获得精灵界面

local ElvesGetSkinView = class("ElvesGetSkinView",Window)

local _ElvesColorSubNum  = 3

function ElvesGetSkinView:ctor()
    self._packName = "ElvesSystem"
    self._compName = "ElvesGetSkinView"
    self._rootDepth = LayerDepth.PopWindow

    -- self.playerIcon = false
    -- self.lihuiDisplay = false
    self.rareCtrl   = false
    self.bannerIconLoader = false
    self.elfModel   = false
end

function ElvesGetSkinView:_initUI()
    self.rareCtrl       = self.view:getController("rareCtrl")
    self.txt_name       = self.view:getChildAutoType("txt_name")
    self.elfModel       = self.view:getChildAutoType("elfModel")
    -- self.bannerIconLoader = self.view:getChildAutoType("bannerIconLoader")
    -- self.playerIcon     = self.view:getChildAutoType("lihuiDisplay")
    -- self.lihuiDisplay   = BindManager.bindLihuiDisplay(self.playerIcon)
end

function ElvesGetSkinView:_initEvent()
    self:refreshPanal()
end

function ElvesGetSkinView:refreshPanal()
    local effectUpLoader    = self.view:getChildAutoType("effectUpLoader")
    local effectDownLoader  = self.view:getChildAutoType("effectDownLoader")
    local x1 = effectUpLoader:getWidth() / 2;
    local y1 = effectUpLoader:getHeight() / 2;
    local x2 = effectDownLoader:getWidth() / 2;
    local y2 = effectDownLoader:getHeight() / 2;
    effectUpLoader:displayObject():removeAllChildren()
    effectDownLoader:displayObject():removeAllChildren()
    local sp1 = SpineUtil.createSpineObj(effectUpLoader, cc.p(x1, y1), "huodejingling_up", "Effect/UI", "efx_huodejingling", "efx_huodejingling", true);
    local sp2 = SpineUtil.createSpineObj(effectDownLoader, cc.p(x2, y2), "huodejingling_down", "Effect/UI", "efx_huodejingling", "efx_huodejingling", true);

    local elfId = self._args.elfId
    -- if self._args.type == 1 then
    --     elfId = ModelManager.ElvesSystemModel.summonElves[#ModelManager.ElvesSystemModel.summonElves - ModelManager.ElvesSystemModel.summonElvesNum + 1]
    -- else
        -- elfId = self._args.elfId
    -- end
    -- local data = ModelManager.ElvesSystemModel:getElvesDataById(elfId)
    local skinData = self._args.data 
    local sourceBag = self._args.source
    local data = ModelManager.ElvesSystemModel:getElvesDataById(elfId)

    self:setElfModel(data,skinData)
    local power = ElvesSystemModel:getElvesSkinPower(skinData) or 0
    RollTips.showAddFightPoint(power) -- 弹战力
    -- if data.skinId == 1 and (not sourceBag) then
    --     self.rareCtrl:setSelectedIndex(data.color - _ElvesColorSubNum)
    --     self.txt_name:setText(data.elfName)
    -- else
        self.rareCtrl:setSelectedIndex(skinData.color - _ElvesColorSubNum)
        self.txt_name:setText(skinData.name)
    -- end
end

-- 设置精灵模型
function ElvesGetSkinView:setElfModel(data,skinData)
    local size = false
    local resource = false
    -- if data.skinId == 1 then    -- 使用默认皮肤
    --     resource = data.resource
    --     size    = data.size
    --     self.elfModel:setScale(size,size)
    -- else
        size    = skinData.size
        resource = skinData.resource
        self.elfModel:setScale(size,size)
    -- end
    if self.elfModel then
        self.elfModel:displayObject():removeAllChildren()
    end
    local skeletonNode = SpineUtil.createModel(self.elfModel, {x = 0, y =0}, "stand", false,false,resource)
end

-- -- 设置精灵模型
-- function ElvesGetSkinView:setElfModel(data)
--     local size = false
--     -- local modelId = false
--     local resource = false
--     if data.skinId == 1 then    -- 使用默认皮肤
--         -- modelId = data.model
--         resource = data.resource
--         size    = data.size
--         self.elfModel:setScale(size,size)
--     else
--         local skinInfo = ElvesSystemModel:getElvesSkinInfoById(data.elfId,data.skinId)
--         -- modelId = skinInfo.model
--         resource = skinInfo.resource
--         size    = skinInfo.size
--         self.elfModel:setScale(size,size)
--     end
--     if self.elfModel then
--         self.elfModel:displayObject():removeAllChildren()
--     end
--     local skeletonNode = SpineUtil.createModel(self.elfModel, {x = 0, y =0}, "stand", false,false,resource)
--     -- if data.have == 1 then
--         skeletonNode:setColor({r=255,g=255,b=255})
--         -- skeletonNode:pause()
--     -- else
--     --     skeletonNode:setColor({r=100,g=100,b=100})
--     --     -- skeletonNode:pause()
--     -- end
-- end

function ElvesGetSkinView:_exit()
    -- ModelManager.ElvesSystemModel.summonElvesNum = ModelManager.ElvesSystemModel.summonElvesNum - 1
    -- if ModelManager.ElvesSystemModel.summonElvesNum > 0 then
    --     ViewManager.open("ElvesGetSkinView",{type = 1})
    -- elseif #ModelManager.ElvesSystemModel.summonReward > 0 then
    --     RollTips.showReward(ModelManager.ElvesSystemModel.summonReward)
    --     ModelManager.ElvesSystemModel.summonReward = {}
    -- end
end

return ElvesGetSkinView