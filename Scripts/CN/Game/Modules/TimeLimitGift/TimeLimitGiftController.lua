--Name : TimeLimitGiftController.lua
--Author : generated by FairyGUI
--Date : 2020-7-10
--Desc : 

local TimeLimitGiftController = class("TimeLimitGiftController",Controller)
local hasGift = false
local giftID = false
local indexFirst=1

local backgroundindexFirst=1
local backgroundhasGift = false
local backgroundgiftID = false

function TimeLimitGiftController:init()
end

function TimeLimitGiftController:Activity_UpdateData( _,params )
	if params.type == GameDef.ActivityType.SurpriseGift then
		if params and params.surpriseGift and params.surpriseGift.giftMap then
            printTable(999,"限时活动数据",params.surpriseGift.giftMap)
            self:handleOpen(params.surpriseGift.giftMap)
            TimeLimitGiftModel:initData(params.surpriseGift.giftMap)
            indexFirst=2
        end
    elseif params.type == GameDef.ActivityType.SurpriseGiftEx then
        if params and params.surpriseGift and params.surpriseGift.giftMap then
             printTable(156,"限时活动数据",params.surpriseGift.giftMap)
            self:backgroundhandleOpen(params.surpriseGift.giftMap)
            backgroundTimeLimitGiftModel:initData(params.surpriseGift.giftMap)
            backgroundindexFirst=2
        end
	end
end

function TimeLimitGiftController:handleOpen(giftMap)
    printTable(152,"限时活动数据",TimeLimitGiftModel.giftList)
   if indexFirst==1 then
            hasGift = false
            giftID = false
   else
    local hasMap={}
    for k, v in pairs(TimeLimitGiftModel.giftList) do
        hasMap[v.id]=v
    end
        for key, value in pairs(giftMap) do
            if hasMap[key]==nil then
                hasGift = true
                giftID = value.id
            end
        end
   end
    if hasGift and self:isMainUIShow() then
        ViewManager.open("TimeLimitGiftView",{isAutoOpen = true,giftID = giftID})
        hasGift = false
        giftID = false
    end
end


--后台限时活动
function TimeLimitGiftController:backgroundhandleOpen(giftMap)
    printTable(152,"限时活动数据",backgroundTimeLimitGiftModel.giftList)
   if backgroundindexFirst==1 then
    backgroundhasGift = false
    backgroundgiftID = false
   else
    local hasMap={}
    for k, v in pairs(backgroundTimeLimitGiftModel.giftList) do
        hasMap[v.id]=v
    end
        for key, value in pairs(giftMap) do
            if hasMap[key]==nil then
                backgroundhasGift = true
                backgroundgiftID = value.id
            end
        end
   end
    if backgroundhasGift and self:isMainUIShow() then
        ViewManager.open("backgroundTimeLimitGiftView",{isAutoOpen = true,giftID = backgroundgiftID})
        backgroundhasGift = false
        backgroundgiftID = false
    end
end


--角色升级
-- function TimeLimitGiftController:player_levelUp()
--     self:handleOpen(PlayerModel.level,1)
-- end

--获得英雄的星数
-- function TimeLimitGiftController:event_getHighStarHero(name,maxStar,cardCode)
--     print(150,"获得英雄",maxStar,cardCode)
--     self:handleOpen(maxStar,2,cardCode)
-- end

--购买礼包成功
-- function TimeLimitGiftController:buyGift_Success(name,rechargeType,money)
--     print(999,"购买礼包成功",rechargeType,money)
--     if rechargeType  == GameDef.StatFuncType.SFT_BuyNewServerGift then
--         self:handleOpen(money,3)
--     end
-- end

--秘武等级提升
-- function TimeLimitGiftController:secretWeapons_UpLevel(name,scretLevel)
--     print(152,"秘武等级提升",scretLevel)
--     self:handleOpen(scretLevel,4)
-- end

--界面变化
function TimeLimitGiftController:view_change(name)
    if hasGift and self:isMainUIShow() then
        Scheduler.schedule(function()
            ViewManager.open("TimeLimitGiftView",{isAutoOpen = true,giftID = giftID})
            hasGift = false
            giftID = false
        end,0.1,1)
    end
    if backgroundhasGift and self:isMainUIShow() then
        Scheduler.schedule(function()
            ViewManager.open("backgroundTimeLimitGiftView",{isAutoOpen = true,giftID = backgroundgiftID})
            backgroundhasGift = false
            backgroundgiftID = false
        end,0.1,1)
    end
end

-- function TimeLimitGiftController:handleOpen(value,type,cardCode)
--     if hasGift then
--         return
--     end

--     local datas = ModelManager.TimeLimitGiftModel:getData()
--     if type==2 then
--        local configInfo= DynamicConfigData.t_hero[cardCode]
--        if not  configInfo then
--            return
--        end
--         for k,v in pairs(datas) do
--             local config = DynamicConfigData.t_SurpriseGiftConfig[v.id]
--             if config.giftType == type and value == config.openTask[1].value and self:togertherCategory(config.category,config.hero,configInfo.category,cardCode)==true then
--                 hasGift = true
--                 giftID = v.id
--                 break
--             end
--         end
--     else
--         for k,v in pairs(datas) do
--             local config = DynamicConfigData.t_SurpriseGiftConfig[v.id]
--             if config.giftType == type and value == config.openTask[1].value then
--                 hasGift = true
--                 giftID = v.id
--                 break
--             end
--         end
--     end


--     if hasGift and self:isMainUIShow() then
--         ViewManager.open("TimeLimitGiftView",{isAutoOpen = true,giftID = giftID})
--         hasGift = false
--         giftID = false
--     end
-- end

-- function TimeLimitGiftController:togertherCategory(attr,hero,category,cardId)
--     local has =false
--     if #attr>0 then
--         for key, value in pairs(attr) do
--             if value==category then
--                 has=true
--             end
--         end
--     elseif #hero>0 then
--         for key, value in pairs(attr) do
--             if value==cardId then
--                 has=true
--             end
--         end
--     end
--     printTable(150,"233333333",has)
--     return has
-- end

function TimeLimitGiftController:isMainUIShow()
    local mainUILayer = ViewManager.getParentLayer(LayerDepth.MainUI)
    if not mainUILayer then
        return false
    end

    local mainUIChildren = mainUILayer:getChildren()
    if not mainUIChildren then
        return false
    end

    if #mainUIChildren < 1 then
        return false
    end

    local views = ViewManager.getOpeningViews()
    local hasOther = false
    for k,v in pairs(views) do
        if v.window._viewName ~= "MainUIView" and v.window._viewName ~= "BroadcastView" then
            hasOther = true
            break
        end
    end

    return mainUIChildren[1]:isVisible() and not hasOther
end

return TimeLimitGiftController