--Name : MazeController.lua
--Author : generated by FairyGUI
--Date : 2020-4-11
--Desc : 

local MazeController = class("MazeController",Controller)
local MazeConfiger  = require "Game.ConfigReaders.MazeConfiger"
function MazeController:init()
end

--下推更新格子信息
function MazeController:Maze_UpdataNewInfo( _,params )
	-- printTable(1,"Maze_UpdataNewInfo",params)
	local lastData = TableUtil.DeepCopy(ModelManager.MazeModel:getData())
	printTable(1,lastData)
	local count = 0
	for k,v in pairs(params.afterGrid) do
		count = count + 1
	end
	local lastCount = 0
	if lastData and lastData.afterGrid then
		for k,v in pairs(lastData.afterGrid) do
			lastCount = lastCount + 1
		end
	end
	-- print(1,"lastCount",lastCount)
	-- print(1,"count",count)
	ModelManager.MazeModel:setData(params)
	local squadVal = MazeConfiger.getSquadShow()
	if lastData and lastData.roundNumber and params.roundNumber>lastData.roundNumber  then
		--每轮重置 不再提示标识
		MazeModel:setShopBuyFlag(false)
	end
	if lastData and lastData.roundNumber and params.roundNumber and params.roundNumber>=squadVal-1 and params.roundNumber>lastData.roundNumber  then
		print(1,"第四轮 并且是刚好卡到轮回时间")
		--如果是下一轮的更新
		local params = {}
		params.onSuccess = function (res )
		    MazeModel:setLayerMirrorData(res.mirrorHero)
	        Dispatcher.dispatchEvent("maze_update_MazeView")
		end
		RPCReq.Maze_GetLayerAllHeroMirror(params, params.onSuccess)
	elseif lastCount>0 and count==0  then  --又一特殊处理  从前一层传送到下一层的时候 战力数据问题
		print(1,"跳层时 重新拉取战力数据")
		local params = {}
		params.onSuccess = function (res )
		    MazeModel:setLayerMirrorData(res.mirrorHero)
	        Dispatcher.dispatchEvent("maze_update_MazeView")
		end
		RPCReq.Maze_GetLayerAllHeroMirror(params, params.onSuccess)
	else
	    Dispatcher.dispatchEvent("maze_update_MazeView")
	end
end

--检测魔王打赢没有
function MazeController:maze_check_open_getGodRes( _,params )
	print(1,"maze_check_open_getGodRes")
	local data = ModelManager.MazeModel:getData()
	local config = MazeConfiger.getConfigByMazeId(data.Grid)
	local curFloor = tonumber(string.sub(data.Grid,1,1))
	local lastGezi = false
	if curFloor>2  then
		local next =  config.next
		if #next==1 then
			local nextConfig  = MazeConfiger.getConfigByMazeId(next[1])
			if #nextConfig.next<=0 then
				lastGezi = true
			end
		end
	end

	if config.mazetype>=5 and config.mazetype<=8 and data.successful==1 then
		if not lastGezi then
			ViewManager.open("GodResGetView",{config =config})
		end
	end
end


return MazeController