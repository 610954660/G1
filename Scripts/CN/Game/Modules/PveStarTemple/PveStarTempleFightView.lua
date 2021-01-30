--Name : PveStarTempleFightView.lua
--Author : generated by FairyGUI
--Date : 2020-7-30
--Desc : 

local PveStarTempleFightView,Super = class("PveStarTempleFightView", Window)
local BattleConfiger = require "Game.ConfigReaders.BattleConfiger"

function PveStarTempleFightView:ctor()
	--LuaLog("PveStarTempleFightView ctor")
	self._packName = "PveStarTemple"
	self._compName = "PveStarTempleFightView"
	self._rootDepth = LayerDepth.PopWindow
	self.areaID = self._args.areaID
end

function PveStarTempleFightView:_initEvent( )
	
end

function PveStarTempleFightView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:PveStarTemple.PveStarTempleFightView
		--{vmFieldsEnd}:PveStarTemple.PveStarTempleFightView
	--Do not modify above code-------------
end

function PveStarTempleFightView:_initUI( )
	self:_initVM()
	self.currSelectHeroIndex = false
	self.mySeat = BindManager.bindSeatItem(self.view:getChildAutoType("mySeat"))
	self.bossSeat = BindManager.bindSeatItem(self.view:getChildAutoType("bossSeat"))
	self.txtMyCapacity = self.view:getChildAutoType("txtMyCapacity")
	self.txtBossCapacity = self.view:getChildAutoType("txtBossCapacity")
	self.btnSkipFight = self.view:getChildAutoType("btnSkipFight")
	self.btnStart = self.view:getChildAutoType("btnStart")
	self.selectHeroList = self.view:getChildAutoType("selectHeroList")

	self.selectHeroList:setItemRenderer(function(index,obj)
		self:selectHeroListRenderer(index,obj)
	end)

	self.btnSkipFight:addClickListener(function()
		self:onBtnSkipFight()
	end)

	self.btnStart:addClickListener(function()
		self:onBtnStartClick()
	end)

	self.view:getChildAutoType("n32"):setURL(PathConfiger.getBg("bg_Expedition.jpg"))
	self:updateHeroList()
	self:updateCurrHero()
	self:updateCurrBoss()
	self:updateSkipFight()
end

function PveStarTempleFightView:_exit()
	self.areaID = false
end

function PveStarTempleFightView:updateHeroList()
	self.selectHeroData = {}
	for k,v in pairs(ModelManager.PveStarTempleModel:getHeroList(true)) do
		table.insert(self.selectHeroData,v)
	end
	table.sort(self.selectHeroData,function (a,b)
		return a.combat > b.combat
	end)

	if not self.currSelectHeroIndex then
		
		local lastIndex=PveStarTempleModel:getSelectHeroIndex()
		print(086,lastIndex,"lastIndex")
		local heroInfo=self.selectHeroData[lastIndex]
		if heroInfo and heroInfo.hp>0 then
			self.currSelectHeroIndex=lastIndex
		else
			for i,v in ipairs(self.selectHeroData) do
				if v.hp > 0 then
					self.currSelectHeroIndex = i
					break
				end
			end
		end

	end

	self.selectHeroList:setNumItems(#self.selectHeroData)
end

function PveStarTempleFightView:updateCurrHero()
	if not self.currSelectHeroIndex then
		--self.mySeat:exit()
		self.mySeat.view:setVisible(false)
		self.txtMyCapacity:setText("")
		return
	end

	local heroData = self.selectHeroData[self.currSelectHeroIndex]
	self.mySeat.view:setVisible(true)
	local fashionId = heroData.fashion
	self.mySeat:initItemCell(heroData.code,heroData.star,heroData.level,1,fashionId,heroData.uniqueWeaponLevel)
	self.txtMyCapacity:setText(StringUtil.transValue(heroData.combat))
	self.mySeat.controller:setSelectedPage("out")
end

function PveStarTempleFightView:updateCurrBoss()
	local layer = ModelManager.PveStarTempleModel:getLayer()
	local fightID = DynamicConfigData.t_PveStarTemplePartConfig[layer][self.areaID].monster
	local fightData = DynamicConfigData.t_fight[fightID]
	local data = ModelManager.PveStarTempleModel:getBossData(fightID,fightData.monsterStand[1],self.areaID)

	if not data then
		self.bossSeat:exit()
		self.bossSeat.view:setVisible(false)
		return
	end

	self.bossSeat.view:setVisible(true)
	self.bossSeat:initItemCell(data.code,data.star,data.level,2,data.fashionId, data.uniqueWeaponLevel)
	self.txtBossCapacity:setText(StringUtil.transValue(data.combat))
	self.bossSeat.controller:setSelectedPage("out")
end

function PveStarTempleFightView:updateSkipFight()
	local roundNumber = ModelManager.PveStarTempleModel:getRoundNumber()
	local battleFlag = ModelManager.PveStarTempleModel:getBattleFlag()
	local layer = ModelManager.PveStarTempleModel:getLayer()
	local skipLevel = DynamicConfigData.t_PveStarTempleRoundConfig[roundNumber].skipLevel
	self.btnSkipFight:setVisible(layer >= skipLevel)
	self.btnSkipFight:setSelected(battleFlag)
end

function PveStarTempleFightView:selectHeroListRenderer(index,obj)
	local isSelect = self.currSelectHeroIndex == index + 1
	obj:addEventListener(FUIEventType.Click,function (context)
		self:onHeroClick(index + 1)
	end,1)
	obj:getController("state"):setSelectedPage(isSelect and "on" or "out")

	local heroCell = BindManager.bindHeroCell(obj)
	heroCell:setData(self.selectHeroData[index+1])
end

function PveStarTempleFightView:onHeroClick(index)
	if self.selectHeroData[index].hp <= 0 then
		RollTips.show("阵亡英雄无法上阵")
		return
	end

	if self.currSelectHeroIndex ~= index then
		self.currSelectHeroIndex = index
		self:updateCurrHero()
		self:updateHeroList()
		PveStarTempleModel:setSelectHeroIndex(self.currSelectHeroIndex)
		ViewManager.call("PveStarTempleMainView", "updateHeroList")
	end
end

function PveStarTempleFightView:onBtnSkipFight()
	local isSelected = self.btnSkipFight:isSelected()
	ModelManager.PveStarTempleModel:setBattleFlag(isSelected)
	Dispatcher.dispatchEvent(EventType.PveStarTemple_SetBttleFlag,isSelected)
end

function PveStarTempleFightView:onBtnStartClick()
	if not self.currSelectHeroIndex then
		RollTips.show("需先选择上阵探员")
		return
	end

	local heroData = self.selectHeroData[self.currSelectHeroIndex]
	local layer = ModelManager.PveStarTempleModel:getLayer()
	local fightID = DynamicConfigData.t_PveStarTemplePartConfig[layer][self.areaID].monster

	Dispatcher.dispatchEvent(EventType.PveStarTemple_Battle,{heroData = heroData,areaID = self.areaID,fightID = fightID})
	--self:closeView()
end


return PveStarTempleFightView