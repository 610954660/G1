-- add by zn
-- 段位提升
local HigherPvPUpRankView = class("HigherPvPUpRankView", Window);

function HigherPvPUpRankView: ctor()
    self._packName = "HigherPvP";
    self._compName = "HigherPvPUpRankView";
    self._rootDepth = LayerDepth.PopWindow;
    self.timers = {};
end

function HigherPvPUpRankView: _initUI()
    local root = self;
    local rootView = self.view;
        root.rankIcon = rootView:getChildAutoType("rankIcon");
        root.rankName = rootView:getChildAutoType("rankName");
        root.titleEff = rootView:getChildAutoType("titleEff");
        root.rankEff = rootView:getChildAutoType("rankEff");
        root.rankEffUp = rootView:getChildAutoType("rankEffUp");

    local rankIndex = self._args.curRank;
    local conf = DynamicConfigData.t_HPvPRank[rankIndex];
    self.rankIcon:setIcon(string.format("Icon/rank/%s.png", conf.res));
    self.rankName:setText(string.format(Desc["HigherPvP_rankColor"..conf.res], conf.rank));
    self.view:getTransition("t0"):play(function()
    end)
    
    -- SpineUtil.createSpineObj(self.rankEff, cc.p(x1, y1), "duanweitisheng_down_loop", "Effect/UI", "efx_gaojiejingjichang", "efx_gaojiejingjichang", true);
    -- SpineUtil.createSpineObj(self.rankEffUp, cc.p(x1, y1), "duanweitisheng", "Spine/ui/jiesuan", "efx_jiesuan", "efx_jiesuan", true);

    -- 标题
    self.timers[1] = Scheduler.schedule(function()
        if (tolua.isnull(self.view)) then return end;
        local x2 = self.titleEff:getWidth() / 2;
        local y2 = self.titleEff:getHeight() / 2;
        local sp = SpineUtil.createSpineObj(self.titleEff, cc.p(x2, y2), "duanweitisheng", "Spine/ui/jiesuan", "efx_jiesuan", "efx_jiesuan", false);

        self.timers[1] = Scheduler.schedule(function()
            if (tolua.isnull(self.view)) then return end;
            sp:removeFromParent();
            SpineUtil.createSpineObj(self.titleEff, cc.p(x2, y2), "duanweitisheng_loop", "Spine/ui/jiesuan", "efx_jiesuan", "efx_jiesuan", true);
        end, 1.1, 1)
    end, 0.1, 1);

    -- 段位底
    self.timers[2] = Scheduler.schedule(function()
        if (tolua.isnull(self.view)) then return end;
        local x1 = self.rankEffUp:getWidth() / 2;
        local y1 = self.rankEffUp:getHeight() / 2;
        local sp1 = SpineUtil.createSpineObj(self.rankEff, cc.p(x1, y1), "duanweitisheng_down", "Effect/UI", "efx_gaojiejingjichang", "efx_gaojiejingjichang", false);
        local sp2 = SpineUtil.createSpineObj(self.rankEffUp, cc.p(x1, y1), "duanweitisheng_up", "Effect/UI", "efx_gaojiejingjichang", "efx_gaojiejingjichang", false);

        self.timers[2] = Scheduler.schedule(function()
            if (tolua.isnull(self.view)) then return end;
            sp1:removeFromParent();
            sp2:removeFromParent();
            SpineUtil.createSpineObj(self.rankEff, cc.p(x1, y1), "duanweitisheng_down_loop", "Effect/UI", "efx_gaojiejingjichang", "efx_gaojiejingjichang", true);
        end, 1.05, 1)
    end, 0.1, 1);
end

return HigherPvPUpRankView