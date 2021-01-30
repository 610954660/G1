--added by xhd 
--活动统一控制
local BaseModel = require "Game.FMVC.Core.BaseModel"
local ActivityModel = class("ActivityModel", BaseModel)
local ActivityMap = require "Game.Modules.Activity.ActivityMap"
local RedConst = require "Game.Consts.RedConst"
-- # 活动信息
-- .PActivity_Info {
-- 	id					0:integer			#活动id
-- 	type				1:integer			#活动类型
-- 	loopTime			2:integer			#循环类型
-- 	startMs				3:integer			#开始时间
-- 	endMs				4:integer			#结束时间
-- 	priority			5:integer			#优先级
-- 	showContent			6:string			#展示类型
-- 	realStartMs 		7:integer			#真实开始时间
-- 	realEndMs 			8:integer			#真实结束时间
-- 	iconName			9:string 			#图标名字
-- 	iconSrc 			10:string 			#图标资源名字
-- 	name 				11:string 			#活动名字
-- 	readyTime			12:integer			#准备时间
-- 	minLv				13:integer			#等级
-- 	status              14:integer          #状态  
-- }

function ActivityModel:ctor( ... )
   self.actData = {}  --所有活动数据（前端缓存）
   self.showData1  = {} --所有合集所有数据(可存在多个合集)
   self.tempShowData2 = {} --每个图标的数据放一份到这里，后面根据这个列出需要显示的图标
   self.showData3 = {}  --banner活动列表数据
   self.showData2 = {} --右上活动列表数据
end

function ActivityModel:clearData( ... )
   self.showData1  = {}
   self.tempShowData2 = {}
   self.showData3 = {}  --banner活动列表数据
   self.showData2 = {} --右上活动列表数据
end

--服务端要求本地配置的活动，先把活动信息传过来，然后再showContent传过来时再合并
function ActivityModel:saveShowContent(params)
	--printTable(69, "saveShowContent", self.actData)
	local showContentSave = json.decode(params.showContent)			
	for _,v in pairs(self.actData) do
		if v.id == params.id and v.type == params.type then
			for k,content in pairs(showContentSave) do
				if type(v.showContent) == "string" then
					--printTable(69, "saveShowContent_showContent", v)
					v.showContent = json.decode(v.showContent)
				end
				v.showContent[k] = content
			end
		end
	end
end

--isShrink 是否收起需要隐藏的按钮
function ActivityModel:getAllActDatas(isShrink)
	local showData2 = {}
	
	local redMap = {}
	for k,actList in pairs(self.showData2) do
		showData2[k] = {}
		for _,v in ipairs(actList) do
			if not isShrink or v.showContent.show == 1 then
				table.insert(showData2[k], v)
			else
				table.insert(redMap, "V_ACTIVITY_"..v.type)
			end
		end
		
	end
	RedManager.addMap("V_SHRINK_ACTIVITY", redMap)
	return self.showData1,showData2,self.showData3
end

function ActivityModel:getDataByShowData( activity_mask,actid)
	if self.showData1 and self.showData1[activity_mask] then
		for k,v in pairs(self.showData1[activity_mask]) do
			if v.showContent.mainActiveId == activity_mask and  v.id == actid then
				 return true
			end
		end
	end
	return false
end

