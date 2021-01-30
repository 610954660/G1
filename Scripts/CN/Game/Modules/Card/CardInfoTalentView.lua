---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by:技能学习
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local FGUIUtil = require "Game.Utils.FGUIUtil"
local ItemCell = require "Game.UI.Global.ItemCell"
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger"
local CardInfoTalentView, Super = class("CardInfoTalentView", Window)
function CardInfoTalentView:ctor()
    self._packName = "CardSystem"
    self._compName = "CardInfoTalentView"
	self._isFullScreen = false

    self.skillActiveBtn = false
    self.btn_learn = false
	self.skillBoard = false
	
	self._cardcgInfo = false
	
	self.c1 = false
	self.uuid = 0
	self.animTimer = false;
end

function CardInfoTalentView:_initUI()
	
	
	self.btn_learn = self.view:getChildAutoType("btn_learn")
	self.skillBoard  = self.view:getChildAutoType("skillBoard")
	self.c1 = self.skillBoard:getController("c1")
	self.btn_learn:addClickListener(function ( ... )
		local HeroInfo = ModelManager.CardLibModel.curCardStepInfo
		if (not HeroInfo) then
			return;
		end
		if (TableUtil.GetTableLen(HeroInfo.passiveSkill) >= 9) then
			ViewManager.open("CardTalentLearnSkillView", {heroInfo = ModelManager.CardLibModel.curCardStepInfo})
		else
			RollTips.show(Desc.card_talentLearnNotOpen);
		end
	end,33)
	
	self:_refresh();
end

function CardInfoTalentView:cardView_updateInfo(_, param)
	if not param or (param.type ~= "learnTalent") then
		self:_refresh();
	end
end

--设置卡牌(英雄)详情
function CardInfoTalentView:_refresh()
	self:stopLearnAnim();
    -- print(5, index, self._cardcgInfo, "升级")
    local HeroInfo = ModelManager.CardLibModel.curCardStepInfo
    if not HeroInfo then
        return
	end
	self.btn_learn:setGrayed(TableUtil.GetTableLen(HeroInfo.passiveSkill) < 9)
    self:updateHeroInfo(HeroInfo)
end

--更新卡牌详情信息
function CardInfoTalentView:updateHeroInfo(HeroInfo)
    self.heroInfo = HeroInfo
	self.uuid = self.heroInfo.uuid
    --显示卡牌名字
    local ultSkill, passiveSkill = ModelManager.CardLibModel:getSkillList(HeroInfo.code)
    --获取英雄的技能列表
    printTable(5, "卡牌技能属性id", ultSkill, passiveSkill)
    self:setSkill(ultSkill, passiveSkill, HeroInfo)
    RedManager.updateValue("V_CardTaletLevel"..self.uuid, false)
end

--设置技能列表的技能(分主动技能和被动技能)
function CardInfoTalentView:setSkill(ultSkill, passive, heroInfo)
    -- self.passiveSkill={};
    -- for key, value in pairs(heroInfo.passiveSkill) do
    --     table.insert( self.passiveSkill, value.id) 
    -- end

    -- for key, value in pairs(heroInfo.reservedSkill) do
    --     table.insert( self.passiveSkill, value.id) 
	-- end
	self:sortSkillList(heroInfo);
    printTable(8, ">>>>>>>>>>>>?1督导员大师傅阿萨德f",self.passiveSkill)
   
	self:updateAllItem(heroInfo)
	
end

