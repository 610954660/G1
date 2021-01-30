local BoundaryMapView = class("BoundaryMapView",Window)

function BoundaryMapView:ctor()
 	self._packName 	= "BoundaryMap"
 	self._compName 	= "BoundaryMapView"
	self._rootDepth = LayerDepth.Window
	self.__reloadPacket = true
	self.__relationView = {"FightInfoView","BlessingBagView","BlessingSelectViews","BossInfoView","ClearanceView","CustomsRecordView","SceneRewardView","SceneTpView","SkillPreviewView","BattlePrepareView"}
	self.showData = false
	self.showReward = false
	self.buffBtnList = {}
	self.nodeMonsterList = {}
	self.skeletonNode = false
	self.bossSkeletonNode = false
	self.bossNode = false
	self.layer = 1
	self.difficulty = 1
	self.timer = false
end
function BoundaryMapView:refrush(state)
	local function call()
		self.disTouchLayer:setVisible(false)
		self.layer = BoundaryMapModel:getCurLayer()
		self.difficulty = BoundaryMapModel:getPowerDifficult() -- 关卡强度
		self:initSeverTimeHander()
		self:initNodeOther()
		self:initMonsterBuff()
		self:initMonsterNode()
		self:boss_refush()
	end
	if state then return call() end
	self.disTouchLayer:setVisible(true)
	self.spine:setVisible(true)
	self.spine:setAnimation(0, "animation", false)
	self.spine:stopAllActions()
	local arr = {}
	table.insert(arr,cc.DelayTime:create(0.5))
	table.insert(arr,cc.CallFunc:create(function()
		call()
	end))
	self.spine:runAction(cc.Sequence:create(arr))
end
function BoundaryMapView:refresh_BoundaryData()
	self:refrush()
end
function BoundaryMapView:initSeverTimeHander()
	BoundaryMapModel:setCurBestToScene()
end
function BoundaryMapView:_initUI()
	RedManager.updateValue("V_Boundary",false)
	self.bg = self.view:getChildAutoType("bg")
	self.bg:setIcon(PathConfiger.getBg("BoundaryMap.jpg"))

	self.heroItem = self.view:getChildAutoType("heroItem")

	self.t_BoundaryNode = BoundaryMapModel:getBoundaryNode()
	self.t_BoundaryPos = BoundaryMapModel:getBoundaryPos()