--根据服务器 增加或者更新删除整理下整个活动列表
function ActivityModel:actServerDataSplit(data )
	--增加活动
	if data.addData then
		for k,v in pairs(data.addData) do
			if type(v.showContent) == "string" then
				v.showContent = json.decode(v.showContent)
			end 
			if v.type==GameDef.ActivityType.BoundaryWarOrder then
				if PlayerModel.boundary>1 then
					table.insert(self.actData,v)
				end
			else
				table.insert(self.actData,v)
			end
		end
	end
	--删除活动
	if data.delData then
		for k,v in pairs(data.delData) do
			for k1,v1 in pairs(self.actData) do
				if v.id == v1.id and v.type ==v1.type then
					table.remove(self.actData,k1)
					GlobalUtil.delayCallOnce("ActivityModel.closeFrameActFunc", function()
						Dispatcher.dispatchEvent("close_ActivityView",nil,v1.type) 
					end, nil, 0.1)
				end
			end
		end
	end
    
    --活动更新 运营调整活动之后通过这里更新
	if data.updateData then
		for k,v in pairs(data.updateData) do
			for k1,v1 in pairs(self.actData) do
				if v.id == v1.id and v.type ==v1.type then
					if type(v.showContent) == "string" then
						v.showContent = json.decode(v.showContent)
					end 
					self.actData[k1] = v
				end
			end
		end
	end
	for key, value in pairs(self.actData) do
		if value.type==102 then
			printTable(159,"这种DAU的都是",value)
		end
	end
	--printTable(152,"当前打印的",self.actData)
	-- self:checkYugaoAct(data.addData,data.updateData)
end

function ActivityModel:speDeleteSeverData(id)
	print(1,"speDeleteSeverData")
	for i,v in ipairs(self.actData) do
		if v.type == id then
			table.remove(self.actData,i)
			break
		end
	end
	self:clearData()
	self:screenActvity()
end

--通过活动模块ID获取活动数据
function ActivityModel:getActityByModuleId( moduleId )
	for k,v in pairs(self.actData) do
		if v.showContent  and v.showContent.moduleOpen == moduleId then
			return v
		end
	end
	return nil
end

--通过活动类型获取moduleId
function ActivityModel:getModuleIdByActivityType( activityType )
	local actData = ModelManager.ActivityModel:getActityByType(activityType)
	local moduleId = actData and actData.showContent.moduleId or 1
	return moduleId
end

--通过活动类型获取活动开始时间（ms）
function ActivityModel:getActivityStartMs( activityType )
	local actData = ModelManager.ActivityModel:getActityByType(activityType)
	local startMs = actData and actData.realStartMs or -1
	return startMs
end

function ActivityModel:updateSevenDayTime( id,startMs,endMs )
	for i,v in ipairs(self.actData) do
		if v.type == id then
			v.realStartMs = startMs
			v.realEndMs = endMs
            break
		end
	end
	-- printTable(1,"修改之后的七天",self.actData)
end

function ActivityModel:updateDataInfo( data)
	print(1,"ActivityModel:updateDataInfo")
	self:clearData()
	self:actServerDataSplit(data)
	--前端特殊的数据处理 服务器数据存在---------------
	self:specialActivityDisPone()
	self:screenActvity()
	
	
	-- Dispatcher.dispatchEvent("close_ActivityView",3) --针对集合3的入口剔除
end

--前端特殊的数据处理 服务器数据存在---------------
function ActivityModel:specialActivityDisPone(  )
	local actTypeArr = {GameDef.ActivityType.SurpriseGift,GameDef.ActivityType.SurpriseGiftDup,GameDef.ActivityType.SurpriseGiftEx}
	local dataArr = {TimeLimitGiftModel:getData(),TimeLimitGiftDupModel:getData(),backgroundTimeLimitGiftModel:getData()}
	for i,v in ipairs(self.actData) do
		for j=1,3 do
			if v.type == actTypeArr[j] then
				if #dataArr[j]<=0 then
					v.cannotShow = true
				else
					v.cannotShow = false
				end
			end
		end
	end
end

--又一个从外部打破框架的入口控制 限时礼包
function ActivityModel:updateTimitGift(activityType,data ) 
	print(1,"ActivityModel:updateTimitGift")
	if not data then return end
	for i,v in ipairs(self.actData) do
		if v.type == activityType then --存在入口
			if #data<=0 then
				v.cannotShow = true
			else
				v.cannotShow = false
			end
			self:clearData()
			self:screenActvity()
			break
		end
	end
end

