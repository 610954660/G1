-- add by zn
-- 宝箱奖励

local GLBoxView = class("GLBoxView", Window)

function GLBoxView:ctor()
    self._packName = "GuildLeague"
    self._compName = "GLBoxView"
    -- self._rootDepth = LayerDepth.PopWindow
    self.actCD = false
end

function GLBoxView:_initUI()
    local root = self
    local rootView = self.view
        self.list_box = rootView:getChildAutoType("list_box");
        self.txt_cd = rootView:getChildAutoType("txt_cd");
        self.txt_desc = rootView:getChildAutoType("txt_desc");
        self.list_box:setVirtual()

    GuildLeagueModel:getBoxInfo()
end

function GLBoxView:_refresh()
    GuildLeagueModel:getBoxInfo()
end

function GLBoxView:GuildLeague_boxInfoUpdate()
    local boxInfo = GuildLeagueModel.boxInfos;
    local c1 = self.view:getController("c1")
    if (not boxInfo or not next(boxInfo)) then
        c1:setSelectedIndex(0);
        return;
    else
        c1:setSelectedIndex(1);
    end
    local canReceive = boxInfo.rewardStatus or 0; -- 0 不可领取 1 可领 2已领
    local baseInfo = GuildLeagueModel:getBaseInfo();
    local rankConf = DynamicConfigData.t_GLRank[baseInfo.scoreRank];
    local boxConf = rankConf and rankConf.boxId[1] or {}
    local boxId = boxInfo.result and boxConf.win or boxConf.lose;
    -- local actStatus = baseInfo.actStatus or 0;
    if (canReceive == 1) then
        local time = math.ceil(math.abs(baseInfo.nextActStamp - ServerTimeModel:getServerTimeMS()) / 1000)
        self:starCD(time, Desc.GL_descStr3);
    else
        if (self.actCD) then
            TimeLib.clearCountDown(self.actCD);
            self.actCD = false;
        end
        self.txt_cd:setText("");
    end

    local gotMap = {};
    for _, d in pairs(boxInfo.recordMap) do
        if (d.boxIndex) then
            gotMap[d.boxIndex] = d;
        end
    end
    self.list_box:setItemRenderer(function(idx, obj)
        local gotInfo = gotMap[idx + 1]
        local c1 = obj:getController("c1");
        obj:removeClickListener(888);
        if (gotInfo) then
            c1:setSelectedIndex(1);
            local name = gotInfo.playerId == tonumber(PlayerModel.userid) and string.format("[color=#CA5600]%s[/color]",gotInfo.name) or gotInfo.name
            obj:getChildAutoType("txt_name"):setText(name);

            if not obj.itemCell then
                obj.itemCell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"));
            end
            local a = gotInfo.rewardList[1]
            obj.itemCell:setData(a.code, a.amount, a.type);
        else
            c1:setSelectedIndex(0);
            obj:removeClickListener(888)
            obj:addClickListener(function()
                if (canReceive == 1) then
                    GuildLeagueModel:getBoxAward(idx + 1)
                elseif canReceive == 0 then
                    RollTips.show(Desc.GL_box0);
                else
                    RollTips.show(Desc.GL_box1);
                end
            end, 888);
        end
        local boxUrl = PathConfiger.getItemIcon(boxId or "");
        obj:getChildAutoType("loaderBox"):setIcon(boxUrl);
    end)
    self.list_box:setNumItems(boxInfo.boxNum);
end

function GLBoxView:starCD(time, formatStr)
    if (not time) then
        return;
    end
    if (self.actCD) then
        TimeLib.clearCountDown(self.actCD);
        self.actCD = false;
    end
    local fmat = function(t)
        if (t > 86400) then
            return TimeLib.GetTimeFormatDay(t);
        else
            return TimeLib.formatTime(t, true);
        end
    end
    local onCD = function(t)
        self.txt_cd:setText(string.format(formatStr, fmat(t)));
    end
    local onEnd = function()
        GuildLeagueModel:requestBaseInfo();
        GuildLeagueModel:getBoxInfo()
    end
    self.actCD = TimeLib.newCountDown(time, onCD, onEnd, false, false, false);
    self.txt_cd:setText(string.format(formatStr, fmat(time)));
end

function GLBoxView:_exit()
    if (self.actCD) then
        TimeLib.clearCountDown(self.actCD);
        self.actCD = false;
    end
end

return GLBoxView