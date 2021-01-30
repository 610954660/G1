--Date :2020-12-27
--Author : added by xhd
--Desc : 巅峰竞技场model

local StrideServerModel = class("StrideServer", BaseModel)
function StrideServerModel:ctor()
   self.baseInfoData = {} --基础数据
   self.panelInfoData = false --巅峰赛页面
   self.curSelectZone = 1 --巅峰赛当前选中
   self.guessData = false -- 竞猜数据
   self.gearUpData = false --竞技赛数据
   self.gearUpCurArr = false
   self.rankData = false

   self.championData = false --冠军赛数据
   self.championCurArr = false --冠军赛当前选中赛区
   self.isFighting =false
   self.fightIndex = 0
   self.ItemPosJJ = {
        "3_1",
        "3_2",
        "3_3",
        "3_4",
        "3_5",
        "3_6",
        "3_7",
        "3_8",
        "2_1",
        "2_2",
        "2_3",
        "2_4",
        "1_1",
        "1_2",
    }
    self.ItemPosGJ = {
        "3_1",
        "3_2",
        "3_3",
        "3_4",
        "3_5",
        "3_6",
        "3_7",
        "3_8",
        "2_1",
        "2_2",
        "2_3",
        "2_4",
        "1_1",
        "1_2",
        "0_1"
    }
    self.LinePosJJ = {"2_1", "2_2", "2_3", "2_4", "1_1", "1_2", "1_3", "1_4"}
    self.LinePosGJ = {"2_1", "2_2", "2_3", "2_4", "1_1", "1_2", "1_3", "1_4", "0_1"}
    self.curGJIndex = 1 -- 当前是第几轮冠军赛比赛

    self.stateArr = { 
        {str1="预选赛",bigStage=1,battleState={1,6}}, --1
        {str1="晋级赛",str2="256晋128",bigStage=2,battleState=1,first=256,second=128},  --2
        {str1="晋级赛",str2="128晋64",bigStage=2,battleState=2,first=128,second=64},   --3
        {str1="冠军赛",str2="64晋32",bigStage=3,battleState=1,first=64,second=32}, --4
        {str1="冠军赛",str2="32晋16",bigStage=3,battleState=2,first=32,second=16}, --5
        {str1="冠军赛",str2="16晋8",bigStage=3,battleState=3,first=16,second=8}, --6
        {str1="冠军赛",str2="8晋4",bigStage=4,battleState=1,first=8,second=4}, --7
        {str1="冠军赛",str2="4晋2",bigStage=4,battleState=2,first=4,second=2}, --8
        {str1="冠军赛",str2="2晋1",bigStage=4,battleState=3,first=2,second=1}, --9
    }


    self._ackTemp = { --战斗类型
        GameDef.BattleArrayType.TopArenaAckOne,
        GameDef.BattleArrayType.TopArenaAckTwo,
        GameDef.BattleArrayType.TopArenaAckThree,
    }

	self.curPVPModule = GameDef.BattleArrayType.TopArenaAckOne
	self._CrossPVPType = {
		_ack = 0,
		_def = 1,
    }
    self.curPVPType = self._CrossPVPType._ack
    self.recordIndex = 0
    self.battleRecord = {}
    self.heroTempItems = {}
    self.controller = {}
    self.curSelectPage = 1
    self.serverList = {}
    self.fightId = DynamicConfigData.t_TopArenaConfig[1].fightId
    self.recordIds = {}
    self.fightData = {}
    self.recordIdIdx = {}
    self.interfaceType  = 1
    self:initListeners()
end


function StrideServerModel:getStateConfig(index)
    return self.stateArr[index]
end


--大阶段
function StrideServerModel:getBigStageStr( bigStage,battleStage)
    if bigStage and battleStage then
        for i,v in ipairs(self.stateArr) do
            if bigStage <=1 and v.bigStage == bigStage  then
                return v.str1,"",v
            else
                if v.bigStage == bigStage and v.battleState == battleStage then
                    return v.str1,v.str2,v
                end
            end

        end
    end
    
    if self:checkBaseInfoState() then
        local stateInfo = self.baseInfoData.info.stateInfo
        for i,v in ipairs(self.stateArr) do
            if stateInfo.bigStage <=1 then
                return v.str1,"",v
            else
                if v.bigStage == stateInfo.bigStage and v.battleState == stateInfo.battleStage then
                    return v.str1,v.str2,v
                end
            end
        end
    else
        return "未开赛"
    end
end

--小阶段
function StrideServerModel:getSmallStateStr()
    if not self.baseInfoData then
        return "未开赛"
    end
    if not self.baseInfoData.info then
        return "未开赛"
    end
    if not self.baseInfoData.info.stateInfo then
        return "未开赛"
    end
    local stateInfo = self.baseInfoData.info.stateInfo
    if not stateInfo.smallStage then
        return "未开赛"
    end
    if stateInfo.smallStage == 1 then
        return DescAuto[295] -- [295]="竞猜中"
    elseif stateInfo.smallStage == 2 then
        return DescAuto[296] -- [296]="对战中"
    elseif stateInfo.smallStage == 3 then
        return DescAuto[297] -- [297]="休整中"
    else
        return "未开赛"
    end
end


function StrideServerModel:setMainSelectPage(page)
    self.curSelectPage = page
end

function StrideServerModel:getMainSelectPage()
    return self.curSelectPage
end

function StrideServerModel:setGJIndex(index)
    self.curGJIndex = index
 end
 
 function StrideServerModel:getGJIndex()
     return  self.curGJIndex
  end

function StrideServerModel:init()

end

-- 设置入口数据
function StrideServerModel:getMainSubInfo(fun)

    local state,lastTime = self:getLastTime()
    local bigStage,battleStage = self:getTwoStage(  )
    local data = {}
    data.state = state
    data.bigStage = bigStage
    data.battleStage = battleStage
    data.dayState = self:getSmallStateStr()
    data.seasonTime = lastTime
    data.red     = "V_Stride"
    data.moduleId = ModuleId.StridePVP.id
    data.status = self:isActiveIng()
    fun(data)
