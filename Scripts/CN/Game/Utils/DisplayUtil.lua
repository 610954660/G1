local DisplayUtil = {}
local poetryTimer = false
local poetryImg = nil

--[[
获取一个cc.Node及子类的全局显示区域
@param	node	[cc.Node及其子类]	显示对象
@return [cc.rect]	全局矩形区域
]]
function DisplayUtil.getNodeGRect(node)
	if not node then
		return cc.rect(0,0,0,0)
	end
	
	local point = node:convertToWorldSpaceAR(cc.p(0,0))
	
	local anchorPoint, w, h = node:getAnchorPoint(), math.abs(node:getContentSize().width*node:getScaleX()), math.abs(node:getContentSize().height*node:getScaleY())
	point.x = point.x - w * anchorPoint.x
	point.y = point.y - h * anchorPoint.y
	
	return cc.rect(point.x, point.y, w, h)
end


--[[
@param #number		x				x坐标
@param #number 		y				y坐标
@param #number		width			宽度
@param #number		height			高度
@param #ccui.Widget 	parent			父组件
@param #number		tag				组件的标签
@param #string		name			组件的名字
@param #number		opacity			设置透明度0-255
@param #boolean		enabled 		是否启用
@param #boolean 	visible 		是否显示
@param #boolean 	touchEnabled	是否接收touch事件
@param #number		zOrder 			深度排序值
@param #CCPoint		anchorPoint		锚点坐标
@param #number		scaleX			X方向缩放比例
@param #number		scaleY			Y方向缩放比例
@param #number		scale			整体缩放比例
@param #number		rotationX		X方向旋转角度
@param #number		rotationY		Y方向旋转角度
@param #number		rotation		整体旋转角度
]]
function DisplayUtil.fillWidgetParams(widget,params)
	if params == nil then
		return
	end
	if tolua.cast(widget,"ccui.Widget") == nil or type(params) ~= "table" then	
		error("参数类型不匹配")
		--[[error("Parameter type do not match")--]]
	end
	local p = params
	local x,y = p.x or 0,p.y or 0
	widget:setPosition(ccp(x,y))				--设置坐标
	
	if p.width ~= nil and p.height ~= nil then		--设置大小
		widget:setSize(p.width,p.height)
	end
	
	if p.parent ~= nil then							--设置父组件
		p.parent:addChild(widget)
	end
	
	if p.tag ~= nil then
		widget:setTag(p.tag)						--设置标签
	end
	
	if p.name ~= nil then							--设置组件名字
		widget:setName(p.name)
	end
	
	if p.opacity ~= nil then						--设置透明度
		widget:setOpacity(p.opacity)
	end
	
	if p.enabled ~= nil then						--设置是否启用
		widget:setEnabled(p.enabled)
	end
	
	if p.visible ~= nil then						--设置是否显示
		widget:setVisible(p.visible)
	end
	
	if p.touchEnabled ~= nil then					--设置是否接收touch事件
		widget:setTouchEnabled(p.touchEnabled)
	end
	
	if p.zOrder ~= nil then							--深度排序值
		widget:setZOrder(p.zOrder)
	end
	
	if p.anchorPoint ~= nil then					--设置锚点坐标
		widget:setAnchorPoint(p.anchorPoint)
	end
	
	if p.scaleX ~= nil then							--设置X方向缩放比例
		widget:setScaleX(p.scaleX)
	end
	
	if p.scaleY ~= nil then							--设置Y方向缩放比例
		widget:setScaleY(p.scaleY)
	end
	
	if p.scale ~= nil then							--设置整体缩放比例
		widget:setScale(p.scale)
	end
	
	if p.rotationX ~= nil then						--设置X方向旋转角度
		widget:setRotationX(p.rotationX)
	end
	
	if p.rotationY ~= nil then						--设置Y方向旋转角度
		widget:setRotationY(p.rotationY)
	end
	
	if p.rotation ~= nil then						--整体旋转角度
		widget:setRotation(p.rotation)
	end
	
	if not __IS_RELEASE__ then
		local canUseAttr = {"x","y","height","width","scaleX","parent","name","opacity","enabled","visible","touchEnabled","zOrder","anchorPoint","scaleX","scaleY","scale","rotationX","rotationY","rotation"}
		for nameInParam,value in pairs(p) do
			for _,nameInList in pairs(canUseAttr) do
				if string.lower(nameInParam) == string.lower(nameInList) and nameInParam ~= nameInList then
					print("warning : 兄台，是不是属性名打错了？ ", nameInParam)
				end
			end
		
		end
	end
