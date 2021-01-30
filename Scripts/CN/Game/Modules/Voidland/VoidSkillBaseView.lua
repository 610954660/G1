--[[
	name: VoidSkillBaseView
	author: zn
]]

local VoidSkillBaseView = class("VoidSkillBaseView", Window)

function VoidSkillBaseView:ctor()
	self._rootDepth = LayerDepth.PopWindow
	self.skillList = {}
	for _, skill in pairs(VoidlandModel.skillSelect) do
		table.insert(self.skillList, skill);
	end
	self.select = 1--math.random(#self.skillList);

	self.countDown = 30;
	self.timer = false;
	print(2233, "====== 技能界面打开")
end

function VoidSkillBaseView:_initUI()
	local root = self;
	local rootView = self.view;
		root.list_skill = rootView:getChildAutoType("list_skill");
		root.txt_countDown = rootView:getChildAutoType("txt_countDown");
		root.btn_cancel = rootView:getChildAutoType("btn_cancel");
		root.btn_ok = rootView:getChildAutoType("btn_ok");
		root.bg = rootView:getChildAutoType("bg");
		root.role = rootView:getChildAutoType("role")

	local countFunc = function(dt)
		self.countDown = math.max(self.countDown - dt, 0);
		self.txt_countDown:setText(string.format(Desc.Voidland_autoClose, math.floor(self.countDown)))
		if (self.countDown == 0 and self.timer) then
			VoidlandModel:setSelectSkill(self.select, function()
				Dispatcher.dispatchEvent(EventType.Voidland_battle);
				if (tolua.isnull(self.view)) then return end
				self:closeView();
			end);
			Scheduler.unschedule(self.timer);
		end
	end
	self.timer = Scheduler.schedule(countFunc, 1);
	if (self.bg and self.bgUrl) then
		self.bg:setIcon(self.bgUrl);
	end

	if (self.role and self.roleUrl) then
		self.role:setIcon(self.roleUrl);
	end
end

function VoidSkillBaseView:_initEvent()
	if (self.list_skill) then
		self.list_skill:setItemRenderer(function(idx, obj)
			self:upSkillItems(idx, obj);
		end)
		self.list_skill:setNumItems(#self.skillList);
		self.list_skill:setSelectedIndex(self.select - 1);
		self.list_skill:addClickListener(function()
			self.select = self.list_skill:getSelectedIndex() + 1
		end)
	end

	if (self.btn_ok) then
		self.btn_ok:addClickListener(function()
			VoidlandModel:setSelectSkill(self.select, function()
				Dispatcher.dispatchEvent(EventType.Voidland_battle);
				if (tolua.isnull(self.view)) then return end
				self:closeView();
			end);
		end)
	end

	if (self.btn_cancel) then
		self.btn_cancel:addClickListener(function()
			VoidlandModel:setSelectSkill(0, function()
				Dispatcher.dispatchEvent(EventType.Voidland_battle);
				if (tolua.isnull(self.view)) then return end
				self:closeView();
			end);
		end)
	end
	self:afterInit();
end

-- 子类重写
function VoidSkillBaseView:upSkillItems(idx, obj)
-- 	local skillId = self.skillList[idx + 1];
-- 	local skillCell = BindManager.bindSkillCell(obj:getChildAutoType("skillCell"))
-- 	local skillConf = DynamicConfigData.t_skill[skillId];
-- 	skillCell:setData(skillId);
-- 	obj:getChildAutoType("txt_skillName"):setText(skillConf.skillName);
-- 	obj:getChildAutoType("txt_desc"):setText(skillConf.showName);
end

-- 子类重写
function VoidSkillBaseView:afterInit()

end

function VoidSkillBaseView:battle_end()
	self:closeView();
end

function VoidSkillBaseView:_exit()
	if (self.timer) then
		Scheduler.unschedule(self.timer);
	end
end

return VoidSkillBaseView