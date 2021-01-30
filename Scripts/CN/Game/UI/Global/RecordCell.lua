--added by ljj
--道具框封裝
local RecordCell = class("RecordCell")
local HeroPos=ModelManager.BattleModel.HeroPos
local HeroConfiger = require "Game.ConfigReaders.HeroConfiger"
local BattleConfiger=require "Game.ConfigReaders.BattleConfiger"
local SeatType=ModelManager.BattleModel.SeatType
function RecordCell:ctor(view)
	self.view = view
	self.view:addEventListener(FUIEventType.Exit,function(context) self:__onExit()  end);
	--Dispatcher:addEventListener(EventType.Battle_BattleRecordData,self);
	self.battleData=false
	self.data=false
end


function RecordCell:init( ... )
	self.playerLaout=self.view:getChildAutoType("playerLaout")
	self.enemyLaout=self.view:getChildAutoType("enemyLaout")
	self.replayBtn=self.view:getChildAutoType("replayBtn")
	
	self.roundNum=self.view:getChildAutoType("roundNum")
	self.times=self.view:getChildAutoType("times")
	self.recordName=self.view:getChildAutoType("recordName")
	self.recordMenu=self.view:getChildAutoType("recordMenu")
	self.pvpBg=self.view:getChildAutoType("pvpBg")
	self.pvpFame=self.view:getChildAutoType("pvpFame")
	self.playInfoCell=self.view:getChildAutoType("playInfoCell")
	self.enemyInfoCell=self.view:getChildAutoType("enemyInfoCell")
	self.pvpThreeList=self.view:getChildAutoType("pvpThreeList")
	self.recordFame=self.view:getChildAutoType("recordFame")
	self.winType=self.view:getChildAutoType("winType")
	self.worldFightTitle=self.view:getChildAutoType("worldFightTitle")
	
	self:_initEvent()
end


function RecordCell:_initEvent()

	if self.replayBtn then
		self.replayBtn:addClickListener(function ()
				if self.battleData then
					Dispatcher.dispatchEvent(EventType.Battle_replayRecord,{isRecord=true,battleData=self.battleData})
				end
		end)
	end

end


function RecordCell:setData(data,gamePlayType,fromBattleRecordType)
	self.pvpBg:setURL(string.format("UI/Chat/%s.jpg", "pvpBg"))
	self.pvpFame:setURL(string.format("UI/Chat/%s.jpg", "pvpFrame2"))
	if not data  then	
	   return 
	end
	self.data=data
	self.data.gamePlayType=gamePlayType
	self.data.fromBattleRecordType=fromBattleRecordType
	
	if gamePlayType ==GameDef.GamePlayType.Arena or gamePlayType ==GameDef.GamePlayType.WorldArena then
		if data then
			if data.fightMs then
				self.times:setText(TimeLib.msToString(data.fightMs,"%Y-%m-%d"))
			end
			local params={
				recordId =	data.recordId,
				gamePlayType	=gamePlayType,
			}
			local success=function()
				--printTable(5656,data,k)
				self:setLaoutData(data.recordId,ChatModel:getBattleData(gamePlayType,data.recordId))
				
			end
			if ChatModel:getBattleData(gamePlayType,data.recordId)==nil then
				 local serverId=math.tointeger(LoginModel:getLoginServerInfo().unit_server)
				 BattleModel:requestBattleRecord(data.recordId,success,gamePlayType,serverId,true)
			else
				print(5656,data.recordId,"录像已存在")
				success()
			end

		end
	end
	
	if gamePlayType ==GameDef.GamePlayType.HigherPvp or gamePlayType ==GameDef.GamePlayType.WorldSkyPvp then
		if data and data.recordIds then
			local responseCount=0
			for k, recordInfo in pairs(data.recordIds) do
				local params={
					recordId =	recordInfo.recordId,
					gamePlayType=gamePlayType,
				}
				local success=function()
					responseCount=responseCount+1
					if responseCount==3 then
						self:setPvpLaoutData(data.recordIds,gamePlayType)
					end
				end
				if ChatModel:getBattleData(gamePlayType,recordInfo.recordId)==nil then
					local serverId=data.serverId or math.tointeger(LoginModel:getLoginServerInfo().unit_server)
					BattleModel:requestBattleRecord(recordInfo.recordId,success,gamePlayType,data.serverId,true)
				else
					print(5656,data.recordId,"录像已存在")
					success()
				end
			end
		end
	end
	if self.data then
		self:setTitleData()
	end

end

