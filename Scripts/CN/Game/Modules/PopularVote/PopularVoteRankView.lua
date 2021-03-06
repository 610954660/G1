--Date :2021-01-13
--Author : generated by FairyGUI
--Desc : 

local PopularVoteRankView,Super = class("PopularVoteRankView", Window)

function PopularVoteRankView:ctor()
	--LuaLog("PopularVoteRankView ctor")
	self._packName = "PopularVote"
	self._compName = "PopularVoteRankView"
	self._rootDepth = LayerDepth.PopWindow
	self.rankListData = {}
end

function PopularVoteRankView:_initEvent( )
	
end

function PopularVoteRankView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:PopularVote.PopularVoteRankView
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.rankHead = viewNode:getChildAutoType('rankHead')--rankHead
		self.rankHead.txt_attrName1 = viewNode:getChildAutoType('rankHead/txt_attrName1')--GTextField
		self.rankHead.txt_attrName2 = viewNode:getChildAutoType('rankHead/txt_attrName2')--GTextField
		self.rankHead.txt_attrName3 = viewNode:getChildAutoType('rankHead/txt_attrName3')--GTextField
		self.rankHead.txt_attrName4 = viewNode:getChildAutoType('rankHead/txt_attrName4')--GTextField
		self.rankHead.txt_rank = viewNode:getChildAutoType('rankHead/txt_rank')--GTextField
	self.rankList = viewNode:getChildAutoType('rankList')--GList
	--{autoFieldsEnd}:PopularVote.PopularVoteRankView
	--Do not modify above code-------------
end

function PopularVoteRankView:_initListener( )

end

function PopularVoteRankView:_initUI( )
	self:_initVM()
	local params = {}
	params.activityType = GameDef.ActivityType.HeroVote
	params.onSuccess = function(data)
		ModelManager.PopularVoteModel:setRankData(data or {})
		self.rankListData = ModelManager.PopularVoteModel:getHeroVotePopularHeroData()
		self:setRankList()
	end
	RPCReq.Activity_HeroVote_GetRankData(params,params.onSuccess)
end

function PopularVoteRankView:setRankList( )
	local popularHeroId = ModelManager.PopularVoteModel.popularHeroId
	local loveHeroId = ModelManager.PopularVoteModel.loveHeroId
	self.rankList:setItemRenderer(function (idx,obj)
		local index = idx + 1
        local data = self.rankListData[index]
        local info = DynamicConfigData.t_hero[data.heroCode]
        local showCtr = obj:getController("showCtr")
        local rankCtr = obj:getController("rankCtr")
        local txt_rank = obj:getChildAutoType("txt_rank")
        local heroIcon = obj:getChildAutoType("heroIcon/icon")
        heroIcon:setURL(PathConfiger.getHeroCard(data.heroCode))
        local txt_name = obj:getChildAutoType("txt_name")
        txt_name:setText(info.heroName)
        local txt_num = obj:getChildAutoType("txt_num")
		txt_num:setText(data.votesNum)
        if idx == 0 then 
        	rankCtr:setSelectedIndex(0)
        elseif idx == 1 then 
        	rankCtr:setSelectedIndex(1)
        elseif idx == 2 then
        	rankCtr:setSelectedIndex(2)
        else 
        	rankCtr:setSelectedIndex(3)
        	txt_rank:setText(index)
        end 
        if popularHeroId and popularHeroId == data.heroCode then 
        	showCtr:setSelectedIndex(1)
        elseif loveHeroId and loveHeroId == data.heroCode then 
        	showCtr:setSelectedIndex(2)
        else
        	showCtr:setSelectedIndex(0)
        end
	end)
	self.rankList:setData(self.rankListData)
end


return PopularVoteRankView