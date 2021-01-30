--DataCheckUtil  配置表检查测试
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger"
local DataCheckUtil = {}
local _check_data ={
    --字段名映射到具体的表主键，0默认为通用物品格式（ 例如： [2,1,3405045600][3,10000007,1450] ） ,
    ["t_tower"]={
        ["key"] = 2,    --当前表有多少个主键 ,必须填写
        ["fightId"]="t_fight",
        ["dropId"]="t_reward",
        ["rewardPre"]=0
    },
    ["t_hero"]={
        ["key"] = 1,
        ["skill3"]="t_skill",
        ["skill4"]="t_skill"
    } 
}

----检查配置处理
function DataCheckUtil.checkData()
    print(1 , "==============开始检测配置===================")
    for k, v in pairs(_check_data) do
        local t_data = DynamicConfigData[k]
        if t_data ~= nil then            
            for k1,v1 in pairs(t_data) do                
                if v1 ~= nil then
                    --多层检测逻辑
                    if v.key ==1 then
                        DataCheckUtil.checkItem(k , v , v1)
                    elseif v.key == 2 then
                       for k3 , v3 in pairs( v1 ) do
                        if v3 ~= nil then
                            DataCheckUtil.checkItem(k , v , v3)
                        end
                       end 
                    end
                end 
            end
        end
    end
    print(1 , "================所有配置检测完毕==============")

end

function DataCheckUtil.checkItem(k , v , v1)
    --检测表中字段处理
    for k2,v2 in pairs( v ) do        
        local target_value = v1[""..k2]
        if k2 ~= "key" then 
             if target_value == nil and k2 ~= "key" then
                print(1, "error："..k.." 找不到对应字段："..k2)    
                printTable(1, "error："..k.." 找不到对应字段："..k2 , v1)    
            else
                --v1[''..k2] 为当前字段值 , v2 为映射表名
                if v2 ==0 then  --检查物品表
                    if target_value ~= nil then
                        for k3,v3 in pairs( target_value ) do
                            local t_item = ItemConfiger.getInfoByCode( v3.code )
                            if t_item == nil then
                                print(1, "error："..k.."中"..k2.."字段映射表 t_item 找不到对应物品："..v3.code )   
                            end
                        end
                    end
                    -- printTable(1 , "信息 ，", k2 , v1[''..k2] , v1 )
                elseif type(target_value)=="table" then
                    local check_data = DynamicConfigData[v2]
                    for k4,v4 in pairs(target_value) do                        
                        if check_data == nil then
                            print(1, "error："..k.."中"..k2.."字段映射表 "..v2)
                        elseif check_data[v4] ==nil then
                            print(1, "error："..k.."中"..k2.."字段映射表 "..v2.." 找不到对应数据："..v4 )
                        end
                    end
                else
                    local check_data = DynamicConfigData[v2] 
                    if check_data == nil then
                        print(1, "error："..k.."中"..k2.."字段映射表 "..v2)
                    elseif check_data[target_value] ==nil then
                        print(1, "error："..k.."中"..k2.."字段映射表 "..v2.." 找不到对应数据："..target_value )
                    end
                end
            end  
        end                             
    end
end




return DataCheckUtil