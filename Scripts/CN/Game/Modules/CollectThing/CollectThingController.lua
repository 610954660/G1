


local CollectThingController = class("CollectThingController", Controller)


function CollectThingController:Activity_UpdateData( _,params )
	Dispatcher.dispatchEvent(EventType.shopView_refreshActivityBtn)
	if params.type == GameDef.ActivityType.CollectThingsShop then
		if params and params.newHeroShop then
			CollectThingModel:initShopData(params.newHeroShop)
		end
	end

	if params.type == GameDef.ActivityType.CollectThings then
		local data = ActivityModel:getActityByType( params.type )
		if not data then
			return
		end

		if params.fromLogin then --如果是初始化的数据
		end

		if params.endState then --如果是true 直接结束
		  	ActivityModel:speDeleteSeverData(params.type)
	    else
	    	-- --修改活动时间
	    	-- local startMs = params.sevenDayTask.realEndMs - 7*24 *3600*1000
	    	-- ActivityModel:updateSevenDayTime(params.type,startMs,params.sevenDayTask.realEndMs)
	    end
	    -- printTable(999,"集物活动",params)
	    ModelManager.CollectThingModel:initData(params.collectThings,data.id)
	end


	local params = ActivityModel.actData
    for _, data in pairs(params) do
        if data.type == GameDef.ActivityType.CollectThings then
            CollectThingModel:initActivityEnd(data)
            -- printTable(8848,"集物活动", data)
            -- --修改活动时间
	    	local startMs = data.realEndMs - 7*24 *3600*1000
	    	ActivityModel:updateSevenDayTime(GameDef.ActivityType.CollectThings,startMs,data.realEndMs)
            break
        end
    end
end

return CollectThingController