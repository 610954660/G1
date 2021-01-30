-- add by zn
-- 公会联赛宝库奖励预览

local GuildLeagueTreasureView = class("GuildLeagueTreasureView", Window)

function GuildLeagueTreasureView:ctor()
    self._packName = "GuildLeague"
    self._compName = "GuildLeagueTreasureView"
    self.page = 0; -- 当前段位所在页
end

function GuildLeagueTreasureView:_initUI()
    local root = self
    local rootView = self.view
        root.list_tab = rootView:getChildAutoType("list_tab");
        root.list_item = rootView:getChildAutoType("list_item");

    self.rankIndex = GuildLeagueModel:getBaseInfo().scoreRank or 0;
    local data = self:getAwardConf();
    self.list_tab:setItemRenderer(function(idx, obj)
        obj:setTitle(Desc["GL_rank"..(idx + 1)]);
    end)
    self.list_tab:setNumItems(#data);
    self.list_tab:setSelectedIndex(self.page);
    self.list_tab:removeClickListener();
    self.list_tab:addClickListener(function()
        local idx = self.list_tab:getSelectedIndex();
        self:upList(data[idx + 1]);
    end)
    self:upList(data[self.page + 1]);
end

function GuildLeagueTreasureView:upList(dataArr)
    self.list_item:setItemRenderer(function(idx, obj)
        local data = dataArr[idx + 1];
        local icon = obj:getChildAutoType("rankIcon");
        local txt_rankName = obj:getChildAutoType("txt_rankName");
        icon:setIcon(PathConfiger.getRankLevelIcon(data.res));
        txt_rankName:setText(data.rank);
        for i = 1, 2 do
            local list_award = obj:getChildAutoType("list_award"..i);
            local awardList = i == 1 and data.treasury or data.treasuryRandom;
            list_award:setItemRenderer(function(idx1, obj1)
                if (not obj1.cell) then
                    obj1.cell = BindManager.bindItemCell(obj1);
                end
                local d = awardList[idx1 + 1];
                obj1.cell:setData(d.code, d.amount, d.type);
            end)
            list_award:setNumItems(#awardList);
        end
        local c1 = obj:getController("c1");
        c1:setSelectedIndex(data.index == self.rankIndex and 1 or 0);
    end)
    self.list_item:setNumItems(#dataArr)
end

function GuildLeagueTreasureView:getAwardConf()
    local conf = DynamicConfigData.t_GLRank;
    local info = {}
    for idx, data in ipairs(conf) do
        if (not info[data.res]) then
            info[data.res] = {}
        end
        if (self.rankIndex == data.index) then
            self.page = data.res - 1;
        end
        table.insert(info[data.res], data);
    end
    for _, arr in ipairs(info) do
        table.sort(arr, function(a, b)
            return a.index > b.index
        end)
    end
    return info
end

return GuildLeagueTreasureView