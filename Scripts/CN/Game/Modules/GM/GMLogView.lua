--示测试页
local GMLogView = {}

function GMLogView:initLog(gmView,view)
	self.searText = false
	self.textList = view:getChildAutoType("tree")
	gmView.saveLog = {}
	self.saveLog = gmView.saveLog
	local printid = view:getChildAutoType("printid")
	local lognum = view:getChildAutoType("lognum")
	local checklog = view:getChildAutoType("checklog")
	checklog:addClickListener(function()
			print(33,"checklog")
			--self.window:hide();
			__PRINT_TYPE__ = tonumber(printid:getText())
			local f1 = LuaLogE
			local f2 = LuaLog
			local saveprint = print
			local saveprintTable = printTable
			--print = nil
			--printTable = nil
			
			print = function(printId,...)
				if __PRINT_TYPE__ ~= printId and printId ~= 0 then
					return
				end
				saveprint(printId,...)
				local args = {...}
				local logd = {}
				logd.k = #GMModel.logData
				logd.v = ""
				for k, v in pairs(args) do
					
					logd.v = logd.v..tostring(v).." "
					
					--self:addLog({[1]=t})
				end
				table.insert(GMModel.logData,1,logd)
				--self:addLog(GMModel.logData)
				lognum:setText(#GMModel.logData)
			end
			
			printTable = function(printId,...)
				if __PRINT_TYPE__ ~= printId and printId ~= 0 then
					return
				end
				saveprintTable(printId,...)
				local args = {...}
				for k, v in pairs(args) do
					local t = {}
					t.k = #GMModel.logData
					t.v = GMModel:getData(v,10,false,self.searText)
					if type(t.v) == "table" then
						t.vn = "["..#t.v.."]"..tostring(v)
					end
					table.insert(GMModel.logData,1,t)
					
					--self:addLog({[1]=t})
				end
				lognum:setText(#GMModel.logData)

			end
		end)
	
	local clog = view:getChildAutoType("clog")
	local begin = view:getChildAutoType("begin")
	local ends = view:getChildAutoType("end")
	clog:addClickListener(function()
			self.textList:getRootNode():removeChildren()
			local begss = tonumber(begin:getText())
			local endss = tonumber(ends:getText())
			self:showLog(GMModel.logData,begss,endss)
			end)
	
	local clearlog = view:getChildAutoType("clear")
	clearlog:addClickListener(function()
			self.textList:getRootNode():removeChildren()
			GMModel.logData = {}
			lognum:setText(#GMModel.logData)
		end)
end


function GMLogView:showLog(data,begin,ends)
	--printTable(33,"initList",data)
	self.textList:setVisible(true)
	self.textList:setTreeNodeRender(function(node,obj)


			local ipkey = obj:getChildAutoType("iptitle")
			local key = obj:getChildAutoType("title")
			local fuzhi = obj:getChildAutoType("fuzhi")
			local textStr = node:getData()

			key:setText("[color=##CC9933]"..textStr.k.."[/color] = ".. textStr.v)

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
	if #data < ends then ends = #data end
	
	
	for i=begin,ends do
		createitem(treeRootNode,data[i])
	end

end

return GMLogView