function ActivityModel:showActivityEntrance(activityType, show)
	print(1," ActivityModel:showActivityEntrance")
	for _, activityBaseInfo in ipairs(self.actData) do
		if activityBaseInfo.type == activityType then
			if activityBaseInfo.cannotShow ~= not show then
				activityBaseInfo.cannotShow = not show
				self:clearData()
				self:screenActvity()
			end
			break
		end
	end
end


--等级提升 重新判断排列活动入口
function ActivityModel:refresh( ... )
	print(1,"ActivityModel:refresh")
	self:clearData()
	self:screenActvity()
end



function ActivityModel:screenActvity( )
	local serverTime = ModelManager.ServerTimeModel:getServerTimeMS()
	for _, v in pairs(self.actData) do
		repeat
			if v.cannotShow then
				break
			end
			local maxNum =  PushMapModel:haveBeenPassPoint()
			if tonumber(v.minLv) <= tonumber(ModelManager.PlayerModel.level) then
				if v.showContent then
					if type(v.showContent)== "string" then
						v.showContent = json.decode(v.showContent)
					end
				end
				if v.showContent.moduleOpen and not  ModuleUtil.moduleOpen(v.showContent.moduleOpen, false) then
					break
				end
				if v.showContent.fightfd and v.showContent.fightfd > maxNum then
					break
				end

				--如果服务器下发数据错误  前端拦截下
				if v.realEndMs< serverTime then
					break
				end

				if v.id == -22 then
					v.showContent.enterType = 1
				end
				if v.type == GameDef.ActivityType.SecordCharge then
					local SecordChargeinfo= FirstChargeLuxuryGiftModel.currentGift
					 if SecordChargeinfo and SecordChargeinfo.isShow==false then
						break
					 end
				end
				--根据活动标识 activitymark 独立活动 2合集
				if v.showContent.activitymark == 1 then --独立活动
					if v.showContent.enterType == 1 then --enterType  入口类型  1btn  2banner  3 btn&banner
						self.tempShowData2["1_"..v.id] = v
					elseif v.showContent.enterType == 2 then
						table.insert(self.showData3,v)
					elseif v.showContent.enterType == 3 then
						self.tempShowData2["1_"..v.id] = v
						table.insert(self.showData3,v)
					end
				elseif v.showContent.activitymark == 2 then --框架活动 合集
					if v.showContent.enterType == 1 then --btn
						if not self.showData1[v.showContent.mainActiveId] then
							self.showData1[v.showContent.mainActiveId] = {}
						end
						local key = "2_"..v.showContent.mainActiveId
						if v.showContent.mainActiveId ~= 1 and (v.showContent.row  or not self.tempShowData2[key]) then
							self.tempShowData2[key] = v
						end
						table.insert(self.showData1[v.showContent.mainActiveId],v)
					elseif v.showContent.enterType == 2 then --banner
						if not self.showData1[v.showContent.mainActiveId] then
							self.showData1[v.showContent.mainActiveId] = {}
						end
						local key = "2_"..v.showContent.mainActiveId
						if v.showContent.mainActiveId ~= 1 and (v.showContent.row  or not self.tempShowData2[key]) then
							self.tempShowData2[key] = v
						end
						table.insert(self.showData1[v.showContent.mainActiveId],v)
						table.insert(self.showData3,v)
					elseif v.showContent.enterType == 3 then --btn &banner
						if not self.showData1[v.showContent.mainActiveId] then
							self.showData1[v.showContent.mainActiveId] = {}
						end
						local key = "2_"..v.showContent.mainActiveId
						if v.showContent.mainActiveId ~= 1 and (v.showContent.row  or not self.tempShowData2[key]) then
							self.tempShowData2[key] = v
						end
						table.insert(self.showData1[v.showContent.mainActiveId],v)
						table.insert(self.showData3,v)
					elseif v.showContent.enterType == 4 then --直接出現在合集 没有单独入口，没有banner入口
						if not self.showData1[v.showContent.mainActiveId] then
							self.showData1[v.showContent.mainActiveId] = {}
						end
						table.insert(self.showData1[v.showContent.mainActiveId],v)
					end
				end
			end
		until true
	end
    
    self:sortActData()
    printTable(1,"self.showData1",self.showData1[3])
	Dispatcher.dispatchEvent("activity_update")
