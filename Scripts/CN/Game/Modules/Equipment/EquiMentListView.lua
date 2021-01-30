--Name : EquiMentListView.lua
--Author : generated by FairyGUI
--Date : 2020-6-28
--Desc : 

local EquiMentListView,Super = class("EquiMentListView", View)
local  HeroConfiger = require "Game.ConfigReaders.HeroConfiger"

function EquiMentListView:ctor()
	--LuaLog("EquiMentListView ctor")
	self._packName = "Equipment"
	self._compName = "EquiMentListView"
	self._rootDepth = LayerDepth.PopWindow
	
	self.equipWearScore = 0 --身上穿的装备评分
end

function EquiMentListView:_initEvent( )
	
end

function EquiMentListView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:Equipment.EquiMentListView
		vmRoot.list = viewNode:getChildAutoType("$list")--list
	--{vmFieldsEnd}:Equipment.EquiMentListView
	--Do not modify above code-------------
end

function EquiMentListView:_initUI( )
	self:_initVM()
	self.curPos = EquipmentModel.curPos

	
	self.view:getChildAutoType("blackBg"):addClickListener(function()
		self:closeView()
	end,33)
	self.list:setVirtual();
	self.list:setItemRenderer(function(index,obj)
			self:itemShow(obj,index)
		end)
	self:equipment_refresheq( )
	
end


