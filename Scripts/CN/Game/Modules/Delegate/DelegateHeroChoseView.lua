
local DelegateConfiger = require "Game.ConfigReaders.DelegateConfiger";
local DelegateHeroChoseView, Super = class("DelegateHeroChoseView", Window);

local pointCostData = {
    code = 9,
    type = CodeType.MONEY,
    amount = 1000,
}
function DelegateHeroChoseView:ctor ()
	self._packName = "Delegate";
    self._compName = "DelegateHeroChoseView";
    self._rootDepth = LayerDepth.PopWindow

    -- 英雄列表
    self.list_hero = false;
    -- 种族筛选
    self.btn_category = {};
    for i = 0, 5 do
        self.btn_category[i] = false;
    end

    self.taskName = false;
    -- 队伍条件列表
    self.list_team = false;
    self.heroLimit = {};
    -- 加号
    self.btn_addHero = {};
    self.btn_addHeroItem = {}
    for i = 1, 3 do
        self.btn_addHero[i] = false;
        self.btn_addHeroItem[i] = false;
    end

    -- 派遣
    self.btn_ok = false;
    self.costItem_ok = false;
    -- 一键上阵
    self.btn_recom = false;
end

function DelegateHeroChoseView:_initUI()
    -- 英雄列表
    self.list_hero = self.view:getChildAutoType("heroList");
    self.list_hero:setVirtual();
    self.list_hero:setItemRenderer(function(idx, obj)
        self:upHeroListItem(idx, obj);
    end)
	
	local categoryChoose = self.view:getChildAutoType("categoryChoose");
    -- 种族选择
    for idx = 0, 5 do
        self.btn_category[idx] = categoryChoose:getChildAutoType("category"..idx);
        if (idx == 0) then
            self.btn_category[idx]:setSelected(true);
        end
    end

    self.taskName = self.view:getChildAutoType("txt_taskName");
    local data = DelegateModel.taskList[DelegateModel:getCurIdx()];
    local conf = DelegateConfiger.getConfByID(data.id);
    self.taskName:setText(conf.name);
    -- 队伍条件列表
    self.list_team = self.view:getChildAutoType("list_team");
    -- self.list_team:setVirtual();
    self.list_team:setItemRenderer(function(idx, obj)
        self.heroLimit[idx + 1] = obj;
    end)

    -- 加号
    for idx in ipairs(self.btn_addHero) do
        self.btn_addHero[idx] = self.view:getChildAutoType("btn_hero"..idx);
        self.btn_addHeroItem[idx] = BindManager.bindCardCell(self.btn_addHero[idx]:getChildAutoType("cardItem"));
    end

    -- 派遣
    self.btn_ok = self.view:getChildAutoType("btn_ok")
    self.costItem_ok = BindManager.bindCostButton(self.btn_ok);
    self.costItem_ok:setData(pointCostData);
    -- 一键上阵
    self.btn_recom = self.view:getChildAutoType("btn_recom");

    self:changeCategory(0);
    self:delegate_upWaitList();
end

