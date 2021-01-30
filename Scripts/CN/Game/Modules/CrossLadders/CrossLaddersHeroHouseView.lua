--Date :2020-12-30
--Author : generated by FairyGUI
--Desc : 

local CrossLaddersHeroHouseView,Super = class("CrossLaddersHeroHouseView", Window)

function CrossLaddersHeroHouseView:ctor()
	--LuaLog("CrossLaddersHeroHouseView ctor")
	self._packName = "CrossLadders"
	self._compName = "CrossLaddersHeroHouseView"
	self._rootDepth = LayerDepth.PopWindow
	
end

function CrossLaddersHeroHouseView:_initEvent( )
	
end

function CrossLaddersHeroHouseView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossLadders.CrossLaddersHeroHouseView
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.itme_1 = viewNode:getChildAutoType('itme_1')--praiseItem
		self.itme_1.btn_praise = viewNode:getChildAutoType('itme_1/btn_praise')--btn_praise
			self.itme_1.btn_praise.img_red = viewNode:getChildAutoType('itme_1/btn_praise/img_red')--GImage
		self.itme_1.click = viewNode:getChildAutoType('itme_1/click')--GGraph
		self.itme_1.modelNode = viewNode:getChildAutoType('itme_1/modelNode')--GComponent
		self.itme_1.txt_guildName = viewNode:getChildAutoType('itme_1/txt_guildName')--GTextField
		self.itme_1.txt_playerName = viewNode:getChildAutoType('itme_1/txt_playerName')--GTextField
	self.itme_2 = viewNode:getChildAutoType('itme_2')--praiseItem
		self.itme_2.btn_praise = viewNode:getChildAutoType('itme_2/btn_praise')--btn_praise
			self.itme_2.btn_praise.img_red = viewNode:getChildAutoType('itme_2/btn_praise/img_red')--GImage
		self.itme_2.click = viewNode:getChildAutoType('itme_2/click')--GGraph
		self.itme_2.modelNode = viewNode:getChildAutoType('itme_2/modelNode')--GComponent
		self.itme_2.txt_guildName = viewNode:getChildAutoType('itme_2/txt_guildName')--GTextField
		self.itme_2.txt_playerName = viewNode:getChildAutoType('itme_2/txt_playerName')--GTextField
	self.itme_3 = viewNode:getChildAutoType('itme_3')--praiseItem
		self.itme_3.btn_praise = viewNode:getChildAutoType('itme_3/btn_praise')--btn_praise
			self.itme_3.btn_praise.img_red = viewNode:getChildAutoType('itme_3/btn_praise/img_red')--GImage
		self.itme_3.click = viewNode:getChildAutoType('itme_3/click')--GGraph
		self.itme_3.modelNode = viewNode:getChildAutoType('itme_3/modelNode')--GComponent
		self.itme_3.txt_guildName = viewNode:getChildAutoType('itme_3/txt_guildName')--GTextField
		self.itme_3.txt_playerName = viewNode:getChildAutoType('itme_3/txt_playerName')--GTextField
	self.txt_tips = viewNode:getChildAutoType('txt_tips')--GTextField
	--{autoFieldsEnd}:CrossLadders.CrossLaddersHeroHouseView
	--Do not modify above code-------------
end

function CrossLaddersHeroHouseView:_initListener( )
	
end

function CrossLaddersHeroHouseView:_initUI( )
	self:_initVM()
	self:_initListener()
	self:CrossLaddersHeroHouseView_refreshPanel()
	CrossLaddersModel:reqSkyLadder_GetHeroHouse()
end

function CrossLaddersHeroHouseView:CrossLaddersHeroHouseView_refreshPanel()
	self:refreshPanel()
end

function CrossLaddersHeroHouseView:refreshPanel()
	local myId = tonumber(PlayerModel.userid)
	local heroHouseInfo = CrossLaddersModel.heroHouseInfo or {}
	local likeInfo = CrossLaddersModel.likeInfo or {}
	for i=1,3 do
		local data = heroHouseInfo[i]
		local obj = self.view:getChildAutoType("itme_"..i)
		local modelNode = obj:getChildAutoType("modelNode")
		local txt_playerName = obj:getChildAutoType("txt_playerName")
		local txt_guildName = obj:getChildAutoType("txt_guildName")
		local btn_praise = obj:getChildAutoType("btn_praise")
		local title = btn_praise:getChildAutoType("title")
		local haveData = obj:getController("haveData")
		local click = obj:getChildAutoType("click")

		if modelNode then
			modelNode:displayObject():removeAllChildren()
		end
		local skeletonNode =false
		haveData:setSelectedIndex(1)
		if data then
			haveData:setSelectedIndex(0)
			txt_playerName:setText(string.format(Desc.CrossLadders_str5,data.serverId,data.name))
			if data.guildName ~= "" then
				txt_guildName:setText(data.guildName)
			else
				txt_guildName:setText(Desc.CrossLadders_str24)
			end
			if data.heroOpertion == 0 then
				data.heroOpertion = 35001
			end
			skeletonNode = SpineUtil.createModel(modelNode, {x = 0, y =0}, "stand", data.heroOpertion or 35001,true)
			title:setText(data.totalLike or 0)
		end

		
		if likeInfo[i] and likeInfo[i].like then
			btn_praise:getChildAutoType("img_red"):setVisible(false)
			btn_praise:getController("button"):setSelectedIndex(1)
		else
			btn_praise:getChildAutoType("img_red"):setVisible(true)
			btn_praise:getController("button"):setSelectedIndex(0)
		end
		btn_praise:removeClickListener(11)
		btn_praise:addClickListener(function() 
			local isLike = (likeInfo[i] and likeInfo[i].like) and likeInfo[i].like or false
			if isLike then
				RollTips.show(Desc.CrossLadders_str6)
				return
			end
			CrossLaddersModel:reqSkyLadder_Like(i,data.playerId)
		end,11)


		click:removeClickListener(11)
		click:addClickListener(function()  
			if data.id == myId then
				RollTips.show(Desc.CrossLadders_str4)
				return
			end
			ViewManager.open("ViewPlayerView",{playerId = data.playerId or myId,serverId = data.serverId,arrayType =  GameDef.BattleArrayType.SkyLadderDef})
		end,11)
	end
end




return CrossLaddersHeroHouseView