end

--[[
	显示任务诗歌
	@param poetry 显示内容
--]]
function DisplayUtil.createPoetryText(poetry)
	--设置参数
	local fontSize = 19         --诗歌字体大小
	local wordSpeed = 0.2		--展开显示时每个字的展开时间
	local leading = 5			--行距
	local delayTime = 0			--诗歌展开后停留时间
	local fadeOutTime = 4		--诗歌淡出时间
	
	--初始化组件
	local labelNodes = {}		--褶皱组件
	local labels = {}			--文本组件
	
	--控制参数
	local rowShow = 1			--当前展开的列数
	local heightShow = 0		--当前展开的高度
	local labelHeights = {}		--每列诗歌的高度
	local stepHeight = (fontSize + leading)*refreshTime*2/wordSpeed --每次刷新增加的显示高度
	
	
	--删除生成的组件
	local function onComplete()
		for _, label in ipairs(labels) do
			label:removeFromParent(true)
		end
		for _, labelNode in ipairs(labelNodes) do
			labelNode:removeFromParent(true)
		end
		poetryTimer = false
	end
	
	--显示效果
	local function roll()
		while labels[rowShow] do
			if heightShow >= labelHeights[rowShow] then
				rowShow = rowShow + 1
				heightShow = 0
			else
				heightShow = heightShow + stepHeight
				heightShow = math.min(heightShow, labelHeights[rowShow])
				labelNodes[rowShow]:setViewSize(cc.size(fontSize+10,heightShow))
				break
			end
		end
		--展示完后加入停留时间和淡出效果
		if rowShow == #labels and heightShow == labelHeights[rowShow] then
			for _, label in ipairs(labels) do
				local fadeOut = cc.FadeOut:create(fadeOutTime) 
				local delay = cc.DelayTime:create(delayTime)	
				local array = CCArray:create()
				array:addObject(delay)
				array:addObject(cc.EaseSineOut:create(fadeOut))
				local callBack = cc.CallFunc:create(onComplete)
				array:addObject(callBack)
				local seq = cc.Sequence:create(array)
				label:runAction(seq)
			end		
		end
	end
	
	--遍历poetry，每行诗歌用一个RichText显示
	for k, lineContent in pairs(string.split(poetry,"|")) do
	
		--遍历每行的文字，每个文字后插入换行符
		local arr = MutableString:create(lineContent):splitWord()
		local tbl = {}
		local count = arr:count()
		for i=0,count-1 do
			local ccObj = arr:objectAtIndex(i)
			-- local word = tolua.cast(ccObj,"CCString"):getCString()
			--3.0 不使用CCString,在Array中的数据已经是lua的string类型
			local word = ccObj
			tbl[i+1] = word
		end

		--设置文本内容
		local text = table.concat(tbl, "\n")
	
		local label = UI.newArtLabel({
    		text=text,
    		type=UI.PLOT_VERSE,
    		anchorPoint = ccp(0,0.5),
		})
		--记录文本高度（由于FRScissor目前锚点只能为中心，而诗歌效果是只向下展开，所以高度乘以2）
		labelHeights[k] = (fontSize+leading)*count*2
		label:setPosition(0, -labelHeights[k]/4)
		labels[k] = label

		
		--每个lable作为FRScissor的子节点实现褶皱显示效果
		local labelNode = FRScissor:create(cc.size(fontSize+10, 0))
		labelNode:setAnchorPoint(UI.POINT_CENTER_BOTTOM)
		labelNode:setPosition(Display.screenWidth - k*(rowSpace+fontSize) - 135, Display.screenHeight/2 + 175)
		labelNodes[k] = labelNode
		labelNode:addChild(label) 
		LayerManager.addTopLayer(labelNode)
	end
	--获取显示区域总高度
	local totalHeight = 0
	for _, labelHeight in ipairs(labelHeights) do
		totalHeight = totalHeight + labelHeight
	end
	--计算需要调用roll函数的次数,每一列多加一次补偿小数精度问题
	local stepNum = math.ceil(totalHeight/stepHeight) + #labels
	--通过每隔refreshTime调用roll展开诗歌
	poetryTimer = Scheduler.schedule(roll, refreshTime , false, stepNum)
