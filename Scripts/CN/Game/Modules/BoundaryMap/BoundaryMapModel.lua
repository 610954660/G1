local BoundaryMapModel = class("BoundaryMapModel",BaseModel)

function BoundaryMapModel:ctor()
	self.t_BoundaryNode = DynamicConfigData.t_BoundaryNode
	self.t_BoundaryPos = DynamicConfigData.t_BoundaryPos
	self.t_BoundaryReward = DynamicConfigData.t_BoundaryReward
	self.t_BoundaryBless = DynamicConfigData.t_BoundaryBless
	self.t_BoundaryConst = DynamicConfigData.t_BoundaryConst[1]
	self:ctorData()
end
function BoundaryMapModel:setLastHeroPos(roud,pos)
	self.lastHeroPos[self.layer] = {roud = roud,pos = pos}
end
function BoundaryMapModel:getLastHeroPos()
	return self.lastHeroPos[self.layer]
end
function BoundaryMapModel:setBlessing(blessing)
	self.blessing = blessing
end
function BoundaryMapModel:getBlessing()
	return self.blessing
end
function BoundaryMapModel:getBoundaryNode()
	return self.t_BoundaryNode
end
function BoundaryMapModel:getBoundaryPos()
	return self.t_BoundaryPos
end
function BoundaryMapModel:getBoundaryReward()
	return self.t_BoundaryReward
end
function BoundaryMapModel:getBoundaryBless()
	return self.t_BoundaryBless
end
function BoundaryMapModel:ctorData()
	self.lastHeroPos = {}
	self.severData = {}
	self.curSceneData = {}
	self.layer = 1
	self.monsterBuff = {}
	self.bossBuff = {}
	self.powerDifficult = 1
	self.bossDifficult = {}
	self.route = {}
	self.blessing = {}
	self.bestToScene = 1
	self.initServerState = false
end
function BoundaryMapModel:setServerData(data)
	self:ctorData()
	self.initServerState = true
	self.severData = data
	self.layer = self.severData.layer == 0 and 1 or self.severData.layer
	self.powerDifficult = self.severData.powerDifficult or 1
	self.bossDifficult = {}
	self.route = {}
	self.lastHeroPos = {}
	self.curSceneData = {}
	self.route = {}
	self.blessing = {}
	self.bestToScene = 1
	self:initData()
	if self.severData.bossDifficult then
		for key,curLayerDiff in pairs(self.severData.bossDifficult) do
			self.bossDifficult[curLayerDiff.layerId].mark = curLayerDiff.mark or -1
			self.bossDifficult[curLayerDiff.layerId].value = curLayerDiff.value or 0
			self.bossDifficult[curLayerDiff.layerId].bossSkill = curLayerDiff.bossSkill or {}
		end
	end
	if self.severData.route then
		for key,scene in pairs(self.severData.route) do
			self.route[key].blessingBuff = scene.blessingBuff or {}
			if scene.index and scene.index ~= 0 then
				local lsPos = 1
				if scene.node[scene.index] then
					lsPos = scene.node[scene.index].pos
				end
				self.lastHeroPos[scene.layerId] = {roud = scene.index,pos = lsPos}
			end
			if scene.node then
				for k,node in pairs(scene.node) do
					self.route[key].node[k] = node
				end
			end
		end
	end
	Dispatcher.dispatchEvent("praise_moon_refresh")
	self:setCurBestToScene()

	local bestScene =  self:getBestMarkScene()
	if (bestScene < self.bestToScene) or (bestScene == self.bestToScene and self:getBossStrongByLayer(bestScene) == -1) then
		RedManager.updateValue("V_Boundary", true)
	end
	--local isShow = FileCacheManager.getBoolForKey("V_Boundary_Reward"..PlayerModel.userid..self.powerDifficult,true)
	--RedManager.updateValue("V_Boundary_Reward", isShow)
	--if not isShow then
	--	FileCacheManager.setBoolForKey("V_Boundary_Reward"..PlayerModel.userid..self.powerDifficult,true)
	--end
