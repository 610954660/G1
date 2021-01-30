--Name : MonsterTipView.lua
--Author : generated by FairyGUI
--Date : 2020-4-11
--Desc : 魔王

local MonsterTipView,Super = class("MonsterTipView", Window)
local MazeConfiger  = require "Game.ConfigReaders.MazeConfiger"
local ItemCell = require "Game.UI.Global.ItemCell"
function MonsterTipView:ctor()
	--LuaLog("MonsterTipView ctor")
	self._packName = "Maze"
	self._compName = "MonsterTipView"
	self._rootDepth = LayerDepth.PopWindow
	--self._rootDepth = LayerDepth.Window
	self.data = {}
	self.showFlag = 1
	self.fightConfig = false
	self.monstersquad = self._args.config.monstersquad
end

function MonsterTipView:_initEvent( )
	--如果是三轮之后 数据多请求一层
	local data = MazeModel:getData(  )
	print(1,data.roundNumber)
	local squadVal = MazeConfiger.getSquadShow()
	if data.roundNumber>=squadVal-1 then
		--Maze_GetLayerGridMirror 协议数据为准
		local params = {}
		params.grid = self._args.config.id
		-- printTable(1,params)
		params.onSuccess = function (res )
		   	self.data = res.hero
		   	-- printTable(1,"服务器数据Maze_GetLayerGridMirror",self.data)
		   	if tolua.isnull(self.view) then return end
		   	if 	self.data and #self.data>0 then --有数据需要拿服务器数值
		   	  	self.showFlag = 3
		   	  	self.list:setData(self.data)
		   	else --没有数据 说明只需要预览
		   		self.data = {}
				local params = {}
				params.onSuccess = function (res )
					if tolua.isnull(self.view) then return end
				   	self.data = res.monster
				   	printTable(1,"Maze_GetLayerGridMirror",self.data)
				   	if 	self.data and #self.data>0 then --有数据需要拿服务器数值
				   	  	self.showFlag = 2
				   	  	self.list:setData(self.data)
				   	else --没有数据 说明只需要预览
				   		self.showFlag = 1
					    self.fightConfig = MazeConfiger.getFightConfig(self.monstersquad)
					    if (self.fightConfig) then
							self.list:setData(self.fightConfig)
					    end
				   	end
				end
				RPCReq.Maze_MonsterInfo(params, params.onSuccess)
		   	end
		end
		RPCReq.Maze_GetLayerGridMirror(params, params.onSuccess)

	else
		local params = {}
		params.onSuccess = function (res )
			if tolua.isnull(self.view) then return end
		   	self.data = res.monster
		   	printTable(1,"服务器数据Maze_MonsterInfo",self.data)
		   	if 	self.data and #self.data>0 then --有数据需要拿服务器数值
		   	  	self.showFlag = 2
		   	  	self.list:setData(self.data)
		   	else --没有数据 说明只需要预览
		   		self.showFlag = 1
			    self.fightConfig = MazeConfiger.getFightConfig(self.monstersquad)
			    if (self.fightConfig) then
					self.list:setData(self.fightConfig)
			    end
		   	end
		end
		RPCReq.Maze_MonsterInfo(params, params.onSuccess)
	end

end

function MonsterTipView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:Maze.MonsterTipView
		vmRoot.title = viewNode:getChildAutoType("$title")--text
		vmRoot.list = viewNode:getChildAutoType("$list")--list
		vmRoot.awardList = viewNode:getChildAutoType("$awardList")--list
		vmRoot.goBtn = viewNode:getChildAutoType("$goBtn")--Button
	--{vmFieldsEnd}:Maze.MonsterTipView
	--Do not modify above code-------------
end

function MonsterTipView:_initUI( )
	self:_initVM()
    self.awardList:setItemRenderer(function(index,obj)
    	local itemcell = BindManager.bindItemCell(obj)
        local itemData = ItemsUtil.createItemData({data = self.award[index+1]})
		itemcell:setItemData(itemData) 
    end)
    self.award = self._args.config.mazereward1
    self.awardList:setData(self.award)
    self.goBtn:setVisible(ModelManager.MazeModel:checkExsitNext(self._args.config.id))
    self.goBtn:addClickListener(function( ... )

		ViewManager.close("MonsterTipView")
		ModelManager.MazeModel:setFightFlag(true)
		Dispatcher.dispatchEvent(EventType.battle_requestFunc,function( eventName )
			   	if eventName == "begin" then
					local params = {}
					params.grid = self._args.config.id
					params.onSuccess = function (res )
					   if res.ret ==0 then
					   	   local params = {}
					   	   params.isWin = res.code
					   	   params.reward = res.reward
					   	   params.type = GameDef.GamePlayType.Maze
						   ModelManager.PlayerModel:set_awardData(params)
						   if not params.isWin then
							  Dispatcher.dispatchEvent(EventType.fight_lose_event,{fightID=self.monstersquad,configType=GameDef.BattleArrayType.Maze,index=self._args.config.id})
						   end 
					   end
					end
					RPCReq.Maze_Challenge(params, params.onSuccess)
				end
				if eventName=="end" then
				   ModelManager.MazeModel:setFightFlag(false)
                   Dispatcher.dispatchEvent(EventType.maze_check_open_getGodRes)
			    end 
		end,{fightID=self.monstersquad,configType=GameDef.BattleArrayType.Maze,index=self._args.config.id})--fightID 战斗场景 
    end)

    self.list:setItemRenderer(function( index,obj )
    	obj:getController("hadHPCtrl"):setSelectedIndex(1)
    	if self.showFlag == 2 then
    		local config = MazeConfiger.getMonsterConfig(self.data[index+1].code)
    		-- print(1,self.monstersquad,config.monsterId)
	        local monsterInfo = MazeConfiger.getFightInfo(self.monstersquad,config.monsterId)
	        -- printTable(1,monsterInfo)
			if monsterInfo then
				local showData = {}
				showData.code = self.data[index+1].code
				showData.level = monsterInfo.level
				showData.star = monsterInfo.star
				showData.maxHp = self.data[index+1].maxHp
				showData.hp = self.data[index+1].hp
				showData.category = config.category
				printTable(1,showData)
	            local heroCell = BindManager.bindHeroCell(obj)
	            heroCell:setData(showData)
			end
		elseif self.showFlag == 3 then --走的英雄体系
        	local config = MazeConfiger.getMonsterConfig(self.data[index+1].code)
			local showData = {}
			showData.code = self.data[index+1].code
			showData.level = self.data[index+1].level
			showData.star = self.data[index+1].star
			showData.maxHp = self.data[index+1].maxHp
			showData.hp = self.data[index+1].hp
			-- showData.combat = self.data[index+1].combat
			-- showData.mirror = self.data[index+1].mirror
			showData.category = config.category
            local heroCell = BindManager.bindHeroCell(obj)
            heroCell:setData(showData)
        elseif self.showFlag == 1 then --走的配置
        	local monsterConfig = MazeConfiger.getMonsterConfig(self.fightConfig[index+1].monsterId)
            local showData = {}
			showData.code = self.fightConfig[index+1].monsterId
			showData.level = self.fightConfig[index+1].level
			showData.star = self.fightConfig[index+1].star
			showData.maxHp = monsterConfig.hp
			showData.hp = monsterConfig.hp
			showData.category = monsterConfig.category
            local heroCell = BindManager.bindHeroCell(obj)
            heroCell:setData(showData)
        end
        
    end)
end




return MonsterTipView