--Name : FilmEditView.lua
--Author : generated by FairyGUI
--Date : 2020-4-18
--Desc : 
local PushMapFilmView = require "Game.Modules.Film.PushMapFilmView"
local FilmEditView,Super = class("FilmEditView", PushMapFilmView)
local film_Config = false
local film_curConfig = false
function FilmEditView:ctor()
	--LuaLog("FilmEditView ctor")
	self._packName = "Film"
	self._compName = "FilmEditView"
	--self._rootDepth = LayerDepth.Window
	self.step = "simple"
	self.index = 1
	self.curKey = ""
	self.curItemObj = false
	self.clickFuc = false
	self.isAuto = false
	self.updateFunc = false
	self.delObj = false
	self.isAutoOpen = 3
	self.luaFile = GMModel.currentAssets .."Scripts/CN/Configs/Generate/FilmConfig.lua"
end

function FilmEditView:_initEvent( )
	
end

function FilmEditView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:Film.FilmEditView
		vmRoot.name = viewNode:getChildAutoType("layer/$name")--Label
		vmRoot.user1 = viewNode:getChildAutoType("layer/$user1")--Button
		vmRoot.closebt = viewNode:getChildAutoType("$closebt")--Button
		vmRoot.text = viewNode:getChildAutoType("layer/$text")--Label
		vmRoot.user2 = viewNode:getChildAutoType("layer/$user2")--Button
		vmRoot.exit = viewNode:getChildAutoType("$exit")--Button
		local filmContent = viewNode:getChildAutoType("$filmContent")--
		vmRoot.filmContent = filmContent
			filmContent.createbt = viewNode:getChildAutoType("$filmContent/$createbt")--Button
			filmContent.savebt = viewNode:getChildAutoType("$filmContent/$savebt")--Button
			filmContent.tuodong = viewNode:getChildAutoType("$filmContent/$tuodong")--graph
			filmContent.treeList = viewNode:getChildAutoType("$filmContent/$treeList")--list
			filmContent.input = viewNode:getChildAutoType("$filmContent/$input")--text
			filmContent.hide = viewNode:getChildAutoType("$filmContent/$hide")--Button
		vmRoot.auto = viewNode:getChildAutoType("$auto")--Button
		local layer = viewNode:getChildAutoType("layer/$layer")--
		vmRoot.layer = layer
			layer.layer = viewNode:getChildAutoType("layer/$layer/$layer")--loader
		vmRoot.huigu = viewNode:getChildAutoType("$huigu")--Button
		local canshu = viewNode:getChildAutoType("$canshu")--Label
		vmRoot.canshu = canshu
			canshu.url = viewNode:getChildAutoType("$canshu/$url")--text
			canshu.Btnkk = viewNode:getChildAutoType("$canshu/$Btnkk")--Button
			canshu.titleY = viewNode:getChildAutoType("$canshu/$titleY")--text
			canshu.index = viewNode:getChildAutoType("$canshu/$index")--text
			canshu.lsit = viewNode:getChildAutoType("$canshu/$lsit")--list
			canshu.bga = viewNode:getChildAutoType("$canshu/$bga")--text
			canshu.pma = viewNode:getChildAutoType("$canshu/$pma")--text
			canshu.posx = viewNode:getChildAutoType("$canshu/$posx")--text
			canshu.name = viewNode:getChildAutoType("$canshu/$name")--text
			canshu.Btn = viewNode:getChildAutoType("$canshu/$Btn")--Button
			canshu.btn_del = viewNode:getChildAutoType("$canshu/$btn_del")--Button
			canshu.itemicon = viewNode:getChildAutoType("$canshu/$itemicon")--text
			canshu.btn_create = viewNode:getChildAutoType("$canshu/$btn_create")--Button
			canshu.h = viewNode:getChildAutoType("$canshu/$h")--text
			canshu.titleColor = viewNode:getChildAutoType("$canshu/$titleColor")--text
			canshu.eventTxt = viewNode:getChildAutoType("$canshu/$eventTxt")--text
			canshu.posy = viewNode:getChildAutoType("$canshu/$posy")--text
			canshu.bgurl = viewNode:getChildAutoType("$canshu/$bgurl")--text
			canshu.txt = viewNode:getChildAutoType("$canshu/$txt")--text
			canshu.mask = viewNode:getChildAutoType("$canshu/$mask")--Button
			canshu.titleX = viewNode:getChildAutoType("$canshu/$titleX")--text
			canshu.w = viewNode:getChildAutoType("$canshu/$w")--text
			canshu.action = viewNode:getChildAutoType("$canshu/$action")--text
			canshu.titleSize = viewNode:getChildAutoType("$canshu/$titleSize")--text
		local call = viewNode:getChildAutoType("layer/$call")--Label
		vmRoot.call = call
			call.mask = viewNode:getChildAutoType("layer/$call/$mask")--graph
	--{vmFieldsEnd}:Film.FilmEditView
	--Do not modify above code-------------