function DelegateHeroChoseView:_initEvent()
    -- 种族切页
    for idx = 0, 5 do
        self.btn_category[idx]:addClickListener(function()
            self:changeCategory(idx);
        end)
    end
    -- 加号展示英雄取消选中
    for idx in ipairs(self.btn_addHero) do
        self.btn_addHero[idx]:addClickListener(function()
            local data = DelegateModel.waitList[idx];
            if (data) then
                self:removeFromWait(data);
                self.list_hero:setNumItems(#DelegateModel.showHeroList);
            end
        end)
    end
    -- 派遣
    self.btn_ok:addClickListener(function ()
        self:clickBtnOk();
    end)
    -- 一键上阵
    self.btn_recom:addClickListener(function ()
        self:clickBtnRecom();
    end)
end

-- 更新英雄列表组件
function DelegateHeroChoseView:upHeroListItem(idx, obj)
    local data = DelegateModel.showHeroList[idx + 1];
    local ctrl = obj:getController("c1");
    if (not obj.lua_sript) then
        obj.lua_sript = BindManager.bindCardCell(obj);
    end
    local info = DelegateModel:rebuildStruct(data);
    obj.lua_sript:setData(info, true);
    -- 初始选中状态
    local i = DelegateModel:existInWait(data) and 2 or 0;
    ctrl:setSelectedIndex(i);

    obj:removeClickListener(22);
    obj:addClickListener(function()
        if (ctrl:getSelectedIndex() == 0 and DelegateModel:addToWait(data)) then
            ctrl:setSelectedIndex(2);
        elseif (ctrl:getSelectedIndex() == 2) then
            ctrl:setSelectedIndex(0);
            self:removeFromWait(data);
        end
    end, 22)
end

function DelegateHeroChoseView:removeFromWait(cardInfo)
    DelegateModel:removeFromWait(cardInfo.uuid);
end

-- 更新等待列表
function DelegateHeroChoseView:delegate_upWaitList()
    local list = DelegateModel.waitList;
    for i = 1, 3 do
        local data = list[i];
        local ctrl = self.btn_addHero[i]:getController("c1");
        if (data ~= nil) then
            ctrl:setSelectedIndex(1);
            self.btn_addHeroItem[i]:setData(DelegateModel:rebuildStruct(data), true);
        else
            ctrl:setSelectedIndex(0);
        end
    end
    self:upTeamLimit();
end

-- 改变种族 -0 全 1 仙 魔 兽 人 械
function DelegateHeroChoseView:changeCategory(idx)
    DelegateModel:upShowListByCategory(idx);
    local ctrl = self.view:getController("c1");
    if (#DelegateModel.showHeroList > 0) then
        ctrl:setSelectedIndex(0);
        self.list_hero:setNumItems(#DelegateModel.showHeroList);
    else
        ctrl:setSelectedIndex(1);
    end
    
end

-- 更新队伍条件
function DelegateHeroChoseView:upTeamLimit()
    local task = DelegateModel.taskList[DelegateModel:getCurIdx()];
    local conf = DelegateConfiger.getConfByID(task.id);
    local starLimit = conf.starRequire;
    local cateLimit = conf.categoryRequire;
    self.list_team:setNumItems(#starLimit + #cateLimit);
    local _, starFlag, cateFlag = DelegateModel:checkCondition();
    local cateDesc = {
        Desc.common_category1,
        Desc.common_category2,
        Desc.common_category3,
        Desc.common_category4,
        Desc.common_category5,
    };
    for idx = 1, #starLimit + #cateLimit do
        local obj = self.heroLimit[idx];
        local ctrl = obj:getController("c1");
        local desc = false;
        local gray = false;
        if (idx <= #cateLimit) then
            -- LuaLog(idx, cateLimit[idx].param, cateLimit[idx].amount, cateDesc[cateLimit[idx].param]);
            ctrl:setSelectedIndex(cateLimit[idx].param);
            local name = cateDesc[cateLimit[idx].param]
            desc = string.format(Desc.delegate_str1, cateLimit[idx].amount, name);
            gray = cateFlag[idx] ~= true;
        else
            local i = idx - #cateLimit;
            local param = starLimit[i].param;
            local amount = starLimit[i].amount;
            ctrl:setSelectedIndex(0);
            obj:getChildAutoType("star"):setText(param);
            desc = string.format(Desc.delegate_str2, amount, Desc["common_"..param]);
            gray = starFlag[i] ~= true;
        end
        obj:setTitle(desc);
        obj:setGrayed(gray);
    end
end

-- 派遣
function DelegateHeroChoseView:clickBtnOk()
    DelegateModel:starTask(function ()
        self:closeView();
    end);
end

-- 一键上阵
function DelegateHeroChoseView:clickBtnRecom()
    local flag = DelegateModel:getRecomList();
    if (flag ~= true) then
        RollTips.show(Desc.delegate_cannotRecom);
        DelegateModel:clearWait();
    end
    self.list_hero:setNumItems(#DelegateModel.showHeroList);
end

return DelegateHeroChoseView