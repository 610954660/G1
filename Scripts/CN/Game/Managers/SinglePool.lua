

local SinglePool = class("SinglePool")

function SinglePool:ctor()
	self._updateId = false
	self.pooList=false
	self._TimeThrehold=0
	self._lastGetTime=0
	self._currentTime=0
	self._CountThrehold = 10  --清缓存时，最多保留这么多个.
	self._MaxCount = 60  --如果有这么多，不管怎么样都要清理掉.
	self._poolName=false
end

function SinglePool:initialize(poolData,count)
	self.pooList= Queue.new()
	for i = 1, count do
		local gObject=fgui.UIPackage:createObjectFromURL(poolData.url)
		gObject:retain()
		self.pooList:enqueue(gObject)
	end
	return self
end

--默认策略：超过池子最大数量的阀值则强制清理；或者隔固定时间清理一波；如果有自定义的策略，只执行自定义的。
function SinglePool:sweep()
	-- 如果有自定义的策略，只执行自定义的.
	if self._sweepFunc then
		self._sweepFunc(self)
		return
	end

	if self.pooList:size() <= self._CountThrehold then
		return
	end

	local curTime = self:getTime()

	if curTime - self._lastGetTime >= self._TimeThrehold or (self._MaxCount > 0 and self.pooList:size() > self._MaxCount) then
		while self.pooList:size() > self._CountThrehold
			do
				--local object = self.pooList:dequeue()
				--object:removeFromParent()
				--object:release()
			end
	end
end


function SinglePool:update(dt, currentTime, preTime)
	self._currentTime=currentTime
end


function SinglePool:getTime()
   return self._currentTime
end



--从池子获取一个对象没有就创建
function SinglePool:getObject(url)
	self._lastGetTime = self:getTime()
	if self.pooList:size()>0 then
	    local gObject=self.pooList:dequeue()
		return gObject
	end
	local newObject=fgui.UIPackage:createObjectFromURL(url)
	newObject:retain()
	return newObject
end

--回收一个对象
function SinglePool:returnObject(gObject)
	self.pooList:enqueue(gObject)
	gObject:removeFromParent(false)
end


--清楚对象
function SinglePool:clearAll()
	while self.pooList:size()>0 do
		local object=self.pooList:dequeue()
		object:removeFromParent()
		object:release()
	end	
end
	
--清楚池子不用的对象
function SinglePool:clearPool()
	while self.pooList:size()>0 do
		local object=self.pooList:dequeue()
	    print(086086,self._poolName,"清清")
		object:removeFromParent()
		object:release()
	end
end
	
return SinglePool