--Date :2020-12-30
--Author : generated by FairyGUI
--Desc : 

local CrossLaddersEndView,Super = class("CrossLaddersEndView", View)

function CrossLaddersEndView:ctor()
	--LuaLog("CrossLaddersEndView ctor")
	self._packName = "CrossLadders"
	self._compName = "CrossLaddersEndView"
	--self._rootDepth = LayerDepth.Window
	
end

function CrossLaddersEndView:_initEvent( )
	
end

function CrossLaddersEndView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossLadders.CrossLaddersEndView
	self.heroCell1 = viewNode:getChildAutoType('heroCell1')--GButton
	self.heroCell2 = viewNode:getChildAutoType('heroCell2')--GButton
	self.rankCtrl = viewNode:getController('rankCtrl')--Controller
	self.txt_addRank = viewNode:getChildAutoType('txt_addRank')--GTextField
	self.txt_curRank = viewNode:getChildAutoType('txt_curRank')--GTextField
	self.txt_danTitle = viewNode:getChildAutoType('txt_danTitle')--GTextField
	self.txt_myName = viewNode:getChildAutoType('txt_myName')--GTextField
	self.txt_myPower = viewNode:getChildAutoType('txt_myPower')--GTextField
	self.txt_otherName = viewNode:getChildAutoType('txt_otherName')--GTextField
	self.txt_otherPower = viewNode:getChildAutoType('txt_otherPower')--GTextField
	self.txt_rankTitle = viewNode:getChildAutoType('txt_rankTitle')--GTextField
	self.txt_tips = viewNode:getChildAutoType('txt_tips')--GTextField
	--{autoFieldsEnd}:CrossLadders.CrossLaddersEndView
	--Do not modify above code-------------
end

function CrossLaddersEndView:_initListener( )
	local rankInfo = CrossLaddersModel.challengeList
	local myRankData = rankInfo.myRankData or {}
	self.heroCell1:addClickListener(function()

	end)
	-- self.heroCell1:setHead()
	local heroCell1 = BindManager.bindPlayerCell(self.heroCell1)
	heroCell1:setHead(myRankData.head, myRankData.level, myRankData.id,nil,myRankData.headBorder)
	self.txt_myName:setText(myRankData.name)
	self.txt_myPower:setText(StringUtil.transValue(myRankData.combat))

	local otherEndInfo = CrossLaddersModel.otherEndInfo or {}
	local heroCell2 = BindManager.bindPlayerCell(self.heroCell2)
	heroCell2:setHead(otherEndInfo.head, otherEndInfo.level, otherEndInfo.id,nil,otherEndInfo.headBorder)
	
	self.txt_otherPower:setText(StringUtil.transValue(otherEndInfo.combat))
	self.txt_otherName:setText(otherEndInfo.name)
	
	self.heroCell2:addClickListener(function()

	end)

	self.txt_curRank:setText(string.format(Desc.CrossLadders_str12,CrossLaddersModel.myOldRank))
	self.txt_tips:setText(Desc.CrossLadders_str13)

	self.rankCtrl:setSelectedIndex((CrossLaddersModel.myNewRank-CrossLaddersModel.myOldRank) < 0 and 0 or 1)
	self.txt_addRank:setText(math.abs(CrossLaddersModel.myNewRank-CrossLaddersModel.myOldRank))
	CrossLaddersModel.myRank = CrossLaddersModel.myNewRank
end

function CrossLaddersEndView:_initUI( )
	self:_initVM()
	self:_initListener()

end




return CrossLaddersEndView