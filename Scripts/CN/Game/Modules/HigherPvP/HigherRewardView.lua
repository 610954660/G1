-- add by zn
-- 段位奖励界面

local HigherRewardView = class("HigherRewardView", Window)

function HigherRewardView: ctor()
    self._packName = "HigherPvP";
    self._compName = "HigherRewardView";
    self._rootDepth = LayerDepth.PopWindow;

    self.conf = DynamicConfigData.t_HPvPReward;
end

function HigherRewardView: _initUI()
    local root = self;
    local rootView = self.view;
        root.pageList = rootView:getChildAutoType("pageList");
        root.rewardList = rootView:getChildAutoType("rewardList");

    self.pageList:setSelectedIndex(0);
    self.pageList:addClickListener(function ()
        self:HigherPvp_upRankReward();
    end)
    self.rewardList:setItemRenderer(function (idx, obj)
        self:upRankRewardItem(idx, obj);
    end)
    self.rewardList:setVirtual();
    self:HigherPvp_upRankReward();
end

function HigherRewardView: HigherPvp_upRankReward()
    self.data = HigherPvPModel:getRankReward();
    if (self.pageList:getSelectedIndex() == 0) then
        self.rewardList:setNumItems(#self.data);
    else
        self.rewardList:setNumItems(#self.conf);
    end
    
end

function HigherRewardView: upRankRewardItem(idx, obj)
    local id = self.pageList:getSelectedIndex() == 0 and (self.data[idx + 1].id) or (#self.conf - idx);
    local state = self.pageList:getSelectedIndex() == 0 and (self.data[idx + 1].state) or false;
    local conf = self.conf[id];
    local rankConf = DynamicConfigData.t_HPvPRank[conf.id];
    local ctrl = obj:getController("c1");
    obj:getChildAutoType("txt_rankName"):setText(conf.name);
    obj:getChildAutoType("txt_score"):setText(string.format(Desc.HigherPvp_str1, conf.score));
    obj:getChildAutoType("loader_icon"):setIcon(string.format("Icon/rank/%s.png", rankConf.res));
    local list = obj:getChildAutoType("itemCellList");
    local itemList = self.pageList:getSelectedIndex() == 0 and conf.rankReward or conf.seasonReward;
    list:setItemRenderer(function (idx2, obj2)
        if (not obj2.itemCell) then
            obj2.itemCell = BindManager.bindItemCell(obj2);
        end
        local c = itemList[idx2 + 1];
        obj2.itemCell:setData(c.code, c.amount, c.type);
    end)
    list:setNumItems(#itemList);
    if (state) then
        ctrl:setSelectedIndex(state);
    else
        ctrl:setSelectedIndex(3);
    end

    local btn = obj:getChildAutoType("btn_get");
    btn:removeClickListener(222);
    btn:addClickListener(function ()
        print(2233, "----- 段位奖励领取 ---------", id);
        HigherPvPModel:getRankAward(id);
    end, 222)
end

return HigherRewardView;