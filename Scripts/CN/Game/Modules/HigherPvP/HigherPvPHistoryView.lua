-- add by zn
-- 高阶竞技场战斗记录

local HigherPvPHistoryView = class("HigherPvPHistoryView", Window);

function HigherPvPHistoryView: ctor()
    self._packName = "HigherPvP";
    self._compName = "HigherPvPHistoryView";
    self._rootDepth = LayerDepth.PopWindow;
    self.data = false;
end

function HigherPvPHistoryView:_initUI()
    local root = self;
    local rootView = self.view;
        root.recordList = rootView:getChildAutoType("$recordList");
        root.ctrl = rootView:getController("c1");

    self.recordList:setItemRenderer(function (idx, obj)
        self:upItem(idx, obj);
    end)
    HigherPvPModel:getHistoryList();
end

function HigherPvPHistoryView: HigherPvp_upHistoryList(_, param)
    self.data = param;
    if (#self.data > 0) then
        self.recordList:setNumItems(#self.data)
        self.ctrl:setSelectedIndex(1);
    else
        self.ctrl:setSelectedIndex(0);
    end
    
end

function HigherPvPHistoryView:upItem(idx, obj)
    local data = self.data[idx + 1];
    if (not obj.playerCell) then
        obj.playerCell = BindManager.bindPlayerCell(obj:getChildAutoType("heroCell"));
    end
    obj.playerCell:setHead(data.head, data.level,nil,nil,data.headBorder);
    obj:getChildAutoType("fightCap"):setText(StringUtil.transValue(data.combat));
    local score = data.addScore >= 0 and string.format("[color=%s]+%d[/color]",ColorUtil.textColorStr.green, data.addScore) or string.format("[color=%s]%d[/color]",ColorUtil.textColorStr.red, data.addScore)
    obj:getChildAutoType("score"):setText(score);
    obj:getChildAutoType("name"):setText(data.name);

    local recordBtn = obj:getChildAutoType("recordBtn");
    recordBtn:removeClickListener(223);
    recordBtn:addClickListener(function ()
        local const = DynamicConfigData.t_HPvPConst[1];
        local args = {
            fightID= const.fightId,
            configType= GameDef.BattleArrayType.HigherPvpAckOne,
        }
        BattleModel:setBattleConfig(args);
        HigherPvPModel:clearFightData();
        HigherPvPModel.recordIds = data.recordIds;
        local info = {
            -- isWin = data.addScore > 0, --
            ackName = data.isAttack and PlayerModel.username or data.name,
            ackAddScore = data.isAttack and data.addScore or data.adddefScore, 
            defName = data.isAttack and data.name or PlayerModel.username,
            defAddScore = data.isAttack and data.adddefScore or data.addScore, 
            -- otherId = data.enemyId,
        }
        if (data.isAttack) then
            info.isWin = data.addScore > 0
        else
            info.isWin = data.addScore < 0
        end
        ViewManager.open("HigherPvPResultView", info);
    end, 223)

    local cosumBtn = obj:getChildAutoType("cosumBtn");
    local btnTitle = HigherPvPModel.selfInfo.freeTimes > 0 and Desc.HigherPvP_freedom or "x1";
    cosumBtn:setTitle(btnTitle);
    data.revengeTimes = data.revengeTimes or 0
    local showFlag = data.addScore < 0 and data.revengeTimes == 0;
    cosumBtn:setVisible(showFlag);
    cosumBtn:removeClickListener(224);
    cosumBtn:addClickListener(function ()
        HigherPvPModel:battleBegin(data.enemyId, data.name, data.idx);
    end)
    
    local loader_btnIcon = cosumBtn:getChildAutoType("itemIcon");
    loader_btnIcon:setIcon(ItemConfiger.getItemIconByCode(10000063, CodeType.ITEM, false))
end

return HigherPvPHistoryView;