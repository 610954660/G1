--added by wyang 排行榜窗口
local RankView = require "Game.Modules.Rank.RankView"
local PataRankView,Super = class("PataRankView",RankView)
local RankConfiger = require "Game.ConfigReaders.RankConfiger" 
function PataRankView:ctor( data )
	self._packName = "Rank"
	self._compName = "PataRankView"
	self._rootDepth = LayerDepth.PopWindow
	--self._openType = GameDef.RankType.NormalTower
end

-------------------常用------------------------
--UI初始化
function PataRankView:_initUI( ... )
--	local info=self.args[1];
	local a = self.view
	Super._initUI(self, ... )
	
end



--这个方法给特殊排行榜继承后加需要特殊处理的内容
function PataRankView:updateItemSpec(obj, rank, info, isMine)

end



--事件初始化
function PataRankView:_initEvent( ... )
	--[[self.btn_apply:addClickListener(function ( ... )
	GuildModel.joinGuildReq(self.args[1].id)
	end)--]]
end

--initEvent后执行
function PataRankView:_enter( ... )
	print(1,"PataRankView _enter")
end


--页面退出时执行
function PataRankView:_exit( ... )

	print(1,"PataRankView _exit")
end

-------------------常用------------------------

return PataRankView