end


--进入场景诗句
function DisplayUtil.createScenePoetry(mapId)
	if not tolua.isnull(poetryImg) then
		poetryImg:removeFromParent()
	end

	local res = ResManager.getRes(ResType.MAIN_UI, "scene_poetry_"..mapId)
	if type(res) == "string" and res ~= "" then
		poetryImg = Display.newSprite(res, 256, Display.height-124)
		poetryImg:setAnchorPoint(UI.POINT_LEFT_TOP)
		poetryImg:setOpacity(0)
		LayerManager.addMainUILayer(poetryImg)

		local function callBack()
			poetryImg:removeFromParent(true)
			poetryImg = nil
		end
		
		local action = cc.Sequence:create({
			cc.EaseSineOut:create(cc.FadeIn:create(1.5)),
			cc.DelayTime:create(3.0),
			cc.EaseSineIn:create(cc.FadeOut:create(1.5)),
			cc.CallFunc:create(callBack)
		})
		poetryImg:runAction(action)
	end
end

-- 生成一个数字的长度
function DisplayUtil.getNumberLength(value)
	if value < 0 then
		value = math.abs(value)
	end
	local minE = 10
	local i = 1
	while math.floor(value/minE) > 0 do
		minE = minE*10
		i = i + 1
	end
	return i
end


--[[
	创建弧线动作
	@startPoint         起点
	@endPoint           终点
	@controlPointS      起点控制点
	@controlPointE      终点控制点
	@duration           运动时间
--]]
function DisplayUtil.createArcMove(startPoint,endPoint,controlPointS,controlPointE,duration)
	--初始位置
	local initPlace = cc.Place:create(startPoint)
	--曲线运动
	local bezier = frBezierConfig(endPoint,controlPointS,controlPointE)
	local bezierAction = cc.BezierTo:create(duration,bezier)

	return cc.Sequence:createWithTwoActions(initPlace,bezierAction)
end
--截屏
local fileUtils = cc.FileUtils:getInstance()

function DisplayUtil.captureScreen(callback ,rect,pathName)
	pathName = pathName or "temp.jpg"
	local fileUtils = cc.FileUtils:getInstance()
	local absolutePath = fileUtils:getWritablePath()..pathName
	print(absolutePath)
	if cc.utils.captureScreenEx~=nil then 
		cc.utils:captureScreenEx(function (isSucceed,name)
			if type(callback)=="function" then
				callback(isSucceed,name)
			end
		end,
		absolutePath,rect.x,rect.y,rect.width,rect.height)
	else 
		cc.utils:captureScreen(function (isSucceed,name)
			if type(callback)=="function" then
				callback(isSucceed,name)
			end 
		end,
		absolutePath)
	end 
	
end

function DisplayUtil.captureNode(node)
	
	local size = node:getContentSize()
	--local size = cc.size(contentSize.width,contentSize.height)
	local ss_canvas = cc.RenderTexture:create(size.width,size.height,cc.TEXTURE2_D_PIXEL_FORMAT_RG_B888)

	local posx,posy = node:getPosition()
	ss_canvas:beginWithClear(0,0,0,0)
	--canvas:begin()

	node:setPosition(size.width/2,0)
	node:visit()

	ss_canvas:endToLua()

	node:setPosition(posx,posy)

	local c_Node = cc.Sprite:createWithTexture(ss_canvas:getSprite():getTexture())
	--c_Node:setAnchorPoint(0.5,0)
	c_Node:setFlippedY(true);
	return c_Node
end

return DisplayUtil