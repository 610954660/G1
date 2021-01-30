---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File
local MaterialCopyViewController = class("MaterialCopyViewController",Controller)

function MaterialCopyViewController:player_updateRoleInfo()
	MaterialCopyModel:materCopyRed()
end

function MaterialCopyViewController:update_cards_fightVal()
	MaterialCopyModel:materCopyRed()
end

function MaterialCopyViewController:pata_showNext()
	MaterialCopyModel:materCopyRed()
end

--request#下推更新次数增加次数
function MaterialCopyViewController:Limit_ConsumeTimes(_,data)
	local copyList = ModelManager.MaterialCopyModel:getCopyInfo(data.type)
	if  copyList == nil or copyList.dailyInfo == nil then
		local daily={}
		daily['times']=data.times
		local dailyList=ModelManager.MaterialCopyModel.__copyInfo[data.type] or {}
		dailyList['dailyInfo']=daily
		ModelManager.MaterialCopyModel.__copyInfo[data.type]=dailyList
	else
	 	if copyList ~= nil and copyList.dailyInfo ~= nil then
			copyList.dailyInfo.times = data.times + (copyList.dailyInfo.times or 0)
		end
	end
	MaterialCopyModel:setAllCopyRed()
	Dispatcher.dispatchEvent(EventType.materialCopy_updata,data)
end

--request#下推副本增加次数
--function MaterialCopyViewController:Limit_AddCopyTimes(_,data)
--	printTable(5,"下推副本增加次数",data);
--	--type		0:integer					#副本type
--	--times		1:integer					#增加的次数
--	--addType		2:integer					#增加的形式
--end

--副本数据更新
function MaterialCopyViewController:Copy_CopyInfo(_,data)
	for copyCode, daily in pairs(data.info) do
		local dailyList=ModelManager.MaterialCopyModel.__copyInfo[daily.gamePlayType] or {}
		dailyList['diffPass']=daily;
		ModelManager.MaterialCopyModel.__copyInfo[daily.gamePlayType]=dailyList;
		printTable(5,"副本更新星新",copyCode,daily);
		Dispatcher.dispatchEvent(EventType.materialCopy_pass,copyCode); 
	end
end


--request#更新增加次数#次数上限的更新字典
function MaterialCopyViewController:Limit_TopupUpdate(_,data)
	if data == nil or data.topups == nil then
		return
	end
	for copyType,value in pairs(data.topups) do
		local copyList= ModelManager.MaterialCopyModel:getCopyInfo(copyType);
		if  copyList==nil then
			local daily={}
			daily['topup']=value.topup;
			local dailyList=ModelManager.MaterialCopyModel.__copyInfo[copyType] or {}
			dailyList['dailyInfo']=daily;
			ModelManager.MaterialCopyModel.__copyInfo[copyType]=dailyList;
		else
			if (not copyList.dailyInfo) then
				copyList.dailyInfo = {};
			end
			copyList.dailyInfo.topup=value.topup;
		end
		MaterialCopyModel:setAllCopyRed()
		Dispatcher.dispatchEvent(EventType.materialCopy_addCopyNum,copyType); 
		printTable(22,"次数上限的更新字典后的列表",copyList);
	end 	
end


--request#request更新增加次数
--function MaterialCopyViewController:Limit_GPTopupUpdate(_,data)
--
--end


--request#跨天重置
function MaterialCopyViewController:Limit_ResetInfos(_,data)
	local dailyList=ModelManager.MaterialCopyModel.__copyInfo;
	if dailyList then
		for copyType,value in pairs(dailyList) do
			if value and value.dailyInfo and value.dailyInfo.times then
				value.dailyInfo.times = 0
				value.dailyInfo.topup = 0
				MaterialCopyModel:setAllCopyRed()
				Dispatcher.dispatchEvent(EventType.materialCopy_resetDay,copyType); 
			end
		end
	end
end

--request#同步gp购买次数
--function MaterialCopyViewController:Limit_GPTopupMaxUpdate(_,data)
--	printTable(5,"同步gp发送的参数",data);
--end


return MaterialCopyViewController