end


--巅峰页面里面的赛区记录
function StrideServerModel:setCurSelectZone(zone)
    self.curSelectZone = zone
end


function StrideServerModel:getCurSelectZone()
    return  self.curSelectZone
end

function StrideServerModel:checkBaseInfoState( ... )
    if not self.baseInfoData then
        return false
    end
    if not self.baseInfoData.info then
        return false
    end
    if not self.baseInfoData.info.stateInfo then
        return false
    end
    --基于构建初始结构  多增加一次判断
    if not self.baseInfoData.info.likeList then
        return false
    end
    return true
end

function StrideServerModel:initBaseInfoStruct( ... )
    if not self.baseInfoData then
        self.baseInfoData = {}
    end
    if not self.baseInfoData.info then
        self.baseInfoData.info = {}
    end
    if not self.baseInfoData.info.stateInfo then
        self.baseInfoData.info.stateInfo = {}
    end
    if not self.baseInfoData.info.isGuess then
        self.baseInfoData.info.isGuess = false
    end
    if not self.baseInfoData.info.likeTimes then
        self.baseInfoData.info.likeTimes = 0
    end
    if not self.baseInfoData.info.likeList then
        self.baseInfoData.info.likeList = {}
    end
end

--基础数据
function StrideServerModel:reqInfoData()
    RPCReq.TopArena_GetInfo({},function(data)
        printTable(1,"数据数据",data)
		if next(data) then
            self.baseInfoData = data
            self:checkRedDot()
            Dispatcher.dispatchEvent(EventType.update_stride_enterPanel)
		end
	end)
end

--检测红点
function StrideServerModel:checkRedDot(  )
    if self:isActiveIng() then
        local bigStage,battleStage = self:getTwoStage()
        local smallStage =  self:getSmallStage()
        if smallStage == 1 then
            if not  self:getIsGuess() then
                RedManager.updateValue("V_Stride",true)
                return
            end
        end 
    end
    RedManager.updateValue("V_Stride",false)
end

--获取巅峰版数据
function StrideServerModel:reqTopPanelInfo(zoneId)
    RPCReq.TopArena_GetTopPanelInfo({zoneId=zoneId},function(data)
		if next(data) then
            self.panelInfoData = data
            --更新基础数据
            if not self:checkBaseInfoState() then
                self:initBaseInfoStruct()
            end
            self.baseInfoData.info.stateInfo = data.stateInfo
            --更新赛区总数量
            self.baseInfoData.zoneNum = data.zoneNum
            self:checkRedDot()
            Dispatcher.dispatchEvent(EventType.update_stride_dianfenPanel)
            Dispatcher.dispatchEvent(EventType.update_stride_enterPanel)
		end
	end)
end

--获取排行的数据
function StrideServerModel:reqRankListData()
    RPCReq.Rank_GetRankData({rankType = GameDef.RankType.TopArenaScore,collectionId =self.curSelectZone},function(data)
        if next(data) then
            if data.myRankData and next(data.myRankData) and data.myRankData.rank>0 then
                data.inRank = true
            end
            self.rankData = data
            Dispatcher.dispatchEvent(EventType.update_stride_rank)
        end
    end)
    return false
end

function StrideServerModel:getRankListData()
    return  self.rankData
end


function StrideServerModel:modifyRankdata( playerId,totalLike )
    for k,v in pairs(self.rankData.rankData) do
        if v.id ==playerId then
            v.exParam.param1 = totalLike
        end
    end
end

function StrideServerModel:getTopPanelInfo()
    return self.panelInfoData
end

--获取入口数据
function StrideServerModel:getStateInfo( ... )
    if self:checkBaseInfoState() then
        return self.baseInfoData.info.stateInfo
    end
    return {}
end

function StrideServerModel:setStateInfo( stateInfo )
    if self:checkBaseInfoState() then
        if not self:checkBaseInfoState() then
            self:initBaseInfoStruct()
        end
        self.baseInfoData.info.stateInfo =stateInfo
        self:checkRedDot()
    end
end

--已战斗场数
function StrideServerModel:getBattleNum( ... )
    if self.baseInfoData then
        return self.baseInfoData.battleNum
    end
    return false
end

--下注状态
function StrideServerModel:getIsGuess( ... )
    if self:checkBaseInfoState() then
        return self.baseInfoData.info.isGuess
    end
    return false
end

function StrideServerModel:modifyIsGuess( flag )
    if  self:checkBaseInfoState() then
        self.baseInfoData.info.isGuess  = flag
    end
end


--点赞
function StrideServerModel:getLikeTimes( ... )
    if self.baseInfoData then
        return self.baseInfoData.likeTimes
    end
    return 0
end

--点赞玩家列表
function StrideServerModel:getLikeList( ... )
    if not self:checkBaseInfoState() then
        return {}
    end
    return self.baseInfoData.info.likeList or {}
end

function StrideServerModel:modifyLikeListAndTimes(list,times)
    if  self:checkBaseInfoState() then
        self.baseInfoData.info.likeList = list
        self.baseInfoData.info.likeTimes = times
    end
end

function StrideServerModel:checkInLikeList(pid)
    local arr = self:getLikeList()
    if #arr>0 then
        for k,v in pairs(arr) do
            if v == pid then
                return true
            end
        end
    end
    return false
end

--获取当前赛季
function StrideServerModel:getSeasonId( ... )
    if self:checkBaseInfoState() then
        return self.baseInfoData.info.stateInfo.seasonId
    end
    return 0
end

--获取赛区数
function StrideServerModel:getAllzoneNum( ... )
    if not self.baseInfoData then
        return 0
    end
    if self.baseInfoData.zoneNum then
        return self.baseInfoData.zoneNum
    end
    return 0
end

