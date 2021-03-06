--Name : RuneSystemController.lua
--Author : generated by FairyGUI
--Date : 2020-5-21
--Desc : 

local RuneSystemController = class("RuneSystemController",Controller)

function RuneSystemController:init()
	
end

--只有两个地方会通知 1  主动请求  2.服务器等级触发
function RuneSystemController:Rune_SendPageInfo(_,params)
    -- printTable(1,"服务器数据协议 Rune_SendPageInfo",params)
    if params.pageRecordId and params.pageRecordId>0 then
    	 ModelManager.RuneSystemModel:setCurBjRuneID(params.pageRecordId)
    else
    	 ModelManager.RuneSystemModel:setCurBjRuneID(1)
    end
	ModelManager.RuneSystemModel:setAllRunePages(params.data)
	RuneSystemModel:setFreeTimes( params.freeTimes )
end

function RuneSystemController:card_delete_event(_,uuid)
	RuneSystemModel:cardDeleteEvent(uuid)
end

function RuneSystemController:cardView_levelUpSuc()
	RuneSystemModel:checkRuneRedDot()
end

return RuneSystemController