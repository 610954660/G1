--added by xhd 主界面view
local SubBtnView = class("SubBtnView", Window)
function SubBtnView:ctor()
	self._packName = "MainSubBtn"
	self._compName = "SubBtnView"
	self._rootDepth = LayerDepth.Window
	self.__reloadPacket = true
	self._isFullScreen = true
	self._showParticle = true
	
	self.list_btns = false
	self._tabBar = false
	
	self._subBtnData = {
	--{name = "btn_pata", icon = "", redType = "V_TOWER", battleType="V_PATA",mid = ModuleId.Tower.id},
	--{name = "btn_heroPalace", icon = "", redType = "M_HEROPALACE", mid = ModuleId.HeroPalace.id},
	{name = "btn_maze", icon = "", redType = "M_MAZE",battleType=GameDef.BattleArrayType.Maze, mid = ModuleId.Maze.id},
	--{name = "btn_arena", icon = "", redType = "v_ArneaMain",battleType=GameDef.BattleArrayType.ArenaAck, mid = ModuleId.Arena.id},
	{name = "btn_fraiyLand", icon = "", redType = "M_FAIRYLAND", battleType=GameDef.BattleArrayType.FairyLand,mid = ModuleId.FairyLand.id},
	{name = "btn_copy", icon = "", redType = "M_MATERIALCOPYRED", battleType=GameDef.BattleArrayType.Copy,mid = ModuleId.Copy.id},
	{name = "btn_endlessRoad", icon = "", redType = "M_ENDLESSROAD", battleType=GameDef.BattleArrayType.EndlessRoad,mid = ModuleId.EndlessRoad.id},
	--{name = "btn_endlessTrial", icon = "", redType = "M_ENDLESSTRIAL", battleType="V_Voidland",mid = ModuleId.EndlessTrial.id},
	{name = "btn_pveStarTemple", icon = "", redType = "V_PVESTARTEMPLE",battleType=GameDef.BattleArrayType.PveStarTemple, mid = ModuleId.PveStarTemple.id},
	{name = "btn_voidland", icon = "", redType = "V_VOIDLAND",battleType="V_EndlessTrial", mid = ModuleId.Voidland.id},
	{name = "btn_boundaryMap", icon = "", redType = "V_Boundary",battleType=GameDef.BattleArrayType.Boundary, mid = ModuleId.BoundaryMapView.id}
	}
	self._args.regCtrl = true
	self.voidlandBtn = false

	self.boundaryDesc1 = false
	self.boundaryDesc2 = false
	self.timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.update),1, false)
end
function SubBtnView:update()
	if self.boundaryDesc1 and self.boundaryDesc2 then
		self:doTimeShow()
	end
