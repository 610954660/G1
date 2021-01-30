local BaseModel = require "Game.FMVC.Core.BaseModel"
local PataModel = class("PataModel",BaseModel)
local gamePlayType = 2000
local spceFlag = false
local towerLayer = {}
local ModuleType = GameDef.ModuleType
function PataModel:ctor()
	
end

function PataModel:getSpceFlag( ... )
	return spceFlag
end

function PataModel:init()
	self.__floor = 1
	self.__isSuccess = false
	self.__gamePlayType = 0  --场景玩法类型
	self.topInfo=false
	self.activeType=false
	self.pataArgs=false
	self.arrayType=false
end
--登录时，解析爬塔信息
function PataModel:setPataInfos(infos)
	--printTable(1 , "副本信息： " , infos )
	local playTypes = {2000,2001,2002,2003,2005}
	for k,v in pairs(playTypes) do
		local pataInfos = infos[ v ] or DT
		local difficultyInfo = pataInfos.difficultyInfo or DT
		local floor = next(difficultyInfo) or 1
		towerLayer[v] = floor
	end
	self:updateRed()
	Dispatcher.dispatchEvent(EventType.sevenday_activity_tower_pass)
end

--设置当选选择的玩法类型
function PataModel:setViewArgs(data)
	self.pataArgs=data
	self.activeType=data.activeType
	self.arrayType=data.type
end


function PataModel:getCurFloor()
	return self.__floor
end

function PataModel:getFightFloor()
	return self:getPataFloor(self.activeType or GameDef.GamePlayType.NormalTower)
end

--获取不同塔的层数信息
function PataModel:getPataFloor(gamePlay,realFloor)
	
	local cfg_tower = DynamicConfigData.t_tower[gamePlay]	
	local curFloor=towerLayer[ gamePlay ]
	if curFloor > #cfg_tower and not realFloor then
		curFloor = #cfg_tower
	end
	return curFloor
	-- local copy_info = ModelManager.MaterialCopyModel:getCopyInfo( gamePlay )
	-- local floor = 1
	-- if copy_info ~= nil then
	-- 	local difficultyInfo = pataInfos.difficultyInfo or DT
	-- 	floor = next(difficultyInfo) or 1
	-- end
	-- return floor towerLayer[ gamePlay ]
end
--检测副本是否开启
function PataModel:isOpen(gamePlay)
	if gamePlay==2000 then return true end
	local weekday = TimeLib.getWeekDay2( ServerTimeModel:getServerTime() )
	if weekday  == 0 then
		weekday = 7
	end
	local cfg_towerType = DynamicConfigData.t_towerType[ gamePlay ]
	if cfg_towerType then 
		for k,v in pairs( cfg_towerType.openDay ) do
			if v == weekday then return true end
		end
	end
	return false
end

function PataModel:getSuccess()
	return self.__isSuccess
end
--测试过场效果
function PataModel:setSuccess(playType)
	self.__isSuccess = true
	local floor = towerLayer[ playType ] + 1
	local maxFloor = #DynamicConfigData.t_tower[playType]
	printTable(999,"爬塔结算",playType,floor,maxFloor)
	towerLayer[ playType ] = floor <= maxFloor and floor or maxFloor
	Dispatcher.dispatchEvent(EventType.sevenday_activity_tower_pass)
end

function PataModel:getPlayType()
	return self.__gamePlayType
end

function PataModel:resetSuccess()
	self.__isSuccess = false
end
--请求挑战爬塔
function PataModel:enterCopy(playType)
	local function response( data )
		printTable(086,"爬塔副本结果返回",data)
		local params = {}
		params.isWin = data.isSuccess
		local playType = data.gamePlayType
		local floor = data.level
		if playType ==0 then playType = 2000 end
		local cfg_tower = DynamicConfigData.t_tower[ playType ]
		local floorInfo = cfg_tower[ floor-1 ] or DT  -- ? 需要测试下。
		local rewardPre = floorInfo.rewardPre
		if self._args and self._args.type == 2 then
			local cfg_drop = DynamicConfigData.t_drop[ floorInfo.cleanReward ]
			if cfg_drop then
				rewardPre = cfg_drop.item1
			end
		end
		
		params.reward = rewardPre
		params.type = playType

		params.closeCallBack = self.onFightRewardClose
		params.closeCaller = self
		ModelManager.PlayerModel:set_awardData(params)
						
						
		self.__floor = data.level--data.level <= #cfg_tower and data.level or #cfg_tower
		self.__isSuccess = data.isSuccess
		self.__gamePlayType = data.gamePlayType		
		--成功的话，打开结算界面
		if data.isSuccess then
			towerLayer[ self.__gamePlayType ] = self.__floor
		 	--ViewManager.open("PataEndLayer" , {showType=1})
			Dispatcher.dispatchEvent(EventType.module_check, ModuleType.Tower , self.__floor)
	
			Dispatcher.dispatchEvent(EventType.sevenday_activity_tower_pass)
		else 
			--RollTips.show("爬塔挑战失败")
		end
		 spceFlag = true
	end
	print(1,"挑战爬塔，发送的参数",playType)
	RPCReq.Copy_EnterTower({gamePlayType = playType},response)
end

function PataModel:onFightRewardClose()
	Dispatcher.dispatchEvent(EventType.pata_showNext)
end
--副本结束
function PataModel:fightCopyEnd()
	local function response(data)
	end
    print(1111,"请求服务器 爬塔副本结束")
	RPCReq.Copy_EndTower(nil,response)
end
--请求扫荡
function PataModel:sweepTower(finished)
	print(1,"扫荡处理")
	--因为玩家排名相关后端还没有做，所以扫荡没有数据返回。后续这里需要返回相关排名前3 数据，和  排名前三额外奖励数据
	local function response(data)
		if finished then
			finished()
		end
		-- ViewManager.open("PataEndLayer" , {showType=2} )
	end
	RPCReq.Copy_SweepTower(nil, response)
end
--检查爬塔红点
function PataModel:updateRed()
	
	local test =0
	local function setRed()
		local rankCount = ModelManager.MaterialCopyModel:getCopyCount( GameDef.GamePlayType.TowerTopInfo )
		local rankRed = false
		if rankCount ==0 then
			rankRed =#self.topInfo>0
		end
		printTable(0866,self.topInfo,"self.topInfo")
		RedManager.updateValue("V_TOWER_RANK", rankRed and self.activeType==2000);
		RedManager.updateValue("V_TOWER_MAINVIEW", rankRed);
	end
	if self.topInfo==false then
		local params={}
		params.onSuccess = function( data )
			self.topInfo=data.topInfo 
			setRed()
		end
		RPCReq.Copy_GetTowerTopInfo(params, params.onSuccess)
		
	else 
		setRed()
	end
end


function PataModel:materialCopy_addCopyNum(_,copytype)
    print(086,"materialCopy_addCopyNum",copytype)
	self:updateRed()
	
end




function PataModel:materialCopy_updata(_,data)
	printTable(086,"点击扫荡1");
end

function PataModel:materialCopy_pass(_,copytype)
	printTable(086,"点击扫荡2");

end


function PataModel:saveSkipArray(arrayType, skip)
	FileCacheManager.setBoolForKey(PlayerModel.userid..FileDataType.SKIPARRAY.."_"..arrayType,skip,false,false)
end


function PataModel:checkSkipArray(arrayType)
	return FileCacheManager.getBoolForKey(PlayerModel.userid..FileDataType.SKIPARRAY.."_"..arrayType,false,false,false)
end




function PataModel:materialCopy_resetDay(_,copytype)
	printTable(086,"跨天重置2");

end







return PataModel