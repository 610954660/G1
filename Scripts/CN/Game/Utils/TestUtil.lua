local TestUtil = {}
local guideId = false
function TestUtil:startGuide()
	if guideId then
		Scheduler.unschedule(guideId) 
		guideId = false
		return
	end
	local guideView = false
	local gWindow = false
	local width = 1
	local height = 1
	local x = 1
	local y = 1
	local director = cc.Director:getInstance()
	local isBegin = false

	guideId = Scheduler.schedule(function ()
			local guideSetNameView = ViewManager.getView("GuideSetNameView")
			local randId = math.random(1,3)
			if guideSetNameView then
				isBegin = true
				local sss = {"btn_sure","btn_random"}
				local r = math.random(1,2)
				width = guideSetNameView.view:getChildAutoType(sss[r]):getWidth()
				height = guideSetNameView.view:getChildAutoType(sss[r]):getWidth()
				
				local pos = guideSetNameView.view:getChildAutoType(sss[r]):localToGlobal(cc.p(0,0))
				x = pos.x * display.sizeInPixels.width/display.width
				y = pos.y * display.sizeInPixels.height/display.height
			elseif randId == 1 and not tolua.isnull(gWindow) and guideView.GuideType2View:isVisible() then
				width = gWindow:getWidth()
				height = gWindow:getHeight()
				printTable(33,gWindow:getPosition())
				local pos = gWindow:localToGlobal(cc.p(0,0))
				x = pos.x * display.sizeInPixels.width/display.width
				y = pos.y * display.sizeInPixels.height/display.height
			else
				guideView = ViewManager.getView("GuideView")
				if guideView then
					gWindow = guideView.GuideType2View.window
				elseif isBegin then
					Scheduler.scheduleNextFrame(function()
							Scheduler.unschedule(guideId) 
					end)
				end
				print(33,"gWindow",gWindow)
				width = display.sizeInPixels.width
				height = display.sizeInPixels.height
				x = 1
				y = 1
				
			end
			
			local touchX = math.random(x,x+width)
			local touchY = math.random(y,y+height)
			
			print(33,x,y,width,height,touchX,touchY)
			director:handleTouchesBegin(1,touchX,touchY)
			director:handleTouchesEnd(1,touchX,touchY)
			
	end,0.5,0)
end

return TestUtil