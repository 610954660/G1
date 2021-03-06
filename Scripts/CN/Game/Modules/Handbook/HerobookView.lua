--Name : HerobookView.lua
--Author : generated by FairyGUI
--Date : 2020-5-28
--Desc : 

local HerobookView,Super = class("HerobookView", Window)

function HerobookView:ctor()
	--LuaLog("HerobookView ctor")
	self._packName = "Handbook"
	self._compName = "HerobookView"
	self._rootDepth = LayerDepth.Window
	self.heroSpine = {}
	self.heroLH = {}

	self.heroToPage = false
	self.pageToHero = false

	self.curIndex = 0
	self.curHeroId = 0

	self.scrolling = false

	self.heroZan = {}
	
	self.lhSpine = {}
	self.lhtemp = false
	
	
	self.lhPos = 1
	self.scrollToIndex = true
	
	self.scrollStep = 1
	
	self.widthDist = 150
	self.lhScale = 0.5
	self.checkAsyncId = false
end

function HerobookView:_initEvent( )
	
end

function HerobookView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:Handbook.HerobookView
		vmRoot.jihuo = viewNode:getChildAutoType("$jihuo")--text
		vmRoot.xiangqingbt = viewNode:getChildAutoType("$xiangqingbt")--Button
		vmRoot.lh1 = viewNode:getChildAutoType("$lh1")--
		vmRoot.leftBt = viewNode:getChildAutoType("$leftBt")--Button
		local info = viewNode:getChildAutoType("$info")--
		vmRoot.info = info
			info.name = viewNode:getChildAutoType("$info/$name")--text
			info.zanicon = viewNode:getChildAutoType("$info/$zanicon")--image
			info.shoujiTxt = viewNode:getChildAutoType("$info/$shoujiTxt")--text
			info.progressBar = viewNode:getChildAutoType("$info/$progressBar")--ProgressBar
			info.cardStar = viewNode:getChildAutoType("$info/$cardStar")--
			info.barTxt = viewNode:getChildAutoType("$info/$barTxt")--text
			info.zanTxt = viewNode:getChildAutoType("$info/$zanTxt")--text
			info.img_category = viewNode:getChildAutoType("$info/$img_category")--loader
		vmRoot.jibangIcon = viewNode:getChildAutoType("$jibangIcon")--loader
		vmRoot.lh2 = viewNode:getChildAutoType("$lh2")--
		local levelCmp = viewNode:getChildAutoType("$levelCmp")--
		vmRoot.levelCmp = levelCmp
			levelCmp.levelName2 = viewNode:getChildAutoType("$levelCmp/$levelName2")--text
			levelCmp.pointNum = viewNode:getChildAutoType("$levelCmp/$pointNum")--richtext
			levelCmp.levelIcon = viewNode:getChildAutoType("$levelCmp/$levelIcon")--loader
			levelCmp.levelBar = viewNode:getChildAutoType("$levelCmp/$levelBar")--ProgressBar
			levelCmp.levelNnum = viewNode:getChildAutoType("$levelCmp/$levelNnum")--text
			levelCmp.levelName = viewNode:getChildAutoType("$levelCmp/$levelName")--text
		vmRoot.btn_help = viewNode:getChildAutoType("$btn_help")--Button
		vmRoot.heroList = viewNode:getChildAutoType("$heroList")--Label
		vmRoot.rightBt = viewNode:getChildAutoType("$rightBt")--Button
		vmRoot.labelList = viewNode:getChildAutoType("$labelList")--list
	--{vmFieldsEnd}:Handbook.HerobookView
	--Do not modify above code-------------
end


