--[[
	name: AddVoidlandSingleView
	author: zn
]]

local AddVoidlandSingleView = class("AddVoidlandSingleView", Window)

function AddVoidlandSingleView:ctor()
	self._packName = "Voidland";
	self._compName = "AddVoidlandSingleView";
	self._rootDepth = LayerDepth.WindowUI;
end

function AddVoidlandSingleView:_initUI()
	local root = self;
	local rootView = self.view;
		for i = 1, 2 do
			local heroCell = BindManager.bindHeroCell(rootView:getChildAutoType("heroCell"..i));
			root["heroCell"..i] = heroCell;
			heroCell.view:setVisible(false);
		end

	
end

function AddVoidlandSingleView:_initEvent()
	for i = 1, 2 do
		local heroCell = self["heroCell"..(i)];
		heroCell.view:addClickListener(function()
			VoidlandModel:removeSingleListArray(heroCell.uuid);
		end)
	end
	self:Voidland_upSingleList();
end

function AddVoidlandSingleView:Voidland_upSingleList()
	for k, info in pairs(VoidlandModel.singleList) do
		if (k > 1) then
			local heroCell = self["heroCell"..(k-1)];
			if (info) then
				local conf = DynamicConfigData.t_hero[info.code];
				local data = CardLibModel:getHeroByUid(info.uuid);
				local heroInfo = {
					category = conf.category,
					star = data.star,
					level = data.level,
					code = info.code,
					uuid = info.uuid,
					fashion = info.fashionCode
				}
				heroCell.view:setVisible(true);
				heroCell:setBaseData(heroInfo);
			else
				heroCell.view:setVisible(false);
			end
		end
	end
end

return AddVoidlandSingleView