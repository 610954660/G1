
local GuildMLSController = class("GuildMLSController", Controller)

--#魔灵山玩家个人信息数据同步
-- .EvilMountain_PlayerInfo {
--     openState               1:integer       #开启状态
--     energy                  2:integer       #精力
--     maxBossLevel            3:integer       #已召唤并击败的boss最高等级
-- }
function GuildMLSController:EvilMountain_PlayerInfoUpdate(_,params)
    ModelManager.GuildMLSModel:playerData(params.data)
end


-- #boss更新通知
-- #boss开启, boss挑战结束(被打死 或 挑战时间到), boss消失, 强制通知所有关联的玩家刷新一次
-- #主要优化停留在这个活动界面的玩家的体验
-- EvilMountain_BossUpdateNotify 26101 {
--     request {
--         updateList            1:*EvilMountain_BossUpdateInfo(updateType)    #更新列表
--     }
-- }

-- #boss更新信息
-- #更新类型, 1新开启, 2刷新, 3移除
-- #如果是移除, 需要注意, 可能玩家此时停留在被移除的Boss界面, 前端需要考虑下这部分情况
-- .EvilMountain_BossUpdateInfo {
--     updateType          1:integer       #更新类型, 1新开启, 2刷新, 3删除
--     bossId              2:integer       #bossId
--     bossInfo            3:EvilMountain_BossInfo #boss信息
-- }

function GuildMLSController:EvilMountain_BossUpdateNotify(_,params)
    ModelManager.GuildMLSModel:insertBoss(params.updateList)
end


return GuildMLSController