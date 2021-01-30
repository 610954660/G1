-- add by zn
-- 高阶竞技场比赛结果
local HigherPvPResultView = class("HigherPvPResultView", Window);

function HigherPvPResultView: ctor()
    self._packName = "HigherPvP";
    self._compName = "HigherPvPResultView";
    self._rootDepth = LayerDepth.PopWindow;
    self.isWin = self._args.isWin;
    self.gamePlayType = self._args.gamePlayType or GameDef.GamePlayType.HigherPvp
end

function HigherPvPResultView: _initUI()
    local root = self;
    local rootView = self.view;
        root.resultCtrl = rootView:getController("c1");
        root.txt_selfScore = rootView:getChildAutoType("txt_selfScore");
        root.txt_selfName = rootView:getChildAutoType("txt_selfName");
        root.txt_otherScore = rootView:getChildAutoType("txt_otherScore");
        root.txt_otherName = rootView:getChildAutoType("txt_otherName");
        root.txt_winCount = rootView:getChildAutoType("txt_winCount");
        root.list_group = rootView:getChildAutoType("list_group");
         root.shareBtn = rootView:getChildAutoType("shareBtn");
         
    CrossArenaPVPModel:setNeedPlay(false)
    if (#HigherPvPModel.fightData <= 0 and #HigherPvPModel.recordIds > 0) then
        for idx, recordIds in ipairs(HigherPvPModel.recordIds) do
            local info = {
                recordId     = recordIds.recordId,
                gamePlayType = self.gamePlayType
            }
			BattleModel:requestBattleRecord(recordIds.recordId)
        end
    else
        self:upGroupInfo()
    end
	
    local gamePlayType=self.gamePlayType
    if self.gamePlayType == GameDef.GamePlayType.CrossArena then
        self.shareBtn:setVisible(false)
    else
        self.shareBtn:addClickListener(function ()
			local params={
				gamePlayType=gamePlayType,
				fromBattleRecordType=3,
				recordId=HigherPvPModel.fightData[1].recordId,
			}
			local function success(data)
				params.serverId=self._args.serverId
					
				ViewManager.open("ShareVideoView",params)
			end
			RPCReq.BattleRecord_Share(params, success)
	end)
    end
	printTable(5656,self._args,"self._args.serverId")
	
	
end

function HigherPvPResultView: _initEvent()
    self._frame:addClickListener(function ()
        self:closeView();
    end)
end

function HigherPvPResultView: upGroupInfo()
    
    self.list_group:setItemRenderer(function (idx, obj)
        self:upGroupItem(idx, obj);
    end)
    self.list_group:setOpaque(false);
    self.list_group:setNumItems(#HigherPvPModel.fightData);
    self.resultCtrl:setSelectedIndex(self.isWin and 0 or 1);
    local winCount = 0;
    for _, data in ipairs(HigherPvPModel.fightData) do
        if (data.result) then
            winCount = winCount + 1;
        end
    end
    local loseCount = 3 - winCount;
    self.txt_winCount:setText(winCount..":"..loseCount);
    self.txt_selfName:setText(self._args.ackName);
    self.txt_otherName:setText(self._args.defName);
    local arrayType = self._args.arrayType
    local ctrl = self.view:getController("c2")
    if (arrayType and WorldHighPvpModel:isWoroldHighPvpArrayType(arrayType)) then
        ctrl:setSelectedIndex(0)
    else
        ctrl:setSelectedIndex(1)
        self.txt_selfScore:setText(self._args.ackAddScore < 0 and self._args.ackAddScore or "+"..self._args.ackAddScore);
        self.txt_selfScore:setColor(self.isWin and ColorUtil.textColor_Light.green or ColorUtil.textColor_Light.red);
        self.txt_otherScore:setText(self._args.defAddScore < 0 and self._args.defAddScore or "+"..self._args.defAddScore);
        self.txt_otherScore:setColor(self.isWin and ColorUtil.textColor_Light.red or ColorUtil.textColor_Light.green);
    end
end

function HigherPvPResultView: upGroupItem(idx, obj)
    obj:getController("c1"):setSelectedIndex(idx);
    if self.gamePlayType == GameDef.GamePlayType.CrossArena then
        
        obj:getChildAutoType("n12"):setText(Desc["common_team1"..(idx+1)])
    end

    local fightData = HigherPvPModel.fightData[idx + 1];
    local combats = HigherPvPModel.recordIds[idx + 1];
    local isWin = fightData.result;
    local data = fightData.battleObjSeq;
    local selfHeros = {};
    local otherHeros = {};
    for _, d in ipairs(data) do
        if (d.id < 200) then
            if (d.type == 1) then
                table.insert(selfHeros, d);
            end
        else
            if (d.type == 1 or d.type == 2) then
                table.insert(otherHeros, d);
            end
        end
    end

    local selfObj = obj:getChildAutoType("self");
    local otherObj = obj:getChildAutoType("other");
    selfObj:getController("c1"):setSelectedIndex(isWin and 0 or 1);
    otherObj:getController("c1"):setSelectedIndex(isWin and 1 or 0);
    selfObj.list = selfObj:getChildAutoType("list_hero");
    otherObj.list = otherObj:getChildAutoType("list_hero");
    
    local combat = 0
    local defCombat = 0
    if combats.combat then
        combat = combats.combat
        defCombat = combats.defCombat
    elseif fightData.gamePlayInfo.playerInfo[1].combat then
        combat = fightData.gamePlayInfo.playerInfo[1].combat
        defCombat = fightData.gamePlayInfo.playerInfo[2].combat
    end
    selfObj:getChildAutoType("txt_power"):setText(StringUtil.transValue(combat));
    otherObj:getChildAutoType("txt_power"):setText(StringUtil.transValue(defCombat));

    selfObj.list:setItemRenderer(function (idx1, obj1)
        local hd = selfHeros[idx1 + 1];
        local conf = DynamicConfigData.t_hero[hd.code]
        if (conf) then
            hd.category = conf.category
            local heroCell = BindManager.bindHeroCell(obj1);
            heroCell:setBaseData(hd);
        else
            printTable(2233, "============= 错误数据", hd, selfHeros);
        end
        local isAlive = hd.finalHp > 0;
        obj1:getController("grayCtrl"):setSelectedIndex(isAlive and 0 or 1);
    end)
    selfObj.list:setNumItems(#selfHeros);

    otherObj.list:setItemRenderer(function (idx2, obj2)
        local hd = otherHeros[idx2 + 1];
        local conf = hd.type == 1 and DynamicConfigData.t_hero[hd.code] or DynamicConfigData.t_monster[hd.code]
        if (conf) then
            hd.category = conf.category;
            local heroCell = BindManager.bindHeroCell(obj2);
            heroCell:setBaseData(hd);
        end
        local isAlive = hd.finalHp > 0;
        if (isAlive) then
            printTable(2233, hd);
        end
        obj2:getController("grayCtrl"):setSelectedIndex(isAlive and 0 or 1);
    end)
    otherObj.list:setNumItems(#otherHeros);

    local btn = obj:getChildAutoType("btn_details");
    btn:removeClickListener(22);
    btn:addClickListener(function ()
       -- ModelManager.BattleModel:updateBettleData(fightData);
        ViewManager.open("BattledataView",{isWin=fightData.result,isRecord=true,battleData=fightData});
    end, 22)
end

function HigherPvPResultView:Battle_BattleRecordData(_, param)
    if (#HigherPvPModel.fightData < #HigherPvPModel.recordIds) then
        HigherPvPModel:addFightData(param);
    end
    if (#HigherPvPModel.fightData == #HigherPvPModel.recordIds) then
        if (tolua.isnull(self.view)) then return end;
        self:upGroupInfo();
    end
end

return HigherPvPResultView;