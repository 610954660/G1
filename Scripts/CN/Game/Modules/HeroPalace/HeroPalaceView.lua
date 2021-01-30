--Name : HeroPalaceView.lua
--Author : wyang
--Date : 2020-5-21
--Desc :
--local SeatItem=require "Game.Modules.Battle.Cell.SeatItem"
local HeroPalaceView,Super = class("HeroPalaceView", Window)

function HeroPalaceView:ctor()
	self._packName = "HeroPalace"
	self._compName = "HeroPalaceView"
	
	self.list_item = false
	self.btn_upgrade = false
	self.txt_crystalLv = false
	self.costBar_upgrade = false
	self.txt_num = false
	self.txt_Level = false
	self.fullStarCardNum = false
	self.effectLoader = false
	self.c1 = false
	
	
	self.effectMc = false
	
	
	self._upgradeCost = false
	self.listData = {{},{},{},{},{},{},{},{},{},{},{}}
	
	self.chooseUuids = {}
	
	self.countDownIds = {}
	
	self.seatItems = {}
end

function HeroPalaceView:_initUI( )
	self:setBg("bg_heroPalace.jpg")
	local heroListBoard = self.view:getChildAutoType("heroListBoard")
	local heroPos = self.view:getChildAutoType("heroPos")

	self.c1 = self.view:getController("c1")
	self.list_item = heroListBoard:getChildAutoType("list_item")
	self.txt_num = heroListBoard:getChildAutoType("txt_num")
	self.effectLoader = self.view:getChildAutoType("effectLoader")
	self.btn_upgrade = self.view:getChildAutoType("btn_upgrade")
	self.txt_crystalLv = self.view:getChildAutoType("txt_crystalLv")
	self.txt_Level = self.view:getChildAutoType("txt_Level")
	
	RedManager.register("V_TACTICAL_UPGRADE", self.btn_upgrade:getChild("img_red"))
	
	local costBar_upgrade =  self.view:getChildAutoType("costBar_upgrade")
	self.costBar_upgrade = BindManager.bindCostBar(costBar_upgrade)
	self.costBar_upgrade:setDarkBg(true)
	
	for i=1,6,1 do 
		local seat = heroPos:getChildAutoType("seatItem"..i)
		seat:getChildAutoType("heroInfo"):setPosition(48, -50)
		local seatCell=BindManager.bindSeatItem(seat)
		seatCell.index = i
		self.seatItems[i] = seatCell
		if i == 6 then
			seat:getChildAutoType("level"):setColor(ColorUtil.textColor_Light.green)
		end
	end

	
	self:updateHeroList()
	self:updateCrystal()
	self:updateGroupA()
	self:updateGroupB()
	
	self:activeHint()
end


function HeroPalaceView:_initEvent( )
	self.btn_upgrade:addClickListener(
				function(...)
					self:doUpgrade()
				end,100
			)
	
end

--更新水晶等级信息
function HeroPalaceView:updateCrystal()
	if ModelManager.HeroPalaceModel.crystal then
		if not self.fullStarCardNum then self.fullStarCardNum  = ModelManager.CardLibModel:getFullStarCardNum() end
		local maxLv = ModelManager.HeroPalaceModel:getCrystalMaxLv(self.fullStarCardNum)
		self.txt_crystalLv:setText(string.format(Desc.heroPalace_lv, ModelManager.HeroPalaceModel.crystal, maxLv))
		local upgradeInfo = DynamicConfigData.t_HeroPalaceUplevel[ModelManager.HeroPalaceModel.crystal + 1]
		if ModelManager.HeroPalaceModel.crystal < maxLv and upgradeInfo then
			self.c1:setSelectedIndex(1)
			self._upgradeCost = upgradeInfo.cost
			self.costBar_upgrade:setData(upgradeInfo.cost, false)
			if not self.effectMc then
				self.effectMc = SpineUtil.createSpineObj(self.effectLoader, vertex2(0,0), "animation", "Spine/ui/heroPalace", "efx_shuijing", "efx_shuijing",true)
			end
		else
			self.c1:setSelectedIndex(2)
			
		end
	else
		self.c1:setSelectedIndex(0)
	end
end


