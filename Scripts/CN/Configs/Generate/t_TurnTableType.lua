--This file is auto transformed from excel sheet file by script. 
--You **should NOT** edit it manually.
--Copyright @Guangyv Games 2016.

-- PowerTurnTable.xls
-- TurnTableType
-- DynamicConfigData.t_TurnTableType

return {
	[1] = {
		poolType = 1,pointType = 1,pointName = "普通能量",point = 10,draw = {{cost=1,get=1,},},tenDraw = {{cost=10,get=11,},},score = "[2,26,10]",tenScore = "[2,26,110]",needItem = {{type=3,code=10000036,amount=1,},},itemBuy = {},refresh = {{type=2,code=2,amount=30,},},refreshTime = 1440,condition = 1,startValue = 0
	},
	[2] = {
		poolType = 2,pointType = 2,pointName = "高级能量",point = 10,draw = {{cost=1,get=1,},},tenDraw = {{cost=10,get=10,},},score = "[2,26,10]",tenScore = "[2,26,100]",needItem = {{type=3,code=10000037,amount=1,},},itemBuy = {{type=2,code=1,amount=150,},},refresh = {{type=2,code=2,amount=30,},},refreshTime = 1440,condition = 3,startValue = 30
	},
}