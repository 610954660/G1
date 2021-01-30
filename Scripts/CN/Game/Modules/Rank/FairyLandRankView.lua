-- added by wyz
-- 秘境排行榜

local RankView = require "Game.Modules.Rank.RankView"
local FairyLandRankView,Super = class("FairyLandRankView",RankView)
local RankConfiger = require "Game.ConfigReaders.RankConfiger" 


function FairyLandRankView:ctor(data)
	self._packName = "Rank"
	self._compName = "FairyLandRankView"
	self._rootDepth = LayerDepth.Window

end

function FairyLandRankView:_initUI( ... )
--	local info=self.args[1];
	local a = self.view
	Super._initUI(self, ... )
	
	if self.list_type then
		self.list_type:setItemRenderer(
			function(index, obj) 
				local info = self._groupData[index + 1]
				obj:setTitle(info.groupTab);
				obj:setIcon(PathConfiger.getFairyLandRankBtnIcon(info.rankType - 26));
				-- obj:getController("size"):setSelectedIndex(0)
				obj:removeClickListener(100)
				obj:addClickListener(
					function(...)
						self:updateRankData()
					end,100
				)
			end
		)
		self.list_type:setData(self._groupData)
		self.list_type:setSelectedIndex(self._currentIndex - 1)
	end
	
end

--这个方法给特殊排行榜继承后加需要特殊处理的内容
function FairyLandRankView:updateItemSpec(obj, rank, info, isMine)
	local img_bg = obj:getChild("img_bg")
	if not isMine then
		local path = PathConfiger.getEndLessRankBg(rank)
		img_bg:setURL(path)
	else
		img_bg:setURL(PathConfiger.getEndLessRankBg(0))
	end
end

--事件初始化
function FairyLandRankView:_initEvent( ... )

end

--initEvent后执行
function FairyLandRankView:_enter( ... )
	print(1,"FairyLandRankView _enter")
end


--页面退出时执行
function FairyLandRankView:_exit( ... )

	print(1,"FairyLandRankView _exit")
end

return FairyLandRankView