end
function SubBtnView:_initPageList()
	--[[self._tabBar = self.view:getChildAutoType("list_page")
	self._args.viewData = {}
	if (not ModuleUtil.getModuleOpenTips(ModuleId.DailyPlay.id)) then
		local info = {
		red = "",
		mid = ModuleId.DailyPlay.id,
		title = "日常玩法",
		page = ""
		}
		table.insert(self._args.viewData, info)
	end
	local info = {
	red = "v_ArneaMain",
	mid = ModuleId.Arena.id,
	title = "铳梦竞技",
	page = "WorldChallengeView"
	}
	table.insert(self._args.viewData, info)
	if (not ModuleUtil.getModuleOpenTips(ModuleId.RelicCopy.id)) then
		local info = {
		red = "V_RELICCOPYRED",
		mid = ModuleId.RelicCopy.id,
		title = "种族神殿",
		page = "RelicCopyView"
		}
		table.insert(self._args.viewData, info)
	end
	self._tabBar:setItemRenderer(
	function (index, obj)
		local d = self._args.viewData[index + 1]
		if d.red and d.red ~= "" then
			RedManager.register(d.red, obj:getChildAutoType("img_red"), d.mid)
		end
		obj:setTitle(d.title)
		-- local icon = obj:getChildAutoType("icon")
		--obj:setIcon("Icon/mainSub/"..d.mid..".png")
		--local icon = obj:getChildAutoType("icon")
		--icon:setScale(0.8,0.8)
	end
	)
	self._tabBar:setNumItems(#self._args.viewData)
	self._args.page = self._args.viewData[1].page--]]
end

-- [子类重写] 初始化UI方法
function SubBtnView:_initUI(...)
	-- self:setBg("main_sub_bg.jpg")
	local viewRoot = self.view
	
	self:_initPageList()
	self.list_btns = viewRoot:getChildAutoType("list_btns")
	self.list_btns:setItemRenderer(
	function (index, obj)
		for _, v in ipairs(self._subBtnData) do
			local btn = obj:getChildAutoType(v.name)
			RedManager.register(v.redType, btn:getChildAutoType("img_red"), v.mid)
			if v.mid then
				btn:getChildAutoType("img_lock"):setVisible(not ModuleUtil.moduleOpen(v.mid, false))
				btn:getChildAutoType("mark"):setVisible(not ModuleUtil.moduleOpen(v.mid, false))
			end
			if v.battleType then
			    RedManager.register(v.battleType, btn:getChildAutoType("image_battle"))
				SpineUtil.createBattleFlag(btn:getChildAutoType("image_battle"))
		    end
			
			btn:removeClickListener(100)
			btn:addClickListener(
			function ()
				self:onBtnClick(v.name)
			end,
			100
			)
			
			if (v.name == "btn_voidland") then
				self.voidlandBtn = btn
				self:Voidland_infoUpdate()
			end
			if v.battleType and v.battleType == GameDef.BattleArrayType.Boundary then
				self.boundaryDesc1 = btn:getChildAutoType("txt_dec1")
				self.boundaryDesc2 = btn:getChildAutoType("txt_dec2")
				self:doTimeShow(btn)
			end
		end

			Scheduler.scheduleNextFrame(function ( ... )
				if tolua.isnull(obj) then return end
				obj:getTransition("t0"):play(function( ... )
			end)
		
		end);
	end
	)
	self.list_btns:setNumItems(1)

	local width = self.view:getWidth() - self.list_btns:getX() + (display.width - self.view:getWidth()) / 2
	self.list_btns:setWidth(width)
end

function SubBtnView:_refresh()
	self.list_btns:getChildAt(0):getTransition("t0"):play(function( ... )
	end);
end

function SubBtnView:doTimeShow()
	local lastTime = TimeLib.nextMonthBeginTime() - ServerTimeModel:getServerTime()
	if lastTime <= 0 then 
		lastTime = 0 
	end
	local typ = "d"
	local descTyp = Desc.common_TimeDesc
	if lastTime < 60 * 60 * 24 then
		typ = "h"
		descTyp =  Desc.common_TimeDesc2
	end
	local best = BoundaryMapModel:getBestMarkScene()
	best = best == 0 and 1 or best
	self.boundaryDesc1:setText(string.format(Desc.Boundary_desc1,best))
	self.boundaryDesc2:setText(StringUtil.formatTime(lastTime,typ,descTyp)..Desc.Boundary_desc11)
end
function SubBtnView:player_levelUp(_, params)
	--self.list_btns:setNumItems(1)
end

function SubBtnView:Voidland_infoUpdate()
	if (self.voidlandBtn) then
		local txt_mode = self.voidlandBtn:getChildAutoType("txt_mode")
		local txt_point = self.voidlandBtn:getChildAutoType("txt_point")
		txt_mode:setText(Desc["Voidland_mode" .. VoidlandModel:todayMode()])
		local conf = VoidlandModel:getPointInfoById(nil, VoidlandModel:todayMode())
		if (conf) then
			txt_point:setText(string.format(Desc.Voidland_point, conf.nodeId, conf.index))
		else
			txt_point:setText(string.format(Desc.Voidland_point, 1, 1))
		end
	end
end

--把某个按钮居中
function SubBtnView:centerBtn(btnName)
	local btnPanel = self.list_btns:getChildAt(0)
	local btnPanelWidth = 1741
	local listWidth = self.list_btns:getWidth()
	local btn = btnPanel:getChildAutoType(btnName)
	local posX = -(btn:getPosition().x - listWidth / 2)
	if posX < -(btnPanelWidth - listWidth) then
		posX = -(btnPanelWidth - listWidth)
	end
	
	if posX > 0 then
		posX = 0
	end
	
	btnPanel:getScrollPane():setPosX(-posX, false)
end

function SubBtnView:onBtnClick(btnName)
	if btnName == "btn_pata" then
		local hasOpen = ModuleUtil.moduleOpen(ModuleId.TowerRace.id, false)
		if hasOpen then
			ViewManager.open("PataChooseView")
			return
		end
		ViewManager.open(
		"PataView",
		{
		type = 6,
		name = "第五之塔",
		activeType = 2000,
		towerType = 1,
		rankType = 2,
		space = -15,
		showCount = 6,
		moveCount = 4
		}
		)
		ModuleUtil.openModule(ModuleId.Pata, true)
	elseif btnName == "btn_heroPalace" then
		--ViewManager.open("HeroPalaceView")
		ModuleUtil.openModule(ModuleId.HeroPalace, true)
	elseif btnName == "btn_maze" then
		ModuleUtil.openModule(ModuleId.Maze, true)
	elseif btnName == "btn_arena" then
		ViewManager.open("WorldChallengeView")
	elseif btnName == "btn_fraiyLand" then
		if ViewManager.getView("BattleBeginView") then
			RollTips.show(Desc.fairyLand_haveOtherBattle)
			return
		end
		ViewManager.open("FairyLandView")
	elseif btnName == "btn_copy" then
		ModuleUtil.openModule(ModuleId.Copy, true)
	elseif btnName == "btn_endlessRoad" then
		ViewManager.open("ExpeditionView")
	elseif btnName == "btn_endlessTrial" then
		local trialAllData = EndlessTrialModel.trialAllData
		local trialSynthData = EndlessTrialModel:getTrialDataByType(GameDef.TopChallengeType.Common) -- 获取综合试炼数据
		if trialSynthData.maxLevel >= 200 then
			ModuleUtil.openModule(ModuleId.EndlessTrialSecond.id, true, {trialType = trialAllData.raceType})
		else
			ModuleUtil.openModule(ModuleId.EndlessTrial.id, true, {trialType = GameDef.TopChallengeType.Common})
		end
	elseif btnName == "btn_pveStarTemple" then
		local hasOpen = ModuleUtil.moduleOpen(ModuleId.PveStarTemple.id, true)
		if not hasOpen then
			return
		end
		Dispatcher.dispatchEvent(EventType.PveStarTemple_Start)
	elseif btnName == "btn_voidland" then
		ModuleUtil.openModule(ModuleId.Voidland, true)
	elseif btnName == "btn_boundaryMap" then
		ModuleUtil.openModule(ModuleId.BoundaryMapView.id, true)
	end
end

--指引时传入按钮名字，可把按钮名字居中
function SubBtnView:_doGuideFunc(args)
	self:centerBtn(args)
end
function SubBtnView:_exit()
	if self.timer then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer)
		self.timer = false
	end
end
return SubBtnView