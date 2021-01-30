--Date :2020-12-11
--Author : wyz
--Desc : 组队竞技 战斗记录（里面一层） 

local CrossTeamPVPRecordInView,Super = class("CrossTeamPVPRecordInView", Window)

function CrossTeamPVPRecordInView:ctor()
	--LuaLog("CrossTeamPVPRecordInView ctor")
	self._packName = "CrossTeamPVP"
	self._compName = "CrossTeamPVPRecordInView"
	self._rootDepth = LayerDepth.PopWindow
	
end

function CrossTeamPVPRecordInView:_initEvent( )
	
end

function CrossTeamPVPRecordInView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossTeamPVP.CrossTeamPVPRecordInView
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.list_group = viewNode:getChildAutoType('list_group')--GList
	self.shareBtn = viewNode:getChildAutoType('shareBtn')--GButton
	self.txt_myTeam = viewNode:getChildAutoType('txt_myTeam')--GTextField
	self.txt_otherTeam = viewNode:getChildAutoType('txt_otherTeam')--GTextField
	self.txt_winCount = viewNode:getChildAutoType('txt_winCount')--GTextField
	--{autoFieldsEnd}:CrossTeamPVP.CrossTeamPVPRecordInView
	--Do not modify above code-------------
end

function CrossTeamPVPRecordInView:_initUI( )
    self:_initVM()
    printTable(8848,">>>data>>>",self._args.data)
    CrossTeamPVPModel.interfaceTypeFlag = false
    -- 发送录像
	for idx, recordIds in ipairs(self._args.data.recordIds) do
		local info = {
			recordId     = recordIds,
			gamePlayType = GameDef.GamePlayType.HigherPvp
		}
		BattleModel:requestBattleRecord(recordIds)
	end
end

function CrossTeamPVPRecordInView:refreshPanel()
	-- 分享
	local gamePlayType=GameDef.GamePlayType.HigherPvp
	self.shareBtn:addClickListener(function ()
			local params={
				gamePlayType=gamePlayType,
				fromBattleRecordType=3,
				recordId=CrossTeamPVPModel.fightData[1].recordId,
			}
			local function success(data)
				ViewManager.open("ShareVideoView",params)
			end
			RPCReq.BattleRecord_Share(params, success)
    end)
    self:setList()
end

-- 设置列表信息
function CrossTeamPVPRecordInView:setList()
    self.list_group:setItemRenderer(function (idx, obj)
        local title = obj:getChildAutoType("title")
        title:setText(string.format(Desc.CrossTeamPVP_fightTipsNum,idx+1))
        self:upGroupItem(idx, obj);
    end)
    self.list_group:setOpaque(false);
	self.list_group:setNumItems(#CrossTeamPVPModel.fightData);

	local winCount = 0;
    for _, data in pairs(CrossTeamPVPModel.fightData) do
        if (data.result) then
            winCount = winCount + 1;
        end
	end
	local loseCount = 3 - winCount;
	self.txt_winCount:setText(winCount..":"..loseCount);
end

-- findType 1 是自己 2 是敌人
function CrossTeamPVPRecordInView:findName(findType,playerId) 
    local data = self._args.data
    data = findType == 1 and data.left or data.right
    for k,v in pairs(data.members) do
        if v.playerId == playerId then
            return v.name,v.fight
        end
    end
end

function CrossTeamPVPRecordInView:upGroupItem(idx, obj)
    local fightData = CrossTeamPVPModel.fightData[idx + 1];
    -- local combats = self._args.data.recordIds[idx + 1];
    local isWin     = fightData.result;
    local data      = fightData.battleObjSeq;
    local groupInfo = fightData.groupInfo;
    local gamePlayInfo  = fightData.gamePlayInfo
    local playerInfo    = gamePlayInfo.playerInfo
    local findCombat = function(playerId)
        for k,v in pairs(playerInfo) do
            if v.playerId == playerId then
                return  v.combat
            end
        end
    end
    printTable(8848,">>>groupInfo>>>",groupInfo)
    local selfGroupInfo     = groupInfo[1] or {}
    local otherGroupInfo    = groupInfo[2] or {}
    local selfHeros = {};
    local otherHeros = {};
    for _, d in ipairs(data) do
        if (d.id < 200) then
            if (d.type == 1 or d.type == 2) then
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
    selfObj:getController("checkWin"):setSelectedIndex(isWin and 0 or 1);
    otherObj:getController("checkWin"):setSelectedIndex(isWin and 1 or 0);
    selfObj.list = selfObj:getChildAutoType("list_hero");
    otherObj.list = otherObj:getChildAutoType("list_hero");
    
    local combat = 0
	local defCombat = 0
	local attackName,defName = "",""
  	-- if fightData.gamePlayInfo.playerInfo[1].combat then
    --     combat = fightData.gamePlayInfo.playerInfo[1].combat
    --     defCombat = fightData.gamePlayInfo.playerInfo[2].combat
	-- end
	-- if fightData.gamePlayInfo.playerInfo[1].name then
    --     attackName = fightData.gamePlayInfo.playerInfo[1].name
    --     defName = fightData.gamePlayInfo.playerInfo[2].name
    -- end
    attackName,combat  = self:findName(1,selfGroupInfo.playerId) 
    defName,defCombat  = self:findName(2,otherGroupInfo.playerId) 
	
    selfObj:getChildAutoType("txt_power"):setText(StringUtil.transValue(combat or 0));
	otherObj:getChildAutoType("txt_power"):setText(StringUtil.transValue(defCombat or 0));
	selfObj:getChildAutoType("txt_playerName"):setText(attackName);
    otherObj:getChildAutoType("txt_playerName"):setText(defName);

    selfObj.list:setItemRenderer(function (idx1, obj1)
        local hd = selfHeros[idx1 + 1];
        local conf = hd.type == 1 and DynamicConfigData.t_hero[hd.code] or DynamicConfigData.t_monster[hd.code]
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
            -- printTable(8848, hd);
        end
        obj2:getController("grayCtrl"):setSelectedIndex(isAlive and 0 or 1);
    end)
    otherObj.list:setNumItems(#otherHeros);

    local btn_details = obj:getChildAutoType("btn_details");
    btn_details:removeClickListener(22);
    btn_details:addClickListener(function ()
        ViewManager.open("BattledataView",{isWin=fightData.result,isRecord=true,battleData=fightData});
    end, 22)
end




-- 接收录像战报
function CrossTeamPVPRecordInView:Battle_BattleRecordData(_, param)
    if (#CrossTeamPVPModel.fightData < #self._args.data.recordIds) then
        CrossTeamPVPModel:addFightData(param);
    end
    if (#CrossTeamPVPModel.fightData == #self._args.data.recordIds) then
        if (tolua.isnull(self.view)) then return end;
        self:refreshPanel();
    end
end

function CrossTeamPVPRecordInView:_exit()
    CrossTeamPVPModel:clearFightData()
    CrossTeamPVPModel.interfaceTypeFlag = true
end




return CrossTeamPVPRecordInView