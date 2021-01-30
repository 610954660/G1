--Date :2020-12-10
--Author : wyz
--Desc : 组队竞技 结算界面（战斗胜利）

local CrossTeamPVPEndView,Super = class("CrossTeamPVPEndView", Window)

function CrossTeamPVPEndView:ctor()
	--LuaLog("CrossTeamPVPEndView ctor")
	self._packName = "CrossTeamPVP"
	self._compName = "CrossTeamPVPEndView"
	--self._rootDepth = LayerDepth.Window
	
end

function CrossTeamPVPEndView:_initEvent( )
	
end

function CrossTeamPVPEndView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossTeamPVP.CrossTeamPVPEndView
	self.checkWin = viewNode:getController('checkWin')--Controller
	self.danIconLoader = viewNode:getChildAutoType('danIconLoader')--GLoader
	self.txt_danTitle = viewNode:getChildAutoType('txt_danTitle')--GTextField
	self.txt_integral = viewNode:getChildAutoType('txt_integral')--GRichTextField
	self.txt_rank = viewNode:getChildAutoType('txt_rank')--GRichTextField
	self.txt_rankTitle = viewNode:getChildAutoType('txt_rankTitle')--GTextField
	self.txt_rankup = viewNode:getChildAutoType('txt_rankup')--GRichTextField
	--{autoFields5End}:CrossTeamPVP.CrossTeamPVPEndView
	--Do not modify above code-------------
end

function CrossTeamPVPEndView:_initUI( )
	self:_initVM()
	self:refreshPanel()
end

function CrossTeamPVPEndView:refreshPanel()
	local txt_upTips = self.view:getChildAutoType("txt_upTips")
	local isMax 	 = self.view:getController("isMax")
	local data = CrossTeamPVPModel.battleResultInfo or {}
	local txt_danName = self.view:getChildAutoType("txt_danName")
	self.txt_rank:setText(string.format(Desc.CrossTeamPVP_resultRankWin1,data.myRank or 0,data.addRank or 0))
	self.txt_integral:setText(string.format(Desc.CrossTeamPVP_resultIntegralWin1,data.myScore or 0 ,data.addScore or 0))

	local danInfo,danInfo2 = CrossTeamPVPModel:getCurDanInfoByIntegral(data.myScore or 0) 
	txt_danName:setText(string.format(Desc["HigherPvP_rankColor"..danInfo.icon], danInfo.name));
	self.danIconLoader:setIcon(string.format("Icon/rank/%s.png", danInfo.icon));	
	isMax:setSelectedIndex(danInfo2 and 0 or 1)
	if danInfo2 then
		local myScore = data.myScore or 0
		txt_upTips:setText(string.format(Desc.CrossTeamPVP_resultTips1,(danInfo2.min-myScore),danInfo2.name))
	end
		
end





return CrossTeamPVPEndView