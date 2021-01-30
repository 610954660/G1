--Date :2021-01-13
--Author : generated by FairyGUI
--Desc : 排行榜

local CrossLaddersChampRankView,Super = class("CrossLaddersChampRankView", Window)

function CrossLaddersChampRankView:ctor()
	--LuaLog("CrossLaddersChampRankView ctor")
	self._packName = "CrossLaddersChamp"
	self._compName = "CrossLaddersChampRankView"
	self._rootDepth = LayerDepth.PopWindow
	
	self.rankData 	= {}
	self.myRankData = {}
end

function CrossLaddersChampRankView:_initEvent( )
	
end

function CrossLaddersChampRankView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossLaddersChamp.CrossLaddersChampRankView
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.isHaveCtrl = viewNode:getController('isHaveCtrl')--Controller
	self.list_rank = viewNode:getChildAutoType('list_rank')--GList
	self.myRankItem = viewNode:getChildAutoType('myRankItem')--rankItem
		self.myRankItem.bgMask = viewNode:getChildAutoType('myRankItem/bgMask')--GLoader
		self.myRankItem.btn_like = viewNode:getChildAutoType('myRankItem/btn_like')--btn_like
			self.myRankItem.btn_like.img_red = viewNode:getChildAutoType('myRankItem/btn_like/img_red')--GImage
		self.myRankItem.heroCell = viewNode:getChildAutoType('myRankItem/heroCell')--GButton
		self.myRankItem.rankIconLoader = viewNode:getChildAutoType('myRankItem/rankIconLoader')--GLoader
		self.myRankItem.txt_integral = viewNode:getChildAutoType('myRankItem/txt_integral')--GTextField
		self.myRankItem.txt_myRankTitle = viewNode:getChildAutoType('myRankItem/txt_myRankTitle')--GTextField
		self.myRankItem.txt_name = viewNode:getChildAutoType('myRankItem/txt_name')--GTextField
		self.myRankItem.txt_noRank = viewNode:getChildAutoType('myRankItem/txt_noRank')--GTextField
		self.myRankItem.txt_power = viewNode:getChildAutoType('myRankItem/txt_power')--GTextField
		self.myRankItem.txt_rank = viewNode:getChildAutoType('myRankItem/txt_rank')--GTextField
	self.txt_integralTitle = viewNode:getChildAutoType('txt_integralTitle')--GTextField
	self.txt_likeTitle = viewNode:getChildAutoType('txt_likeTitle')--GTextField
	self.txt_rankInfoTitle = viewNode:getChildAutoType('txt_rankInfoTitle')--GTextField
	self.txt_rankTitle = viewNode:getChildAutoType('txt_rankTitle')--GTextField
	--{autoFieldsEnd}:CrossLaddersChamp.CrossLaddersChampRankView
	--Do not modify above code-------------
end

function CrossLaddersChampRankView:_initListener( )
 self:CrossLaddersChampRankView_refreshPanel()
end

function CrossLaddersChampRankView:CrossLaddersChampRankView_refreshPanel()
	self.list_rank:setVirtual()
	self.list_rank:setItemRenderer(function(index, obj)
		index 	= index + 1
		local data 	= self.rankData[index]
		local rankCtrl 	= obj:getController("rankCtrl")
		local haveRankCtrl 	= obj:getController("haveRankCtrl") 	-- 0没排名 1有排名
		local isMe 	= obj:getController("isMe") 	-- 0不是自己 1是自己
		local txt_rank 	= obj:getChildAutoType("txt_rank")
		local heroCell 	= BindManager.bindPlayerCell(obj:getChildAutoType("heroCell"))
		local txt_name 	= obj:getChildAutoType("txt_name")
		local txt_power 	= obj:getChildAutoType("txt_power")
		local txt_noRank 	= obj:getChildAutoType("txt_noRank")
		local rankIconLoader 	= obj:getChildAutoType("rankIconLoader")
		local txt_integral 	= obj:getChildAutoType("txt_integral")
		local btn_like 	= obj:getChildAutoType("btn_like")
		
		rankCtrl:setSelectedIndex(index < 4 and index or 4)
		haveRankCtrl:setSelectedIndex(1)
		isMe:setSelectedIndex(0)
		txt_rank:setText(index)
		heroCell:setHead(data.head, data.level, data.id,nil,data.headBorder)
		txt_power:setText(string.format(Desc.CrossLaddersChamp_str9,StringUtil.transValue(data.combat or 0)))
		txt_name:setText(data.name)
		txt_integral:setText(data.value or 0)

		if CrossLaddersChampModel:checkIsLike(data.id) then
			btn_like:getController("button"):setSelectedIndex(1)
		else
			btn_like:getController("button"):setSelectedIndex(0)
		end

		btn_like:getChildAutoType("img_red"):setVisible(CrossLaddersChampModel:checkCanLike() and (not CrossLaddersChampModel:checkIsLike(data.id)))
		btn_like:getChildAutoType("title"):setText(data.exParam.param1 or 0)
		btn_like:removeClickListener(11)
		btn_like:addClickListener(function()  
			local SkyLadChampionConst = DynamicConfigData.t_SkyLadChampionConst[1]
			local limit 	= SkyLadChampionConst.limit
			if CrossLaddersChampModel:checkIsLike(data.id) then
				RollTips.show(Desc.CrossLaddersChamp_str35)
				return
			end

			if CrossLaddersChampModel.likeTimes >= limit then
				btn_like:getController("button"):setSelectedIndex(0)
				RollTips.show(Desc.CrossLaddersChamp_str33)
				return
			end
			CrossLaddersChampModel:reqSkyLadChampion_Like(data.id,data.serverId,function(totalLike)  
				btn_like:getChildAutoType("title"):setText(totalLike or 0)
			end)
		end,11)

		obj:getChildAutoType("heroCell"):removeClickListener(11)
		obj:getChildAutoType("heroCell"):addClickListener(function(context)
			context:stopPropagation()--阻止事件冒泡
			ViewManager.open("ViewPlayerView",{playerId = data.id,serverId = data.serverId,arrayType = GameDef.BattleArrayType.SkyLadderDef })
		end,11)

	end)

	local reqInfo = {
        rankType = GameDef.RankType.SkyLadChampion,
    }
	RPCReq.Rank_GetRankData(reqInfo,function(params)
		printTable(8849,">>>>排行榜数据>>Rank_GetRankData>>>",params)
        self.rankData = params.rankData or {}
        self.myRankData = params.myRankData or {}
        if tolua.isnull(self.view) then return end
		self.list_rank:setData(self.rankData)  
		self.isHaveCtrl:setSelectedIndex(TableUtil.GetTableLen(self.rankData) > 0 and 1 or 0)
        local inRank = false
        local myRank = false
        local myId = tonumber(ModelManager.PlayerModel.userid)
        for k,v in pairs(self.rankData) do
            if myId == v.id then
                inRank = true
                myRank = k
                break
            end
		end
		self:setMyRankInfo(inRank)
    end)