--设置录像通用标题
function RecordCell:setTitleData()

	local attakerInfo=self.data.attacker
	local defenderInfo=self.data.defender
	if not attakerInfo then
		return 
	end
	
	local menuData={
		recordId=self.data.recordId,
		gamePlayType=self.data.gamePlayType,
		fromBattleRecordType=self.data.fromBattleRecordType,
		playName=self.data.playName or attakerInfo.name,
		enemyName=self.data.enemyName or defenderInfo.name,
		curLikes=self.data.curLikes,
		serverId=self.data.serverId,
		windowType=self.data.windowType
	}
	local recordMenuCell=BindManager.bindRecordMenu(self.recordMenu)
	recordMenuCell:setData(menuData)

	if attakerInfo  then
		self.winType:setVisible(true)
		if attakerInfo.isWin then
			self.view:getController("isWin"):setSelectedPage("true")
		else
			self.view:getController("isWin"):setSelectedPage("false")
		end
		self.playInfoCell:getChildAutoType("playerName"):setText(attakerInfo.name)
		self.playInfoCell:getChildAutoType("score"):setText(attakerInfo.score)
		self.playInfoCell:getChildAutoType("combat"):setText(StringUtil.transValue(attakerInfo.combat))
		local  aHeadCell= BindManager.bindPlayerCell(self.playInfoCell:getChildAutoType("playerCell"));
		aHeadCell:showRelation(false);
		aHeadCell:setHead(attakerInfo.head, attakerInfo.level, attakerInfo.playerId)
	end
	if defenderInfo then
		self.enemyInfoCell:getChildAutoType("enemyName"):setText(defenderInfo.name)
		self.enemyInfoCell:getChildAutoType("combat"):setText(StringUtil.transValue(defenderInfo.combat))
		self.enemyInfoCell:getChildAutoType("score"):setText(defenderInfo.score)
		local  dHeadCell= BindManager.bindPlayerCell(self.enemyInfoCell:getChildAutoType("playerCell"));
		dHeadCell:showRelation(false);
		dHeadCell:setHead(defenderInfo.head, defenderInfo.level, defenderInfo.playerId)
	end
	self.worldFightTitle:setVisible(false)
	self.enemyInfoCell:getController("pos"):setSelectedPage("normal")
	
	if self.data.gamePlayType==GameDef.GamePlayType.HigherPvp then
		self.playInfoCell:getChildAutoType("combat"):setText(0)--不需要显示战力
	end
	
	if self.data.gamePlayType==GameDef.GamePlayType.WorldArena then
		self.worldFightTitle:setVisible(true)
		self.playInfoCell:getController("show"):setSelectedPage("WorldArena")
		self.enemyInfoCell:getController("show"):setSelectedPage("WorldArena")
		self.enemyInfoCell:getController("pos"):setSelectedPage("right")
	end
	if self.data.gamePlayType==GameDef.GamePlayType.WorldSkyPvp then
		self.worldFightTitle:setVisible(true)
		self.playInfoCell:getController("show"):setSelectedPage("WorldSkyPvp")
		self.enemyInfoCell:getController("show"):setSelectedPage("WorldSkyPvp")
	end
end


