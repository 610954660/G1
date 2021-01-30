-- added by wyz
-- 魔灵山 购买体力界面

local GuildMLSPowerTipsView = class("GuildMLSPowerTipsView",Window)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器


function GuildMLSPowerTipsView:ctor()
    self._packName = "GuildMagicLingShan"
    self._compName = "GuildMLSPowerTipsView"
    self._rootDepth = LayerDepth.PopWindow

    self.txt_title  = false 
    self.txt_tips   = false
    self.btn_ok     = false
    self.btn_close  = false
    self.txt_haveTitle  = false
    self.costItem   = false
    self.costItem1  = false
    self.costItem2  = false
    self.txt_power  = false
    self.iconProp   = false
end


function GuildMLSPowerTipsView:_initUI()
    self.txt_title  = self.view:getChildAutoType("txt_title")
    self.txt_tips   = self.view:getChildAutoType("txt_tips")
    self.btn_ok     = self.view:getChildAutoType("btn_ok")
    self.btn_close  = self.view:getChildAutoType("btn_close")
    self.txt_haveTitle = self.view:getChildAutoType("txt_haveTitle")
    self.costItem   = self.view:getChildAutoType("costItem")
    self.costItem1   = self.view:getChildAutoType("costItem1")
    self.costItem2   = self.view:getChildAutoType("costItem2")
    self.txt_power  = self.view:getChildAutoType("txt_power")
    self.iconProp   = self.view:getChildAutoType("iconProp")
end

function GuildMLSPowerTipsView:_initEvent()
    self:refreshPanal()
end

function GuildMLSPowerTipsView:refreshPanal()
    local buyEnergyNum = ModelManager.GuildMLSModel:getBuyEnergyNum()
    local buyEnergyCost = ModelManager.GuildMLSModel:getPowerMoney()
    local times        = ModelManager.GuildMLSModel.purchaseCount 

    self.txt_haveTitle:setText(Desc.GuildMLSMain_haveTitle)
    self.txt_title:setText(string.format(Desc.GuildMLSMain_buyPower,buyEnergyCost,buyEnergyNum))
    self.txt_tips:setText(string.format(Desc.GuildMLSMain_buyPowerTips,times))

    self.btn_close:removeClickListener(11)
    self.btn_close:addClickListener(function()
        ViewManager.close("GuildMLSPowerTipsView")
    end,11)

    local const = DynamicConfigData.t_EvilConst[1]
    local energyItem = const.energyItem
    local url 			= ItemConfiger.getItemIconByCode(energyItem, GameDef.ItemType.EvilMountainEnergy, true)
    self.iconProp:setURL(url)
    local haveMoney =  ModelManager.PackModel:getItemsFromAllPackByCode(energyItem) or 0
    
    local pack  = PackModel:getNormalBag()
    local itemData = pack:getItemsByCode(energyItem)


    self.btn_ok:removeClickListener(11)
    self.btn_ok:addClickListener(function()
        if haveMoney > 0 then
            local params = {}
            params.bagType = itemData[1].__bagType
            params.itemId = itemData[1].__data.id
            params.amount = 1
            params.onSuccess = function( res )
                RollTips.show(string.format(Desc.GuildMLSMain_useEvilMountainEnergy,itemData[1].__itemInfo.effect ))
                ViewManager.close("GuildMLSPowerTipsView")
            end
            RPCReq.Bag_UseItem(params, params.onSuccess)
        else
            local reqInfo = {
            }
            RPCReq.EvilMountain_PurchaseEnergyReq(reqInfo,function()
                printTable(8848,">>>>EvilMountain_PurchaseEnergyReq>>>>购买精力>>>>")  
                RollTips.show(string.format(Desc.GuildMLSMain_buyPowerSuccess,buyEnergyNum))
                ViewManager.close("GuildMLSPowerTipsView")
            end)
        end
    end,11)

    self.txt_power:setText(buyEnergyNum)

    self.costItem = BindManager.bindCostItem(self.costItem)
    self.costItem:setData(GameDef.ItemType.Money,GameDef.MoneyType.Diamond,buyEnergyCost,true,true)
    self.costItem1 = BindManager.bindCostItem(self.costItem1)
    self.costItem1:setData(GameDef.ItemType.Money,GameDef.MoneyType.Diamond,buyEnergyCost,true,false)
    self.costItem2 = BindManager.bindCostItem(self.costItem2)
    self.costItem2:setData(GameDef.GameResType.Item,energyItem,0,false,true)
end


return GuildMLSPowerTipsView