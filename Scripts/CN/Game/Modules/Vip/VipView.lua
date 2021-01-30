
-- Vip
-- added by zn

local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
local VipView = class("VipView", Window)

function VipView: ctor()
    self._packName = "Vip";
    self._compName = "VipView";
    self.curVipIndex = math.max(VipModel.level, 1);
end

function VipView: _initUI()
    local root = self;
    local rootView = self.view;
        root.list_vipPage = rootView:getChildAutoType("list_vipPage");
        root.list_desc = rootView:getChildAutoType("list_desc");
        root.list_pack = rootView:getChildAutoType("list_pack");

        root.txt_curLv = rootView:getChildAutoType("txt_curLv");
        -- root.txt_vipDescLevel = rootView:getChildAutoType("txt_vipDescLevel");
        -- root.txt_cast = rootView:getChildAutoType("txt_cast")-- 还需充值
        -- root.txt_nextLv = rootView:getChildAutoType("txt_nextLv")-- 下一级
        root.txt_desc = rootView:getChildAutoType("txt_desc") -- 策划描述
        root.txt_dailyDesc = rootView:getChildAutoType("n54") -- 每日描述
        -- root.txt_itemName = rootView:getChildAutoType("txt_itemName") -- 上方banner道具
        root.txt_delCash = rootView:getChildAutoType("txt_delCash")-- 删除线金额
        root.txt_realCash = rootView:getChildAutoType("txt_realCash") --礼包真实价格
        root.txt_total = rootView:getChildAutoType("txt_total")

        root.load_cash = rootView:getChildAutoType("loader_cash");

        -- root.itemCell = BindManager.bindItemCell(rootView:getChildAutoType("itemCell")); -- 上方banner显示的item
        root.itemCell_day1 = BindManager.bindItemCell(rootView:getChildAutoType("itemCell_day1"));
        root.itemCell_day2 = BindManager.bindItemCell(rootView:getChildAutoType("itemCell_day2"));

        root.btn_go = rootView:getChildAutoType("btn_go");
        root.btn_buy = rootView:getChildAutoType("btn_buy");
        root.btn_award = rootView:getChildAutoType("btn_award");
        root.prog_exp = rootView:getChildAutoType("prog_exp");
    
        root.loader_banner = rootView:getChildAutoType("banner");
        root.btn_shop = rootView:getChildAutoType("btn_shop");

    self.btn_shop:addClickListener(function() 
        ModuleUtil.openModule(ModuleId.Shop_noble.id) 
    end)

    local conf = VipModel:getAllVipTab();
    -- self.list_vipPage:setVirtual();
    self.list_vipPage:setItemRenderer(function (idx, obj)
        if (idx + 1 == self.curVipIndex) then
            self.list_vipPage:setSelectedIndex(idx);
        end
        local c = conf[idx + 1]
        if (c and c.vipDec and c.vipDec ~= "") then
            obj:getChildAutoType("desc"):setText(c.vipDec);
            obj:getController("c1"):setSelectedIndex(1);
        else
            obj:getController("c1"):setSelectedIndex(0)
        end
        obj:setTitle("VIP"..c["level"]);
        obj:removeClickListener(22);
        obj:addClickListener(function ()
            if ((idx + 1) ~= self.curVipIndex) then
                self.curVipIndex = idx + 1;
                self:Vip_UpView();
            end
        end, 22)
        RedManager.register("V_VIP_"..(idx + 1), obj:getChildAutoType('img_red'));
    end)
    self.list_vipPage:setNumItems(#conf);
    self.list_vipPage:scrollToView(self.curVipIndex - 1, true);
    local lastVip = conf[#conf].level;
    self.btn_go:setVisible(VipModel.level < lastVip);
    self:Vip_UpView();
end

function VipView:_initEvent()
    self.btn_buy:addClickListener(function ()
        VipModel:receiveLevelGift(self.curVipIndex);
    end)

    self.btn_award:addClickListener(function ()
        VipModel:receiveDaily(self.curVipIndex);
    end)

    self.btn_go:addClickListener(function ()
        if (not ModuleUtil.getModuleOpenTips(ModuleId.Recharge.id, true)) then
            Dispatcher.dispatchEvent("Vip_openRecharge");
        end
    end)
end

function VipView:Vip_UpView()
    local checkOpenShop = self.view:getController("checkOpenShop")
    if (not ModuleUtil.getModuleOpenTips(ModuleId.Shop_noble.id)) then
        checkOpenShop:setSelectedIndex(1)
    else
        checkOpenShop:setSelectedIndex(0)
    end

    local conf = DynamicConfigData.t_Vip[self.curVipIndex];

    self.loader_banner:setIcon(string.format("UI/Vip/%s.png", conf.vipBanner));
    -- self.txt_vipDescLevel:setText(self.curVipIndex);
    self:upTopBannerInfo();
    self:upPriviligeDesc(conf.vipType);
    self:upItemCells();
    self:upBtnStatus();
end

function VipView:upTopBannerInfo()
    self.txt_curLv:setText(VipModel.level);
    local conf = DynamicConfigData.t_Vip
    -- 更新进度条
    local nextConf = conf[VipModel.level + 1];
    if (nextConf) then
        self.prog_exp:setMax(nextConf.vipExp);
        self.prog_exp:setValue(VipModel.exp);
    else
        self.prog_exp:setMax(100);
        self.prog_exp:setValue(100);
        self.prog_exp:getChildAutoType('title'):setText("MAX");
    end
    -- 更新升级描述
    if (nextConf and nextConf.dec and string.len(nextConf.dec) > 1) then
        self.txt_desc:setText(nextConf.dec);
    elseif nextConf then
        self.txt_desc:setText(string.format(Desc.vip_moreRecharge, nextConf.vipExp - VipModel.exp, nextConf.level));
    else
        self.txt_desc:setVisible(false);
        self.txt_total:setText("");
        self.view:getChildAutoType("n62"):setVisible(false);
    end
    local showConf = conf[self.curVipIndex]
    -- if (showConf) then
        local num = VipModel:getTotalCost(self.curVipIndex)
        self.txt_total:setText(string.format(Desc.vip_totalRecharge, math.ceil(num / 10), showConf.level));
    -- else
    --     self.txt_total:setText("")
    -- end
end

-- 更新特权描述
function VipView:upPriviligeDesc(typeList)
    local vipLv = self.curVipIndex;
    self.list_desc:setItemRenderer(function (idx, obj)
        local conf = VipModel:getPriviligeType(typeList[idx + 1], vipLv);
        obj:setTitle(conf.tips)
        obj:getController("isNew"):setSelectedIndex(conf.newShow or 0);
    end)
    self.list_desc:setNumItems(#typeList);
end

function VipView:upItemCells()
    local conf = DynamicConfigData.t_Vip[self.curVipIndex];
    -- 每日
    local str = self.curVipIndex < VipModel.level and Desc.vip_award or Desc.vip_dailyAward;
    self.txt_dailyDesc:setText(str);
    local award = conf.dayGift;
    for i = 1, 2 do
        local cell = self["itemCell_day"..i];
        cell:setData(award[i].code, award[i].amount, award[i].type);
    end
    -- 礼包奖励
    -- self.list_pack:setVirtual();
    self.list_pack:setItemRenderer(function (idx, obj)
        local data = conf.gift[idx + 1];
        BindManager.bindItemCell(obj):setData(data.code, data.amount, data.type);
    end)
    self.list_pack:setNumItems(math.max(#conf.gift, 0));
    -- 礼包花费
    self.txt_delCash:setText(conf.oldPrice[1].amount);
    self.txt_realCash:setText(conf.price[1].amount);
    self.load_cash:setIcon(PathConfiger.getMoneyIcon(conf.price[1].code))
end

function VipView:upBtnStatus()
    local flag1 = VipModel:getMarkStatus(self.curVipIndex, 2);
    self.btn_buy:setGrayed(flag1 or self.curVipIndex > VipModel.level);
    self.btn_buy:setTouchable(not (flag1 or self.curVipIndex > VipModel.level));
    self.btn_buy:setTitle(flag1 and Desc.vip_bought or Desc.vip_buy);

    -- 每日
    local flag2 = VipModel:getMarkStatus(self.curVipIndex, 1);
    self.btn_award:setGrayed(flag2 or self.curVipIndex > VipModel.level);
    self.btn_award:setTouchable(not (flag2 or self.curVipIndex > VipModel.level));
    self.btn_award:getChildAutoType("img_red"):setVisible((not flag2) and (self.curVipIndex <= VipModel.level));
    local str = Desc.vip_got;
    if (flag2) then
        if (self.curVipIndex == VipModel.level) then
            str = Desc.vip_getTomorrow;
        end
    else
        if (self.curVipIndex > VipModel.level) then
            str = string.format(Desc.vip_levelCanGet, self.curVipIndex);
        else
            str = Desc.vip_get;
        end
    end
    self.btn_award:setTitle(str);
end

return VipView