local GlobalUtil = {}
local MATH_FLOOR = math.floor

function GlobalUtil.delayTalk(callback)
	return Scheduler.scheduleOnce(0.5, callback)
end


--[[计算字体间距]]
function GlobalUtil.getAdditionalKerning(fontNum, fontWidth, targetWidth)
	dump({fontNum = fontNum,fontWidth = fontWidth, targetWidth = targetWidth})
	if fontNum >= 2  and targetWidth > fontWidth  then
		local spaceNum = fontNum - 1
		return (targetWidth - fontWidth) / spaceNum
	else
		return 0
	end
end

--[[值的转换， 值达到100万时，显示为100万；当值达到10亿时，显示为10亿
如果firstMarkValue有值，则以firstMarkValue为准
]]
function GlobalUtil.getCoinValue(value, firstMarkValue)
	local head = tonumber(value)
	if not head then
		print(168, "invalid value: "..tostring(value))
		return "0"
	end
	if firstMarkValue and firstMarkValue > value then
		return value
	end
	local tail = ""
	local firstMax = firstMarkValue or 1000000
	local secondeMax = 1000000000
	local firstDev 	= math.ceil(firstMax / 10000)
	if head >= firstMax  and head < secondeMax then
		tail = Desc.common_w
		head = math.floor(head / (firstMax / firstDev))
	elseif head >= secondeMax then
	    tail = Desc.common_y
	    head = math.floor(head / (secondeMax / 10))
	end
	return tostring(head)..tostring(tail)
end

--[[获取随机角色名]]
function GlobalUtil.randomRoleName(career)
	--做10次随机还有铭感词就没办法了
	local str
	for i=1,10 do
		str = NameConfiger.getRandowName(career)
		if not StringUtil.containShieldCharacter(str) then
			return str
		end
	end
	return NameConfiger.getRandowName(career)
end

--[[获取随机用户名]]
function GlobalUtil.randomUserName()
	local n = {0,1,2,3,4,5,6,7,8,9}

	local name = rawget(_G, "__PROJECT_NAME__") or ""
	for k=1,7 do
		--local randomNum = math.random(1,10000000)
		--local temp = randomNum%8
		--if temp < 5 then
		--	name = name ..t[math.random(1,26)]
		--else
			name = name ..n[math.random(1,10)]
		--end
	end

	return name
end

