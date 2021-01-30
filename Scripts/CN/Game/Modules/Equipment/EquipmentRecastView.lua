-- 装备重铸  之前的锻造坊的装备升星，分解，重铸因为功能剔除了升星和分解  所以挪动到单独的地方以适应MutiWindow

local EquipmentRecastView,Super = class("EquipmentRecastView", Window)

local lastInterTime = 0.1
local maxInterTime = 0.5

function EquipmentRecastView:ctor()
	--LuaLog("EquipmentRecastView ctor")
	self._packName = "Equipment"
	self._compName = "EquipmentRecastView"
	self._rootDepth = LayerDepth.Window
	self.curPos = 1
	self.curEqData = false
	self.curPageId = 0
	-- self.viewCtrlName = "base"
	-- self._tabBarName = "$btnlist"
	self.initPage = {}
	
	self.selectDecompose = {}
	self.selectDecomposeGrid = {}
	self.sortDesc = true  --从低到高排列
	
	self.curHid = false --选中的
	self.curData = false  --重铸选中的装备 
	
	self.curDecomposeType = 2
	self.DecomposeShowData = {}
	self.colorCtrl = false
	self.cur_type = 1 --当前选择的类型
	-- self.btn_help = false;
	-- self.btn_help2 = false;
	-- self.helpPanelMask = false;
	-- self.helpPanel = false
	self.helpStr = "";
	self.helpTitle = "";
	self.hero_icon = false
	self.btn_left = false
	self.btn_right = false
	self.chongzhuState = false -- 重铸的状态
	self.nselectIndex = 1
	self.scheduler = {}
	self.aniFlagArr = {false,false,false}
	--GButton
	--GTextField
	
	--按钮上的红点数据
	self.redTypes = {
		{redType="", moduleId = ModuleId.Forge_starUp.id},
		{redType="", moduleId = ModuleId.Forge_Decompose.id},
		{redType="", moduleId = ModuleId.Forge.id},
		{redType="", moduleId = ModuleId.Forge_Compose.id},
		{redType="", moduleId = ModuleId.Forge_Wash.id},
		{redType="", moduleId = 0},
		{redType="", moduleId = 0},
	}

	self.showMoneyRebuildType = {
		{type = GameDef.GameResType.Item, code = 10000058, iconType = GameDef.ItemType.Money},
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Gold},
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond},
	}

	self.showMoneyUpstarType = {
		{type = GameDef.GameResType.Item, code = 10000017, iconType = GameDef.ItemType.Normal},
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Gold},
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond},
	}

	self.showMoneyDefaultType = {
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Gold},
		{type = GameDef.ItemType.Money, code = GameDef.MoneyType.Diamond},
		}
	self.data = {};
	self.eqTabId = false;
	self.lselectIndex = false;
	self.skeletonNode = nil
	
end

function EquipmentRecastView:_initVM()
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:Equipment.EquipmentRecastView
		vmRoot.xinyuanTxt = viewNode:getChildAutoType("$xinyuanTxt")--text
		vmRoot.equipInfo = viewNode:getChildAutoType("$equipInfo")--list
		-- vmRoot.btnlist = viewNode:getChildAutoType("$btnlist")--list
		vmRoot.quick = viewNode:getChildAutoType("$quick")--Button
		vmRoot.chongzhu = viewNode:getChildAutoType("$chongzhu")--Button
		vmRoot.heroName = viewNode:getChildAutoType("$heroName")--text
		vmRoot.shengx = viewNode:getChildAutoType("$shengx")--Button
		vmRoot.btn_xinyuan = viewNode:getChildAutoType("$btn_xinyuan")--Button
		vmRoot.fenjie = viewNode:getChildAutoType("$fenjie")--Button
		vmRoot.sx = viewNode:getChildAutoType("$sx")--list
		vmRoot.upgrade = viewNode:getChildAutoType("$upgrade")--Label
		vmRoot.now = viewNode:getChildAutoType("$now")--Label
		vmRoot.eqitem = viewNode:getChildAutoType("$eqitem")--Label
		vmRoot.skill1 = viewNode:getChildAutoType("$skill1")--list
		vmRoot.combob = viewNode:getChildAutoType("$combob")--ComboBox
		vmRoot.toollist = viewNode:getChildAutoType("$toollist")--list
		local list = viewNode:getChildAutoType("$list")--
		vmRoot.list = list
			list.btn_score = viewNode:getChildAutoType("$list/$btn_score")--Button
			list.secondTab = viewNode:getChildAutoType("$list/$secondTab")--list
			list.eqlist = viewNode:getChildAutoType("$list/$eqlist")--list
		vmRoot.getlist = viewNode:getChildAutoType("$getlist")--list
		vmRoot.descname = viewNode:getChildAutoType("$descname")--text
		vmRoot.heroLevel = viewNode:getChildAutoType("$heroLevel")--text
		vmRoot.man = viewNode:getChildAutoType("$man")--Label
		vmRoot.newskill = viewNode:getChildAutoType("$newskill")--list
		vmRoot.btn_change = viewNode:getChildAutoType("$btn_change")--Button
		vmRoot.ForgeState = viewNode:getController("ForgeState")--Button
		vmRoot.spine = viewNode:getChildAutoType("spine")--list
		vmRoot.spine1 = viewNode:getChildAutoType("spine1")--list
		vmRoot.spine2 = viewNode:getChildAutoType("spine2")--list
		vmRoot.spine3 = viewNode:getChildAutoType("spine3")--list
		vmRoot.spine4 = viewNode:getChildAutoType("spine4")--list

		self.hero_icon = self.view:getChildAutoType("hero_icon")
		self.btn_left = self.view:getChildAutoType("btn_left")
		self.btn_right = self.view:getChildAutoType("btn_right")
		self.colorCtrl 	= self.view:getController("colorCtrl")
	--{vmFieldsEnd}:Equipment.EquipmentRecastView
	--Do not modify above code-------------
	self.curDecomposeType = FileCacheManager.getIntForKey("EquipmentRecastView_curDecomposeType", 2)
	self:moveTitleToTop()
	vmRoot.now.skeletonNode = SpineUtil.createSpineObj(vmRoot.now,vertex2(0,0), "ui_duanzaofang_shengxing_a", "Spine/ui/equipment", "efx_duanzaofang", "efx_duanzaofang",false,true)
	vmRoot.now.skeletonNode:setVisible(false)

	SpineUtil.createSpineObj(vmRoot.spine,vertex2(0,0), "ui_duanzaofang_jiantou_loop", "Spine/ui/equipment", "efx_duanzaofang", "efx_duanzaofang",true,true)
	SpineUtil.createSpineObj(vmRoot.spine1,vertex2(0,0), "ui_zhongzhu_beijing", "Spine/ui/equipment", "efx_duanzaofang", "efx_duanzaofang",true,true)
	vmRoot.spine2.skeletonNode = SpineUtil.createSpineObj(vmRoot.spine2,vertex2(0,0), "ui_zhongzhu", "Spine/ui/equipment", "efx_duanzaofang", "efx_duanzaofang",false,true)
	vmRoot.spine3.skeletonNode = SpineUtil.createSpineObj(vmRoot.spine3,vertex2(0,0), "ui_zhongzhu", "Spine/ui/equipment", "efx_duanzaofang", "efx_duanzaofang",false,true)
	vmRoot.spine2:setVisible(false)
	vmRoot.spine3:setVisible(false)

	self.spine4.skeletonNode = SpineUtil.createSpineObj(vmRoot.spine4,vertex2(0,0), "ui_duanzaofang_fenjie", "Spine/ui/equipment", "efx_duanzaofang", "efx_duanzaofang",false,true)
	vmRoot.spine4:setVisible(false)

