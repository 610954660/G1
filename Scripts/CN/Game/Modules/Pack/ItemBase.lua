--道具item数据类基类
--added by xhd
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
local ItemBase = class("ItemBase")

--------------------------------------------------
--[[
.PItem_Item {
    id              1:integer       #每次存入玩家身上时这个物品需要改变ID。这个值为nil时候表示是一个非玩家物品
    #这里刘一行代码用来告诉后人不用将uuid放到这个结构里面。没必要
    code            3:integer       #物品配置的code
    amount          4:integer       #物品数量
    price           5:integer      #价格(市场用)
    expireMS        6:integer       #物品失效时间 
    
    #物品特殊类型扩展数据 100-300
    equip           51:PItem_ItemEquip
    fate            52:PItem_ItemFate
    wing            53:PItem_ItemWing
    jewelry         54:PItem_ItemJewelry
    robot           59:PItem_Robot
    sword           60:PItem_ItemFate
    beast           61:PItem_ItemJewelry
    secretBook		62:PItem_SecretBook
	equipJewel 		64:PItem_Jewel #宝石类型物品会有这个数据

    #查看他人信息使用
    strengthen      55:PosStrenInfo
    wash            56:PosWashInfo
    jewel           57:PEquip_PosHoles
    suit            58:EquipSuit
}

self.__data 可能有上面的变量
]]

--------------------------------------------------

function ItemBase:ctor(args)
	args = args or {}
	-- 服务器数据结构
	self.__data = false 

	--配置信息
	self.__itemInfo = false

	--背包类型
	self.__bagType = false

    self.winType = 0 -- 只是一個标记位 标记是否是从背包打开的item

	--背包位置
	self.__posIndex = args.posIndex or false

	if type(args.data) == "table" then
		self:setData(args.data)
	end
end

function ItemBase:checkType( type )
	-- body
end

function ItemBase:setData( data)
	if data and data.code then
       self.__data = data
       self.__itemInfo = ItemConfiger.getInfoByCodeAndType(data.type,data.code) or false
       if self.__itemInfo then self:setBagType(self.__itemInfo.category) end
	else
	end
end

function ItemBase:getData()
    return self.__data
end

-- 物品的配置信息
function ItemBase:getItemInfo()
    return self.__itemInfo or {}
end

function ItemBase:getCodeType()
	return self.__data.type
end


function ItemBase:getUuid()
	return self.__data.uuid
end

-- 物品数量
function ItemBase:getItemAmount()
    return self.__data.amount and self.__data.amount or 0
end

function ItemBase:setAmount(value)
    self.__data.amount = value
end

-- 背包类型
function ItemBase:setBagType(bagType)
    self.__bagType = bagType
end

function ItemBase:getBagType()
    return self.__bagType
end

function ItemBase:getExpireMS()
    return self.__data.expireMS
end

--获取配置原本默认的背包类型
function ItemBase:getDefaultBagType()
    if self.__itemInfo then
        return self.__itemInfo.bagType
    end
    return 0
end

function ItemBase:getItemCode()
    if self.__data then
        return self.__data.code
    end
end

function ItemBase:getItemType()
    if self.__data then
        return self.__data.type
    end
end


function ItemBase:getItemId()
    if self.__data then
        return self.__data.id
    end
end

--获取道具特殊类型的拓展数据接口
function ItemBase:getItemSPecialData( ... ) 
    if self.__data then
        return self.__data.specialData
    end
    return nil
end

-- 物品描述
function ItemBase:getDesc()
    
end

-- 用途描述
function ItemBase:getUsageDesc()
    if self.__itemInfo then
        return self.__itemInfo.usageDesc
    end 
end

-- 获取途径
function ItemBase:getGainDesc()
    if self.__itemInfo then
        return self.__itemInfo.gainDesc
    end
    return {}
end

function ItemBase:getDescStr( ... )
	if self.__itemInfo then
        return self.__itemInfo.descStr
    end
    return ""
end

 
-- 背包位置
function ItemBase:getPosIndex()
    return self.__posIndex
end

function ItemBase:setPosIndex(index)
    self.__posIndex = index or false
end

-- 物品名字
function ItemBase:getName()
    if self.__itemInfo then
        return self.__itemInfo.name
    end
    return ""
end

--获取自选礼包拓展道具
function ItemBase:geteEfectEx()
    if self.__itemInfo then
        return self.__itemInfo.effectEx
    end
    return {}
end

--物品的颜色Id
function ItemBase:getColorId()
	if self.__itemInfo then
       return self.__itemInfo.color
    end
	return 0
end

--物品的颜色值
function ItemBase:getColor()
	if self.__itemInfo then
       return ColorUtil.getItemColor(self.__itemInfo.color)
    end
	return ccc3(0,0,0)
end

function ItemBase:getItemTipsColor()
	if self.__itemInfo then
       return ColorUtil.getItemTipsColor(self.__itemInfo.color)
    end	
	return ccc3(0,0,0)
end

--物品category
function ItemBase:getCategory()
    if self.__itemInfo then
        return self.__itemInfo.category
    end
    return -1
end

-- 物品type
function ItemBase:getType()
    if self.__itemInfo then
        return self.__itemInfo.type
    end
    return -1
end

--获取使用类型
function ItemBase:getUseType()
    if self.__itemInfo then
        return self.__itemInfo.useType
    end
    return -1
end

-- 使用等级，level是使用等级，itemLevel是物品等级
function ItemBase:getUseLevel()
    if self.__itemInfo then
        return self.__itemInfo.level
    end
    return -1
end

-- 获取装备等级
function ItemBase:getItemLevel()
    return self.__itemInfo.itemLevel or 0
end

-- 更换纹章种族
function ItemBase:setCategory(category)
    if self.__data then
        self.__data.specialData.category = category
		self.__data.specialData.categoryShow = false	
    end
	if self.__data.specialData.heraldry then
		self.__data.specialData.heraldry.category = category
		self.__data.specialData.heraldry.categoryShow = false
	end
end
-- 刷新纹章等级和经验
function ItemBase:setLevelExpByUUID(level,exp)
	if self.__data.specialData.heraldry then
		self.__data.specialData.heraldry.star = level
		self.__data.specialData.heraldry.exp = exp
	end
end
return ItemBase