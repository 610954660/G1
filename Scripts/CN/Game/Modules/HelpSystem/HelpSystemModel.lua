
-- added by zn

local HelpSystemModel = class("HelpSystemModel", BaseModel);

function HelpSystemModel: ctor()
    self.selected = 1;
    -- 我的上阵阵容
    self.myHeroList = false;
    -- 对应英雄的最高数据
    self.heroInfo = false;
    -- 我的阵容的展示数据
    self.myHeroInfo = false;
end

-- 获取英雄信息
function HelpSystemModel:getHeroInfo(cb)
    local array = BattleModel:getArrayInfo(GameDef.BattleArrayType.Chapters, true).array;
    local uidList = {};
    for uid in pairs(array) do
        table.insert(uidList, uid);
    end
    local info = {
        HeroList = uidList
    }
    RPCReq.Stronger_GetHeroInfo(info, function (data)
        self.heroInfo = data.heroInfo;
        self.myHeroInfo = data.myHero;
        if cb then cb() end;
    end)
end

-- 获取上阵英雄
function HelpSystemModel: getAllInBattle()
    local array = BattleModel:getArrayInfo(GameDef.BattleArrayType.Chapters, true).array;
    local heroes = {};

    for uid in pairs(array) do
        table.insert(heroes, CardLibModel:getHeroByUid(uid))
    end
    -- printTable(1, heroes);
    TableUtil.sortByMap(heroes, {{key="combat", asc=true}});
    self.myHeroList = heroes;
    return heroes;
end

-- 英雄等级 level   英雄进阶 stage   英雄星级 star   特性学习 passiveSkill  装备穿戴 equip
-- 工会技能 guildSkill  符文镶嵌 rune
function HelpSystemModel: getHeroSelfAndMaxByType(type)
    if (#self.myHeroList == 0) then
        return 0, 0;
    end
    local select = self.myHeroList[self.selected];
    local my = self.myHeroInfo[select.uuid][type] or 0;
    local max = self.heroInfo[select.code][type] or 0;
    return my, max;
end

return HelpSystemModel;