--[[
	name: VoidlandResultView 结算
	author: zn
]]

local VoidlandResultView = class("VoidlandResultView", Window)

function VoidlandResultView:ctor()
	self._packName = "Voidland";
	self._compName = "VoidlandResultView";
	self._rootDepth = LayerDepth.PopWindow;
end

function VoidlandResultView:_initUI()
	self.data = self._args.data;
	local root = self;
	local rootView = self.view;
		root.itemCell = BindManager.bindItemCell(rootView:getChildAutoType("itemCell"));
		root.txt_reward = rootView:getChildAutoType("txt_reward");
		root.txt_point = rootView:getChildAutoType("txt_point");
		root.progress = rootView:getChildAutoType("progress");
		root.list_award = rootView:getChildAutoType("list_award/list_reward");
		
	self:initFristItem();
	self:initListAward();
end

function VoidlandResultView:initFristItem()
	local ctrl = self.view:getController("first");
	ctrl:setSelectedIndex(1);
	local id = self.data.id--self._args.result and self._args.id or self._args.id - 1;
	local nearData = VoidlandModel:getNearFirstAward(id);
	local data = VoidlandModel:getPointInfoById(id);
	local distance = nearData.index - data.index;
	if (distance == 0 and VoidlandModel:isFinalWave(id)) then
		if (self.data.isFirst) then
			self.txt_reward:setText(Desc.Voidland_firstPass);
		else
			ctrl:setSelectedIndex(0);
		end
	else
		self.txt_reward:setText(string.format(Desc.Voidland_disAward, distance));
	end
	local award = nearData.passReward[1];
	self.itemCell:setData(award.code, award.amount, award.type);
	self.txt_point:setText(string.format(Desc.Voidland_point8, data.nodeId, data.index));
	self.progress:setMax(nearData.index);
	self.progress:setValue(data.index);
end

function VoidlandResultView:initListAward()
	local data = self.data.rewardList;
	local ctrl = self.view:getController("daily");
	if (data and next(data)) then
		ctrl:setSelectedIndex(0);
		self.list_award:setItemRenderer(function(idx, obj)
			local k = next(data, idx);
			local d = data[k];
			if (not obj.itemCell) then
				obj.itemCell = BindManager.bindItemCell(obj:getChildAutoType("itemCell"));
			end
			obj.itemCell:setData(d.code, d.amount, d.type);
		end)
		self.list_award:setNumItems(TableUtil.GetTableLen(data));
	else
		ctrl:setSelectedIndex(1);
	end
end

return VoidlandResultView