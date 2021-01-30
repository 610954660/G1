--add by wyang 
--Spine处理类
local SpineUtil = {}
local _pcFxList={}
--创建Spine对象
--parent 需要添加spine对象的fgui对象
--pos 添加到位置
--action 需要播放的动作
--path spine 路径
function SpineUtil.createSpineObj(parent, pos, action, path, skelName, atlasName,isloop,autoPos,tag)
	if  isloop==nil then
		isloop=true
	end
	local skeletonNode=SpineMnange.createByPath(path,skelName,atlasName)
	if skeletonNode==nil then
		print(4,"加载 spine  :"..skelName.." .skel    "..atlasName.." .atlas","出错")
		return  false,false
	end
	--local skillObj = FGUIUtil.createObjectFromURL(self.battlePackge,'GoWrap')
	if parent and not tolua.isnull(parent) then
		if parent.displayObject then
			if tag then
				parent:displayObject():addChild(skeletonNode,tag)
			else
				parent:displayObject():addChild(skeletonNode,10)
			end
			
		end
	end
	skeletonNode:setPosition(pos.x,pos.y)
	if action then	
		skeletonNode:setAnimation(0, action, isloop)
	end
    if autoPos and parent then		
		skeletonNode:setPosition(pos.x+parent:getWidth()/2,pos.y+parent:getHeight()/2)
	end
	--skeletonNode:setAnchorPoint({x=0.5,y=0.5})
	--skeletonNode:setPosition(pos.x,pos.y)
	--skillObj:setSortingOrder(layer)
	return  skeletonNode
end

--创建常驻粒子
function SpineUtil.residentSpine(path,skelName, atlasName,parent,pos,action,scale)
	local spineObj= false
	if _pcFxList[atlasName]==nil then
		local skeletonNode=SpineMnange.createByPath(path,skelName,atlasName)
		if skeletonNode==nil then
			print(0866,"加载 spine  :"..skelName.." .skel    "..atlasName.." .atlas","出错")
			return  false,false
		end
		local spineObj = fgui.GObject:create()
		spineObj:setTouchable(false)
		spineObj:setPivot(1,1)
		spineObj:displayObject():addChild(skeletonNode)
		spineObj:retain()
		spineObj.spine=skeletonNode
		if scale then
			spineObj:setScale(scale,scale)
		end
		_pcFxList[atlasName]=spineObj

	end
	parent:addChild(_pcFxList[atlasName])
	_pcFxList[atlasName]:setPosition(pos.x,pos.y)
	_pcFxList[atlasName]:setVisible(true)
	if action then
		_pcFxList[atlasName].spine:setAnimation(0, action, false)
	end
	return  _pcFxList[atlasName].spine
end



--创建模型
--parent 需要添加模型的fgui对象
--pos 添加到位置
--action 需要播放的动作
--heroID 英雄id，
--isHero true 英雄  false怪物
--elfSpine 精灵的spine名
function SpineUtil.createModel(parent, pos, action, heroID,isHero,elfSpine,fashionId)
	local skeletonNode=SpineMnange.createSprineById(heroID,isHero,false,elfSpine, fashionId)
	--local skillObj = FGUIUtil.createObjectFromURL(self.battlePackge,'GoWrap')
	parent:displayObject():addChild(skeletonNode)
	skeletonNode:setAnimation(0, action, true)
	skeletonNode:setPosition(pos.x,pos.y)
	--skillObj:setSortingOrder(layer)
	return  skeletonNode
	
end

--將節點插入到动画模型的插槽中
--skeletonNode 
--child 节点child
--slotName 插槽名字
function SpineUtil.addChildToSlot(skeletonNode,obj,slotName,localZOrder)
	if not skeletonNode then
		return
	end
	local ccNode = skeletonNode:getNodeForSlot(slotName)--找到插槽的挂点
	if ccNode then
		ccNode:setAnchorPoint({x=0.5,y=0.5})
		if type(localZOrder) =="number" and localZOrder>0 then
			ccNode:addChild(obj,localZOrder)
		else
			ccNode:addChild(obj,1)
		end
	end
	return  skeletonNode
end


