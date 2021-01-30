

local PushMapController = class("PlayerController",Controller)


function PushMapController:init()
	LuaLogE("PlayerController init")
end

-- 手动注册方法
function PushMapController:_initListeners()
	
end

function PushMapController:PriviligeGift_upGiftData()--刷新快速挂机免费次数红点
	PushMapModel:upPushMapMofangRed()
end

--#推送全部挂机收益
function PushMapController:Chapters_sendAllHangUpReward(_,data)
	printTable(19,'#推送全部挂机收益',data)
end

--#推送通关记录
function PushMapController:Chapters_sendNewBattleRecord(_,data)
	printTable(28,'#推送通关记录',data)
	PushMapModel:isFirstTen()
	local city=data.record.city;
	local chapter=data.record.point
	local heroList=PushMapModel.pushMapListInfo[city] or {}
	local map={};
	local levels=PushMapModel:buildServerPointData(data.record,city,chapter)
	data.record.levels=levels
	map['star']=data.record.levels
	map['serverInfo']=data.record
	heroList[chapter]=map;
	PushMapModel.pushMapListInfo[city]=heroList;
	Dispatcher.dispatchEvent(EventType.pushMap_updatePointInfo)
	printTable(16,'#推送通关记录11111111',PushMapModel.pushMapListInfo)
	PushMapModel:getMaxCityAndChapterAndPoint()
end

--#推送红点
function PushMapController:Chapters_sendBattleRecordRedPoint(_,data)
	printTable(19,'#推送红点',data)
end

-- function PushMapController:pushMap_openWorldMapView()
-- 	ViewManager.open("PlayerInfoView")
-- end


return PushMapController