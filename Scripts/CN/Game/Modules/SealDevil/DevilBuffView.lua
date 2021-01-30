--[[
name: DevilBuffView
author: zn
]]

local base = require "Game.Modules.Voidland.VoidSkillBaseView";
local DevilBuffView = class("DevilBuffView", Window)

function DevilBuffView:ctor()
	self._packName = "SealDevil";
	self._compName = "DevilBuffView";
	self.selectedItem = false;
	self._rootDepth = LayerDepth.PopWindow
	self.skillList = {}
	self.select = 1--math.random(#self.skillList);
	self.countDown = 30;
	self.timer = false;
	print(2233, "====== 技能界面打开")
	for _, skill in pairs(self._args.skillList) do
		table.insert(self.skillList, skill);
	end
end


function DevilBuffView:_initUI()
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
			SealDevilModel:devilRoad_Action(self.skillList[self.select],function ()
					if (tolua.isnull(self.view)) then return end
					self:closeView();
			end)
			table.insert(SealDevilModel.curBuffs,self.skillList[self.select])
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

function DevilBuffView:_initEvent()
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
				SealDevilModel:devilRoad_Action(self.skillList[self.select],function ()
						if (tolua.isnull(self.view)) then return end
						self:closeView();
				end)
				table.insert(SealDevilModel.curBuffs,self.skillList[self.select])			
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



function DevilBuffView:afterInit()
	

	
	self.selectedItem = self.view:getChildAutoType("selected");
	local ctrl = self.view:getController("c1");
	local ctrl2 = self.view:getController("c2");
	self.list_skill:removeClickListener();
	self.list_skill:addEventListener(FUIEventType.TouchBegin, function()
			self.select = self.list_skill:getSelectedIndex() + 1;
			self:upSkillItems(self.select - 1, self.selectedItem);
			ctrl:setSelectedIndex(self.select - 1);
			if (ctrl2:getSelectedIndex() == 0) then
				ctrl2:setSelectedIndex(1);
			end
		end)
	self:upSkillItems(self.select - 1, self.selectedItem);
	ctrl:setSelectedIndex(self.select - 1);
	ctrl2:setSelectedIndex(1);
end

function DevilBuffView:upSkillItems(idx, obj)
	local skillId = self.skillList[idx + 1];
	local icon = obj:getChildAutoType("icon");
	local skillInfo = DynamicConfigData.t_skill[skillId]
	if skillInfo then
		-- local ultSkillurl = ModelManager.CardLibModel:getItemIconByskillId(skillInfo.icon)
		-- icon:setURL(ultSkillurl) --放了一张技能图片
		-- obj:getChildAutoType("txt_skillName"):setText(skillInfo.skillName);
		obj:getChildAutoType("txt_desc"):setText(skillInfo.showName);
	end

	local VoidSkillConf = DynamicConfigData.t_DevilRoadSkill[skillId];
	if (VoidSkillConf) then
		local ultSkillurl = ModelManager.CardLibModel:getItemIconByskillId(VoidSkillConf.icon)
		icon:setURL(ultSkillurl) --放了一张技能图片
		obj:getChildAutoType("txt_skillName"):setText(VoidSkillConf.name);
		local ctrl = obj:getController("c1");
		ctrl:setSelectedIndex(VoidSkillConf.color or 3);
	end
end

function DevilBuffView:_exit()
	Scheduler.unschedule(self.timer)
	if self._args.exitFunc then
		self._args.exitFunc()
	end
	
end


return DevilBuffView