function CardInfoTalentView:updateAllItem(heroInfo)
	heroInfo = heroInfo == nil and CardLibModel.curCardStepInfo or heroInfo;
	self.c1:setSelectedIndex(#self.passiveSkill)
	for i = 1,#self.passiveSkill, 1 do
		local item = self.skillBoard:getChildAutoType("skillItem_"..i)
		self:refreshSkiilItem(i - 1, item, heroInfo)
	end
end

function CardInfoTalentView:refreshSkiilItem(index, obj, heroInfo)
	obj:removeClickListener(100)
	local passiveId = self.passiveSkill[index + 1]
	--池子里面原来的事件注销掉
	local passiveInfo = DynamicConfigData.t_passiveSkill[passiveId]
	obj:addClickListener(
		function(context)
			--local passiveId = self.passiveSkill[index + 1]
			if not heroInfo.passiveSkill[passiveId] then  --没激活的打开激活窗口
				ViewManager.open("CardTalentActiveSkillView", {passiveInfo}) 
			else
				--ViewManager.open("CardTalentSkillTipsView", {passiveInfo, 2}) 
				ViewManager.open("ItemTips", {codeType = CodeType.PASSIVE_SKILL, id = passiveInfo.id, data = passiveInfo})
			end
		end,
		100
	)
	
	local itemCell = BindManager.bindItemCell(obj)
	itemCell:setClickable(false)
	itemCell:setAmountVisible(false);
	itemCell:setData(passiveId, 1, CodeType.PASSIVE_SKILL)
	local frameUrl = PathConfiger.getPassiveSkillFrame(passiveInfo.quality);
	itemCell.view:getChildAutoType("frame"):setIcon(frameUrl);
	
	local lockCtrl = obj:getController("isLock")
	RedManager.register("V_passiveSkill"..self.uuid.."_"..passiveId, obj:getChild("img_red"))

	local skillPass = obj:getChild("skillPass")
	if heroInfo.passiveSkill[passiveId] then
		--skillPass:setText("已激活")
		lockCtrl:setSelectedIndex(1)
	end
	if heroInfo.reservedSkill[passiveId] then
		--skillPass:setText("未激活")
		lockCtrl:setSelectedIndex(0)
	end
end


function CardInfoTalentView:cardView_CardAddAndDeleInfo(_, data)
    printTable(8, "卡牌属性更新")
    local info= ModelManager.CardLibModel.curCardStepInfo;
    local HeroInfo= CardLibModel:getHeroByUid(info.uuid)
	self.heroInfo=HeroInfo;
	self:sortSkillList();
    -- self.passiveSkill={};
    -- for key, value in pairs(HeroInfo.passiveSkill) do
    --     table.insert( self.passiveSkill, value.id) 
    -- end

    -- for key, value in pairs(HeroInfo.reservedSkill) do
    --     table.insert( self.passiveSkill, value.id) 
    -- end
    --获取英雄的技能列表
 
    --self:updateHeroInfo(HeroInfo)
end


function CardInfoTalentView:cardView_activeSkillSuc(_, data)
    printTable(8, "卡牌被动技能激活返回", data)
    if data then
        -- self.passiveSkill={};
        -- for key, value in pairs(self.heroInfo.passiveSkill) do
        --     table.insert( self.passiveSkill, value.id) 
        -- end
    
        -- for key, value in pairs(self.heroInfo.reservedSkill) do
        --     table.insert( self.passiveSkill, value.id) 
		-- end
		
		self:sortSkillList();
        --获取英雄的技能列表
        self:updateAllItem(data.hero)
    end
end

-- 技能学习成功
function CardInfoTalentView:CardView_talentLearnSuc(_, data, param)
	if data then
		local endIdx = 0
		self:sortSkillList();
		for idx, id in ipairs(self.passiveSkill) do
			if (id == param.skillId) then
				endIdx = idx
				break;
			end
		end
		-- 动画
		self:talentLearnAnim(endIdx, function ()
			--获取英雄的技能列表
			self:updateAllItem(data.hero)
			Dispatcher.dispatchEvent("CardView_showTanlentLearnSuc", data.hero, param);
		end);
    end
end

function CardInfoTalentView:sortSkillList(heroInfo)
	heroInfo = heroInfo == nil and self.heroInfo or heroInfo;
	self.passiveSkill={};
	if (TableUtil.GetTableLen(heroInfo.reservedSkill) ~= 0) then
		for _, value in pairs(heroInfo.passiveSkill) do
			table.insert(self.passiveSkill, value.id);
		end
		for _, value in pairs(heroInfo.reservedSkill) do
			table.insert(self.passiveSkill, value.id);
		end
	else
		local uuid = heroInfo.uuid;
		if (CardLibModel.cardTalentLearnMap[uuid]) then
			local map = CardLibModel.cardTalentLearnMap[uuid];
			local m = {}
			local flag = false;
			for i, id in ipairs(map) do
				if (heroInfo.passiveSkill[id]) then
					self.passiveSkill[i] = id;
					m[id] = true;
				else
					flag = i;
				end
			end
			for id in pairs(heroInfo.passiveSkill) do
				if (not m[id]) then
					self.passiveSkill[flag] = id;
					break;
				end
			end
			CardLibModel.cardTalentLearnMap[uuid] = self.passiveSkill;
		else
			CardLibModel.cardTalentLearnMap[uuid] = {};
			local map = CardLibModel.cardTalentLearnMap[uuid];
			local i = 1;
			for _, value in pairs(heroInfo.passiveSkill) do
				map[i] = value.id;
				table.insert(self.passiveSkill, value.id);
				i = i + 1;
			end
		end
	end
	
end

-- 特性学习动画
function CardInfoTalentView:talentLearnAnim(endIdx, cb)
	local arr = {}
	for i = 1,#self.passiveSkill, 1 do
		local item = self.skillBoard:getChildAutoType("skillItem_"..i)
		table.insert(arr, item);
	end
	local grid = self.skillBoard:getChildAutoType("grid");
	grid:setVisible(true);
	grid:setAlpha(1);
	grid:setPosition(arr[1]:getX(), arr[1]:getY());
	local count = 1;
	local timeCount = 0;
	local animFunc = function (dt)
		if (tolua.isnull(self.view)) then return end;
		if (count < 18) then
			if (timeCount > count * math.pow(1.066, count) * 0.05) then
				count = count + 1;
				local idx = count > 9 and count - 9 or count;
				local item = arr[idx];
				grid:setPosition(item:getX(), item:getY());
			end
		elseif (timeCount > count * math.pow(1.07, count) * 0.05) then
			local item = arr[endIdx];
			grid:setPosition(item:getX(), item:getY());
			self.skillBoard:getTransition("t1"):play(function ()
				if (tolua.isnull(self.view)) then return end;
				grid:setVisible(false);
				if (cb) then cb() end;
			end)
			if (self.animTimer) then
				Scheduler.unschedule(self.animTimer);
				self.animTimer = false;
			end
		end

		timeCount = timeCount + dt;
	end
	self.animTimer = Scheduler.schedule(animFunc, 0);
end

function CardInfoTalentView:stopLearnAnim()
	if (self.animTimer) then
		Scheduler.unschedule(self.animTimer);
		self.animTimer = false;
		self.skillBoard:getChildAutoType("grid"):setVisible(false);
	end
end

function CardInfoTalentView:_enter()
end

function CardInfoTalentView:_exit()
	if (self.animTimer) then
		Scheduler.unschedule(self.animTimer);
		self.animTimer = false;
	end
end

return CardInfoTalentView
