--准备主游戏部分环境

--主游戏部分启用严格检查
if not __IS_RELEASE__ then
	require "Strict"
end

require "Dex.MVVM.VMBase"

require "Game.Utils.Init"

require "Game.Types.Init"
require "Game.ConfigReaders.Init"
require "Game.Managers.Init"
require "Game.FGuiConfig"


print(1, "---------Game environment inited.-----------")