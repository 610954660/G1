
-- added by zn
-- 名字库
local NameConfiger = {}

local data = {}--DynamicConfigData.NickNameLib;
local name = {}--data.name; -- 姓
local male = {}--data.male; -- 男名
local female = {}--data.female; -- 女名
local verb = {}--data.verb; -- 动词
local noun = {}--data.noun; -- 名词
local adjective = {}--data.adjective; -- 形容词
local adverb = {}--data.adverb; -- 副词
local verbObj = {}--data.verbObj; -- 动宾

--[[
    1: 姓 + 名
    2、 动词/形容词 + 名词
    3、 副词/名词 + 动词
    4、 名词 + 名词
    5、 形容词 + 名词
    6、 副词 + 动宾
]]

-- 随机昵称 1 男 2 女
function NameConfiger.randomName(sex)
    data = DynamicConfigData.NickNameLib;
    name = data.name; -- 姓
    male = data.male; -- 男名
    female = data.female; -- 女名
    verb = data.verb; -- 动词
    noun = data.noun; -- 名词
    adjective = data.adjective; -- 形容词
    adverb = data.adverb; -- 副词
    verbObj = data.verbObj; -- 动宾
    local type = math.random(10);
    if (type <= 5) then
        return NameConfiger.getType1(sex);
    elseif (type == 6) then
        return NameConfiger.getType2();
    elseif (type == 7) then
        return NameConfiger.getType3();
    elseif (type == 8) then
        return NameConfiger.getType4();
    elseif (type == 9) then
        return NameConfiger.getType5();
    elseif (type == 10) then
        return NameConfiger.getType6();
    end
end

-- 1、 姓 + 名
function NameConfiger.getType1(sex)
    local str1 = name[math.random(#name)];
    local str2 = "";
    if (sex == 1) then
        str2 = male[math.random(#male)];
    else
        str2 = female[math.random(#female)];
    end
    return str1..str2;
end

-- 2、 动词/形容词 + 名词
function NameConfiger.getType2()
    local rand = math.random();
    local str1 = "";
    if (rand < 0.5) then
        str1 = verb[math.random(#verb)];
    else
        str1 = adjective[math.random(#adjective)];
    end
    local str2 = noun[math.random(#noun)];
    return str1..str2;
end

-- 3、 副词/名词 + 动词
function NameConfiger.getType3()
    local rand = math.random();
    local str1 = "";
    if (rand < 0.5) then
        str1 = noun[math.random(#noun)];
    else
        str1 = adverb[math.random(#adverb)];
    end
    local str2 = verb[math.random(#verb)];
    return str1..str2;
end

-- 4、 名词 + 名词
function NameConfiger.getType4()
    local len = #noun;
    local rand1 = math.random(len);
    local rand2 = math.random(len);
    return noun[rand1]..noun[rand2];
end

-- 5、 形容词 + 名词
function NameConfiger.getType5()
    local str1 = adjective[math.random(#adjective)];
    local str2 = noun[math.random(#noun)];
    return str1..str2;
end

-- 6、 副词 + 动宾
function NameConfiger.getType6()
    local str1 = adverb[math.random(#adverb)];
    local str2 = verbObj[math.random(#verbObj)];
    return str1..str2;
end

return NameConfiger