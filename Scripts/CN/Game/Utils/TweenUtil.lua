--模拟flash的tween类

module("TweenUtil", package.seeall)


local tweenList={}

local unitIndex =1
function getUnitIndex()
	unitIndex = unitIndex + 1
	return unitIndex
end
function to(target,arg)
	local curPos = target:getPosition()
	local targetPos = {x=arg.x,y=arg.y} 
	local tween1 = fgui.GTween:to(curPos,targetPos,arg.time)
	if(arg.ease) then
		tween1:setEase(arg.ease)
	end
	tween1:onUpdate(function(tweener)
			if tolua.isnull(target) then
				return
			end
			local info = tweener:getDeltaValue():getVec2()
			target:setPosition(info.x,info.y)
			
			if arg.onUpdate ~= nil then
				arg.onUpdate()
			end
		end
	)
	
	tween1:onComplete(function(tweener)
			if arg.onComplete ~= nil then
				arg.onComplete()
			end
		end
	)
	return tween1
end

function to2(target,arg)
	local curPos = target:getPosition()
	local targetPos = {x=arg.x,y=arg.y} 
	local tween1 = fgui.GTween:to(curPos,targetPos,arg.time)
	if(arg.ease) then
		tween1:setEase(arg.ease)
	end
	tween1:onUpdate(function(tweener)
			if tolua.isnull(target) then
				return
			end
			local info = tweener:getDeltaValue():getVec2()
			target:setPosition(info.x,info.y)
			
			if arg.onUpdate ~= nil then
				arg.onUpdate()
			end
		end
		
	)
	
	tween1:onComplete(function(tweener)
			if arg.onComplete ~= nil then
				arg.onComplete()
			end
		end
	)
end


function moveTo(target,arg)
	local curPos = arg.from
	local targetPos = arg.to
	local tween1 = fgui.GTween:to(curPos,targetPos,arg.time)
	if arg.tweenType then
		tween1.tweenType=arg.tweenType
	end
	
	local tweenIndex=getUnitIndex()
	
	printTable(1,tween1,"creator moveTo ")
	
	if(arg.ease) then
		tween1:setEase(arg.ease)
	end
	tween1:onUpdate(function(tweener)
			if tolua.isnull(target) then
				return
			end
			local info = tweener:getDeltaValue():getVec2()
			--print(0934,tween1,"tween1 onUpdate")
			target:setPosition(info.x,info.y)

			if arg.onUpdate then
				arg.onUpdate(info.x,info.y)
			end
		end

	)
	tween1:onComplete(function(tweener)
			if arg.onComplete ~= nil then
				arg.onComplete()
				tweenList[tweenIndex] = nil
			end
		end
	)

	tweenList[tweenIndex] = tween1
	return tween1
end

function scaleTo(target,arg)
	local curPos = arg.from
	local targetPos = arg.to
	local tweenIndex=getUnitIndex()
	local tween1 = fgui.GTween:to(curPos,targetPos,arg.time)
	local tweenIndex=table.getn(tweenList)+1
	if(arg.ease) then
		tween1:setEase(arg.ease)
	end
	printTable(0934,tween1,"creator scaleTo ")
	tween1:onUpdate(function(tweener)
			if tolua.isnull(target) then
				return
			end
			local info = tweener:getDeltaValue():getVec2()
			target:setScale(info.x,info.y)

			if arg.onUpdate ~= nil then
				arg.onUpdate()
			end
		end

	)
	tween1:onComplete(function(tweener)
			tweenList[tweenIndex] = nil
			if arg.onComplete ~= nil then
				arg.onComplete()
				tweenList[tweenIndex] = nil
			end
		end
	)

	tweenList[tweenIndex] = tween1
end

function toDouble(target,arg)
	local from = arg.from
	local to = arg.to
	local tween1 = fgui.GTween:toDouble(from,to,arg.time)
	if(arg.ease) then
		tween1:setEase(arg.ease)
	end
	tween1:onUpdate(function(tweener)
			if tolua.isnull(target) then
				return
			end
			if arg.onUpdate ~= nil then
				arg.onUpdate(tweener:getDeltaValue():getD())
			end	
	end)
	tween1:onComplete(function ()
			if arg.onComplete ~= nil then
				arg.onComplete()
			end
	end)
end


function alphaTo(target,arg)
	local from = arg.from
	local to = arg.to
	local tween1 = fgui.GTween:toDouble(from,to,arg.time)
	if(arg.ease) then
		tween1:setEase(arg.ease)
	end
	tween1:onUpdate(function(tweener)
			if tolua.isnull(target) then
				return
			end
			target:setAlpha(tweener:getDeltaValue():getD())

			if arg.onUpdate ~= nil then
				arg.onUpdate()
			end
		end

	)
	tween1:onComplete(function(tweener)
			if arg.onComplete ~= nil then
				arg.onComplete()
			end
		end
	)
	return tween1
end



function clearTween(TweenId)
	if  TweenId then
		TweenId:kill();
		TweenId = nil
   end
end

function clearAllTween(tweenType)
	print(096,"TweenId.tweenType",tweenType)
	printTable(096,tweenList)
	for i, TweenId in pairs(tweenList) do
		print(096,TweenId.tweenType,"TweenId.tweenType")
		if TweenId and TweenId.tweenType==tweenType then
		--	print(1,TweenId.tweenType)
			TweenId:kill()
			tweenList[i] = nil
		--	printTable(1,"移除TweenId",TweenId,i)
		end
	end
end


