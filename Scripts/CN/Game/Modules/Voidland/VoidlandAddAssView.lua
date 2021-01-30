--[[
	name: VoidlandAddAssView 添加我的外援
	author: zn
]]

local VoidlandAddAssView = class("VoidlandAddAssView", Window)

function VoidlandAddAssView:ctor()
	self._packName = "Voidland";
	self._compName = "VoidlandAddAssView";
	self._rootDepth = LayerDepth.PopWindow
	self.data = false;
	self.select = false;
end

function VoidlandAddAssView:_initUI()
	local root = self;
	local rootView = self.view;
		root.list_hero = rootView:getChildAutoType("list_hero");
		root.btn_add = rootView:getChildAutoType("btn_add");
		root.categoryChoose = rootView:getChildAutoType("categoryChoose");
	for i = 0, 5 do
		root["btn_category"..i] = root.categoryChoose:getChildAutoType("category"..i);
	end

	self.list_hero:setItemRenderer(function(idx, obj)
		self:upHero(idx, obj);
	end)
	self.list_hero:setVirtual();
	self:upHeroList(0);
end

function VoidlandAddAssView:_initEvent()
	local ctrl = self.categoryChoose:getController("category");
	for i = 0, 5 do
		self["btn_category"..i]:addClickListener(function()
			self:upHeroList(i);
			ctrl:setSelectedIndex(i);
		end)
	end
	self.btn_add:addClickListener(function()
		if (not self.select) then
			RollTips.show(Desc.Voidland_addAss);
			return;
		end
		self:closeView();
		VoidlandModel:addMyHire(self._args.index, self.select.uuid);
	end)
end

function VoidlandAddAssView:upHeroList(categroy)
	self.data = VoidlandModel:getMyHeroList(categroy);
	local sortMap = {{key="combat",asc=true}, {key="hasBattle",asc=true}, {key="star",asc=true},  {key="level",asc=true},{key="code",asc=false}};
	TableUtil.sortByMap(self.data, sortMap);
	self.list_hero:setNumItems(#self.data);
end

function VoidlandAddAssView:upHero(idx, obj)
	local data = self.data[idx + 1];
	if (not obj.heroCell) then
		obj.heroCell = BindManager.bindHeroCell(obj);
	end
	local conf = DynamicConfigData.t_hero[data.code];
	local info = {
		star = data.star,
		level = data.level,
		uuid = data.uuid,
		code = data.code,
		category = conf.category
	}
	local state = (self.select and self.select.uuid == data.uuid) and "on" or "out";
	obj:getController("state"):setSelectedPage(state);
	if (state == "on") then
		self.select.obj = obj;
	end
	obj.heroCell:setBaseData(info);
	obj:removeClickListener(222);
	obj:addClickListener(function()
		if (self.select) then
			self.select.obj:getController("state"):setSelectedPage("out");
		end
		obj:getController("state"):setSelectedPage("on");
		self.select = {
			obj= obj,
			uuid = data.uuid
		}
	end, 222)
end

return VoidlandAddAssView