--	self.closeBtn = self.view:getChildAutoType("closeBtn")
	self.disTouchLayer = self.view:getChildAutoType("disTouchLayer")
	self.btn_shop = self.view:getChildAutoType("btn_shop")
	self.btn_shop:addClickListener(function()
		ModuleUtil.openModule(ModuleId.Shop.id,true,{shopType = 15})
	end)
	self.btn_bag = self.view:getChildAutoType("btn_bag")
	self.btn_bag:addClickListener(function()
		ViewManager.open("BlessingBagView")
	end)
	self.btn_rank = self.view:getChildAutoType("btn_rank")
	self.btn_rank:addClickListener(function()
		ViewManager.open("BoundaryRankView",{layer = self.layer,difficulty = self.difficulty})
	end)
	
	self.spine = SpineUtil.createSpineObj(self.view:getChildAutoType("spine"),{x=0,y=0}, "animation", "Effect/UI", "Ef_guochangyun", "Ef_guochangyun",false) 
	self.spine:setVisible(false)

	self.btn_reward = self.view:getChildAutoType("btn_reward")
	self.btn_reward:addClickListener(function()
		ViewManager.open("SceneRewardView",{layer = self.layer,difficulty = self.difficulty})
	end)
	self.btn_tp = self.view:getChildAutoType("btn_tp")
	self.btn_tp:addClickListener(function()
		ViewManager.open("SceneTpView",{layer = self.layer,difficulty = self.difficulty})
	end)

	self.buffList = self.view:getChildAutoType("buffList")
	self.buffList:setItemRenderer(handler(self,self.buffHandle))

	self.bg = self.view:getChildAutoType("bg")
	self.bg:addClickListener(function()
		self.tipPanel:setVisible(false)
	end)
	self.diff_str = self.view:getChildAutoType("diff_str")
	self.curScene_str = self.view:getChildAutoType("curScene_str")

	self.heroScene = self.view:getChildAutoType("heroScene")
	self.heroScene:addEventListener(FUIEventType.TouchBegin,function()
		self.tipPanel:setVisible(false)
	end)
	self.starList = self.heroScene:getChildAutoType("starList")
	self.starList:setItemRenderer(handler(self,self.starListObjHandle))


	self.btn_left = self.view:getChildAutoType("btn_left")
	self.btn_left:addClickListener(function()
		if self.layer == 0 then return end
		BoundaryMapModel:setCurLayer(self.layer - 1)
	end)

	self.btn_right = self.view:getChildAutoType("btn_right")
	self.btn_right:addClickListener(function()
		local mark = BoundaryMapModel:getBossStrongByLayer(self.layer)
		if mark >= 0 then
			BoundaryMapModel:setCurLayer(self.layer + 1)
		end
	end)
	self.tpBtn = self.heroScene:getChildAutoType("bossTp")
	local spine =  SpineUtil.createSpineObj(self.tpBtn, vertex2(75,75), "animation", "Spine/ui/BoundaryMap", "efx_chuansongmen", "efx_chuansongmen",true)

	self.tipPanel = self.view:getChildAutoType("tipPanel")
	local t_skill = DynamicConfigData.t_skill
	for key,value in pairs(BoundaryMapModel:getMonsterBuff()) do
		if self.view:getChildAutoType("titleTip"..key) then
			local skill = t_skill[value]
			self.view:getChildAutoType("titleTip"..key):setText(skill.skillName)
			self.view:getChildAutoType("content"..key):setText(skill.showName)
		end
	end

	self.time_str = self.view:getChildAutoType("time_str")
	local lastTime = TimeLib.nextMonthBeginTime() - ServerTimeModel:getServerTime()
	local typ = "d"
	local descTyp = Desc.common_TimeDesc
	if lastTime < 60 * 60 * 24 then
		typ = "h"
		descTyp =  Desc.common_TimeDesc2
	end
	self.time_str:setText(StringUtil.formatTime(lastTime,typ,descTyp))

	self.timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.update),1, false)

	self.btn_help = self.view:getChildAutoType("btn_help1")
	self.btn_help:addClickListener(function()
		local info = {}
	    info['title'] = Desc.help_StrTitle149
	    info['desc'] = Desc.help_StrDesc149
	    ViewManager.open("GetPublicHelpView",info) 
	end)
	self.heroObject = self.heroScene:getChildAutoType("heroObject")
	self.heroObject:setSortingOrder(5)
	local heroId = ModelManager.HandbookModel.heroOpertion --改用看板娘
	local fashionId = ModelManager.HandbookModel.fashionCode --改用看板娘
	if self.skeletonNode then
		self.skeletonNode:removeFromParent()
	end
	local skeletonNode = SpineMnange.createSprineById(heroId, true,nil,nil,fashionId)
	if skeletonNode then
		skeletonNode:setAnimation(0,"stand",true)
		self.heroObject:displayObject():addChild(skeletonNode)
		self.skeletonNode = skeletonNode
		self.skeletonNode:setPosition(cc.p(30,0))
		self.skeletonNode:setScale(0.8)
	end

	self.tpBtn:addClickListener(function()
		if self.layer == BoundaryMapModel:getCurBestToScene() then
			local severDay = tonumber(os.date("%d",ServerTimeModel:getServerTime()))
			RollTips.show(BoundaryMapModel:getBoundaryNode()[self.layer + 1].openDay - severDay..Desc.Boundary_desc5)
			return
		end
		BoundaryMapModel:setCurLayer(self.layer + 1)
	end)

	self.bossNode = self.heroScene:getChildAutoType("spineLoad")
	self.bossNode:addClickListener(function()
		ViewManager.open("BossInfoView",{layer = self.layer,difficulty = self.difficulty})
	end)
	RPCReq.Boundary_GetDifficultPower({},function(data)
		BoundaryMapModel:setPowerDifficult(data.power)
		self:refrush(true)
	end)
	RedManager.register("V_Boundary_Reward",self.btn_reward:getChild("img_red"))
end
function BoundaryMapView:praise_moon_refresh()
	local info = {
		text = Desc.Boundary_desc10,
		type="ok",
		onOk= function()
			for key,value in pairs(self.__relationView) do
				ViewManager.close(value)
			end
			self:closeView()
		end,
	}
	Alert.show(info)
