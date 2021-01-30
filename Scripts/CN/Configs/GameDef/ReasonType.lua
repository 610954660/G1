--更新原因，这里主要列举功能点吧，比如获取物品更新原因可以是掉落，打开礼包，市场等。主要用于log，偶尔客户端也可以借用这里做区分性的表现，比如礼包开启的物品获取可以做些表现特效
return {
	UseItem				= 0, 	--使用物品
	MasterDown			= 1,	--宿主服务挂了
	BagArrange			= 2,	--整理背包
	NoMapAvailable		= 3,	--没有场景可用
	NetDisconnected		= 4,	--网络异常断开
	LoginError			= 5,	--登陆异常
	ElseLogin			= 6,	--同账号人在登陆
	Logout				= 7,	--登出
	Drop				= 8,	--掉落
	GiftBag 			= 9,	--打开礼包获得
	ODMUpdateFailed		= 10,	--数据保存异常踢号
	GMKickPlayer		= 11,	--GM强制离线
	DelPlayer			= 12,	--删除角色
	ReLogin 			= 13,	--重登

	--动态服务对象管理取消注册
	MgrSrvClose			= 100,	--管理服务非正常终止
	SameKeySrvOGRegReplace = 101,	--别的相同的key值的对象把你赶走了
	

	--agent 200-1000
	Shopping			= 200,	--商店购买
	Upgrade				= 201,	--物品升级
	Compose				= 202,  --物品合成
	UsePack				= 203,	--使用礼包
	VipPack				= 204,	--VIP升级礼包
	Renew				= 205,	--物品续费
	
}