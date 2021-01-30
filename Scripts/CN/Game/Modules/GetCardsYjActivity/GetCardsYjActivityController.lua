--Name : GetCardsYjActivityController.lua
--Author : generated by FairyGUI
--Date : 2020-9-3
--Desc : 异界招募控制器

local GetCardsYjActivityController = class("GetCardsYjActivityController",Controller)

function GetCardsYjActivityController:init()
	
end

function GetCardsYjActivityController:Activity_UpdateData( _,params )
	if params.type == GameDef.ActivityType.Farplane then
		print(1,"GetCardsYjActivityController 活动数据更新 Activity_UpdateData")
		local data = ActivityModel:getActityByType( params.type )
		if not data then
			return
		end

		if params.fromLogin then --如果是初始化的数据
		end

		if params.endState then --如果是true 直接结束
		  	-- ActivityModel:speDeleteSeverData(params.type)
	    end
	    GetCardsYjActivityModel:initData(params)
	end


end

return GetCardsYjActivityController