end

--检测预告弹出页面 1.如果存在预告活动 弹出对应的预告页面 2.如果活动到达开启时间
-- function ActivityModel:checkYugaoAct( addData,updateData )
-- 	--先保留
-- end

--添加红点
function ActivityModel:add_RedDots( ... )
	--UI框架添加红点
	local redMap = {}
	if (self.showData1[1]) then
		for _,v in ipairs(self.showData1[1]) do
			table.insert(redMap, "V_ACTIVITY_"..v.type)
		end
		RedManager.addMap("M_ACTIVITYFRAME", redMap)
	end
	--UI框架有多个 可能存在 1 2 3 4合集 其中 3合集没开的情况
	for k,v in pairs(self.showData1) do
		if (k ~= 1) then 
			local Map = {}
			for _,v in ipairs(self.showData1[k]) do
				table.insert(Map, "V_ACTIVITY_"..v.type)
			end
			RedManager.addMap("M_ACTIVITYFRAME_"..k, Map)
		end
	end
	-- RedManager.printDebug()
	print(1,"ActivityModel:add_RedDots 添加活动红点映射关系完成")
	-- printTable(1,"showData1集合",self.showData1)
end

function ActivityModel:sortActData( ... )
	print(1,"sortActData活动排序")
	--banner数据排序
	if #self.showData3>0 then
		table.sort( self.showData3, function(a,b)
			return a.priority<b.priority
		end )
	end

	--强行在头部插入一个精彩活动入口
    local data = {}
    local showContent = {}
    showContent.bannerSrc = "banner_3101"
    data.showContent = showContent
    data.speFlag = true
    data.priority = 1
    table.insert(self.showData3,1,data)

	--所有合集排序
	for k,v in pairs(self.showData1) do
		if self.showData1[k] and #self.showData1[k]>0 then
			table.sort( self.showData1[k], function( a,b )
			return a.priority <b.priority
		end )
		end
	end
    
	for j,v in pairs(self.tempShowData2) do
		local row = v.showContent.row or 1
		if not self.showData2[row] then self.showData2[row] = {} end
		v.showContent.column = v.showContent.column or 1000
		table.insert(self.showData2[row],v)
	end

	for k,v in pairs(self.showData2) do
		table.sort(v,function( a,b)
			return a.showContent.column < b.showContent.column
		end)
	end

    self:add_RedDots()

end

function ActivityModel:hasActivity(actType)--活动存在并且功能开启
	local curHasActivity=false
	local actInfo= self:getActityByType( actType )
	if not actInfo then
		return curHasActivity
	end
	
	local  moduleisOpen=false--活动都应该配置一个模块id
	if actInfo.showContent and actInfo.showContent.moduleOpen then
		local moduleId=actInfo.showContent.moduleOpen
		 local tips=ModuleUtil.moduleOpen(moduleId,false)
		 if tips==true then--前端开启了该功能
			moduleisOpen=true
		 end
	end
	local activeIsOpen=false
 	local actState=self:getActStatusAndLastTime(actInfo.id)
	if actState==2 then
		activeIsOpen=true
	end	
	local fightfdPass=true
	local maxNum =  PushMapModel:haveBeenPassPoint()
	if actInfo.showContent.fightfd and actInfo.showContent.fightfd > maxNum then
		fightfdPass=false	
	end
	if moduleisOpen and activeIsOpen and fightfdPass then
		curHasActivity=true
	end
	return curHasActivity  
end