function HeroPalaceView:updateGroupA()
	for i = 1,6,1 do
		local info = ModelManager.HeroPalaceModel:getPosAInfo(i)
		if info and info.uuid then
			self.seatItems[i].view:setVisible(true)
			local heroInfo = ModelManager.CardLibModel:getHeroByUid(info.uuid)
			if heroInfo then
				local fashionId = heroInfo.fashion and heroInfo.fashion.code or nil
				self.seatItems[i]:initItemCell(heroInfo.heroId,heroInfo.star,heroInfo.level,nil,fashionId, heroInfo.uniqueWeaponLevel)
			end
		else
			self.seatItems[i].view:setVisible(false)
		end
	end
	
	self.txt_Level:setText(string.format(Desc.heroPalace_lv, HeroPalaceModel:getLevel()))
end

function HeroPalaceView:updateGroupB()
	local heroNum = ModelManager.HeroPalaceModel:getHeroNumB()
	local totalNum = ModelManager.HeroPalaceModel.crystal and (ModelManager.HeroPalaceModel.openIdx + 6) or ModelManager.HeroPalaceModel.openIdx
	self.txt_num:setText(heroNum.."/"..totalNum)
	local totalGrid = ModelManager.HeroPalaceModel.crystal and #self.listData or (#self.listData - 6)
	self.list_item:setNumItems(totalGrid)
end



function HeroPalaceView:updateHeroList(board)
	self.listData = {}
	for _,v in ipairs(DynamicConfigData.t_HeroPalace) do
		table.insert(self.listData, v)
	end
	if ModelManager.HeroPalaceModel.crystal then
		--如果满200级后，把type等于3的格式排在前面
		TableUtil.sortByMap(self.listData, {{key="type", asc=true},{key="id", asc = false}})
	else
		TableUtil.sort(self.listData, function(a,b)
			local typeA = a.type == 2 and 0 or a.type
			local typeB = b.type == 2 and 0 or b.type
			if typeA == typeB then
				return a.id - b.id
			else
				return typeA - typeB
			end
		end)
	end
	
	self.list_item:setItemRenderer(
        function(index, obj)
			local data = self.listData[index + 1]
			local pos = data.id
			if self.countDownIds[index + 1] then
				CountDownUtil.stop(self.countDownIds[index + 1])
			end
			local statusCtrl = obj:getController("c1")
			local btn_active =  obj:getChildAutoType("btn_active")
			local btn_active2 =  obj:getChildAutoType("btn_active2")
			local btn_add =  obj:getChildAutoType("btn_add")
			local btn_takeOff =  obj:getChildAutoType("btn_takeOff")
			local btn_coolDown =  obj:getChildAutoType("btn_coolDown")
			local txt_time =  obj:getChildAutoType("txt_time")
			local cardItem =  obj:getChildAutoType("cardItem")
			local txt_level = cardItem:getChildAutoType("txt_level")
			
			
			
			local actived = pos <= ModelManager.HeroPalaceModel.openIdx
			local posInfo = ModelManager.HeroPalaceModel:getPosBInfo(pos)
			local posSetting = DynamicConfigData.t_HeroPalace[pos]	
			
			
			
			local cardInfo =(posInfo and posInfo.uuid) and ModelManager.CardLibModel:getHeroByUid(posInfo.uuid) or false
			if cardInfo then
				if cardInfo.level ~= posInfo.level then
					txt_level:setColor(ColorUtil.textColor_Light.green)
				else
					txt_level:setColor(ColorUtil.textColor_Light.white)
				end
			end
				
			local time = (posInfo and posInfo.coolTime) and  (posInfo.coolTime - ModelManager.ServerTimeModel:getServerTime()) or 0
			if data.type == 3 and ModelManager.HeroPalaceModel.crystal then actived = true end
			obj:setVisible(true)
			if not actived then
				--未解锁
				if pos == ModelManager.HeroPalaceModel.openIdx + 1 then
					statusCtrl:setSelectedIndex(0)
					RedManager.register("V_HEROPALACE_ACTIVE", obj:getChild("img_red"))
				else
					statusCtrl:setSelectedIndex(4)
					RedManager.register("", obj:getChild("img_red"))
				end
				
				if #posSetting.openItem1 == 0 then
					obj:setVisible(false)
				end
			elseif time > 0 then
				--需冷却
				RedManager.register("", obj:getChild("img_red"))
				statusCtrl:setSelectedIndex(3)
				local endTime = posInfo.coolTime
				local countDownId = CountDownUtil.startNew(time*1000, 1000, function() 
					local timeLeft = endTime - ModelManager.ServerTimeModel:getServerTime()	
					txt_time:setText(DateUtil.getTimeStrBySec(timeLeft))
				end,
				function()
					statusCtrl:setSelectedIndex(1)
					if pos ==ModelManager.HeroPalaceModel.openIdx + 1 then
						RedManager.register("V_HEROPALACE_ACTIVE", obj:getChild("img_red"))
					else
						RedManager.register("", obj:getChild("img_red"))
					end
				end,self)
				
				self.countDownIds[index + 1] = countDownId
			elseif cardInfo then
				--已选择
				RedManager.register("", obj:getChild("img_red"))
				statusCtrl:setSelectedIndex(2)
				local cardCell = BindManager.bindCardCell(cardItem)
				cardCell:setData(cardInfo, true)
			else
				RedManager.register("V_TACTICAL_ADD", obj:getChild("img_red"))
				--未选择
				statusCtrl:setSelectedIndex(1)
			end		
			btn_active:removeClickListener(100)
			btn_active:addClickListener(
				function(...)
				   self:doActive(pos)
				end,100
			)

			btn_active2:removeClickListener(100)
			btn_active2:addClickListener(
				function(...)
				   self:doActive(pos)
				end,100
			)
		
			btn_coolDown:removeClickListener(100)
			btn_coolDown:addClickListener(
				function(...)
				   self:doCoolDown(pos)
				end,100
			)
				
			btn_add:removeClickListener(100)
			btn_add:addClickListener(
				function(...)
				   self:doChoose(pos)
				end,100
			)
			
			btn_takeOff:removeClickListener(100)
			btn_takeOff:addClickListener(
				function(...)
				   self:doTakeOff(pos)
				end,100
			)
		end
	)
