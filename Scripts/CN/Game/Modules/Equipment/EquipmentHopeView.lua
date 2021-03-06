--Name : EquipmentHopeView.lua
--Author : generated by FairyGUI
--Date : 2020-4-6
--Desc : 

local EquipmentHopeView,Super = class("EquipmentHopeView", Window)

function EquipmentHopeView:ctor()
	--LuaLog("EquipmentHopeView ctor")
	self._packName = "Equipment"
	self._compName = "EquipmentHopeView"
	self._rootDepth = LayerDepth.PopWindow
	
	self.curSkill = false
end

function EquipmentHopeView:_initEvent( )
	
end

function EquipmentHopeView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:Equipment.EquipmentHopeView
		vmRoot.selectlist = viewNode:getChildAutoType("$selectlist")--list
		vmRoot.name = viewNode:getChildAutoType("$name")--text
		vmRoot.btn_select = viewNode:getChildAutoType("$btn_select")--Button
		vmRoot.skillname = viewNode:getChildAutoType("$skillname")--text
		vmRoot.save = viewNode:getChildAutoType("$save")--Button
		vmRoot.buwei = viewNode:getChildAutoType("$buwei")--text
		vmRoot.skilllist = viewNode:getChildAutoType("$skilllist")--list
		vmRoot.desc = viewNode:getChildAutoType("$desc")--text
	--{vmFieldsEnd}:Equipment.EquipmentHopeView
	--Do not modify above code-------------
end

