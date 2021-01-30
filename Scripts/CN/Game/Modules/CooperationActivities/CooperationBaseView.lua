-- 协力活动入口 暂时没用的
local CooperationBaseView = class("CooperationBaseView", MutiWindow)

function CooperationBaseView:ctor()
    self._packName = "CooperationActivities"
    self._compName = "CooperationBaseView"
    self._tabBarName = "list_page"
    self._rootDepth = LayerDepth.Window
	self.__reloadPacket = true
	self._args.regCtrl = true
    self.pageView = false
    self.list_page = false
    self.frame = false
end

function CooperationBaseView:onShowPage(page)
    self.frame = self.view:getChildAutoType("frame")
    self.moneyBar:setData(
        {
            {type = GameDef.ItemType.Money, code = GameDef.MoneyType.Gold},
            {type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond}
        }
    )
    self.frame:getController("c3"):setSelectedIndex(0)
    if page == "CooperationActivitieMainView" then
        self:setBg("CooperationActivitieMain.jpg")
    elseif page == "CooperationActivitieCheatingView" then
        self:setBg("CooperationActivitieMain.jpg")
    elseif page == "CooperationActivitieShopView" then
        self.moneyBar:setData({})
        self.frame:getController("c3"):setSelectedIndex(1)
        self:setBg("CooperationActivitieMain.jpg")
    elseif page == "CooperationActivitieLimitView" then
		self:setBg("CooperationActivitieMain.jpg")
    else
		self:setBg("CooperationActivitieMain.jpg")
    end
end

function CooperationBaseView:_initPageList()
    self._tabBar = self.view:getChildAutoType("list_page")
    self._args.viewData = {}
    if (not ModuleUtil.getModuleOpenTips(ModuleId.CooperationActivitieMain.id)) then
        local info = {
            red = "",
            mid = ModuleId.CooperationActivitieMain.id,
            title = "领地协战",
            page = "CooperationActivitieMainView"
        }
        table.insert(self._args.viewData, info)
    end

    if (not ModuleUtil.getModuleOpenTips(ModuleId.CooperationActivitieCheating.id)) then
        local info = {
            red = "",
            mid = ModuleId.CooperationActivitieCheating.id,
            title = "支援助力",
            page = "CooperationActivitieCheatingView",
            size = 1
        }
        table.insert(self._args.viewData, info)
    end

    if (not ModuleUtil.getModuleOpenTips(ModuleId.CooperationActivitieShop.id)) then
        local info = {
            red = "",
            mid = ModuleId.CooperationActivitieShop.id,
            title = "物资兑换",
            page = "CooperationActivitieShopView",
            size = 1,
            icon = string.format("UI/MainSub/mainsub%s.png", ModuleId.CooperationActivitieShop.id)
        }
        table.insert(self._args.viewData, info)
    end

    if (not ModuleUtil.getModuleOpenTips(ModuleId.CooperationActivitieLimit.id)) then
        local info = {
            red = "",
            mid = ModuleId.CooperationActivitieLimit.id,
            title = "限时商城",
            page = "CooperationActivitieLimitView",
            size = 1,
            icon = string.format("UI/MainSub/mainsub%s.png", ModuleId.CooperationActivitieLimit.id)
        }
        table.insert(self._args.viewData, info)
    end

    self._tabBar:setItemRenderer(
        function(index, obj)
            local size = obj:getController("size")
            local icon = obj:getChildAutoType("icon")
            local d = self._args.viewData[index + 1]
            if d.red and d.red ~= "" then
                RedManager.register(d.red, obj:getChildAutoType("img_red"), d.mid)
            end
            obj:setTitle(d.title)
            if d.size then
                size:setSelectedIndex(d.size)
            end
            if d.icon then
                icon:setURL(d.icon)
            end
            --obj:setIcon("Icon/mainSub/"..d.mid..".png")
            --local icon = obj:getChildAutoType("icon")
            --icon:setScale(0.8,0.8)
        end
    )
    self._tabBar:setNumItems(#self._args.viewData)
    -- local needOpenPage = self._args.page
    -- if needOpenPage then
        --如里需要打开的窗口未到开放条件，打开第一个
        self._args.page = self._args.viewData[1].page
   -- end
end

function CooperationBaseView:_initUI()
	self.closeBtn = self.view:getChildAutoType("closeButton")
	self.closeBtn:addClickListener(function ( ... )
		self:closeView()
	end)
    self.pageView = self.view:getChildAutoType("pages")
    self.list_page = self.view:getChildAutoType("list_page")
    self._pageNode = self.view:getChildAutoType("frame"):getChildAutoType("contentNode")
    self:_initPageList()
end

return CooperationBaseView
