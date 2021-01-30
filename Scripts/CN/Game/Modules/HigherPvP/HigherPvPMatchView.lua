-- add by zn
-- 高阶竞技场匹配界面

local HigherPvPMatchView = class("HigherPvPMatchView", Window)

function HigherPvPMatchView: ctor()
    self._packName = "HigherPvP";
    self._compName = "HigherPvPMatchView";
    self._rootDepth = LayerDepth.PopWindow;
    self.data = false;
	self.skipArray =false
end

function HigherPvPMatchView: _initUI()
    local root = self;
        root.list_challenge = self.view:getChildAutoType("challengeList");
        root.btn_addTicket = self.view:getChildAutoType("addTicket");
        root.btn_refresh = self.view:getChildAutoType("refreshBtn");
        root.leftTicket = self.view:getChildAutoType("leftTicket");
        root.txt_myCombat = self.view:getChildAutoType("txt_myCombat");
    root.list_challenge:setItemRenderer(function (idx, obj)
        self:upChallengeItem(idx, obj);
    end)
    HigherPvPModel:getChallengeList();

	self.skipToggle=self.view:getChildAutoType("skipToggle")
	self.skipToggle:addClickListener(function ()
			local notfight,desc= ModuleUtil.checkNotFight(GameDef.BattleArrayType.HigherPvpAckOne)	
			if not notfight then
				RollTips.show(desc)
				self.skipToggle:setSelected(false)
				return 
			end
			
			self.skipArray = self.skipToggle:isSelected()
			PataModel:saveSkipArray(GameDef.BattleArrayType.HigherPvpAckOne, self.skipArray)
	end)
	if PataModel:checkSkipArray(GameDef.BattleArrayType.HigherPvpAckOne) then
		self.skipToggle:setSelected(true)
		self.skipArray =true
	end
	
	
	
    local myCombat = HigherPvPModel:getAllBattleCombat() or 0;
    self.txt_myCombat:setText(StringUtil.transValue(myCombat));
    self.view:getChildAutoType("ticketIcon"):setIcon(ItemConfiger.getItemIconByCode(10000063, CodeType.ITEM, false))
    -- root.list_challenge:addClickListener(function (contest)
        -- printTable(2233, root.list_challenge:getSelectedIndex());
    -- end)
    self:pack_item_change();
end

function HigherPvPMatchView: pack_item_change(_, param)
    local cost = DynamicConfigData.t_HPvPConst[1].buyTicket[1];
    if (cost) then
        self.leftTicket:setText(PackModel:getItemsFromAllPackByCode(cost.code));
    end
end

function HigherPvPMatchView: _initEvent()
    self.btn_refresh:addClickListener(function ()
        HigherPvPModel:getChallengeList();
    end)

    self.btn_addTicket:addClickListener(function ()
        ViewManager.open("HigherPvPTicketView");
    end)
end

function HigherPvPMatchView: HigherPvp_upChallengeList(_, param)
    self.data = param;
    self.list_challenge:setNumItems(#param);
end

function HigherPvPMatchView: upChallengeItem(idx, obj)
    local selfInfo = HigherPvPModel.selfInfo;
    local data = self.data[idx + 1];
    if (not obj.playerCell) then
        obj.playerCell = BindManager.bindPlayerCell(obj:getChildAutoType("heroCell"));
    end
    obj.playerCell:setHead(data.head, data.level, data.playerId,nil,data.headBorder);
    obj:getChildAutoType("fightCap"):setText(Desc.materialCopy_str5..StringUtil.transValue(data.combat));
    local addScore = HigherPvPModel:getScoreAddByWin(selfInfo.score, data.score);
    obj:getChildAutoType("score"):setText("+"..addScore);
    obj:getChildAutoType("name"):setText(data.name);
    local loader_btnIcon = obj:getChildAutoType("cosumBtn/itemIcon");
    loader_btnIcon:setIcon(ItemConfiger.getItemIconByCode(10000063, CodeType.ITEM, false))

    local btn = obj:getChildAutoType("cosumBtn");
    local btnTitle = selfInfo.freeTimes > 0 and Desc.HigherPvP_freedom or "x1";
    btn:setTitle(btnTitle)
    btn:removeClickListener(222);
    btn:addClickListener(function (context)
        context:stopPropagation()
        local cost = DynamicConfigData.t_HPvPConst[1].buyTicket[1];
        if (selfInfo.freeTimes <= 0 and PackModel:getItemsFromAllPackByCode(cost.code) <= 0) then
            ViewManager.open("HigherPvPTicketView");
            return;
        end
        HigherPvPModel:battleBegin(data.playerId, data.name);
        self:closeView();
    end, 222);

    obj:removeClickListener(222);
    obj:addClickListener(function ()
        ViewManager.open("HigherPvPPlayerInfoView", data);
    end, 222);
end


return HigherPvPMatchView;