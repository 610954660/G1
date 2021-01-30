local NewbieUtil = {}

local scales = {
	cc.p(1, 1),
	cc.p(-1, -1),
	cc.p(-1, 1),
	cc.p(1, -1),
}

local poses = {
	cc.p(1, 1),
	cc.p(0, 0),
	cc.p(0, 1),
	cc.p(1, 0),
}

local poses_ex = {
	cc.p(10, 10),
	cc.p(-10, -10),
	cc.p(-10, 10),
	cc.p(10, -10),
}

local moveTos = {
	cc.p(-10, -10),
	cc.p(10, 10),
	cc.p(10, -10),
	cc.p(-10, 10),
}

local arrowPoses = {
	cc.p(1, 1),
	cc.p(1, 1),
	cc.p(1, 1),
	cc.p(0, 0.5),
	cc.p(1, 1),
	cc.p(1, 1),
	cc.p(1, 1),
	cc.p(1, 1),
	cc.p(1, 1),
}

local arrowPoses_ex = {
	cc.p(-30, 0),
	cc.p(-30, 0),
	cc.p(-30, 0),
	cc.p(-30, 0),
	cc.p(-30, 0),
	cc.p(-30, 0),
	cc.p(-30, 0),
	cc.p(-30, 0),
	cc.p(-30, 0),
}

local bgPos = {
	cc.p(-82, 0),
	cc.p(-82, 0),
	cc.p(-82, 0),
	cc.p(-82, 0),
	cc.p(-82, 0),
	cc.p(-82, 0),
	cc.p(-82, 0),
	cc.p(-82, 0),
	cc.p(-82, 0),
}

local arrowMoveTos = {
	cc.p(-10, 0),
	cc.p(-10, 0),
	cc.p(-10, 0),
	cc.p(-10, 0),
	cc.p(-10, 0),
	cc.p(-10, 0),
	cc.p(-10, 0),
	cc.p(-10, 0),
	cc.p(-10, 0),
}

local arrowScales = {
	cc.p(1, 1),
	cc.p(1, 1),
	cc.p(1, 1),
	cc.p(-1, 1),
	cc.p(1, 1),
	cc.p(1, 1),
	cc.p(1, 1),
	cc.p(1, 1),
	cc.p(1, 1),
}

local function effectBtn(btn)
	-- print(92, "effectBtn btn")
	local size = btn:getContentSize()
	for k = 1, 4 do
		local initPos = cc.p(size.width * poses[k].x, size.height *  poses[k].y)
		initPos = cc.pAdd(initPos, poses_ex[k])

		local s1 = cc.Sprite:create(ResManager.getRes(ResType.GUIDE,"s1"))
		s1:runAction(cc.RepeatForever:create(cc.Sequence:create(
				cc.MoveTo:create(0.5, cc.pAdd(moveTos[k], initPos)),
				cc.MoveTo:create(0.5, cc.pAdd(cc.p(0, 0), initPos))
			)))
		s1:setPosition(initPos)
		btn:addChild(s1, 99999)
		s1:setScale(scales[k].x, scales[k].y)
	end

	
end

function NewbieUtil.showHand(father, btn, guideStepInfo, scale9Dir, desStr)
	effectBtn(btn)
	-- local zysSpx = UI.newSpxSprite({
 --        src = ResManager.getRes("guide","zys"),
 --        -- x = __continueImg:getPositionX()-90, y = 100,
 --    })
 --    father:addChild(zysSpx, 99999)

 	local zysSpx = cc.Node:create()
 	father:addChild(zysSpx, 99999)

 	local moveNode = cc.Node:create()
 	zysSpx:addChild(moveNode)

 	local bg = cc.Sprite:create(ResManager.getRes(ResType.GUIDE,"s2"))
 	moveNode:addChild(bg)

 	local bgbg = cc.Sprite:create(ResManager.getRes(ResType.GUIDE,"s3"))
 	-- bgbg:setContentSize(cc.size(146, 45))
 	
 	-- 
 	bg:addChild(bgbg)
 
 	if scale9Dir == 4 then
 		bgbg:setScale(-1, 1)
 		bgbg:setPosition(94, 27)
 	elseif scale9Dir == 6 then
 		bgbg:setScale(1, 1)
 		bgbg:setPosition(57, 27)
 	elseif scale9Dir == 2 then
 		bgbg:setScale(0.4, 3.13)
 		bgbg:setRotation(90)
 		bgbg:setPosition(77, 29) 	
  	elseif scale9Dir == 8 then
 		bgbg:setScale(0.4, 3.13)
 		bgbg:setRotation(-90)
 		bgbg:setPosition(75, 25) 				
 	end
 	
 	bg:setPosition(bgPos[scale9Dir])

 	local arrow = cc.Sprite:create(ResManager.getRes(ResType.GUIDE,"s4"))
 	arrow:setScale(arrowScales[scale9Dir].x, arrowScales[scale9Dir].y)
 	moveNode:addChild(arrow)

 	moveNode:setPosition(arrowMoveTos[scale9Dir])
	moveNode:runAction(cc.RepeatForever:create(cc.Sequence:create(
		cc.MoveTo:create(0.5, cc.p(0, 0)),
		cc.MoveTo:create(0.5, arrowMoveTos[scale9Dir])
		
	)))

	local des = UI.newBMFontLabel({
        text = desStr,
        anchorPoint = cc.p(0.5, 0.5),
        x = 78,
        y = 25,
        style = {
            font = ResManager.getResSub(ResType.FONT, FontType.FNT, "jjk_name"),
            additionalKerning = -3
        }
    })
    bg:addChild(des)

    local size = btn:getContentSize()
    local anchor = cc.p(0, 0) or btn:getAnchorPoint()

   	-- dump(93, size, "size")

   	-- dump(93, anchor, "anchor")

   	local update = true

    local pos = father:convertToNodeSpace(btn:convertToWorldSpace(cc.p(0,0)))
    local showPos = pos

    pos = cc.pAdd(pos, cc.p(size.width * arrowPoses[scale9Dir].x, size.height* arrowPoses[scale9Dir].y))
    pos = cc.pAdd(pos, arrowPoses_ex[scale9Dir])
    zysSpx:setPosition(pos)



    
    -- zysSpx:setPosition(pos.x +  (0.5 - anchor.x) * size.width, pos.y +  (0.5 - anchor.y) * size.height)

    btn:onNodeEvent("exit", function()
    	if not tolua.isnull(zysSpx) then
			zysSpx:setVisible(false)
			update = false
		else
			update = false
		end
	end)



	btn:onUpdate(function() 
			-- print(93, "update = " .. tostring(update))
			if update then
				local pos = father:convertToNodeSpace(btn:convertToWorldSpace(cc.p(0,0)))
				if pos.x == showPos.x and pos.y == showPos.y then
					if not tolua.isnull(zysSpx) then
						zysSpx:setVisible(true)
					else
						update = false
					end
				else
					if not tolua.isnull(zysSpx) then
						zysSpx:setVisible(false)
					else
						update = false
					end				
				end
			end
		end)

    return zysSpx
end


return NewbieUtil