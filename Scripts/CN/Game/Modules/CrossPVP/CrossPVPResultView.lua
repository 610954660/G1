local CrossPVPResultView = class("CrossPVPResultView", Window)

function CrossPVPResultView:ctor()
    self._packName = "CrossPVP"
    self._compName = "CrossPVPResultView"
    self._rootDepth = LayerDepth.PopWindow
    self.isWin = self._args.score > 0
	self.recordIds = self._args.battleeUuid
	self.otherPlayer = self._args.playerData
end

function CrossPVPResultView:_initUI()
    local root = self
    local rootView = self.view
    root.resultCtrl = rootView:getController("c1")
    root.txt_selfScore = rootView:getChildAutoType("txt_selfScore")
    root.txt_selfName = rootView:getChildAutoType("txt_selfName")
    root.txt_otherScore = rootView:getChildAutoType("txt_otherScore")
    root.txt_otherName = rootView:getChildAutoType("txt_otherName")
    root.txt_winCount = rootView:getChildAutoType("txt_winCount")
    root.list_group = rootView:getChildAutoType("list_group")
 	root.shareBtn = rootView:getChildAutoType("shareBtn")
	CrossPVPModel:setNeedPlay(false)
	for key,fightId in pairs(self.recordIds) do
		BattleModel:requestBattleRecord(fightId)
	end

	self.fightData = {}
end

function CrossPVPResultView:_initEvent()
    self._frame:addClickListener(function ()
        self:closeView()
    end)
end

function CrossPVPResultView:upGroupInfo()
    self.list_group:setItemRenderer(function (idx, obj)
        self:upGroupItem(idx, obj)
    end)
    self.list_group:setOpaque(false)
    self.list_group:setNumItems(#self.fightData)
    self.resultCtrl:setSelectedIndex(self.isWin and 0 or 1)
    local winCount = 0
    for _, data in ipairs(self.fightData) do
        if (data.result) then
            winCount = winCount + 1
        end
    end
    local loseCount = 3 - winCount
    self.txt_winCount:setText(winCount..":"..loseCount)
	if self._args.ackType == 2 then --·ÀÓù
		self.txt_otherName:setText(PlayerModel.username)
		self.txt_selfName:setText(self._args.playerData.name)
	else	
		self.txt_selfName:setText(PlayerModel.username)
		self.txt_otherName:setText(self._args.playerData.name)
	end
    local arrayType = self._args.arrayType
    local ctrl = self.view:getController("c2")
    ctrl:setSelectedIndex(0)
--    self.txt_selfScore:setText(self._args.score < 0 and self._args.score or "+"..self._args.score)
--    self.txt_selfScore:setColor(self.isWin and ColorUtil.textColor_Light.green or ColorUtil.textColor_Light.red)
--    self.txt_otherScore:setText(self._args.score < 0 and self._args.score or "+"..self._args.score)
--    self.txt_otherScore:setColor(self.isWin and ColorUtil.textColor_Light.red or ColorUtil.textColor_Light.green)
end

function CrossPVPResultView:upGroupItem(idx, obj)
    local fightData = self.fightData[idx + 1]
    local combats = self.recordIds[idx + 1]
    local isWin = fightData.result
    local data = fightData.battleObjSeq
    local selfHeros = {}
    local otherHeros = {}
    for _, d in pairs(data) do
        if (d.id < 200) then
            if (d.type == 1) then
                table.insert(selfHeros, d)
            end
        else
            if (d.type == 1 or d.type == 2) then
                table.insert(otherHeros, d)
            end
        end
    end
    local selfObj = obj:getChildAutoType("self")
    local otherObj = obj:getChildAutoType("other")
    selfObj:getController("c1"):setSelectedIndex(isWin and 0 or 1)
    otherObj:getController("c1"):setSelectedIndex(isWin and 1 or 0)
    selfObj.list = selfObj:getChildAutoType("list_hero")
    otherObj.list = otherObj:getChildAutoType("list_hero")
    local combat = fightData.gamePlayInfo.playerInfo[1].combat
    local defCombat = fightData.gamePlayInfo.playerInfo[2].combat
    selfObj:getChildAutoType("txt_power"):setText(StringUtil.transValue(combat))
    otherObj:getChildAutoType("txt_power"):setText(StringUtil.transValue(defCombat))

    selfObj.list:setItemRenderer(function (idx1, obj1)
        local hd = selfHeros[idx1 + 1]
        local conf = DynamicConfigData.t_hero[hd.code]
        if (conf) then
            hd.category = conf.category
            local heroCell = BindManager.bindHeroCell(obj1)
            heroCell:setBaseData(hd)
        end
        local isAlive = hd.finalHp > 0
        obj1:getController("grayCtrl"):setSelectedIndex(isAlive and 0 or 1)
    end)
    selfObj.list:setNumItems(#selfHeros)
    otherObj.list:setItemRenderer(function (idx2, obj2)
        local hd = otherHeros[idx2 + 1]
        local conf = hd.type == 1 and DynamicConfigData.t_hero[hd.code] or DynamicConfigData.t_monster[hd.code]
        if (conf) then
            hd.category = conf.category
            local heroCell = BindManager.bindHeroCell(obj2)
            heroCell:setBaseData(hd)
        end
        local isAlive = hd.finalHp > 0
        obj2:getController("grayCtrl"):setSelectedIndex(isAlive and 0 or 1)
    end)
    otherObj.list:setNumItems(#otherHeros)

    local btn = obj:getChildAutoType("btn_details")
    btn:removeClickListener(22)
    btn:addClickListener(function ()
        ViewManager.open("BattledataView",{isWin = fightData.result,isRecord = true,battleData = fightData})
    end, 22)
end

function CrossPVPResultView:Battle_BattleRecordData(_, param)
    if (#self.fightData < #self.recordIds) then
		table.insert(self.fightData,param.battleData)
    end
    if (#self.fightData == #self.recordIds) then
        if (tolua.isnull(self.view)) then return end
        self:upGroupInfo()
    end
end

return CrossPVPResultView