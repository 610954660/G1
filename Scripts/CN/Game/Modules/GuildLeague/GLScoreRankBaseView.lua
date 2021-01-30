-- add by zn
-- description

local RankConfiger = require "Game.ConfigReaders.RankConfiger" 
local RankView = require "Game.Modules.Rank.RankView"
local GLScoreRankBaseView = class("GLScoreRankBaseView", RankView)

function GLScoreRankBaseView:ctor()
    self._openType = GameDef.RankType.GuildPvpMatchPlayer
end

function GLScoreRankBaseView:_initUI()
    self.list_type = FGUIUtil.getChild(self.view, "list_type", "GList")
	self.list_rank = FGUIUtil.getChild(self.view, "list_rank", "GList")
	
	self.c1 = self.view:getController("c1")
	self.myRankItem = self.view:getChildAutoType("myRankItem")
	self.txt_noData = self.view:getChildAutoType("txt_noData")
	self.rankHead = self.view:getChildAutoType("rankHead")
	self.closeBtn = self.view:getChildAutoType("closeBtn")
	
	if self.myRankItem then
		self.myRankItem:getController("c2"):setSelectedIndex(1)
	end
	
	
	self.list_rank:setVirtual()
	self.list_rank:setItemRenderer(
			function(index, obj) 
				local info = self._rankData[index + 1]
				--obj:setTitle(info.groupTab);
				local rank = info.rank or (index + 1)
				self:updateRankItem(obj, rank, info, false)
			end
		)		
	
	if self.closeBtn then
		self.closeBtn:addClickListener(function ( ... )
			self:closeView()
		end)
    end

    if (self.initBeforeReqData) then
        self:initBeforeReqData();
    end

    self:updateRankData()
end

function GLScoreRankBaseView:_refresh()
    self:updateRankData()
end

function GLScoreRankBaseView:onSuccess(res)
    self._rankData = {}
    if not res.rankData then
        self:updateRankInfo(self._openType)
        self.list_rank:setNumItems(#self._rankData)
        self.list_rank:scrollToView(0)
        self:updateRankEnd(self._openType)
        self.txt_noData:setVisible(true)
        if self.myRankItem then
            self.myRankItem:setVisible(#self._rankData ~= 0)
        end
        return
    end
    for _,v in ipairs(res.rankData) do
        table.insert(self._rankData, v)
    end
    if tolua.isnull(self.view) then return end
    if (self.txt_noData) then
        self.txt_noData:setVisible(#self._rankData == 0)
    end
    if self.myRankItem then
        self.myRankItem:setVisible(#self._rankData ~= 0)
    end
    
    --找出自己的排名数据，找不到的话就是没上榜
    local myInfo = res.myRankData
    self._myRank = myInfo and myInfo.rank or 0
    local myRank = 0;
    for k,v in pairs(self._rankData) do
        if(v.id == ModelManager.PlayerModel.userid) then
            myRank = v.rank or k
            self._myRank = myRank
            myInfo = v
            break
        end
    end
    if self.myRankItem then
        self:updateMyRankItem(self._myRank, myInfo, true)
    end
    self:updateRankInfo(self._openType)
    self.list_rank:setNumItems(#self._rankData)
    self.list_rank:scrollToView(0)
    self:updateRankEnd(self._openType)
end

return GLScoreRankBaseView