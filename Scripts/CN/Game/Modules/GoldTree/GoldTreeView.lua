
-- added by zn
-- 摇钱树

local TimeLib = require "Game.Utils.TimeLib";
local TimeUtil = require "Game.Utils.TimeUtil";
local GoldTreeView, Super = class("GoldTreeView", Window);

function GoldTreeView:ctor()
	self._packName = "GoldTree";
    self._compName = "GoldTreeView";
    self._rootDepth = LayerDepth.PopWindow;
    
    self.bg = false;
    self.item = {};
    -- 帮助按钮
    self.btn_help = false;
    self.btn_privilige = false;
    -- 刷新倒计时
    self.txt_countDown = false;
    -- 倒计时
    self.timer = false;
end

function GoldTreeView:_initUI()
    self:setBg('bg_GoldTree.png');

    for i=1, 3 do
        self.item[i] = self.view:getChild('item_'..i);
    end

    self.txt_count = self.view:getChild('txt_countdown');
    self.btn_privilige = self.view:getChild('btn_privilige');

    self.tipsFrame = self.view:getChild('tipsFrame');
    self.tipsFrame:setTitle(Desc.help_StrTitle47);
    self.tipsFrame:getChild("desc"):setText(Desc.help_StrDesc47);
	
	self.btn_privilige:addClickListener(function ()
		ModuleUtil.openModule(ModuleId.PriviligeGiftView.id);
	end)
    self:GoldTree_UpView();
end

function GoldTreeView:GoldTree_UpView()
    if (tolua.isnull(self.view)) then return end;
    for idx in ipairs(self.item) do
        self:upItemInfo(idx);
        self:initBtnGet(idx);
    end
    PushMapModel:getMaxCityAndChapterAndPoint();
    self:upCountDown();
end

function GoldTreeView:initBtnGet(idx)
    local conf = DynamicConfigData.t_GoldTree[idx];
    local btnGet = self.item[idx]:getChild('btn_get');
    local cost = {type = CodeType.MONEY, code = GameDef.MoneyType.Diamond, amount = conf.price};
    local ctrl = btnGet:getController("iconCtrl");
    if (conf.price == 0) then
        btnGet:setTitle(Desc.moneyBuyGift_free);
        ctrl:setSelectedIndex(1);
    else
        local url = PathConfiger.getMoneyIcon(GameDef.MoneyType.Diamond);
        btnGet:getChildAutoType("icon"):setURL(url);
        btnGet:setTitle(conf.price);
        ctrl:setSelectedIndex(0);
    end
    btnGet:removeClickListener(22);
    btnGet:addClickListener(function ()
        local flag = PlayerModel:checkCostEnough(cost, true);
        if (flag) then
            local info = {
                id = idx,
            }
            RPCReq.GamePlay_Modules_GoldTree_GetGoldTreeReward(info, function (param)
                -- printTable(1, param);
                -- local data = GoldTreeModel.dataList[idx];
                -- data.storeTimes = math.max(data.storeTimes - 1, 0);
                -- data.buyTimes = data.buyTimes + 1;
                -- self:GoldTree_UpView();
                local data = {
                    show = 1,
                    reward = {{type = 2, code = GameDef.MoneyType.Gold, amount = param.gold}}
                }
                ViewManager.open("AwardShowView",data);
            end);
        end
    end, 22);
end

function GoldTreeView:upItemInfo(idx)
    local item = self.item[idx];
    local conf = DynamicConfigData.t_GoldTree[idx];
    item:setTitle((conf.time / 60)..Desc.common_hour);
    local ctrl = item:getController("c1");
    local count = GoldTreeModel:getBuyCount(idx);--conf.number + data.storeTimes - data.buyTimes
    local c = count > 0 and 0 or 1;
    ctrl:setSelectedIndex(c);

    item:getChild('txt_leave'):setText(count);
end

function GoldTreeView: pushMap_getCurPassPoint(_, param)
    local cityId = param.cityId;
    local chapterId = param.chapterId;
    local pointId = param.pointId;
    local curLv = DynamicConfigData.t_chaptersPoint[cityId][chapterId][pointId].fightfd;
    local conf = DynamicConfigData.t_chaptersPointFightFd[curLv];
    local goldExpr = conf and conf.greward[1].amount or 0;
    LuaLog("======== GoldTreeView ===== lv ",cityId.."-"..chapterId.."-"..pointId, "id."..curLv, "rate."..goldExpr);

    for idx in ipairs(self.item) do
        local item = self.item[idx];
        local numgold = DynamicConfigData.t_GoldTree[idx].numgold;
        local vipRate = VipModel:getVipPrivilige(6) / 100;
        local award = (goldExpr + numgold) * DynamicConfigData.t_GoldTree[idx].time;
        if (vipRate ~= 0) then
            award = (1 + vipRate) * award;
        end
        -- local award = GoldTreeModel:getTotalAward(idx);
        item:getChild('txt_value'):setText(award);
    end
end

function GoldTreeView:upCountDown()
    if (self.timer) then
        TimeUtil.clearTime(self.timer);
    end
    local offset = GoldTreeModel.refreshTime - ServerTimeModel:getServerTime();
    self.timer = TimeUtil.upText(self.txt_count, offset - 1, "%s");
    self.txt_count:setText(TimeLib.formatTime(offset));
end


-- function GoldTreeView:_addRed()
    
-- end

function GoldTreeView:__onExit()
    if (self.timer) then
        TimeUtil.clearTime(self.timer);
    end
    Super.__onExit(self);
end

return GoldTreeView;