--获取倒计时
function StrideServerModel:getLastTime(type)
   if self:checkBaseInfoState() then
      local lastTime = 0
      local smallTime = 0
      local serverTime = ServerTimeModel:getServerTimeMS()
      if self.baseInfoData.info.stateInfo.isOpen == 0 then --未开启  
          lastTime =  self.baseInfoData.info.stateInfo.nextSeasonTime - serverTime
          smallTime = 0
          return 0,lastTime/1000,smallTime
      elseif self.baseInfoData.info.stateInfo.isOpen == 1 then --已开启  小阶段结束时间
          if self.baseInfoData.info.stateInfo.isPartIn == 0 then
            lastTime =  self.baseInfoData.info.stateInfo.nextSeasonTime - serverTime
            smallTime = self.baseInfoData.info.stateInfo.smallEndTime - serverTime
          else
            lastTime =  self.baseInfoData.info.stateInfo.seasonEndTime - serverTime
            smallTime = self.baseInfoData.info.stateInfo.smallEndTime - serverTime
          end
          return 1,lastTime/1000,smallTime/1000
      elseif self.baseInfoData.info.stateInfo.isOpen == 2 then --  小阶段结束时间 --下赛季
            lastTime =  self.baseInfoData.info.stateInfo.nextSeasonTime - serverTime
            smallTime = 0
            return 2,lastTime/1000,smallTime
      end
   end
   return 1,0,0
end




--获取赛程信息
function StrideServerModel:reqGetMyBattleInfo( ... )
    RPCReq.TopArena_GetMyBattleInfo({},function(data)
		if next(data) then
            Dispatcher.dispatchEvent(EventType.update_stride_myCourse,{data= data})
		end
	end)
end

--请求挑战竞猜界面
function StrideServerModel:reqGetGuessPanelInfo( ... )
    -- body
    RPCReq.TopArena_GetGuessPanelInfo({},function(data)
        if next(data) then
           if not self:checkBaseInfoState() then
              self:initBaseInfoStruct()
           end
           self.baseInfoData.info.stateInfo = data.stateInfo
           self.guessData = data
           self:checkRedDot()
            Dispatcher.dispatchEvent(EventType.update_stride_GuessPanelInfo,{data= self.guessData})
		end
	end)
end

--请求历史最高排行
function StrideServerModel:reqGetHistoryRank( ... )
    -- body
    RPCReq.TopArena_GetHistoryRank({},function(data)
        if next(data) then
            Dispatcher.dispatchEvent(EventType.update_stride_histroyRank,data)
		end
	end)
end

--获取对阵详情记录界面
function StrideServerModel:getGuessDataInfo()
    if self.guessData then
        return self.guessData
    end
end


--竞猜
function StrideServerModel:reqDoGuess( pid )
    -- body
    RPCReq.TopArena_DoGuess({playerId=pid},function(data)
        if next(data) then
            self.guessData.flag = data.flag
            self.guessData.guessNumList = data.guessNumList
            self.guessData.rateList = data.rateList
            self.guessData.isGuess = true
            self.guessData.choosePlayerId = pid
            self:modifyIsGuess(true)
            self:checkRedDot()
            Dispatcher.dispatchEvent(EventType.update_stride_guessMain,{data= self.guessData})
		end
	end)
end

--请求竞猜记录
function StrideServerModel:reqGetGuessRecord( )
    -- body
    RPCReq.TopArena_GetGuessRecord({},function(data)
        if next(data) then
            Dispatcher.dispatchEvent(EventType.update_stride_guessRecord,{data=data})
		end
	end)
end


--请求晋级赛界面数据
function StrideServerModel:reqGetGrearUpgradeInfo(zid,sgid)
    if not (zid and sgid) then
        print(1,"请求参数存在空值 请检查")
        return
    end
    if not self.gearUpCurArr then
        self.gearUpCurArr = {}
        self.gearUpCurArr.zid = zid
        self.gearUpCurArr.sgid = sgid
    end
    RPCReq.TopArena_GetGearUpgradePanelInfo({zoneId=zid,subGroupId=sgid},function(data)
        if next(data) then
            if not self:checkBaseInfoState() then
                self:initBaseInfoStruct()
            end
            self.baseInfoData.info.stateInfo = data.stateInfo
            self.gearUpData = data
            self:checkRedDot()
            Dispatcher.dispatchEvent(EventType.update_stride_upGradeJJPvp,{data=data})
            Dispatcher.dispatchEvent(EventType.update_stride_enterPanel)
		end
	end)
end

function StrideServerModel:getGearUpgradeData( ... )
    return self.gearUpData
end

--获取两个状态
function StrideServerModel:getTwoStage(  )
    if self:checkBaseInfoState() then
        return self.baseInfoData.info.stateInfo.bigStage,self.baseInfoData.info.stateInfo.battleStage
    end
    return 1,1
end

--获取小阶段
function StrideServerModel:getSmallStage(  )
    if self:checkBaseInfoState() then
        return self.baseInfoData.info.stateInfo.smallStage
    end
    return 3
end

function StrideServerModel:getChampionData( ... )
    return self.championData
end
function StrideServerModel:getGearPlayInfo( playid )
    if self.gearUpData and self.gearUpData.playerList then
        local list = self.gearUpData.playerList
        for i = 1, #list do
            if list[i].playerId == playid then
                return list[i]
            end
        end
    end
    return false
end

function StrideServerModel:getCurGrearGroupId()
    if self.gearUpCurArr then
        return  self.gearUpCurArr
    end
    return  false
end




--判断是否在活动中
function StrideServerModel:isActiveIng() --在活动中
    if  self:checkBaseInfoState() then
       if self.baseInfoData.info.stateInfo.isOpen == 1 and self.baseInfoData.info.stateInfo.isPartIn~=0 then
          return true
       end
    end
    return false
end