--设置普通竞技场列表
function RecordCell:setLaoutData(recordId,battleData)
	
	self.battleData=battleData
	if not battleData  then
		return 
	end
	
	local groupInfo=battleData.groupInfo
	local playerDatas={}
	local enemyDatas={}
	local battleObjSeqs=battleData.battleObjSeq
	for i, battleObjSeq in pairs(battleObjSeqs) do
		if battleObjSeq.type~=3 and battleObjSeq.type~=4 then
			if battleObjSeq.id>BattleModel.HeroPos.enemy.pos then
				table.insert(enemyDatas,battleObjSeq)
			else
				table.insert(playerDatas,battleObjSeq)
			end
		end

	end
	local fightId=battleData.mapId
	if fightId==nil then
		fightId=1
	end
	for seatKey, seatIndexs in pairs(SeatType) do
		if seatKey=="front" or  seatKey=="replace"  then
			for k, ranges in ipairs(seatIndexs) do
				for seatId = ranges[1], ranges[2] do
					--print(5656,seatKey,seatId)
					local enemyChild=self.enemyLaout:getChildAutoType(tostring(seatId))
					local playerChild=self.playerLaout:getChildAutoType(tostring(seatId))
					local heroCell = BindManager.bindHeroCell(enemyChild)
					local heroCell2 = BindManager.bindHeroCell(playerChild)
					heroCell:setEmptyData()
					heroCell2:setEmptyData()
	         	end
			end
		end
	end
	
	
	local mapConfig=BattleConfiger.getMapByID(fightId)
	self.roundNum:setText(#battleData.roundDataSeq.."/"..mapConfig.maxRound)
	for i, playerData in ipairs(playerDatas) do
		local objKey= tonumber(playerData.id)%100
		local child=self.playerLaout:getChildAutoType(tostring(objKey))
		--child:setVisible(true)
		--child:setScale(1,1)
		local data=	playerData
		local heroCell = BindManager.bindHeroCell(child)
		local heroInfo=HeroConfiger.getHeroInfoByID(data.code)
		if heroInfo  then
			data.category=heroInfo.category
			heroCell:setBaseData(data)
			if groupInfo then
				local params = {
					playerInfo = groupInfo[1],
					heroArray ={data.uuid}
				}
				child:addClickListener(function ()
						Dispatcher.dispatchEvent(EventType.HeroInfo_Show, params);
				end,101)
			end

		end

	end
	for i, playerData in ipairs(enemyDatas) do
		local objKey= tonumber(playerData.id)%100
		local child=self.enemyLaout:getChildAutoType(tostring(objKey))
		--child:setVisible(false)
		--child:setScale(1,1)
		local heroCell = BindManager.bindHeroCell(child)
		local monster=DynamicConfigData.t_monster[playerData.code]
		if monster then
			playerData.category=monster.category
			heroCell:setBaseData(playerData)
			if groupInfo then
				child:addClickListener(function ()
						if groupInfo[2] then
							local params = {
								playerInfo = groupInfo[2],
								heroArray ={playerData.uuid}
							}
							Dispatcher.dispatchEvent(EventType.HeroInfo_Show, params);
						else
							RollTips.show(Desc.battle_DataStr)
						end
				end,102)
			end
		end
	end
end



--设置天境赛列表
function RecordCell:setPvpLaoutData(recordIds,gamePlayType) 
	printTable(5656,"setPvpLaoutData",recordIds)
	self.recordFame:setURL(string.format("UI/Chat/%s.png", "recordBg"))
	self.pvpThreeList:setItemRenderer(function(index,obj)
		local recordId=	recordIds[index+1].recordId
		obj:getController("c1"):setSelectedIndex(index);
        self:upGroupItem(recordIds[index+1],obj,gamePlayType)		
			
	end)
	self.pvpThreeList:setNumItems(3)
end


--设置天境赛列表
function RecordCell: upGroupItem(recordInfo,obj,gamePlayType)
	local recordId=	recordInfo.recordId
	local fightData=ChatModel:getBattleData(gamePlayType,recordId)
	if not fightData then
		return 
	end
	local isWin = fightData.result;
	local data = fightData.battleObjSeq;
	local selfHeros = {};
	local otherHeros = {};
	for _, d in ipairs(data) do
		if (d.id < 200) then
			if (d.type == 1) then
				table.insert(selfHeros, d);
			end
		else
			if (d.type == 1 or d.type == 2) then
				table.insert(otherHeros, d);
			end
		end
	end
	local itemBg = obj:getChildAutoType("itemBg");
	itemBg:setURL(string.format("UI/Chat/%s.png", "pvpItemBg"))
	local selfObj = obj:getChildAutoType("self");
	local otherObj = obj:getChildAutoType("other");
	selfObj:getController("c1"):setSelectedIndex(isWin and 0 or 1);
	otherObj:getController("c1"):setSelectedIndex(isWin and 1 or 0);
	selfObj.list = selfObj:getChildAutoType("list_hero");
	otherObj.list = otherObj:getChildAutoType("list_hero");
	
	
	
	

	local combat = recordInfo.combat
	local defCombat =recordInfo.defCombat
	

	selfObj:getChildAutoType("txt_power"):setText(StringUtil.transValue(combat));
	otherObj:getChildAutoType("txt_power"):setText(StringUtil.transValue(defCombat));

	selfObj.list:setItemRenderer(function (idx1, obj1)
			local hd = selfHeros[idx1 + 1];
			local conf = DynamicConfigData.t_hero[hd.code]
			if (conf) then
				hd.category = conf.category
				local heroCell = BindManager.bindHeroCell(obj1);
				heroCell:setBaseData(hd);
			else
				printTable(2233, "============= 错误数据", hd, selfHeros);
			end
			local isAlive = hd.finalHp > 0;
			obj1:getController("grayCtrl"):setSelectedIndex(isAlive and 0 or 1);
		end)
	selfObj.list:setNumItems(#selfHeros);

	otherObj.list:setItemRenderer(function (idx2, obj2)
			local hd = otherHeros[idx2 + 1];
			local conf = hd.type == 1 and DynamicConfigData.t_hero[hd.code] or DynamicConfigData.t_monster[hd.code]
			if (conf) then
				hd.category = conf.category;
				local heroCell = BindManager.bindHeroCell(obj2);
				heroCell:setBaseData(hd);
			end
			local isAlive = hd.finalHp > 0;
			if (isAlive) then
				printTable(2233, hd);
			end
			obj2:getController("grayCtrl"):setSelectedIndex(isAlive and 0 or 1);
		end)
	otherObj.list:setNumItems(#otherHeros);

	local btn = obj:getChildAutoType("btn_details");
	local replayBtn = obj:getChildAutoType("replayBtn");
	btn:removeClickListener(22);
	btn:addClickListener(function ()
			ViewManager.open("BattledataView",{isWin=fightData.result,isRecord=true,battleData=fightData});
	end, 22)
	replayBtn:removeClickListener(23);
	replayBtn:addClickListener(function ()
			Dispatcher.dispatchEvent(EventType.Battle_replayRecord,{isRecord=true,battleData=fightData})
	end, 23)
end




--退出操作 在close执行之前
function RecordCell:__onExit()
	print(1,"HeroCell __onExit")
end

return RecordCell