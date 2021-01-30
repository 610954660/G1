
---------------------------------------------------------------------
-- Win (C) CompanyName, All Right Reserved
-- Created by: lijiejian
-- Date: 2020-01-13 19:30:46
---------------------------------------------------------------------
-- 战斗结算的面板
--
---@class BattleModel

local BattleSettleView,Super = class("BattleSettleView", Window)
local UpdateDescription = require "Configs.Handwork.UpdateDescription"


function BattleSettleView:ctor()
	self._packName = "Battle"
	self._compName = "BattleSettleView"
	
	self.playerSettelment=false--我方阵营的结算面板
	self.enemySettelment=false --地方阵营的结算面板
	
	self.battleData=false--战报数据
	--self._rootDepth = LayerDepth.Window
	
	self.win=false--输赢的动效
	
	--self.closeBt=false
	
	self.myRank=false
	self.addRank=false
	self.addScore=false
	self.myScore=false
	self.rankValue=false
	self.rankValueS=false
	self.battleHeroList=false
	self.heroCellList=false
	self._isFullScreen = true
end

function BattleSettleView:_initUI()
	
	local viewRoot = self.view
	--self.closeBt=self.view:getChildAutoType("closeBt")
	self.myRank=self.view:getChildAutoType("myRank")
	self.addScore=self.view:getChildAutoType("addScore")
	self.myScore=self.view:getChildAutoType("myScore")
	
	self.rankValue=self.view:getChildAutoType("rankValue")
	
	self.battleHeroList=self.view:getChildAutoType("battleHeroList")
	self.heroCellList=self.view:getChildAutoType("heroCellList")
	
	--self.closeBt:addClickListener(function ()
			--ViewManager.close("BattleSettleView")
	--end)
	local resultInfo= ModelManager.ArenaModel:getChallengeResult()
    self:setSettleData(resultInfo)
	--self.view:setSortingOrder(1)	
	--printTable(4,self.view:getPackageItem(),"self.view:getPackageItem()")
end


function BattleSettleView:setSettleData(resultInfo)
	if resultInfo.win then
		self:setWinData(resultInfo)
	else
		self:setLoseData(resultInfo)
	end
end

function BattleSettleView:setWinData(resultInfo)
	local myInfo=resultInfo.myInfo
	local challengeinfo=resultInfo.challengeInfo
	self.view:getController("isWin"):setSelectedPage("win")
	self.rankValue:setText(string.format("排名%s（上升[color=#00FF00]%s[/color]位）",myInfo.rank-resultInfo.myAddRank,resultInfo.myAddRank))
	--print(5656,myInfo.rank-resultInfo.myAddRank,"myInfo.rank-resultInfo.myAddRank","??????")
	self.battleHeroList:setItemRenderer(function(index,item)
			local iconLoader =item:getChildAutoType("iconLoader")
			local playName=item:getChildAutoType("playName")
			local integral=item:getChildAutoType("integral")
			local addScore=item:getChildAutoType("addScore")
            item:getController("scoreType"):setSelectedIndex(index)
			if index==0 then 
				playName:setText(myInfo.name)
				integral:setText(myInfo.score)
				local symbol = resultInfo.myAddScore > 0 and "+" or ""
				--iconLoader:setURL(PlayerModel:getUserHeadURL(myInfo.head))
				addScore:setText(string.format("（%s%s）",symbol,resultInfo.myAddScore))
			else
				playName:setText(challengeinfo.name)
				integral:setText(challengeinfo.score)
				--iconLoader:setURL(PlayerModel:getUserHeadURL(challengeinfo.head))
				local symbol = resultInfo.challengeAddScore > 0 and "+" or ""
				addScore:setText(string.format("（%s%s）",symbol,resultInfo.challengeAddScore))
				addScore:setColor({r=255,g=0,b=0})
			end	
    end)
	self.battleHeroList:setNumItems(2)

	self.heroCellList:setItemRenderer(function(index,item)
			local hero = BindManager.bindPlayerCell(item)
			if index==0 then
				hero:setHead(myInfo.head, myInfo.level,nil,nil,myInfo.headBorder)
			else
				hero:setHead(challengeinfo.head, challengeinfo.level,nil,nil,challengeinfo.headBorder)
			end
		end)
	self.heroCellList:setNumItems(2)
	
end

function BattleSettleView:setLoseData(resultInfo)
	self.view:getController("isWin"):setSelectedPage("lose")
	local myInfo=resultInfo.myInfo
	self.myRank:setText(string.format("排名%s（下降[color=#FF0000]%s[/color]位）",myInfo.rank-resultInfo.myAddRank,math.abs(resultInfo.myAddRank)))
	self.myScore:setText(myInfo.score)
	self.addScore:setText(string.format("(%s)",resultInfo.myAddScore))
end


function BattleSettleView:_enter()

end

function BattleSettleView:_exit()

end

return BattleSettleView