-- add by zn
-- 排行奖励

local GLRankAwardView = class("GLRankAwardView", Window)

function GLRankAwardView:ctor()
    self._packName = "GuildLeague"
    self._compName = "GLRankAwardView"
    self.pageIndex = false;
    -- self._rootDepth = LayerDepth.PopWindow
end

function GLRankAwardView:_initUI()
    local root = self
    local rootView = self.view
        root.list_item = rootView:getChildAutoType("list_item")
        root.txt_desc = rootView:getChildAutoType("txt_desc")
end

function GLRankAwardView:onShow(pageIndex)
    self.pageIndex = pageIndex;
    local conf = DynamicConfigData.t_GLRank;
    local indexList = {};
    for id in ipairs(conf) do
        table.insert(indexList, id);
    end
    table.sort(indexList, function(a, b)
        return a > b;
    end)
    self.list_item:setVirtual()
    self.list_item:setItemRenderer(function(idx, obj)
        local id = indexList[idx + 1];
        local c = conf[id];
        local baseInfo = GuildLeagueModel:getBaseInfo();
        local isCur = baseInfo.score >= c.min and baseInfo.score <= c.max;
        self:upItemInfo(obj, c, isCur);
    end)
    self.list_item:setNumItems(#conf);
    local txt = pageIndex == 3 and Desc.GL_descStr2 or Desc.GL_descStr1;
    self.txt_desc:setText(txt);
end

function GLRankAwardView:upItemInfo(obj, data, isCur)
    obj:setIcon(PathConfiger.getRankLevelIcon(data.res));
    obj:setTitle(data.rank);
    obj:getChildAutoType("txt_star"):setText(data.min);
    local list_item = obj:getChildAutoType("list_item");
    local award = self.pageIndex == 3 and data.seasonReward or data.rankReward;
    list_item:setItemRenderer(function(idx, o)
        if (not o.cell) then
            o.cell = BindManager.bindItemCell(o);
        end
        local d = award[idx + 1];
        o.cell:setData(d.code, d.amount, d.type);
    end)
    list_item:setNumItems(#award);
    obj:getController("c1"):setSelectedIndex(isCur and 1 or 0);
end

return GLRankAwardView