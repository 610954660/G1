--[[
	name: VoidlandRewardView 首通奖励
	author: zn
]]

local VoidlandRewardView = class("VoidlandRewardView", Window)

function VoidlandRewardView:ctor()
	self._packName = "Voidland";
	self._compName = "VoidlandRewardView";
	self._rootDepth = LayerDepth.PopWindow
	self.data = false;
	self.mode = self._args.modeType or 1;
	self.listScrollFlag = -1;
end

function VoidlandRewardView:_initUI()
	local root = self;
	local rootView = self.view;
		root.list_mode = rootView:getChildAutoType("list_mode");
		root.list_reward = rootView:getChildAutoType("list_reward");
	
	root.list_mode:setSelectedIndex(self.mode - 1);
	root.list_mode:addClickListener(function()
		self.mode = root.list_mode:getSelectedIndex() + 1;
		self:Voidland_infoUpdate(true);
	end)
	root.list_reward:setItemRenderer(function(idx, obj)
		self:upReward(idx, obj);
	end)
	root.list_reward:setVirtual();
	self:Voidland_infoUpdate(true);
end

function VoidlandRewardView:Voidland_infoUpdate(needScroll)
	self.data = VoidlandModel.confByPoint[self.mode];
	self.listScrollFlag = -1;
	self.list_reward:setNumItems(#self.data);
	
	for idx in ipairs(self.data) do
		local data = VoidlandModel:getPassRewardByPoint(idx, self.mode);
		for _, d in ipairs(data) do
			local state = VoidlandModel:getPassRewardState(d.id, self.mode);
			if (state == 1) then
				self.listScrollFlag = idx - 1;
				break;
			elseif (state == 0) then
				self.listScrollFlag = idx - 1;
				break;
			end
		end
		if (self.listScrollFlag ~= -1) then
			break;
		end
	end
	if (self.listScrollFlag == -1) then
		self.listScrollFlag = #self.data - 1;
	end
	if (needScroll) then
		self.list_reward:scrollToView(self.listScrollFlag, true);
	end
end

function VoidlandRewardView:upReward(idx, obj)
	local data = VoidlandModel:getPassRewardByPoint(idx+1, self.mode);
	obj:getChildAutoType("txt_point"):setText(string.format(Desc.Voidland_point5, idx+1));
	local txt_dis = obj:getChildAutoType("txt_dis")
	local landData = VoidlandModel:getCurModeData(self.mode);
	local conf = VoidlandModel:getNearFirstAward(landData.maxId + 1, self.mode);
	if (idx + 1 == conf.nodeId) then
		txt_dis:setText(string.format(Desc.Voidland_point6, conf.id - landData.maxId));
	elseif (idx + 1 > conf.nodeId) then
		txt_dis:setText(string.format(Desc.Voidland_point7, idx))
	else
		txt_dis:setText("");
	end
	local list = obj:getChildAutoType("list_item");
	list:setItemRenderer(function(idx1, obj)
		self:upRewardItem(obj, data[idx1 + 1], idx);
	end)
	list:setNumItems(#data)
end

function VoidlandRewardView:upRewardItem(obj, data, row)
	obj:setTitle(string.format(Desc.Voidland_point4, data.index));
	if (not obj.itemCell) then
		obj.itemCell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"));
	end
	local reward = data.passReward;
	obj.itemCell:setData(reward.code, reward.amount, reward.type);
	obj.itemCell:setClickable(false);
	local state = VoidlandModel:getPassRewardState(data.id, self.mode);
	obj.itemCell:setReceiveFrame(state == 1)
	obj.itemCell:setIsHook(state == 2)
	obj:removeClickListener(222)
	obj:addClickListener(function()
		if (state == 1) then
			VoidlandModel:getPassReward(data.id, self.mode);
		end
	end, 222)
end

function VoidlandRewardView:_addRed()
	-- body
	local children = self.list_mode:getChildren();
	for idx, child in ipairs(children) do
		RedManager.register("V_VOIDLAND_AWARDMODE_"..idx, child:getChildAutoType("img_red"));
	end
end

function VoidlandRewardView:_exit()
	-- body
end

function VoidlandRewardView:battle_end()
	self:closeView();
end

return VoidlandRewardView