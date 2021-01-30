--示测试页
local GMCheckDataView,Super = class("GMSendMsgView", Window)
function GMCheckDataView:ctor()
	LuaLogE("GMCheckDataView ctor")
	self._packName = "GM"
	self._compName = "GMCheckDataView"
	self.msgNameText = ""
	self.infoTable= {}
	self.textList = false
	
	self.lastIput1 = {}
	self.lastIput2 = {}
	self.isG = false
	self.searText = false
end
function GMCheckDataView.loadComponent(_,comp)
	print(33,"GMCheckDataView.loadComponent",comp)
	local view = GMCheckDataView.new()

	view.view = comp
	view:__toInit()
	return view
end

function GMCheckDataView:_initUI()
	
	self:readLastInput1()
	self:readLastInput2()
	
	local textCmp = self.view:getChildAutoType("text")
	local text = textCmp:getChildAutoType("text")
	
	text.logText = function(tt,str)
		if str == "" then
			textCmp:setOpaque(false)
		else
			textCmp:setOpaque(true)
		end
		text:setText(str)
	end

	self.logText = text
	
	local function GMLog(str)
		text:logText(str)
	end
	rawset(_G,"GMLog",GMLog)
	
	
	local edittext1 = self.view:getChildAutoType("edittext1")
	local edittext2 = self.view:getChildAutoType("edittext2")
	--self.textList = self.view:getChildAutoType("textList")
	self.textList = self.view:getChildAutoType("tree")
	
	local check1 = self.view:getChildAutoType("check1")
	check1:addClickListener(function()
			text:logText("")
			self.textList:setVisible(false)
			local inputText = edittext1:getText()
			local listParam = self:split(inputText, ".")
			printTable(33,"check1 ",listParam)
			local value = "no find"
			if inputText == "_G" then
				self.isG = true
			end
			if type(listParam) == "table" then
				for i = 1, #listParam do
					if i==1 then
						value = rawget(_G,listParam[i])
					else
						value = value[listParam[i]]
					end
					if not value then RollTips.show("no find:"..inputText) return end
				end
			else
				value = rawget(_G,listParam)
			end
			if value then
				local data = GMModel:getData(value,13,false,self.searText)
				if type(data) == "table" then
					self:initList(data);
				else
					text:logText(data)
				end
				
				if self.lastIput1[1] ~= inputText then
					table.insert(self.lastIput1,1,inputText)
					if #self.lastIput1 > 20 then
						self.lastIput1[21] = nil
					end
					self:saveLastInput1()
					self.comb1:setItems(self.lastIput1)
					self.comb1:refresh()
				end
				
				--printTable(33,"lastIput1 = ",self.lastIput1)
			else
				RollTips.show("no find:"..edittext1:getText())
			end
		end)
	
	 
	local check2 = self.view:getChildAutoType("check2")
	check2:addClickListener(function()
			text:logText("")
			self.textList:setVisible(false)
			print(33,"check2 ",edittext2:getText())
			local f = loadstring(edittext2:getText())
			local value = f()
			if value then
				local data = GMModel:getData(value,13,true,self.searText)
				if type(data) == "table" then
					self:initList(data);
				elseif data then
					text:logText(data)
				end
				
				
				if self.lastIput2[1] ~= edittext2:getText() then
					table.insert(self.lastIput2,1,edittext2:getText())
					if #self.lastIput2 > 20 then
						self.lastIput2[21] = nil
					end
					self:saveLastInput2()
					self.comb2:setItems(self.lastIput2)
					self.comb2:refresh()
				end
				
			end
		end)
	
	local clear = self.view:getChildAutoType("clear")
	clear:addClickListener(function()
			text:logText("")
			
			self.textList:getRootNode():removeChildren()
			self.textList:setVisible(false)
		end)
	
	self.comb1 = self.view:getChildAutoType("$comb1")
	self.comb2 = self.view:getChildAutoType("$comb2")
	self.gnlist = self.view:getChildAutoType("$gnlist")
	local seartext = self.view:getChildAutoType("seartext")
	
	self.comb1:setItems(self.lastIput1)
	self.comb2:setItems(self.lastIput2)
	--self.comb1:setValues(self.lastIput1)
	--self.comb1:setItems(self.lastIput1)
	--self.comb2:setItems(self.lastIput2)
	
	self.comb1:addEventListener(FUIEventType.Changed,function(data)
			edittext1:setText(self.comb1:getTitle())
		end)
	
	self.comb2:addEventListener(FUIEventType.Changed,function(data)
			edittext2:setText(self.comb2:getTitle())
		end)
	
	
	
	self.gnlist:setItemRenderer(function(index,obj)
			obj:removeClickListener(88)
			obj:addClickListener(function()
					self:clickGNItem(index,obj)
				end)
		end)
	self.gnlist:setNumItems(6)
	
	seartext:onChanged(function (str)
			if seartext:getText() == "" then
				self.searText = false
			else
				self.searText = seartext:getText()
			end
		end)
end
 
