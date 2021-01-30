--This file is auto transformed from excel sheet file by script. 
--You **should NOT** edit it manually.
--Copyright @Guangyv Games 2016.

-- TrainingCamp.xls
-- TrainingCamp
-- DynamicConfigData.t_trainingCamp

return {
	[1] = {
		id = 1,title = "限制教学",task = "眩晕能限制敌方某单位一定回合的行动，让其被动挨打",formation = {15002,34002,44001,},position = {5,},fixedhero = {{heroId=15004,pos=2,},},answer = {{heroId=15002,fightData="FightConfig6",pos=5,},{heroId=34002,fightData="FightConfig7",pos=5,},{heroId=44001,fightData="FightConfig8",pos=5,},},enemy = {{heroId=25002,pos=2,star=6,},},ModuleId = "",WindowId = {},correct = {{id=15002,pos=5,},},reward = {{type=2,code=1,amount=50000,},},tips = "灵娲拥有控制眩晕技能",tips1 = "所有的控制技能都能限制敌方某单位的行<br>动，控制技能包括冰冻、眩晕等； [img]ui://Training/1[/img] 眩晕是成功率较高的控制技能之一，但被眩晕的目标一般情况下，2回合后将解除眩晕状态。",tips2 = "若解除眩晕时，该回合已错过该探员的出手时间[color=#F43636]（出手时间详情请查看出手顺序，） [/color]则该回合该出手的探员不会出手",photo = "",herocard = {{heroId=15002,effectName="眩晕控制",},{heroId=34002,effectName="法群",},{heroId=44001,effectName="降低命中",},}
	},
	[2] = {
		id = 2,title = "先下手为强教学",task = "探员的速度属性决定了其在战斗中的出手顺序",formation = {44002,45004,55002,},position = {3,},fixedhero = {{heroId=35003,pos=4,},},answer = {{heroId=55002,fightData="TrainingSpeed1",pos=3,},{heroId=44002,fightData="TrainingSpeed2",pos=3,},{heroId=45004,fightData="TrainingSpeed3",pos=3,},},enemy = {{heroId=25002,pos=2,star=6,},},ModuleId = "",WindowId = {},correct = {{id=55002,pos=3,},},reward = {{type=2,code=1,amount=50000,},},tips = "斑衣蜡蝉可以提高全体的速度",tips1 = "[img]ui://Training/3[/img]<br>部分探员的技能可以使队员加速，实现我方慢速的输出探员能先手进攻。",tips2 = "每个回合战斗开始时，将对双方全部探员<br>的速度进行排序，速度值越大，则排名越<br>前；然后按照速度排名的先后，双方探员<br>依次出手。",photo = "",herocard = {{heroId=55002,effectName="速攻光环",},{heroId=45004,effectName="降低暴击",},{heroId=44002,effectName="治疗回血",},}
	},
	[3] = {
		id = 3,title = "减益buff教学",task = "减益buff能一定回合内降低某单位一定属性",formation = {34002,45008,25001,},position = {5,},fixedhero = {{heroId=35002,pos=2,},},answer = {{heroId=45008,fightData="FightConfig12",pos=5,},{heroId=34002,fightData="FightConfig10",pos=5,},{heroId=25001,fightData="FightConfig11",pos=5,},},enemy = {{heroId=45007,pos=5,star=6,},},ModuleId = "",WindowId = {},correct = {{id=45008,pos=5,},},reward = {{type=2,code=1,amount=50000,},},tips = "星期五是位扫除障碍的小能手",tips1 = "减益buff能对目标造成一定的影响，比如降低防御、降低输出等等 [img]ui://Training/4[/img]",tips2 = "[color=#d83a3c]特别提示：星期五的卫生死角能使敌方某目标一定回合内物理防御能力削减，让我方输出更高的伤害。[/color]",photo = "",herocard = {{heroId=45008,effectName="驱散防御",},{heroId=25001,effectName="自愈",},{heroId=34002,effectName="法群",},}
	},
	[4] = {
		id = 4,title = "站位教学",task = "合理的站位能避免敌方的重火力进攻",formation = {55008,},position = {5,6,},fixedhero = {{heroId=55009,pos=2,},},answer = {{heroId=55008,fightData="TrainingStand1",pos=6,},{heroId=55008,fightData="TrainingStand2",pos=5,},},enemy = {{heroId=54001,pos=5,star=6,},},ModuleId = "",WindowId = {},correct = {{id=55008,pos=6,},},reward = {{type=2,code=1,amount=50000,},},tips = "守护输出，避开机械赢（请移动英雄变更站位）",tips1 = "[img]ui://Training/2[/img]<br>一般而言，我们需要守护我方输出型探员，避开对方的直接攻击，让我方有反击的机<br>会。",tips2 = "",photo = "",herocard = {}
	},
	[5] = {
		id = 5,title = "增益buff教学",task = "增益buff能一定程度提升我方单位的属性",formation = {25001,34002,55006,},position = {5,},fixedhero = {{heroId=35002,pos=2,},},answer = {{heroId=55006,fightData="FightConfig9",pos=5,},{heroId=34002,fightData="FightConfig10",pos=5,},{heroId=25001,fightData="FightConfig11",pos=5,},},enemy = {{heroId=45007,pos=2,star=5,},},ModuleId = "",WindowId = {},correct = {{id=55006,pos=5,},},reward = {{type=2,code=1,amount=50000,},},tips = "匣中少女是位提升暴击率不错的探员",tips1 = "[img]ui://Training/5[/img]<br>增益buff的对象往往是我方探员，能够根据技能效果，提升我方一定的属性，也能做到让我方探员造成更多的伤害。",tips2 = "",photo = "",herocard = {{heroId=34002,effectName="法群",},{heroId=55006,effectName="加暴增伤",},{heroId=25001,effectName="自愈",},}
	},
	[6] = {
		id = 6,title = "种族克制教学",task = "种族属性之间相互克制，对应克制有伤害加成",formation = {55004,35003,45001,},position = {5,},fixedhero = {},answer = {{heroId=45001,fightData="TrainingRace1",pos=5,},{heroId=55004,fightData="TrainingRace3",pos=5,},{heroId=35003,fightData="TrainingRace2",pos=5,},},enemy = {{heroId=55001,pos=5,star=6,},},ModuleId = "",WindowId = {},correct = {{id=45001,pos=5,},},reward = {{type=2,code=1,amount=50000,},},tips = "人族能克制械族",tips1 = "种族克制效果：[color=#119717]伤害+20%[/color][img]ui://Training/6[/img]",tips2 = "人族的探员对械族的探员造成的伤害可额外造成20%伤害",photo = "",herocard = {{heroId=55004,effectName="械族辅助",},{heroId=35003,effectName="兽族射手",},{heroId=45001,effectName="人族战士",},}
	},
	[7] = {
		id = 7,title = "阵法教学",task = "特定的阵法能满足整体站位需求",formation = {},position = {},fixedhero = {{heroId=45007,pos=3,},{heroId=55010,pos=1,},},answer = {{heroId=1,fightData="TrainingArray1",pos=-1,},{heroId=0,fightData="TrainingArray2",pos=-1,},},enemy = {{heroId=25006,pos=2,star=6,},},ModuleId = 35,WindowId = {{id=5,args=2000,},},correct = {{id=3,pos=-1,},},reward = {{type=2,code=1,amount=50000,},},tips = "飞扬阵速度可加30%",tips1 = "[img]ui://Training/7[/img]<br>当没有场上的探员某些属性相对比较低的情况下，添加阵法可以让我方战队更易胜利。",tips2 = "例如：上图的探员速度没有boss速度快，添加飞扬阵能让我方的探员得到属性加成，从而有机率使我方的速度比敌方速度快。",photo = "",herocard = {}
	},
	[8] = {
		id = 8,title = "阵容教学",task = "了解每个探员的定位，合理搭配阵容，做到最强输出",formation = {24001,35008,45008,},position = {2,},fixedhero = {{heroId=35010,pos=1,},{heroId=45011,pos=5,},{heroId=45003,pos=6,},{heroId=15003,pos=3,},{heroId=45007,pos=4,},},answer = {{heroId=35008,fightData="TrainingRanks1",pos=2,},{heroId=24001,fightData="TrainingRanks2",pos=2,},{heroId=45008,fightData="TrainingRanks3",pos=2,},},enemy = {{heroId=60001,pos=2,star=8,},},ModuleId = "",WindowId = {},correct = {{id=35008,pos=2,},},reward = {{type=2,code=1,amount=50000,},},tips = "对抗狼鲨需要有一个坦克",tips1 = "每个探员的属性会有不同，荆楚和聂隐专门瞄准敌方血量最低单位，快速把敌方的后排输出干掉，荆楚还可以搭配躲闪特性，获得闪避后的伤害加成，最后搭配嫦娥高回血以及大后期伤害爆表的占卜师。",tips2 = "[color=#d83a3c]特别提示：搭配虎男的抗伤加眩晕效果会更佳。[/color]",photo = "",herocard = {{heroId=35010,effectName="降低怒气",},{heroId=45011,effectName="法攻光环",},{heroId=45003,effectName="残血收割",},{heroId=15003,effectName="群疗群驱",},{heroId=45007,effectName="追杀残血",},}
	},
}