end
function BoundaryMapView:update()
	local lastTime = TimeLib.nextMonthBeginTime() - ServerTimeModel:getServerTime()
	if lastTime <= 0 then 
		lastTime = 0 
	end
	local typ = "d"
	local descTyp = Desc.common_TimeDesc
	if lastTime < 60 * 60 * 24 then
		typ = "h"
		descTyp =  Desc.common_TimeDesc2
	end
	self.time_str:setText(StringUtil.formatTime(lastTime,typ,descTyp))
end
function BoundaryMapView:getBuff_action(_,object,pos)
	object:setScale(1,1)
	object:setPosition(pos.x,pos.y)
	object:removeClickListener()
	local toPos = cc.p(self.btn_bag:displayObject():getPosition())
	local arr = {}
	table.insert(arr,cc.MoveTo:create(0.7,toPos))
	table.insert(arr,cc.ScaleTo:create(0.7,0))
	local arr1 = {}
	table.insert(arr1,cc.EaseSineIn:create(cc.Spawn:create(arr)))
	table.insert(arr1,cc.CallFunc:create(function()
		object:removeFromParent()
	end))
	object:displayObject():runAction(cc.Sequence:create(arr1))
	self.view:addChild(object)
end
function BoundaryMapView:starListObjHandle(index, obj)
	obj:getController("state"):setSelectedIndex(self.starList._dataTemplate[index + 1])
end
function BoundaryMapView:boss_refush()
	local curDif = BoundaryMapModel:getBossDifficultById(self.layer)
	self.tpBtn:setVisible(curDif and curDif.mark >= 0 and self.layer <= BoundaryMapModel:getCurBestToScene() and self.layer ~= table.nums(self.t_BoundaryNode))
	local curDif = BoundaryMapModel:getBossDifficultById(self.layer)
	if curDif and curDif.mark >= 1 then
		local list = {0,0,0,0,0,0}
		for i = 1,curDif.mark do
			list[i] = 1
		end
		self.starList:setData(list)
		self.starList:setVisible(true)
	else
		self.starList:setVisible(false)
	end
	local mark = BoundaryMapModel:getBossStrongByLayer(self.layer)
	self.btn_right:setVisible(mark >= 0 and self.layer < BoundaryMapModel:getCurBestToScene() and self.layer ~= table.nums(self.t_BoundaryNode))
	self.btn_left:setVisible(self.layer ~= 1)
end
function BoundaryMapView:initNodeOther()
	self.curScene_str:setText(self.layer .."/" .. table.nums(self.t_BoundaryNode))
	self.diff_str:setText(string.format(Desc.Boundary_desc3,self.difficulty))
end
local _initX = 15
local _initY = 0
function BoundaryMapView:initMonsterNode()
	self.nodeMonsterList = {}
	for i = 1,4 do
		self.nodeMonsterList[i] = {}
		for key,pos in pairs(self.t_BoundaryPos[self.layer]["nodePosList"..i]) do
			local obj = self.heroScene:getChildAutoType("item"..i .. key)
			local icon = obj:getChild("icon")
			icon:displayObject():stopAllActions()
			icon:displayObject():setPosition(_initX,_initY)
			self.heroScene:addChild(obj)
			if icon.initUrl == nil then
				icon.initUrl = icon:getURL()
			end
			icon:setURL("ui://pfacbfr8c16b4f")
			icon:setVisible(true)

			obj:setSortingOrder(4 - key)
			obj:setVisible(true)
			obj:addClickListener(function()
				ViewManager.open("FightInfoView",{roud = i,index = key,layer = self.layer,difficulty = self.difficulty})
			end,99)
			obj:setGrayed(true)
			table.insert(self.nodeMonsterList[i],obj)
			obj:setTouchable(false)
			if tolua.isnull(obj.spine) then
				obj.spine =  SpineUtil.createSpineObj(obj:getChild("spine"), vertex2(30,0), "shuijing_lan_loop", "Spine/ui/BoundaryMap", "efx_shuijing", "efx_shuijing",true)
			end
			obj.spine:setVisible(false)
		end
	end
	if not tolua.isnull(self.bossSkeletonNode) then
		self.bossSkeletonNode:removeFromParent()
	end
	local skeletonNode = SpineMnange.createSprineById(self.t_BoundaryNode[self.layer].bossid,false)
	if skeletonNode then
		self.bossSkeletonNode = skeletonNode
		skeletonNode:setAnimation(0,"stand",true)
		self.bossNode:displayObject():addChild(skeletonNode)
		self.bossSkeletonNode:setPosition(cc.p(50,10))
	end
	self:nodeMonster_refrush()
