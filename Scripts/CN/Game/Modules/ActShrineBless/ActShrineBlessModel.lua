--added by xhd
--神社祈福model层
local ActShrineBlessModel = class("ActShrineBlessModel",BaseModel)

function ActShrineBlessModel:ctor()
	self.moduleId = 1
	self.actType = GameDef.ActivityType.ShrinePray
    self.data = {}
    self.tempData = false --缓存数据
    self.checkFlag = false
end

function ActShrineBlessModel:setCheck2Flag(flag)
    self.checkFlag = flag
end

function ActShrineBlessModel:getCheck2Flag()
    return self.checkFlag
end

function ActShrineBlessModel:setShirneTempCode()
    if self.data.wish> 0 then
        local tempConfig = self:getConfigChooseById(self.data.wish)
        if tempConfig.reward and tempConfig.reward[1] then
            self.tempData = tempConfig.reward[1]
        end
    else
        self.tempData = false
    end
end

function ActShrineBlessModel:getShirneTempCode()
    return  self.tempData 
end

--获取对应的模块ID
function ActShrineBlessModel:getModuleId()
    local moduleId = 1
    local actData = ModelManager.ActivityModel:getActityByType(self.actType)
    moduleId = actData and actData.showContent.moduleId or 1
    return moduleId
end

function ActShrineBlessModel:getActivityId( )
	local viewData = ActivityModel:getActityByType( self.actType )
	return viewData.id
end


function ActShrineBlessModel:getData( ... )
	return  self.data
end

function ActShrineBlessModel:getitemDataById(id)
    local config = DynamicConfigData.t_PrayChoose[self.moduleId]
    if config[id] then
        return config[id].reward[1]
    end
    return nil
end

function ActShrineBlessModel:getConfigChooseById(id)
    local config = DynamicConfigData.t_PrayChoose[self.moduleId]
    if config[id] then
        return config[id]
    end
    return nil
end

function ActShrineBlessModel:getPrayChooseConfig( ... )
    local arr = {}
	local config = DynamicConfigData.t_PrayChoose[self.moduleId]
	for i,v in pairs(config) do
		table.insert(arr,v)
	end
	arr = TableUtil.sortBy(arr, "id", true)
	return arr
end

function ActShrineBlessModel:getDevideByModuleId(  )
    local config = DynamicConfigData.t_PrayChoose[self.moduleId]
    for i,v in pairs(config) do
		return v.devide
	end
	return 1
end

function ActShrineBlessModel:getTabData()
    local config = self:getPrayChooseConfig()
    local modArr = {}
    local lastModnum = 0
    for i,v in ipairs(config) do
        if lastModnum<=0 then
            lastModnum = v.mod[1]
            table.insert(modArr,v.mod)
        else
            if lastModnum ~=v.mod[1] then
                table.insert(modArr,v.mod)
                lastModnum = v.mod[1]
            end
        end
    end
    return modArr
end

function ActShrineBlessModel:getChooseConfigByMod( mod )
    local config =  self:getPrayChooseConfig()
    local rewardConfig = {}
    for i=1,#config do
        if config[i].mod[1] == mod then
            table.insert(rewardConfig,config[i])
        end
    end
    return rewardConfig
end

function ActShrineBlessModel:getRewardConfig( ... )
    local config = self:getPrayShowConfig(self.data.codeId)
    local config1 = {}
    local config2 = {}
    for i=1,#config do
       if self:checkHadGetReward(config[i].id) then
          table.insert(config1,config[i])
       else
        table.insert(config2,config[i])
       end
    end
    return config1,config2
end

function ActShrineBlessModel:getPrayDrawConfig( ... )
    local costItem = DynamicConfigData.t_PrayDraw[self.moduleId]
    if costItem then
        return costItem[1]
    end
    return nil
end


--右边奖励配置
function ActShrineBlessModel:getPrayShowConfig( code )
    if not code then code = 1 end
    local arr = {}
    local config = DynamicConfigData.t_PrayDrop[self.moduleId]
    for i,v in ipairs(config) do
        if v.code == code then
            if #arr>=35 then
                break
            end
            if self.data.ring-1 >= v.min and self.data.ring -1 <=v.max then
                table.insert(arr,v)
            end
        end
    end
    return arr
end

--检测 是否是抽过奖的格子
function ActShrineBlessModel:checkGeziReward(gridId)
   if self.data and self.data.reward then
       for k,v in pairs(self.data.reward) do
           if v.gridId == gridId then
              return true,v
           end
       end
   end
   return false,nil
end

function ActShrineBlessModel:checkHadGetReward(id)
    if self.data and self.data.reward then
        for k,v in pairs(self.data.reward) do
            if v.id == id then
               return true
            end
        end
    end
    return false
 end

function ActShrineBlessModel:findGeziReward(id)
    local config = DynamicConfigData.t_PrayDrop[self.moduleId]
    for i,v in ipairs(config) do
        if v.id == id then
            return v
        end
    end
end

function ActShrineBlessModel:initData(data)
    self.data = data
    --初始化下数据 避免服务器数据不全报错
    if not self.data.wish then
        self.data.wish = 0
    end
    if not self.data.reward then
        self.data.reward = {}
    end
    if not self.data.has then
        self.data.has = false
    end
    if not self.data.ring then
        self.data.ring = 1
    end
    if not self.data.wishPool then
        self.data.wishPool = {}
    end
    if not self.data.getRewardPool then
        self.data.getRewardPool = {}
    end
    self.moduleId  = self:getModuleId()
    self:checkRed()
    Dispatcher.dispatchEvent(EventType.ActShrineView_refreshPanal)
end

function ActShrineBlessModel:getLimitbyCodeId( code )
	if self.data.wishPool and self.data.wishPool[code] then
		return self.data.wishPool[code].limit
	end
	return 0
end

--红点检测
function ActShrineBlessModel:checkRed( ... )
    RedManager.updateValue("V_ACTIVITY_"..self.actType,false)
    local keyArr = {}
    table.insert(keyArr,"V_ACTIVITY_"..self.actType.."_big")
    table.insert(keyArr,"V_ACTIVITY_"..self.actType.."_begin")
    table.insert(keyArr,"V_ACTIVITY_"..self.actType.."_next")
    RedManager.addMap("V_ACTIVITY_" ..self.actType, keyArr)
    GlobalUtil.delayCallOnce("ActShrineBlessModel:checkRedot", function ()
        RedManager.updateValue("V_ACTIVITY_"..self.actType.."_big",false)
        --是否选了大奖
	    local config = self:getPrayChooseConfig(  )
        for i=1,#config do
            local hadNum = self:getLimitbyCodeId( config[i].id )
            local limit = config[i].limit
            if hadNum<limit and (self.data.wish and self.data.wish ==0) and not self.data.has then
                RedManager.updateValue("V_ACTIVITY_"..self.actType.."_big",true)
                break
            end
        end

        --是否可以点击开始寻宝
       if (not self.data.has) and (not self.data.isStartDraw) and (self.data.wish >0) then
           RedManager.updateValue("V_ACTIVITY_"..self.actType.."_begin",true)
       else
           RedManager.updateValue("V_ACTIVITY_"..self.actType.."_begin",false)
       end

       --是否可以点击下一层
       RedManager.updateValue("V_ACTIVITY_"..self.actType.."_next",false)
       if self.data.has then
        RedManager.updateValue("V_ACTIVITY_"..self.actType.."_next",true)
       end

    end, self, 0.5)

end


return ActShrineBlessModel