function GMCheckDataView:clickGNItem( index,obj )
	local title = obj:getTitle()
	self.textList:getRootNode():removeChildren()
	self.textList:setVisible(false)
	if title == "Model" then
		self:initList(GMModel:getData(ModelManager,8,false,self.searText));
	elseif title == "View" then
		
		--for k,v in pairs(ViewManager.getOpeningViews()) do
			--local index = ViewManager.getParentLayer(v.window._rootDepth):getChildIndex(v.window.view)
			--v.window._childIndex = index
			--v.window._localZOrder = v.window.view:displayObject():getLocalZOrder()
			--print(33,"|-------------internalVisible = |",v.window.view:internalVisible())
		--end
		local data = GMModel:getData(ViewManager.getOpeningViews(),8,false,self.searText)

		for k,v in pairs(data) do
			local view = ViewManager.getView(v.k)
			local isVisible = view.view:isVisible() and view._parent:isVisible()
			if isVisible then
				v.k = v.k..DescAuto[121] -- [121]=" [可见]"
			else
				v.k = v.k..DescAuto[122] -- [122]=" [隐藏]"
			end
		end
		
		self:initList(data); 
	elseif title == "Config" then
		self:initList(GMModel:getData(DynamicConfigData,8,false,self.searText));
	elseif title == "Desc" then
		self:initList(GMModel:getData(Desc,13,false,self.searText));
	elseif title == "Texture" then
		self.textList:getRootNode():removeChildren()
		self.textList:setVisible(false)
		local str = cc.Director:getInstance():getTextureCache():getCachedTextureInfo()
		self.logText:logText(str)
	elseif title == "package" then
		self:initList(GMModel:getData(ViewManager._packView,13,false,self.searText));
	end
end

function GMCheckDataView:split( str,reps )
	local resultStrList = {}
	string.gsub(str,'[^'..reps..']+',function ( w )
			table.insert(resultStrList,w)
		end)
	return resultStrList
end



function GMCheckDataView:initList(data)
	--printTable(33,"initList",data)
	self.logText:logText("")
	self.textList:setVisible(true)
	self.textList:setTreeNodeRender(function(node,obj)


			local ipkey = obj:getChildAutoType("iptitle")
			local key = obj:getChildAutoType("title")
			local fuzhi = obj:getChildAutoType("fuzhi")
			local textStr = node:getData()
			
			key:setText("[color=#DBE615]"..textStr.k.."[/color] = ".. textStr.v)
			
			ipkey:setWidth(800)
			ipkey:setText(textStr.k.." = ".. textStr.v)

			if node:isFolder() then
				
			end
			
			--key:removeEventListener(FUIEventType.RightClick)
			--key:addEventListener(FUIEventType.RightClick,function()
					--print(33,"RightClick = "..textStr.k)
					
				--end)
			fuzhi:removeClickListener(88)
			fuzhi:addClickListener(function( ... )
					print(33,"fuzhi "..textStr.k)
					local c1Ctl = obj:getController("c1");
					local idx = c1Ctl:getSelectedIndex()
					idx = idx + 1
					if idx > 1 then
						idx = 0
					end
					c1Ctl:setSelectedIndex(idx)
					
				end,88)
			
		end)
	
	local treeRootNode = self.textList:getRootNode()
	
	local function createitem(rootNode,treeData)
			
			if type(treeData.v) == "table" then
				local str = {k=treeData.k,v = treeData.vn}
				--local str = "[color=##AAAA00]"..treeData.k.."[/color] = ".. treeData.vn
				local topNode = fgui.GTreeNode:create(true);
				topNode:setData(str);
				rootNode:addChild(topNode);
			    for i=1,#treeData.v do
				   createitem(topNode,treeData.v[i])
			    end
			else
			    --printTable(33,rootNode,treeData)
				--local str = "[color=##AAAA00]"..tostring(treeData.k).."[/color] = ".. tostring(treeData.v)
				local str = {k=treeData.k,v = treeData.v}
				local topNode = fgui.GTreeNode:create(false);
				topNode:setData(str);
				rootNode:addChild(topNode);
			end


	end
	
	for i=1,#data do
		createitem(treeRootNode,data[i])
	end
	
	self.isG = false
end


function GMCheckDataView:readLastInput1()
	if CC_TARGET_PLATFORM == CC_PLATFORM_MAC or CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then

		local lastIput1 = FileCacheManager.getStringForKey(LoginModel:formatUserDefaultKeyWithAgent(FileDataType.GM_INPUT1), "", nil, true)
		if lastIput1 ~= "" then
			local Info = json.decode(lastIput1)
			if type(Info) == "table" then
				self.lastIput1 = Info
			end
		end
	end
end

function GMCheckDataView:saveLastInput1()
	if CC_TARGET_PLATFORM == CC_PLATFORM_MAC or CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
		FileCacheManager.setStringForKey(LoginModel:formatUserDefaultKeyWithAgent(FileDataType.GM_INPUT1), json.encode(self.lastIput1), nil, true)
	end
end

function GMCheckDataView:readLastInput2()
	if CC_TARGET_PLATFORM == CC_PLATFORM_MAC or CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then

		local lastIput = FileCacheManager.getStringForKey(LoginModel:formatUserDefaultKeyWithAgent(FileDataType.GM_INPUT2), "", nil, true)
		if lastIput ~= "" then
			local Info = json.decode(lastIput)
			if type(Info) == "table" then
				self.lastIput2 = Info
			end
		end
	end
end

function GMCheckDataView:saveLastInput2()
	if CC_TARGET_PLATFORM == CC_PLATFORM_MAC or CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
		FileCacheManager.setStringForKey(LoginModel:formatUserDefaultKeyWithAgent(FileDataType.GM_INPUT2), json.encode(self.lastIput2), nil, true)
	end
end

return GMCheckDataView
