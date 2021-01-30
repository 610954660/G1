--[[
	name: VoidlandAssView 好友外援
	author: zn
]]

local VoidlandAssView = class("VoidlandAssView", Window)

function VoidlandAssView:ctor()
	self._packName = "Voidland";
	self._compName = "VoidlandAssView";
	self._rootDepth = LayerDepth.PopWindow
	self.maxAss = 6;
	VoidlandModel:getHireList();
	self.data = false;
	self.viewType = 0;
end

function VoidlandAssView:_initUI()
	local root = self;
	local rootView = self.view;
		root.txt_assed = rootView:getChildAutoType("txt_assed");
		root.list_heroes = rootView:getChildAutoType("list_heroes");
		root.list_page = rootView:getChildAutoType("list_page");

	self.list_page:setSelectedIndex(0);
	self.list_heroes:setItemRenderer(function(idx, obj)
		if (self.viewType == 0) then
			self:upHeroItem(idx, obj);
		elseif (self.viewType == 1) then
			self:upMyHeroItems(idx, obj);
		end
	end)
end

function VoidlandAssView:_initEvent()
	self.list_page:addClickListener(function ()
		if (self.list_page:getSelectedIndex() == 0) then
			VoidlandModel:getHireList();
			VoidlandModel:saveSelfPostHire();
		else
			VoidlandModel:getSelfPostHireList();
		end
	end)

	self._closeBtn:removeClickListener();
	self._closeBtn:addClickListener(function()
		self:closeView();
		VoidlandModel:saveSelfPostHire();
	end)

	self.view:getChildAutoType("closebg"):addClickListener(function ()
		self:closeView();
		VoidlandModel:saveSelfPostHire();
	end)
end

function VoidlandAssView:Voidland_upMyHire()
	if (self.list_page:getSelectedIndex() == 0) then
		return
	end
	self.viewType = 1;
	self.data = VoidlandModel.myHireArray;
	self.txt_assed:setText(string.format(Desc.Voidland_assCount, TableUtil.GetTableLen(self.data), self.maxAss));
	self.list_heroes:setNumItems(self.maxAss);
	self.view:getController("c1"):setSelectedIndex(1);
end

function VoidlandAssView:Voidland_upAssList()
	if (self.list_page:getSelectedIndex() ~= 0) then
		return
	end
	self.viewType = 0;
	self.txt_assed:setText(string.format(Desc.Voidland_assCount, VoidlandModel.hireCount, 2));
	self.data = VoidlandModel.hireList;
	local ctrl = self.view:getController("c1");
	if (#self.data > 0) then
		self.list_heroes:setNumItems(#self.data);
		ctrl:setSelectedIndex(1);
	else
		ctrl:setSelectedIndex(0);
	end
end

-- 更新可雇佣列表
function VoidlandAssView:upHeroItem(idx, obj)
	obj:getController("c2"):setSelectedIndex(0);
	local data = self.data[idx + 1];
	local txt_name = obj:getChildAutoType("txt_name");
	local txt_power = obj:getChildAutoType("txt_power");
	local txt_friend = obj:getChildAutoType("txt_friend");
	local btn_hire = obj:getChildAutoType("btn_hire");
	if (not obj.heroCell) then
		obj.heroCell = BindManager.bindHeroCell(obj:getChildAutoType("playerCell"));
	end
	local conf = DynamicConfigData.t_hero[data.code];
	data.category = conf.category;
	obj.heroCell:setBaseData(data);
	txt_name:setText(conf.heroName);
	txt_power:setText(StringUtil.transValue(data.combat));
	txt_friend:setText(data.friendName);
	obj:getController("c1"):setSelectedIndex(data.state);
	btn_hire:removeClickListener(222);
	btn_hire:addClickListener(function()
		if (VoidlandModel.hireCount < 2) then
			-- VoidlandModel:hireFirend(data.friendId, data.uuid, idx + 1);
			ViewManager.open("VoidlandAssTipsView", {data = data, idx = idx + 1});
		else
			RollTips.show(Desc.Voidland_maxAssed);
		end
		
	end, 222)
end

-- 更新自己的派遣列表
function VoidlandAssView:upMyHeroItems(idx, obj)
	local data = self.data[idx + 1];
	local ctrl = obj:getController("c3");
	obj:getController("c2"):setSelectedIndex(1);
	if (not data) then -- 无数据
		ctrl:setSelectedIndex(0);
		local addFrame = obj:getChildAutoType("btn_addFrame");
		local addbtn = obj:getChildAutoType("btn_add");
		addFrame:removeClickListener(222);
		addFrame:addClickListener(function()
			ViewManager.open("VoidlandAddAssView", {index = idx + 1});
		end, 222)
		addbtn:removeClickListener(222);
		addbtn:addClickListener(function()
			ViewManager.open("VoidlandAddAssView", {index = idx + 1});
		end, 222)
	else
		ctrl:setSelectedIndex(1);
		if (not obj.heroCell) then
			obj.heroCell = BindManager.bindHeroCell(obj:getChildAutoType("playerCell"));
		end
		local btn_remove = obj:getChildAutoType("btn_remove");
		local hero = CardLibModel:getHeroByUid(data.uuid);
		local conf = DynamicConfigData.t_hero[hero.code];
		local info = {
			star = hero.star,
			level = hero.level,
			uuid = hero.uuid,
			code = hero.code,
			category = conf.category
		}
		obj.heroCell:setBaseData(info);
		local str = data.isHire and Desc.Voidland_assed or Desc.Voidland_noneAss;
		obj:getChildAutoType("txt_onDesc"):setText(str);
		obj:getChildAutoType("txt_name"):setText(conf.heroName);
		btn_remove:removeClickListener(222);
		btn_remove:addClickListener(function()
			VoidlandModel:removeMyHire(idx + 1)
		end, 222)
	end
end

return VoidlandAssView