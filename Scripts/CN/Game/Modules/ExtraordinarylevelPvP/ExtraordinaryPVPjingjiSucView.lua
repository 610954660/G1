--Date :2021-01-03
--Author : generated by FairyGUI
--Desc : 

local ExtraordinaryPVPjingjiSucView,Super = class("ExtraordinaryPVPjingjiSucView", Window)

function ExtraordinaryPVPjingjiSucView:ctor()
	--LuaLog("ExtraordinaryPVPjingjiSucView ctor")
	self._packName = "ExtraordinarylevelPvP"
	self._compName = "ExtraordinaryPVPjingjiSucView"
	self._rootDepth = LayerDepth.PopWindow
end

function ExtraordinaryPVPjingjiSucView:_initEvent( )
	
end

function ExtraordinaryPVPjingjiSucView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:ExtraordinarylevelPvP.ExtraordinaryPVPjingjiSucView
	self.closeButton = viewNode:getChildAutoType('closeButton')--GLabel
	self.img_duanwei = viewNode:getChildAutoType('img_duanwei')--GLoader
	self.txt_duanwei = viewNode:getChildAutoType('txt_duanwei')--GRichTextField
	--{autoFieldsEnd}:ExtraordinarylevelPvP.ExtraordinaryPVPjingjiSucView
	--Do not modify above code-------------
end

function ExtraordinaryPVPjingjiSucView:_initListener( )
	
end

function ExtraordinaryPVPjingjiSucView:_initUI( )
	self:_initVM()
	self:_initListener()
	self.img_duanwei:setURL(ExtraordinarylevelPvPModel:getDanIcon(self._args.dan))--段位图标
	local desc = ExtraordinarylevelPvPModel:getDanChinese(self._args.dan)--段位文字
	self.txt_duanwei:setText(desc)
end




return ExtraordinaryPVPjingjiSucView