function EquipmentHopeView:_initUI( )
	self:_initVM()
	
	
	self.cur_skillCell = BindManager.bindSkillCell(self.view:getChildAutoType("skillCell"))
	
	
	local eqSkill = DynamicConfigData.t_equipskill
	local eqArr = {}
	for k,v in pairs(eqSkill) do
		for _, limit in ipairs(v.positionLimit) do
			if self._args.position == limit then
				table.insert(eqArr,v)
				break
			end
		end
	end
	
	local selectData = self._args.hopeSkill
	if not selectData or #selectData == 0 then
		selectData = {eqArr[1].skillID,eqArr[2].skillID,eqArr[3].skillID,eqArr[4].skillID,eqArr[5].skillID}
		RPCReq.Equipment_SaveHopeSkill({itemUuid = self._args.uuid,heroUuid = self._args.hid,skill = selectData},function (args)
				printTable(33,"Equipment_SaveHopeSkill callback",args)
				EquipmentModel:setSkillData(args.list[1].uuid,args.list[1])
			end)
	else
		for i=#selectData,6,-1 do
			selectData[i] = nil
		end
	end
	

	self.curSelect = {}
	self.selectItem = {}
	local unmm = 1
	for k,v in pairs(selectData) do
		local info = {}
		info.pos = k
		info.code = v
		info.data = EquipmentModel:getSkillConfigByCode(v)
		self.curSelect["key"..v] = info
		self.curSelect[unmm] = info
		unmm = unmm + 1
	end
	self.save:addClickListener(function( ... )
			local xykill = {}
			for i=1,5  do
				if self.curSelect[i].item then
					table.insert(xykill,self.curSelect[i].code)
				end
			end
			if #xykill == 5 then
				RPCReq.Equipment_SaveHopeSkill({itemUuid = self._args.uuid,heroUuid = self._args.hid,skill = xykill},function (args)
						printTable(33,"Equipment_SaveHopeSkill callback",args)
						EquipmentModel:setSkillData(args.list[1].uuid,args.list[1])
						RollTips.show(Desc.equipment_save)
				end)
			else
				RollTips.show(Desc.equipment_xytips)
			end
		end)
	self.btn_select:addClickListener(function( ... )
			if not self.curSkill then return end
			local add =true
			local index = 0
			for i=5,1,-1  do
				if not  self.curSelect[i].item  then
					index = i
				else
					if self.curSelect[i].code == self.curSkill.skillID then
						RollTips.show(Desc.equipment_hopetips2)
						return
					end
				end
				
			end
			if index > 0 and add then
				self.curSelect[index].select(self.curSkill)
				self.curSelect[index].item = true
				self.curSelect[index].code = self.curSkill.skillID
				self.curSelect[index].data = self.curSkill
			else
				RollTips.show(Desc.equipment_hopetips)
			end
			local grade = false
			for i=1,5  do
				if not  self.curSelect[i].item  then
					grade = true
				end
			end
			self.save:setGrayed(grade)
			self.save:setTouchable(not grade)
			self.btn_select:setGrayed(not grade)
			self.btn_select:setTouchable(grade)
			
		end)
	
	self.btn_select:setGrayed(true)
	self.btn_select:setTouchable(false)
	
	self.selectlist:setItemRenderer(function(index,obj)
			local curData = self.curSelect[index+1]
			local skillInfo = self.curSelect[index+1].data
			
			
			local icon = obj:getChildAutoType("skillCell")
			local title = obj:getChildAutoType("title")
			local del = obj:getChildAutoType("del")
			local add = obj:getChildAutoType("add")
			local select = obj:getChildAutoType("select")
			local skillCell = BindManager.bindSkillCell(obj:getChildAutoType("skillCell"))
			skillCell:setEquipmentData(skillInfo.skillID,1)
			skillCell.iconLoader:setTouchable(false);
			self.curSelect[index+1].item = true
			select:setVisible(false)
			add:setVisible(false)
			self.curSelect[index+1].select = function(newskill)
				skillCell:setEquipmentData(newskill.skillID,1)
				icon:setVisible(true)
				--icon:setIcon()
				title:setVisible(true)
				title:setText(newskill.skillName)
				--add:setVisible(false)
				del:setVisible(true)
			end
			
			
			title:setVisible(true)
			title:setText(skillInfo.skillName)
			
			
			del:setVisible(true)
			del:setTouchable(true)
			del:removeClickListener(88)
			del:addClickListener(function( ... )
					del:setVisible(false)
					title:setVisible(false)
					--icon:setVisible(false)
					--add:setVisible(true)
					skillCell:setEquipmentData()
					self.curSelect["key"..skillInfo.skillID] = nil
					
					self.curSelect[index+1].item = false

					self.save:setGrayed(true)
					self.save:setTouchable(false)
					self.btn_select:setGrayed(false)
					self.btn_select:setTouchable(true)
				end,88)
			
		end)
	self.selectlist:setNumItems(#selectData)
	
	self.skilllist:setVirtual()
	self.skilllist:setItemRenderer(function(index,obj)
			obj:setName(index)
			local skillInfo = eqArr[index+1]
			obj:getChildAutoType("title"):setVisible(true)
			obj:setTitle(skillInfo.skillName)
			local skillCell = BindManager.bindSkillCell(obj:getChildAutoType("skillCell"))
			skillCell:setEquipmentData(skillInfo.skillID)
			
			local select = obj:getChildAutoType("select")
			select:setVisible(true)
			--local cinfo = self.curSelect["key"..skillInfo.skillID]
			--if  cinfo then
				--select:setVisible(true)
				--cinfo.item = obj
			--else
				--select:setVisible(false)
			--end
			--local longP = false
			--obj:getChildAutoType("skillCell"):addLongPressListener(function(context)
					--longP = true
					--ViewManager.open("ItemTips", {codeType = CodeType.EQUIPMENT_SKILL, id = skillInfo.skillID})
				--end)
			
			local function clickFunc()
				self.curSkill = skillInfo
				self.cur_skillCell:setEquipmentData(skillInfo.skillID,1)
				self.skillname:setText(skillInfo.skillName)
				local text = Desc.equipment_pos
				if #skillInfo.positionLimit >=4 then
					text = text..Desc.equipment_posAll
				else
					for k,v in pairs(skillInfo.positionLimit) do
						text = text.."["..Desc["common_equipPosT"..v].."]"
					end
				end

				self.desc:setText(skillInfo.skillDesc)
				self.buwei:setText(text)
			end
			
			obj:removeClickListener(88)
			obj:addClickListener(clickFunc)
			if index == 0 then clickFunc() end
					--if longP then
						--longP = false
						--return
					--end
					--if select:isVisible() then
						--return
					--end
					--local add =false
					--for i=1,5  do
						--if not  self.curSelect[i].item  then
							--self.curSelect[i].select(skillInfo)
							--self.curSelect[i].item = obj
							--self.curSelect[i].code = skillInfo.skillID
							--self.curSelect[i].data = EquipmentModel:getSkillConfigByCode(skillInfo.skillID)
							--select:setVisible(true)
							--add = true
							--break
						--end
					--end
					--if not add then
						--RollTips.show(Desc.equipment_hopetips)
					--end
				--end)
			--obj:getChildAutoType("desc"):setText(skillInfo.skillDesc)
		end)
	self.skilllist:setNumItems(#eqArr)
	self.skilllist:setSelectedIndex(0)
end




return EquipmentHopeView