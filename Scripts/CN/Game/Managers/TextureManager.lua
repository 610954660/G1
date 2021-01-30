--added by wyang TextureManager管理类
---@class TextureManager
local TextureManager = {}


--package 管理器初始化
--暂定5秒一次检查 包资源使用情况
function TextureManager.init( ... )
    TextureManager.__timerId = false
    TextureManager.__checkTime = 5
    TextureManager.__referTime = 20
    TextureManager.startCheckAssets()
end

--定时检测包使用
function TextureManager.startCheckAssets(  )
    if TextureManager.__timerId then
        Scheduler.unschedule(TextureManager.__timerId)
    end
    TextureManager.__timerId = Scheduler.schedule(function()
        --print(1,"清除无用包体")
        TextureManager.clearUnusedAssets()
    end, TextureManager.__checkTime)
end

function TextureManager.clearUnusedAssets()
	local isInBattle = false
	if ViewManager.isShow("BattleBeginView") or ViewManager.isShow("BattlePrepareView") then
		isInBattle = true
	end
	
	--LuaLogE("TextureManager.clearUnusedAssets")
	if not isInBattle then
		--LuaLogE("TextureManager.clearUnusedAssets not battle")
		local nowTime = cc.millisecondNow()
		local removeTime = display.lastClearTime
		local freeTime = nowTime - removeTime
		if freeTime >= TextureManager.__referTime * 1000 then
			--LuaLogE("TextureManager.clearUnusedAssets clear")
			display.removeUnusedSpriteFrames()
		end 
	end
end

return TextureManager