function StrideServerModel:getXiantiaobyStageAnim(com,type)
    local ani = false
    if  self:checkBaseInfoState()  then
        local smallStage =  self:getSmallStage()
        if self.baseInfoData.info.stateInfo.battleStage~=0 then
            if type== 1 then
                if self.baseInfoData.info.stateInfo.bigStage == 2 and smallStage ==2  then
                    ani = self:getWorldChallengeXiantiaoAnim(com, self.baseInfoData.info.stateInfo.battleStage)
                else
                    return false
                end
            elseif type == 2 then
                if self.baseInfoData.info.stateInfo.bigStage >=3 and smallStage ==2 then
                    ani = self:getWorldChallengeXiantiaoAnim(com, self.baseInfoData.info.stateInfo.battleStage)
                else
                    return false
                end
            end
        end 
    end
	return ani
end

--查找晋级赛中间几个位置数据
function StrideServerModel:getPlayDataByPosKey(key)
    if self.gearUpData and self.gearUpData.battleNodeList then
        for k,v in pairs(self.gearUpData.battleNodeList) do
            if v.pos == key then
                local playInfo = self:getGearPlayInfo( v.winPlayerId )
                return playInfo
            end
        end
    end
    return false
end

--查找冠军赛中间几个位置数据
function StrideServerModel:getGjPlayDataByPosKey(key)
    local battleInfo = false
    local sgid = self.championCurArr.sgid
    if self:getGJIndex() == 1 then
        sgid = self.championCurArr.sgid
    elseif self:getGJIndex() == 2 then
        sgid = self.championCurArr.sgid2
    end
    if self.curGJIndex==1 then --冠军赛第一轮
        battleInfo = self.championData.battleInfo
    else
        battleInfo = self.championData.battleInfo2
    end
    if battleInfo and battleInfo[sgid] and battleInfo[sgid].battleNodeList  then
        for k,v in pairs(battleInfo[sgid].battleNodeList) do
            if v.pos == key then 
                local playInfo = self:getChampionPlayInfo( v.winPlayerId,sgid)
                return playInfo
            end
        end
    end
    return false
end

function StrideServerModel:getLineBarState(lineId,type,sgid)
    if (not sgid) and type == 2 and self:getGJIndex() == 1  then
        sgid = self.championCurArr.sgid
    elseif (not sgid) and type == 2 and self:getGJIndex() == 2  then
        sgid = self.championCurArr.sgid2
    end
	local arr = string.split(lineId, "_")  --2-2
	local key = tonumber(arr[1]) --2
	local pos = tonumber(arr[2]) --2
	local oldKey = 1
	local oldPosshang = 1
	local oldPosXia = 2
    local isshuang = false
    local curKey = 0
    local tempKey = 0
    curKey = tonumber(string.format( "%d%d",key,pos))
    if key == 2 then
        if curKey == 21 then
            oldPosshang = 1  
            oldPosXia = 2
            tempKey = 11
        elseif curKey == 22 then
            oldPosshang = 3
            oldPosXia = 4
            tempKey = 12
        elseif curKey == 23 then
            oldPosshang = 5
            oldPosXia = 6
            tempKey = 13
        elseif curKey == 24 then
            oldPosshang = 7
            oldPosXia = 8
            tempKey = 14
        end
        isshuang = true
	elseif key == 1 and pos >= 1 and pos <= 2 then --左边2->1
		oldPosshang = 11
		oldPosXia = 12
		curKey =21
	elseif key == 1 and pos >= 3 and pos <= 4 then --右边2->1
		oldPosshang = 13
		oldPosXia = 14
		curKey =22
	elseif key == 0 then -- 中间2->1
		oldPosshang = 21
        oldPosXia = 22
        curKey =31
    end
    local curItem  = false
    local shangItem  = false
    local xiaItem  = false
    if type == 1 then --晋级赛
        if isshuang then --
            if self.gearUpData then
                curItem = self:getPlayDataByPosKey(tempKey)
                if self.gearUpData.playerList[oldPosshang] then
                    shangItem = self.gearUpData.playerList[oldPosshang]
                end
    
                if self.gearUpData.playerList[oldPosXia] then
                    xiaItem = self.gearUpData.playerList[oldPosXia]
                end
            end
        else
            if self.gearUpData and self.gearUpData.battleNodeList then
                curItem = self:getPlayDataByPosKey(curKey)
                shangItem = self:getPlayDataByPosKey(oldPosshang)
                xiaItem =  self:getPlayDataByPosKey(oldPosXia)
            end
        end
    else --冠军赛
        if isshuang then --
            if self.championData then
                local battleInfo = false
                if self.curGJIndex==1 then --冠军赛第一轮
                    battleInfo = self.championData.battleInfo
                else
                    battleInfo = self.championData.battleInfo2
                end
                if battleInfo then
                    curItem = self:getGjPlayDataByPosKey(tempKey)
        
                    if battleInfo[sgid] and battleInfo[sgid].playerList and battleInfo[sgid].playerList[oldPosshang] then
                        shangItem = battleInfo[sgid].playerList[oldPosshang]
                    end
        
                    if battleInfo[sgid] and battleInfo[sgid].playerList and battleInfo[sgid].playerList[oldPosXia]then
                        xiaItem = battleInfo[sgid].playerList[oldPosXia]
                    end
                end
            end
        else
            if self.championData then
                curItem = self:getGjPlayDataByPosKey(curKey)
                shangItem = self:getGjPlayDataByPosKey(oldPosshang)
                xiaItem =  self:getGjPlayDataByPosKey(oldPosXia)
            end
        end
    end

	if not curItem then
		return false
	end
	if isshuang and pos <= 2 then
		if curItem and shangItem and curItem.playerId == shangItem.playerId then
			return 1
		end
		if curItem and xiaItem and curItem.playerId == xiaItem.playerId then
			return 2
		end
	elseif isshuang and pos >= 2 and pos <= 4 then
		if curItem and shangItem and curItem.playerId == shangItem.playerId then
			return 2
		end
		if curItem and xiaItem and curItem.playerId == xiaItem.playerId then
			return 1
		end
	else
		if curItem and xiaItem and shangItem and key == 0 and pos == 1 then --最后一个
			if curItem and shangItem and curItem.playerId == shangItem.playerId then
				return 3
			end
			if curItem and xiaItem and curItem.playerId == xiaItem.playerId then
				return 4
			end
		end

		if curItem and shangItem and curItem.playerId == shangItem.playerId and pos % 2 ~= 0 then
			return true
		end
		if curItem and xiaItem and curItem.playerId == xiaItem.playerId and pos % 2 == 0 then
			return true
		end
		
	end
	return false
