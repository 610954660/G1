

local PoolManager={}
local SinglePool=require "Game.Managers.SinglePool"
local SpinePool=require "Game.Managers.SpinePool"
local pooList={}
local interval=30

--function M:ctor()
	--self._updateId = false

	----一些具体对象池，可以是单例，也可以这边创建，然后统一从这边取.
	----全部继承自 CustomPoolBase，具体时间参数可以在类的构造函数里设置，也可以这边根据统计数据动态调整.
	----动态创建的对象池如果需要自动管理，调用 registerPools() 和 removePool()
	--self.pooList={}
--end
--* 注册缓存池
--* @private
--*
--function PoolManager.registerPools(PoolName) 
	 --local lihuiPool=self._registerPool(PoolName.lihui);
--end
function PoolManager.init()
	local layerNode = ViewManager.getParentLayer(LayerDepth.Window)
	layerNode:displayObject():onUpdate(function (dt)
			PoolManager.update(dt,0,0)
	end,0)
end


	
function PoolManager.registerPool(poolData,count)
	   local SinglePool= SinglePool.new()
	   SinglePool:initialize(poolData)
	   pooList[poolData.name]=SinglePool
	   return SinglePool
end

function PoolManager.registSpinePool(medelName,count)
	local SpinePool= SpinePool.new()
	SpinePool:initialize(medelName,count)
	pooList[medelName]=SpinePool
	return SpinePool
end


function PoolManager.update(dt, currentTime, preTime)
    interval=interval-dt
	if interval<=0 then
		interval=30
		printTable(086086,"30秒监听一次对象池信息",table.nums(pooList))
		for _, pool in pairs(pooList) do
			if pool then
				pool:update(interval)
			end
		end
	end
end


function PoolManager.removePool(poolData)
	pooList[poolData.name]:clear()
	pooList[poolData.name] = nil
end


--清楚池子和被外界使用的对象
function PoolManager.clearAll()
	for _, pool in pairs(pooList) do
	       if pool then
	           pool:clear()
           end
	end
	pooList={}
end

--清楚没有池子内没引用的对象
function PoolManager.clearPool()
	for _, pool in pairs(pooList) do
		if pool then
			pool:clear()
		end
	end
	pooList={}
end


return PoolManager
