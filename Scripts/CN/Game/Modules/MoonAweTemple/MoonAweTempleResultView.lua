--Date :2020-12-04
--Author : generated by FairyGUI
--Desc : 

local MoonAweTempleResultView,Super = class("MoonAweTempleResultView", Window)

function MoonAweTempleResultView:ctor()
	--LuaLog("MoonAweTempleResultView ctor")
	self._packName = "MoonAweTemple"
	self._compName = "MoonAweTempleResultView"
	--self._rootDepth = LayerDepth.Window
	
end

function MoonAweTempleResultView:_initEvent( )
	
end

function MoonAweTempleResultView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:MoonAweTemple.MoonAweTempleResultView
	self.haloIcon = viewNode:getChildAutoType('haloIcon')--GLoader
	self.itemCell = viewNode:getChildAutoType('itemCell')--GButton
	self.txt_attr = viewNode:getChildAutoType('txt_attr')--GRichTextField
	self.txt_title = viewNode:getChildAutoType('txt_title')--GTextField
	--{autoFieldsEnd}:MoonAweTemple.MoonAweTempleResultView
	--Do not modify above code-------------
end

function MoonAweTempleResultView:_initUI( )
	self:_initVM()
	self:refreshPanal()
end

function MoonAweTempleResultView:refreshPanal()
	local godId 		= MoonAweTempleModel.resultInfo.godId
	local godInfo 		= DynamicConfigData.t_MoonTempleBasic[godId]
	local crownInfo 	= DynamicConfigData.t_CrownTitle 		-- 称号信息
	local crownId 		= godInfo.crownId

	local itemCell 		= BindManager.bindItemCell(self.itemCell)
	itemCell:setData(crownInfo[crownId].code,0,CodeType.ITEM)
	
	self.txt_attr:setText(crownInfo[crownId].attrType)
	self.haloIcon:setURL(string.format("UI/MoonAweTemple/%s.png",crownId))
	-- self.txt_title:setText(string.format(Desc.MoonAweTemple_godName,godInfo.name))
end

function MoonAweTempleResultView:_exit()

end


return MoonAweTempleResultView