--[[
	name: VoidlandMyAssView 我的外援
	author: zn
	废弃
]]

local VoidlandMyAssView = class("VoidlandMyAssView", Window)

function VoidlandMyAssView:ctor()
	self._packName = "Voidland";
	self._compName = "VoidlandMyAssView";
	self._rootDepth = LayerDepth.PopWindow
	self.maxAss = 6;
	VoidlandModel:getSelfPostHireList();
end

function VoidlandMyAssView:_initUI()
	local root = self;
	local rootView = self.view;
		root.txt_ass = rootView:getChildAutoType("txt_ass") -- 已派遣
		root.list_item = rootView:getChildAutoType("list_item");

	self.list_item:setItemRenderer(function(idx, obj)
		self:upItems(idx, obj);
	end)
	self._closeBtn:removeClickListener();
	self._closeBtn:addClickListener(function()
		self:closeView();
		VoidlandModel:saveSelfPostHire();
	end)
end

function VoidlandMyAssView:Voidland_upMyHire()
	self.txt_ass:setText(string.format(Desc.Voidland_assCount, TableUtil.GetTableLen(VoidlandModel.myHireArray), self.maxAss));
	self.list_item:setNumItems(self.maxAss);
end

function VoidlandMyAssView:upItems(idx, obj)
	local data = VoidlandModel.myHireArray[idx + 1];
	local ctrl = obj:getController("c1");
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
		obj:getChildAutoType("txt_heroName"):setText(conf.heroName);
		btn_remove:removeClickListener(222);
		btn_remove:addClickListener(function()
			VoidlandModel:removeMyHire(idx + 1)
		end, 222)
	end
end

function VoidlandMyAssView:_exit()
	-- body
end

return VoidlandMyAssView