end

function EquipmentRecastView:_initUI()
	self:_initVM()
	
	-- if self._args.page then
		self.curPageId = 2--self._args.page
	-- end
	
	if self._args.equuid then
		EquipmentModel.curEqUUID = self._args.equuid
	end
	
	
	-- self.btnlist:setNumItems(5)
	--self:setTabBarData({{mid=ModuleId.UpStart.id},{mid=ModuleId.CardDecompose.id}})
	
	self.saveArr = {}
	

	self.maxCtl = self.view:getController("max");
	-- self.helpPanelMask = self.view:getChildAutoType("helpPanelMask");
	-- self.helpPanel = self.view:getChildAutoType("helpPanel");
	self.group4 = self.view:getChildAutoType("group4")
	self.chongz22 = self.view:getChildAutoType("chongz22")
	self.daoju = self.view:getChildAutoType("daoju")
	self.tipslabel = self.view:getChildAutoType("tipslabel")
	self.list.eqlist:setVirtual()
	self.list.eqlist:setItemRenderer(function(index,obj)
			self:itemShow(obj,index)
		end)
	self.list.eqlist:addEventListener(FUIEventType.Scroll,function ( ... )
		self.aniFlagArr[self.curPageId+1] = true
	end)
	self.curPos = EquipmentModel.curPos
	self.list.secondTab:setSelectedIndex(self.curPos)
	self.list.secondTab:addEventListener(FUIEventType.ClickItem,function( context )
			local cindex= self.list.secondTab:getChildIndex(context:getData())
			local index = self.list.secondTab:childIndexToItemIndex(cindex);
			if self.curPos == index then return end
			self.curPos = index
			self.nselectIndex = 1
			EquipmentModel.curPos = index
			EquipmentModel.curEqUUID = false
			self.curData = false
			self:showEqByPos()
		end);
	
	self.quick:removeClickListener(88)
	self.quick:addClickListener(function( ... )
			for i=0,self.list.eqlist:getNumItems()-1 do
				local item = self.list.eqlist:getChildAt(i)
				if not item:isSelected() then
					item:setSelected(true)
					local itemCongfig = DynamicConfigData.t_item[self.data[i+1].v.id]
					if itemCongfig and itemCongfig.decompose then
						EquipmentModel:addDecompose(self.selectDecompose,itemCongfig.decompose)
						self.selectDecomposeGrid[self.data[i+1].grid] = self.data[i+1].uuid
						self.descname:setText(Desc.equipment_seltips)
					end
				end
			end
			
			local showData = {}
			for k,v in pairs(self.selectDecompose) do
				table.insert(showData,v)
			end
			
			self.getlist:setItemRenderer(function(index,obj)
				
					local itemcell = BindManager.bindItemCell(obj)
					itemcell:setIsBig(true)
					local itemData = ItemsUtil.createItemData({data = showData[index+1]})
					itemcell:setItemData(itemData)
					obj:removeClickListener(88)
					obj:addClickListener(function( ... )
							itemcell:onClickCell(index)
						end,88)
				end)
			self.getlist:setNumItems(#showData)
			if #showData > 0 then
				self.view:getChildAutoType("n54"):setVisible(false)
			end
		end)
	self.fenjie:addClickListener(function( ... )
			if self.fenjie.action then return end
			if not next(self.selectDecomposeGrid) then
				RollTips.show(Desc.equipment_noseltips);
				return
			end
			self.fenjie.action = true
			local dd = {}
			for k,v in pairs(self.selectDecomposeGrid) do
				table.insert(dd,{bagType = 2,itemId = k,amount = 1})
			end
			self.spine4:setVisible(true)
			self.spine4.skeletonNode:setAnimation(0,"ui_duanzaofang_fenjie",false)
			self.spine4.skeletonNode:stopAllActions()
			local arr = {}
			table.insert(arr,cc.DelayTime:create(0.8))
			table.insert(arr,cc.CallFunc:create(function()
				self.spine4:setVisible(false)
				RPCReq.Bag_DecomposeItem({items = dd},function(args)
					self.fenjie.action = false
					if tolua.isnull(self.view) then return end
					self:showEqByPos()
					self.descname:setText(Desc.equipment_noseltips)
					self.getlist:setNumItems(0)
					EquipmentModel.curEqUUID = false
					self.selectDecomposeGrid = {}
					self.selectDecompose = {}
				end)
			end))
			self.spine4.skeletonNode:runAction(cc.Sequence:create(arr))
		end,88)
		
	self.list.btn_score:addClickListener(function( ... )
		self.sortDesc = not self.sortDesc
		self:refreshList()
		-- self:refreshFenjie()
	end,88)
	
	--self.combob:setTitle(Desc.equipment_pinzhi)
	self.btn_left:removeClickListener(111)
	self.btn_left:addClickListener(function()
		if self.curDecomposeType == 2 then
			self.curDecomposeType = 4
		else
			self.curDecomposeType = self.curDecomposeType - 1
		end
		self:refreshFenjie()
	end,111)

	self.btn_right:removeClickListener(111)
	self.btn_right:addClickListener(function()
		if self.curDecomposeType == 4 then
			self.curDecomposeType = 2
		else
			self.curDecomposeType = self.curDecomposeType + 1
		end
		self:refreshFenjie()
	end,111)

	print(8848,">>>self.curDecomposeType1>>>",self.curDecomposeType)
	self.combob:addEventListener(FUIEventType.Changed,function(data)
			--edittext1:setText(self.combob:getTitle())
			printTable(33,"self.combob:getTitle() = ",self.combob:getValue())
			self.curDecomposeType = tonumber(self.combob:getValue())
			--self:showEqByPos()
			print(8848,">>>self.curDecomposeType22>>>",self.curDecomposeType)
			self.list.eqlist:refreshVirtualList()
			self.selectDecomposeGrid = {}
			self.selectDecompose = {}
			for i=1,#self.data do
				local info = self.data[i].v
				if info.color <= self.curDecomposeType then
					local itemCongfig = DynamicConfigData.t_item[info.id]
					if itemCongfig and itemCongfig.decompose then
						EquipmentModel:addDecompose(self.selectDecompose,itemCongfig.decompose)
						self.selectDecomposeGrid[self.data[i].grid] = self.data[i].uuid
						self.descname:setText(Desc.equipment_seltips)
					end
				end
			end
			
			self.DecomposeShowData = {}
			for k,v in pairs(self.selectDecompose) do
				table.insert(self.DecomposeShowData,v)
			end


			self.getlist:setNumItems(#self.DecomposeShowData)

			if #self.DecomposeShowData > 0 then
				self.view:getChildAutoType("n54"):setVisible(false)
			end
			
		end,33)
	
	self.combob:addEventListener(FUIEventType.Click,function(data)
			--edittext1:setText(self.combob:getTitle())
			print(33,"ClickMenu")
		end,33)
	
	self.getlist:setItemRenderer(function(index,obj)
			local itemcell = BindManager.bindItemCell(obj)
			itemcell:setIsBig(true)
			local itemData = ItemsUtil.createItemData({data = self.DecomposeShowData[index+1]})
			itemcell:setItemData(itemData)
			local url = ItemConfiger.getItemIconByCode(itemData:getItemInfo().icon)
			obj:removeClickListener(88)
			obj:addClickListener(function(...)
				itemcell:onClickCell(index)
			end,88)
		end)
	
	self.baseCtl = self.view:getController("base");
	
	self.eqTabId = false
	self.baseCtl:setSelectedIndex(self.curPageId)
	-- if not ModuleUtil.moduleOpen(ModuleId.Forge.id,false) then	
	-- 	-- self:initTableData()
	-- else
		self:onControllerChanged()
	-- end

	self.btn_change:removeClickListener(111)
	self.btn_change:addClickListener(function()
		if not self.chongzhuState then
			RollTips.show(Desc.Equipmentforge_chongzhuTips)
			return
		end
	end,111)
end

-- 分解
function EquipmentRecastView:refreshFenjie()
	self.colorCtrl:setSelectedIndex(self.curDecomposeType)
	FileCacheManager.setIntForKey("EquipmentRecastView_curDecomposeType", self.curDecomposeType)
	self.list.eqlist:refreshVirtualList()
	self.selectDecomposeGrid = {}
	self.selectDecompose = {}
	for i=1,#self.data do
		local info = self.data[i].v
		if info.color <= self.curDecomposeType then
			local itemCongfig = DynamicConfigData.t_item[info.id]
			if itemCongfig and itemCongfig.decompose then
				EquipmentModel:addDecompose(self.selectDecompose,itemCongfig.decompose)
				self.selectDecomposeGrid[self.data[i].grid] = self.data[i].uuid
				self.descname:setText(Desc.equipment_seltips)
			end
		end
	end
	
	self.DecomposeShowData = {}
	for k,v in pairs(self.selectDecompose) do
		table.insert(self.DecomposeShowData,v)
	end
	self.getlist:setNumItems(#self.DecomposeShowData)

	if #self.DecomposeShowData > 0 then
		self.view:getChildAutoType("n54"):setVisible(false)
	end
end

-- function EquipmentRecastView:closeHelpPanel()
-- 	local fromScale = self.helpPanel:getScaleX()
-- 	TweenUtil.moveTo(self.helpPanel, {from = self.helpPanel:getPosition(), to = self.btn_help2:getPosition(), time = 0.3})
-- 	TweenUtil.scaleTo(self.helpPanel, {from = Vector2(fromScale,fromScale), to = Vector2(0.01, 0.01), time = 0.3, onComplete=function()
-- 		self.helpPanel:setVisible(false)
-- 		self.helpPanelMask:setVisible(false)
-- 	end})
-- end

--监听控制器页面改变
function EquipmentRecastView:initTableData()
	--历史遗留问题，先这样处理
	local listNum = self._tabBar:getNumItems()
	--self._tabBar:removeSelectionController()
	local tabData = {}
	self.eqTabId = {}
	local pageId = {"0","2","1","3","4"}
	for i = 1, listNum do
		local index = self._tabBar:itemIndexToChildIndex(i-1)
		local obj = self._tabBar:getChildAt(index)
		
		local pageName = self.viewCtrl:getPageNameById(pageId[i])
		self.eqTabId[pageName] = index
		local tab = {}
		tab.page = pageName
		tab.btData = {}
		tab.btData.title = obj:getTitle()
		tab.btData.icon = obj:getChildAutoType("icon"):getURL()
		table.insert(tabData,tab)
		print(33,"pageName = ",pageName)
	end
	--if not ModuleUtil.moduleOpen(ModuleId.Forge.id,false) then
		table.remove(tabData,3)
		table.remove(self.redTypes,3)
	--end
	
	printTable(33,"initTableData",tabData)
	self:setTabBarData(tabData)
	self:onControllerChanged()
end

--监听控制器页面改变
function EquipmentRecastView:onControllerChanged()
	local pageId = self.baseCtl:getSelectedIndex()
	local pageName = self.baseCtl:getSelectedPage()
	print(33,"onControllerChanged ",pageId,pageName)
	if not ModuleUtil.moduleOpen(self.redTypes[pageId + 1].moduleId,true) then 
		self.baseCtl:setSelectedIndex(self.curPageId)
		-- self.btnlist:setSelectedIndex(self.curPageId)
		return
	end
	self.curData = false
	if self.eqTabId then
		self.curPageId = self.eqTabId[pageName]
	else
		self.curPageId = pageId
	end
	self.aniFlagArr[self.curPageId+1] = false

	if self._args.equuid then
		EquipmentModel.curEqUUID = self._args.equuid
		self._args.equuid = false
	else
		EquipmentModel.curEqUUID = false
	end
	self:showEqByPos()
	if self.curPageId == 1 then
		self:refreshFenjie()
	end
end

function EquipmentRecastView:showEqByPos(uuid)
	-- self.curDecomposeType = 2  -- 0
	self.selectDecomposeGrid = {}
	self.selectDecompose = {}
	self.lselectIndex = false
	if self.curPageId == 0 then
		self.maxCtl:setSelectedIndex(3)
	else
		if self.curPageId == 1 then
			EquipmentModel.curEqUUID  = false
		end
		self.view:getChildAutoType("n54"):setVisible(true)
	end
	
	self.data = {}
	print(8848,">>>self.curPageId>>>",self.curPageId)
	if self.curPageId ~= 1 then
		local wearData = EquipmentModel:getWearEqList()
		for m,n in pairs(wearData) do
			for k,v in pairs(n) do
				local eqInfo = EquipmentModel:getConfingByCode(v.code)
				if eqInfo.position == self.curPos  or self.curPos == 0 then
					--品质4以上才可以重铸
					print(8848,">>>eqInfo.color>>",eqInfo.color)
					if self.curPageId == 2 and eqInfo.color <= 4 then
						
					--elseif self.curPageId == 0 and eqInfo.attType ~= EquipmentModel.attType then

					else
						local info = {}
						info.k = k
						info.v = eqInfo
						info.d = v
						info.w = true
						info.uuid = v.uuid
						info.hid = m
						info.score = EquipmentModel:calcCombat({code = eqInfo.id,uuid = v.uuid})
						
						if self.lselectIndex == false and info.uuid == EquipmentModel.curEqUUID then
							self.lselectIndex = info
						else
							table.insert(self.data,info)
						end
					end
				end
			end
		end
	end
	
	local data = EquipmentModel:getEquipBag().__packItems
	
	for k,v in pairs(data) do
		local eqInfo = EquipmentModel:getConfingByPackItem(v)
		if eqInfo.position == self.curPos or self.curPos == 0 then
			if self.curPageId == 2 and  eqInfo.color <= 4 then
				
			--elseif self.curPageId == 0 and eqInfo.attType ~= EquipmentModel.attType then

			else
				local info = {}
				info.k = k
				info.v = eqInfo
				info.d = v
				info.uuid = v.__data.uuid
				info.grid = v.__data.id
				info.score = EquipmentModel:calcCombat(v.__data)

				
				if self.lselectIndex == false and info.uuid == EquipmentModel.curEqUUID then
					self.lselectIndex = info
				else
					table.insert(self.data,info)
				end
			end
		end
	end
	
	print(33,"showEqByPos data = ",#self.data)
	self:refreshList(uuid)
	if self.curPageId == 2 then
		if self.curData then
			self.list.eqlist:setSelectionMode(0)
			self:updateChongzhuInfo()
		else
			self.chongz22:setVisible(false)
			self.group4:setVisible(false)
			self.daoju:setVisible(false)
			self.tipslabel:setVisible(true)
			self.list.eqlist:setSelectionMode(0)
			self.list.eqlist:setSelectedIndex(-1)
			self.chongzhu:removeClickListener(88)
			self.chongzhu:addClickListener(function( ... )
					RollTips.show(Desc.equipment_noseltips);
				end,88)
		end
	elseif self.curPageId == 1 then
		self.list.eqlist:setSelectionMode(2)
		self.selectDecomposeGrid = {}
		self.selectDecompose = {}
		self.getlist:setNumItems(0)
		self.descname:setText(Desc.equipment_noseltips)
		self.combob:setTitle(Desc.equipment_pinzhi)
		self:refreshFenjie()
	else
		self.daoju:setVisible(true)
		self.list.eqlist:setSelectionMode(0)
		local showIndex = self.nselectIndex
		if self.nselectIndex >= 6 then
			showIndex = showIndex - 6
		else
			showIndex = 0
		end
		self.list.eqlist:scrollToView(showIndex,false,false)
	end
end

function EquipmentRecastView:refreshList(uuid)
	local keys = {
		{key = "score", asc = self.sortDesc},
	}
	TableUtil.sortByMap(self.data, keys)
	if self.lselectIndex and self.lselectIndex ~= 1 then
		table.insert(self.data,1,self.lselectIndex)
	end
	for key,value in pairs(self.data) do
		if value.uuid == uuid then
			self.nselectIndex = key
		end
	end
	self.lselectIndex = 1

	if self.curPageId == 2 and self.curData == false then
		self.curHid = ""
		if next(self.data) then
			if self.data[1].w then
				self.curHid  = self.data[1].hid
			end
		end
		self.curData = self.data[1] or false
	end
	self.list.eqlist:setNumItems(#self.data)
	self.list:getController("c1"):setSelectedIndex(#self.data > 0 and 0 or 1)
	if self.curPageId == 1 then
		self:refreshFenjie()
	end
end

function EquipmentRecastView:itemShow( obj,index )

	local eqInfo = self.data[index+1].v;
	--local eqInfo = EquipmentModel:getConfingByPackItem(eqdata.v)
	
	if self.curPageId == 1 then
		obj:getChildAutoType("checkMark"):setVisible(true)
	else
		obj:getChildAutoType("checkMark"):setVisible(false)
	end
	
	if self.data[index+1].w == true then
		obj:getChildAutoType("hero_icon"):setVisible(true)
		obj:getChildAutoType("head_frame"):setVisible(true)
		local heroId = ModelManager.CardLibModel:getHeroByUid(self.data[index+1].hid).heroDataConfiger.heroId
		obj:getChildAutoType("hero_icon"):setURL(PathConfiger.getHeroCard(heroId))--放了卡牌图片	
		--local heroCell = BindManager.bindCardCell(obj:getChildAutoType("hero_icon"))
		--heroCell:setData()
	else
		-- self.hero_icon:setVisible(false)
		obj:getChildAutoType("hero_icon"):setVisible(false)
		obj:getChildAutoType("head_frame"):setVisible(false)
	end
	
	obj:setSelected(false)
	if (self.curPageId == 0 and index + 1 == self.nselectIndex) or (self.curPageId == 2 and self.curData.uuid == self.data[index+1].uuid) then
		self["setRightArea"..self.curPageId]( self,eqInfo,self.data[index+1] )
		obj:setSelected(true)
		local heroId = false
		if ModelManager.CardLibModel:getHeroByUid(self.data[index+1].hid) then
			heroId = ModelManager.CardLibModel:getHeroByUid(self.data[index+1].hid).heroDataConfiger.heroId
		end
		if heroId then
			self.hero_icon:setVisible(true)
			self.hero_icon:setURL(PathConfiger.getHeroCard(heroId))
		else
			self.hero_icon:setVisible(false)
			self.hero_icon:setURL("")
		end
	elseif self.curPageId == 1 then 
		if self.selectDecomposeGrid[self.data[index+1].grid] then
			obj:setSelected(true)
		end
	end
	
	if not obj.itemcell then
		obj.itemcell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"))
		obj.itemcell.view:removeClickListener()
		obj.itemcell:setIsBig(true)
	end
	obj.itemcell:setData(eqInfo.id,0,CodeType.ITEM)
	obj:removeClickListener(88)
	obj:addClickListener(function()
		self.nselectIndex = index + 1
		if self.curPageId == 2 then
			if self.curData == self.data[index+1] then return end
			self.curHid = ""
			if self.data[index+1].w then
				self.curHid  = self.data[index+1].hid
			end
			self.curData = self.data[index+1]
			self:updateChongzhuInfo()
		else
			self["setRightArea"..self.curPageId]( self,eqInfo,self.data[index+1] ,obj)
		end
		local heroId = false
		if ModelManager.CardLibModel:getHeroByUid(self.data[index+1].hid) then
			heroId = ModelManager.CardLibModel:getHeroByUid(self.data[index+1].hid).heroDataConfiger.heroId
		end
		if heroId then
			self.hero_icon:setVisible(true)
			self.hero_icon:setURL(PathConfiger.getHeroCard(heroId))
		else
			self.hero_icon:setVisible(false)
			self.hero_icon:setURL("")
		end
	end,88)

	--动画
	local maxNum = #self.data<18 and #self.data or 18
	local interTime = maxInterTime/maxNum
    if interTime >= lastInterTime then
    	interTime = lastInterTime
	end
	if not self.aniFlagArr[self.curPageId+1] then
		obj:setVisible(false)
		local tempIndex = index+1-self.list.eqlist:getFirstChildInView()
		self.scheduler[tempIndex] = Scheduler.scheduleOnce(tempIndex*interTime, function( ... )
			if obj and  (not tolua.isnull(obj)) then
				obj:setVisible(true)
				obj:getTransition("t1"):play(function( ... )
				end);
			end
		end)
	end
end

function EquipmentRecastView:resetItemCell(index, obj,data,itemData )
	if tolua.isnull(obj) then return end
	local icon = obj:getChildAutoType("icon")
	local num = obj:getChildAutoType("need")
	local ower = obj:getChildAutoType("ower")
	local numstr = itemData.__data.amount
	local curNum = 0
	--printTable(33,"##",data)
	
	local url = ItemConfiger.getItemIconByCode(itemData:getItemInfo().icon)
	obj:setIcon(url)
	
	if data.type  == 2 then
		curNum = PlayerModel:getMoneyByType(data.code)
	else
		curNum =  PackModel:getNormalBag():getAmountByCode(data.code)
	end
	--print(33,"0000000000000000-------------------== ",curNum , data.amount)
	if curNum < data.amount then
		num:setColor({r=255,g=0,b=0})
	else
		num:setColor({r=0,g=255,b=0})
	end
	
	--if  data.type ~= 1 and data.type ~=2 then
		if curNum >= 100000000 then
			curNum = Desc.player_expStr2:format(curNum/100000000)
		elseif curNum >= 10000 then
			curNum = Desc.player_expStr1:format(curNum/10000)
		end
	
		if numstr >= 100000000 then
			numstr = Desc.player_expStr2:format(numstr/100000000)
		elseif numstr >= 10000 then
			numstr = Desc.player_expStr1:format(numstr/10000)
		end

		
		--num:setFontSize(12)
	--end
	num:setText(numstr)
	ower:setText(curNum.."/")
	
	--[[obj:removeClickListener(88)
	obj:addClickListener(function( ... )
		itemcell:onClickCell(index)
	end,88)--]]
end

function EquipmentRecastView:updateChongzhuInfo()
	local eqInfo = self.curData.v
	EquipmentModel:reqSkillData(self.curHid,{self.curData.uuid},function()
						self["setRightArea"..self.curPageId]( self,eqInfo,self.curData )
				end)
	self.chongz22:setVisible(true)
	
	self.daoju:setVisible(true)
	self.tipslabel:setVisible(false)
	self.ForgeState:setSelectedIndex(0)
end

function EquipmentRecastView:setRightArea0( eqInfo,eqData )
	
	
	--self.now:getChildAutoType("frame"):setURL(PathConfiger.getItemFrame(eqInfo.color, false))
	--self.now:setIcon(EquipmentModel:getEqIconByeCode(eqInfo.id))
	self.now:setTitle(eqInfo.name)
	--self.now:getChildAutoType("star"):setNumItems(eqInfo.staramount)

	if eqData and eqData.w then
		local infoData= CardLibModel:getHeroByUid(eqData.hid)
		self.group4:setVisible(true)
		self.heroName:setText(infoData.heroDataConfiger.heroName)
		self.heroLevel:setText("lv."..infoData.level)

	else
		self.group4:setVisible(false)
	end
	
	if not self.now.itemcell then
		self.now.itemcell = BindManager.bindItemCell(self.now:getChildAutoType("itemCell"))
		--self.now.itemcell.view:removeClickListener()
		if not self.now:getChildAutoType("itemCell/frameBg") then
			self.now.itemcell:setIsBig(true)
		end
		self.now.cardStar= BindManager.bindCardStar(self.now:getChildAutoType("cardStar"))
	end
	self.now.itemcell:setData(eqInfo.id,0,CodeType.ITEM)
	self.now.cardStar:setData(eqInfo.staramount)
	
	local nextInfo = EquipmentModel:getConfingByCode(eqInfo.next)
	EquipmentModel.curEqUUID = eqData.uuid
	local showList = false
	if nextInfo then
		
		showList = self.sx
		if not self.upgrade.itemcell then
			self.upgrade.itemcell = BindManager.bindItemCell(self.upgrade:getChildAutoType("itemCell"))
			--self.upgrade.itemcell.view:removeClickListener()
			if not self.upgrade:getChildAutoType("itemCell/frameBg") then
				self.upgrade.itemcell:setIsBig(true)
			end
			self.upgrade.cardStar= BindManager.bindCardStar(self.upgrade:getChildAutoType("cardStar"))
		end
		self.upgrade.itemcell:setData(nextInfo.id,0,CodeType.ITEM)
		self.upgrade.cardStar:setData(nextInfo.staramount)
		self.upgrade:setTitle(nextInfo.name)
		
		self.shengx:setTouchable(true)
		self.shengx:setGrayed(false)
		if nextInfo.staramount == 0 then
			self.maxCtl:setSelectedIndex(1)
		else
			self.maxCtl:setSelectedIndex(0)
		end
		
		local costData = eqInfo.upCost
		printTable(33,"costData = ",costData)
		--消耗道具显示
		self.toollist:setItemRenderer(function(index,obj)
			-- --local itemcell = BindManager.bindItemCell(obj)
			-- --local itemData = ItemsUtil.createItemData({data = costData[index+1]})
			-- --itemcell:setItemData(itemData)
			-- --self:resetItemCell(index, obj,costData[index+1],itemData)
			-- 	local itemData = ItemsUtil.createItemData({data = costData[index+1]})
			-- 	--itemcell:setItemData(itemData)
			-- 	self:resetItemCell(index, obj,costData[index+1] ,itemData)
			-- 	--obj:setIcon("url")
			-- --[[obj:removeClickListener(88)
			-- obj:addClickListener(function( ... )
			-- 		--itemcell:onClickCell(index)
			-- 	end,88)--]]
				local data = costData[index+1]
				local costItem = BindManager.bindCostItem(obj)
				-- costItem.txt_num:setColor(hasNum >= data.amount and {r=60,g=254,b=69} or {r=255,g=59,b=59})
				costItem:setGreenColor("#3cfe45")
				costItem:setRedColor("#ff3b3b")
				costItem:setData(data.type,data.code,data.amount,true)
		end)
		self.toollist:setNumItems(#costData)
		
		self.shengx:removeClickListener(88)
		self.shengx:addClickListener(function( ... )
				if self.shengx.action then return end
				if not EquipmentModel.curEqUUID then
					RollTips.show(Desc.equipment_noseltips);
					return
				end
				if not PlayerModel:isCostEnough(costData) then
					return
				end
				self.shengx.action = true
				local info = {}
				if eqData.w then
					info.heroUuid = eqData.hid
				end
				info.itemUuid = eqData.uuid
				RPCReq.Equipment_UpgradeOrder(info,function(args)
					if (tolua.isnull(self.view)) then
						return;
					end
					self.now.skeletonNode:setVisible(true)
					self.now.skeletonNode:setAnimation(0,"ui_duanzaofang_shengxing_a",false)
					self.now.skeletonNode:setEventListener(function(name,event)
						local eventName=event:getData():getName()
					end)
					self.now.skeletonNode:setCompleteListener(function(name)
						if name == "ui_duanzaofang_shengxing_a" then
							self.now.skeletonNode:setVisible(false)
						end
					end)
					self.now.skeletonNode:stopAllActions()
					local arr = {}
					table.insert(arr,cc.DelayTime:create(1.1))
					table.insert(arr,cc.CallFunc:create(function()
						if args.type == 0 then
							EquipmentModel:updateWearEqList(args.pos,args.list[1],info)
						end 
						if eqData.w then
							local newScore = EquipmentModel:calcCombat({code = args.list[1].code,uuid = args.list[1].uuid})
							RollTips.showAddFightPoint(newScore - eqData.score)
						end
						if tolua.isnull(self.view) then return end
						self:showEqByPos(args.list[1].uuid)
						self.shengx.action = false
					end))
					self.now.skeletonNode:runAction(cc.Sequence:create(arr))
				end)
			end,88)
	else
		if  self.curPageId == 0 then
			self.maxCtl:setSelectedIndex(2)
			if not self.man.itemcell then
				self.man.itemcell = BindManager.bindItemCell(self.man:getChildAutoType("itemCell"))
				--self.man.itemcell.view:removeClickListener()
				--self.now.itemcell:setIsBig(true)
				self.man.cardStar= BindManager.bindCardStar(self.man:getChildAutoType("cardStar"))
			end
			self.man.itemcell:setData(eqInfo.id,0,CodeType.ITEM)
			self.man.cardStar:setData(eqInfo.staramount)
			self.man:setTitle(eqInfo.name)
		else
			self.maxCtl:setSelectedIndex(0)
		end
		
		nextInfo = {}
		showList = self.equipInfo
		self.shengx:setTouchable(false)
		self.shengx:setGrayed(true)
	end

	
	local sx = {}
		
	if nextInfo.hp ~= 0 then
		table.insert(sx,{name = Desc.equipment_sx1, key="hp", value = eqInfo.hp,upgrade = nextInfo.hp})
	end

	if nextInfo.attack ~= 0 then
		table.insert(sx,{name = Desc.equipment_sx2, key="attack", value = eqInfo.attack,upgrade = nextInfo.attack})
	end
	if nextInfo.defense ~= 0 then
		table.insert(sx,{name = Desc.equipment_sx3, key="defense", value = eqInfo.defense,upgrade = nextInfo.defense})
	end
	if nextInfo.magic ~= 0 then
		table.insert(sx,{name = Desc.equipment_sx4, key="magic", value = eqInfo.magic,upgrade = nextInfo.magic})
	end
	if nextInfo.magicDefense ~= 0 then
		table.insert(sx,{name = Desc.equipment_sx5, key="magicDefense", value = eqInfo.magicDefense,upgrade = nextInfo.magicDefense})
	end
	if nextInfo.speed ~= 0 then
		table.insert(sx,{name = Desc.equipment_sx6, key="speed", value = eqInfo.speed,upgrade = nextInfo.speed})
	end

	local len = #sx
	local i = 1;
	while (i < len) do
		local data = sx[i]
		if data and data.value == 0 then
			table.remove(sx,i)
		else
			i = i + 1
		end
	end
	
	showList:setItemRenderer(function(index,obj)
			local sxInfo = sx[index+1]
			local name = obj:getChildAutoType("name")
			name:setText(sxInfo.name)
			local value = obj:getChildAutoType("value")
			value:setText(sxInfo.value)
			local upgrade = obj:getChildAutoType("upgrade")
			if upgrade then
				upgrade:setText(sxInfo.upgrade)
			end

		end)
	
	showList:setNumItems(#sx)
end



function EquipmentRecastView:setRightArea2( eqInfo,eqData )
	
	if not self.eqitem.itemcell then
		self.eqitem.itemcell = BindManager.bindItemCell(self.eqitem:getChildAutoType("itemCell"))
		--self.eqitem.itemcell.view:removeClickListener()
		if not self.eqitem:getChildAutoType("itemCell/frameBg") then
			self.eqitem.itemcell:setIsBig(true)
		end
		self.eqitem.cardStar= BindManager.bindCardStar(self.eqitem:getChildAutoType("cardStar"))
	end
	self.eqitem.itemcell:setData(eqInfo.id,0,CodeType.ITEM)
	self.eqitem.cardStar:setData(eqInfo.staramount)
	
	self.eqitem:setTitle(eqInfo.name)

	if eqData.w then
		local infoData= CardLibModel:getHeroByUid(eqData.hid)
		self.group4:setVisible(true)
		self.heroName:setText(infoData.heroDataConfiger.heroName)
		self.heroLevel:setText("lv."..infoData.level)

	else
		self.group4:setVisible(false)
	end
	
	local max = 20;
	local cur = tonumber(eqData.d.prob or eqData.d.__data.specialData.equipment.prob)
	local temp_sk = EquipmentModel:getSkillData(eqData.uuid)
	if temp_sk and temp_sk.prob then
		cur = temp_sk.prob
	end
	--self.progressBar:setMax(max)
	--self.progressBar:setValue(cur)
	if cur then
		-- self.xinyuanTxt:setText(Desc.equipment_xinyuan..cur.."/")
		self.xinyuanTxt:setText("("..cur.."/20)")
	end
	self.maxCtl:setSelectedIndex(0)
	
	
	printTable(33,"eqInfo = ",eqInfo)
	local costData = EquipmentModel:getCastConfigByColor(eqInfo.color).cost
	local function costFunc()
		
		--printTable(33,"costData = ",costData)
		--消耗道具显示
		if tolua.isnull(self.view) then return end
		self.toollist:setItemRenderer(function(index,obj)
				--local itemcell = BindManager.bindItemCell(obj)
				-- local itemData = ItemsUtil.createItemData({data = costData[index+1]})
				-- --itemcell:setItemData(itemData)
				-- self:resetItemCell(index, obj,costData[index+1] ,itemData)
				--[[obj:removeClickListener(88)
				obj:addClickListener(function( ... )
						itemcell:onClickCell(index)
					end,88)--]]
					local data = costData[index+1]
					local costItem = BindManager.bindCostItem(obj)
					costItem:setGreenColor("#3cfe45")
					costItem:setRedColor("#ff3b3b")
					costItem:setData(data.type,data.code,data.amount,true)
			end)
		self.toollist:setNumItems(#costData)
	end
	costFunc()
	

	self.chongzhu:removeClickListener(88)
	self.chongzhu:addClickListener(function( ... )
			if self.chongzhu.action then return end
			if not PlayerModel:isCostEnough(costData) then
				return
			end
			self.chongzhu.action = true
			local info = {}
			info.itemUuid = eqData.uuid
			if eqData.w then
				info.heroUuid = eqData.hid
			end
			RPCReq.Equipment_Recasting(info,function(args)
					printTable(33,"Equipment_Recasting callback",args)
					EquipmentModel:setSkillData(args.list[1].uuid,args.list[1])
					if tolua.isnull(self.view) then return end
					self.spine2:setVisible(true)
					self.spine3:setVisible(true)

					self.spine2.skeletonNode:setAnimation(0,"ui_zhongzhu",false)
					self.spine3.skeletonNode:setAnimation(0,"ui_zhongzhu",false)

					self.spine2.skeletonNode:setCompleteListener(function(name)
						if name == "ui_zhongzhu" then
							self.spine2:setVisible(false)
							self.spine3:setVisible(false)
						end
					end)
					self.spine2.skeletonNode:stopAllActions()
					local arr = {}
					table.insert(arr,cc.DelayTime:create(0.3))
					table.insert(arr,cc.CallFunc:create(function()
						self.xinyuanTxt:setText("("..tonumber(args.list[1].prob).."/20)")
						self.chongzhuState = true
						local config = args.list[1]
						if config.showSkill and #config.showSkill > 0 then
							self.newskill:setItemRenderer(function(index,obj)
								local titleCtrl = obj:getController("titleCtrl")
								titleCtrl:setSelectedIndex(1)
								local skillCtrl = obj:getController("skillCtrl")
								skillCtrl:setSelectedIndex(0)
								local skillCell = BindManager.bindSkillCell(obj:getChildAutoType("skillCell"))
								skillCell:setEquipmentData(config.showSkill[index+1],1)
								local conf = EquipmentModel:getSkillConfigByCode(config.showSkill[index+1])
								obj:getChildAutoType("title1"):setText(conf.skillName)
							end)
							self.newskill:setNumItems(#config.showSkill)
						end
						costFunc()
						self.ForgeState:setSelectedIndex(1)
						self.chongzhu.action = false
					end))
					self.spine2.skeletonNode:runAction(cc.Sequence:create(arr))
				end)
		end,88)

	self.btn_change:removeClickListener(111)
	self.btn_change:addClickListener(function()
		local info = {}
		info.itemUuid = eqData.uuid
		if eqData.w then
			info.heroUuid = eqData.hid
		end
		if not self.chongzhuState then
			RollTips.show(Desc.Equipmentforge_chongzhuTips)
			return
		end
		RPCReq.Equipment_SaveRecasting(info,function(args)
			EquipmentModel:setSkillData(args.list[1].uuid,args.list[1])
			local newScore = EquipmentModel:calcCombat(args.list[1])
			if eqData.w then
				RollTips.showAddFightPoint(newScore-eqData.score)
				eqData.score = newScore
			end
			self.chongzhuState = false
			Dispatcher.dispatchEvent(EventType.equipment_refresheq)
			RollTips.show(Desc.equipment_save)
			-- self:closeView()
			self.newskill:setItemRenderer(function(index,obj)
				local titleCtrl = obj:getController("titleCtrl")
				titleCtrl:setSelectedIndex(1)
				local skillCtrl = obj:getController("skillCtrl")
				skillCtrl:setSelectedIndex(1)
			end)
			self.newskill:setNumItems(2)
			self.ForgeState:setSelectedIndex(0)
		end)
	end,111)
	
	--local ppos1 = self.progressBar:getPosition()
	--local ppos2 = self.xinyuan:getPosition()
	--self.xinyuan:setPosition(ppos1.x+self.progressBar:getWidth()*cur/max -self.xinyuan:getWidth()/2 ,ppos2.y)
	self.btn_xinyuan:removeClickListener(88)
	self.btn_xinyuan:addClickListener(function( ... )
			local skilldatas = EquipmentModel:getSkillData(eqData.uuid)
			ViewManager.open("EquipmentHopeView",{
				uuid = eqData.uuid,
				hid = eqData.hid or "",
				hopeSkill = skilldatas.hopeSkill,
				position = eqInfo.position
			})
		end,33)
	
	self:equipment_updateSkillData(eqData.uuid)
	
end

function EquipmentRecastView:equipment_updateSkillData(uuid)

	local skilldata = EquipmentModel:getSkillData(uuid)
	if skilldata  then
		if skilldata.skill and #skilldata.skill>0 then
			printTable(33,"skilldata = ",skilldata.skill)
			self.skill1:setItemRenderer(function(index,obj)
					local titleCtrl = obj:getController("titleCtrl")
					titleCtrl:setSelectedIndex(1)
					local skillInfo = EquipmentModel:getSkillConfigByCode(skilldata.skill[index+1])
					obj:getChildAutoType("title1"):setVisible(true)
					obj:getChildAutoType("title1"):setText(skillInfo.skillName)
					local skillCell = obj:getChildAutoType("skillCell")
					skillCell:getChildAutoType("n29"):setVisible(false)
					local skillCell = BindManager.bindSkillCell(skillCell)
					skillCell:setEquipmentData(skillInfo.skillID,0)
					-- obj:setTitle(skillInfo.skillName)
					--obj:getChildAutoType("desc"):setText(skillInfo.skillDesc)
				end)
			local num = #skilldata.skill
			if num > 2 then num = 2 end
			self.skill1:setNumItems(num)
			self.newskill:setItemRenderer(function(index,obj)
				local titleCtrl = obj:getController("titleCtrl")
				titleCtrl:setSelectedIndex(1)
				local skillCtrl = obj:getController("skillCtrl")
				skillCtrl:setSelectedIndex(1)
			end)
			self.newskill:setNumItems(2)
		else
			self.skill1:setNumItems(0)
			self.newskill:setItemRenderer(function(index,obj)
				local titleCtrl = obj:getController("titleCtrl")
				titleCtrl:setSelectedIndex(1)
				local skillCtrl = obj:getController("skillCtrl")
				skillCtrl:setSelectedIndex(1)
			end)
			self.newskill:setNumItems(2)
		end

	else
		self.skill1:setNumItems(0)
		self.newskill:setItemRenderer(function(index,obj)
			local titleCtrl = obj:getController("titleCtrl")
			titleCtrl:setSelectedIndex(1)
			local skillCtrl = obj:getController("skillCtrl")
			skillCtrl:setSelectedIndex(1)
		end)
		self.newskill:setNumItems(2)
		--self.skill2:setNumItems(0)
	end
end

function EquipmentRecastView:setRightArea1( eqInfo,eqData ,obj)
	if obj and not tolua.isnull(obj) then
		local itemCongfig = DynamicConfigData.t_item[eqInfo.id]
		if itemCongfig and itemCongfig.decompose then
			if obj:isSelected() then
				EquipmentModel:addDecompose(self.selectDecompose,itemCongfig.decompose)
				self.selectDecomposeGrid[eqData.grid] = eqData.uuid
				printTable(33,"addDecompose:"..eqInfo.id,self.selectDecomposeGrid)
			else
				EquipmentModel:delDecompose(self.selectDecompose,itemCongfig.decompose)
				self.selectDecomposeGrid[eqData.grid] = nil
				printTable(33,"delDecompose",self.selectDecomposeGrid)
			end
		end
	end 
	
	
	
	-- self.curDecomposeType = 2  -- 0
	self.combob:setTitle(Desc.equipment_pinzhi)
	self.DecomposeShowData = {}
	for k,v in pairs(self.selectDecompose) do
		table.insert(self.DecomposeShowData,v)
	end
	
	self.getlist:setNumItems(#self.DecomposeShowData)
	
	if #self.DecomposeShowData > 0 then
		self.view:getChildAutoType("n54"):setVisible(false)
	end

end

function EquipmentRecastView:equipment_refresheq()
	
	self:refresh()
end

function EquipmentRecastView:refresh()
	if tolua.isnull(self.list) then return end
	--if self.curPos ~= EquipmentModel.curPos then
	self.curPos = EquipmentModel.curPos
	self.list.secondTab:setSelectedIndex(self.curPos)
	--end
	self:showEqByPos()
	-- end
end

function EquipmentRecastView:Equipment_rebuildSelect(_, uuid)
	EquipmentModel.curEqUUID = uuid;
	self.curData = false
	self:showEqByPos()
end

function EquipmentRecastView:_exit()
	for k,v in pairs(self.scheduler) do
		if self.scheduler[k] then
			Scheduler.unschedule(self.scheduler[k])
	        self.scheduler[k] = false
		end
	end
end
return EquipmentRecastView