--0 未开放  1 已开放 未开启不能参与  2已开放 已开启可参与  3.未结束 结算中不可以参与  4.已结束 已关闭
--返回状态 和不同状态下的倒计时时间  时间为毫秒
function ActivityModel:getActStatusAndLastTime( actId)
	local serverTime = ModelManager.ServerTimeModel:getServerTimeMS()
	for k,v in pairs(self.actData) do
		if v.id == actId then
            if (v.realEndMs - v.realStartMs)/1000 >= 365 * 24 *3600 then --永久
	            return 2,-1  --永久
	        else
	        	if v.readyTime == 0 then --没有准备阶段
					if not v.rewardTime or v.rewardTime ==0 then
						if serverTime< v.realStartMs then
							return 1,v.realStartMs - serverTime
						else
							if serverTime>= v.realEndMs then
								return 4,0
							else
		                    	return 2,v.realEndMs - serverTime
							end
						end
					else
						if serverTime<v.realStartMs then
							return 1,v.realStartMs - serverTime
						else
							if serverTime< v.rewardTime then
								return 2,v.rewardTime - serverTime
							elseif serverTime>= v.rewardTime and serverTime<=v.realEndMs  then
								return 3,v.realEndMs - serverTime
							elseif serverTime> v.realEndMs  then
								return 4,0
							end
						end
					end

				else --有准备阶段
					 if v.rewardTime ==0 then --没有结算
	                     if serverTime< v.readyTime then
	                     	return 0,v.readyTime - serverTime
	                     else
	                     	if serverTime>=v.readyTime and serverTime< v.realStartMs then
	                     		return 1,v.realStartMs - serverTime
	                     	elseif serverTime>= v.realStartMs and serverTime<=v.realEndMs then
	                     		return 2,v.realEndMs - serverTime
	                     	elseif serverTime>v.realEndMs then
	                     		return 4,0
	                     	end
	                     end
					 else --有结算
                        if serverTime< v.readyTime then
                        	return 0,v.readyTime - serverTime
                        else
                           if serverTime<= v.realStartMs then
                           	   return 1,v.realStartMs - serverTime
                           elseif serverTime>v.realStartMs and serverTime< v.rewardTime then
                           	  return 2,v.rewardTime - serverTime
                           elseif serverTime>v.rewardTime and serverTime< v.realEndMs then
                           	  return 3,v.realEndMs - serverTime
                           elseif serverTime>v.realEndMs then
                           	  return 4,0
                           end
                        end
					 end
				end
	        end
		end
	end
    return 0
end

function ActivityModel:getActityById( actId )
	for k,v in pairs(self.actData) do
		if v.id == actId then
			return v
		end
	end
end

function ActivityModel:getActityByType( actType )

	-- printTable(8848,"self.actData",self.actData)
	for k,v in pairs(self.actData) do
		-- print(8848,v.type,"========",actType)
		if v.type == actType then
			return v
		end
	end
	return false
end

--组装 注意区分合集活动ID
function ActivityModel:marketUIWinData(mainActiveId)
    local data = {}
    for k,v in pairs(self.showData1) do
    	data[k] = {}
    	for i,v2 in ipairs(self.showData1[k]) do
    		local temp =  {
		        page = "DailySignView",
		        btData = {
		            title = "",
		        },
		        red = "V_ACTIVITY_"..v2.type, --红点名称
		        pageData = {
		            -- title = "我修改成标题11111",
		            -- bg = "Map/100001.jpg",
		            -- icon = "icon/item/10000005.png",
		        }
			}
	        temp.page = ActivityMap.actWinMap[v2.showContent.moduleOpen]
			temp.btData.title = v2.name
			temp.btData.icon =string.format( "%s%s","UI/activity/",v2.iconName) 
			temp.activeBg=string.format( "%s%s","UI/activity/",v2.showContent.activeBg) 
			temp.actType=v2.type
			temp.actmoduleId=v2.showContent.moduleOpen
			table.insert(data[k],temp)
    	end
	end
    return data[mainActiveId]
end


return ActivityModel