--[[获取随机密码]]
function GlobalUtil.randomPassword()
	local t = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'}
	local n = {0,1,2,3,4,5,6,7,8,9}
	local f = {'$','#','@','*'}

	local pwd = t[math.random(1,26)]
	for k=1, 9 do
		local randomNum = math.random(1,10000000)
		local temp = randomNum%9
		if temp < 3 then
			pwd = pwd..t[math.random(1,#t)]
		elseif temp < 7 then
			pwd = pwd..n[math.random(1,#n)]
		else
			pwd = pwd..f[math.random(1,#f)]
		end
	end

	return pwd
end

--秒转化为时间,天，小时， 分
function GlobalUtil.getTime(value) --秒
	local v = tonumber(value)
	local res = {day = 0, hour = 0,min = 0, sec = 0}
	if v and v >=0  then
		res.day = math.floor(v/86400)
		res.hour = math.floor((value - res.day * 86400)/3600)
		res.min = math.floor((value - res.day * 86400 - res.hour * 3600)/60)
		res.sec = value - res.day * 86400 - res.hour * 3600 - res.min * 60
	end
	return res
end

function GlobalUtil.getTimeByMSec(value) --豪秒
	local v = tonumber(value)
	return getTime(math.floor(v/1000))
end

-- 剩余时间 转换 天-时-分-秒
function GlobalUtil.getTimeStr(value, space, hour)
	local res = getTime(value)

	local space = ""
	if space then
		space = ""
	end
	local hourStr = Desc.common_hourShort
	if hour then
		hourStr = Desc.common_hour
	end

	local prefix = false
	local str = ""
	if res.day > 0 then
		prefix = true
		str = str .. res.day .. Desc.common_day .. space
	end
	if res.hour > 0 or prefix then
		prefix = true
		str = str .. res.hour .. hourStr .. space
	end
	if res.min > 0 or prefix then
		str = str .. res.min .. Desc.common_minute .. space
	end
	if res.sec >= 0 then
		str = str .. res.sec .. Desc.common_second
	end
	return str
end

--是否是itemCell
function GlobalUtil.isItemCell(params)
	params = params or {}
	if type(params.isItemCell) == "function" then
		return params.isItemCell()
	end
end

--设置widget的margin
function GlobalUtil.setWidgetLayout(widget, layoutParams)
	if tolua.iskindof(widget, "ccui.Widget") and type(layoutParams) == "table" then
		local layoutParameter = ccui.LinearLayoutParameter:create()
		local linearGravity = layoutParams.left and ccui.LinearGravity.left
							or layoutParams.right and ccui.LinearGravity.right
							or layoutParams.top and ccui.LinearGravity.top
							or layoutParams.bottom and ccui.LinearGravity.bottom
							or layoutParams.hCenter and ccui.LinearGravity.centerHorizontal
							or layoutParams.vCenter and ccui.LinearGravity.centerVertical
		if linearGravity then
			layoutParameter:setGravity(linearGravity)
		end

    	local margin = {left = 0, top = 0, right = 0, bottom = 0}
    	TableUtil.mergeA2B(layoutParams.margin, margin)
    	layoutParameter:setMargin(margin)
   		widget:setLayoutParameter(layoutParameter)
	end
end

--字符匹配
function GlobalUtil.getFavoriteItem(args)
	args = args or {}
	local function getWeight(src, tar)
		local function getChildStr(input)
			local len  = string.len(input)
		    local left = len
		    local cnt  = 0
		    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
		    local child ={}
		    while left ~= 0 do
		        local tmp = string.byte(input, -left)
		        local i   = #arr
		        while arr[i] do
		            if tmp >= arr[i] then
		            	table.insert(child, string.sub(input, -left, -(left - i + 1) ))
		                left = left - i
		                break
		            end
		            i = i - 1
		        end
		    end
		    return child
		end
		local child = getChildStr(tar)
		--printTable(168, "child str: ", child)
		local w = 0
		for i,v in ipairs(child) do
			if string.find(src, v) then
				w = w + 10
			end
		end

		return w
	end
	print(168, args.targetStr)
	local res = {}
	for k, v in args.iter(args.data) do
		local testStr = args.getString(v, k)
		local w = getWeight(testStr or "", args.targetStr)
		if w > 0 then
			table.insert(res, {w=w,item = v})
		end
	end
	table.sort(res, function (first, second)
		if second.w < first.w then
			return true
		else
			return false
		end
	end)
	return res
end

--分解字符串
function GlobalUtil.getChildStr(input)
	local len  = string.len(tostring(input))
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    local child ={}
    while left ~= 0 do
        local tmp = string.byte(input, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
            	table.insert(child, string.sub(input, -left, -(left - i + 1) ))
                left = left - i
                break
            end
            i = i - 1
        end
    end
    return child
end

function GlobalUtil.removeArrayItem(ary, condt)
	local testI = 1
	while testI <= #ary do
		if condt(ary[testI]) then
			table.remove(ary, testI)
		else
			testI = testI + 1
		end
	end
end

function GlobalUtil.newSortData(params)
	local item = {}
	function item:getSortKey()
		return params.key
	end

	function item:getSortValue()
		return params.value
	end

	return item
end

function GlobalUtil.sortByKey(data)
	if data then
		for i,v in ipairs(data:getSortKey()) do
			TableUtil.realSort(data:getSortValue(), function (first, second)
				local fp,sp =  first.value:getPriority(v),second.value:getPriority(v)
				if fp ~= sp then
					return fp < sp
				else
					return first.index < second.index
				end
			end)
		end
	end
end

function GlobalUtil.delayAction(delayTime,callback)
	local delay = cc.DelayTime:create(delayTime)
	local endCallback = cc.CallFunc:create(callback)
	return cc.Sequence:create({delay,endCallback})
end

--获取小红点的key
function GlobalUtil.getPromptKey(...)
	local count = select("#",...)
	local formatStr = string.rep("%s.",count-1) .. "%s"
	return string.format(formatStr,...)
end

--[[
	点击外部触发回调
]]
function GlobalUtil.createTouchLayer(x,y,width,height,callback,notSwallow,anchorPoint)
	local callback = callback or function () end
	
	
	local node = cc.Node:create()
	DisplayUtil.fillWidgetParams(node,{
		x = x,
		y = y,
		width = width,
		height = height,
		anchorPoint = anchorPoint or UI.POINT_LEFT_BOTTOM
	})

	local function onTouchBegan(pTouch)
	local parent = node
		while parent do 
			if not parent:isVisible() then
				return false
			end
			parent = parent:getParent()
		end

		local point = node:convertTouchToNodeSpace(pTouch)
		local x,y = point.x,point.y

		return callback(cc.Handler.EVENT_TOUCH_BEGAN,x,y,width,height)
	end

	local function onTouchMoved(pTouch)
		local point = node:convertTouchToNodeSpace(pTouch)
		local x,y = point.x,point.y
		callback(cc.Handler.EVENT_TOUCH_MOVED,x,y,width,height)
	end

	local function onTouchEnded(pTouch)
		local point = node:convertTouchToNodeSpace(pTouch)
		local x,y = point.x,point.y
		callback(cc.Handler.EVENT_TOUCH_ENDED,x,y,width,height)
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)

	if not notSwallow then
		listener:setSwallowTouches(true)
	else
		listener:setSwallowTouches(false)
	end
	local dispatcher = node:getEventDispatcher()
	dispatcher:addEventListenerWithSceneGraphPriority(listener,node)
	
	return node
end

function GlobalUtil.createLayerOutSideEvent( node,callBack,isSwallow )

	local function isTouchInsideNode(pTouch,node,nodeSize)
		local point = node:convertTouchToNodeSpace(pTouch)
		local x,y = point.x,point.y
		if x >= 0 and x <= nodeSize.width and y >= 0 and y <= nodeSize.height then
			return true
		end
	end

	local size = node:getContentSize()
	local function onTouchBegan(pTouch)
		local parent = node		
		while parent do 
			if not parent:isVisible() then
				return false
			end
			parent = parent:getParent()
		end

		if isTouchInsideNode(pTouch,node,size) then
			return false
		end

		return true
	end

	local function onTouchEnded(pTouch)
		if not isTouchInsideNode(pTouch,node,size) then
			callBack(node)
		end
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	listener:setSwallowTouches(isSwallow)
	local dispatcher = node:getEventDispatcher()
	dispatcher:addEventListenerWithSceneGraphPriority(listener,node)
end

--创建节点点击事件
function GlobalUtil.createLayerTouchEvent( node,callBack,isSwallow )
	local function isTouchInsideNode(pTouch,node,nodeSize)
		local point = node:convertTouchToNodeSpace(pTouch)
		local x,y = point.x,point.y
		printTable(21,"打印的坐标",x,y,nodeSize,pTouch)
		if x >= 0 and x <= nodeSize.width and y >= 0 and y <= nodeSize.height then
			return true
		end
	end

	--local size = node:getContentSize()
	local size = node:getBoundingBox()
	local function onTouchBegan(pTouch)
		local parent = node		
		while parent do 
			if not parent:isVisible() then
				return false
			end
			parent = parent:getParent()
		end

		if not isTouchInsideNode(pTouch,node,size) then
			return false
		end

		return true
	end

	local function onTouchEnded(pTouch)
		if  isTouchInsideNode(pTouch,node,size) then
			callBack(node)
		end
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	listener:setSwallowTouches(isSwallow)
	local dispatcher = node:getEventDispatcher()
	dispatcher:addEventListenerWithSceneGraphPriority(listener,node)
end


--[[
	node        listen的node
	isSwallow	是否吞入事件
	extraNodes	不受吞噬事件影响,并且不会调用callBack的node
]]--
function GlobalUtil.createLayerOutSideExtraNodeEvent( node,extraNodes,callBack,isSwallow)
	local function isTouchInsideNode(pTouch,node)
		local nodeSize = node:getContentSize()
		local point = node:convertTouchToNodeSpace(pTouch)
		local x,y = point.x,point.y
		if x >= 0 and x <= nodeSize.width and y >= 0 and y <= nodeSize.height then
			return true
		end
	end

	table.insert(extraNodes,node)
	local function onTouchBegan(pTouch)
		local parent = node		
		while parent do 
			if not parent:isVisible() then
				return false
			end
			parent = parent:getParent()
		end
		
		local isInPlace = true
		for k,v in pairs(extraNodes) do 
			if isTouchInsideNode(pTouch,v) then 
				isInPlace = false
				break
			end
		end
		if isInPlace then 
			callBack(node)
			return true
		else
			
		end
	end

	local function onTouchEnded(pTouch)
		
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	listener:setSwallowTouches(isSwallow)
	local dispatcher = node:getEventDispatcher()
	dispatcher:addEventListenerWithSceneGraphPriority(listener,node)
end

--满足条件回调
function GlobalUtil.delayCall(callback,conditionFunc,interval,repeatCount)
	if not type(callback) == "function" or not type(conditionFunc) == "function" then
		return
	end
	local handle = false
	local function delayFunc()
		if conditionFunc() then
			callback()
			if handle then
				Scheduler.unschedule(handle)
				handle = false
			end
		end
	end
	handle = Scheduler.schedule(delayFunc, interval or 0, repeatCount or 5)
end

--同一事件一帧只执行一次 （针对一个boss掉一堆东西掉帧的优化）
local eventMap = {}
function GlobalUtil.delayDispatch(event, ...)
	local preHandler = eventMap[event]
	if preHandler then
		Scheduler.unschedule(preHandler)
	end
	local handler = Scheduler.scheduleNextFrame(function ( ... )
		Dispatcher.dispatchEvent(event, ...)
		eventMap[event] = nil
	end)
	eventMap[event] = handler
end


--同一函数等所有调用完后xx时间才调用 （优化连续调用）
--key 函数唯一key，可以模块名+函数名
--func需要回调的函数
--回调时传的self
--time 超过这个时间没有新的调用就回调
local delayCallOneceMap = {}
function GlobalUtil.delayCallOnce(key,func, caller, time)
	if not time then time = 0.1 end
	local preHandler = delayCallOneceMap[key]
	if preHandler then
		Scheduler.unschedule(preHandler)
	end
	local handler = Scheduler.scheduleOnce(time, function ( )
		func(caller)
		delayCallOneceMap[key] = nil
	end)
	delayCallOneceMap[key] = handler
end


-- 按key递增顺序遍历
function GlobalUtil.ascpairs(tbl)
	local t = {}
	for k, v in pairs(tbl) do
		t[#t+1] = k
	end
	table.sort(t, function(a, b)
		return a < b 
	end	)

	local i = 0
	local function iter(tb)
		i = i + 1
		local key = t[i]
		if not key then
			return
		end
		return key, tb[key]
	end

	return iter, tbl, 0
end

function GlobalUtil.purgeGame()	
	SoundManager.stopMusic()
	gy.GYGameEntry:getInstance():restart()
end

function GlobalUtil.transLevel(level)
	return ChangeJobConfiger.getLevelStr(level)
end

function GlobalUtil.transLevelNum(lv)
	if lv > 370 then
		return lv - 370
	else
		return lv
	end
end

--获得00:00格式的时间
function GlobalUtil.transTimeSecondAndMin(time)
	time = time > 0 and time or 0
	local seconds = os.date("%S", time)
	local minutes = math.floor(time / 60)
	if(minutes < 10)then
		minutes = "0"..minutes
	end
	return minutes..":"..seconds
end

local ATTACK_INDEX = 10 --攻击力系数
local HP_INDEX = 0.6 --生命系数
local INDEX_100000 = 100000
local INDEX_200000 = 200000

function GlobalUtil.calFightAttrAdd( fightAttr )
	local roleLevel = Cache.roleCache:getLevel()
	local MATH_FLOOR = math.floor

	local levelTmp = MATH_FLOOR(roleLevel/3)
	if fightAttr.levelHpMaxAdd > 0 then
		fightAttr.hpMax = fightAttr.hpMax + levelTmp * fightAttr.levelHpMaxAdd
	end

	if fightAttr.levelAttackAdd > 0 then
		fightAttr.attack = fightAttr.attack + levelTmp * fightAttr.levelAttackAdd
	end

	if fightAttr.levelDefenseAdd > 0 then
		fightAttr.defense = fightAttr.defense + levelTmp * fightAttr.levelDefenseAdd
	end	

	if fightAttr.levelCrackAdd > 0 then
		fightAttr.crack = fightAttr.crack + levelTmp * fightAttr.levelCrackAdd
	end

	if fightAttr.eachLevelAttackAdd > 0 then
		fightAttr.attack = fightAttr.attack + roleLevel * fightAttr.eachLevelAttackAdd
	end

	if fightAttr.level50HurtAddPct > 0 then
		local levelFactor = MATH_FLOOR(roleLevel / 50)
		fightAttr.hurtAdditionPct = fightAttr.hurtAdditionPct + levelFactor * fightAttr.level50HurtAddPct
	end

	if fightAttr.levelHpRecoverAdd > 0 then
		fightAttr.hpRecover = fightAttr.hpRecover + roleLevel * fightAttr.levelHpRecoverAdd
	end

	fightAttr.hpMax 			= fightAttr.hpMax + MATH_FLOOR(fightAttr.hpMax * (fightAttr.hpMaxAddPct or 0))
	fightAttr.attack 			= fightAttr.attack + MATH_FLOOR(fightAttr.attack * (fightAttr.attackAddPct or 0))
	fightAttr.crack 			= fightAttr.crack + MATH_FLOOR(fightAttr.crack * (fightAttr.crackAddPct or 0))
	fightAttr.defense 			= fightAttr.defense + MATH_FLOOR(fightAttr.defense * (fightAttr.defenseAddPct or 0))
	fightAttr.hpRecover 		= fightAttr.hpRecover + MATH_FLOOR(fightAttr.hpRecover * (fightAttr.hpRecoverAddPct or 0))
	fightAttr.moveSpeed 		= fightAttr.moveSpeed + MATH_FLOOR(fightAttr.moveSpeed * (fightAttr.moveSpeedAddPct or 0))
	fightAttr.internalDamage 	= fightAttr.internalDamage + MATH_FLOOR(fightAttr.internalDamage * (fightAttr.internalDamageAddPct or 0))
	fightAttr.internalInjury 	= fightAttr.internalInjury + MATH_FLOOR(fightAttr.internalInjury * (fightAttr.internalInjuryAddPct or 0))
	fightAttr.dodge 			= fightAttr.dodge + MATH_FLOOR(fightAttr.dodge * fightAttr.dodgePct)
	fightAttr.hit 				= fightAttr.hit + MATH_FLOOR(fightAttr.hit * fightAttr.hitPct)
end

--计算战力
function GlobalUtil.calFightCap(fightAttr)

	calFightAttrAdd(fightAttr)

	local level = Cache.roleCache:getLevel()

	local capTb = {}
	--生命
	capTb.hpMaxCap = fightAttr.hpMax * 0.5
	--攻击
	capTb.attackCap = fightAttr.attack * 10
	--物理护甲
	capTb.defenseCap = fightAttr.defense * 5
	--法术护甲
	capTb.roleSpellDefenseCap = fightAttr.roleSpellDefense * 5
	--破甲
	capTb.crackCap = fightAttr.crack * 10
	--命中
	capTb.hitCap = fightAttr.hit * 10
	--闪避
	capTb.dodgeCap = fightAttr.dodge * 10
	--抗暴
	capTb.toughCap = fightAttr.tough * 10
	--暴击
	capTb.critCap = fightAttr.crit * 10
	--内功伤害
	capTb.internalDamageCap = fightAttr.internalDamage * 10
	--内功减伤
	capTb.internalInjuryCap = fightAttr.internalInjury * 10
	--暴击伤害
	capTb.critHurtCap = fightAttr.critHurt * 10
	--暴击减伤
	capTb.critInjuryCap = fightAttr.critInjury * 10


	capTb.defenseTotalCap = capTb.hpMaxCap + capTb.defenseCap + capTb.roleSpellDefenseCap + capTb.dodgeCap + capTb.toughCap + capTb.internalInjuryCap + capTb.critInjuryCap
	capTb.attackTotalCap = capTb.attackCap + capTb.crackCap + capTb.hitCap + capTb.critCap + capTb.internalDamageCap + capTb.critHurtCap
	capTb.blockPctCap = capTb.defenseTotalCap * fightAttr.blockPct * 0.25 / 0.75
	capTb.wreckPctCap = capTb.attackTotalCap * fightAttr.wreckPct * 0.25 / 0.75
	if fightAttr.blockEffectPct >= 0 then
		local blockEffectPct = fightAttr.blockEffectPct
		if blockEffectPct >= 2.99 then
			blockEffectPct = 2.99
		end
		if blockEffectPct < 0 then
			blockEffectPct = 0
		end
		capTb.blockEffectPctCap = capTb.defenseTotalCap * (1 / (0.75 - 0.25 * blockEffectPct) - 1 / 0.75)
	else
		capTb.blockEffectPctCap = 0
	end
	if fightAttr.blockPenetratePct >= 0 then
		local blockPenetratePct = fightAttr.blockPenetratePct
		if blockPenetratePct >= 2.99 then
			blockPenetratePct = 2.99
		end
		if blockPenetratePct < 0 then
			blockPenetratePct = 0
		end
		capTb.blockPenetratePctCap = capTb.attackTotalCap * (1 / (0.75 - 0.25 * blockPenetratePct) - 1 / 0.75)
	else
		capTb.blockPenetratePctCap = 0
	end
	capTb.critRatePctCap = capTb.attackTotalCap * fightAttr.critRatePct * 0.5
	capTb.toughPctCap = capTb.defenseTotalCap * fightAttr.toughPct * 0.5
	capTb.critEffectPctCap = capTb.attackTotalCap * fightAttr.critEffectPct * 0.5
	capTb.critInjuryPctCap = capTb.defenseTotalCap * fightAttr.critInjuryPct * 0.5
	capTb.fatalBlowPctCap = capTb.attackTotalCap * fightAttr.fatalBlowPct
	capTb.fatalResistancePctCap = capTb.defenseTotalCap * fightAttr.fatalResistancePct
	capTb.fatalBlowAddHurtPctCap = capTb.attackTotalCap * fightAttr.fatalBlowAddHurtPct *0.5
	capTb.fatalBlowInjuryPctCap = capTb.defenseTotalCap * fightAttr.fatalBlowInjuryPct * 0.5
	capTb.skillAdditionPctCap = capTb.attackTotalCap * fightAttr.skillAdditionPct
	capTb.skillResistancePctCap = capTb.defenseTotalCap * fightAttr.skillResistancePct
	capTb.hurtAdditionPctCap = capTb.attackTotalCap * fightAttr.hurtAdditionPct
	local hurtResistancePct = fightAttr.hurtResistancePct
	if hurtResistancePct > 0.99 then
		hurtResistancePct = 0.99
	end
	if hurtResistancePct < 0 then
		hurtResistancePct = 0
	end
	capTb.hurtResistancePctCap = capTb.defenseTotalCap / (1 - hurtResistancePct)
	capTb.pvpHurtAddPctCap = capTb.attackTotalCap * fightAttr.pvpHurtAddPct
	local pvpHurtDelPct = fightAttr.pvpHurtDelPct
	if pvpHurtDelPct > 0.99 then
		pvpHurtDelPct = 0.99
	end
	if pvpHurtDelPct < 0 then
		pvpHurtDelPct = 0
	end
	capTb.pvpHurtDelPctCap = capTb.defenseTotalCap / (1 - pvpHurtDelPct)

	local fightCap = MATH_FLOOR(
		capTb.defenseTotalCap + capTb.attackTotalCap + 
		capTb.blockPctCap + capTb.wreckPctCap +
		capTb.blockEffectPctCap + capTb.blockPenetratePctCap + 
		capTb.critRatePctCap + capTb.toughPctCap + 
		capTb.critEffectPctCap + capTb.critInjuryPctCap + 
		capTb.fatalBlowPctCap + capTb.fatalResistancePctCap + 
		capTb.fatalBlowAddHurtPctCap + capTb.fatalBlowInjuryPctCap + 
		capTb.skillAdditionPctCap + capTb.skillResistancePctCap + 
		capTb.hurtAdditionPctCap + capTb.hurtResistancePctCap + 
		capTb.pvpHurtAddPctCap + capTb.pvpHurtDelPctCap
		)

	return fightCap
end

local function valifyFightAttr( attr )
  for k,v in pairs(attr) do
    if v ~= 0 then
      v = string.format("%.5f",v)
      v = string.gsub(v,"(0+)$","")
      v = string.gsub(v,"(%.)$","")
      attr[k] = tonumber(v)
    end
  end
end


--[[
--计算战力
一般用于界面显示战力的计算

	src: 			用来计算战力的属性
	unused: 		这部分属性目前是否还没有加到战力计算中，比如装备背包就是已经加了，物品背包的就是还未加的
]]

--[[function GlobalUtil.calFightCapacity(src, unused)
	local roleCache = Cache.roleCache		
	local curFightCap = roleCache:getFightCap()
	local rawFightAttr = roleCache:getRawBaseFightAttr()

	if unused then
		local restAttr = SFightAttr.new(rawFightAttr) + src
		valifyFightAttr(restAttr)
		local restFightCap = calFightCap(restAttr)
		local result = restFightCap - curFightCap
		if result < 0 then
			result = 0
		end
		return result
	else
		local restAttr = SFightAttr.new(rawFightAttr) - src
		valifyFightAttr(restAttr)
		local restFightCap = calFightCap(restAttr)
		return curFightCap - restFightCap
	end
end

function GlobalUtil.calFightCapacityEx( add,sub )
	local roleCache = Cache.roleCache
	local curFightCap = roleCache:getFightCap()
	local rawFightAttr = roleCache:getRawBaseFightAttr()
	local nowAttr = SFightAttr.new(rawFightAttr)
	if sub then
		nowAttr = nowAttr - sub
		valifyFightAttr(nowAttr)
		curFightCap = calFightCap(nowAttr)
	end

	local restAttr = nowAttr + add
	valifyFightAttr(restAttr)
	local restFightCap = calFightCap(restAttr)
	return restFightCap - curFightCap
end--]]


function GlobalUtil.transExp(exp)
	local res = exp
	if exp >= 100000000 then
		res = exp / 100000000
		res = string.format(Desc.common_floatY2,res)
	elseif exp >= 10000 then
		res = exp / 10000
		res = string.format(Desc.common_floatW2,res)
	end
	return res
end

function GlobalUtil.transExpNoPoint(exp)
	local res = exp
	if exp >= 100000000 then
		res = exp / 100000000
		res = string.format(Desc.common_floatY,res)
	elseif exp >= 10000 then
		res = exp / 10000
		res = string.format(Desc.common_floatW,res)
	end
	return res
end

function GlobalUtil.transBigExp(exp)
	local res = exp
	if exp >= 10000000000000 then
		res = exp / 1000000000000
		res = string.format(Desc.common_floatWY2, res)
		return res
	end
	if exp >= 100000000 then
		res = exp / 100000000
		res = string.format(Desc.common_floatY2, res)
		return res
	end
	if exp >= 10000 then
		res = exp / 10000
		res = string.format(Desc.common_floatW2, res)
		return res
	end
	return res
end

-- 转换数字为带单位缩写
-- 商为整数时不带小数位
function GlobalUtil.transMoney(amount)
	if amount >= 1000000000000 then
		local value = amount / 1000000000000
		if math.floor(value) == value then
			return string.format(Desc.common_intWY, value)
		end
		return string.format(Desc.common_floatWY2, value)
	end

	if amount >= 100000000 then
		local value = amount / 100000000
		if math.floor(value) == value then
			return string.format(Desc.common_intY, value)
		end
		return string.format(Desc.common_floatY2, value)
	end

	if amount >= 10000 then
		local value = amount / 10000
		if math.floor(value) == value then
			return string.format(Desc.common_intY, value)
		end
		return string.format(Desc.common_floatW2, value)
	end

	return amount
end

--二分查找提高速度

--[[
	自定义函数
	compFunc(a,b)	
	return: 0:	a==b   
			1:	a>b
			-1	a<b

]]
function GlobalUtil.binarySearch(targetVal,srcTb,maxIndex,compFunc)
	local minIndex = 1
	local MATH_FLOOR = math.floor
	
	if type(compFunc) == "function" then		
		while minIndex <= maxIndex do 
			local middle = MATH_FLOOR((minIndex + maxIndex)/2)
			local val = srcTb[middle]
			if not val then
				maxIndex = middle - 1

			else
				local rlt = compFunc(targetVal, val)
				if rlt == 0 then 
					return middle
				elseif rlt > 0 then
					minIndex = middle + 1
				else
					maxIndex = middle - 1
				end
			end			
		end
	else
		while minIndex <= maxIndex do 
			local middle = MATH_FLOOR((minIndex + maxIndex)/2)
			local val = srcTb[middle]

			if not val then
				maxIndex = middle - 1
			elseif targetVal == val then 
				return middle
			elseif targetVal > val then
				minIndex = middle + 1
			else
				maxIndex = middle - 1
			end
		end
	end
	return maxIndex
end

function GlobalUtil.isPCDownload()
	return (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 or CC_TARGET_PLATFORM == CC_PLATFORM_MAC) and ScriptType == ScriptTypePackS
end

--判断字符串中是否有后台发过来的超链接，有的话提取出来
function GlobalUtil.partPhpUrlLink(str)
	local finalStr
	local decodeStr
	local i= string.find(str,'%[')
	local j= string.find(str,'%]')
	if i and j and i > 0 and j > 0 then
		local jsonStr = string.sub(str,i,j)
		decodeStr = json.decode(jsonStr)
		local urlHtml = "<a href='"..decodeStr[1].url.."'>"..decodeStr[1].name.."</a>"
		finalStr = string.sub(str,1,i-1)..urlHtml..string.sub(str,j+1)
	else
		finalStr = str
	end
	return finalStr
end

function GlobalUtil.bigInt2Str(a)
	if a >= 10 ^ 14 then
		local t = {}
		while a > 1 do
			local n = a % 10
			table.insert(t, 1, n)
			a = math.floor(a / 10)
		end
		local s = table.concat(t, "")
		return s
	end

	return tostring(a)
end

--获取某个目录下的所有文件, 仅在电脑上生效！！！！
function GlobalUtil.getDirFiles(fullPath)
	local lfs = require"lfs"
	local dirs = {}
	local files = {}

	local function fileFiles(directory)
		for file in lfs.dir(directory) do
			local fullPath = directory .. file			
	        local attr = lfs.attributes(fullPath)
	        if file ~= "." and file ~= ".." and attr then
		        if attr.mode == "directory" then
		        	dirs[fullPath] = true
		        	fileFiles(fullPath .. "/")
		        elseif attr.mode == "file" then
		        	files[fullPath] = true
		        end
		    end
	    end
	end
	fileFiles(fullPath)

	return dirs, files
end

return GlobalUtil