end

function HeroPalaceView:clearAllCountDown()
	for _,v in pairs(self.countDownIds) do
		CountDownUtil.stop(v)
	end
end

function HeroPalaceView:activeHint()
	local pos = ModelManager.HeroPalaceModel.openIdx + 1
	local posInfo = DynamicConfigData.t_HeroPalace[pos]	
	if #posInfo.openItem1 > 0 then
		local costName1 = ItemConfiger.getItemNameByCode(posInfo.openItem1[1].code, posInfo.openItem1[1].type)
		local costName2 = ItemConfiger.getItemNameByCode(posInfo.openItem2[1].code, posInfo.openItem2[1].type)
		local costNameIcon1 = ItemConfiger.getItemIconStrByCode(posInfo.openItem1[1].code, posInfo.openItem1[1].type)
		local costNameIcon2 = ItemConfiger.getItemIconStrByCode(posInfo.openItem2[1].code, posInfo.openItem2[1].type, true)
		
		local cost = {}
		local hintStr
		if ModelManager.PlayerModel:isCostEnough(posInfo.openItem1, false) then
			cost = posInfo.openItem1
			hintStr = string.format(Desc.heroPalace_active1, costName1, costNameIcon1, ColorUtil.textColorStr.green, posInfo.openItem1[1].amount)
		end
		if hintStr then
			local info = {}
			info.text = hintStr
			info._rootDepth = LayerDepth.PopWindow
			info.align = "center"
			info.type = "yes_no"
			--info.cost = {posInfo.openItem1[1],posInfo.openItem2[1]}
			info.costType = {
				-- {type = GameDef.ItemType.Money, code = GameDef.MoneyType.Friend},
				posInfo.openItem1[1], 
				posInfo.openItem2[1]
			}
			info.hintEx = Desc.heroPalace_active3
			info.onlyHasNum = true
			info.onYes = function()
				if ModelManager.PlayerModel:isCostEnough(cost, true) then
					ModelManager.HeroPalaceModel:doOpenIndexReq(pos)
				end
			end
			
			Alert.show(info)
		end
	end
end

