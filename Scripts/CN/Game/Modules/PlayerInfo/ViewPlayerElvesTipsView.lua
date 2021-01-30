--Date :2021-01-22
--Author : generated by FairyGUI
--Desc : 

local ViewPlayerElvesTipsView,Super = class("ViewPlayerElvesTipsView", Window)

function ViewPlayerElvesTipsView:ctor(args)
	--LuaLog("ViewPlayerElvesTipsView ctor")
	self._packName = "PlayerInfo"
	self._compName = "ViewPlayerElvesTipsView"
	self._rootDepth = LayerDepth.Tips
	
	self.data = args.data
	self.fullData = args.fullData
	
	
	self.levelAddData = false
end

function ViewPlayerElvesTipsView:_initEvent( )
	
end

function ViewPlayerElvesTipsView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:PlayerInfo.ViewPlayerElvesTipsView
	self.blackbgAlpha = viewNode:getChildAutoType('blackbgAlpha')--GLabel
	self.btn_closeTotal = viewNode:getChildAutoType('btn_closeTotal')--GLabel
	self.btn_full = viewNode:getChildAutoType('btn_full')--GButton
	self.iconLoader = viewNode:getChildAutoType('iconLoader')--skillIconLoader
		self.iconLoader.iconLoader = viewNode:getChildAutoType('iconLoader/iconLoader')--GLoader
	self.img_bg = viewNode:getChildAutoType('img_bg')--GImage
	self.list_attrLvTotal = viewNode:getChildAutoType('list_attrLvTotal')--GList
	self.list_levelAdd = viewNode:getChildAutoType('list_levelAdd')--GList
	self.list_starAttrTotal = viewNode:getChildAutoType('list_starAttrTotal')--GList
	self.totlaAttrBoard = viewNode:getChildAutoType('totlaAttrBoard')--GGroup
	self.txt_desc = viewNode:getChildAutoType('txt_desc')--GTextField
	self.txt_level = viewNode:getChildAutoType('txt_level')--GTextField
	self.txt_levelName = viewNode:getChildAutoType('txt_levelName')--GTextField
	self.txt_name = viewNode:getChildAutoType('txt_name')--GTextField
	self.txt_starAdd = viewNode:getChildAutoType('txt_starAdd')--GTextField
	--{autoFieldsEnd}:PlayerInfo.ViewPlayerElvesTipsView
	--Do not modify above code-------------
end

function ViewPlayerElvesTipsView:_initListener( )
	
	self.btn_full:addClickListener(function()
		self.btn_closeTotal:setVisible(true)
		self.totlaAttrBoard:setVisible(true)
	end)

	self.btn_closeTotal:addClickListener(function()
		self.btn_closeTotal:setVisible(false)
		self.totlaAttrBoard:setVisible(false)
	end)

	self.list_attrLvTotal:setItemRenderer(function(index, obj)
		local txt_name = obj:getChildAutoType("txt_name")
		local txt_value = obj:getChildAutoType("txt_value")
		local data = self.fullData.upgradeAttr[index + 1]
		
		txt_name:setText(GMethodUtil:getFightAttrName(data.type))
        local attrValue=GMethodUtil:getFightAttrName(data.type,data.value)
        txt_value:setText(attrValue)
	end)

	self.list_starAttrTotal:setItemRenderer(function(index, obj)
		local txt_name = obj:getChildAutoType("txt_name")
		local data = self.fullData.starAttr[index + 1]
		txt_name:setText(data)
	end)

	self.list_levelAdd:setItemRenderer(function(index, obj)
		local txt_name = obj:getChildAutoType("txt_name")
		local txt_num = obj:getChildAutoType("txt_num")
		local data = self.levelAddData[index + 1]
		
		txt_name:setText(GMethodUtil:getFightAttrName(data.type))
        local attrValue=GMethodUtil:getFightAttrName(data.type,data.value)
        txt_num:setText(attrValue)
	end)

end

function ViewPlayerElvesTipsView:_initUI( )
	self:_initVM()
	self:_initListener()
	
	local elfConfig = DynamicConfigData.t_ElfMain[self.data.id][self.data.level]
	self.txt_name:setText(elfConfig.elfName)
	self.txt_level:setText(self.data.level)
	self.iconLoader.iconLoader:setURL(ItemConfiger.getItemIconByCode(self.data.id))
		
	local starConfig = DynamicConfigData.t_ElfStar[self.data.id][self.data.star]	
	self.txt_desc:setText(starConfig.skillTipDesc)
	self.txt_starAdd:setText(starConfig.desc)
	
	local skinConfig = DynamicConfigData.t_ElfSkin[self.data.id] and DynamicConfigData.t_ElfSkin[self.data.id][self.data.skinId]
	
	local attrMap = {}

	for _,attr in pairs(elfConfig.attribute) do
		if not attrMap[attr.type] then
			attrMap[attr.type] = attr.value
		else
			attrMap[attr.type] = attrMap[attr.type] + attr.value
		end
	end
	
	if skinConfig then
		for _,attr in pairs(skinConfig.basicAttr) do
			if not attrMap[attr.type] then
				attrMap[attr.type] = attr.value
			else
				attrMap[attr.type] = attrMap[attr.type] + attr.value
			end
		end
	end


	
	local attrList = {}
	for k,v in pairs(attrMap) do
		table.insert(attrList, {type = k, value = v})
	end
	
	self.levelAddData = attrList	
	self.list_levelAdd:setNumItems(#self.levelAddData)
	
	self.list_starAttrTotal:setNumItems(#self.fullData.starAttr)
	self.list_attrLvTotal:setNumItems(#self.fullData.upgradeAttr)
	
	
end




return ViewPlayerElvesTipsView