end


--获取对应的线条动效 com 组件对象
function StrideServerModel:getWorldChallengeXiantiaoAnim(com, Tag) --线条动效
	local animation = false
	local str = "ui_lianxian8_1_loop"
	if Tag == 1 then  --8->4
		str = "ui_lianxian8_1_loop"
	elseif Tag == 2 then --4->2
		str = "ui_lianxian4_1_loop"
	elseif Tag == 3 then  --2->1
		str = "ui_lianxian2_1_loop"
	end
	animation =
	SpineUtil.createSpineObj(
		com,
		{x = 0, y = 0},
		str,
		"Effect/UI",
		"efx_sijieleitaisai",
		"efx_sijieleitaisai",
		false
	)
	animation:setAnimation(0, str, true)
	return animation
end

--检测该条线该不该亮
function StrideServerModel:getWorldChallengeXiantiao(lineId,type)
	local isActive = self:isActiveIng()
	--在活动中
	if isActive == true then
		local xianArr= self:getXiantiaobyStage(type)
		if table.indexof(xianArr, lineId) ~= false then 
			return true
		end
	end
	return false
end


--获取线条的状态
function StrideServerModel:getXiantiaobyStage(type)
    if not self:checkBaseInfoState() then
         return {}
    end
    local  bigStage = self.baseInfoData.info.stateInfo.bigStage --首先应该是竞技赛
    local  battleStage = self.baseInfoData.info.stateInfo.battleStage
    local smallStage =  self:getSmallStage()
    local flag = false
    if type == 1 then
        flag = (bigStage == 2) and (smallStage == 2)
    elseif type ==2  then
        if self:getGJIndex() == 1 then
            flag = (bigStage == 3) and (smallStage == 2)
        else
            flag = (bigStage == 4) and (smallStage == 2)
        end 
    end
	local  xiantiaoArr = {}
    if flag  then
        if battleStage == 1 then --8进4
            xiantiaoArr = {"2_1", "2_2", "2_3", "2_4"}
        elseif battleStage == 2 then --4进2
            xiantiaoArr = {"1_1", "1_2", "1_3", "1_4"}
        elseif battleStage == 3 then --2进1
            xiantiaoArr = {"0_1"}
        end
    end
	return xiantiaoArr
end


function StrideServerModel:getGearUpCurArr()
    if self.gearUpCurArr then
        return  self.gearUpCurArr
    end
    return  false
end


function StrideServerModel:setGearUpCurArr(zid,sgid)
    if not self.gearUpCurArr then
        self.gearUpCurArr = {}
        self.gearUpCurArr.zid = zid
        self.gearUpCurArr.sgid = 1
    else
        self.gearUpCurArr.zid = zid
        self.gearUpCurArr.sgid = sgid
    end
end

function StrideServerModel:setGearUpCurArrZid(zid)
    if not self.gearUpCurArr then
        self.gearUpCurArr = {}
        self.gearUpCurArr.zid = zid
        self.gearUpCurArr.sgid = 1
    else
        self.gearUpCurArr.zid = zid
    end
end

function StrideServerModel:setGearUpCurArrSGid(sgid)
    if not self.gearUpCurArr then
        self.gearUpCurArr = {}
        self.gearUpCurArr.zid = 1
        self.gearUpCurArr.sgid = 1
    else
        self.gearUpCurArr.sgid = sgid
    end
end


function StrideServerModel:getCurChampionCurArr()
    if self.championCurArr then
        return  self.championCurArr
    end
    return  false
end


function StrideServerModel:setChamptionCurArr(zid,sgid)
    if not self.championCurArr then
        self.championCurArr = {}
        self.championCurArr.zid = zid
        self.championCurArr.sgid = 1
        self.championCurArr.sgid2 = 1
    else
        self.championCurArr.zid = zid
        self.championCurArr.sgid = sgid
        self.championCurArr.sgid2 = 1
    end
end

function StrideServerModel:setChamptionCurZid(zid)
    if not self.championCurArr then
        self.championCurArr = {}
        self.championCurArr.zid = zid
        self.championCurArr.sgid = 1
        self.championCurArr.sgid2 = 1
    else
        self.championCurArr.zid = zid
        self.championCurArr.sgid2 = 1
    end
end

function StrideServerModel:setChamptionCurSGid(sgid)
    if not self.championCurArr then
        self.championCurArr = {}
        self.championCurArr.zid = 1
        self.championCurArr.sgid = 1
        self.championCurArr.sgid2 = 1
    else
        self.championCurArr.sgid = sgid
        self.championCurArr.sgid2 = 1
    end
end



--请求冠军赛界面数据 冠军赛有两轮 第一轮有小组  第二轮没有小组
function StrideServerModel:reqGetChamptionPanelInfo(zid)
    if not (zid) then
        print(1,"请求参数存在空值 请检查")
        return
    end
    if not self.championCurArr then
        self.championCurArr = {}
        self.championCurArr.zid = zid
        self.championCurArr.sgid = 1
        self.championCurArr.sgid2 = 1
    end
    RPCReq.TopArena_GetChampionPanelInfo({zoneId=zid},function(data)
        if next(data) then
            if not self:checkBaseInfoState() then
                self:initBaseInfoStruct()
            end
            self.baseInfoData.info.stateInfo = data.stateInfo
            self.championData = data
            self:checkRedDot()
            Dispatcher.dispatchEvent(EventType.update_stride_champtionGJPvp,{data=data})
            Dispatcher.dispatchEvent(EventType.update_stride_enterPanel)
		end
	end)
