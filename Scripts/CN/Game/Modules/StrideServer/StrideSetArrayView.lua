--Date :2020-12-27
--Author : added by xhd
--Desc : 巅峰赛队伍排序页面

local StrideSetArrayView,Super = class("StrideSetArrayView", Window)

function StrideSetArrayView:ctor()
	--LuaLog("StrideSetArrayView ctor")
	self._packName = "StrideServer"
	self._compName = "StrideSetArrayView"
	self._rootDepth = LayerDepth.PopWindow
	
end

function StrideSetArrayView:_initEvent( )
	
end

function StrideSetArrayView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:StrideServer.StrideSetArrayView
	self.closeButton = viewNode:getChildAutoType('$closeButton')--GLabel
	self.btn_save = viewNode:getChildAutoType('btn_save')--GButton
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.list = viewNode:getChildAutoType('list')--GList
	--{autoFieldsEnd}:StrideServer.StrideSetArrayView
	--Do not modify above code-------------
end

function StrideSetArrayView:_initListener( )
	
	self.closeButton:addClickListener(function()
		self:closeView()
	end)

	self.btn_save:addClickListener(function()
		StrideServerModel:refrushTypeHeroTempInfo(self.tempData)  --请求保存阵容排序
		self:closeView()
	end)

	self.tempData = clone(StrideServerModel:getTypeHeroTempInfo())
	self:_refreshView()

	self.list:setItemRenderer(function(index, obj)

	end)

end

function StrideSetArrayView:heroListHander(index, obj)
	local heroCell = BindManager.bindHeroCell(obj)
	self:getHeroInfoById(heroId,uuid)
	heroCell:setData(self.showData[index + 1])
end

function StrideSetArrayView:changeHeroTemp(p1,p2)
	if not p1 or not p2 then return false end
	local temp1 = self.tempData[p1].array
	local temp2 = self.tempData[p2].array
	self.tempData[p1].array = temp2
	self.tempData[p2].array = temp1
end 

function StrideSetArrayView:_refreshView()
	local group = StrideServerModel:getCurEnumGroup()
	for key,list in pairs(self.list:getChildren()) do
		local listObj = list:getChild("list")
		local btn_left = list:getChild("btn_left")
		local btn_right = list:getChild("btn_right")
		local array = {}
		for key,value in pairs(self.tempData[group[key]].array) do
			table.insert(array,value.uuid)
		end
		local combat = 0 
		listObj:setItemRenderer(function(index, obj)
			local heroCell = BindManager.bindHeroCell(obj)
			local data = BattleModel:getHeroByUid(array[index + 1])
			local heroInfo = {}
			heroInfo['level'] = data.level
			heroInfo['star'] = data.star
			heroInfo['code'] = data.code
			heroInfo['uuid'] = data.uuid
			heroInfo['category'] = data.category
			heroInfo['combat'] = data.combat
			heroCell:setData(heroInfo)
			combat = combat + data.combat
		end)
		listObj:setData(array)
		local fight = list:getChild("fight")
		fight:setText(StringUtil.transValue(combat))
		list:getController("index"):setSelectedIndex(key - 1)

		--往下
		btn_right:addClickListener(function()
			if key == 1 then
				self:changeHeroTemp(group[1],group[2])
			elseif key == 2 then
				self:changeHeroTemp(group[2],group[3])
			end
			self:_refreshView()
		end,99)
		
		--往上
		btn_left:addClickListener(function()
			if key == 3 then
				self:changeHeroTemp(group[2],group[3])
			elseif key == 2 then
				self:changeHeroTemp(group[1],group[2])
			end
			self:_refreshView()
		end,99)
	end
end


function StrideSetArrayView:_initUI( )
	self:_initVM()
	self:_initListener()

end

return StrideSetArrayView