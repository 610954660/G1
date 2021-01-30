local BubbleManager = {}
local lastRefNode = false
local containers = {}
local canShow = {true,true,true}
local num = {}
local maxTimer = 0 
local TimerMap = {}
local TimingMap = {}
local schedule = Scheduler.schedule
local schedulerIdMap = {}
local time = 0

--加入到随机队列
function BubbleManager.add2TimerMap(code,data,uid)
	local mapId = Cache.mapCache.getCurMapId()
	local info = BubbleConfiger.getBubbleConfig(code,mapId)

	
	if info then 
		if not schedulerIdMap[code] then 
			--给每一个怪堆一个定时器
			local function callback()
				--printTable(14,TimerMap)
				--printTable(14,num)
				--print(14,os.time() - time)
				--time = os.time()
			
				--	print(14,v.config.maxNum,num[k],k)
					--printTable(14,v)
					--print(14,k,num[k])
				local value = TimerMap[code]
				if value and num and num[code] and num[code] < value.config.maxNum and TimerMap[value.config.mobCode].length > 0 then 
					math.randomseed(os.time())
					local talkRate = math.random(1,100) 
					--每一次定时计算概率是否展示
					if value.config.rate > talkRate then 
						local index = math.random(1,TimerMap[value.config.mobCode].length)
						local temp = value[index]
						local strIndex = math.random(1,#value.config.tStr)
						num[code] = num[code] + 1
						show({
							referNode = temp.data,
							uid = temp.uid,
							info = value.config,
							code = temp.code,
							str = value.config.tStr[strIndex],
						})
					end
				end
			end

			schedulerIdMap[code] = schedule(callback,info.span)
		end 

		if not num[code] then 
			num[code] = 0
		end
		if not TimingMap[uid] then 
			if not TimerMap[code] then 
				TimerMap[code] = {}
				TimerMap[code].config = info
				TimerMap[code].length = 0
			end
			TimerMap[code].length = TimerMap[code].length + 1
			table.insert( TimerMap[code], {code = code,data = data,uid = uid,mapId = mapId})
		end 
	end 
end

function BubbleManager.remove2TimerMap(id,code)
	if TimerMap[code] then 
		for k,v in ipairs(TimerMap[code]) do 
			if MapDefines.EntityUtil.isSameEntity(v.uid,id) then
				table.remove(TimerMap[code],k)
				--print(14,"table.remove(TimerMap[code]")
				TimerMap[code].length = TimerMap[code].length - 1
				if TimerMap[code].length == 0 then 
					Scheduler.unschedule(schedulerIdMap[code])
					schedulerIdMap[code] = nil
					TimerMap[code] = nil
				end
	 			break
			end 
			-- for key,value in pairs(v) do 
			-- 	for key2,value2 in pairs(value) do 
			-- 		if value2.uid == id then 
			-- 			table.remove(value,key2)
			-- 		end 
			-- 	end 
			-- end 
		end 
	end

	if TimingMap[id] then 
		--hideBubble(TimingMap[id])
	--	print(14,"remove2TimerMap")
		num[code] = num[code] - 1
		TimingMap[id] = nil
		if num[code] == 0 then 
			num[code] = nil
		end
	end 
end

local function template(str,width)
	local width = width or 230
	local str = str or ""
	local word = UI.newRichText({
		text = str,
		width = width,
	})

	local wordSize = word:getContentSize()
	local offSetX = 3
	local bg = UI.newScale9Sprite({
		width = wordSize.width + offSetX*2,
		height = wordSize.height + 35,
		style = {
			src = ResManager.getRes(ResType.PUBLIC, "talk_frame"),
			scale9Rect = { left = 60, right = 10, top = 10, bottom = 10 }
		},
		anchorPoint = UI.POINT_CENTER_BOTTOM,
	})
	bg:addChild(word)
	word:setPosition(5 + offSetX,wordSize.height + 25)

	function bg:setData(str)
		word:setText(str)
		local wordSize = word:getContentSize()
		bg:setContentSize(cc.size(wordSize.width,wordSize.height + 25))
		word:setPosition(5 + offSetX,wordSize.height + 25)
	end
	return bg
end

function BubbleManager.createBubble(params)
	local showNode = template(params.str)

	local referNode = params.referNode

	if tolua.isnull(referNode) then 
		return
	end

	local duration = 0.5
	showNode:setScale(0.01)
	showNode:runAction(cc.EaseExponentialOut:create(cc.ScaleTo:create(duration, 1)))

	local function close()
		if not tolua.isnull(showNode) then
			local function callback()
				showNode:removeFromParent()
				if params.endCallback then
					params.endCallback()
				end
			end
			local endCallback = cc.CallFunc:create(callback)
			showNode:runAction(cc.Sequence:create(cc.EaseExponentialIn:create(cc.ScaleTo:create(duration, 0)), endCallback))
		end
	end

	Scheduler.scheduleOnce(params.time or 3, close)

	showNode:setPosition(referNode:getHeadwear():getPosition())
	dump(333,showNode:getPosition(),"showNode:getPosition()")
	referNode:addChild(showNode, 100)
	showNode:setPositionZ(200)
end

--展示冒泡对话
function BubbleManager.show(params)

	local showNode = template(params.str)

	local referNode = params.referNode

	if tolua.isnull(referNode) then 
		remove2TimerMap(params.uid,params.code)  
		return 
	end
	local duration = 0.5
	showNode:setScale(0.01)	
	showNode:runAction(cc.EaseExponentialOut:create(cc.ScaleTo:create(duration, 1)))

	local function close()
		if TimingMap[params.uid] then 
			if not tolua.isnull(showNode) then 				
				local function callback()
					showNode:removeFromParent()
					num[params.code] = num[params.code] - 1
					if num[params.code] == 0 then 
						num[params.code] = nil
					end
					TimingMap[params.uid] = nil
					add2TimerMap(params.code,params.referNode,params.uid)		
				end
				local endCallback = cc.CallFunc:create(callback)
				showNode:runAction(cc.Sequence:create(cc.EaseExponentialIn:create(cc.ScaleTo:create(duration, 0)), endCallback))
			end
		end
	end
	Scheduler.scheduleOnce(3,close)
	--移除出列表
	remove2TimerMap(params.uid,params.code)

	--params.referNode:getHeadwear():showTalkBubble(params.str)
	--加入正在展示列表
	TimingMap[params.uid] = true

	showNode:setPosition(referNode:getHeadwear():getPosition())

	referNode:addChild(showNode,100)
	showNode:setPositionZ(200)
end

function BubbleManager.createBubbleLoop(params)
	local paramsCreator = params.paramsCreator
	local bubbleParams = paramsCreator()
	createBubble(bubbleParams)

	local scheduleId = Scheduler.schedule(function()
		local bubbleParams = paramsCreator()
		createBubble(bubbleParams)
	end,params.loopTime or 5,0)
	return scheduleId
end

function BubbleManager.cancelBubbleLoop(scheduleId)
	Scheduler.unschedule(scheduleId)
end

function BubbleManager.clear()
	TimingMap = {}
	TimerMap = {}
	num = {}

	for k,v in pairs(schedulerIdMap) do 
		Scheduler.unschedule(v)
	end
	schedulerIdMap = {}
end

function BubbleManager.release()
	TimingMap = {}
	TimerMap = {}
	num = {}

	for k,v in pairs(schedulerIdMap) do 
		Scheduler.unschedule(v)
	end
	schedulerIdMap = {}
end

return BubbleManager