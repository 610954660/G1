-- add by xhd
-- 跨服赛显示玩家信息cell

local StrideCell = class("StrideCell", BindView)

function StrideCell:ctor()
    self.playerCell = false;
	self.data = false;
	self.playName = false
	self.serverName = false
	self.statusCtrl = false
	self.rIndex = false
	self.wenCtrl = false
end

function StrideCell:_initUI()
    local playerCell = self.view:getChildAutoType("playerCell");
    if (playerCell) then
        self.playerCell = BindManager.bindPlayerCell(playerCell)
	end
	self.playName = self.view:getChildAutoType("playName");
	self.serverName = self.view:getChildAutoType("serverName");
	self.rIndex = self.view:getChildAutoType("rIndex");
end


function StrideCell:setData(data)
	self.wenCtrl = self.view:getController("wenCtrl");
	self.statusCtrl = self.view:getController("statusCtrl");
	if not data then
		self.wenCtrl:setSelectedIndex(1)
		return
	else
		self.wenCtrl:setSelectedIndex(0)
	end
    self.data = data

	if (self.statusCtrl) then
		if self.data.rank >=1 and self.data.rank<=3 then
			self.statusCtrl:setSelectedIndex(self.data.rank);
		elseif self.data.rank<=10 then
			self.statusCtrl:setSelectedIndex(4);
			self.rIndex:setText(self.data.rank)
		else
			self.statusCtrl:setSelectedIndex(0);
		end
	end

	if self.playName then
		self.playName:setText(self.data.name)
	end

	if self.serverName then
		-- local serverName = ""
		-- local serverGroup = LoginModel:getServerGroups()
		-- for _, d in pairs(serverGroup) do
		-- 	for _, info in pairs(d) do
		-- 		if (info.unit_server == self.data.serverId) then
		-- 			serverName = info.name;
		-- 		end
		-- 	end
		-- end
		self.serverName:setText(string.format("[S.%s]",self.data.serverId))
		-- self.serverName:setText(serverName);
	end
    
	self.playerCell:setHead(self.data.head, self.data.level, self.data.playerId, self.data.name, self.data.headBorder)
	self.view:removeEventListeners()
	self.view:getChildAutoType("playerCell"):addClickListener(function() 
		if self.data.playerId<0 then
			RollTips.show(Desc.Friend_cant_show)
			return
		end
		--这里可能有疑问 是否打开的是这个页面
		ViewManager.open(
			"ViewPlayerView",
			{playerId = self.data.playerId, serverId = self.data.serverId, arrayType = GameDef.BattleArrayType.TopArenaAckOne} --这里的type应该有问题
		)
	end,100)
end


return StrideCell