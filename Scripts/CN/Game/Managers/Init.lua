

--缓存管理
Cache = require "Game.Managers.Cache"
--文件缓存管理器
FileCacheManager = require "Game.Managers.FileCacheManager"
--数据缓存管理
ModelManager = require "Game.Managers.ModelManager"

--spine管理
SpineMnange = require "Game.Managers.SpineMnange"
SkillManager= require "Game.Modules.Battle.Effect.SkillManager"
BattleManager= require "Game.Modules.Battle.BattleManager"
FsmMachine= require "Game.Modules.Battle.Fsm.FsmMachine"
FightManager=require "Game.Modules.Battle.MuitiBattle.FightManager"


--对象池管理
PoolManager=require "Game.Managers.PoolManager"
--冒泡对话管理器
-- BubbleManager = require  "Game.Managers.BubbleManager"
-- --推送消息管理器
PushNotificationManager = require  "Game.Managers.PushNotificationManager"