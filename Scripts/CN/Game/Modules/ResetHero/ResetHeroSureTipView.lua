-- add by zn
-- description

local ResetHeroSureTipView = class("ResetHeroSureTipView", Window)

function ResetHeroSureTipView:ctor()
    self._packName = "ResetHero"
    self._compName = "ResetHeroSureTipView"
    self._rootDepth = LayerDepth.PopWindow
end

function ResetHeroSureTipView:_initUI()
    local root = self
    local rootView = self.view
        root.txt_desc= rootView:getChildAutoType("txt_desc");
        root.noBtn = rootView:getChildAutoType("noBtn");
        root.yesBtn = rootView:getChildAutoType("yesBtn");
end

function ResetHeroSureTipView:_initEvent()
    self.txt_desc:setText(self._args.text);
    self.yesBtn:addClickListener(function ()
        local onYes = self._args.onYes;
        if (onYes) then onYes() end;
        self:closeView();
    end)

    self.noBtn:addClickListener(function ()
        self:closeView();
    end)
end

return ResetHeroSureTipView