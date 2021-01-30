--推送消息管理器
local PushNotificationManager = {}
local isInit = false
--推送管理器
local notificationInstance = gy.GYPushNotificationCenter:getInstance()

--策划只有一个推送需要，暂时先写这里
local pushData = {
    {time = "18:00:00",desc = "探长大人，来自小橘的关爱准点送达，快登录游戏领取小橘的心意吧~",days = {}}

}

--切前台
function PushNotificationManager.onEnterForeground()
    --LuaLogE("--移除推送--")
    if __IN_AUDITING__ or __ENGINE_VERSION__ < 2 then return end
    notificationInstance:removeAllNotificationForLua(0)
end

--切后台
function PushNotificationManager.onEnterBackground()
    --LuaLogE("--开始推送--")
    if __IN_AUDITING__ or not isInit or __ENGINE_VERSION__ < 2 then return end
    --固定某个时间触发
 
    for k,v in pairs(pushData) do
        notificationInstance:addLocalNotificationAtNextTime(v.time, v.desc, table.concat(v.days, ","), 0)
    end

    --激活推送
    local playerId = 0
    if PlayerModel and PlayerModel.userid ~= "" then 
        playerId = tonumber(PlayerModel.userid)
    end
    notificationInstance:active(playerId)
end

--设置静默时间
function PushNotificationManager.setInvalidNotificationTimeInterval(startMs, duration)
    notificationInstance:setInvalidNotificationTimeInterval(startMs, duration)
end


--监听前后台变化
function PushNotificationManager.init()
   -- Dispatcher.addEventListener(EventType.APP_ENTER_FOREGROUND, PushNotificationManager)
   -- Dispatcher.addEventListener(EventType.APP_ENTER_BACKGROUND, PushNotificationManager)
    isInit = true
    --进游戏、先清除推送
    PushNotificationManager.onEnterForeground()
end

function PushNotificationManager.appStateChange(toBackground)
   -- LuaLogE("-appStateChange")
    --if type(toBackground) == "table" then
      --  LuaLogE("toBackground = "..json.encode(toBackground))
   -- end
    if toBackground then
        PushNotificationManager.onEnterBackground()
    else
        PushNotificationManager.onEnterForeground()
    end
end

notificationInstance:registerNotificationHandle(PushNotificationManager.appStateChange)

return PushNotificationManager