function HeroPalaceView:doActive(pos)
	if pos ~= ModelManager.HeroPalaceModel.openIdx + 1 then
		RollTips.show(Desc.heroPalace_activePrev)
		return
	end
	
	local posInfo = DynamicConfigData.t_HeroPalace[pos]	
	if #posInfo.openItem1 > 0 then
		local costName1 = ItemConfiger.getItemNameByCode(posInfo.openItem1[1].code, posInfo.openItem1[1].type)
		local costName2 = ItemConfiger.getItemNameByCode(posInfo.openItem2[1].code, posInfo.openItem2[1].type)
		local costNameIcon1 = ItemConfiger.getItemIconStrByCode(posInfo.openItem1[1].code, posInfo.openItem1[1].type)
		local costNameIcon2 = ItemConfiger.getItemIconStrByCode(posInfo.openItem2[1].code, posInfo.openItem2[1].type, true)
		
		local cost = {}
		local hintStr
		if ModelManager.PlayerModel:isCostEnough(posInfo.openItem1, false) then
			hintStr = string.format(Desc.heroPalace_active1, costName1, costNameIcon1, ColorUtil.textColorStr.green, posInfo.openItem1[1].amount)
		else--if ModelManager.PlayerModel:isCostEnough(posInfo.openItem2, false) then
			cost = posInfo.openItem2
			local openItem2 = posInfo.openItem2[1]
			local moneyNumStr = posInfo.openItem2[1].amount
			if ModelManager.PlayerModel:isCostEnough(posInfo.openItem1,false) then
				moneyNumStr = string.format(Desc.common_ColorStr, ColorUtil.textColorStr.green, posInfo.openItem2[1].amount)
			else
				moneyNumStr = string.format(Desc.common_ColorStr, ColorUtil.textColorStr.red, posInfo.openItem2[1].amount)
			end
			hintStr = string.format(Desc.heroPalace_active2, costName1, posInfo.openItem1[1].amount, costNameIcon2, moneyNumStr)
		--else
		--	cost = posInfo.openItem2   --如果两个都不够，要点确定时跳转去充值
		--	hintStr = string.format(Desc.heroPalace_active3, posInfo.openItem1[1].amount, costName1, posInfo.openItem2[1].amount, costName2)
		end
		
		local info = {}
		info.text = hintStr
		info._rootDepth = LayerDepth.PopWindow
		info.type = "yes_no"
		info.align = "center"
		info.costType = {
			-- {type = GameDef.ItemType.Money, code = GameDef.MoneyType.Friend},
			posInfo.openItem1[1], 
			posInfo.openItem2[1]
		}
		--info.cost = {posInfo.openItem1[1],posInfo.openItem2[1]}
		info.hintEx = Desc.heroPalace_active3
		info.onlyHasNum = true
		info.onYes = function()
			if ModelManager.PlayerModel:isCostEnough(cost, true) then
				ModelManager.HeroPalaceModel:doOpenIndexReq(pos)
			end
		end
		
		Alert.show(info)
	end
end

function HeroPalaceView:doChoose(pos)
	local chooseUuids = ModelManager.HeroPalaceModel:getChooseUuids()
	ViewManager.open("CardChooseView", {noLock = false, noBattle = false, callback = function(self, cardInfo)   
		print(1, "CardChooseView.doChoose", cardInfo.uuid)
		ModelManager.HeroPalaceModel:doAddReq(pos, cardInfo.uuid)
	end, caller = self, excludeUuids = chooseUuids})
end


function HeroPalaceView:doCoolDown(pos)
	local posInfo = DynamicConfigData.t_HeroPalace[pos]
	if ModelManager.PlayerModel:isCostEnough(posInfo.cost) then
		local info = {}
		info.text = string.format(Desc.heroPalace_coolDown, posInfo.cost[1].amount, Desc["common_moneyType"..posInfo.cost[1].code])

		info.type = "yes_no"
		info.onYes = function()
			ModelManager.HeroPalaceModel:doClearCoolTimeReq(pos)
		end
		
		Alert.show(info)
	end
end

function HeroPalaceView:doUpgrade()
	if ModelManager.PlayerModel:isCostEnough(self._upgradeCost) then
		ModelManager.HeroPalaceModel:doUpgradeCrystalReq()
	end
end

function HeroPalaceView:doTakeOff(pos)
	ViewManager.open("HeroPalaceRemoveView", {pos = pos})
end


function HeroPalaceView:heroPalace_groupAChange(pos)
	self:updateGroupA()
end

function HeroPalaceView:heroPalace_groupBChange(pos)
	self:updateGroupB()
end

function HeroPalaceView:heroPalace_crystalChange()
	self:updateCrystal()
end

function HeroPalaceView:heroPalace_heroLvUp(evnt, data)
	ViewManager.open("HeroPalaceUpLvView", data)
end


function HeroPalaceView:_exit()
	self:clearAllCountDown()
	--SpineMnange.clearAll()
end

return HeroPalaceView