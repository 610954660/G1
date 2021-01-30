-- add by zn
-- 高阶竞技场编队额外控件
local AddHPvPPrebattleView = class("AddHPvPPrebattleView", Window);

function AddHPvPPrebattleView: ctor()
    self._packName = "HigherPvP";
    self._compName = "AddHPvPPrebattleView";
	self._rootDepth = LayerDepth.WindowUI;
    HigherPvPModel.curTeamIdx = 1;
    HigherPvPModel:checkTeamHasEmpty();
end

function AddHPvPPrebattleView: _initUI()
    local root = self;
    local rootView = self.view;
        root.list_team = rootView:getChildAutoType("list_team");
    local configType = BattleModel:getBattleArrayType()
    local showTop = WorldHighPvpModel:isWoroldHighPvpArrayType(configType) and 1 or HigherPvPModel.battleTeamType
    self.view:getController("c2"):setSelectedIndex(showTop);
    local teamArr = WorldHighPvpModel:isWoroldHighPvpArrayType(configType) and WorldHighPvpModel:getArrayType() or HigherPvPModel:getBattleTeamType();
    HigherPvPModel.curTeamIdx = 1;
    self.list_team:addClickListener(function (idx)
        if (self.list_team:getSelectedIndex() + 1 ~= HigherPvPModel.curTeamIdx) then
            -- HigherPvPModel: saveTeamInfo()
            HigherPvPModel.curTeamIdx = self.list_team:getSelectedIndex() + 1;
            Dispatcher.dispatchEvent("battle_highPvpChangeTeamType", teamArr[HigherPvPModel.curTeamIdx]);
        end
    end)

    local children = self.list_team:getChildren();
    for idx, obj in ipairs(children) do
        RedManager.register("HigherPvp_teamEmpty"..idx, obj:getChildAutoType("img_red"));
    end
end

function AddHPvPPrebattleView:HigherPvP_changeTeam(_, team)
    print(2233, "改变页签--------", self.list_team:getSelectedIndex() + 1, team);
    if (self.list_team:getSelectedIndex() + 1 ~= team) then
        -- HigherPvPModel: saveTeamInfo()
        HigherPvPModel.curTeamIdx = team;
        self.list_team:setSelectedIndex(team - 1);
        local configType = BattleModel:getBattleArrayType()
        local teamArr = WorldHighPvpModel:isWoroldHighPvpArrayType(configType) and WorldHighPvpModel:getArrayType() or HigherPvPModel:getBattleTeamType();
        Dispatcher.dispatchEvent("battle_highPvpChangeTeamType", teamArr[HigherPvPModel.curTeamIdx]);
    end
end

function AddHPvPPrebattleView: battle_canCel()
    -- HigherPvPModel: clearTeamInfo()
    ViewManager.close("AddHPvPPrebattleView")
end

function AddHPvPPrebattleView: battle_begin()
    if HigherPvPModel:battleCheckTeam(false) then
        return;
    end
    -- HigherPvPModel: clearTeamInfo()
    ViewManager.close("AddHPvPPrebattleView")
end


return AddHPvPPrebattleView