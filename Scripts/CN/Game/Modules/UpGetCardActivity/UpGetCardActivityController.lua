--Name : UpGetCardActivityController.lua
--Author : generated by FairyGUI
--Date : 2020-9-3
--Desc : 

local UpGetCardActivityController = class("UpGetCardActivityController",Controller)

function UpGetCardActivityController:init()
	
end

function UpGetCardActivityController:Activity_UpdateData( _,params )
	if params.type == GameDef.ActivityType.SpecialSummon then
		print(1,"UpGetCardActivityController 活动数据更新 Activity_UpdateData")
		local data = ActivityModel:getActityByType( params.type )
		if not data then
			return
		end

		if params.fromLogin then --如果是初始化的数据
		end

		if params.endState then --如果是true 直接结束
		  	-- ActivityModel:speDeleteSeverData(params.type)
	    end
	    UpGetCardActivityModel:initData(params)
	end


end

return UpGetCardActivityController