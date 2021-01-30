--Name : HeroPalaceUpLvView.lua
--Author : wyang
--Date : 2020-5-21
--Desc : 

local HeroPalaceUpLvView,Super = class("HeroPalaceUpLvView", Window)

function HeroPalaceUpLvView:ctor(args)
	self._packName = "HeroPalace"
	self._compName = "HeroPalaceUpLvView"
	self._rootDepth = LayerDepth.PopWindow
	
	self.cardItem = false


	self.uuid = args.uuid
	self.oldLevel = args.oldLevel
	self.newLevel = args.newLevel
end

function HeroPalaceUpLvView:_initUI( )
	
	self.view:getChildAutoType("bg_loader"):setURL("UI/HeroPalace/heroPalace_lvUp.png")
	
	
	self.cardItem = self.view:getChildAutoType("cardItem")

	
	local cardCell = BindManager.bindCardCell(self.cardItem)

	local txt_lv1 = self.view:getChildAutoType("txt_lv1")
	local txt_lv2 = self.view:getChildAutoType("txt_lv2")
	local txt_hint = self.view:getChildAutoType("txt_hint")
	local blackBg = self.view:getChildAutoType("blackBg")
	local heroInfo = ModelManager.CardLibModel:getHeroByUid(self.uuid)
	cardCell:setData(heroInfo,true)
	txt_lv1:setText(self.oldLevel)
	txt_lv2:setText(self.newLevel)
	if heroInfo.star < 5 then
		txt_hint:setText(Desc.heroPalace_lvUpHint1)
	else
		if ModelManager.HeroPalaceModel.crystal then
			txt_hint:setText(Desc.heroPalace_lvUpHint3)
		else
			txt_hint:setText(Desc.heroPalace_lvUpHint2)
		end
	end
	blackBg:addClickListener(function()
		self:closeView()
	end)
end


function HeroPalaceUpLvView:_initEvent( )

end





function HeroPalaceUpLvView:_exit()
	
end

return HeroPalaceUpLvView