end
function BoundaryMapModel:initData()
	for layer = 1,#self.t_BoundaryNode do
		if self.bossDifficult[layer] == nil then
			self.bossDifficult[layer] = {
				layerId = layer,
				mark = -1,--已经通过的强度-1代表未打过
				value = 0,--星级
				bossSkill = {}--boss选择技能
			}
		end
		if self.route[layer] == nil then
			self.route[layer] = {
				layerId = layer,
				node = {{id = 1,pos = 0},{id = 2,pos = 0},{id = 3,pos = 0},{id = 4,pos = 0}},
				blessingBuff = {}
			}
		end
	end
end
function BoundaryMapModel:setCurLayer(layer)
	if layer < 1 then return end
	if layer > self.bestToScene then return end
	self.layer = layer
	Dispatcher.dispatchEvent("refresh_BoundaryData")
end
function BoundaryMapModel:getCurLayer()
	return self.layer
end
function BoundaryMapModel:getPowerDifficult()
	return self.powerDifficult
end
function BoundaryMapModel:setPowerDifficult(val)
	self.powerDifficult = val
end
function BoundaryMapModel:setBossDifficult(data,layer)
	self.bossDifficult[layer] = data
end
function BoundaryMapModel:getBossStrongData()
	local curData = self.bossDifficult[self.layer]
	return curData.value,curData.mark,curData.bossSkill
end
function BoundaryMapModel:getBossStrongByLayer(layer)
	if not self.bossDifficult[layer] then return -1 end
	return self.bossDifficult[layer].mark or -1
end
function BoundaryMapModel:setMonsterMark()
	local curData = self.bossDifficult[self.layer]
	if curData.mark < curData.value + #curData.bossSkill then
		curData.mark = curData.value + #curData.bossSkill
	end
end
function BoundaryMapModel:getAllBossDifficult()
	return self.bossDifficult
end
function BoundaryMapModel:getBossDifficultById(layer)
	return self.bossDifficult[layer]
end
function BoundaryMapModel:getBestMarkScene()--已经通过的最高层
	local index = 0 
	for key,value in pairs(self.bossDifficult) do
		if value.mark and value.mark >= 0 then
			index = key
		end
	end
	return index
end
function BoundaryMapModel:setMonsterBuff(buff)
	self.monsterBuff = buff
end
function BoundaryMapModel:setBossBuff(buff)
	self.bossBuff = buff
end

function BoundaryMapModel:getMonsterBuff()
	return self.monsterBuff
end
function BoundaryMapModel:getBossBuff()
	if not self.bossBuff[self.layer] then return {} end
	return self.bossBuff[self.layer].skill or {}
end
function BoundaryMapModel:getCurLayer()
	return self.layer
end
function BoundaryMapModel:runLayerTo(sceneIndex)
	self.layer = sceneIndex
end
function BoundaryMapModel:addRouteNodeBuff(id)
	table.insert(self.route[self.layer].blessingBuff,id)
end
function BoundaryMapModel:getRouteBuff()
	return self.route[self.layer].blessingBuff
end
function BoundaryMapModel:getAllRouteNode()--获取所有路线状态
	return self.route
end
function BoundaryMapModel:getRouteNodeByLayer(id)
	return self.route[id]
end
function BoundaryMapModel:getRouteNode()--获取路线状态
	return self.route[self.layer].node
end
function BoundaryMapModel:setRouteNodeSucces(roud)
	local route = self.route[self.layer]
	route.node[roud].pos = route.node[roud].pos + 1
end
function BoundaryMapModel:getRoadCareer(index)
	return self.t_BoundaryConst.roadCareer[index]
end
function BoundaryMapModel:setCurBestToScene()
	local best = 1
	local severDay = tonumber(os.date("%d",ServerTimeModel:getServerTime()))
	for key,value in ipairs(self.t_BoundaryNode) do
		if severDay >= value.openDay then
			best = key
		end
	end
	self.bestToScene = best
end
function BoundaryMapModel:getCurBestToScene()
	return self.bestToScene
end
function BoundaryMapModel:isInitSeverState()
	return self.initServerState
end

return BoundaryMapModel