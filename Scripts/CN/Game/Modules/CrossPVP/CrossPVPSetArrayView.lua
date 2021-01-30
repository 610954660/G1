local CrossPVPSetArrayView,Super = class("CrossPVPSetArrayView", Window)

function CrossPVPSetArrayView:ctor()
	self._packName = "CrossPVP"
	self._compName = "CrossPVPSetArrayView"
	self._rootDepth = LayerDepth.PopWindow
	self.__reloadPacket = true
	self.model = CrossPVPModel
end

function CrossPVPSetArrayView:_initEvent()
	
end

function CrossPVPSetArrayView:_initVM()
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:CrossPVP.CrossPVPSetArrayView
	self.closeButton = viewNode:getChildAutoType('$closeButton')--GLabel
	self.btn_save = viewNode:getChildAutoType('btn_save')--GButton
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.list = viewNode:getChildAutoType('list')--GList
	--{autoFieldsEnd}:CrossPVP.CrossPVPSetArrayView
	--Do not modify above code-------------
end

function CrossPVPSetArrayView:_initUI()
	self:_initVM()
	if self._args.model then
		self.model = self._args.model
	end
	self.closeButton:addClickListener(function()
		self:closeView()
	end)
	self.btn_save:addClickListener(function()
		self.model:refrushTypeHeroTempInfo(self.tempData)
		self:closeView()
	end)
	
	self.tempData = clone(self.model:getTypeHeroTempInfo())
	self:_refreshView()
end
function CrossPVPSetArrayView:heroListHander(index, obj)
	local heroCell = BindManager.bindHeroCell(obj)
	self:getHeroInfoById(heroId,uuid)
	heroCell:setData(self.showData[index + 1])
end
function CrossPVPSetArrayView:changeHeroTemp(p1,p2)
	if not p1 or not p2 then return false end
	local temp1 = self.tempData[p1].array
	local temp2 = self.tempData[p2].array
	self.tempData[p1].array = temp2
	self.tempData[p2].array = temp1
end 
function CrossPVPSetArrayView:_refreshView()
	local group = self.model:getCurEnumGroup()
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
		btn_right:addClickListener(function()
			if key == 1 then
				self:changeHeroTemp(group[1],group[2])
			elseif key == 2 then
				self:changeHeroTemp(group[2],group[3])
			end
			self:_refreshView()
		end,99)

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

function CrossPVPSetArrayView:onExit_()

end

return CrossPVPSetArrayView