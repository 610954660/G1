--Name : PveStarTempleStartAnswerView.lua
--Author : generated by FairyGUI
--Date : 2020-7-31
--Desc : 

local PveStarTempleStartAnswerView,Super = class("PveStarTempleStartAnswerView", Window)

function PveStarTempleStartAnswerView:ctor()
	--LuaLog("PveStarTempleStartAnswerView ctor")
	self._packName = "PveStarTemple"
	self._compName = "PveStarTempleStartAnswerView"
	self._rootDepth = LayerDepth.PopWindow
	self.areaID = self._args.areaID
	self.pos = self._args.pos
end

function PveStarTempleStartAnswerView:_initEvent( )
	
end

function PveStarTempleStartAnswerView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:PveStarTemple.PveStarTempleStartAnswerView
		--{vmFieldsEnd}:PveStarTemple.PveStarTempleStartAnswerView
	--Do not modify above code-------------
end

function PveStarTempleStartAnswerView:_initUI( )
	self:_initVM()
	self.btnStart = self.view:getChildAutoType("btnStart")
	self.model = self.view:getChildAutoType("model")
	self.model:setScale(0.7,0.7)
	self.btnStart:addClickListener(function()
		self:onBtnStartClick()
	end,1)

	local spine = SpineUtil.createHeroDraw(nil,Vector2(0,0),15003)
	self.model:displayObject():addChild(spine)
	spine:setPosition(400,200)

	self.view:getChildAutoType("n5"):setURL(PathConfiger.getPveStarTempleBG("startanswer_frame"))
end

function PveStarTempleStartAnswerView:_exit()
	self.areaID = false
	self.pos = false
end

function PveStarTempleStartAnswerView:onBtnStartClick()
	ViewManager.open("PveStarTempleAnswerView",{areaID = self.areaID,pos = self.pos})
	self:closeView()
end

return PveStarTempleStartAnswerView