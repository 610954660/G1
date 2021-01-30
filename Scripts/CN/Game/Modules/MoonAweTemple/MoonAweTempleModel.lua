--Date :2020-12-01
--Author : wyz
--Desc : 

local MoonAweTempleModel = class("MoonAweTemple", BaseModel)

function MoonAweTempleModel:ctor()
    self.allGodData = {}        -- 所有神位信息
    self.curGodInfo = {}        -- 当前神位数据
    self.curRecordInfo = {}     -- 挑战记录
    self.settleEndInfo = {}
    self.godId      = false     -- 神位id
    self.resultInfo = {}        -- 结算胜利界面信息
    self:initListeners()
end

function MoonAweTempleModel:init()

end


-- 请求月慑神殿所有数据
-- #所有信息
-- StarTemple_GetInfo 18175 {
-- 	request {
-- 	}
-- 	response {
-- 		data	0:*PStarTemple_Info(id)
-- 	}
-- }

-- #普通数据
-- .PStarTemple_Info{ 
--     id                      1:integer       #神位id
--     stage                   2:integer       #当前加强状态
--     playerId                3:integer       #玩家id
--     name                    4:string        #名字
--     head                    5:integer       #头像
--     heroOpertion            6:integer       #板娘id   
--     rank                    7:integer       #我的竞技场排行  只有当前数据存在
--     headBorder              8:integer       #头像框
--     level                   9:integer                             #等级
-- }
function MoonAweTempleModel:reqStarTempleInfo()
    local reqInfo ={
    }
    RPCReq.StarTemple_GetInfo(reqInfo,function(params) 
        printTable(8848,">>>所有神位数据>>>",params)
        self.allGodData = params.data or {}
        Dispatcher.dispatchEvent(EventType.MoonAweTempleView_refreshPanal)
    end)
end

-- 获取当前神位信息
-- #当前神位信息
-- StarTemple_GetCurGodPosInfo 14317 {
-- 	request {
-- 		id 				1:integer			#神位id	
-- 	}
-- 	response {
-- 		data			0:PStarTemple_Info
-- 	}	
-- }
function MoonAweTempleModel:reqCurGodPosInfo(godId)
    local reqInfo = {
        id = godId,
    }
    RPCReq.StarTemple_GetCurGodPosInfo(reqInfo,function(params)
        self.curGodInfo = params.data or {}
        Dispatcher.dispatchEvent(EventType.MoonAweTempleChallengeView_refreshPanal)
    end)

end

-- 挑战记录
-- #获得当前神位记录
-- StarTemple_GetRecords 30971 {
-- 	request {
-- 		id 				1:integer						#神位id	
-- 	}
-- 	response {
-- 		data 			2:*PStarTemple_Record(index)	#记录信息
-- 	}	
-- }

-- #录像数据
-- .PStarTemple_Record{ 
--     index                   1:integer       #序号
--     stage                   2:integer       #当前加强状态
--     playerId                3:integer       #玩家id
--     name                    4:string        #名字
--     head                    5:integer       #头像
--     headBorder              6:integer       #头像框   
--     heroList                7:*PStarTemple_HeroRecord(id)
--     timeMs                  8:integer       #产生时间
--     level                   9:integer       #等级
--     recordId                10:integer      #录像请求id
-- }
function MoonAweTempleModel:reqRecordInfo(godId)
    local reqInfo = {
        id = godId,
    }
    printTable(8848,">>>reqInfo>>",reqInfo)
    RPCReq.StarTemple_GetRecords(reqInfo,function(params)
        self.curRecordInfo = params.data or {}
        local keys ={
            {key = "timeMs",asc = true},
        }
        TableUtil.sortByMap(self.curRecordInfo,keys)
        Dispatcher.dispatchEvent(EventType.MoonAweTempleRecordView_refresh)
    end)
end


-- 获取怪物阵容
function MoonAweTempleModel:getMonsterSquad(fightId,godId,stage)
    local fightInfo = DynamicConfigData.t_fight[fightId]
    local MoonTempleFight = DynamicConfigData.t_MoonTempleFight[godId]
    local stageLevel =  0
    local squadInfo = {}
    if MoonTempleFight and MoonTempleFight[stage] and MoonTempleFight[stage].level then
        stageLevel = MoonTempleFight[stage].level
    end
    for k,v in pairs(fightInfo.monsterStand) do
        local data = {}
        data.level = fightInfo["level" .. v]  + stageLevel
        data.star   = fightInfo["star" .. v]
        data.code   = fightInfo["monsterId" .. v]
        data.type   = 2
        table.insert(squadInfo,data)
    end
    return squadInfo
end

-- 挑战返回的信息
function MoonAweTempleModel:setSettleEndInfo(data)
    self.settleEndInfo = data or {}
end

-- 获取结算界面信息
function MoonAweTempleModel:gettleEndInfo()
    return self.settleEndInfo
end

-- 更新红点
function MoonAweTempleModel:updateRed()
	local dayStr = DateUtil.getOppostieDays()
	local isShow = FileCacheManager.getBoolForKey("MoonAweTempleView_isShow" .. dayStr,false)
	RedManager.updateValue("V_MOONAWETEMPLE", (not isShow))
end

function MoonAweTempleModel:public_enterGame()
    self:updateRed()
end
return MoonAweTempleModel
