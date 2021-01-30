--[[
name: VoidlandSkillView2
author: zn
]]

--local base = require "Game.Modules.Voidland.VoidSkillBaseView";
local DevilEventView = class("DevilEventView", Window)

function DevilEventView:ctor()
	self._packName = "SealDevil";
	self._compName = "DevilEventView";
	self._rootDepth = LayerDepth.PopWindow
	--self.bgUrl = "UI/Voidland/bg2.png";
	--self.roleUrl = "UI/Voidland/role.png";
	
	
	self.listData={}
	
	--for _, skill in pairs(self._args.skillList) do
		--table.insert(self.skillList, skill);
	--end
end

function DevilEventView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:SealDevil.DevilEventView
	self.bg = viewNode:getChildAutoType('bg')--GLoader
	self.btn_ok = viewNode:getChildAutoType('btn_ok')--GButton
	self.closeButton = viewNode:getChildAutoType('closeButton')--GButton
	self.eventDesc = viewNode:getChildAutoType('eventDesc')--GTextField
	self.eventName = viewNode:getChildAutoType('eventName')--GTextField
	self.list_skill = viewNode:getChildAutoType('list_skill')--GList
	self.role = viewNode:getChildAutoType('role')--GLoader
	self.tip = viewNode:getChildAutoType('tip')--GComponent
	self.txt_countDown = viewNode:getChildAutoType('txt_countDown')--GRichTextField
	--{autoFieldsEnd}:SealDevil.DevilEventView
	--Do not modify above code-------------
	
end


function DevilEventView:_initUI( )
	self:_initVM()
	self:triggerEvent()
	self.btn_ok:addClickListener(function ()
			self:closeView()
	end)

end


function DevilEventView:triggerEvent()
	local eventType=self._args.data.eventType
	local type=self._args.data.type
	
	local descData=DynamicConfigData.t_DevilRoadDesc[type][eventType]
	if descData then
		self.eventName:setText(descData.eventName)
		self.eventDesc:setText(descData.eventDesc)
	end
	
	
	if eventType==GameDef.DevilRoadEventType.Buff then
		for k, v in pairs(self._args.data.buffs) do
			table.insert(self.listData,v)
		end
		self.list_skill:setItemRenderer(function(idx, obj)
              self:upSkillItems(idx, obj)
		end)

		self.list_skill:setNumItems(#self.listData)	

	elseif eventType==GameDef.DevilRoadEventType.Revived then

	elseif eventType==GameDef.DevilRoadEventType.Damage then

	elseif eventType==GameDef.DevilRoadEventType.Hero then
	    local heroInfo=DynamicConfigData.t_DevilRoadHero[self._args.data.assistId]
        table.insert(self.listData,heroInfo)
		self.list_skill:setItemRenderer(function(idx, obj)
				obj:getController("cellType"):setSelectedPage("hero")
				local heroCell=BindManager.bindHeroCell(obj:getChildAutoType("heroCell"))
                local heroData=self.listData[idx+1]
				heroData.code=heroData.heroCode
				heroCell:setBaseData(heroData)		
		end)
		
		self.list_skill:setNumItems(#self.listData)
	end

end




function DevilEventView:upSkillItems(idx, obj)
	---- print(2233, "======== VoidlandSkillView2:upSkillItems");
	local skillId = self.listData[idx + 1];
	local skillCell = BindManager.bindSkillCell(obj:getChildAutoType("skillCell"))
	local skillConf = DynamicConfigData.t_DevilRoadSkill[skillId];
	--local VoidSkillConf = DynamicConfigData.t_VoidlandSkill[skillId];
	if (skillConf) then
		local url = ModelManager.CardLibModel:getItemIconByskillId(skillConf.icon)
		skillCell.iconLoader:setURL(url)
	end
	-- obj:getChildAutoType("txt_skillName"):setText(skillConf.skillName);
	obj:getChildAutoType("txt_desc/txt_desc"):setText(skillConf.showName);
end


return DevilEventView