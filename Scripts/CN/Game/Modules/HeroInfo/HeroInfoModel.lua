-- added by zn
-- 英雄信息界面
local RuneConfiger = require "Game.Modules.RuneSystem.RuneConfiger"
local HeroInfoModel = class("HeroInfoModel", BaseModel)

function HeroInfoModel:ctor()
    self.playerInfo = false
    self.heroArray = false
    self.showIndex = false -- 当前查看的位置

    self.data = false -- 所有数据
    self.heroId = false
    self.power = false
    self.attrs = false -- 属性
	self.fashionId = false --时装
	self.uuid = false
    -- self.reservedSkill = false; --
    self.rune = false -- 符文
    self.equipmentMap = false -- 装备
    self.passiveSkill = false -- 特性
    self.rank = false -- 种族榜排名
    self:initListeners()
end

-- 显示英雄信息
--[[
    data = {
        playerInfo = { // 需要玩家的信息
            playerId = val,
            serverId = val 默认当前服 
            ...
        }}
        heroArray = {  // 所有查看的英雄 进入界面可以左右滑动
            ...  -- eg {uuid = "adsf", ...} || 直接string
        }
        index = 1 // 进入界面展示的英雄
  ]]
function HeroInfoModel:HeroInfo_Show(_, data)
    if (data) then
        self.playerInfo = data.playerInfo or {}
        self.heroArray = data.heroArray
        self.showIndex = data.index or 1

        self:getHeroInfo()
    end
end

-- 翻页 0 按左 1 按右
function HeroInfoModel:turnPage(dir)
    if ((dir == 0 and self.showIndex == 1) or (dir == 1 and self.showIndex == #self.heroArray)) then
        return false
    else
        self.showIndex = dir == 0 and (self.showIndex - 1) or (self.showIndex + 1)
        return true
    end
end

function HeroInfoModel:getHeroInfo(cb)
    local heroUuid = self.heroArray[self.showIndex]
	self.uuid = heroUuid
    if (not heroUuid) then
        return
    end
    if (type(heroUuid) == "table" and not next(self.playerInfo)) then
        self.data = heroUuid
        -- printTable(1, "=+== 英雄信息 ====",self.data);
        self.heroId = self.data.code
        self.power = self.data.combat or 0
        self.passiveSkill = self.data.newPassiveSkill or {}
        self.attrs = self.data.attrs or {}
        self.rune = self.data.rune or {} -- 符文
        self.equipmentMap = self.data.equipmentMap or {} -- 装备
        if (cb) then
            cb()
        end
        ViewManager.open("HeroView")
        Dispatcher.dispatchEvent(EventType.HeroView_initView)
    else
        local info = {
            serverId = self.playerInfo.serverId or LoginModel:getLoginServerInfo().unit_server,
            playerId = self.playerInfo.playerId or PlayerModel.userid,
            heroUuid = type(heroUuid) == "string" and heroUuid or heroUuid.uuid
        }
        print(2233, "=== getHeroInfo", self.playerInfo.serverId, LoginModel:getLoginServerInfo().unit_server)
        if (not info.playerId or tonumber(info.playerId) < 0) then
            RollTips.show(Desc.Friend_cant_show);
        else
            RPCReq.Player_FindPlayerHeroInfo(
                info,
                function(param)
                    if (param.heroData) then
                        self.data = param.heroData
                        -- printTable(1, "=+== 英雄信息 ====",self.data);
                        self.heroId = self.data.code
                        self.power = self.data.combat or 0
                        self.passiveSkill = self.data.newPassiveSkill or {}
                        self.attrs = self.data.attrs or {}
                        self.rune = self.data.rune or {} -- 符文
						self.fashionId = self.data.fashion and self.data.fashion.code or false --时装
                        self.equipmentMap = self.data.equipmentMap or {} -- 装备
                        self.rank = param.rank or false;
                        if (cb) then
                            cb()
                        end
    
                        ViewManager.open("HeroView")
                        Dispatcher.dispatchEvent(EventType.HeroView_initView)
                    end
                end
            )
        end
    end
end

--获取配点数据
function HeroInfoModel:getAttrPointList(id)
    local num = 0
    if self.data and self.data.attrPointPlanNew then
        local pointList = self.data.attrPointPlanNew[self.data.attrPointId]
        if pointList and pointList.points then
            local addValue = pointList.points[id]
            if addValue then
                num=addValue.num
            end
        end
    end
    return num
end
-- 获取符文的总属性
function HeroInfoModel:getAllRuneAttrs()
    local conf = DynamicConfigData.t_module[45].condition[1]
    if (conf.type == 1 and self.data.level < conf.val) then
        return {}
    end
    local prosArr = {}

    local function checkProArr(proTab)
        for k, v in pairs(prosArr) do
            if v.id == proTab.id then
                v.value = v.value + proTab.value
                return true
            end
        end
        table.insert(prosArr, proTab)
        return false
    end

    local data = self.rune
    if data.blue and #data.blue > 0 then
        for i, v in ipairs(data.blue) do
            if v.attr and #v.attr > 0 then
                for i2, v2 in ipairs(v.attr) do
                    checkProArr(TableUtil.DeepCopy(v2))
                end
            end
        end
    end

    if data.green and #data.green > 0 then
        for i, v in ipairs(data.green) do
            if v.attr and #v.attr > 0 then
                for i2, v2 in ipairs(v.attr) do
                    checkProArr(TableUtil.DeepCopy(v2))
                end
            end
        end
    end

    if data.red and #data.red > 0 then
        for i, v in ipairs(data.red) do
            if v.attr and #v.attr > 0 then
                for i2, v2 in ipairs(v.attr) do
                    checkProArr(TableUtil.DeepCopy(v2))
                end
            end
        end
    end

    return prosArr
end

-- 获取符文总等级
function HeroInfoModel:getAllRuneLevel()
    local conf = DynamicConfigData.t_module[45].condition[1]
    if (conf.type == 1 and self.data.level < conf.val) then
        return 0
    end
    local data = self.rune
    local allLevel = 0
    if data.blue and #data.blue > 0 then
        for i, v in ipairs(data.blue) do
            allLevel = allLevel + RuneConfiger.getRuneLevel(v.itemCode)
        end
    end

    if data.green and #data.green > 0 then
        for i, v in ipairs(data.green) do
            allLevel = allLevel + RuneConfiger.getRuneLevel(v.itemCode)
        end
    end

    if data.red and #data.red > 0 then
        for i, v in ipairs(data.red) do
            allLevel = allLevel + RuneConfiger.getRuneLevel(v.itemCode)
        end
    end
    return allLevel
end

return HeroInfoModel
