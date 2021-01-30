--Date :2021-01-22
--Author : generated by FairyGUI
--Desc : 

local ViewPlayerHallowBaseTipsView,Super = class("ViewPlayerHallowBaseTipsView", Window)

function ViewPlayerHallowBaseTipsView:ctor()
	--LuaLog("ViewPlayerHallowBaseTipsView ctor")
	self._packName = "PlayerInfo"
	self._compName = "ViewPlayerHallowBaseTipsView"
	self._rootDepth = LayerDepth.RollTips
	
end

function ViewPlayerHallowBaseTipsView:_initEvent( )
	
end

function ViewPlayerHallowBaseTipsView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:PlayerInfo.ViewPlayerHallowBaseTipsView
	self.blackbgAlpha = viewNode:getChildAutoType('blackbgAlpha')--GLabel
	self.iconLoader = viewNode:getChildAutoType('iconLoader')--skillIconLoader
		self.iconLoader.iconLoader = viewNode:getChildAutoType('iconLoader/iconLoader')--GLoader
	self.img_bg = viewNode:getChildAutoType('img_bg')--GImage
	self.txt_curAttr = viewNode:getChildAutoType('txt_curAttr')--GTextField
	self.txt_curMaxLv = viewNode:getChildAutoType('txt_curMaxLv')--GTextField
	self.txt_level = viewNode:getChildAutoType('txt_level')--GTextField
	self.txt_levelName = viewNode:getChildAutoType('txt_levelName')--GTextField
	self.txt_name = viewNode:getChildAutoType('txt_name')--GTextField
	--{autoFieldsEnd}:PlayerInfo.ViewPlayerHallowBaseTipsView
	--Do not modify above code-------------
end

function ViewPlayerHallowBaseTipsView:_initListener( )
	
end

function ViewPlayerHallowBaseTipsView:_initUI( )
	self:_initVM()
	self:_initListener()
	
	--local hallowData = DynamicConfigData.t_HallowLevel[self._args.]
	if self._args.hallowBaseLevel > 0  then
		self.iconLoader.iconLoader:setURL(string.format("UI/Hallow/hallow%s.png", self._args.hallowBaseLevel))
	end
	self.txt_name:setText("圣器基座")
	self.txt_level:setText(self._args.hallowBaseLevel)
	
	local curConf = DynamicConfigData.t_HallowStandard[self._args.hallowBaseLevel];
	
	if (not curConf) then
        self.txt_curAttr:setText(string.format(Desc.Hallow_baseAttrAdd, 0));
        self.txt_curMaxLv:setText(string.format(Desc.Hallow_baseLvLimit, 0));
    else
        self.txt_curAttr:setText(string.format(Desc.Hallow_baseAttrAdd, curConf.attrRate / 100));
        self.txt_curMaxLv:setText(string.format(Desc.Hallow_baseLvLimit, curConf.lvLimit));
    end
end




return ViewPlayerHallowBaseTipsView