-- add by zn
-- 公会联赛据点创建 只记录一组循环坐标，然后根据数据创建

local FortComponent = require "Game.Modules.GuildLeague.GLFortComponent"
local GLFortListView = class("GLFortListView", BindView)

function GLFortListView:ctor()
    self._packName = "GuildLeague"
    self._compName = "GLFortListView"
    -- self._rootDepth = LayerDepth.PopWindow
    self.circleLength = 0;
    self.posInfo = {};
    self.compList = {};
end

function GLFortListView:_initUI()
    local root = self
    local rootView = self.view
        local x = 1;
        while(true) do
            local view = rootView:getChildAutoType("pos"..x);
            if (view) then
                local pos = view:getPosition();
                table.insert(self.posInfo, pos);
                x = x + 1;
            else
                break;
            end
        end
        local pos1 = self.posInfo[1];
        local pos2 = self.posInfo[x - 1];
        self.circleLength = pos2.y - pos1.y + 200;
        for i = 1, 2 do
            local bg = rootView:getChildAutoType("bg"..i);
            root["bg"..i] = bg;
            bg:setIcon("Bg/GuildLeagueFort.jpg");
        end
end

function GLFortListView:_initEvent()
    self.view:addEventListener(FUIEventType.Scroll, (function(context, args)
        local winHeight = CCDirector:getInstance():getWinSize().height;
        for i = 1, 2 do
            local j = 3 - i;
            local curBg = self["bg"..i]
            local otherBg = self["bg"..j];
            local _, y = curBg:displayObject():getPosition();

            local worldPos = self:getWorldPos(curBg);
            if (worldPos.y >= 0 and worldPos.y <= winHeight) then
                y = y + otherBg:getHeight();
                otherBg:displayObject():setPositionY(y);
                break;
            elseif (worldPos.y > winHeight and worldPos.y < winHeight * 2) then
                y = y - otherBg:getHeight();
                otherBg:displayObject():setPositionY(y);
                break;
            end
        end
    end))
end

function GLFortListView:getWorldPos(comp)
    local obj = comp:displayObject();
    local parent = obj:getParent();
    if (parent) then
        local pos = parent:convertToWorldSpaceAR(cc.p(obj:getPosition()));
        return pos;
    end
    return cc.p(0, 0);
end

function GLFortListView:refreashWithData(data)
    if (tolua.isnull(self.view)) then
        return;
    end
    local posLen = #self.posInfo;
    local arr = {};
    for _, d in pairs(data) do
        arr[d.index] = d;
    end
    for i, d in ipairs(arr) do
        local idx = (i - 1) % posLen + 1;
        local page = math.floor((i - 1) / posLen);
        local pos = self.posInfo[idx];
        local y = pos.y + page * self.circleLength;
        if (not self.compList[i]) then
            local fort = FortComponent.new({parent = self.view});
            fort:toCreate(function(v)
                if (tolua.isnull(self.view)) then
                    return;
                end
                v.view:setPosition(pos.x, y);
                v:setData(d, i);
                self.compList[i] = v;
            end)
        else
            local fort = self.compList[i];
            fort:setData(d, i);
        end
    end
end

return GLFortListView