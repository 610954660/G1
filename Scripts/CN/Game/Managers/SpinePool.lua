---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: Ljj
-- Date: 2020-08-05 15:09:27
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class SpinePool
local SinglePool=require "Game.Managers.SinglePool"

local SpinePool,super = class("SpinePool",SinglePool)

function SpinePool:ctor()
	--self._updateId = false
	--self.pooList=false
	--self._TimeThrehold=0
	--self._lastGetTime=0
	--self._currentTime=0
	--self._CountThrehold = 10  --清缓存时，最多保留这么多个.
	--self._MaxCount = 60  --如果有这么多，不管怎么样都要清理掉.
	 
	self.__useList={}--被使用的列表
end

function SpinePool:initialize(medelName,count)
	self._poolName=medelName
	self.pooList= Queue.new()
	for i = 1, count do
		local skeletonNode=sp.SkeletonAnimation:createWithBinaryFile(medelName..".skel",medelName..".atlas",1,ModelManager.SettingModel:useMinMapMode())
		skeletonNode:retain()
		skeletonNode.isRetain=true
		self.pooList:enqueue(skeletonNode)
	end
	return self
end


--默认策略：超过池子最大数量的阀值则强制清理；或者隔固定时间清理一波；如果有自定义的策略，只执行自定义的。
function SpinePool:sweep()
	--super.sweep(self)
end


function SpinePool:update(interval)
	self._lastGetTime=self._lastGetTime+interval
	if self._lastGetTime>=30 then
		self:clearPool()
		self._lastGetTime=0
	end
end




function SpinePool:getTime()
	return self._currentTime
end


--从池子获取一个对象没有就创建
function SpinePool:getObject(medelName)
	self._lastGetTime = 0
	--print(0932,self._poolName,self.pooList:size())
	if self.pooList:size()>0 then
		local skeletonNode=self.pooList:dequeue()
		skeletonNode.isRetain=true
		skeletonNode.guid=self:guid()
		self.__useList[skeletonNode.guid]=skeletonNode
		return skeletonNode
	end
	local skeletonNode=sp.SkeletonAnimation:createWithBinaryFile(medelName..".skel",medelName..".atlas",1,ModelManager.SettingModel:useMinMapMode())
    skeletonNode:retain()
	skeletonNode.isRetain=true
	skeletonNode.guid=self:guid()
	self.__useList[skeletonNode.guid]=skeletonNode
	return skeletonNode
end

--回收一个对象
function SpinePool:returnObject(skeletonNode)
	if skeletonNode.isRetain then
		if self.__useList[skeletonNode.guid] then
			self.__useList[skeletonNode.guid]=nil
		end
		super.returnObject(self,skeletonNode)
		skeletonNode.isRetain=false
	end
end

--清楚对象
function SpinePool:clearAll()
	for k, skeletonNode in pairs(self.__useList) do
		self:returnObject(skeletonNode)
	end 
	self.__useList={}
	super.clearAll(self)
end

--清楚池子不用的对象
function SpinePool:clearPool()
	super.clearPool(self)
end


function SpinePool:guid()
	local seed={'e','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'}
	local tb={}
	for i=1,32 do
		table.insert(tb,seed[math.random(1,16)])
	end
	local sid=table.concat(tb)
	return string.format('%s-%s-%s-%s-%s',
		string.sub(sid,1,8),
		string.sub(sid,9,12),
		string.sub(sid,13,16),
		string.sub(sid,17,20),
		string.sub(sid,21,32)
	)
end


return SpinePool