--创建英雄立绘
function SpineUtil.createHeroDraw(parent, pos, heroID,staticFlag, fashionId)
	local path,name = PathConfiger.getHeroDraw(heroID, fashionId)
	return SpineUtil.createHeroDrawByName(parent,pos, path,name,name,staticFlag)
end

function SpineUtil.createHeroDrawByName(parent,pos, path,skelName, atlasName,staticFlag)
	if skelName then
		local skeletonNode=SpineMnange.createByPath(path,skelName,atlasName)
		if skeletonNode then
			if not staticFlag or type(staticFlag) ~= "string" then
				skeletonNode:setAnimation(0, "animation", true)
			else
				skeletonNode:setAnimation(0, staticFlag, true)	
			end
			if parent then
				parent:displayObject():addChild(skeletonNode)
				local bone = skeletonNode:findBone("pair_box")
				if bone ~=nil  then
					local posX = bone:getWorldX()
					local posY = bone:getWorldY()
					skeletonNode:setPosition(pos.x - posX,pos.y - posY)
				else
					skeletonNode:setPosition(pos.x,pos.y)
				end
			end
		end
		return  skeletonNode and skeletonNode or false
	end
	return false
end

function SpineUtil.createEffectById(effectID,pathRoot,parent,viewGroup)

	local effectInfo = DynamicConfigData.t_effect[effectID]--查看技能信息
	if effectInfo==nil then
		LuaLogE("特效:"..effectID.."没有配表")
		return  false
	end
	local fxList={}
	for k, effectConfig in pairs(effectInfo) do
		--print(086,pathRoot,effectConfig.name)
		local skeletonNode=SpineMnange.createByPath(pathRoot,effectConfig.name)
		if skeletonNode==nil then
			print(4,"加载 spine  :"..effectConfig.name.." .skel    "..effectConfig.name.." .atlas","出错")
			return  false
		end
		local skillObj =fgui.GObject:create()
		skillObj:displayObject():addChild(skeletonNode)
		if parent~=nil then
			parent:addChild(skillObj)
		end
		--if viewGroup~=nil then
			--skillObj:setGroup(viewGroup)
		--end
		skillObj:setSortingOrder(effectConfig.hierarchy)
		local infos={}
		infos.goWrap=skillObj
		infos.spine=skeletonNode
		infos.effectConfig=effectConfig
		table.insert(fxList,infos)
	end
	return  fxList
end

--创建战斗标识特效
function SpineUtil.createBattleFlag(parent)
	local skeletonNode=SpineUtil.createSpineObj(parent, Vector2.zero, "ui_zhandoubiaozhi_up", SpinePathConfiger.SwordEffect.path, SpinePathConfiger.SwordEffect.upEffect, SpinePathConfiger.SwordEffect.upEffect,true,true)
	return skeletonNode
end




function SpineUtil.changeParent(parent,skeletonNode)
	--skeletonNode:retain()
	skeletonNode:removeFromParent(false)
	parent:addChild(skeletonNode)
	skeletonNode:setPosition(Vector2.zero)
end

function SpineUtil.relaseSpine(skeletonNode)
	if skeletonNode and not tolua.isnull(skeletonNode) then
		skeletonNode:removeFromParent()
		skeletonNode:release()
	end

end


function SpineUtil.clearEffect(skeletonNode)
	if not skeletonNode then
		return
	end
	if type(skeletonNode) == "table" then
		for key, value in pairs(skeletonNode) do
			if not tolua.isnull(value)  then
				value:removeFromParent()
				skeletonNode[key]=nil
			end
		end
	else
		if not tolua.isnull(skeletonNode) then
			skeletonNode:removeFromParent()
		end
	end
end


function SpineUtil.retainSpine(atlasName)
	if _pcFxList[atlasName] then
		local view = ViewManager.getLayerTopWindow(LayerDepth.Window)
		if view==nil then
			_pcFxList[atlasName]:release()
			_pcFxList[atlasName] = nil
			return
		end
		if  view.window._showParticle then
			local action=view.window._action or "xuehua_zhujiemian"
			view.window.view:addChild(_pcFxList[atlasName])
			_pcFxList[atlasName].spine:setAnimation(0, action, true)
		end
	end
end



return SpineUtil