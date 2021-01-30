---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: ljj
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local CardAttrView, Super = class("CardAttrView", Window)

function CardAttrView:ctor()
    self._packName = "CardSystem"
    self._compName = "CardAttrView"
	self._rootDepth = LayerDepth.PopWindow
	self._isFullScreen = true
	
	self.listData = {}
	self.listData2 = {}
    
	self.attrTipsBoard = false
	self.closeTipsBtn = false 
end

function CardAttrView:_initUI()
	local list_attr = self.view:getChild("list_attr")
	local valueMap = {};
	list_attr:setItemRenderer(
        function(index, obj)
			local txt_attrName = obj:getChild("txt_attrName")
			local txt_value = obj:getChild("txt_value")
			local btn_attr = obj:getChild("btn_attr")
			
			local info  = self.listData[index + 1]
			btn_attr:removeClickListener()
			btn_attr:addClickListener(function( ... )
				local pos1=btn_attr:localToGlobal(vertex2(0,0))
				self:showAttrTips(pos1, info)
			end)
			
			
			if info.text then
				txt_attrName:setText(info.name)
				txt_value:setText(info.text)
			else
				txt_attrName:setText(info.name)
				-- local hero = ModelManager.CardLibModel.curCardStepInfo
				-- local attrs = hero.attrs 
				local value = valueMap[info.attrId] or 0
				-- for _,v in pairs(attrs) do
				-- 	if v.id == info.attrId then
				-- 		value = v.value
				-- 		break
				-- 	end
				-- end
				-- if hero.fashion and hero.fashion.code then
				-- 	local fashion = DynamicConfigData.t_Fashion[hero.heroId][hero.fashion.code]
				-- 	if fashion then
				-- 		local attr = fashion.attr
				-- 		for _,attr in pairs(attrs) do
				-- 			if attr.id == info.attrId then
				-- 				value = value + attr.value
				-- 			end
				-- 		end
				-- 	end
				-- end
				local percent = value/100
				txt_value:setText(percent.." %")
			end
		end
	)
	
	local conf = DynamicConfigData.t_combat
	for _,v in pairs(conf) do
		if v.display == 2 then
			table.insert(self.listData, v)
		end
	end
	-- 配置含assign的都是要特殊处理的
	local hero = ModelManager.CardLibModel.curCardStepInfo
	local attrs = hero.attrs
	for _,v in pairs(attrs) do
		if (conf[v.id]) then
			local assign = conf[v.id].assign
			if (next(assign)) then
				for _, id in pairs(assign) do
					valueMap[id] = valueMap[id] and valueMap[id] + v.value or v.value
				end
			else
				valueMap[v.id] = valueMap[v.id] and valueMap[v.id] + v.value or v.value
			end
		end
	end
	
	
	TableUtil.sortByMap(self.listData, {{key="seq", asc = false}})
	list_attr:setData(self.listData)
	
	
	local list_attr2 = self.view:getChild("list_attr2")
	
	list_attr2:setItemRenderer(
        function(index, obj)
			local txt_attrName = obj:getChild("txt_attrName")
			local txt_value = obj:getChild("txt_value")
			local btn_attr = obj:getChild("btn_attr")
			
			local info  = self.listData2[index + 1]
			--[[btn_attr:removeClickListener()
			btn_attr:addClickListener(function( ... )
				local pos1=btn_attr:localToGlobal(vertex2(0,0))
				self:showAttrTips(pos1, info)
			end)--]]
			
			if info.text then
				txt_attrName:setText(info.name)
				txt_value:setText(info.text)
			else
				txt_attrName:setText(info.name)
				local hero = ModelManager.CardLibModel.curCardStepInfo
				local attrs = hero.attrs 
				local value = 0
				for _,v in pairs(attrs) do
					if v.id == info.attrId then
						value = v.value
						break
					end
				end
				local percent = math.floor(value/100*100)/100
				txt_value:setText(percent.." %")
			end
		end
	)
	
	local hero = ModelManager.CardLibModel.curCardStepInfo
	table.insert(self.listData2, {name = Desc.card_attrAdd1, text = string.format(Desc.card_attrAddLevel, SecretWeaponsModel:getCurLevel())})
	table.insert(self.listData2, {name = string.format(Desc.card_attrAdd2, Desc["common_creer"..hero.heroDataConfiger.professional]), text = string.format(Desc.card_attrAddLevel, GuildModel:getguildskillLevel(hero.heroDataConfiger.professional))})
	table.insert(self.listData2, {name = Desc.card_attrAdd3, text = RuneSystemModel:checkHeroHadEquip(hero.uuid) or Desc.card_noRune})
	table.insert(self.listData2, {name = Desc.card_attrAdd4, text = DutyModel:getCurDutyName()})
	table.insert(self.listData2, {name = Desc.card_attrAdd5, text = string.format(Desc.card_attrAddLevel, HandbookModel:GetLinkingLevelById(hero.heroId))})
	
	list_attr2:setData(self.listData2)
	
	self.attrTipsBoard = self.view:getChildAutoType("attrTipsBoard")
	self.closeTipsBtn = self.view:getChildAutoType("closeTipsBtn")
	self.closeTipsBtn:removeClickListener()
	self.closeTipsBtn:addClickListener(function( ... )
		self.attrTipsBoard:setVisible(false)
		self.closeTipsBtn:setVisible(false)
	end)
	
	local frame = self.view:getChildAutoType("frame")
	frame:removeClickListener(1000)
	frame:addClickListener(function( ... )
		self.attrTipsBoard:setVisible(false)
		self.closeTipsBtn:setVisible(false)
	end,1000)
end

function CardAttrView:showAttrTips(pos, data)
	self.attrTipsBoard:setVisible(true)
	self.closeTipsBtn:setVisible(true)
	local txt_name = self.attrTipsBoard:getChildAutoType("txt_name")
	local txt_desc = self.attrTipsBoard:getChildAutoType("txt_desc")
	txt_name:setText(data.name)
	txt_desc:setText(data.attrshow)
	
	local posLocal = self.view:globalToLocal(pos)
	self.attrTipsBoard:setPosition(posLocal.x + 20, posLocal.y + 30)
end

function CardAttrView:closeAttrTips()
	
end

--保存后关闭窗口
function CardAttrView:cardView_configurationPoint()
	--self:closeView()
end

function CardAttrView:_exit()

end

function CardAttrView:_enter()
end

return CardAttrView
