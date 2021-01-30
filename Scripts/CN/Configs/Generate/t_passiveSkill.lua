--This file is auto transformed from excel sheet file by script. 
--You **should NOT** edit it manually.
--Copyright @Guangyv Games 2016.

-- Skill.xls
-- PassiveSkill
-- DynamicConfigData.t_passiveSkill

return {
	[101] = {
		id = 101,name = "强壮",desc = "增加（探员等级*10+探员星级*200）的血量",constAttr = {},growthAttr = {{attrId=1,levelRatio=10,starRatio=200,},},targetSkill = 0,power = 0,learn = 1,quality = 3,learnCost = {{type=3,code=10004101,amount=1,},},activeCost = {{type=3,code=10004101,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 101
	},
	[102] = {
		id = 102,name = "强力",desc = "增加（探员等级*2+探员星级*40）的物理攻击",constAttr = {},growthAttr = {{attrId=2,levelRatio=2,starRatio=40,},},targetSkill = 0,power = 0,learn = 1,quality = 3,learnCost = {{type=3,code=10004102,amount=1,},},activeCost = {{type=3,code=10004102,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 102
	},
	[103] = {
		id = 103,name = "法强",desc = "增加（探员等级*2+探员星级*40）的法术攻击",constAttr = {},growthAttr = {{attrId=4,levelRatio=2,starRatio=40,},},targetSkill = 0,power = 0,learn = 1,quality = 3,learnCost = {{type=3,code=10004103,amount=1,},},activeCost = {{type=3,code=10004103,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 103
	},
	[104] = {
		id = 104,name = "防御",desc = "增加（探员等级*2+探员星级*40）的物理、法术防御",constAttr = {},growthAttr = {{attrId=3,levelRatio=2,starRatio=40,},{attrId=5,levelRatio=2,starRatio=40,},},targetSkill = 0,power = 0,learn = 1,quality = 3,learnCost = {{type=3,code=10004104,amount=1,},},activeCost = {{type=3,code=10004104,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 104
	},
	[105] = {
		id = 105,name = "物暴",desc = "增加10%的物理暴击",constAttr = {{attrId=105,attrVal=1000,},},growthAttr = {},targetSkill = 0,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004105,amount=1,},},activeCost = {{type=3,code=10004105,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 105
	},
	[106] = {
		id = 106,name = "法暴",desc = "增加10%的法术暴击，部分法术类治疗技能可以暴击",constAttr = {{attrId=106,attrVal=1000,},},growthAttr = {},targetSkill = 0,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004106,amount=1,},},activeCost = {{type=3,code=10004106,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 106
	},
	[107] = {
		id = 107,name = "抗暴",desc = "受到物理、法术暴击的概率下降10%",constAttr = {{attrId=107,attrVal=1000,},{attrId=108,attrVal=1000,},},growthAttr = {},targetSkill = 0,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004107,amount=1,},},activeCost = {{type=3,code=10004107,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 107
	},
	[108] = {
		id = 108,name = "暴伤加强",desc = "增加6.6%的物理暴伤",constAttr = {{attrId=109,attrVal=660,},},growthAttr = {},targetSkill = 0,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004108,amount=1,},},activeCost = {{type=3,code=10004108,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 108
	},
	[109] = {
		id = 109,name = "法暴加强",desc = "增加6.6%的法术暴伤，部分法术类治疗技能可以受到加成",constAttr = {{attrId=110,attrVal=660,},},growthAttr = {},targetSkill = 0,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004109,amount=1,},},activeCost = {{type=3,code=10004109,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 109
	},
	[110] = {
		id = 110,name = "敏捷",desc = "增加（探员等级*1+探员星级*20）的速度",constAttr = {},growthAttr = {{attrId=6,levelRatio=1,starRatio=20,},},targetSkill = 0,power = 0,learn = 1,quality = 3,learnCost = {{type=3,code=10004110,amount=1,},},activeCost = {{type=3,code=10004110,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 110
	},
	[111] = {
		id = 111,name = "绝速",desc = "进入战斗后仅第1回合增加300点速度，不可驱散",constAttr = {},growthAttr = {},targetSkill = 111,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004111,amount=1,},},activeCost = {{type=3,code=10004111,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 111
	},
	[112] = {
		id = 112,name = "精准",desc = "增加6%的物理命中",constAttr = {{attrId=101,attrVal=600,},},growthAttr = {},targetSkill = 0,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004112,amount=1,},},activeCost = {{type=3,code=10004112,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 112
	},
	[113] = {
		id = 113,name = "会心",desc = "增加6%的法术命中",constAttr = {{attrId=102,attrVal=600,},},growthAttr = {},targetSkill = 0,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004113,amount=1,},},activeCost = {{type=3,code=10004113,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 113
	},
	[114] = {
		id = 114,name = "躲闪",desc = "增加6%的物理、法术闪避",constAttr = {{attrId=103,attrVal=600,},{attrId=104,attrVal=600,},},growthAttr = {},targetSkill = 0,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004114,amount=1,},},activeCost = {{type=3,code=10004114,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 114
	},
	[115] = {
		id = 115,name = "控制",desc = "增加10%的控制命中，只对控制类技能生效",constAttr = {{attrId=111,attrVal=1000,},},growthAttr = {},targetSkill = 0,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004115,amount=1,},},activeCost = {{type=3,code=10004115,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 115
	},
	[116] = {
		id = 116,name = "抗控",desc = "增加10%的控制抵抗，只对控制类技能生效",constAttr = {{attrId=112,attrVal=1000,},},growthAttr = {},targetSkill = 0,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004116,amount=1,},},activeCost = {{type=3,code=10004116,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 116
	},
	[117] = {
		id = 117,name = "偷袭",desc = "增加6.6%的物伤加成",constAttr = {{attrId=113,attrVal=660,},},growthAttr = {},targetSkill = 0,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004117,amount=1,},},activeCost = {{type=3,code=10004117,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 117
	},
	[118] = {
		id = 118,name = "法偷",desc = "增加6.6%的法伤加成",constAttr = {{attrId=114,attrVal=660,},},growthAttr = {},targetSkill = 0,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004118,amount=1,},},activeCost = {{type=3,code=10004118,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 118
	},
	[119] = {
		id = 119,name = "反伤",desc = "受到物理、法术伤害时，10%的概率反弹50%的伤害",constAttr = {{attrId=221,attrVal=1000,},{attrId=222,attrVal=5000,},{attrId=223,attrVal=1000,},{attrId=224,attrVal=5000,},},growthAttr = {},targetSkill = 0,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004119,amount=1,},},activeCost = {{type=3,code=10004119,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 119
	},
	[120] = {
		id = 120,name = "物理吸血",desc = "造成物理伤害时，自身恢复造成造成物理伤害5%的血量",constAttr = {{attrId=225,attrVal=500,},},growthAttr = {},targetSkill = 0,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004120,amount=1,},},activeCost = {{type=3,code=10004120,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 120
	},
	[121] = {
		id = 121,name = "法术吸血",desc = "造成法术伤害时，自身恢复造成造成法术伤害5%的血量",constAttr = {{attrId=226,attrVal=500,},},growthAttr = {},targetSkill = 0,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004121,amount=1,},},activeCost = {{type=3,code=10004121,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 121
	},
	[122] = {
		id = 122,name = "物理连击",desc = "释放物理攻击后，4%的概率再次释放该技能，造成的伤害和触发效果的概率降低为原来的50%",constAttr = {{attrId=212,attrVal=400,},{attrId=213,attrVal=4000,},{attrId=214,attrVal=5000,},},growthAttr = {},targetSkill = 0,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004122,amount=1,},},activeCost = {{type=3,code=10004122,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 122
	},
	[123] = {
		id = 123,name = "法术连击",desc = "释放法术攻击后，4%的概率再次释放该技能，造成的伤害和触发效果的概率降低为原来的50%",constAttr = {{attrId=215,attrVal=400,},{attrId=216,attrVal=4000,},{attrId=217,attrVal=5000,},},growthAttr = {},targetSkill = 0,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004123,amount=1,},},activeCost = {{type=3,code=10004123,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 123
	},
	[124] = {
		id = 124,name = "杏林",desc = "增加自己6.6%的治疗加成",constAttr = {{attrId=117,attrVal=660,},},growthAttr = {},targetSkill = 0,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004124,amount=1,},},activeCost = {{type=3,code=10004124,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 124
	},
	[125] = {
		id = 125,name = "受疗",desc = "增加自己6.6%的受疗加成",constAttr = {{attrId=118,attrVal=660,},},growthAttr = {},targetSkill = 0,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004125,amount=1,},},activeCost = {{type=3,code=10004125,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 125
	},
	[126] = {
		id = 126,name = "禁疗",desc = "（70%/目标数量）的概率使得对方受到的治疗降低7%，持续5回合，最多叠加3层",constAttr = {},growthAttr = {},targetSkill = 126,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004126,amount=1,},},activeCost = {{type=3,code=10004126,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 126
	},
	[127] = {
		id = 127,name = "终结",desc = "进入战斗7回合后，法术、物伤加成提高25%；无法驱散",constAttr = {},growthAttr = {},targetSkill = 127,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004127,amount=1,},},activeCost = {{type=3,code=10004127,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 127
	},
	[128] = {
		id = 128,name = "先发制人",desc = "进入战斗后仅前2回合增加12%的物理、法伤加成；无法驱散",constAttr = {},growthAttr = {},targetSkill = 128,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004128,amount=1,},},activeCost = {{type=3,code=10004128,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 128
	},
	[129] = {
		id = 129,name = "坚壁",desc = "进入战斗后仅前2回合增加12%的物伤、法伤减免；无法驱散",constAttr = {},growthAttr = {},targetSkill = 129,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004129,amount=1,},},activeCost = {{type=3,code=10004129,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 129
	},
	[130] = {
		id = 130,name = "永生",desc = "每回合恢复自己生命上限*4%的血量",constAttr = {},growthAttr = {},targetSkill = 130,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004130,amount=1,},},activeCost = {{type=3,code=10004130,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 130
	},
	[131] = {
		id = 131,name = "斩杀",desc = "对血量低于50%的单位提高13%的物伤加成",constAttr = {},growthAttr = {},targetSkill = 131,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004131,amount=1,},},activeCost = {{type=3,code=10004131,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 131
	},
	[132] = {
		id = 132,name = "法灭",desc = "对血量低于50%的单位提高13%的法伤加成",constAttr = {},growthAttr = {},targetSkill = 132,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004132,amount=1,},},activeCost = {{type=3,code=10004132,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 132
	},
	[133] = {
		id = 133,name = "破防",desc = "无视敌方6%的物理防御",constAttr = {},growthAttr = {},targetSkill = 133,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004133,amount=1,},},activeCost = {{type=3,code=10004133,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 133
	},
	[134] = {
		id = 134,name = "破法",desc = "无视敌方6%的法术防御",constAttr = {},growthAttr = {},targetSkill = 134,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004134,amount=1,},},activeCost = {{type=3,code=10004134,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 134
	},
	[135] = {
		id = 135,name = "固防",desc = "增加自己6%的物理、法术防御",constAttr = {},growthAttr = {},targetSkill = 135,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004135,amount=1,},},activeCost = {{type=3,code=10004135,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 135
	},
	[136] = {
		id = 136,name = "神佑复生",desc = "死亡时有4%的概率直接复活，并回复100%的生命",constAttr = {},growthAttr = {},targetSkill = 136,power = 500,learn = 1,quality = 3,learnCost = {{type=3,code=10004136,amount=1,},},activeCost = {{type=3,code=10004136,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 136
	},
	[137] = {
		id = 137,name = "舍生",desc = "自己的物理、法术减免降低20%，增加4%的物理攻击",constAttr = {},growthAttr = {},targetSkill = 137,power = 500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 137
	},
	[138] = {
		id = 138,name = "法舍",desc = "自己的物理、法术减免降低20%，增加4%的法术攻击",constAttr = {},growthAttr = {},targetSkill = 138,power = 500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {{type=2,code=2,amount=300,},},icon = 138
	},
	[201] = {
		id = 201,name = "高级强壮",desc = "增加（探员等级*50+探员星级*1000）的血量",constAttr = {},growthAttr = {{attrId=1,levelRatio=50,starRatio=1000,},},targetSkill = 0,power = 0,learn = 1,quality = 5,learnCost = {{type=3,code=10004201,amount=1,},},activeCost = {{type=3,code=10004201,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 201
	},
	[202] = {
		id = 202,name = "高级强力",desc = "增加（探员等级*10+探员星级*200）的物理攻击",constAttr = {},growthAttr = {{attrId=2,levelRatio=10,starRatio=200,},},targetSkill = 0,power = 0,learn = 1,quality = 5,learnCost = {{type=3,code=10004202,amount=1,},},activeCost = {{type=3,code=10004202,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 202
	},
	[203] = {
		id = 203,name = "高级法强",desc = "增加（探员等级*10+探员星级*200）的法术攻击",constAttr = {},growthAttr = {{attrId=4,levelRatio=10,starRatio=200,},},targetSkill = 0,power = 0,learn = 1,quality = 5,learnCost = {{type=3,code=10004203,amount=1,},},activeCost = {{type=3,code=10004203,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 203
	},
	[204] = {
		id = 204,name = "高级防御",desc = "增加（探员等级*10+探员星级*200）的物理、法术防御",constAttr = {},growthAttr = {{attrId=3,levelRatio=10,starRatio=200,},{attrId=5,levelRatio=10,starRatio=200,},},targetSkill = 0,power = 0,learn = 1,quality = 5,learnCost = {{type=3,code=10004204,amount=1,},},activeCost = {{type=3,code=10004204,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 204
	},
	[205] = {
		id = 205,name = "高级物暴",desc = "增加30%的物理暴击",constAttr = {{attrId=105,attrVal=3000,},},growthAttr = {},targetSkill = 0,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004205,amount=1,},},activeCost = {{type=3,code=10004205,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 205
	},
	[206] = {
		id = 206,name = "高级法暴",desc = "增加30%的法术暴击，部分法术类治疗技能可以暴击",constAttr = {{attrId=106,attrVal=3000,},},growthAttr = {},targetSkill = 0,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004206,amount=1,},},activeCost = {{type=3,code=10004206,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 206
	},
	[207] = {
		id = 207,name = "高级抗暴",desc = "受到物理、法术暴击的概率下降30%",constAttr = {{attrId=107,attrVal=3000,},{attrId=108,attrVal=3000,},},growthAttr = {},targetSkill = 0,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004207,amount=1,},},activeCost = {{type=3,code=10004207,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 207
	},
	[208] = {
		id = 208,name = "高级暴伤加强",desc = "增加25%的物理暴伤",constAttr = {{attrId=109,attrVal=2500,},},growthAttr = {},targetSkill = 0,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004208,amount=1,},},activeCost = {{type=3,code=10004208,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 208
	},
	[209] = {
		id = 209,name = "高级法暴加强",desc = "增加25%的法术暴伤，部分法术类治疗技能会受到法术暴伤加成",constAttr = {{attrId=110,attrVal=2500,},},growthAttr = {},targetSkill = 0,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004209,amount=1,},},activeCost = {{type=3,code=10004209,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 209
	},
	[210] = {
		id = 210,name = "高级敏捷",desc = "增加（探员等级*5+探员星级*100）的速度",constAttr = {},growthAttr = {{attrId=6,levelRatio=5,starRatio=100,},},targetSkill = 0,power = 0,learn = 1,quality = 5,learnCost = {{type=3,code=10004210,amount=1,},},activeCost = {{type=3,code=10004210,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 210
	},
	[211] = {
		id = 211,name = "高级绝速",desc = "进入战斗后仅第1回合增加20%+2500点速度，不可驱散",constAttr = {},growthAttr = {},targetSkill = 211,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004211,amount=1,},},activeCost = {{type=3,code=10004211,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 211
	},
	[212] = {
		id = 212,name = "高级精准",desc = "增加20%的物理命中，当自身的物理命中大于敌人的物理躲闪时，溢出部分转为物理伤害加成（至多伤害+10%）",constAttr = {},growthAttr = {},targetSkill = 2120,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004212,amount=1,},},activeCost = {{type=3,code=10004212,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 212
	},
	[213] = {
		id = 213,name = "高级会心",desc = "增加20%的法术命中，当自身的法术命中大于敌人的法术躲闪时，溢出部分转为法术伤害加成（至多伤害+10%）",constAttr = {},growthAttr = {},targetSkill = 2130,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004213,amount=1,},},activeCost = {{type=3,code=10004213,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 213
	},
	[214] = {
		id = 214,name = "高级躲闪",desc = "增加20%的物理、法术闪避",constAttr = {{attrId=103,attrVal=2000,},{attrId=104,attrVal=2000,},},growthAttr = {},targetSkill = 0,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004214,amount=1,},},activeCost = {{type=3,code=10004214,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 214
	},
	[215] = {
		id = 215,name = "高级控制",desc = "增加35%的控制命中，只对控制类技能生效",constAttr = {{attrId=111,attrVal=3500,},},growthAttr = {},targetSkill = 0,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004215,amount=1,},},activeCost = {{type=3,code=10004215,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 215
	},
	[216] = {
		id = 216,name = "高级抗控",desc = "增加35%的控制抵抗，只对控制类技能生效",constAttr = {{attrId=112,attrVal=3500,},},growthAttr = {},targetSkill = 0,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004216,amount=1,},},activeCost = {{type=3,code=10004216,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 216
	},
	[217] = {
		id = 217,name = "高级偷袭",desc = "增加20%的物伤加成",constAttr = {{attrId=113,attrVal=2000,},},growthAttr = {},targetSkill = 0,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004217,amount=1,},},activeCost = {{type=3,code=10004217,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 217
	},
	[218] = {
		id = 218,name = "高级法偷",desc = "增加20%的法伤加成",constAttr = {{attrId=114,attrVal=2000,},},growthAttr = {},targetSkill = 0,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004218,amount=1,},},activeCost = {{type=3,code=10004218,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 218
	},
	[219] = {
		id = 219,name = "高级反伤",desc = "受到物理、法术伤害时，40%的概率反弹50%的伤害",constAttr = {{attrId=221,attrVal=4000,},{attrId=222,attrVal=5000,},{attrId=223,attrVal=4000,},{attrId=224,attrVal=5000,},},growthAttr = {},targetSkill = 0,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004219,amount=1,},},activeCost = {{type=3,code=10004219,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 219
	},
	[220] = {
		id = 220,name = "高级物理吸血",desc = "造成物理伤害时，自身恢复造成造成物理伤害18%的血量",constAttr = {{attrId=225,attrVal=1800,},},growthAttr = {},targetSkill = 0,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004220,amount=1,},},activeCost = {{type=3,code=10004220,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 220
	},
	[221] = {
		id = 221,name = "高级法术吸血",desc = "造成法术伤害时，自身恢复造成造成法术伤害18%的血量",constAttr = {{attrId=226,attrVal=1800,},},growthAttr = {},targetSkill = 0,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004221,amount=1,},},activeCost = {{type=3,code=10004221,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 221
	},
	[222] = {
		id = 222,name = "高级物理连击",desc = "释放物理攻击后，20%的概率再次释放该技能，造成的伤害和触发效果的概率降低为原来的50%",constAttr = {{attrId=212,attrVal=2000,},{attrId=213,attrVal=10000,},{attrId=214,attrVal=5000,},},growthAttr = {},targetSkill = 0,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004222,amount=1,},},activeCost = {{type=3,code=10004222,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 222
	},
	[223] = {
		id = 223,name = "高级法术连击",desc = "释放法术攻击后，20%的概率再次释放该技能，造成的伤害和触发效果的概率降低为原来的50%",constAttr = {{attrId=215,attrVal=2000,},{attrId=216,attrVal=10000,},{attrId=217,attrVal=5000,},},growthAttr = {},targetSkill = 0,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004223,amount=1,},},activeCost = {{type=3,code=10004223,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 223
	},
	[224] = {
		id = 224,name = "高级杏林",desc = "增加自己25%的治疗加成",constAttr = {{attrId=117,attrVal=2500,},},growthAttr = {},targetSkill = 0,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004224,amount=1,},},activeCost = {{type=3,code=10004224,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 224
	},
	[225] = {
		id = 225,name = "高级受疗",desc = "增加自己25%的受疗加成",constAttr = {{attrId=118,attrVal=2500,},},growthAttr = {},targetSkill = 0,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004225,amount=1,},},activeCost = {{type=3,code=10004225,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 225
	},
	[226] = {
		id = 226,name = "高级禁疗",desc = "（100%/目标数量）的概率使得对方受到的治疗降低35%，持续5回合，最多叠加2层,无法驱散",constAttr = {},growthAttr = {},targetSkill = 226,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004226,amount=1,},},activeCost = {{type=3,code=10004226,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 226
	},
	[227] = {
		id = 227,name = "高级终结",desc = "进入战斗7回合后，法术、物伤加成提高50%，防御穿透提高60%；无法驱散",constAttr = {},growthAttr = {},targetSkill = 227,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004227,amount=1,},},activeCost = {{type=3,code=10004227,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 227
	},
	[228] = {
		id = 228,name = "高级先发制人",desc = "进入战斗后仅前2回合增加33%的物理、法伤加成；无法驱散",constAttr = {},growthAttr = {},targetSkill = 228,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004228,amount=1,},},activeCost = {{type=3,code=10004228,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 228
	},
	[229] = {
		id = 229,name = "高级坚壁",desc = "进入战斗后仅前2回合增加40%的物伤、法伤减免；无法驱散",constAttr = {},growthAttr = {},targetSkill = 229,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004229,amount=1,},},activeCost = {{type=3,code=10004229,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 229
	},
	[230] = {
		id = 230,name = "高级永生",desc = "每回合恢复自己生命上限*12%的血量",constAttr = {},growthAttr = {},targetSkill = 230,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004230,amount=1,},},activeCost = {{type=3,code=10004230,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 230
	},
	[231] = {
		id = 231,name = "高级斩杀",desc = "对血量低于50%的单位提高40%的物伤加成",constAttr = {},growthAttr = {},targetSkill = 231,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004231,amount=1,},},activeCost = {{type=3,code=10004231,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 231
	},
	[232] = {
		id = 232,name = "高级法灭",desc = "对血量低于50%的单位提高40%的法伤加成",constAttr = {},growthAttr = {},targetSkill = 232,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004232,amount=1,},},activeCost = {{type=3,code=10004232,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 232
	},
	[233] = {
		id = 233,name = "高级破防",desc = "无视敌方20%的物理防御",constAttr = {},growthAttr = {},targetSkill = 233,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004233,amount=1,},},activeCost = {{type=3,code=10004233,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 233
	},
	[234] = {
		id = 234,name = "高级破法",desc = "无视敌方20%的法术防御",constAttr = {},growthAttr = {},targetSkill = 234,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004234,amount=1,},},activeCost = {{type=3,code=10004234,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 234
	},
	[235] = {
		id = 235,name = "高级固防",desc = "增加自己20%的物理、法术防御",constAttr = {},growthAttr = {},targetSkill = 235,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004235,amount=1,},},activeCost = {{type=3,code=10004235,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 235
	},
	[236] = {
		id = 236,name = "高级神佑复生",desc = "死亡时有20%的概率直接复活，并回复100%的生命",constAttr = {},growthAttr = {},targetSkill = 236,power = 15000,learn = 1,quality = 5,learnCost = {{type=3,code=10004236,amount=1,},},activeCost = {{type=3,code=10004236,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 236
	},
	[237] = {
		id = 237,name = "高级舍生",desc = "自己的物理、法术减免降低10%，增加10%的物理攻击",constAttr = {},growthAttr = {},targetSkill = 237,power = 15000,learn = 0,quality = 5,learnCost = {{type=35002,code=5,amount=1,},},activeCost = {{type=35002,code=5,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 237
	},
	[238] = {
		id = 238,name = "高级法舍",desc = "自己的物理、法术减免降低10%，增加10%的法术攻击",constAttr = {},growthAttr = {},targetSkill = 238,power = 15000,learn = 0,quality = 5,learnCost = {{type=54001,code=5,amount=1,},},activeCost = {{type=54001,code=5,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=10000,},},icon = 238
	},
	[301] = {
		id = 301,name = "超级神盾",desc = "开场时获得自身生命上限60%血量的护盾，持续1回合，第四回合开始时获得自身生命上限40%的护盾，持续2回合",constAttr = {},growthAttr = {},targetSkill = 301,power = 50000,learn = 1,quality = 6,learnCost = {{type=3,code=10004301,amount=1,},},activeCost = {{type=3,code=10004301,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=20000,},},icon = 301
	},
	[302] = {
		id = 302,name = "超级唤醒",desc = "第五回合，释放技能时会复活己方阵亡单位中攻击最高的队友，并恢复其80%的血量，如果无队友阵亡则对敌方攻击最高的单位造成其生命上限70%的真实伤害（该伤害不超过自身生命上限的70%）",constAttr = {},growthAttr = {},targetSkill = 302,power = 50000,learn = 1,quality = 6,learnCost = {{type=3,code=10004302,amount=1,},},activeCost = {{type=3,code=10004302,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=20000,},},icon = 302
	},
	[303] = {
		id = 303,name = "超级涅槃",desc = "触发神佑或者复活后，恢复50%的怒气，并且连击概率+40%，持续2回合",constAttr = {},growthAttr = {},targetSkill = 303,power = 50000,learn = 1,quality = 6,learnCost = {{type=3,code=10004303,amount=1,},},activeCost = {{type=3,code=10004303,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=20000,},},icon = 303
	},
	[304] = {
		id = 304,name = "超级贪婪",desc = "自身获得30%的禁疗抗性，并且自身触发吸血时，也为生命最低的队友提供等量的治疗",constAttr = {},growthAttr = {},targetSkill = 304,power = 50000,learn = 1,quality = 6,learnCost = {{type=3,code=10004304,amount=1,},},activeCost = {{type=3,code=10004304,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=20000,},},icon = 304
	},
	[305] = {
		id = 305,name = "超级渡江",desc = "提高全体队友20%的速度（不可叠加），并且使得全体队友每次释放怒气技能后速度增加10%，最多叠加3层，无法驱散",constAttr = {},growthAttr = {},targetSkill = 305,power = 50000,learn = 1,quality = 6,learnCost = {{type=3,code=10004305,amount=1,},},activeCost = {{type=3,code=10004305,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=20000,},},icon = 305
	},
	[306] = {
		id = 306,name = "超级封锁",desc = "造成的伤害超过敌方生命上限的35%时，会降低对方20%的伤害加深和25%的暴击伤害加成，持续3回合，最多叠加2层",constAttr = {},growthAttr = {},targetSkill = 306,power = 50000,learn = 1,quality = 6,learnCost = {{type=3,code=10004306,amount=1,},},activeCost = {{type=3,code=10004306,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=20000,},},icon = 306
	},
	[307] = {
		id = 307,name = "超级命运",desc = "场上敌方单位每死亡一次时自身伤害加成和吸血提高4%，至多叠加10层",constAttr = {},growthAttr = {},targetSkill = 307,power = 50000,learn = 1,quality = 6,learnCost = {{type=3,code=10004307,amount=1,},},activeCost = {{type=3,code=10004307,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=20000,},},icon = 307
	},
	[308] = {
		id = 308,name = "超级疯狂",desc = "每回合提高3%的攻击和6%的速度，至多叠加6层",constAttr = {},growthAttr = {},targetSkill = 308,power = 50000,learn = 1,quality = 6,learnCost = {{type=3,code=10004308,amount=1,},},activeCost = {{type=3,code=10004308,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=20000,},},icon = 308
	},
	[309] = {
		id = 309,name = "超级流血",desc = "造成的伤害超过敌方生命上限的30%时，会撕裂敌方的伤口，在接下来的3回合每回合损失生命上限15%的血量，最多叠加2层",constAttr = {},growthAttr = {},targetSkill = 309,power = 50000,learn = 1,quality = 6,learnCost = {{type=3,code=10004309,amount=1,},},activeCost = {{type=3,code=10004309,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=20000,},},icon = 309
	},
	[310] = {
		id = 310,name = "超级禁疗",desc = "提高自身25%的生命上限，降低自己的对位单位35%的受疗效果，无法驱散，持续到战斗结束",constAttr = {},growthAttr = {},targetSkill = 310,power = 50000,learn = 1,quality = 6,learnCost = {{type=3,code=10004310,amount=1,},},activeCost = {{type=3,code=10004310,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=20000,},},icon = 310
	},
	[314] = {
		id = 314,name = "超级躲闪",desc = "增加40%的物理、法术闪避",constAttr = {{attrId=103,attrVal=4000,},{attrId=104,attrVal=4000,},},growthAttr = {},targetSkill = 0,power = 50000,learn = 0,quality = 6,learnCost = {{type=3,code=10004314,amount=1,},},activeCost = {{type=3,code=10004314,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=20000,},},icon = 314
	},
	[315] = {
		id = 315,name = "超级控制",desc = "增加60%的控制命中，只对控制类技能生效",constAttr = {{attrId=111,attrVal=6000,},},growthAttr = {},targetSkill = 0,power = 50000,learn = 0,quality = 6,learnCost = {{type=3,code=10004315,amount=1,},},activeCost = {{type=3,code=10004315,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=20000,},},icon = 315
	},
	[316] = {
		id = 316,name = "超级抗控",desc = "增加60%的控制抵抗，只对控制类技能生效",constAttr = {{attrId=112,attrVal=6000,},},growthAttr = {},targetSkill = 0,power = 50000,learn = 0,quality = 6,learnCost = {{type=3,code=10004316,amount=1,},},activeCost = {{type=3,code=10004316,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=20000,},},icon = 316
	},
	[317] = {
		id = 317,name = "超级偷袭",desc = "增加40%的物伤加成",constAttr = {{attrId=113,attrVal=4000,},},growthAttr = {},targetSkill = 0,power = 50000,learn = 0,quality = 6,learnCost = {{type=3,code=10004317,amount=1,},},activeCost = {{type=3,code=10004317,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=20000,},},icon = 317
	},
	[318] = {
		id = 318,name = "超级法偷",desc = "增加40%的法伤加成",constAttr = {{attrId=114,attrVal=4000,},},growthAttr = {},targetSkill = 0,power = 50000,learn = 0,quality = 6,learnCost = {{type=3,code=10004318,amount=1,},},activeCost = {{type=3,code=10004318,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=20000,},},icon = 318
	},
	[319] = {
		id = 319,name = "超级反伤",desc = "受到物理、法术伤害时，70%的概率反弹60%的伤害",constAttr = {{attrId=221,attrVal=7000,},{attrId=222,attrVal=6000,},{attrId=223,attrVal=7000,},{attrId=224,attrVal=6000,},},growthAttr = {},targetSkill = 0,power = 50000,learn = 0,quality = 6,learnCost = {{type=3,code=10004319,amount=1,},},activeCost = {{type=3,code=10004319,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=20000,},},icon = 319
	},
	[320] = {
		id = 320,name = "超级物理吸血",desc = "造成物理伤害时，自身恢复造成造成物理伤害30%的血量",constAttr = {{attrId=225,attrVal=3000,},},growthAttr = {},targetSkill = 0,power = 50000,learn = 0,quality = 6,learnCost = {{type=3,code=10004320,amount=1,},},activeCost = {{type=3,code=10004320,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=20000,},},icon = 320
	},
	[321] = {
		id = 321,name = "超级法术吸血",desc = "造成法术伤害时，自身恢复造成造成法术伤害30%的血量",constAttr = {{attrId=226,attrVal=3000,},},growthAttr = {},targetSkill = 0,power = 50000,learn = 0,quality = 6,learnCost = {{type=3,code=10004321,amount=1,},},activeCost = {{type=3,code=10004321,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=20000,},},icon = 321
	},
	[322] = {
		id = 322,name = "超级物理连击",desc = "释放物理攻击后，40%的概率再次释放该技能，触发效果的概率降低为原来的50%",constAttr = {{attrId=212,attrVal=4000,},{attrId=213,attrVal=10000,},{attrId=214,attrVal=5000,},},growthAttr = {},targetSkill = 0,power = 50000,learn = 0,quality = 6,learnCost = {{type=3,code=10004322,amount=1,},},activeCost = {{type=3,code=10004322,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=20000,},},icon = 322
	},
	[323] = {
		id = 323,name = "超级法术连击",desc = "释放法术攻击后，40%的概率再次释放该技能，触发效果的概率降低为原来的50%",constAttr = {{attrId=215,attrVal=4000,},{attrId=216,attrVal=10000,},{attrId=217,attrVal=5000,},},growthAttr = {},targetSkill = 0,power = 50000,learn = 0,quality = 6,learnCost = {{type=3,code=10004323,amount=1,},},activeCost = {{type=3,code=10004323,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=20000,},},icon = 323
	},
	[324] = {
		id = 324,name = "超级杏林",desc = "增加自己40%的治疗加成",constAttr = {{attrId=117,attrVal=4000,},},growthAttr = {},targetSkill = 0,power = 50000,learn = 0,quality = 6,learnCost = {{type=3,code=10004324,amount=1,},},activeCost = {{type=3,code=10004324,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=20000,},},icon = 324
	},
	[325] = {
		id = 325,name = "超级受疗",desc = "增加自己40%的受疗加成",constAttr = {{attrId=118,attrVal=4000,},},growthAttr = {},targetSkill = 0,power = 50000,learn = 0,quality = 6,learnCost = {{type=3,code=10004325,amount=1,},},activeCost = {{type=3,code=10004325,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=20000,},},icon = 325
	},
	[337] = {
		id = 337,name = "超级抗连",desc = "连击抵抗+50%，并且敌方单位每触发一次连击恢复血量上限30%的生命（在敌方释放连击前回血）",constAttr = {},growthAttr = {},targetSkill = 337,power = 50000,learn = 1,quality = 6,learnCost = {{type=3,code=10004337,amount=1,},},activeCost = {{type=3,code=10004337,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=20000,},},icon = 337
	},
	[338] = {
		id = 338,name = "超级转移",desc = "将自己和己方当前血量最高的单位链接起来，自身受到的伤害转移50%到链接单位上",constAttr = {},growthAttr = {},targetSkill = 338,power = 50000,learn = 1,quality = 6,learnCost = {{type=3,code=10004338,amount=1,},},activeCost = {{type=3,code=10004338,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=20000,},},icon = 338
	},
	[339] = {
		id = 339,name = "超级恢复",desc = "每次受到攻击，恢复己方血量最低单位血量上限20%的生命",constAttr = {},growthAttr = {},targetSkill = 339,power = 50000,learn = 1,quality = 6,learnCost = {{type=3,code=10004339,amount=1,},},activeCost = {{type=3,code=10004339,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=20000,},},icon = 339
	},
	[340] = {
		id = 340,name = "超级护盾",desc = "第三回合将自身前两回合受到伤害的200%转化为护盾提供给自己，护盾持续4回合",constAttr = {},growthAttr = {},targetSkill = 340,power = 50000,learn = 1,quality = 6,learnCost = {{type=3,code=10004340,amount=1,},},activeCost = {{type=3,code=10004340,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=20000,},},icon = 340
	},
	[341] = {
		id = 341,name = "超级战神",desc = "每死亡一名队友自身伤害减免提高6%，并恢复自身血量上限30%的血量",constAttr = {},growthAttr = {},targetSkill = 341,power = 50000,learn = 1,quality = 6,learnCost = {{type=3,code=10004341,amount=1,},},activeCost = {{type=3,code=10004341,amount=1,},},activeMoneyCost = {{type=2,code=2,amount=20000,},},icon = 341
	},
	[501] = {
		id = 501,name = "物理暴击+5%",desc = "物理暴击+5%",constAttr = {{attrId=105,attrVal=500,},},growthAttr = {},targetSkill = 0,power = 3750,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 501
	},
	[502] = {
		id = 502,name = "物理抗暴+5%",desc = "物理抗暴+5%",constAttr = {{attrId=107,attrVal=500,},},growthAttr = {},targetSkill = 0,power = 3750,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 502
	},
	[503] = {
		id = 503,name = "法术暴击+5%",desc = "法术暴击+5%",constAttr = {{attrId=106,attrVal=500,},},growthAttr = {},targetSkill = 0,power = 3750,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 503
	},
	[504] = {
		id = 504,name = "法术抗暴+5%",desc = "法术抗暴+5%",constAttr = {{attrId=108,attrVal=500,},},growthAttr = {},targetSkill = 0,power = 3750,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 504
	},
	[505] = {
		id = 505,name = "控制命中+5%",desc = "控制命中+5%",constAttr = {{attrId=111,attrVal=500,},},growthAttr = {},targetSkill = 0,power = 3750,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 505
	},
	[506] = {
		id = 506,name = "抵抗封印+5%",desc = "抵抗控制+5%",constAttr = {{attrId=112,attrVal=500,},},growthAttr = {},targetSkill = 0,power = 3750,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 506
	},
	[507] = {
		id = 507,name = "高级神佑",desc = "战斗时当HP=0时，5%的几率出现神佑复活效果。",constAttr = {{attrId=218,attrVal=500,},},growthAttr = {},targetSkill = 0,power = 3750,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 507
	},
	[508] = {
		id = 508,name = "高级神农",desc = "自身使用治疗技能时，治疗量增加5%",constAttr = {{attrId=117,attrVal=500,},},growthAttr = {},targetSkill = 0,power = 3750,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 508
	},
	[509] = {
		id = 509,name = "高级绝杀",desc = "攻击时有15%几率将当前气血小于自身攻击力×1的单位直接击杀。",constAttr = {},growthAttr = {},targetSkill = 0,power = 3750,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 509
	},
	[510] = {
		id = 510,name = "高级暴怒",desc = "获得愤怒时额外增加8%。",constAttr = {{attrId=229,attrVal=800,},},growthAttr = {},targetSkill = 0,power = 3750,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 510
	},
	[511] = {
		id = 511,name = "高级再生",desc = "每回合回复等级*5的气血。",constAttr = {},growthAttr = {},targetSkill = 0,power = 3750,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 511
	},
	[512] = {
		id = 512,name = "忽视物防+5%",desc = "攻击时忽视目标5%的物理防御",constAttr = {{attrId=227,attrVal=500,},},growthAttr = {},targetSkill = 0,power = 3750,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 512
	},
	[513] = {
		id = 513,name = "忽视法防+5%",desc = "攻击时忽视目标5%的法术防御",constAttr = {{attrId=228,attrVal=500,},},growthAttr = {},targetSkill = 0,power = 3750,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 513
	},
	[514] = {
		id = 514,name = "物理连击+5%",desc = "提升5%物理连击概率",constAttr = {{attrId=212,attrVal=500,},},growthAttr = {},targetSkill = 0,power = 3750,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 514
	},
	[515] = {
		id = 515,name = "法术连击+5%",desc = "提升5%法术连击概率",constAttr = {{attrId=215,attrVal=500,},},growthAttr = {},targetSkill = 0,power = 3750,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 515
	},
	[516] = {
		id = 516,name = "高级将神",desc = "进入战斗后，每回合增加一层将神效果（增加2%物理伤害结果），最多叠加5层。",constAttr = {},growthAttr = {},targetSkill = 516,power = 3750,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 516
	},
	[517] = {
		id = 517,name = "高级仙法",desc = "进入战斗后，每回合增加一层仙法效果（增加2%法术伤害结果），最多叠加5层。",constAttr = {},growthAttr = {},targetSkill = 517,power = 3750,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 517
	},
	[518] = {
		id = 518,name = "伤害减免",desc = "自身受到的所有伤害结果降低5%",constAttr = {{attrId=115,attrVal=500,},{attrId=116,attrVal=500,},},growthAttr = {},targetSkill = 0,power = 3750,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 518
	},
	[530] = {
		id = 530,name = "高级铁甲",desc = "受到的物理伤害结果减免30%",constAttr = {{attrId=115,attrVal=3000,},},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 530
	},
	[531] = {
		id = 531,name = "高级仙甲",desc = "受到的法术伤害结果减免30%",constAttr = {{attrId=116,attrVal=3000,},},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 531
	},
	[532] = {
		id = 532,name = "高级强身",desc = "增加（探员等级*50+探员星级*1000）的血量",constAttr = {},growthAttr = {{attrId=1,levelRatio=50,starRatio=1000,},},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 532
	},
	[533] = {
		id = 533,name = "高级恢复",desc = "自身释放治疗技能时，恢复量提升20%",constAttr = {{attrId=117,attrVal=2000,},},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 533
	},
	[534] = {
		id = 534,name = "高级迅捷",desc = "增加（探员等级*5+探员星级*100）的速度",constAttr = {},growthAttr = {{attrId=6,levelRatio=5,starRatio=100,},},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 534
	},
	[535] = {
		id = 535,name = "高级偷袭",desc = "增加物理伤害结果20%",constAttr = {{attrId=113,attrVal=2000,},},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 535
	},
	[536] = {
		id = 536,name = "高级法偷",desc = "增加法术伤害结果20%",constAttr = {{attrId=114,attrVal=2000,},},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 536
	},
	[537] = {
		id = 537,name = "高级物暴",desc = "增加30%的物理暴击，物理类治疗技能可以暴击",constAttr = {{attrId=105,attrVal=3000,},},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 537
	},
	[538] = {
		id = 538,name = "高级法暴",desc = "增加30%的法术暴击，法术类治疗技能可以暴击",constAttr = {{attrId=106,attrVal=3000,},},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 538
	},
	[539] = {
		id = 539,name = "高级抗暴",desc = "受到物理、法术暴击的概率下降30%",constAttr = {{attrId=107,attrVal=3000,},{attrId=108,attrVal=3000,},},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 539
	},
	[540] = {
		id = 540,name = "高级控制",desc = "增加20%的控制命中，只对控制类技能生效",constAttr = {{attrId=111,attrVal=2000,},},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 540
	},
	[541] = {
		id = 541,name = "高级抗控",desc = "增加20%的控制抵抗，只对控制类技能生效",constAttr = {{attrId=112,attrVal=2000,},},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 541
	},
	[542] = {
		id = 542,name = "物理加固",desc = "物理防御+35%",constAttr = {},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 541
	},
	[543] = {
		id = 543,name = "法术加固",desc = "法术防御+35%",constAttr = {},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 541
	},
	[544] = {
		id = 544,name = "法术灭绝",desc = "对血量低于60%的单位，法术爆伤提高50%",constAttr = {},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 541
	},
	[545] = {
		id = 545,name = "物理灭绝",desc = "对血量低于60%的单位，物理爆伤提高50%",constAttr = {},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 541
	},
	[546] = {
		id = 546,name = "物理稳固",desc = "对血量低于60%的单位，物伤减免提高40%",constAttr = {},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 541
	},
	[547] = {
		id = 547,name = "法术稳固",desc = "对血量低于60%的单位，法伤减免提高40%",constAttr = {},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 541
	},
	[548] = {
		id = 548,name = "高级回天",desc = "自身血量低于50%时，物理吸血提高35%",constAttr = {},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 541
	},
	[549] = {
		id = 549,name = "高级法回",desc = "自身血量低于50%时，法术吸血提高35%",constAttr = {},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 541
	},
	[550] = {
		id = 550,name = "饰品技能1",desc = "攻击（100%/目标数量）概率造成敌方速度降低35%，持续2回合",constAttr = {},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 541
	},
	[551] = {
		id = 551,name = "饰品技能2",desc = "攻击50%概率造成敌方速度降低20%，持续2回合",constAttr = {},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 541
	},
	[552] = {
		id = 552,name = "饰品技能3",desc = "攻击（40%/目标数量）概率封印对方的暴击2回合，无法驱散",constAttr = {},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 541
	},
	[553] = {
		id = 553,name = "饰品技能4",desc = "攻击（50%/目标数量）概率使得对方受到的伤害加深40%，持续2回合，无法驱散",constAttr = {},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 541
	},
	[554] = {
		id = 554,name = "饰品技能5",desc = "攻击（50%/目标数量）概率使得对方陷入幽魂状态，持续2回合；幽魂状态：无法触发神佑复生",constAttr = {},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 541
	},
	[555] = {
		id = 555,name = "饰品技能6",desc = "开场时自己和血量最低的队友获得饰品拥有者血量上限25%的护盾，持续2回合",constAttr = {},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 541
	},
	[556] = {
		id = 556,name = "饰品技能7",desc = "开场时获得30%的怒气",constAttr = {},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 541
	},
	[557] = {
		id = 557,name = "饰品技能8",desc = "4回合后，会一次性恢复自身60%的血量；",constAttr = {},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 541
	},
	[558] = {
		id = 558,name = "饰品技能9",desc = "进入战斗后每回合速度提高10%，最多叠加5层，持续到战斗结束，无法驱散",constAttr = {},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 541
	},
	[559] = {
		id = 559,name = "饰品技能10",desc = "开场时自己和血量最低的队友获得饰品拥有者攻击力40%的护盾，持续2回合",constAttr = {},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 541
	},
	[560] = {
		id = 560,name = "饰品技能11",desc = "物理命中+30%，当自己的命中高于敌人的闪避时，命中的溢出部分会转为伤害加成（伤害加成最高不超过30%，必中技能必定触发最高伤害加成）",constAttr = {},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 541
	},
	[561] = {
		id = 561,name = "饰品技能12",desc = "法术命中+30%，当自己的命中高于敌人的闪避时，命中的溢出部分会转为伤害加成（伤害加成最高不超过30%，必中技能必定触发最高伤害加成）",constAttr = {},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 541
	},
	[562] = {
		id = 562,name = "饰品技能13",desc = "获得护盾时，护盾量增加35%",constAttr = {},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 541
	},
	[563] = {
		id = 563,name = "饰品技能14",desc = "被控制时，物伤减免+80%",constAttr = {},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 541
	},
	[564] = {
		id = 564,name = "饰品技能15",desc = "被控制时，法伤减免+80%",constAttr = {},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 541
	},
	[565] = {
		id = 565,name = "饰品技能16",desc = "被控制后，回合结束时恢复自身血量上限25%的血量",constAttr = {},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 5,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 541
	},
	[601] = {
		id = 601,name = "物理暴击+2%",desc = "物理暴击+2%",constAttr = {{attrId=105,attrVal=200,},},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 601
	},
	[602] = {
		id = 602,name = "物理抗暴+2%",desc = "物理抗暴+2%",constAttr = {{attrId=107,attrVal=200,},},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 602
	},
	[603] = {
		id = 603,name = "法术暴击+2%",desc = "法术暴击+2%",constAttr = {{attrId=106,attrVal=200,},},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 603
	},
	[604] = {
		id = 604,name = "法术抗暴+2%",desc = "法术抗暴+2%",constAttr = {{attrId=108,attrVal=200,},},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 604
	},
	[605] = {
		id = 605,name = "控制命中+2%",desc = "控制命中+2%",constAttr = {{attrId=111,attrVal=200,},},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 605
	},
	[606] = {
		id = 606,name = "抵抗封印+2%",desc = "抵抗控制+2%",constAttr = {{attrId=112,attrVal=200,},},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 606
	},
	[607] = {
		id = 607,name = "低级神佑",desc = "战斗时当HP=0时，2%的几率出现神佑复活效果。",constAttr = {{attrId=218,attrVal=200,},},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 607
	},
	[608] = {
		id = 608,name = "低级神农",desc = "自身使用治疗技能时，治疗量增加2%",constAttr = {{attrId=117,attrVal=200,},},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 608
	},
	[609] = {
		id = 609,name = "低级绝杀",desc = "攻击时有5%几率将当前气血小于自身攻击力×1的单位直接击杀。",constAttr = {},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 609
	},
	[610] = {
		id = 610,name = "低级暴怒",desc = "获得愤怒时额外增加3%。",constAttr = {{attrId=229,attrVal=300,},},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 610
	},
	[611] = {
		id = 611,name = "低级再生",desc = "每回合回复等级*5的气血。",constAttr = {},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 611
	},
	[612] = {
		id = 612,name = "忽视物防+2%",desc = "攻击时忽视目标2%的物理防御",constAttr = {{attrId=227,attrVal=200,},},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 612
	},
	[613] = {
		id = 613,name = "忽视法防+2%",desc = "攻击时忽视目标2%的法术防御",constAttr = {{attrId=228,attrVal=200,},},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 613
	},
	[614] = {
		id = 614,name = "物理连击+2%",desc = "提升2%物理连击概率",constAttr = {{attrId=212,attrVal=200,},},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 614
	},
	[615] = {
		id = 615,name = "法术连击+2%",desc = "提升2%法术连击概率",constAttr = {{attrId=215,attrVal=200,},},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 615
	},
	[616] = {
		id = 616,name = "低级将神",desc = "进入战斗后，每回合增加一层将神效果（增加1%物理伤害结果），最多叠加5层。",constAttr = {},growthAttr = {},targetSkill = 516,power = 1500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 616
	},
	[617] = {
		id = 617,name = "低级仙法",desc = "进入战斗后，每回合增加一层仙法效果（增加1%法术伤害结果），最多叠加5层。",constAttr = {},growthAttr = {},targetSkill = 517,power = 1500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 617
	},
	[618] = {
		id = 618,name = "免伤+2%",desc = "自身受到的所有伤害结果降低2%",constAttr = {{attrId=115,attrVal=200,},{attrId=116,attrVal=200,},},growthAttr = {},targetSkill = 0,power = 1500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 618
	},
	[630] = {
		id = 630,name = "中级铁甲",desc = "受到的物理伤害结果减免12%",constAttr = {{attrId=115,attrVal=1200,},},growthAttr = {},targetSkill = 0,power = 800,learn = 0,quality = 4,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 630
	},
	[631] = {
		id = 631,name = "中级仙甲",desc = "受到的法术伤害结果减免12%",constAttr = {{attrId=116,attrVal=1200,},},growthAttr = {},targetSkill = 0,power = 800,learn = 0,quality = 4,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 631
	},
	[632] = {
		id = 632,name = "中级强身",desc = "增加（探员等级*20+探员星级*400）的血量",constAttr = {},growthAttr = {{attrId=1,levelRatio=20,starRatio=400,},},targetSkill = 0,power = 800,learn = 0,quality = 4,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 632
	},
	[633] = {
		id = 633,name = "中级恢复",desc = "自身释放治疗技能时，恢复量提升8%",constAttr = {{attrId=117,attrVal=800,},},growthAttr = {},targetSkill = 0,power = 800,learn = 0,quality = 4,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 633
	},
	[634] = {
		id = 634,name = "中级迅捷",desc = "增加（探员等级*2+探员星级*40）的速度",constAttr = {{attrId=233,attrVal=200,},},growthAttr = {{attrId=6,levelRatio=2,starRatio=40,},},targetSkill = 0,power = 800,learn = 0,quality = 4,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 634
	},
	[635] = {
		id = 635,name = "中级偷袭",desc = "增加物理伤害结果8%",constAttr = {{attrId=113,attrVal=800,},},growthAttr = {},targetSkill = 0,power = 800,learn = 0,quality = 4,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 635
	},
	[636] = {
		id = 636,name = "中级法偷",desc = "增加法术伤害结果8%",constAttr = {{attrId=114,attrVal=800,},},growthAttr = {},targetSkill = 0,power = 800,learn = 0,quality = 4,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 636
	},
	[637] = {
		id = 637,name = "中级物暴",desc = "增加12%的物理暴击，物理类治疗技能可以暴击",constAttr = {{attrId=105,attrVal=1200,},},growthAttr = {},targetSkill = 0,power = 800,learn = 0,quality = 4,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 637
	},
	[638] = {
		id = 638,name = "中级法暴",desc = "增加12%的法术暴击，法术类治疗技能可以暴击",constAttr = {{attrId=106,attrVal=1200,},},growthAttr = {},targetSkill = 0,power = 800,learn = 0,quality = 4,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 638
	},
	[639] = {
		id = 639,name = "中级抗暴",desc = "受到物理、法术暴击的概率下降12%",constAttr = {{attrId=107,attrVal=1200,},{attrId=108,attrVal=1200,},},growthAttr = {},targetSkill = 0,power = 800,learn = 0,quality = 4,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 639
	},
	[640] = {
		id = 640,name = "中级控制",desc = "增加8%的控制命中，只对控制类技能生效",constAttr = {{attrId=111,attrVal=800,},},growthAttr = {},targetSkill = 0,power = 800,learn = 0,quality = 4,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 640
	},
	[641] = {
		id = 641,name = "中级抗控",desc = "增加8%的控制抵抗，只对控制类技能生效",constAttr = {{attrId=112,attrVal=800,},},growthAttr = {},targetSkill = 0,power = 800,learn = 0,quality = 4,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 641
	},
	[701] = {
		id = 701,name = "精准",desc = "增加6%的物理命中",constAttr = {{attrId=101,attrVal=600,},},growthAttr = {},targetSkill = 0,power = 500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 701
	},
	[702] = {
		id = 702,name = "会心",desc = "增加6%的法术命中",constAttr = {{attrId=102,attrVal=600,},},growthAttr = {},targetSkill = 0,power = 500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 702
	},
	[703] = {
		id = 703,name = "突袭",desc = "增加6.6%的物伤加成",constAttr = {{attrId=113,attrVal=660,},},growthAttr = {},targetSkill = 0,power = 500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 703
	},
	[704] = {
		id = 704,name = "瞬法",desc = "增加6.6%的法伤加成",constAttr = {{attrId=114,attrVal=660,},},growthAttr = {},targetSkill = 0,power = 500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 704
	},
	[705] = {
		id = 705,name = "固本",desc = "增加自己6.6%的治疗加成",constAttr = {{attrId=117,attrVal=660,},},growthAttr = {},targetSkill = 0,power = 500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 705
	},
	[706] = {
		id = 706,name = "强身",desc = "增加（探员等级*35+探员星级*400）的血量",constAttr = {},growthAttr = {{attrId=1,levelRatio=35,starRatio=400,},},targetSkill = 0,power = 0,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 706
	},
	[707] = {
		id = 707,name = "物理吸血",desc = "造成物理伤害时，自身恢复造成造成物理伤害5%的血量",constAttr = {{attrId=225,attrVal=500,},},growthAttr = {},targetSkill = 0,power = 500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 707
	},
	[708] = {
		id = 708,name = "法术吸血",desc = "造成法术伤害时，自身恢复造成造成法术伤害5%的血量",constAttr = {{attrId=226,attrVal=500,},},growthAttr = {},targetSkill = 0,power = 500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 708
	},
	[709] = {
		id = 709,name = "壮血",desc = "增加10%的血量",constAttr = {{attrId=231,attrVal=1000,},},growthAttr = {},targetSkill = 0,power = 500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 709
	},
	[710] = {
		id = 710,name = "固防",desc = "增加10%的物防、法防",constAttr = {{attrId=202,attrVal=1000,},{attrId=204,attrVal=1000,},},growthAttr = {},targetSkill = 0,power = 500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 710
	},
	[711] = {
		id = 711,name = "敏捷",desc = "增加8%的速度",constAttr = {{attrId=233,attrVal=800,},},growthAttr = {},targetSkill = 0,power = 500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 711
	},
	[712] = {
		id = 712,name = "抗连",desc = "增加15%的连击抗性",constAttr = {{attrId=246,attrVal=1500,},},growthAttr = {},targetSkill = 0,power = 500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 712
	},
	[730] = {
		id = 730,name = "低级铁甲",desc = "受到的物理伤害结果减免6%",constAttr = {{attrId=115,attrVal=600,},},growthAttr = {},targetSkill = 0,power = 500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 730
	},
	[731] = {
		id = 731,name = "低级仙甲",desc = "受到的法术伤害结果减免6%",constAttr = {{attrId=116,attrVal=600,},},growthAttr = {},targetSkill = 0,power = 500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 731
	},
	[732] = {
		id = 732,name = "低级强身",desc = "增加（探员等级*10+探员星级*200）的血量",constAttr = {},growthAttr = {{attrId=1,levelRatio=10,starRatio=200,},},targetSkill = 0,power = 500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 732
	},
	[733] = {
		id = 733,name = "低级恢复",desc = "自身释放治疗技能时，恢复量提升4%",constAttr = {{attrId=117,attrVal=400,},},growthAttr = {},targetSkill = 0,power = 500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 733
	},
	[734] = {
		id = 734,name = "低级迅捷",desc = "增加（探员等级*1+探员星级*20）的速度",constAttr = {},growthAttr = {{attrId=6,levelRatio=1,starRatio=20,},},targetSkill = 0,power = 500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 734
	},
	[735] = {
		id = 735,name = "低级偷袭",desc = "增加物理伤害结果4%",constAttr = {{attrId=113,attrVal=400,},},growthAttr = {},targetSkill = 0,power = 500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 735
	},
	[736] = {
		id = 736,name = "低级法偷",desc = "增加法术伤害结果4%",constAttr = {{attrId=114,attrVal=400,},},growthAttr = {},targetSkill = 0,power = 500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 736
	},
	[737] = {
		id = 737,name = "低级物暴",desc = "增加6%的物理暴击，物理类治疗技能可以暴击",constAttr = {{attrId=105,attrVal=600,},},growthAttr = {},targetSkill = 0,power = 500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 737
	},
	[738] = {
		id = 738,name = "低级法暴",desc = "增加6%的法术暴击，法术类治疗技能可以暴击",constAttr = {{attrId=106,attrVal=600,},},growthAttr = {},targetSkill = 0,power = 500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 738
	},
	[739] = {
		id = 739,name = "低级抗暴",desc = "受到物理、法术暴击的概率下降6%",constAttr = {{attrId=107,attrVal=600,},{attrId=108,attrVal=600,},},growthAttr = {},targetSkill = 0,power = 500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 739
	},
	[740] = {
		id = 740,name = "低级控制",desc = "增加4%的控制命中，只对控制类技能生效",constAttr = {{attrId=111,attrVal=400,},},growthAttr = {},targetSkill = 0,power = 500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 740
	},
	[741] = {
		id = 741,name = "低级抗控",desc = "增加4%的控制抵抗，只对控制类技能生效",constAttr = {{attrId=112,attrVal=400,},},growthAttr = {},targetSkill = 0,power = 500,learn = 0,quality = 3,learnCost = {},activeCost = {},activeMoneyCost = {},icon = 741
	},
}