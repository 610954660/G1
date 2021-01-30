
-- 派遣提示

local VoidlandAssTipsView = class("VoidlandAssTipsView", Window)

function VoidlandAssTipsView:ctor()
    self._packName = "Voidland";
    self._compName = "VoidlandAssTipsView";
    self._rootDepth = LayerDepth.PopWindow;
end

function VoidlandAssTipsView:_initUI()
    local root = self;
    local rootView = self.view;
        root.heroCell = rootView:getChildAutoType("heroCell");
        root.btn_cancel = rootView:getChildAutoType("btn_cancel");
        root.btn_sure = rootView:getChildAutoType("btn_sure");

    local cell = BindManager.bindHeroCell(self.heroCell);
    if (self._args.data) then
        cell:setBaseData(self._args.data);
    end

    self.btn_cancel:addClickListener(function()
        self:closeView();
    end)

    self.btn_sure:addClickListener(function()
        local data = self._args.data;
        local idx = self._args.idx;
        if (data and idx) then
            VoidlandModel:hireFirend(data.friendId, data.uuid, idx);
        end
        self:closeView();
    end)
end

return VoidlandAssTipsView