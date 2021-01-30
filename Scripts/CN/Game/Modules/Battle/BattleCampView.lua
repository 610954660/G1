
--Name : BattleCampView.lua
--Author : generated by FairyGUI
--Date : 2020-5-19
--Desc : 

local BattleCampView,Super = class("BattleCampView", Window)

function BattleCampView:ctor()
	--LuaLog("BattleCampView ctor")
	self._packName = "Battle"
	self._compName = "BattleCampView"
	self._rootDepth = LayerDepth.PopWindow
	
end

function BattleCampView:_initEvent( )
	
end

function BattleCampView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:Battle.BattleCampView
		vmRoot.closeButton = viewNode:getChildAutoType("$closeButton")--Label
		vmRoot.campList = viewNode:getChildAutoType("$campList")--list
	--{vmFieldsEnd}:Battle.BattleCampView
	--Do not modify above code-------------
end

function BattleCampView:_initUI( )
	self:_initVM()
	self.view:getChildAutoType("bg"):getChildAutoType("closeButton"):addClickListener(function ()
		ViewManager.close("BattleCampView")
	end)
	
	self.closeButton:addClickListener(function ()
		ViewManager.close("BattleCampView")
	end)
	self:setData()

end

function BattleCampView:setData( )
	local campList=false
	if self._args.inBattle then
	 campList=BattleModel:getCampAddInBattelData(self._args.heroPos)
	end
	if not campList or  #campList == 0 then
		campList=BattleModel:getCampAddition(self._args.heroPos)
	end
	
	--同一阵营有可能会有两条的，例如上了7个魔族的，会有5、2两条
	local activedMap = {}	--激活的人阵营+人数
	for _,v in ipairs(campList) do
		activedMap[v.category.."_"..v.num] = true
	end
	
	--兽、人、械、魔、仙 (排列要用这样的顺序，坑)
	local campIndex = {}
	campIndex[3] = 1
	campIndex[4] = 2
	campIndex[5] = 3
	campIndex[2] = 4
	campIndex[1] = 5
	
	local campInfo = {}
	
	for category,v in ipairs(DynamicConfigData.t_camp) do
		local attrs = {}
		--把属性map转成数组
		local activeNum = 0
		for _,attr in pairs(v) do
			table.insert(attrs, attr)
			if activedMap[attr.category.."_"..attr.num] then
				activeNum = activeNum + 1
			end
		end
		TableUtil.sortByMap(attrs, {{key = "num", asc = false}})
		--local activeNum = activedNumMap[category] or 0
		table.insert(campInfo, {category = category, attrs = attrs, activeNum = activeNum,campIndex = campIndex[category] })
	end
	
	--有激活的阵营排在前面,然后要按这样的顺序排 兽、人、械、魔、仙
	TableUtil.sortByMap(campInfo, {{key = "activeNum", asc = true},{key = "campIndex", asc = false}})
	
	
	self.campList:setItemRenderer(function(index,item)
			local data = campInfo[index+1]
			local category = data.category
			local titleList=item:getChildAutoType("titleList")
			if data.activeNum and data.activeNum > 0 then
				item:setIcon(PathConfiger.getCardCategoryColor(category))
			else
				item:setIcon(PathConfiger.getCardCategory(category))
			end
			titleList:setItemRenderer(function (attrIndex,titleItem)
				local numData = data.attrs[attrIndex+1]
				titleItem:setText(numData.describe)
				if activedMap[numData.category.."_"..numData.num] then
					titleItem:getChildAutoType("title"):setColor(ColorUtil.textColor.green)
				end
			end)
			item:getChildAutoType("icon"):setScale(0.7,0.7)
			local dataNum=table.nums(data.attrs)
			if dataNum>4 then
				titleList:setHeight(titleList:getHeight()+dataNum*5)
			end
			titleList:setNumItems(dataNum)
	end)
	self.campList:setData(campInfo)

end



function BattleCampView:battle_end()
	ViewManager.close("BattleCampView")
end


function BattleCampView:battle_Next()
	ViewManager.close("BattleCampView")
end

function BattleCampView:battle_close()
	ViewManager.close("BattleCampView")
end





return BattleCampView