end

function CrossLaddersChampRankView:setMyRankInfo(inRank)
		local data 	= self.myRankData
		local obj 	= self.myRankItem
		local rankCtrl 	= obj:getController("rankCtrl")
		local haveRankCtrl 	= obj:getController("haveRankCtrl") 	-- 0没排名 1有排名
		local isMe 	= obj:getController("isMe") 	-- 0不是自己 1是自己
		local txt_rank 	= obj:getChildAutoType("txt_rank")
		local heroCell 	= BindManager.bindPlayerCell(obj:getChildAutoType("heroCell"))
		local txt_name 	= obj:getChildAutoType("txt_name")
		local txt_power 	= obj:getChildAutoType("txt_power")
		local txt_noRank 	= obj:getChildAutoType("txt_noRank")
		local rankIconLoader 	= obj:getChildAutoType("rankIconLoader")
		local txt_integral 	= obj:getChildAutoType("txt_integral")
		local btn_like 	= obj:getChildAutoType("btn_like")
		-- if data.rank then
		-- 	rankCtrl:setSelectedIndex(4)
		-- end
		rankCtrl:setSelectedIndex(4)
		haveRankCtrl:setSelectedIndex(data.rank and 1 or 0)
		isMe:setSelectedIndex(1)
		txt_rank:setText(data.rank or "")
		heroCell:setHead(data.head or PlayerModel.head, data.level or PlayerModel.level, data.id or tonumber(PlayerModel.userid),nil,data.headBorder or PlayerModel.headBorder)
		txt_power:setText(string.format(Desc.CrossLaddersChamp_str9,StringUtil.transValue(data.combat or (ModelManager.CardLibModel:getFightVal() or 0))))
		txt_name:setText(data.name or PlayerModel.username)
		txt_integral:setText(data.value or 0)

		if CrossLaddersChampModel:checkIsLike(data.id or tonumber(PlayerModel.userid)) then
			btn_like:getController("button"):setSelectedIndex(1)
		else
			btn_like:getController("button"):setSelectedIndex(0)
		end
		btn_like:getChildAutoType("img_red"):setVisible(CrossLaddersChampModel:checkCanLike() and (not CrossLaddersChampModel:checkIsLike(data.id or tonumber(PlayerModel.userid))))
		btn_like:removeClickListener(11)
		btn_like:getChildAutoType("title"):setText((data.exParam and data.exParam.param1)  and data.exParam.param1 or 0)
		btn_like:addClickListener(function()  
			local SkyLadChampionConst = DynamicConfigData.t_SkyLadChampionConst[1]
			local limit 	= SkyLadChampionConst.limit
			if CrossLaddersChampModel:checkIsLike(data.id or tonumber(PlayerModel.userid)) then
				RollTips.show(Desc.CrossLaddersChamp_str35)
				return
			end

			if CrossLaddersChampModel.likeTimes >= limit then
				btn_like:getController("button"):setSelectedIndex(0)
				RollTips.show(Desc.CrossLaddersChamp_str33)
				return
			end

			CrossLaddersChampModel:reqSkyLadChampion_Like(data.id or tonumber(PlayerModel.userid),data.serverId or LoginModel:getUnitServerId(),function(totalLike)  
				btn_like:getChildAutoType("title"):setText(totalLike or 0)
			end)
		end,11)

		obj:getChildAutoType("heroCell"):removeClickListener(11)
		obj:getChildAutoType("heroCell"):addClickListener(function(context)
			context:stopPropagation()--阻止事件冒泡
			ViewManager.open("ViewPlayerView",{playerId = data.id or tonumber(PlayerModel.userid),serverId = data.serverId or LoginModel:getUnitServerId() ,arrayType = GameDef.BattleArrayType.SkyLadderDef })
		end,11)
end


function CrossLaddersChampRankView:_initUI( )
	self:_initVM()
	self:_initListener()

end




return CrossLaddersChampRankView