end

function FilmEditView:_initUI( )
	Super._initUI( self )
	--self:_initVM( )
	
	self.call:setVisible(true)
	self.call:setDraggable(true)
	self.user1:setDraggable(true)
	self.user2:setDraggable(true)
	self.name:setDraggable(true)
	self.canshu:setDraggable(true)
	self.text:setDraggable(true)
	self.canshuCtrl = self.canshu:getController("c1")
	self.filmContent.tuodong:setDraggable(true)
	self.text:setTouchable(true)
	
	film_Config = loadstring(io.readfile(self.luaFile))()
	--film_Config = DynamicConfigData.FilmConfig
	for k,v in pairs(film_Config) do
		self.curData = v[self.index] or {}
		film_curConfig = v
		self.step = k
	end
	
	if rawget(_G,"_GMView") then
		_GMView.window:setSortingOrder(LayerDepth.Window-1)
		_GMView.btlist:setSortingOrder(0)
	end
	self.canshu.lsit:setItemRenderer(function(index,obj)
			local title = obj:getTitle()
			if self.curData and self.curData[title] and self.curData[title] ~= "" then
				self[title]:setVisible(true)
				obj:setSelected(true)
			else
				self[title]:setVisible(false)
			end
			obj:addClickListener(function (context)
						if obj:isSelected() then
							self[title]:setVisible(true)
							local d_data = {}
							local pos = self[title]:getPosition()
							d_data[1] = string.gsub (self[title]:getIcon(), self.userF,"")
							d_data[2] = pos.x
							d_data[3] = pos.y
							d_data[4] = self[title]:getWidth()
							d_data[5] = self[title]:getHeight()
							self.curData[title] = table.concat(d_data,",")
						else
							self[title]:setVisible(false)
							self.curData[title] = nil
						end
					end,2)
		end)
	self.canshu.lsit:setNumItems(3)
	
	
	self.canshu.Btnkk:addClickListener(function (context)
				if self.canshuCtrl:getSelectedIndex() == 2 then
				
					local var = self.call:getChildAutoType("bg"):isVisible()
					self.call:getChildAutoType("bg"):setVisible(not var)
					self.user1:getChildAutoType("bg"):setVisible(not var)
					self.user2:getChildAutoType("bg"):setVisible(not var)
				
					local childs = self.layer:getChildren()
					for i = 1, #childs do
						local itemObj = childs[i]
						itemObj:getChildAutoType("bg"):setVisible(not var)
					end
				
				end
			end)
	self.canshu.btn_del:addClickListener(function (context)
				if self.curKey == "item" then
					print(33,"btn_del->item")
					if self.delObj then
						print(33,"btn_del->item do")
					
						local pos = tonumber(self.delObj:getName())
						if pos>0 then
							self.delObj:removeFromParent()
							table.remove(self.curData.item,pos)
							self.canshu:setVisible(false)

						end
					
						self.delObj = false
					end
				end
			end)
	self.canshu.Btn:addClickListener(function (context)
			if self.curKey == "user1" or self.curKey == "user2" or self.curKey == "call" then
				
				local d_data = string.split(self.curData[self.curKey],",")
				d_data[1] = self.canshu.url:getText()
				d_data[2] = self.canshu.posx:getText()
				d_data[3] = self.canshu.posy:getText()
				d_data[4] = self.canshu.w:getText()
				d_data[5] = self.canshu.h:getText()
				
				local color = self[self.curKey]:getChildAutoType("icon"):getColor()
				if color.r == 255 then
					d_data[6] = ""
				else
					d_data[6] = "mask"
				end
				if self.canshu.action:getText() ~= "" then
					d_data[7] = self.canshu.action:getText()
				else
					d_data[7] = nil
				end
			
				self.curData[self.curKey] = table.concat(d_data,",")
				self[self.curKey]:setData(self.curData[self.curKey])
				--self[self.curKey]:setIcon(self.canshu.url:getText()) 
				--self[self.curKey]:setPosition(tonumber(self.canshu.posx:getText()),tonumber(self.canshu.posy:getText()))
			elseif self.curKey == "bg" then
				self.bg:setURL(self.bgF..self.canshu.bgurl:getText())	
				self.curData.bg = self.canshu.bgurl:getText()
				if self.canshu.bga:getText() == "" then
					self.curData.bga = nil
				else
					self.curData.bga = self.canshu.bga:getText()
				end
				if self.canshu.pma:getText() == "" then
					self.curData.pma = nil
				else
					self.curData.pma = self.canshu.pma:getText()
				end
				--self.s
			elseif self.curKey == "name" or self.curKey == "text" then
				local d_data = string.split(self.curData[self.curKey],",")
				d_data[1] = string.gsub(self.canshu.txt:getText(), "\r\n", "<br>")
				d_data[1] = string.gsub(d_data[1], "\n", "<br>")
				d_data[1] = string.gsub(d_data[1], "\r", "")

				d_data[2] = tonumber(self.canshu.posx:getText())
				d_data[3] = tonumber(self.canshu.posy:getText())
				d_data[4] = tonumber(self.canshu.w:getText())
				d_data[5] = tonumber(self.canshu.h:getText())
				
				if self.canshu.action:getText() ~= "" then
					d_data[6] = self.canshu.action:getText()
				else
					d_data[6] = nil
				end
				
				self[self.curKey]:setTitle(self.canshu.txt:getText())
				self[self.curKey]:setPosition(d_data[2],d_data[3])
				self[self.curKey]:setWidth(d_data[4])
				self[self.curKey]:setHeight(d_data[5])
				
				self.curData[self.curKey] = table.concat(d_data,",")
			elseif self.curKey == "item" then
				local sssdata = self.curItemObj.sdata
				
				sssdata.x = tonumber(self.canshu.posx:getText())
				sssdata.y = tonumber(self.canshu.posy:getText())
				sssdata.w = tonumber(self.canshu.w:getText())
				sssdata.h = tonumber(self.canshu.h:getText())
				sssdata.icon = self.canshu.itemicon:getText()
				
				if self.canshu.action:getText() ~= "" then
					sssdata.a = self.canshu.action:getText()
				else
					sssdata.a = nil
				end
				if self.canshu.eventTxt:getText() ~= "" then
					sssdata.e = self.canshu.eventTxt:getText()
				else
					sssdata.e = nil
				end
				self.curItemObj:setIcon(self.userF..sssdata.icon)
				
				local ttxt = self.canshu.txt:getText()
				if ttxt ~= "" then
					if not sssdata.title then
						sssdata.title = {}
						sssdata.title.x = 0
						sssdata.title.y = 0
					end
					local color = self.canshu.titleColor:getText()
					local xxx = tonumber(self.canshu.titleX:getText())
					local yyy = tonumber(self.canshu.titleY:getText())
					local sss = tonumber(self.canshu.titleSize:getText())
					
					
					local title = self.curItemObj:getChildAutoType("title")
					title:setVisible(true)
					title:setText(ttxt)
					title:setPosition(xxx,yyy)
					title:setFontSize(sss)
					local c_info = string.split(color,",")
					title:setColor({r=tonumber(c_info[1]),g=tonumber(c_info[2]),b=tonumber(c_info[3])})
					

					
					sssdata.title.c=color
					sssdata.title.s=sss
					sssdata.title.x=xxx
					sssdata.title.y=yyy
					sssdata.title.txt = ttxt
				else
					sssdata.title = nil
				end
				
				
				self.curItemObj:setPosition(sssdata.x,sssdata.y)
				self.curItemObj:setWidth(sssdata.w)
				self.curItemObj:setHeight(sssdata.h)

			else
				self[self.curKey]:setTitle(self.canshu.txt:getText())
				self.curData[self.curKey] = self.canshu.txt:getText()
			end
			if self.updateFunc then
				self.updateFunc()
				--self.updateFunc = false
			end
		end)
	
	local tdata = {"user1","user2","call","name","text"}
	
	local function updateObj(key)
		local pos  = self[key]:getPosition()

		local d_data = string.split(self.curData[key],",")
		d_data[2] = pos.x
		d_data[3] = pos.y
		self.curData[key] = table.concat(d_data,",")
		print(33,"pos",d_data[2],d_data[3])
		self:showCanshu(self.curData[key],key)
	end
	
	for i = 1, #tdata do
		local key = tdata[i]
		self[key].edit = true
		self[key]:addEventListener(FUIEventType.Click,function() updateObj(key) end,5330)
		--if i < 5 then
			self[key]:addEventListener(FUIEventType.TouchMove,function() updateObj(key) end,5330)
		--end
	end
	
	
	--self.auto:setTitle("下一页")
	self.auto:addClickListener(function(context)
			local datas = film_Config[self.step][self.index+1]
			if datas then
				self.index = self.index + 1
				self:updateCanshu( datas )
			else
				RollTips.show(DescAuto[108]) -- [108]="已经最后一页"
			end
				
		end,33)


	self.huigu:setVisible(false)
	
	self.view:addClickListener(function()
			end,33)
	self.bg:addClickListener(function (context)
			self:showCanshu(self.curData,"bg")
		end)
	self.bg:addLongPressListener(function (context)
			self.filmContent:setVisible(true)
			end)
	self.filmContent.hide:addClickListener(function (context)
			self.filmContent:setVisible(false)
		end)
	self.canshu.btn_create:addClickListener(function (context)
				if not self.curData.item then
					self.curData.item = {}
				end
				local info = {x=200,y=200,w=300,h=300,icon="44002.png",mask = 0}
				table.insert(self.curData.item,info)
				
				self:itemListerCanshu( info,self:createItem(info,#self.curData.item) )
			end)
	self.canshu.mask:addClickListener(function (context)
			if self.curKey == "call" then
				local var = self.call.mask:isVisible()
				self.call.mask:setVisible(not var)
			elseif self.curKey == "user1" or self.curKey == "user2" then
				local var = self.call.mask:isVisible()
				local color = self[self.curKey]:getChildAutoType("icon"):getColor()
				if color.r == 255 then
					color = cc.c3b(155,155,155)
				else
					color = cc.c3b(255,255,255)
				end
				self[self.curKey]:getChildAutoType("icon"):setColor(color)
			elseif self.curKey == "item"  then
				
				local var = self.call.mask:isVisible()
				local color = self.curItemObj:getChildAutoType("icon"):getColor()
				if color.r == 255 then
					self.curItemObj.sdata.mask = 1
					color = cc.c3b(155,155,155)
				else
					self.curItemObj.sdata.mask = 0
					color = cc.c3b(255,255,255)
				end
				self.curItemObj:getChildAutoType("icon"):setColor(color)
				return
			end
			local d_data = string.split(self.curData[self.curKey],",")
			d_data[6] = (d_data[6] == "mask" and "" or "mask")
			self.curData[self.curKey] = table.concat(d_data,",")
		end)
	
	--self.filmContent.tuodong:addEventListener(FUIEventType.TouchMove,function()
		--local pos = self.filmContent.tuodong:getPosition()
		--self.filmContent.tuodong:setPosition(0,0)
		--self.filmContent:setPosition(pos.x,pos.y)
	--end,5330)
	self.filmContent.savebt:addClickListener(function()
			
			self:save(film_Config)
			RollTips.show(DescAuto[109]) -- [109]="保存成功"
		end,33)
	
	self:initList()
	if self.curData then
		self:updateCanshu( self.curData )
	end
end

function FilmEditView:beginFilm()

end

function FilmEditView:updateCanshu( data )
	self:doFilmType1(data)
end

function FilmEditView:itemListerCanshu( info,itemObj )
	local function updateItem(obj,dinfo)
		local pos  = obj:getPosition()

		dinfo.x = pos.x
		dinfo.y = pos.y
		self.delObj = itemObj
		self:showCanshu(dinfo,"item",obj)
	end
	
	itemObj:setTouchable(true)
	itemObj:setDraggable(true)
	itemObj:addEventListener(FUIEventType.Click,function() updateItem(itemObj,info) end,5330)
	itemObj:addEventListener(FUIEventType.TouchMove,function() updateItem(itemObj,info) end,5330)
end

function FilmEditView:doFilmType1(data)

	
	Super.doFilmType1(self,data)
	self.curData = data
	
	
	
	if data.item and #data.item>0 then
		local childs = self.layer:getChildren()
		for i = 1, #childs do
			self:itemListerCanshu( data.item[i],childs[i] )
		end
	end
end

function FilmEditView:showCanshu( data,key,obj )
	
	self.canshu:setVisible(true)
	self.curKey = key
	self.curItemObj = obj or false
	self.canshu:setTitle(key)
	self.canshu:setTitle(key)
	if key == "bg" then
		self.canshuCtrl:setSelectedIndex(2)
		self.canshu.bgurl:setText(self.curData.bg)
		
		self.canshu.bga:setText(self.curData.bga or "")
		self.canshu.pma:setText(self.curData.pma or "")

		for i = 0, self.canshu.lsit:getNumItems()-1 do
			local item = self.canshu.lsit:getChildAt(i)
			local title = item:getTitle()
			if self.curData[title] and self.curData[title] ~= "" then
				item:setSelected(true)
			else
				item:setSelected(false)
			end
		end
	elseif  key == "name" or key == "text" then
		self.canshuCtrl:setSelectedIndex(1)
		local t_data = string.split(data,",")
		local texts = string.gsub(t_data[1], "<br>", "\r\n")
		self.canshu.txt:setText(texts)
		self.canshu.posx:setText(t_data[2])
		self.canshu.posy:setText(t_data[3])
		self.canshu.w:setText(t_data[4])
		self.canshu.h:setText(t_data[5])

		self.canshu.action:setText(t_data[6] or "")
		
	elseif  key == "item" then
		self.canshuCtrl:setSelectedIndex(3)
		if data.title and data.title.txt then
			self.canshu.txt:setText(data.title.txt)
			self.canshu.titleX:setText(data.title.x)
			self.canshu.titleY:setText(data.title.y)
			self.canshu.titleSize:setText(data.title.s)
			self.canshu.titleColor:setText(data.title.c)
		else
			self.canshu.txt:setText("")
		end
		self.canshu.posx:setText(data.x)
		self.canshu.posy:setText(data.y)
		self.canshu.w:setText(data.w)
		self.canshu.h:setText(data.h)
		self.canshu.itemicon:setText(data.icon)
		self.canshu.action:setText(data.a)
		if data.a then
			self.canshu.eventTxt:setText(data.e)
		else
			self.canshu.eventTxt:setText("")
		end
		if data.e then
			self.canshu.eventTxt:setText(data.e)
		else
			self.canshu.eventTxt:setText("")
		end
	else
		if key == "call" then
			local var = self.call.mask:isVisible()
			self.canshu.mask:setSelected(var)
		else
			--local color = self.user1:getColor()
			--self.user1
		end
		self.canshuCtrl:setSelectedIndex(0)
		local t_data = string.split(data,",")
		self.canshu.url:setText(t_data[1])
		self.canshu.posx:setText(t_data[2])
		self.canshu.posy:setText(t_data[3])
		self.canshu.w:setText(t_data[4])
		self.canshu.h:setText(t_data[5])

		
		if t_data[6] == "mask" then
			self.canshu.mask:setSelected(true)
			self[self.curKey]:getChildAutoType("icon"):setColor(cc.c3b(155,155,155))
		else
			self.canshu.mask:setSelected(false)
			self[self.curKey]:getChildAutoType("icon"):setColor(cc.c3b(255,255,255))
		end
		if t_data[7] then
			self.canshu.action:setText(t_data[7])
		end
	end
	
end


function FilmEditView:initList(data)
	--printTable(33,"initList",data)
	
	
	local saveData = {}
	
	local function createitem(rootNode,p,k,v,t)

		if t and type(v) == "table" then
			local topNode = fgui.GTreeNode:create(true);
			print(33,"createitem",tostring(v[1]))
			--topNode:setData({p=p,k=k,v=v});
			saveData[tostring(topNode)] = {n=topNode,p=p,k=k,v=v}
			rootNode:addChild(topNode);
			for i=1,#v  do
				createitem(topNode,tostring(topNode),i,v[i])
			end
			
			return topNode
		else
			local topNode = fgui.GTreeNode:create(false);
			--topNode:setData({p=p,k=k,v=v});
			saveData[tostring(topNode)] = {n=topNode,p=p,k=k,v=v}
			rootNode:addChild(topNode);
			return topNode
		end
	end
	
	local treeRootNode = self.filmContent.treeList:getRootNode()
	
	self.filmContent.treeList:setVisible(true)
	self.filmContent.treeList:setTreeNodeRender(function(node,obj)
			local n_data = saveData[tostring(node)]
			if node:isFolder() then
				obj:setTitle("[color=##AAAA00]"..n_data.k.."[/color] = ".. tostring(#n_data.v) .. DescAuto[110]) -- [110]="个页面"
			else
				local d_data = string.split(n_data.v.name,",")
				obj:setTitle("[color=##AAAA00]"..tostring(n_data.k).."[/color] = ".. d_data[1])
			end
			
			obj:getChildAutoType("rename"):addClickListener(function(context)
					context:stopPropagation()
					local crt = obj:getController("rename")
					local idx = crt:getSelectedIndex()
					if idx == 0 then
						crt:setSelectedIndex(1)
						obj:getChildAutoType("input"):setText(n_data.k)
					else
						crt:setSelectedIndex(0)
						local name = obj:getChildAutoType("input"):getText()
						if name == "" then
							Alert.show(DescAuto[111]) -- [111]="请输入剧情名字"
							return
						end
						
						if name == n_data.k then
							return
						end
						
						if film_Config[name] then
							Alert.show(DescAuto[112]) -- [112]="剧情已存在"
							return
						end
						film_Config[name] = film_Config[n_data.k]
						film_Config[n_data.k] = nil
						
						
						treeRootNode:removeChild(node)
						local nnode = createitem(treeRootNode,film_Config,name,film_Config[name],true)
						--nnode:setExpaned(true)
					end
						
				end,33)
			obj:getChildAutoType("edit"):addClickListener(function(context)
					context:stopPropagation()
					if node:isFolder() then
						local topNode = fgui.GTreeNode:create(false);
						local info = {
							type = 1,
							bg = "10001.jpg",
							text = DescAuto[113], -- [113]="对话,0,540,1280,180"
							name = DescAuto[114] -- [114]="名字,500,480,218,37"
						}
						table.insert(n_data.v,info)
						print(33,"edit",tostring(n_data.v[1]))
						saveData[tostring(topNode)]={p=tostring(node),k=#n_data.v,v=info}
						--topNode:setData({p=n_data.v,k=#n_data.v,v=info});
						obj:setTitle("[color=##AAAA00]"..n_data.k.."[/color] = ".. tostring(#n_data.v) .. DescAuto[110]) -- [110]="个页面"
						node:addChild(topNode);
					else
						self.index = n_data.k
						self.step  = saveData[n_data.p].k
						self:updateCanshu( n_data.v)
						self.updateFunc = function ()

							local d_data = string.split(n_data.v.name,",")
							obj:setTitle("[color=#00FF00]"..tostring(n_data.k).." = ".. d_data[1].."[/color]")
							
							local index = self.canshu.index:getText()
							if index == "" then return end
							index= tonumber(index)
							if n_data.k ~= index then
								local p_data = saveData[n_data.p]
								local cf = p_data.v[n_data.k]
								table.remove(p_data.v,n_data.k)
								table.insert(p_data.v,index,cf)
								treeRootNode:removeChild(node:getParent())
								local nnode = createitem(treeRootNode,film_Config,p_data.k,p_data.v,true)
								nnode:setExpaned(true)
								self.index = index
								self.updateFunc = false
								self.canshu:setVisible(false)
							end
						end
						self.canshu.name:setText(self.step.." -")
						self.canshu.index:setText(self.index)
					end
			end,33)
			obj:getChildAutoType("del"):addClickListener(function(context)
					context:stopPropagation()
					print(33,"del")
					local info = {}
					info.text = DescAuto[115] -- [115]="确认删除？"
					info.type = "yes_no"
					info.onYes = function()
						if node:isFolder() then
							film_Config[n_data.k] = nil
							treeRootNode:removeChild(node)
						else
							local p_data = saveData[n_data.p]
							table.remove(p_data.v,n_data.k)
							
							treeRootNode:removeChild(node:getParent())
							local nnode = createitem(treeRootNode,film_Config,p_data.k,p_data.v,true)
							nnode:setExpaned(true)
							self.canshu:setVisible(false)
							self.updateFunc = false
						end
					end
					Alert.show(info)
					
				end,33)
			obj:getChildAutoType("refesh"):addClickListener(function(context)
					context:stopPropagation()
					treeRootNode:removeChild(node)
					local nnode = createitem(treeRootNode,film_Config,n_data.k,n_data.v,true)
					nnode:setExpaned(true)
					self.canshu:setVisible(false)
					self.updateFunc = false
				end,33)
			obj:getChildAutoType("play"):addClickListener(function(context)
					context:stopPropagation()
					ViewManager.open("PushMapFilmView",{step = n_data.k,filmConfig = film_Config})
				end,33)
		end)

	

	
	saveData[tostring(treeRootNode)] = {n=treeRootNode,v=film_Config}
	for k,v in pairs(film_Config) do
		createitem(treeRootNode,tostring(treeRootNode),k,v,true)
	end
	
	self.filmContent.createbt:addClickListener(function (context)
			local name = self.filmContent.input:getText()
			if name == "" then
				Alert.show(DescAuto[111]) -- [111]="请输入剧情名字"
				return
			end
			if film_Config[name] then
				Alert.show(DescAuto[112]) -- [112]="剧情已存在"
				return
			end
			local newt = {}
			film_Config[name] = newt
			createitem(treeRootNode,film_Config,name,newt,true)
			
			end)
end

--// The Save Function
function FilmEditView:save(  tbl,filename )
	local function cmpFunc(a,b)
		return a.key < b.key
	end
	local str = self:serialize(tbl,cmpFunc,cmpFunc)
	self:writefile(str,self.luaFile)
end

function FilmEditView:serialize(t, sort_parent, sort_child)
	local mark={}
	local assign={}

	local function ser_table(tbl,parent)
		mark[tbl]=parent
		local tmp={}
		local sortList = {};
		for k,v in pairs(tbl) do
			sortList[#sortList + 1] = {key=k, value=v};
		end

		if tostring(parent) == "ret" then
			if sort_parent then table.sort(sortList, sort_parent); end
		else
			if sort_child then table.sort(sortList, sort_child); end
		end

		for i = 1, #sortList do
			local info = sortList[i];
			local k = info.key;
			local v = info.value;
			local key= type(k)=="number" and "["..k.."]" or k;
			if type(v)=="table" then
				local dotkey= parent..(type(k)=="number" and key or "."..key)
				if mark[v] then
					table.insert(assign,dotkey.."="..mark[v])
				else
					table.insert(tmp, "\n"..key.."="..ser_table(v,dotkey))
				end
			else
				if type(v) == "string" then
					table.insert(tmp, key..'="'..v..'"');
				else
					table.insert(tmp, key.."="..tostring(v));
				end
			end
		end

		return "{"..table.concat(tmp,",").."}";
	end

	return "return \n"..ser_table(t,"ret")..table.concat(assign," ").."\n"
end

function FilmEditView:writefile(str, file)
	os.remove(file);
	local file=io.open(file,"ab");

	local len = string.len(str);
	local tbl = string.split(str, "\n");
	for i = 1, #tbl do
		file:write(tbl[i].."\n");
	end
	file:close();
end

return FilmEditView