function EquiMentListView:equipment_refresheq( )
	
	self.data = {}
	self.equipWearScore  = 0
	if self._args.eqdata then
		local eqInfo = EquipmentModel:getConfingByCode(self._args.eqdata.code)
		local info = {}
		info.eqinfo = eqInfo
		info.uuid = self._args.eqdata.uuid
		local totalPower  = EquipmentModel:calcCombat(self._args.eqdata)--HeroConfiger.CaleAttrPower(eqInfo)
		--[[local skilldata = EquipmentModel:getSkillData(info.uuid)
		if skilldata  then
			totalPower = totalPower + HeroConfiger.CaleSkillPower(skilldata)
		end--]]
		info.totalPower = totalPower
		self.equipWearScore  = totalPower
		--table.insert(self.data,info)
	end
	
	
	local data = EquipmentModel:getEquipBag().__packItems
	
	for k,v in pairs(data) do
		local eqInfo = EquipmentModel:getConfingByPackItem(v)
		if eqInfo.position == self.curPos and (eqInfo.attType == 0 or eqInfo.attType == EquipmentModel.attType ) then
			local info = {}
			info.eqinfo = eqInfo
			info.uuid = v.__data.uuid
			
			
			local totalPower = 0
			totalPower = EquipmentModel:calcCombat(v.__data)--HeroConfiger.CaleAttrPower(eqInfo)
			--[[local skilldata = EquipmentModel:getSkillData(info.uuid)
			if skilldata  then
				totalPower = totalPower + HeroConfiger.CaleSkillPower(skilldata)
			end--]]
			info.totalPower = totalPower
			--[[if totalPower > self.equipWearScore then
				info.needRed = true
			end--]]
			
			table.insert(self.data,info)
		end
	end
	
	
	local curWear = false
	data = EquipmentModel:getWearEqList()
	for m,n in pairs(data) do
		for k,v in pairs(n) do
			local eqInfo = EquipmentModel:getConfingByCode(v.code)
			if eqInfo.position == self.curPos  then
	
				local info = {}
				info.eqinfo = eqInfo
				info.uuid = v.uuid
				
				
				local totalPower = 0
				totalPower = EquipmentModel:calcCombat(v)
				info.totalPower = totalPower
				--[[if totalPower > self.equipWearScore then
					info.needRed = true
				end--]]
				info.heroUuid = m
				self.equipWearScore = totalPower
				if EquipmentModel.hid == m then
					info.w = true
					curWear = info
				else
					info.heroid = ModelManager.CardLibModel:getHeroByUid(m).heroDataConfiger.heroId
					table.insert(self.data,1,info)
				end
				
				print(33,"ssss  heroid = ",info.heroid)
				--break
			end
		end
	end
	
	local function cmp(a,b)
		return a.totalPower > b.totalPower
	end
	table.sort(self.data,cmp)
	if curWear then
		table.insert(self.data,1,curWear)
	end
	print(33,"showEqByPos data = ",#self.data)
	self.list:setNumItems(#self.data)
end

function EquiMentListView:itemShow( obj,index )

	local eqdata = self.data[index+1];
	local eqInfo = eqdata.eqinfo
	
	if eqdata.w then
		obj:getController("state"):setSelectedIndex(1)
	else
		obj:getController("state"):setSelectedIndex(0)
	end
	
	if eqdata.heroid then
		obj:getChildAutoType("hero_icon"):setVisible(true)
		print(33,"setURL = ",PathConfiger.getHeroCard(eqdata.heroid))
		obj:getChildAutoType("hero_icon"):setURL(PathConfiger.getHeroCard(eqdata.heroid))--放了卡牌图片
	else
		obj:getChildAutoType("hero_icon"):setVisible(false)
	end
	
	local shuxing = obj:getChildAutoType("shuxing")
	local jineng = obj:getChildAutoType("jineng")
	
	--obj:getChildAutoType("frame"):setURL(PathConfiger.getItemFrame(eqInfo.color, false))
	--print(33,"getEqIconByeCode = ",EquipmentModel:getEqIconByeCode(eqInfo.id))
	--obj:getChildAutoType("icon"):setURL(EquipmentModel:getEqIconByeCode(eqInfo.id))
	if not obj.itemcell then
		obj.itemcell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"))
		obj.itemcell.view:removeClickListener()
	end
	obj.itemcell:setData(eqInfo.id,0,CodeType.ITEM)
	obj.itemcell:setStars()
	
	
	obj:getChildAutoType("name"):setText(eqInfo.name)
	obj:getChildAutoType("power"):setText(eqdata.totalPower)
	obj:getChildAutoType("btn_c"):getChildAutoType("img_red"):setVisible(eqdata.totalPower > self.equipWearScore)
	obj:getChildAutoType("btn_t"):addClickListener(function()
			self:takeOff(eqInfo,self.curPos,eqdata.heroUuid)
		end,33)
	
	obj:getChildAutoType("btn_c"):addClickListener(function()
			if eqdata.heroid then
				self:takeOff(eqInfo,self.curPos,eqdata.heroUuid,function(uuid)
					self:wear( eqInfo,uuid)
				end)
			else
				self:wear( eqInfo,eqdata.uuid)
			end
		end,33)
	
	local sx = {}
	if eqInfo.hp>0 then
		sx[#sx+1] = {name = Desc.equipment_sx1, key="hp", value = eqInfo.hp}
	end
	if eqInfo.attack>0 then
		sx[#sx+1] = {name = Desc.equipment_sx2, key="attack", value = eqInfo.attack}
	end
	if eqInfo.defense>0 then
		sx[#sx+1] = {name = Desc.equipment_sx3, key="defense", value = eqInfo.defense}
	end
	if eqInfo.magic>0 then
		sx[#sx+1] = {name = Desc.equipment_sx4, key="magic", value = eqInfo.magic}
	end
	if eqInfo.magicDefense>0 then
		sx[#sx+1] = {name = Desc.equipment_sx5, key="magicDefense", value = eqInfo.magicDefense}
	end
	if eqInfo.speed>0 then
		sx[#sx+1] = {name = Desc.equipment_sx6, key="speed", value = eqInfo.speed}
	end
	
	shuxing:setItemRenderer(function(index,obj)
			local sxInfo = sx[index+1]
			local name = obj:getChildAutoType("name")
			name:setText(sxInfo.name.." :")
			local value = obj:getChildAutoType("value")
			value:setText(sxInfo.value)

		end)
	shuxing:setNumItems(#sx)
	

	local uuid = eqdata.uuid
	
	local skilldata = EquipmentModel:getSkillData(uuid)

	if skilldata and  skilldata.skill and #skilldata.skill>0 then
		printTable(33,"skilldata = ",skilldata.skill)
		jineng:setItemRenderer(function(index,obj)
				local skillInfo = EquipmentModel:getSkillConfigByCode(skilldata.skill[index+1])
				local skillId = tonumber(skilldata.skill[index+1])
				local skillCell = BindManager.bindSkillCell(obj)
				skillCell:setEquipmentData(skillId,eqInfo.position)
				obj:getChildAutoType("n29"):setVisible(false)
				local itemName = obj:getChildAutoType("itemName")
				obj:getController("c1"):setSelectedIndex(1)
				obj:getController("c2"):setSelectedIndex(2)
				itemName:setFontSize(36)
				--itemName:setAutoSize(2)
				itemName:setColor({r=69,g=69,b=69})
				itemName:setText(skillInfo.skillName)
				--itemName:setPosition(obj:getWidth()-5,itemName:getPosition().y)
			end)
		jineng:setNumItems(#skilldata.skill)
		obj:getController("skill"):setSelectedIndex(1)
	else
		jineng:setNumItems(0)
		obj:getController("skill"):setSelectedIndex(0)
	end
	
end
function EquiMentListView:takeOff( eqInfo,pos,hid,func )

	RPCReq.Equipment_TakeOff({type = 0,pos = pos,heroUuid = hid},function(args)
			printTable(33,"Equipment_TakeOff call back",args)
			if args.isSuccess and args.list and args.list[1] then
				local downEquip = args.list[1]
				EquipmentModel:upBagEquip(downEquip)
				EquipmentModel:setSkillData(downEquip.uuid, downEquip)
				EquipmentModel:updateWearEqList(args.pos)
				RollTips.show(Desc.equipment_ttips:format(eqInfo.name))
				if func then
					func(downEquip.uuid)
				end
			end
		end)
end

function EquiMentListView:wear( eqInfo,uuid,pos,hid )

	local oldAttr = ModelManager.CardLibModel:getHeroByUid(EquipmentModel.hid).attrs
	local oldCombat = ModelManager.CardLibModel:getHeroByUid(EquipmentModel.hid).combat
	RPCReq.Equipment_Wear({type = 0,pos = eqInfo.position,heroUuid = EquipmentModel.hid,itemUuid =uuid},
		function(args)
			printTable(33,"Equipment_Wear call back",args)
			local downEquip = (args.oldList and #args.oldList > 0) and args.oldList[1] or nil;
			if (downEquip) then
				EquipmentModel:setSkillData(downEquip.uuid, downEquip)
				EquipmentModel:upBagEquip(downEquip)
			end
			EquipmentModel:updateWearEqList(args.pos,args.list[1])
			RollTips.show(Desc.equipment_ctips:format(eqInfo.name))
			--㣬
			GlobalUtil.delayCallOnce("EquipmentCompareView:updateWearEqList",function()
					local heroData = ModelManager.CardLibModel:getHeroByUid(EquipmentModel.hid)
					local newAttr = heroData.attrs
					RollTips.showAttrTips(oldAttr, newAttr)
					local newCombat = heroData.combat
					local addNum = newCombat - oldCombat
					if addNum > 0 then
						RollTips.showAddFightPoint(addNum)
					end
				end, 0.2)
		end)
end

return EquiMentListView