function HerobookView:_initUI( )
	self:_initVM()
	self.view:getChildAutoType("jibang"):setVisible(false)
	self:moveTitleToTop()
	self.lh1:setScale(self.lhScale,self.lhScale)
	self.lh2:setScale(self.lhScale,self.lhScale)
	self.lh1 = BindManager.bindLihuiDisplay(self.lh1)
	self.lh2 = BindManager.bindLihuiDisplay(self.lh2)
	rawset(self.lh1,"find",false)
	rawset(self.lh2,"find",false)

	rawset(self.lh1,"getWidth",function ()
			return self.widthDist
		end)
	rawset(self.lh2,"getWidth",function ()
			return self.widthDist
		end)
	
	
	self.lhSpine = {self.lh1,self.lh2}
	self.info.cardStar = BindManager.bindCardStar(self.info.cardStar)

	self.heroConfig = DynamicConfigData.t_hero
	
	self.titleConfig = DynamicConfigData.t_HeroTotemsTitleLevel

	local heroData = {14001,15001,15002,24001,24002,25001,33001,35001,35002,44001}--
	self.heroData = heroData
	
	self.heroList = self.heroList:getChildAutoType("heroList")
	self.heroList:setItemRenderer(function(index,obj)
		local heroId = self.curData[index+1].hero
		
		obj:addClickListener(function(  )
				if self.curHeroId == heroId then
					ViewManager.open("HeroInfoView",{index = index+1,heroId = heroId,heroList = self.curData })
				end
			end,33)
			
		if obj.heroId ~= heroId then

			if obj.spine then
				obj.spine.isAdd = false
				obj.spine = false
				obj.heroId = -1
				obj:getChildAutoType("icon"):displayObject():removeAllChildren()
				--print(33,"Remove spine")
			end
			
			local spineNode = self:createSprineById( heroId,obj );
				
			if spineNode then
				spineNode:setAnimation(0, "stand", true);
				spineNode:pause()
				--Scheduler.scheduleNextFrame(function()
						
					--end)

				
				--obj:getChildAutoType("icon"):setSortingOrder(22)
				spineNode.isAdd = true
				obj.spine = spineNode
				obj.heroId = heroId
				spineNode:setPosition(obj:getWidth()/2,0)
				if HandbookModel.heroData[heroId] then
					spineNode:setColor({r=255,g=255,b=255})

				else
					spineNode:setColor({r=100,g=100,b=100})
				end
				
				--local SpineTest = require "Game.Modules.Test.SpineTest"
				
				local c_spineNode = self:captureNode(spineNode)
				obj.c_spine = c_spineNode
				obj:getChildAutoType("icon"):displayObject():addChild(spineNode)
				obj:getChildAutoType("icon"):displayObject():addChild(c_spineNode)
				spineNode:setVisible(false)
			end

			
			

		else
			print(33,"nothing do")
		end

	end)
	self.heroList:setVirtualAndLoop()
	--self.heroList:setNumItems(#heroData);
	self.heroList:addEventListener(FUIEventType.Click, function(  )
		print(33,"Click heroList")
	end);
	self.heroList:addEventListener(FUIEventType.Scroll, function(  )
		self:doSpecialEffect(false);
	end);
	self.heroList:addEventListener(FUIEventType.ScrollEnd, function(  )
		self:doSpecialEffect(true);
		
	end);

	

	self.leftBt:addClickListener(function(  )
		--if not self.scrolling then
			--self.scrolling = true
			self.heroList:getScrollPane():scrollLeft(self.scrollStep,true)
		--else
			--self.scrolling = false
			--self.heroList:getScrollPane():scrollLeft(1,false)
		--end
		
	end);
	self.rightBt:addClickListener(function(  )
		--if not self.scrolling then
			--self.scrolling = true
			self.heroList:getScrollPane():scrollRight(self.scrollStep,true)
		--else
			--self.scrolling = false
			--self.heroList:getScrollPane():scrollRight(1,false)
		--end
	end);
	
	
	self.btn_help:addClickListener(function(  )
			local info={}
			info['title']=Desc.help_StrTitle10
			info['desc']=Desc.help_StrDesc10
			ViewManager.open("GetPublicHelpView",info)
		end);
	self.jibangIcon:addClickListener(function( context )
			printTable(33,"jibangIcon",self.curIndex)
			if not HandbookModel.heroTabLevel[self.curIndex] or HandbookModel.heroTabLevel[self.curIndex] < 1 then
				RollTips.show(Desc.handbook_tips2)
				return
			end
			print(33,"jbinfo true")
			local isVisi = self.view:getChildAutoType("jbinfo"):isVisible()
			 
			self.view:getChildAutoType("jbinfo"):setVisible(not isVisi)
			if not isVisi then
				self:jibangSet()
			end
			context:stopPropagation()
		end);
	self.view:addClickListener(function(  )
			print(33,"jbinfo false")
			self.view:getChildAutoType("jbinfo"):setVisible(false)
		end);

	self.xiangqingbt:addClickListener(function(  )
			local index = 1
			for i = 1, #self.curData do
				if self.curData[i].hero == self.curHeroId then
					index = i
					break
				end
			end
		ViewManager.open("HeroInfoView",{index = index,heroId = self.curHeroId,heroList = self.curData })
	end)
	
	
	self:checkAsync()
	self:initBTlist( )
	self:initUI( )
	Scheduler.scheduleNextFrame(function()
		self:doSpecialEffect(true);
	end)
	
	
	--RPCReq.HeroTotems_GetAllHeroInfo({},function(data)
		--printTable(33,"HeroTotems_GetAllHeroInfo",data)
		
	--end)
	
end

function HerobookView:checkAsync()
	if self.checkAsyncId then
		Scheduler.unschedule(self.checkAsyncId)
	end
	self.checkAsyncId = Scheduler.schedule(function()
			print(33,"getAsyncRefCountddddddd",cc.TextureCache:getInstance():getAsyncRefCount())
			if cc.TextureCache:getInstance():getAsyncRefCount() == 0  then
				local cnt = self.heroList:numChildren();
				for  i = 0,cnt-1 do
					local obj = self.heroList:getChildAt(i);
					local al = obj:getAlpha()
					obj:setAlpha(1)
					obj.c_spine:setTexture(self:captureNode(obj.spine,true))
					obj:setAlpha(al)
				end
				Scheduler.unschedule(self.checkAsyncId)
				self.checkAsyncId = false
			end
		end,0.1,0)
end

function HerobookView:jibangSet(info)
	
	printTable(33,"curData = ",self.curData)
	
	local curLevel = HandbookModel.heroTabLevel[self.curData[1].titleId] or 0
	local combatConfig = DynamicConfigData.t_combat
	local linfo = DynamicConfigData.t_HeroTotemsTeamFavor[curLevel]
	local nextExp = linfo.needFavor
	local levelValue = self.view:getChildAutoType("jbinfo/value")
	--local levelText = self.view:getChildAutoType("jbinfo/level")
	--levelText:setText("Lv."..curLevel)
	local curList = self.view:getChildAutoType("jbinfo/curAttr")
	local nextList = self.view:getChildAutoType("jbinfo/nextAttr")
	if linfo then 

		local arrInfo = linfo.attr
		
		curList:setItemRenderer(
			function(index, obj)
				local info = arrInfo[index+1]
				printTable(33,"info",info)
				local value = info.value
				local attrName = combatConfig[info.type].name
	
				local attrN = obj:getChildAutoType("txt_attrName")
				local attNum = obj:getChildAutoType("txt_cur")
				attrN:setText(attrName..": ")
				attNum:setText(value)
			end
		)
		curList:setNumItems(#arrInfo)
	else
		curList:setNumItems(0)
	end
	
	linfo = DynamicConfigData.t_HeroTotemsTeamFavor[curLevel+1]
	
	if linfo then
		nextExp = linfo.needFavor
		local arrInfo = linfo.attr
		nextList:setItemRenderer(
			function(index, obj)
				local info = arrInfo[index+1]
				printTable(33,"info",info)
				local value = info.value
				local attrName = combatConfig[info.type].name

				local attrN = obj:getChildAutoType("txt_attrName")
				local attNum = obj:getChildAutoType("txt_cur")
				attrN:setText(attrName..": ")
				attNum:setText(value)
			end
		)
		nextList:setNumItems(#arrInfo)
	else
		nextList:setNumItems(0)
	end
	
	local exp = 0
	for k,v in pairs(self.curData) do
		if HandbookModel.heroData[v.hero] then
			exp = exp + HandbookModel.heroData[v.hero].likingExp
		end
		
	end
	levelValue:setText(Desc.handbook_jbexp:format(curLevel,exp,nextExp))
	
end

function HerobookView:initUI(  )
	self:setBg("handbook_newbg.jpg")
	self.info.zanicon:addEventListener(FUIEventType.Click, function(  )
		RPCReq.HeroTotems_Support({heroCode = self.curHeroId}, function(data)
			if tolua.isnull(self.view) then return end
			Dispatcher.dispatchEvent(EventType.handbook_refresh_supportNumber,data.data)
		end)
	end,99);

	
	self.levelCmp.levelIcon:addClickListener(function(  )
		ViewManager.open("HandbookTitleView",{heroId = self.curHeroId})
	end,33)
	
	self:updateTitle()
end

function HerobookView:handbook_titleChange()
	self:updateTitle()
end

function HerobookView:handbook_pointChange()
	self:updateTitle()
end

function HerobookView:updateTitle()
	local tid = HandbookModel.title
	local config = DynamicConfigData.t_HeroTotemsTitleLevel[tid]
	local nextconfig = DynamicConfigData.t_HeroTotemsTitleLevel[tid+1]
	local name = config.name
	local needPoint = config.needPoint
	if nextconfig then
		needPoint = nextconfig.needPoint
	end
	self.levelCmp.pointNum:setText(Desc.handbook_needpoint:format(HandbookModel.data.point,needPoint) )
	self.levelCmp.levelName:setText( name )
	self.levelCmp.levelName2:setText( name )
	self.levelCmp.levelNnum:setText( config.lvShow )
	self.levelCmp.levelBar:setMax(needPoint)
	self.levelCmp.levelBar:setValue(HandbookModel.data.point)
	self.levelCmp.levelIcon:setURL(PathConfiger.getHeroTitle(ModelManager.HandbookModel.title))

	if config.lvShow =="" then
		self.levelCmp:getController("c1"):setSelectedIndex(0)
	else
		self.levelCmp:getController("c1"):setSelectedIndex(1)
	end
end


function HerobookView:initBTlist(  )
	self.data = HandbookModel.heroTabData

	for k,v in pairs(self.data) do
		local sindex = -1
		for m,n in pairs(v) do
			print(33,"n.hero sindexsindexsindexsindex = ",n.hero)
			if HandbookModel.heroData[n.hero] then
				sindex = m
				
			end
		end
		local ddnum = #v
		if ddnum > 7 then ddnum = 7 end
		local midNum = math.ceil(ddnum/2.0)
		print(33,"midNum = ",#v,midNum,v[midNum].hero,HandbookModel.heroData[v[midNum].hero],sindex)
		if not HandbookModel.heroData[v[midNum].hero] and sindex > -1 then
			local temp = v[midNum]
			v[midNum] = v[sindex]
			v[sindex] = temp
		end
	end
	
	self.curData = self.data[1]
	self.curIndex = 1
	printTable(33,"labelList ",self.data)
	self.labelList:setItemRenderer(function(index,obj)
			local raceType = index + 1
			local info = self.data[raceType]
			local num = #info
			local hadNum = HandbookModel.heroTabNum[info[1].titleId]

			obj:setTitle(info[1].name)
			obj:getChildAutoType("num"):setText("("..hadNum.."/"..num..")")
			local iconLoader = obj:getChildAutoType("iconLoader")
			if info[1].boolean == 1 then
				iconLoader:setVisible(true)
				if HandbookModel.heroTabLevel[info[1].titleId] and HandbookModel.heroTabLevel[info[1].titleId] > 0 then
					iconLoader:setURL(PathConfiger.getRaceIcon(raceType))
				else
					iconLoader:setURL(PathConfiger.getRaceIcon(raceType, true))
				end
			else
				iconLoader:setVisible(false)
			end
			
			obj:addClickListener(function()
				self.curIndex = index + 1
				self.curData = info
				self:resetHeroList(#info)
				--self:resetHeroList(#info)
				self:checkAsync()
				self.heroList:setNumItems(#info);
				self.heroList:scrollToView(0)
				if info[1].boolean == 1 then
					--self.view:getChildAutoType("jibang"):setVisible(true)
					if HandbookModel.heroTabLevel[info[1].titleId] and HandbookModel.heroTabLevel[info[1].titleId] > 0 then
						self.jihuo:setColor({r=255,g=255,b=255})
						self.jihuo:setText("Lv."..HandbookModel.heroTabLevel[info[1].titleId])
					else
						self.jihuo:setText(Desc.handbook_wjh)
						self.jihuo:setColor({r=255,g=100,b=100})		
					end
				else
					--self.view:getChildAutoType("jibang"):setVisible(false)
				end
				Scheduler.scheduleNextFrame(function()
					self:doSpecialEffect(true);
				end)
					
			end,33 )
		end)
	
	self.labelList:setNumItems(#self.data)
	self.labelList:setSelectedIndex(0)

	 
	self:resetHeroList(#self.data[1])
	self.heroList:setNumItems(#self.data[1]);
	if  self.data[1][1].boolean == 0 then
		--self.view:getChildAutoType("jibang"):setVisible(false)
	else
		self:handbook_refresh_jihuo(  )
	end
	--self.view:getChildAutoType("heroList"):setWidth(471)
end

function HerobookView:handbook_refresh_jihuo(  )
	if tolua.isnull(self.view) then return end
	if HandbookModel.heroTabLevel[self.data[1][1].titleId] and HandbookModel.heroTabLevel[self.data[1][1].titleId] > 0 then
		self.jihuo:setColor({r=255,g=255,b=255})
		self.jihuo:setText("Lv."..HandbookModel.heroTabLevel[self.data[1][1].titleId])

	else
		self.jihuo:setText(Desc.handbook_wjh)
		self.jihuo:setColor({r=255,g=100,b=100})
	end
end

function HerobookView:resetHeroList( heroNum )
	if heroNum < 5 then
		self.lhPos = 1
		self.scrollStep = 3
		self.heroList:setColumnGap(300)
		self.widthDist = 350
	elseif  heroNum < 7 then
		self.scrollStep = 1
		self.lhPos = 2
		self.heroList:setColumnGap(75)
		self.widthDist = 210
	else
		self.scrollStep = 1
		self.lhPos = 3
		self.heroList:setColumnGap(0)
		self.widthDist = 150
	end
end
	
function HerobookView:createLHById( id,obj )
	--if self.heroLH[id] and not self.heroLH[id].isAdd then
		--return self.heroLH[id]
	--end
	local path,name = PathConfiger.getHeroDraw(id)
	print(33,"createLHById = ",path)
	local skeletonNode=SpineMnange.createByPath(path,name)

	if not skeletonNode  then return  end
	
	--self.heroLH[id] = skeletonNode
	--skeletonNode:retain()
	return skeletonNode
end

function HerobookView:createSprineById( id,obj )
	if self.heroSpine[id] and not self.heroSpine[id].isAdd then
		return self.heroSpine[id]
	end
	if not self.checkAsyncId then
		cc.TextureCache:getInstance():setSpineUseAsyncType(2)
	end
	local skeletonNode=SpineMnange.createSprineById(id,true)
	if not self.checkAsyncId then
		cc.TextureCache:getInstance():setSpineUseAsyncType(0)
	end
	if not skeletonNode  then return  end
	
	--self.heroSpine[id] = skeletonNode
	--skeletonNode:retain()
	return skeletonNode
end

function HerobookView:doSpecialEffect( isEnd )
	if tolua.isnull(self.heroList) then return end
	local  midX = self.heroList:getScrollPane():getPosX() + self.heroList:getViewWidth() / 2;
    local cnt = self.heroList:numChildren();
	local offestY = 300
	print(33,"doSpecialEffect*******************begin")
	local lhObjTable = {}
    for  i = 0,cnt-1 do 
        local obj = self.heroList:getChildAt(i);
        local t_dist = midX - obj:getX() - obj:getWidth() / 2;
		local dist = math.abs(t_dist);
		--local pos = obj:localToGlobal(Vector2.zero)
		local t_xxx = 130.0*t_dist / 800
		if t_xxx > 24 then
			t_xxx = t_xxx - 70
		elseif t_xxx < -24 then
			t_xxx = 70+ t_xxx
		elseif t_xxx > 0 then
			t_xxx = -t_xxx/24.0 * 37.5
		elseif t_xxx < 0 then
			t_xxx = -t_xxx/24.0 * 37.5
		end
		obj:getChildAutoType("icon"):setPosition(t_xxx, 550-math.abs(math.cos((1.0*dist / 800))*offestY-offestY));
		obj.dist = dist
		obj.midX = midX
		obj:setAlpha(math.abs(math.cos((1.0*dist / 800)))*3-2)
		local ss = (1-math.abs((1.0*dist / 800)))*1.5
		print(33,i,"offestY ->",550-math.abs(math.cos((1.0*dist / 800))*offestY-offestY),ss)
        if dist > obj:getWidth()-2 then --no intersection
		   --local ss = 0.3 + (1-dist / midX) * 0.5;
		   obj:getChildAutoType("icon"):setScale(ss, ss);
		   obj:getChildAutoType("bg1"):setScale(ss-0.2, ss-0.2);
		   obj:getChildAutoType("bg2"):setScale(ss, ss);
		--elseif dist > obj:getWidth()/2 then --no intersection
			if isEnd and obj.spine then
				--obj.spine:clearTrack()
				obj.spine:pause()
				obj.spine:setVisible(false)
				obj.c_spine:setVisible(true)
				if obj:getController("c1"):getSelectedIndex() == 0 then
					local al = obj:getAlpha()
					obj:setAlpha(1)
					obj.c_spine:setTexture(self:captureNode(obj.spine,true))
					obj:setAlpha(al)
				end
				obj:getController("c1"):setSelectedIndex(1)
			end
		else
			
			local index = self.heroList:childIndexToItemIndex(i)
			--self.curIndex = index
			--local ss = 0.8 + (1 - dist / obj:getWidth()) * 0.5;
			obj:getChildAutoType("icon"):setScale(ss, ss);
			obj:getChildAutoType("bg1"):setScale(ss-0.2, ss-0.2);
			obj:getChildAutoType("bg2"):setScale(ss, ss);
			if isEnd and obj.spine then
				if dist > obj:getWidth()/2  then
					obj.spine:pause()
					obj.spine:setVisible(false)
					obj.c_spine:setVisible(true)
					if obj:getController("c1"):getSelectedIndex() == 0 then
						local al = obj:getAlpha()
						obj:setAlpha(1)
						obj.c_spine:setTexture(self:captureNode(obj.spine,true))
						obj:setAlpha(al)
					end
					obj:getController("c1"):setSelectedIndex(1)
				else
					obj:getController("c1"):setSelectedIndex(0)
					self.curHeroId = obj.heroId
					obj.spine:setVisible(true)
					obj.c_spine:setVisible(false)
					obj.spine:resume();
					local heroConfig = self.heroConfig[obj.heroId]
					self.info.cardStar:setData(heroConfig.heroStar)
					self.info.name:setText(heroConfig.heroName)
					local icons = PathConfiger.getCardProfessional64(heroConfig.professional)
					self.info.img_category:setURL(icons)
					self.scrolling = false
					
					
					HandbookModel:getHeroSupportInfo(self.curHeroId,function (data)
						if tolua.isnull(self.view) then return end
						self.info.zanTxt:setText(data.supportNumber)
						local day = TimeLib.getDay(data.supportTime)
						local curDay = TimeLib.getDay(ServerTimeModel:getServerTimeMS())
						if data.supportTime >0 and day == curDay then
							self.info.zanicon:setGrayed(false)
						else
							self.info.zanicon:setGrayed(true)
						end
					end)
					
					local hcf = HandbookModel.heroData[self.curHeroId]
					if hcf then
						local nextNeed = DynamicConfigData.t_HeroTotemsHeroFavor[hcf.likingLevel+1]
						if not nextNeed then
							nextNeed = DynamicConfigData.t_HeroTotemsHeroFavor[hcf.likingLevel]
						end
						local curFavor = hcf.likingExp
						if curFavor > nextNeed.needFavor then
							curFavor = nextNeed.needFavor
						end
						self.info.progressBar:setMax(nextNeed.needFavor)
						self.info.progressBar:setValue(curFavor)
						self.info.barTxt:setText("")
						self.info.shoujiTxt:setText(hcf.likingLevel)
					else
						self.info.progressBar:setMax(1)
						self.info.progressBar:setValue(0)
						self.info.progressBar:getChildAutoType("title"):setText(Desc.handbook_noget)
						self.info.shoujiTxt:setText(0)
					end
				end
				
				print(33,"doSpecialEffect = ",index)

			end
		end

		if dist < self.widthDist then
			if i== self.lhPos or i== self.lhPos+1 then
				lhObjTable[obj.heroId] = obj
			end
		end
    end

	self:setLHspine(lhObjTable)
end

function HerobookView:setLHspine( t,dist,midX )

	printTable(33,"setLHspine -------------------",t)
	for k,v in pairs(t) do
		v.find = false
	end
	
	for m,n in pairs(self.lhSpine) do
		n.find = false
		n:setVisible(false);
		print(33,"n.herid",n.heroId)
	end
	
	local initHero = {}
	
	for k,v in pairs(t) do
		for m,n in pairs(self.lhSpine) do
			if v.heroId == n.heroId then
				initHero[v.heroId] = true
				local pos = v:localToGlobal(Vector2.zero)
				n:setPosition(pos.x-self.view:getPosition().x-220+75,pos.y-160)
				if v.dist > n:getWidth()-2 then
					n:setVisible(false);
				else
					n:setVisible(true);
					n:setAlpha((1 - v.dist / n:getWidth()));
				end
				print(33,"findfindfindfindfindfindfindfindfindfindfindfindfindfindfind",n)
				n.find = true
				v.find = true
				break
			end
		end
	end
	
	for k,v in pairs(t) do
		if not v.find then
			for m,n in pairs(self.lhSpine) do
				if not n.find then
					if initHero[v.heroId] then
						n:setVisible(false);
						print(33,"n:setVisible(false) n:setVisible(false) n:setVisible(false)")
						break
					end
					--n:displayObject():removeAllChildren()
					
					--local spineNode = self:createLHById( v.heroId );
					--if spineNode then
						--n:displayObject():addChild(spineNode)
						--spineNode:setPosition(n:getWidth()/2,0)
						--spineNode:setScale(0.5)
						--spineNode:setAnimation(0, "animation", false);
						--spineNode:pause()
						--if HandbookModel.heroData[v.heroId] then
							--spineNode:setColor({r=255,g=255,b=255})
						--else
							--spineNode:setColor({r=100,g=100,b=100})
						--end
						
					--end
					n:setData(v.heroId)
					n:pause()
					print(33,"setData(v.heroId)setData(v.heroId)",v.heroId,n)
					if HandbookModel.heroData[v.heroId] then
						n:setColor({r=255,g=255,b=255})
					else
						n:setColor({r=100,g=100,b=100})
					end
					
					
					local pos = v:localToGlobal(Vector2.zero)
					n:setPosition(pos.x-self.view:getPosition().x-220+75 ,pos.y-160)
					if v.dist > n:getWidth()-2 then
						n:setVisible(false);
					else
						n:setVisible(true);
						n:setAlpha((1 - v.dist / n:getWidth()));
					end
					
					n.find = true
					v.find = true
					break
				end
			end
		end
	end

end

function HerobookView:handbook_refresh_supportNumber(_,data )
	self.info.zanTxt:setText(data.supportNumber)
	local day = TimeLib.getDay(data.supportTime)
	local curDay = TimeLib.getDay(ServerTimeModel:getServerTimeMS())
	if data.supportTime >0 and day == curDay then
		self.info.zanicon:setGrayed(false)
	else
		self.info.zanicon:setGrayed(true)
	end
end


function HerobookView:HeroTotems_UpdateLiking(_,data )

	local hcf = data.hero
	
	if hcf then
		HandbookModel.heroData[hcf.heroCode] = hcf
		local nextNeed = DynamicConfigData.t_HeroTotemsHeroFavor[hcf.likingLevel+1]
		if not nextNeed then
			nextNeed = DynamicConfigData.t_HeroTotemsHeroFavor[hcf.likingLevel]
		end
		local curFavor = hcf.likingExp
		if curFavor > nextNeed.needFavor then
			curFavor = nextNeed.needFavor
		end
		if self.info and not tolua.isnull(self.info.progressBar) then
			self.info.progressBar:setMax(nextNeed.needFavor)
			self.info.progressBar:setValue(curFavor)
			self.info.barTxt:setText("")
			self.info.shoujiTxt:setText(hcf.likingLevel)
		end
	end
	
end

function HerobookView:captureNode(node,tex)

	local size = cc.size(400,400)
	local ss_canvas = cc.RenderTexture:create(size.width,size.height)
	local isVis = node:isVisible()
	local alpha = node:getOpacity()
	node:setOpacity(255)
	node:setVisible(true)
	local posx,posy = node:getPosition()
	ss_canvas:beginWithClear(0,0,0,0)
	--canvas:begin()

	node:setPosition(size.width/2,50)
	node:visit()

	ss_canvas:endToLua()

	node:setPosition(posx,posy)

	
	node:setOpacity(alpha)
	node:setVisible(isVis)
	if tex then
		return ss_canvas:getSprite():getTexture()
	end
	local c_Node = cc.Sprite:createWithTexture(ss_canvas:getSprite():getTexture())
	--c_Node:setAnchorPoint(0.5,0)
	c_Node:setFlippedY(true);
	c_Node:setPosition(posx, posy+size.height/2-50)
	return c_Node
end

function HerobookView:_exit()
	if self.checkAsyncId then
		Scheduler.unschedule(self.checkAsyncId)
	end
end

return HerobookView