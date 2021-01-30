
-- 一个玩法有多个阵容类型的时候要将每个阵容类型添加到下表

return {
	-- 高阶竞技场 攻击阵容 
	[1000]={
		GameDef.BattleArrayType.HigherPvpAckOne,
		GameDef.BattleArrayType.HigherPvpAckThree,
		GameDef.BattleArrayType.HigherPvpAckSix,
		},
	[1001]={
		GameDef.BattleArrayType.HigherPvpAckOne,
		GameDef.BattleArrayType.HigherPvpAckThree,
		GameDef.BattleArrayType.HigherPvpAckSix,
		},
	[1002]={
		GameDef.BattleArrayType.HigherPvpAckOne,
		GameDef.BattleArrayType.HigherPvpAckThree,
		GameDef.BattleArrayType.HigherPvpAckSix,
		},
	-- 高阶竞技场防守阵容 
	[2000]={
		GameDef.BattleArrayType.HigherPvpDefOne,
		GameDef.BattleArrayType.HigherPvpDefThree,
		GameDef.BattleArrayType.HigherPvpDefSix,
	},
	[2001]={
		GameDef.BattleArrayType.HigherPvpDefOne,
		GameDef.BattleArrayType.HigherPvpDefThree,
		GameDef.BattleArrayType.HigherPvpDefSix,
	},
	[2002]={
		GameDef.BattleArrayType.HigherPvpDefOne,
		GameDef.BattleArrayType.HigherPvpDefThree,
		GameDef.BattleArrayType.HigherPvpDefSix,
	},

	-- 公会传奇赛
	[2011]={
		GameDef.BattleArrayType.GuildLeagueOne,
		GameDef.BattleArrayType.GuildLeagueTwo,
		GameDef.BattleArrayType.GuildLeagueThree,
	},
	[2012]={
		GameDef.BattleArrayType.GuildLeagueOne,
		GameDef.BattleArrayType.GuildLeagueTwo,
		GameDef.BattleArrayType.GuildLeagueThree,
	},
	[2013]={
		GameDef.BattleArrayType.GuildLeagueOne,
		GameDef.BattleArrayType.GuildLeagueTwo,
		GameDef.BattleArrayType.GuildLeagueThree,
	},

	-- 天境赛世界擂台赛 防守阵容
	[3001]={
		GameDef.BattleArrayType.WorldSkyPvpDefOne,
		GameDef.BattleArrayType.WorldSkyPvpDefThree,
		GameDef.BattleArrayType.WorldSkyPvpDefSix,
	},
	[3002]={
		GameDef.BattleArrayType.WorldSkyPvpDefOne,
		GameDef.BattleArrayType.WorldSkyPvpDefThree,
		GameDef.BattleArrayType.WorldSkyPvpDefSix,
	},
	[3003]={
		GameDef.BattleArrayType.WorldSkyPvpDefOne,
		GameDef.BattleArrayType.WorldSkyPvpDefThree,
		GameDef.BattleArrayType.WorldSkyPvpDefSix,
	},
	--天域赛PVP 攻击阵容
	[3011]={
		GameDef.BattleArrayType.HorizonPvpAckOne,
		GameDef.BattleArrayType.HorizonPvpAckThree,
		GameDef.BattleArrayType.HorizonPvpAckSix,
	},
	[3012]={
		GameDef.BattleArrayType.HorizonPvpAckOne,
		GameDef.BattleArrayType.HorizonPvpAckThree,
		GameDef.BattleArrayType.HorizonPvpAckSix,
	},
	[3013]={
		GameDef.BattleArrayType.HorizonPvpAckOne,
		GameDef.BattleArrayType.HorizonPvpAckThree,
		GameDef.BattleArrayType.HorizonPvpAckSix,
	},
	--天域赛PVP 防守阵容
	[3014]={
		GameDef.BattleArrayType.HorizonPvpDefOne,
		GameDef.BattleArrayType.HorizonPvpDefThree,
		GameDef.BattleArrayType.HorizonPvpDefSix,
	},
	[3015]={
		GameDef.BattleArrayType.HorizonPvpDefOne,
		GameDef.BattleArrayType.HorizonPvpDefThree,
		GameDef.BattleArrayType.HorizonPvpDefSix,
	},
	[3016]={
		GameDef.BattleArrayType.HorizonPvpDefOne,
		GameDef.BattleArrayType.HorizonPvpDefThree,
		GameDef.BattleArrayType.HorizonPvpDefSix,
	},

	--跨服竞技场 攻击阵容
	[3031]={
		GameDef.BattleArrayType.CrossArenaAckOne,
		GameDef.BattleArrayType.CrossArenaAckTwo,
		GameDef.BattleArrayType.CrossArenaAckThree,
	},
	[3032]={
		GameDef.BattleArrayType.CrossArenaAckOne,
		GameDef.BattleArrayType.CrossArenaAckTwo,
		GameDef.BattleArrayType.CrossArenaAckThree,
	},
	[3033]={
		GameDef.BattleArrayType.CrossArenaAckOne,
		GameDef.BattleArrayType.CrossArenaAckTwo,
		GameDef.BattleArrayType.CrossArenaAckThree,
	},
	--跨服竞技场 防守阵容
	[3034]={
		GameDef.BattleArrayType.CrossArenaAckOne,
		GameDef.BattleArrayType.CrossArenaAckTwo,
		GameDef.BattleArrayType.CrossArenaAckThree,
	},
	[3035]={
		GameDef.BattleArrayType.CrossArenaAckOne,
		GameDef.BattleArrayType.CrossArenaAckTwo,
		GameDef.BattleArrayType.CrossArenaAckThree,
	},
	[3036]={
		GameDef.BattleArrayType.CrossArenaAckOne,
		GameDef.BattleArrayType.CrossArenaAckTwo,
		GameDef.BattleArrayType.CrossArenaAckThree,
	},

	--跨服超凡段位赛 攻击阵容
	[3041]={
		GameDef.BattleArrayType.CrossSuperMundaneAckFirst,
		GameDef.BattleArrayType.CrossSuperMundaneAckTwo,
	},
	[3042]={
		GameDef.BattleArrayType.CrossSuperMundaneAckFirst,
		GameDef.BattleArrayType.CrossSuperMundaneAckTwo,
	},
	--跨服超凡段位赛 防守阵容
	[3043]={
		GameDef.BattleArrayType.CrossSuperMundaneDefFirst,
		GameDef.BattleArrayType.CrossSuperMundaneDefTwo,
	},
	[3044]={
		GameDef.BattleArrayType.CrossSuperMundaneDefFirst,
		GameDef.BattleArrayType.CrossSuperMundaneDefTwo,
	},

	-- 巅峰竞技 攻击阵容
	[4006]={
		GameDef.BattleArrayType.TopArenaAckOne,
		GameDef.BattleArrayType.TopArenaAckTwo,
		GameDef.BattleArrayType.TopArenaAckThree,
	},
	[4007]={
		GameDef.BattleArrayType.TopArenaAckOne,
		GameDef.BattleArrayType.TopArenaAckTwo,
		GameDef.BattleArrayType.TopArenaAckThree,
	},
	[4008]={
		GameDef.BattleArrayType.TopArenaAckOne,
		GameDef.BattleArrayType.TopArenaAckTwo,
		GameDef.BattleArrayType.TopArenaAckThree,
	},
}
