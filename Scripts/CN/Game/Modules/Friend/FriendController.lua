--added by xhd
--任务控制器
local FriendController = class("FriendController",Controller)

function FriendController:ctor()

end



-- function FriendController:init()
-- 	LuaLogE("FriendController init")
-- end

--[[FriendList				= 1,--好友列表
	ApplyList				= 2,--申请列表
	Blacklist				= 3,--黑名单列表
	RecommendedList 		= 4,--推荐列表
	ApplyToFriend			= 5,--申请
	DeleteFriend			= 6,--删除
	JoinFriend				= 7,--同意
	RefusedApply 			= 8,--拒绝
	UpdateCache 			= 9,--更新缓存
	MoneyFriend				= 10,--赠送好友币
--]]
function FriendController:Friend_UpdateListMsg( _,params )
    print(1,"Friend_UpdateListMsg Friend_UpdateListMsg")
    --printTable(1,params)
	local playerData = params.list[1]
	if not playerData then return end
	if(params.type == GameDef.FriendListType.ApplyList) then
		ModelManager.FriendModel:initData(params.type, params.list) --更新列表
	elseif params.type == GameDef.FriendListType.ApplyToFriend then
        ModelManager.FriendModel:ApplyToFriend(playerData) --刷新申请列表
    elseif params.type == GameDef.FriendListType.DeleteFriend then
        ModelManager.FriendModel:DeleteFriend(playerData) --刷新好友列表
    elseif params.type == GameDef.FriendListType.JoinFriend then
        ModelManager.FriendModel:JoinFriend(playerData) --刷新好友列表
        ModelManager.FriendModel:DeleteApplyToFriend(playerData) --刷新申请列表
    elseif params.type == GameDef.FriendListType.RefusedApply then
        ModelManager.FriendModel:DeleteApplyToFriend(playerData) --刷新申请列表
	elseif params.type == GameDef.FriendListType.UpdateCache then
		ModelManager.FriendModel:updatePlayerData(playerData) --玩家信息更新了
	elseif params.type == GameDef.FriendListType.MoneyFriend then
		FriendModel:addToAccept(playerData.playerId)
    end
end

function FriendController:Friend_OpenInfoView(_, param)
	-- if (param and param.playerId > 0) then
		ViewManager.open("ViewPlayerView", param);
	-- else
	-- 	RollTips.show(Desc.Friend_cant_show);
	-- end
end

-- 推送友情币信息
-- firendMoneyList 已赠送好友币列表
-- firendMoneyReceiveList 领取友情点列表
-- firendMoneyAcceptList 接收好友币列表
-- firendMoneyReceiveTimes 领取友情点数量
function FriendController:Friend_MoneyData(_, param)
	-- printTable(2233, "=== 好友点列表更新 ====", param);
	FriendModel:initFriendMoneyData(param);
	Dispatcher.dispatchEvent("friend_update_list");
end

function FriendController:clear( ... )
end

return FriendController