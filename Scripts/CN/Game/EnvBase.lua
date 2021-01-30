
--全局变量
Desc = require "Configs.Desc"
require "Configs.DescAuto"
require "Game.GlobalVars.Version"
require "Game.GlobalVars.VersionChange"
require "Game.GlobalVars.Control"

require "Game.Types.PHPType"

require "Game.GlobalFuncs.Debug"
require "Game.GlobalFuncs.LeakDetection"

require "Game.Utils.Collections.Stack"
require "Game.Utils.Collections.Queue"

require "Game.Common.Class"
require "Configs.ConfigEvn"
Scheduler = require "Game.Common.Scheduler"
require "Game.Common.SFightAttr"

TableUtil  =  require "Game.Utils.TableUtil"
GlobalUtil = require "Game.Utils.GlobalUtil"
FileUtil = require "Game.Utils.FileUtil"
HttpUtil = require "Game.Utils.HttpUtil"
RPUtil = require "Game.Utils.RPUtil"
PHPUtil = require "Game.Utils.PHPUtil"
SDKUtil = require "Game.Utils.SDKUtil"

UIDUtil = require "Game.Utils.UIDUtil"
EventType = require "Game.Types.EventType"
DeviceUtil = require "Game.Utils.DeviceUtil"

AgentConfiger = require "Game.ConfigReaders.AgentConfiger"
AgentResConfiger = require "Game.ConfigReaders.AgentResConfiger"

--流程管理
FlowManager = require "Game.Managers.FlowManager"
--公用二次提示框
Alert = require "Game.Managers.Alert"
RollTips = require "Game.Managers.RollTips"

ResManager = require "Game.Managers.ResManager"
RedManager = require "Game.Managers.RedManager"
BindManager = require "Game.Managers.BindManager"
ModuleId = require "Game.Consts.ModuleId"
ModuleUtil = require "Game.Utils.ModuleUtil"
require "Game.Managers.ResUpdateManager"
SoundManager = require "Game.Managers.SoundManager"
FunCheckManager = require "Game.Managers.FunCheckManager"
require "Game.Shaders.Init"
require "Game.FMVC.Init"
require "Game.UI.Init"
print(1, "---------Base environment inited.-----------")