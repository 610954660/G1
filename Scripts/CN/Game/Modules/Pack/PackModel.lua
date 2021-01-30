--added by xhd
--所有背包数据模型层
local BaseModel = require "Game.FMVC.Core.BaseModel"
local PackModel = class("PackModel", BaseModel)

local NormalPackModel = require "Game.Modules.Pack.NormalPackModel"
local EquipmentPackModel = require "Game.Modules.Pack.EquipmentPackModel"
local HeroCompPackModel = require "Game.Modules.Pack.HeroCompPackModel"
local SpecialPackModel = require "Game.Modules.Pack.SpecialPackModel"
local RunePackModel = require "Game.Modules.Pack.RunePackModel"
local JewelryPackModel = require "Game.Modules.Pack.JewelryPackModel"
local PveStarTemplePackModel = require "Game.Modules.Pack.PveStarTemplePackModel"
local HeadBorderPackModel = require "Game.Modules.Pack.HeadBorderPackModel"

local ElvesSystemBagModel = require "Game.Modules.Pack.ElvesSystemBagModel"
local EmblemPackModel = require "Game.Modules.Pack.EmblemPackModel"
local DressEmblemPackModel = require "Game.Modules.Pack.DressEmblemPackModel"
local CrownTitlePackModel = require "Game.Modules.Pack.CrownTitlePackModel"
local FashionPackModel = require "Game.Modules.Pack.FashionPackModel"
local MedalPackModel = require "Game.Modules.Pack.MedalPackModel"
local BagType = GameDef.BagType
local OperType = GameDef.OperType
-- local UpdateCode = GameDef.UpdateCode

function PackModel:ctor()
   -- print(1,"背包packmodel ctor")
    self.__allPacks = {
        [BagType.Normal] = NormalPackModel.new({ type = BagType.Normal }), --普通道具背包
        [BagType.Equip] = EquipmentPackModel.new({ type = BagType.Equip }), --装备道具背包
		[BagType.Special] = SpecialPackModel.new({ type = BagType.Special }), --特殊道具背包
        [BagType.HeroComponent] = HeroCompPackModel.new({ type = BagType.HeroComponent }), --卡牌碎片背包
        [BagType.Rune] = RunePackModel.new({ type = BagType.Rune }), --符文背包
        [BagType.Jewelry] = JewelryPackModel.new({type = BagType.Jewelry}), --饰品背包
        [BagType.PveStarTemple] = PveStarTemplePackModel.new({type = BagType.PveStarTemple}),--星辰圣所背包
        [BagType.Elf] = ElvesSystemBagModel.new({type = BagType.Elf}),--精灵背包
        [BagType.HeadBorder] = HeadBorderPackModel.new({type = BagType.HeadBorder}),--头像框背包
        [BagType.Heraldry] = EmblemPackModel.new({type = BagType.Heraldry}), --纹章背包
        [BagType.DressHeraldry] = DressEmblemPackModel.new({type = BagType.DressHeraldry}), --已穿戴纹章背包
        [BagType.CrownTitle] = CrownTitlePackModel.new({type = BagType.CrownTitle}), --已穿戴纹章背包
        [BagType.Fashion] = FashionPackModel.new({type = BagType.Fashion}), --时装背包
        [BagType.HonorMedalWall] = MedalPackModel.new({type = BagType.HonorMedalWall}), -- 荣誉勋章背包
    }
end

---------------------快捷获取对应背包-----------------------
function PackModel:getPackByType(type)
    return self.__allPacks[type]
end

function PackModel:getNormalBag()
    return self:getPackByType(BagType.Normal)
end

function PackModel:getEquipBag()
    return self:getPackByType(BagType.Equip)
end

function PackModel:getSpecialBag()
    return self:getPackByType(BagType.Special)
end


function PackModel:getHeroCompBag()
	return self:getPackByType(BagType.HeroComponent)
end

function PackModel:getRuneBag()
    return self:getPackByType(BagType.Rune)
end

function PackModel:getElvesBag()
    return self:getPackByType(BagType.Elf)
end

function PackModel:getJewelryBag()
    return self:getPackByType(BagType.Jewelry)
end

function PackModel:getPveStarTempleBag()
    return self:getPackByType(BagType.PveStarTemple)
end

function PackModel:getElfBag()
    return self:getPackByType(BagType.Elf)
end

function PackModel:getEmblemBag()
    return self:getPackByType(BagType.Heraldry)
end

function PackModel:getDressEmblemBag()
    return self:getPackByType(BagType.DressHeraldry)
end

function PackModel:getHeadBorderBag()
    return self:getPackByType(BagType.HeadBorder)
end

function PackModel:getCrownTitleBag()
    return self:getPackByType(BagType.CrownTitle)
end

function PackModel:getFashionBag()
    return self:getPackByType(BagType.Fashion)
end

function PackModel:getHonorMedalBag()
    return self:getPackByType(BagType.HonorMedalWall)
end

--从4个背包里面检索道具
function PackModel:getItemsFromAllPackByCode( code,isBind )
	local amount = self:getNormalBag():getAmountByCode(code)
	if amount == 0 then amount = self:getEquipBag():getAmountByCode(code) end
	if amount == 0 then amount = self:getSpecialBag():getAmountByCode(code) end
    if amount == 0 then amount = self:getHeroCompBag():getAmountByCode(code) end
    if amount == 0 then amount = self:getRuneBag():getAmountByCode(code) end
    if amount == 0 then amount = self:getJewelryBag():getAmountByCode(code) end
    if amount == 0 then amount = self:getPveStarTempleBag():getAmountByCode(code) end
    if amount == 0 then amount = self:getElfBag():getAmountByCode(code) end
    if amount == 0 then amount = self:getHeadBorderBag():getAmountByCode(code) end
    if amount == 0 then amount = self:getEmblemBag():getAmountByCode(code) end
    if amount == 0 then amount = self:getCrownTitleBag():getAmountByCode(code) end
    if amount == 0 then amount = self:getFashionBag():getAmountByCode(code) end
    if amount == 0 then amount = self:getHonorMedalBag():getAmountByCode(code) end
	return amount
end

---------------------快捷获取对应背包-----------------------

function PackModel:setPack(v)
    local pack = self:getPackByType(v.type)
    if pack == nil then
        --printWarning("背包不存在，type=", v.type)
    end
    if pack then
        pack:setPack(v)
    end
end

--背包数据更新
function PackModel:updatePackItems(v, updateCode)
    local operType = v.operType --操作类型
    local bagType = v.bagType
    local bagObj = self:getPackByType(bagType)
    if bagObj == nil then
        printWarning(bagType, "bagObj is nil")
        return
    end

    local eventName, eventArg
    if operType == OperType.Add then
        -- 增加
        local itemData = ItemsUtil.createItemData({ data = v.item })
        itemData:setBagType(bagType)
        eventName, eventArg = bagObj:increateItem(itemData, updateCode)

    elseif operType == OperType.Del then
        -- 删除
        eventName, eventArg = bagObj:deleteItem(v.item.id, updateCode)

    elseif operType == OperType.Update then
        -- 更新
        eventName, eventArg = bagObj:updateItem(v.item, updateCode)
    end
    return eventName, eventArg
end


return PackModel
