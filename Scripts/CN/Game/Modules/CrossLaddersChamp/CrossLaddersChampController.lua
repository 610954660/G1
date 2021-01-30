--Date :2021-01-13
--Author : generated by FairyGUI
--Desc : 

local CrossLaddersChampController = class("CrossLaddersChamp",Controller)

function CrossLaddersChampController:init()
	
end

-- #活动状态通知
-- SkyLadChampion_UpdateStatus 15097 {
--     request {
--        stage      1:integer   # 阶段
--        status     2:integer   # 状态
--        startMs    3:integer   # 开始时间
--        endMs      4:integer   # 结束时间
--     }
-- }
function CrossLaddersChampController:SkyLadChampion_UpdateStatus(_,params)
    printTable(8850,">>>>活动状态通知>SkyLadChampion_UpdateStatus>>",params)
    CrossLaddersChampModel:initStatusInfo(params)
end

-- 有数据的话自动弹出竞猜界面
-- SkyLadChampion_GuessResult 3482 {
--     request {
--         result      1:boolean
--         info        2:PSkyLadChampion_GuessInfo
--         recordId    3:integer  #战斗记录
--     }
-- }
local timer = false
function CrossLaddersChampController:SkyLadChampion_GuessResult(_,params)
    printTable(8850,">>>SkyLadChampion_GuessResult>>自动弹竞猜>>",params)
    if params.info and params.info.nodeId then
        CrossLaddersChampModel.recordId = params.recordId
        local stopTimes = 180
        local sec = 0
		local function onCountDown(dt)
			sec = sec + dt
			if sec >= 1 then
				stopTimes = stopTimes - sec
				sec = sec -1
				if stopTimes <= 0 then
                    stopTimes = 0
                    ViewManager.close("ReWardView")
                    ViewManager.close("CrossLaddersChampQuizView")
                    ViewManager.open("CrossLaddersChampQuizView",
                        {
                            enterType = 4,
                            result = params.result,
                            data  = params.info,
                    })
                    if timer then
                        Scheduler.unschedule(timer)
                    end
				end
			end
        end
        if timer then
            Scheduler.unschedule(timer)
        end
	    timer = Scheduler.schedule(function(dt)
            onCountDown(dt)
        end,0.01)
    end
end

-- SkyLadChampion_PlayerData 8326 {
--     request {
--        likeTimes     1:integer  #使用次数
--        playerList    2:*integer #点过赞的玩家
--     }
-- }
function CrossLaddersChampController:SkyLadChampion_PlayerData(_,params)
    printTable(8850,">>>params>>>SkyLadChampion_PlayerData>",params)
    CrossLaddersChampModel:setLikeTimes(params.likeTimes or 0)
    CrossLaddersChampModel.playerList = params.playerList or {}
end

return CrossLaddersChampController