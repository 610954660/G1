--Date :2020-12-27
--Author : added by xhd
--Desc : 巅峰赛战斗数据界面 -- 已废弃

local StrideResultView,Super = class("StrideResultView", Window)

function StrideResultView:ctor()
	--LuaLog("StrideResultView ctor")
	self._packName = "StrideServer"
	self._compName = "StrideResultView"
    self._rootDepth = LayerDepth.PopWindow;
    self.fightData = {}
    self.recordIds = {}
    self.recordIds = self._args.recordIdList
end

function StrideResultView:_initEvent( )
    self._frame:addClickListener(function ()
        self:closeView()
    end)
    self.list_group:setItemRenderer(function (idx, obj)
        self:upGroupItem(idx, obj)
    end)
end

function StrideResultView:upGroupInfo()
    self.list_group:setNumItems(#self.fightData)
    local winCount = 0
    for _, data in ipairs(self.fightData) do
        if (data.result) then
            winCount = winCount + 1
        end
    end
    local loseCount = 3 - winCount
    self.txt_winCount:setText(winCount..":"..loseCount)
    self.txt_selfName:setText(self.fightData[1].gamePlayInfo.playerInfo[1].name)
    self.txt_otherName:setText(self.fightData[1].gamePlayInfo.playerInfo[2].name)

end

function StrideResultView:_initUI( )
	self:_initVM()
    for key,fightId in pairs(self.recordIds) do
        BattleModel:requestBattleRecord(fightId,nil,GameDef.GamePlayType.TopArena)
    end
end

function StrideResultView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:StrideServer.StrideResultView
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.list_group = viewNode:getChildAutoType('list_group')--GList
	self.txt_otherName = viewNode:getChildAutoType('txt_otherName')--GTextField
	self.txt_selfName = viewNode:getChildAutoType('txt_selfName')--GTextField
	self.txt_winCount = viewNode:getChildAutoType('txt_winCount')--GTextField
	--{autoFieldsEnd}:StrideServer.StrideResultView
    --Do not modify above code-------------

end

function StrideResultView:upGroupItem(idx, obj)
    local fightData = self.fightData[idx + 1]
    local combats = self.recordIds[idx + 1]
    local isWin = fightData.result
    local data = fightData.battleObjSeq
    local selfHeros = {}
    local otherHeros = {}
    for _, d in pairs(data) do
        if (d.type~=3 and d.type~=4) then
            if d.id> BattleModel.HeroPos.enemy.pos then
                table.insert( otherHeros,d)
            else
                table.insert( selfHeros,d)
            end
        end
    end
    local title = obj:getChildAutoType("title")
    title:setText(#selfHeros.."V"..#otherHeros)

    local selfObj = obj:getChildAutoType("self")
    local otherObj = obj:getChildAutoType("other")
    selfObj:getController("checkWin"):setSelectedIndex(isWin and 0 or 1)
    otherObj:getController("checkWin"):setSelectedIndex(isWin and 1 or 0)
    selfObj.list = selfObj:getChildAutoType("list_hero")
    otherObj.list = otherObj:getChildAutoType("list_hero")
    local combat = fightData.gamePlayInfo.playerInfo[1].combat
    local defCombat = fightData.gamePlayInfo.playerInfo[2].combat
    selfObj:getChildAutoType("txt_power"):setText(StringUtil.transValue(combat))
    otherObj:getChildAutoType("txt_power"):setText(StringUtil.transValue(defCombat))

    selfObj.list:setItemRenderer(function (idx1, obj1)
        local hd = selfHeros[idx1 + 1]
        local conf = hd.type == 1 and DynamicConfigData.t_hero[hd.code] or DynamicConfigData.t_monster[hd.code]
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
        ViewManager.open("BattledataView",{isWin = self.fightData[idx+1].result,isRecord = true,battleData = self.fightData[idx+1]})
    end, 22)
end

--战报回来
function StrideResultView:Battle_BattleRecordData(_, param)
    if (#self.fightData < #self.recordIds) then
		table.insert(self.fightData,param.battleData)
    end
    if (#self.fightData == #self.recordIds) then
        if (tolua.isnull(self.view)) then return end
		self:upGroupInfo()
	end
end

return StrideResultView