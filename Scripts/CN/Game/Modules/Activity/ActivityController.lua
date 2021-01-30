--added by xhd 
--活动统一控制
local ActivityController = class("ActivityController",Controller)

--有活动更新（比如开启和关闭 走这里）
function ActivityController:Activity_ActivityInfo( _,params )
	printTable(1,"Activity_ActivityInfo",params)
	ModelManager.ActivityModel:updateDataInfo(params)
end

--活动数据初始化和更新
-- type					0:integer						    #活动类型
-- fromLogin				1:boolean						#登录时的同步
-- existResCanGet 			2:boolean 						#是否存在可领取的奖励	
-- questionnaireSurvey 	3:PQuestionnaireSurvey 			    #调查问卷
--没什么好承接和分发的 各自活动监听根据类型获取需要的数据
function ActivityController:Activity_UpdateData( _,params )
	print(1,"ActivityController:Activity_UpdateData")
	if params.endState then --如果是true 直接结束
		print(1,"params.type="..params.type.."活动结束！")
		Dispatcher.dispatchEvent("close_ActivityView",nil,params.type) 
		return
	end
end

function ActivityController:module_open( ... )
	ModelManager.ActivityModel:refresh()
end

function ActivityController:Activity_ActivityShowContent(_,params )
	ActivityModel:saveShowContent(params)
end

function ActivityController:pushMap_getCurPassPoint( ... )
	print(32,"pushMap_updatePointInfo")
	local maxNum =  PushMapModel:haveBeenPassPoint()
	print(32,"maxNum",maxNum)
	ModelManager.ActivityModel:refresh()
end

return ActivityController