local CustomsRecordView = class("CustomsRecordView",Window)
function CustomsRecordView:ctor(data)
 	self._packName 	= "BoundaryMap"
 	self._compName 	= "CustomsRecordView"
	self._rootDepth = LayerDepth.PopWindow
	self.__reloadPacket = true
end
function CustomsRecordView:_initUI()
	self.view:getChildAutoType("closeButton"):addClickListener(function()
		self:closeView()
	end)
	self.view:getChildAutoType("blackbg"):addClickListener(function()
		self:closeView()
	end)

	self.list = self.view:getChildAutoType("list")
	self.list:setItemRenderer(handler(self,self.listHandle))

	local arg = {layerId = BoundaryMapModel:getCurLayer(),difficult = BoundaryMapModel:getPowerDifficult()}
	RPCReq.Boundary_GetRankInfo(arg,function(data)
		
		if not data.data or not next(data.data) then
			self.view:getController("state"):setSelectedIndex(1)
		else
			self.list:setData(data.data)
		end
	end)
end
function CustomsRecordView:listHandle(index,obj)
	obj:getChild("name"):setText(self.list._dataTemplate[index + 1].name)
	obj:getChild("str_zhanli"):setText(StringUtil.transValue(self.list._dataTemplate[index + 1].combat))
	local starList = obj:getChildAutoType("starList")
	local starData = {0,0,0,0,0,0}
	for i = 1,self.list._dataTemplate[index + 1].value do
		starData[i] = 1
	end
	starList:setItemRenderer(function(index,obj)
		obj:getController("state"):setSelectedIndex(starData[index + 1])
	end)
	starList:setData(starData)
	obj:getChild("btn_record"):addClickListener(function()
		BattleModel:requestBattleRecord(self.list._dataTemplate[index + 1].battleUuid)
			
	end)
	obj:getChild("playerIcon"):setURL(PlayerModel:getUserHeadURL(self.list._dataTemplate[index + 1].head))
end
function CustomsRecordView:_exit()
end
return CustomsRecordView