end

--检测是第几轮
function StrideServerModel:checkChamptionLun()
    if self.championData then
       if self.championData.battleInfo2 and #self.championData.battleInfo2 then
           return 2
       elseif self.championData.battleInfo and #self.championData.battleInfo then
           return 1
       end
    end
    return 0
end

--根据id 到前面的数据块中寻找数据
function StrideServerModel:getChampionPlayInfo( playid,sgid)
    if not sgid then
        if self.curGJIndex == 1 then
            sgid = self.championCurArr.sgid
        else
            sgid = self.championCurArr.sgid2
        end
        
    end
    --查找当前赛区 当前轮 当前组
    if self.championData then
        if self.curGJIndex == 1 then --第一轮
           if self.championData.battleInfo then
                local list = self.championData.battleInfo[sgid].playerList
                for i = 1, #list do
                    if list[i].playerId == playid then
                        return list[i]
                    end
                end
           end
        else
            if self.championData.battleInfo2 then
                local list = self.championData.battleInfo2[sgid].playerList
                for i = 1, #list do
                    if list[i].playerId == playid then
                        return list[i]
                    end
                end
            end
        end
    end
    return false
end







--布阵 战斗相关------------
--布阵 战斗相关------------

function StrideServerModel:getSeverName(serverId)
	return self.serverList[serverId] and self.serverList[serverId].name or serverId
end

function StrideServerModel:loginPlayerDataFinish()
	local severInfo = LoginModel:getServerGroups()
	for key,severList in pairs(severInfo) do
		for k,sever in pairs(severList) do
			self.serverList[sever.server_id] = sever
		end	
	end
	
	self:getAckTemp()

	-- self:hisRedCheck()
end


function StrideServerModel:checkHeroTypeInTeam(code)
    for key,value in pairs(self:getTypeHeroTempInfo()) do
        for k,v in pairs(value.array) do
            local heroInfo = CardLibModel:getHeroByUid(v.uuid)
            if heroInfo.code == code  then
                for l,s in pairs(self:getPVPEnum()) do
                    if s == key then
                        return l
                    end
                end
            end
        end
    end
    return false
end

-- function StrideServerModel:setSeverHeroTemp(data,type)
-- 	if (data.array) then
-- 		local tb = {}
-- 		tb.arrayType = type
-- 		tb.array = {}
--         for uuid,seat in pairs(data.array) do
--             local heroInfo = CardLibModel:getHeroByUid(seat.uuid)
-- 			local hero = {}
-- 			hero.uuid = seat.uuid
-- 			hero.code = heroInfo.code
-- 			hero.id = seat.id
--             if (heroInfo) then
-- 				tb.array[hero.uuid] = hero
--             end
--         end
-- 		self.heroTempItems[self.curPVPType][type] = tb
--     end
-- end


function StrideServerModel:setHeroToTeam(seatId,heroInfo,uuid)
	local curHeroTemp = self:getCurHeroTempInfo()
	if not heroInfo then
		for key,heroInfo in pairs(curHeroTemp.array) do
			if heroInfo.uuid == uuid then
				curHeroTemp.array[key] = nil
				break
			end
		end
	else	
		local hero = {}
		hero.uuid = heroInfo.uuid
		hero.code = heroInfo.code
		hero.id = seatId
		curHeroTemp.array[hero.uuid] = hero
	end
end

function StrideServerModel:getCurHeroTempInfo()
	return self.heroTempItems[self.curPVPType][self.curPVPModule]
end

function StrideServerModel:checkHeroInTeam(uuid)
	for key,value in pairs(self.heroTempItems[self.curPVPType]) do
		for k,heroInfo in pairs(value.array) do 
			if heroInfo.uuid == uuid  then
				return self.controller[key]
			end
		end
	end
	return false
end

function StrideServerModel:getCurEnumGroup()
	if self.curPVPType == self._CrossPVPType._ack then
		return self._ackTemp
	end
	return self._defTemp
end

function StrideServerModel:getTypeHeroTempInfo(typ)
	local typ = typ or self.curPVPType
	return self.heroTempItems[typ]
end

function StrideServerModel:setCurPVPModule(moduleId)
	self.curPVPModule = moduleId
end
function StrideServerModel:getCurPVPModule()
	return self.curPVPModule
end

function StrideServerModel:getPVPEnum()
    return self._ackTemp
end
function StrideServerModel:getCurPVPType()
	return self.curPVPType
end

function StrideServerModel:getCurTempForSever()
	if self.curPVPType == self._CrossPVPType._ack then
		self:getAckTemp()
	end
end


function StrideServerModel:getAIEnemyInfos(playerId,index)
	local data = self:getRobotInfo(playerId,DynamicConfigData.t_TopArenaRobot)
	return data.arrayInfo[index]
end

--初始化数据
function StrideServerModel:getAckTemp()
	self.heroTempItems[self._CrossPVPType._ack] = {}
	for key,id in pairs(self._ackTemp) do
		self.heroTempItems[self._CrossPVPType._ack][id] = {}
		self.heroTempItems[self._CrossPVPType._ack][id].arrayType = id
		self.heroTempItems[self._CrossPVPType._ack][id].array = {}
		self.controller[id] = key
	end
	for _, v in ipairs(self._ackTemp) do
		self:doHandle(self._CrossPVPType._ack,v)
	end
end

