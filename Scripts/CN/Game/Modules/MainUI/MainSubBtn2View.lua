-- 主界面铳梦竞技入口 
-- 1-1-铳梦竞技内有的内容有：1-竞技场、2-世界擂台赛、3-天境赛、4-天域试炼
-- 1-2-跨服竞技内的内容有：1-先驱组队竞技、2-跨服竞技、3-天梯赛
-- 1-3-月摄殿堂保持原有的不变
--1 -4

local MainSubBtn2View = class("MainSubBtn2View", MutiWindow)

function MainSubBtn2View:ctor()
    self._packName = "MainSubBtn"
    self._compName = "MainSubBtn2View"
	self._tabBarName = "list_page"
	self._rootDepth = LayerDepth.Window
	self._showParticle=true
	self.__reloadPacket = true
	self.pageView = false
	self.list_page = false
	self.frame = false
	self.redArr = {
		-- "V_MAIN_SHILAIN",
		"v_ArneaMain",
		-- "V_RELICCOPYRED",
		"V_MOONAWETEMPLE", 	-- 月慑神殿
	}

end

function MainSubBtn2View:onShowPage(page)
	self.frame = self.view:getChildAutoType("frame")
	self.moneyBar:setData({
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Gold},
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond},
	})
	self.frame:getController("c3"):setSelectedIndex(0)
	if page == "WorldChallengeView" then
		self:setBg("worldchallengeArena.jpg")
		--self.list_btns:setVisible(false)
	elseif page == "RelicCopyView" then
		self:setBg("reliccopybg.jpg")
		if RelicCopyModel.lastBattleArrayType and FightManager.isOnBack(RelicCopyModel.lastBattleArrayType) then
			ViewManager.backToBattleView(RelicCopyModel.lastBattleArrayType)
		end
		--self.list_btns:setVisible(false)
	elseif page == "MoonAweTempleView" then
		self.moneyBar:setData({})
		self.frame:getController("c3"):setSelectedIndex(1)
		self:setBg("pveStarTemplebg1.jpg")
	elseif page == "CrossTabView" then
		self:setBg("CrossTabView_bg.png")
	else
		self:setBg("main_sub_bg.jpg")
		--self.list_btns:setVisible(true)
	end
end

function MainSubBtn2View: _initPageList()
	self._tabBar = self.view:getChildAutoType("list_page")
	self._args.viewData = {}
	local info = {
		red= "v_ArneaMain",
		mid= ModuleId.Arena.id,
		title = Desc.MainSubBtnView_2,
		page="WorldChallengeView",
		size = 1,
		icon = string.format("UI/MainSub/mainsub%s.png", ModuleId.Arena.id),
	}
	table.insert(self._args.viewData, info);
	

	if (not ModuleUtil.getModuleOpenTips(ModuleId.MoonAweTemple.id)) then
        local info = {
            red = "V_MOONAWETEMPLE",
            mid = ModuleId.MoonAweTemple.id,
            title = Desc.MainSubBtnView_4,
            page = "MoonAweTempleView",
			battlePoint="V_MOONAWETEMPLEPOINT",
			battleType = GameDef.BattleArrayType.HeroTrial,
			size = 1,
			icon = string.format("UI/MainSub/mainsub%s.png", ModuleId.MoonAweTemple.id),
        }
        table.insert(self._args.viewData, info)
	end

	local info = {
		red = "M_CROSS_AREAN",
		--mid = ModuleId.CrossArena.id,
		title = Desc.MainSubBtnView_5,
		page = "CrossTabView",
		size = 1,
		icon = string.format("UI/MainSub/mainsub%s.png", ModuleId.CrossArena.id),
	}
	table.insert(self._args.viewData, info)
		

	self._tabBar:setItemRenderer(function(index, obj)
		local size = obj:getController("size")
		local icon = obj:getChildAutoType("icon")
		local d = self._args.viewData[index + 1];
		if d.red and d.red ~= "" then
			RedManager.register(d.red, obj:getChildAutoType("img_red"), d.mid);
		end
		local image_battle = obj:getChildAutoType("image_battle")
		if d.battleType then
			--obj:getChildAutoType("image_battle"):removeAllChildren()
			--image_battle:setVisible(true)
			SpineUtil.createBattleFlag(image_battle)
			RedManager.register(d.battleType, image_battle)
		else
			RedManager.register("" , image_battle)
		end
		obj:setTitle(d.title);
		if d.size then
			size:setSelectedIndex(d.size)
		end
		if d.icon then
			icon:setURL(d.icon)
		end
		--obj:setIcon("Icon/mainSub/"..d.mid..".png")
		--local icon = obj:getChildAutoType("icon")
		--icon:setScale(0.8,0.8)
	end)
	self._tabBar:setNumItems(#self._args.viewData)
	
	local needOpenPage = self._args.page
	if needOpenPage then
		--如里需要打开的窗口未到开放条件，打开第一个
		local exist = false
		for _,v in ipairs(self._args.viewData) do
			if needOpenPage == v.page then
				exist = true
				break
			end
		end
		if not exist then
			self._args.page = self._args.viewData[1].page
		end
	else
		self._args.page = self._args.viewData[1].page
	end
end

function MainSubBtn2View:_initUI( )
	self:_initVM()
	self.pageView = self.view:getChildAutoType("pages")
	self.list_page = self.view:getChildAutoType("list_page")
	self._pageNode = self.view:getChildAutoType("frame"):getChildAutoType("contentNode")
	self:_initPageList();
	CrossPVPModel:get_RankData()
end
function MainSubBtn2View:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	vmRoot.SubBtnView = viewNode:getChildAutoType("SubBtnView");
end

return MainSubBtn2View