end
local _roudColor = {
	"shuijing_lan_loop",
	"shuijing_zi_loop",
	"shuijing_hong_loop",
	"shuijing_lu_loop",
}
function BoundaryMapView:nodeMonster_refrush(_,roud)
	for key,value in pairs(BoundaryMapModel:getRouteNode()) do
		for i = 1,value.pos + 1 do
			local roudInfo = self.nodeMonsterList[value.id]
			local obj = roudInfo and roudInfo[i] or false
			if obj then
				local icon = obj:getChild("icon")
				icon:setVisible(i == value.pos + 1)
				icon:displayObject():setPosition(_initX,_initY)
				icon:displayObject():stopAllActions()
				obj.spine:setVisible(i == value.pos + 1)
				obj:setTouchable(i == value.pos + 1)
				if i == value.pos + 1 then
					obj:setGrayed(false)
					obj:setTouchable(true)
					local arr = {}
					table.insert(arr,cc.MoveTo:create(1,cc.p(_initX,_initY + 20)))
					table.insert(arr,cc.MoveTo:create(1,cc.p(_initX,_initY)))
					icon:displayObject():runAction(cc.RepeatForever:create(cc.Sequence:create(arr)))
					icon:setURL(icon.initUrl)
					obj.spine:setVisible(true)
					obj.spine:setAnimation(0,_roudColor[key],true)
				end
			end
		end
	end
	if not tolua.isnull(self.skeletonNode) then
		if roud then
			local pos = BoundaryMapModel:getRouteNode()[roud].pos
			if pos ~= 0 then
				BoundaryMapModel:setLastHeroPos(roud,pos)
			end
			self.skeletonNode:stopAllActions()
			local arr = {}
			table.insert(arr,cc.FadeOut:create(0.35))
			table.insert(arr,cc.CallFunc:create(function()
				self.skeletonNode:retain()
				self.skeletonNode:removeFromParent()
				
				self.nodeMonsterList[roud][pos]:getChild("spine1"):displayObject():addChild(self.skeletonNode,99)
				self.skeletonNode:runAction(cc.FadeIn:create(0.35))
			end))
			self.skeletonNode:runAction(cc.Sequence:create(arr))
		else
			local lastRoute = BoundaryMapModel:getLastHeroPos()
			if lastRoute then
				self.skeletonNode:retain()
				self.skeletonNode:removeFromParent()
				local Gobj = self.nodeMonsterList[lastRoute.roud][lastRoute.pos]
				Gobj:getChild("spine1"):displayObject():addChild(self.skeletonNode,99)
				Gobj:getChild("icon"):setVisible(false)
				Gobj.spine:setVisible(false)
				Gobj:setTouchable(false)
			else
				self.skeletonNode:retain()
				self.skeletonNode:removeFromParent()
				self.heroObject:displayObject():addChild(self.skeletonNode,99)
			end
		end
	end
end
function BoundaryMapView:buffHandle(index,obj)
	local t_skill = DynamicConfigData.t_skill
	local skill = t_skill[self.buffList._dataTemplate[index + 1]]
	obj:setText(skill.skillName)
	obj:addClickListener(function()
		self.tipPanel:setVisible(not self.tipPanel:isVisible())
	end,99)
	table.insert(self.buffBtnList,obj)
	local skillCellObj = obj:getChild("skillCell")
	local skillCell = BindManager.bindSkillCell(skillCellObj)
	skillCell:setData(skill.skillId)
end
function BoundaryMapView:initMonsterBuff()
	self.buffBtnList = {}
	self.buffList:setData(BoundaryMapModel:getMonsterBuff())
end
function BoundaryMapView:_exit()
	if self.timer then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer)
		self.timer = false
	end
	if not tolua.isnull(self.skeletonNode) then
		self.skeletonNode:removeFromParent()
	end
end
return BoundaryMapView