function StrideServerModel:doHandle(type,v,cal)
    local requseInfo = {
        fightId	= self.fightId,
        playerId = 0,
        gamePlay = v,
    }
    local function success(data)
        if (data.array) then
			local tb = {}
			tb.arrayType = v
			tb.array = {}
            for uuid,seat in pairs(data.array) do
				local hero = {}
				hero.uuid = seat.uuid
				hero.code = tonumber(seat.uuid)
				hero.id = seat.id
				tb.array[hero.uuid] = hero
            end
			self.heroTempItems[type][v] = tb
        end
		if cal then cal() end
    end
    RPCReq.Battle_GetOpponentBattleArray(requseInfo,success)
end

function StrideServerModel:getRobotInfo(playerId,config)
    local conf = config[playerId] 
    local data = false
    if (conf) then
        -- 基本信息
        local baseInfo = {
            head = conf.head,
            level = conf.level,
            name = conf.name,
            playerId = playerId,
            score = conf.score,
            sex = conf.sex,
        }
        -- 队伍信息
        local arrayInfo = {};
        local fightConf = DynamicConfigData.t_fight
        for _, fightId in pairs(conf.fightId) do
            local c = fightConf[fightId];
            if (c) then
                local combat = c.monstercombat
                local heroInfos = {}
                for _, posIndex in pairs(c.monsterStand) do
                    local d = {
                        code = c["monsterId"..posIndex],
                        level = c["level"..posIndex],
                        star = c["star"..posIndex],
                        type = 2
                    }
                    if posIndex < 4 then
                        d.id = 10 + posIndex
                    elseif posIndex < 7 then
                        d.id = 20 + posIndex - 3
                    else
                        d.id = 30 + posIndex - 6
                    end
                    table.insert(heroInfos, d);
                end
                local info = {
                    combat = combat,
                    heroInfos = heroInfos,
                    arrayType = fightId
                }
                table.insert(arrayInfo, info)
            end
        end
        data = {
            playerInfo = baseInfo,
            arrayInfo = arrayInfo
        }
    end
    return data
end


-- 进入玩法保存一遍精灵阵容
-- function StrideServerModel:saveElvesBattle(planIndex)
--     if TableUtil.GetTableLen(ElvesSystemModel:getElvesEnterData(1)) == 0 and 
--     TableUtil.GetTableLen(ElvesSystemModel:getElvesEnterData(2)) == 0 and 
--     TableUtil.GetTableLen(ElvesSystemModel:getElvesEnterData(3)) == 0 then
--         Dispatcher.dispatchEvent(EventType.ElvesAddTopView_refresh)
--         return
--     end
--     local arrayType = GameDef.BattleArrayType.TopArenaAckOne
--     local saveElvesPlan = function(params)
--         if not ModelManager.ElvesSystemModel.arrays[params.data.arrayType] then
--             ModelManager.ElvesSystemModel.arrays[params.data.arrayType] = {}
--         end
--         table.insert(ModelManager.ElvesSystemModel.arrays[params.data.arrayType],params.data)
--         -- 刷新界面
--         local data = {
--             arrayType = arrayType,
--             planId    = planIndex,
--         }
--         ModelManager.ElvesSystemModel.planId[arrayType] = planIndex
--         ModelManager.ElvesSystemModel:setMyElvesBattleReqInfo(arrayType,planIndex)
--         Dispatcher.dispatchEvent(EventType.ElvesAddTopView_refresh)
--     end
--     local reqInfo = {
--             arrayType = arrayType, -- 阵容类型
--             planId    = planIndex, -- 方案id
--         }
--     RPCReq.Elf_SetArraysPalnId(reqInfo,function(params)
--         saveElvesPlan(params)
--     end)
--     RPCReq.Elf_SetArraysPalnId({arrayType = GameDef.BattleArrayType.TopArenaAckOne,planId = planIndex,},function(params)
--     end)
--     RPCReq.Elf_SetArraysPalnId({arrayType = GameDef.BattleArrayType.TopArenaAckTwo,planId = planIndex,},function(params)
--     end)
--     RPCReq.Elf_SetArraysPalnId({arrayType = GameDef.BattleArrayType.TopArenaAckThree,planId = planIndex,},function(params)
--     end)
--     printTable(8848,">>>>>精灵>>>保存巅峰竞技PVP攻击阵容>>>>>")
-- end

function StrideServerModel:changeHeroTemp(p1,p2)
if not p1 or not p2 then return false end
local temp1 = self.heroTempItems[self.curPVPType][p1].array
local temp2 = self.heroTempItems[self.curPVPType][p2].array
self.heroTempItems[self.curPVPType][p1].array = temp2
self.heroTempItems[self.curPVPType][p2].array = temp1
for key,v in pairs(self.heroTempItems[self.curPVPType]) do
    BattleModel.__arrayInfos[key] = self:getArrayByType(key)
end

self:saveTeamToSever(function()
    Dispatcher.dispatchEvent("battle_StrideChangeTeamType",BattleModel:getBattleConfig().configType)
end)
end

function StrideServerModel:SeatItem_seatInfoUpdate()
	local mapConfig = BattleModel:getBattleConfig()
	if not self:isCrossPVPType(mapConfig.configType) then return end
    local seats = BattleModel:getSeatInfos()
    local array = self:getCurHeroTempInfo().array
    for uuid, d in pairs(array) do
        for _, seat in ipairs(seats) do
            if (seat.uuid == uuid) then
                d.id = seat.seatId
                -- return
            end
        end
    end
end 

function StrideServerModel:isAckArrayType(arrayType)
	return arrayType == GameDef.BattleArrayType.HorizonPvpAckOne
    or arrayType == GameDef.BattleArrayType.HorizonPvpAckThree
    or arrayType == GameDef.BattleArrayType.HorizonPvpAckSix
end

function StrideServerModel:saveTeamToSever(callBack)
	local tb = {}
	tb.arrays = {}
	for key,value in pairs(self.heroTempItems[self.curPVPType]) do
		if table.nums(value.array) == 0 then
			return RollTips.show(Desc.CrossPVPDesc2)
		end 
		table.insert(tb.arrays,value)
	end
	RPCReq.Battle_UpdateArrayMap(tb, function (param)
        if (param) then
            for key,v in pairs(self.heroTempItems[self.curPVPType]) do
                BattleModel.__arrayInfos[key] = self:getArrayByType(key)
            end
            if callBack then callBack() end
        end
    end)
	-- RedManager.updateValue("V_Crosspvp_defand",false)
