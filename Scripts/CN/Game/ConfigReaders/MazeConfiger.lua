--added by xhd
--任务配置读取器
local MazeConfiger = {}
function MazeConfiger.getAllConfig()
	local dict = DynamicConfigData.t_maze
    if not dict then
        dict = require "Configs.Generate.t_maze"
    end
    return dict
end

function MazeConfiger.getConfig(floor,row,cell )
    local config = MazeConfiger.getAllConfig()
    for k,v in pairs(config) do
        if v.mazeline == row and v.mazenumber == cell and tonumber(string.sub(v.id,1,1))  == floor then
            return v
        end
    end
    return nil
end

function MazeConfiger.getConfigByMazeId(id)
    local config = MazeConfiger.getAllConfig()
    return config[id]
end

function MazeConfiger.getMazeRelicConfig( ... )
    -- body
end

function MazeConfiger.getMazeShopByIdAndNum( id,number)
    if #DynamicConfigData.t_mazeShop[id]>0 then
        for i,v in ipairs(DynamicConfigData.t_mazeShop[id]) do
            if v.number == number then
                return v
            end
        end
    end
end

function MazeConfiger.getMonsterConfig( code )
   return DynamicConfigData.t_monster[code]
end

function MazeConfiger.getFightInfo( monstersquad,monsterId)
    local monsterInfo = {}
    for i=1,8 do
        if DynamicConfigData.t_fight[monstersquad]["monsterId"..i] == monsterId then
             monsterInfo.monsterId = monsterId
             monsterInfo.level = DynamicConfigData.t_fight[monstersquad]["level"..i]
             monsterInfo.star = DynamicConfigData.t_fight[monstersquad]["star"..i]
             return monsterInfo
        end
    end
end

function MazeConfiger.getFightConfig( monstersquad )
    local monsterArr = {}
    for i=1,8 do
        local monsterInfo = {}
        if DynamicConfigData.t_fight[monstersquad]["monsterId"..i] then
             monsterInfo.monsterId = DynamicConfigData.t_fight[monstersquad]["monsterId"..i]
             monsterInfo.level = DynamicConfigData.t_fight[monstersquad]["level"..i]
             monsterInfo.star = DynamicConfigData.t_fight[monstersquad]["star"..i]
             monsterArr[i] = monsterInfo
        end
    end
    return monsterArr
end


function MazeConfiger.getMonsterIdBysquad( monstersquad )
    local monsterInfo = {}
    if DynamicConfigData.t_fight[monstersquad]["monsterId1"] then
         monsterInfo.monsterId = DynamicConfigData.t_fight[monstersquad]["monsterId1"]
         monsterInfo.level = DynamicConfigData.t_fight[monstersquad]["level1"]
         monsterInfo.star = DynamicConfigData.t_fight[monstersquad]["star1"]
    end
    return monsterInfo
end

function MazeConfiger.getMonsterFightValBysquad( monstersquad )
    if DynamicConfigData.t_fight[monstersquad]then
        if DynamicConfigData.t_fight[monstersquad]["monstercombat"] then
            return DynamicConfigData.t_fight[monstersquad]["monstercombat"]
        end
    end
    return nil
end

function MazeConfiger.getRelicConfig( skillid )
    local config = {}
    if DynamicConfigData.t_skill[skillid] then
        config.skillName = DynamicConfigData.t_skill[skillid].skillName
        config.showName = DynamicConfigData.t_skill[skillid].showName
    end
    if DynamicConfigData.t_mazeRelic[skillid] then
        config.color = DynamicConfigData.t_mazeRelic[skillid].color
        config.mazeRelictype = DynamicConfigData.t_mazeRelic[skillid].mazeRelictype
        config.apply = DynamicConfigData.t_mazeRelic[skillid].apply
    end
    
    return config
end

function MazeConfiger.getGebuliId(  )
    return DynamicConfigData.t_Mazeconst["MazeGebuliSid"].MazeValue
end

function MazeConfiger.getSquadShow( ... )
   return DynamicConfigData.t_Mazeconst["MazePlayerSquadShow"].MazeValue
end

function MazeConfiger.getHardLevelShow( ... )
    return DynamicConfigData.t_Mazeconst["MazeHardLevelShow"].MazeValue
 end

return MazeConfiger