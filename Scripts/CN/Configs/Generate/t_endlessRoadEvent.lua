--This file is auto transformed from excel sheet file by script. 
--You **should NOT** edit it manually.
--Copyright @Guangyv Games 2016.

-- EndlessRoad.xls
-- EndlessRoadEvent
-- DynamicConfigData.t_endlessRoadEvent

return {
	[1] = {
		eventType = 1,name = "普通敌人",costPoint = 3,weight = 200,mutex = 0,desc = ""
	},
	[2] = {
		eventType = 2,name = "精英敌人",costPoint = 2,weight = 170,mutex = 1,desc = ""
	},
	[3] = {
		eventType = 3,name = "发现宝箱",costPoint = 1,weight = 7,mutex = 1,desc = "有概率获得丰厚奖励"
	},
	[4] = {
		eventType = 4,name = "偶遇好友",costPoint = 0,weight = 20,mutex = 1,desc = "来自好友的物资，随机恢复2-5点补给"
	},
	[5] = {
		eventType = 5,name = "偶遇会友",costPoint = 1,weight = 30,mutex = 1,desc = "会友帮忙疗伤，全体恢复50%血量"
	},
	[6] = {
		eventType = 6,name = "发现虫洞",costPoint = 3,weight = 20,mutex = 1,desc = "进入虚无的空间，随机穿梭到更远的地方"
	},
	[7] = {
		eventType = 7,name = "下个路口",costPoint = 1,weight = 40,mutex = 1,desc = "换个路口继续前进"
	},
}