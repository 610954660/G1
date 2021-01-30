--Name : HeroPalaceRemoveView.lua
--Author : wyang
--Date : 2020-5-21
--Desc : 

local HeroPalaceRemoveView,Super = class("HeroPalaceRemoveView", Window)

function HeroPalaceRemoveView:ctor(args)
	self._packName = "HeroPalace"
	self._compName = "HeroPalaceRemoveView"
	self._rootDepth = LayerDepth.PopWindow
	
	self.cardItem1 = false
	self.cardItem2 = false
	self.txt_time = false
	self.btn_yes = false
	self.btn_no = false
	self.pos = args.pos
end

function HeroPalaceRemoveView:_initUI( )
	self.cardItem1 = self.view:getChildAutoType("cardItem1")
	self.cardItem2 = self.view:getChildAutoType("cardItem2")
	self.txt_time = self.view:getChildAutoType("txt_time")
	
	self.cardItem1:getChildAutoType("txt_level"):setColor(ColorUtil.textColor_Light.green)
	
	
	local cardCell1 = BindManager.bindCardCell(self.cardItem1)
	local cardCell2 = BindManager.bindCardCell(self.cardItem2)
	self.btn_yes = self.view:getChildAutoType("btn_yes")
	self.btn_no = self.view:getChildAutoType("btn_no")
	local info = ModelManager.HeroPalaceModel:getPosBInfo(self.pos)
	local heroInfo = ModelManager.CardLibModel:getHeroByUid(info.uuid)
	
	local posConfig = DynamicConfigData.t_HeroPalace[self.pos]
	self.txt_time:setText(DateUtil.getTimeStrBySec(posConfig.retime))
	cardCell1:setData(heroInfo,true)
	cardCell2:setData(heroInfo,true)
	cardCell2:setLevel(info.level)
end


function HeroPalaceRemoveView:_initEvent( )
	self.btn_yes:addClickListener(function ( ... )
		
		ModelManager.HeroPalaceModel:doRemoveReq(self.pos)
		self:closeView()
	end)
	
	self.btn_no:addClickListener(function ( ... )
		
		self:closeView()
	end)
end





function HeroPalaceRemoveView:_exit()
	
end

return HeroPalaceRemoveView
