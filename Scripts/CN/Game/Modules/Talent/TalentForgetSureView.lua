-- add by zn
-- 遗忘确认提示

local TalentForgetSureView = class("TalentForgetSureView", Window)

function TalentForgetSureView:ctor()
    self._packName = "Talent"
    self._compName = "TalentForgetSureView"
    self._rootDepth = LayerDepth.Alert
end

function TalentForgetSureView:_initUI()
    local root = self
    local rootView = self.view
        root.btn_yes = rootView:getChildAutoType("btn_yes")
        root.btn_no = rootView:getChildAutoType("btn_no")

    if (self._args.cost) then
        local cost = self._args.cost
        local url = ItemConfiger.getItemIconByCode(cost.code)
        rootView:getChildAutoType("icon"):setIcon(url)
        rootView:getChildAutoType("amount"):setText(cost.amount)
    end
end

function TalentForgetSureView:_initEvent()
    self.btn_yes:addClickListener(function()
        local cb = self._args.onYes
        if (cb) then
            cb()
        end
        self:closeView()
    end)
    self.btn_no:addClickListener(function()
        local cb = self._args.noNo
        if (cb) then
            cb()
        end
        self:closeView()
    end)
end

return TalentForgetSureView