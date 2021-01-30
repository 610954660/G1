---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-10-16 19:35:47
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class rewardModel

local BaseModel=require "Game.FMVC.Core.BaseModel"
local RewardModel = class("RewardModel",BaseModel)

function RewardModel:ctor()
	self.battleData=false
	self.arrayType=false
	self.gamePlayType=false
	self.__RerewardQueues=Queue.new()
	
	self.skipBattleData={}  --跳过战斗弹结算之前需要缓存一个战报
end


function RewardModel:setBattleData(battleData)
	self.battleData=battleData
end

--可以把后台战报缓存起来不然弹结算之后会被清掉
function RewardModel:setSkipBattleData(arrayType,battleData)
	self.skipBattleData[arrayType]=battleData or FightManager.getBettleData(arrayType)
end


function RewardModel:getSkipBattleData(arrayType)
	return self.skipBattleData[arrayType]
end

function RewardModel:getBattleData()
	return self.battleData
end

function RewardModel:setArrayType(arrayType,gamePlayType, battleData)
	if gamePlayType == nil then
		print(69, "gamePlayType id nil")
	end
	self.battleData=battleData or false
	self.arrayType=arrayType
	self.gamePlayType=gamePlayType or false
end

function RewardModel:getArrayType()
	return self.arrayType
end



function RewardModel:getArrayType()
	return self.arrayType
end

function RewardModel:getGamePlayType()
	return self.gamePlayType
end


function RewardModel:clearRewardQuese(func)
	self.__RerewardQueues=Queue.new()
end


function RewardModel:pushRewardQues(func)
	local viewNode=ViewManager.getView("ReWardView")
	if viewNode and viewNode.view:isVisible() then
		self.__RerewardQueues:enqueue(func)
	else
		func()
	end
end

function RewardModel:playRewardInQue(info)
	local rewardrFun= self.__RerewardQueues:dequeue()
	if rewardrFun then
		rewardrFun();
	end
end


--重新登录的时候清理
function RewardModel:clear()
	self.__RerewardQueues=Queue.new()
	self.battleData=false
	self.arrayType=false
end


return RewardModel