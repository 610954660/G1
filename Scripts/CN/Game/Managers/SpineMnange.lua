---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-01-10 12:03:08
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class SpineMnange
local SpineMnange = {}

local _SpinePools={}


--创建动作测试页面
function SpineMnange.createSprineById(heroID,isHero,count,elfSpine,fashionId)
	
	local medelName=""
	if elfSpine then
		medelName = elfSpine
	else
		if isHero then 
			local hero=DynamicConfigData.t_hero[heroID]
			if not hero and heroID > 100000 then
				local heroId = math.floor(heroID/1000)  --如果传的是时装头像，去掉后三位（暂时先用着）
				hero = DynamicConfigData.t_hero[heroId]
			end
			if hero==nil then
				LuaLogE("英雄ID找不到")
				if not __IS_RELEASE__ then
					RollTips.show("配表出错英雄ID "..heroID.." 找不到",5)
				end
				return  false
			end
			medelName=DynamicConfigData.t_AllResource[hero.model].name
		else
			local monster=DynamicConfigData.t_monster[heroID]
			if monster==nil then
				LuaLogE("怪物ID找不到")
				if not __IS_RELEASE__ then
					RollTips.show("配表出错怪物ID "..heroID.." 找不到",5)
				end
				return  false
			end
			medelName=DynamicConfigData.t_AllResource[monster.model].name
		end
	end
	
	local heroName="Spine/"..medelName
	
	if not cc.FileUtils:getInstance():isFileExist(heroName..".skel") then
		LuaLogE(heroName..".skel no find")
		RollTips.show(heroName..".skel no find")
		return
	end

	if not cc.FileUtils:getInstance():isFileExist(heroName..".atlas") then
		LuaLogE(heroName..".atlas no find")
		RollTips.show(heroName..".atlas no find")
		return
	end
	--
	if heroName==nil then
		print(4,"this heroID "..heroID.." no exit spine to create")
		return 
	end
		
	if count then
		if fashionId then
			local fanshionInfo = DynamicConfigData.t_Fashion[heroID] and DynamicConfigData.t_Fashion[heroID][fashionId]
			if fanshionInfo then
				if not TableUtil.isEmpty(fanshionInfo.fashionIndex) then
					local DrawId = fanshionInfo.fashionIndex and fanshionInfo.fashionIndex[1]
					if DrawId and DrawId ~= 0 then
						heroName = heroName.."_"..DrawId
					end
				end
			else
				BattleManager:getInstance():fxCheckTips("皮肤配置 英雄id"..heroID.." 皮肤id "..fashionId.." 找不到")
			end
		end
		
		if not  _SpinePools[heroName] then 
			_SpinePools[heroName]=PoolManager.registSpinePool(heroName,count);
		end
		return _SpinePools[heroName]:getObject(heroName) ,_SpinePools[heroName]
	else
		local skelName = heroName..".skel"
		local atlasName = heroName..".atlas"
		if fashionId then 
			local fanshionInfo = DynamicConfigData.t_Fashion[heroID] and DynamicConfigData.t_Fashion[heroID][fashionId] 
			if fanshionInfo then 
				if not TableUtil.isEmpty(fanshionInfo.fashionIndex) then 
					local DrawId = fanshionInfo.fashionIndex and fanshionInfo.fashionIndex[1] 
					if DrawId and DrawId ~= 0 then 
						skelName = heroName.."_"..DrawId..".skel"
						atlasName = heroName.."_"..DrawId..".atlas"
					end
				end
			end
		end
		local skeletonNode = sp.SkeletonAnimation:createWithBinaryFile(skelName,atlasName,1,ModelManager.SettingModel and ModelManager.SettingModel:useMinMapMode() or false)
		--local skeletonNode = sp.SkeletonAnimation:createWithBinaryFile(heroName..".skel",heroName..".atlas",1)
		return skeletonNode
	end
end

--创建动作测试页面
function SpineMnange.createByPath(path,skelName,atlasName)
	if not path or not skelName  then return end
	skelName=path.."/"..skelName
	if atlasName then
		atlasName=path.."/"..atlasName
	else
		atlasName=skelName
	end
	
	if not cc.FileUtils:getInstance():isFileExist(skelName..".skel") then
		LuaLogE(skelName..".skel no find")
		RollTips.show(skelName..".skel no find")
		return
	end
	
	if not cc.FileUtils:getInstance():isFileExist(atlasName..".atlas") then
		LuaLogE(atlasName..".atlas no find")
		RollTips.show(atlasName..".atlas no find")
		return
	end
	
	local skeletonNode =false
	skeletonNode = sp.SkeletonAnimation:createWithBinaryFile(skelName..".skel",atlasName..".atlas",1,ModelManager.SettingModel and ModelManager.SettingModel:useMinMapMode() or false)
	return skeletonNode
end



--创建动作测试页面
function SpineMnange.createWithBinaryFile(path,skillName)
	
	skillName=path.."/"..skillName
	print(4,skillName,"skillName")
	local skeletonNode = sp.SkeletonAnimation:createWithBinaryFile(skillName..".skel",skillName..".atlas",1,ModelManager.SettingModel and ModelManager.SettingModel:useMinMapMode() or false)
	return skeletonNode
end



function SpineMnange.getBonPosition(skeletonNode,name,index)
	--printTable(4,)
	if tolua.isnull(skeletonNode) then
		return {x=2,y=-57}
	end
	local temp= skeletonNode:findBone(name)
	if temp==nil  then
		--if index==nil
		print(08666,index.."这个位置的英雄没有"..name.."挂点")
		return {x=2,y=-57}--美术没做 默认一个挂点
	end
	return  {x=temp:getWorldX(),y=-temp:getWorldY()}--self.view局部坐标转屏幕坐标
	--return  {x=temp:getWorldX(),y=temp:getWorldY()}
end

function SpineMnange.getHugPotision(pos,parent)
	if parent==nil then
		return 
	end
	return parent:globalToLocal(pos)
end

--使用普通spine动画
function SpineMnange.createSpineByName(name)
	local skeletonNode = sp.SkeletonAnimation:createWithBinaryFile(name..".skel",name..".atlas",1,ModelManager.SettingModel and ModelManager.SettingModel:useMinMapMode() or false)
	return skeletonNode
end

--清楚所有的spine
function SpineMnange.clearAll()
	for k, spinePool in pairs(_SpinePools) do
		spinePool:clearAll()
	end
	_SpinePools={}
end

--清楚未使用的spine緩存
function SpineMnange.clearPool()
	for k, spinePool in pairs(_SpinePools) do
		spinePool:clearPool()
	end
	--_SpinePools={}
end


return SpineMnange