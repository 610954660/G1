--Date :2020-12-15
--Author : generated by FairyGUI
--Desc : 

local FashionPreView,Super = class("FashionPreView", MutiWindow)

function FashionPreView:ctor()
	self._packName = "Fashion"
	self._compName = "FashionPreView"
	--self._rootDepth = LayerDepth.Window
end

function FashionPreView:_initUI( )
	self:_initVM()
   	self:setBg("bg_fashionPre.jpg")
    self:createComponentByPageName("FashionPreBtnView")
    self.ctlView["FashionPreBtnView"].view:setSortingOrder(999)
    self:createComponentByPageName("FashionPreBattleView")
    self.ctlView["FashionPreBattleView"].view:setSortingOrder(1)
end

function FashionPreView:_initVM( )

end

function FashionPreView:_exit()
end

return FashionPreView