end

function StrideServerModel:isCrossPVPType(configType)
	for key,id in pairs(self._ackTemp) do
		if id == configType then
			return true
		end
	end
	return false
end

function StrideServerModel:isGamePlayType(gamePlayType)
    if gamePlayType == GameDef.GamePlayType.TopArena then
        return true
    end
    return false
end

function StrideServerModel:clearTypeAllHeroTemp()
	for key,value in pairs(self.heroTempItems[self.curPVPType]) do
		value.array = {}
	end
	for key,v in pairs(self.heroTempItems[self.curPVPType]) do
        BattleModel.__arrayInfos[key] = self:getArrayByType(key)
    end
	Dispatcher.dispatchEvent("battle_StridePVPrefrush",BattleModel:getBattleConfig().configType)
end

function StrideServerModel:refrushTypeHeroTempInfo(data)
	self.heroTempItems[self.curPVPType] = data
	self:saveTeamToSever(function()
		Dispatcher.dispatchEvent("battle_StrideChangeTeamType",BattleModel:getBattleConfig().configType)
	end)
end


function StrideServerModel:getArrayByType(type)
    if self.heroTempItems[self.curPVPType] then
        if self.heroTempItems[self.curPVPType][type] then
            return self.heroTempItems[self.curPVPType][type]
        end
    end
	return {}
end

function StrideServerModel:getRecordIndex()
	return self.recordIndex
end

--请求的战报回来之后
function StrideServerModel:Battle_BattleRecordData(_, param)
    if (self.isFighting == true) then
        self:addFightData(param);
        Dispatcher.dispatchEvent(EventType.Battle_replayRecord,{isRecord=false, battleData=param.battleData});
    end
end

function StrideServerModel:addFightData(data)
    table.insert(self.fightData, data.battleData);
end

function StrideServerModel:clearFightData()
    self.fightData = {};
    self.recordIdIdx = 1;
    self.interfaceType = 1
    self.fightIndex = 1
end

function StrideServerModel:isCrossTeamPvpType(arrayType)
    if arrayType == GameDef.BattleArrayType.TopArenaAckOne
    or arrayType == GameDef.BattleArrayType.TopArenaAckTwo
    or arrayType == GameDef.BattleArrayType.TopArenaAckThree then
        return true
    end
    return false
end

function StrideServerModel:isStridePVPType(configType)
	for key,id in pairs(self._ackTemp) do
		if id == configType then
			return true
		end
	end
	return false
end



--视频回放连播 看后续可否整理成连播  recordIds 回放id列表
function StrideServerModel:battleBegin(recordIds,gTypeArr,gamePlayType)
    self.recordIds = recordIds
    local recordIds = {}; -- 回放id列表
    local recordIdIdx = 1; -- 应该播放的录像位置
    local recordIdCount = #recordIds; -- 录像总数
    self:clearFightData();
    self.recordIdIdx = 1;
    local battleCall = function (param)
        -- 点击开始战斗
        if (param == 'begin') then
            self.isFighting = true;
            recordIds = self.recordIds
            recordIdCount = #recordIds;
            -- 播放战斗动画
            local recordId = recordIds[recordIdIdx] and recordIds[recordIdIdx] or -1
            local info = {
                recordId     = recordId,
                gamePlayType = gamePlayType
            }
            if info.recordId ~= -1 then
                BattleModel:requestBattleRecord(recordId,nil,gamePlayType)
            else
                printTable(1, "======= 服务器数据错误 ======");
            end
            recordIdIdx = recordIdIdx + 1;
            self.fightIndex = 0
        elseif (param == 'next') then
            print(8848, "-------- 下一场战斗播放 -----");
            self.fightIndex = self.fightIndex + 1
            if recordIdIdx ~= 4 then
                local result = self.fightData[recordIdIdx-1].result
                local info = {
                    result = result,  -- 上一场战斗输赢
                    index = recordIdIdx-1, -- 上一场战斗索引
                    battleData = self.fightData, -- 战斗结果
                }
                Dispatcher.dispatchEvent(EventType.StridePVPAddTopView_refreshPanel,info)
            end
            -- 还有战斗
            self.recordIdIdx = self.recordIdIdx + 1;
            if (recordIdIdx <= recordIdCount) then
                local info = {
                    recordId     = recordIds[recordIdIdx],
                    gamePlayType = gamePlayType
                }
				BattleModel:requestBattleRecord(info.recordId,nil,gamePlayType)
                recordIdIdx = recordIdIdx + 1;
            else
                local result = self.fightData[recordIdIdx-1].result
                local info = {
                    result = result,  -- 上一场战斗输赢
                    index = 3, -- 上一场战斗索引
                    battleData = self.fightData, -- 战斗结果
                }
                Dispatcher.dispatchEvent(EventType.StridePVPAddTopView_refreshPanel,info)
                Dispatcher.dispatchEvent("battle_end", {arrayType = GameDef.BattleArrayType.TopArenaAckOne});
            end
        elseif (param == "end") then
            print(8848, "====== 战斗结束 ========");
            if (recordIdIdx <= recordIdCount) then
                self:clearFightData();
            end
            -- ViewManager.open("StrideRecordInView") --竞猜
            self.isFighting = false;
        elseif (param == "cancel") then
            self.isFighting = false;
        end
    end
    local args = {
        fightID= self.fightId,
        configType= GameDef.BattleArrayType.TopArenaAckOne,
        skipArray = true,
    }
    Dispatcher.dispatchEvent(EventType.battle_requestFunc, battleCall, args);
end

--布阵 战斗相关------------
--布阵 战斗相关------------

return StrideServerModel
