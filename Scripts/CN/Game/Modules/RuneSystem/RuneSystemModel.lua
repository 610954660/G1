--Name : RuneSystemModel.lua
--Author : generated by FairyGUI
--Date : 2020-5-21
--Desc : 符文系统数据层
local RuneSystemModel = class("RuneSystemModel", BaseModel)
local  RuneConfiger = require "Game.Modules.RuneSystem.RuneConfiger"
function RuneSystemModel:ctor()
   self.allRunePages = {} --所有符文页
   self.curBjRuneID = 0
   self.runeCompDataArr = {} --合成系统数据记录
   self.curSelectRuneData = false --装备页当前选中的符文格子 仅用于数据记录保存
   self.curRuleResetData = false --当前符文重置数据保存
   self.freeTimes = 0
end

function RuneSystemModel:clear( ... )
	print(1,"RuneSystemModel:clear")
   self.allRunePages = {} --所有符文页
   self.curBjRuneID = 0
   self.runeCompDataArr = {} --合成系统数据记录
   self.curSelectRuneData = false --装备页当前选中的符文格子 仅用于数据记录保存
   self.curRuleResetData = false --当前符文重置数据保存
end



--检测红点
function RuneSystemModel:checkRuneRedDot( ... )
	print(1,"RuneSystemModel checkRuneRedDot")
    GlobalUtil.delayCallOnce("RuneSystemModel:checkRuneRedDot",function()
		local freeTime = self:getFreeTimes(  )
		local data = self:getRunePackByType( 0,3)
		local dayStr = DateUtil.getOppostieDays()
		local hasClickToay = FileCacheManager.getBoolForKey("rune_reset_click".."_"..dayStr,false)  --当天点过就不能再显示红点了
	    if (not hasClickToay) and freeTime>0 and #data>0 then
	    	RedManager.updateValue("V_RUNERESET",true)
	    else
	    	RedManager.updateValue("V_RUNERESET",false)
	    end

	    local data = self:getRunePagesById(self.curBjRuneID)
		local redFlag = false
	
		--检测技能 如果有技能可选但没选

		local skills = self:getcurPageSkills(self.curBjRuneID)
		--printTable(1,skills)
		if (not skills) or #skills<=0 or (#skills==1 and skills[1]==0 ) then
				--检测是否有技能能学习
				local maxLevel = self:getRuleAllLevel( self.curBjRuneID )
				local skillConfig = RuneConfiger.getRuneSkillConfig(  )
				for k,v in pairs(skillConfig) do
					if maxLevel>=v.levellimit then --等級足夠
						--  RedManager.updateValue("V_PACKAGE",true)
						RedManager.updateValue("V_PACKAGE_SKILL",true)
						return true
					end
				end
		end

		RedManager.updateValue("V_PACKAGE_SKILL",false)
		RedManager.updateValue("V_PACKAGE",false)

	    if not data then return end
		if data.blue and #data.blue>0 then
	       for i,v in ipairs(data.blue) do
	           if v.itemCode==0 then
	           	  --查看背包有没有道具
	           	  local bagItems = self:getRunePackByType(1)
	           	  if #bagItems>0 then
	           	  	 redFlag = true
	           	  	 RedManager.updateValue("V_PACKAGE",true)
	           	  	 return true
	           	  end
	           end
	       end
		end


		if data.green and #data.green>0 then
	       for i,v in ipairs(data.green) do
	           if v.itemCode==0 then
	           	 --查看背包有没有道具
	           	  local bagItems = self:getRunePackByType(3)
	           	  if #bagItems>0 then
	           	  	 redFlag = true
	           	  	 RedManager.updateValue("V_PACKAGE",true)
	           	  	 return true
	           	  end
	           end
	       end
		end

		if data.red and #data.red>0 then
	       for i,v in ipairs(data.red) do
	           if v.itemCode==0 then
	           	  --查看背包有没有道具
	           	  local bagItems = self:getRunePackByType(2)
	           	  if #bagItems>0 then
	           	  	 redFlag = true
	           	  	 RedManager.updateValue("V_PACKAGE",true)
	           	  	 return true
	           	  end
	           end
	       end
		end
		
		if data.black and #data.black>0 then
	       for i,v in ipairs(data.black) do
	           if v.itemCode==0 then
	           	 --查看背包有没有道具
	           	  local bagItems = self:getRunePackByType(3)
	           	  if #bagItems>0 then
	           	  	 redFlag = true
	           	  	 RedManager.updateValue("V_PACKAGE",true)
	           	  	 return true
	           	  end
	           end
	       end
		end

	    --没有符文符合 检测技能 如果有技能可选但没选
		-- if not redFlag then
		--    local skills = self:getcurPageSkills(self.curBjRuneID)
		--    --printTable(1,skills)
		--    if (not skills) or #skills<=0 or (#skills==1 and skills[1]==0 ) then
		--    	  --检测是否有技能能学习
		--    	  local maxLevel = self:getRuleAllLevel( self.curBjRuneID )
		--    	  local skillConfig = RuneConfiger.getRuneSkillConfig(  )
		--    	  for k,v in pairs(skillConfig) do
		--    	  	 if maxLevel>=v.levellimit then --等級足夠
		--    	  	 	--  RedManager.updateValue("V_PACKAGE",true)
		-- 				RedManager.updateValue("V_PACKAGE_SKILL",true)
		--    	  	 	 return true
		--    	  	 end
		--    	  end
		--    end
		-- end
		RedManager.updateValue("V_PACKAGE",false)

		--检测是否还有英雄没上阵起效
		local excluedUuids = self:getHeroExcluedUuids()
		local flag = false
		local runeHeroEquipConfig = RuneConfiger.getRunePalace()
		for i=1,5 do
			local configTime = runeHeroEquipConfig[i]
			local data = self:getEquipHeroByPos(i)
			if data then
				if data.cd>0 then
					local nowTime = ServerTimeModel:getServerTimeMS()
	        		local lastTime = configTime.retime -( nowTime - data.cd)/1000
	        		if not (lastTime>0) then
	        			flag = true
	        			break
	        		end
				else
					if not (data.uuid~="" and data.uuid~=nil) then
	        			flag = true
	        		end
				end
		    else
                if runeHeroEquipConfig[i].type == 1 then
                	flag = true
                	break
                end
		    end
		end

		if flag then
			local hadFlag = CardLibModel:checkLeveltoLevel(excluedUuids,100)
			if hadFlag then
				RedManager.updateValue("V_PACKAGE",true)
				return
			end
		end
		RedManager.updateValue("V_PACKAGE",false)

    end, self, 0.2)
end

function RuneSystemModel:getGurRunePageName()
	local curBjRuneID = self:getCurBjRuneID()
	local curRunePageData = self:getRunePagesById(curBjRuneID)
	if curRunePageData then
		return curRunePageData.name
	end
	return ""
end

function RuneSystemModel:getHeroExcluedUuids( )
    local excluedUuids = {}
	for i=1,5 do
		local data = self:getEquipHeroByPos(i)
		if data and data.uuid~="" and data.uuid~=nil then
			table.insert(excluedUuids,data.uuid)
		end
	end
	return excluedUuids
end


function RuneSystemModel:setFreeTimes( freetime )
	self.freeTimes =  freetime
	Dispatcher.dispatchEvent("reset_update_FreeTime")
end

function RuneSystemModel:getFreeTimes(  )
	return self.freeTimes 
end


function RuneSystemModel:setCurRuneResetData( data )
	self.curRuleResetData = data
end

function RuneSystemModel:getCurRuneResetData( ... )
	return self.curRuleResetData
end

function RuneSystemModel:setCurSelectRuneData( data )
	self.curSelectRuneData = data
end

function RuneSystemModel:getCurSelectRuneData(  )
	return self.curSelectRuneData
end


function RuneSystemModel:setRuneCompDataArr( arr )
	self.runeCompDataArr = arr
	printTable(1,"self.runeCompDataArr",self.runeCompDataArr)
end

function RuneSystemModel:getRuneCompDataArr(  )
	return self.runeCompDataArr
end


--获取合成材料数量
function RuneSystemModel:getRuneCompCount( ... )
	local count = 0
	for k,v in pairs(self.runeCompDataArr) do
		count = count + 1
	end
	return count
end

--一键添加
function RuneSystemModel:toOneKeyCompRune( ... )
	-- local data = ModelManager.PackModel:getRuneBag():sort_bagDatas()
	local flag = false
	if self.runeCompDataArr and self:getRuneCompCount() == 5 then
		RollTips.show(Desc.Rune_txt43)
		return false
    end
	for k,v in pairs(self.runeCompDataArr) do
		if v then
			flag = true
			break
		end
	end

    if flag then
    	RollTips.show(Desc.Rune_txt45)
    	return false
    else
		local showData = {}
		
	    for i=1,2 do --等级
	    	showData = {}
			for j=1,3 do --颜色
				local data = self:getRunePackByType(j)
				local tempIDArr = {}
	    		for k,v in pairs(data) do
					local config = RuneConfiger.getRuneConfig( v:getItemCode() )
					if config.level == i then
						-- if config.color>=4 then
						-- 	if showData[1] then
						-- 		print(1,k,config.itemId,showData[1]:getItemCode())
						-- 	end
							
						-- 	if #showData>0 then
						-- 		-- local config2 = RuneConfiger.getRuneConfig( showData[1]:getItemCode() )
						-- 		if config.itemId == tempID then
						-- 			table.insert(showData,v)
						-- 		end
						-- 	else
								table.insert(showData,v)
								-- tempID =  config.itemId
							-- end
						-- else
						-- 	table.insert(showData,v)
						-- end
					end
					if #showData>=5 then
						return showData
					end
				end

				if #showData<5 then
					showData = {}
				end
	    	end
		end
		
		local tempData = {}
		local flag = false
		if #showData<=0 then
			for i=1,2 do --等级
				local data = self:getRunePackByType(4)
				for k,v in pairs(data) do
					local config = RuneConfiger.getRuneConfig( v:getItemCode() )
					if config.level == i then
						if not tempData[v:getItemCode()] then
							local vAr = {}
							table.insert( vAr,v )
							tempData[v:getItemCode()] = vAr
						else
							if #tempData[v:getItemCode()]<5 then
								table.insert( tempData[v:getItemCode()],v)
							else
								break
							end
						end
					end
				end
				for k,v in pairs(tempData) do
					if #v>=5 then
						showData = v
						return showData
					end
				end
				tempData = {}
			end
		end
		

	    return showData
    end
end

--获取当前合成等级
function RuneSystemModel:checkRuneCompCurLevel( itemCode )
	local level = false
	local oldColor = false
	local oldConfig = false
	if self.runeCompDataArr then
		for k,v in pairs(self.runeCompDataArr) do
			level =  RuneConfiger.getRuneLevel( v:getItemCode()) --原来的等级
			oldColor = RuneConfiger.getRuneColor( v:getItemCode()) 
			oldConfig = RuneConfiger.getRuneConfig( v:getItemCode() )
			break
		end
	end
    local level2 = RuneConfiger.getRuneLevel( itemCode)
    if not level then
    	return true,level2
    end
	if level and level==level2 then
		return true,level
    end
    return false
end

function RuneSystemModel:checkRuneSpeColor( itemCode )
	local oldColor = false
	local oldConfig = false
	if self.runeCompDataArr then
		for k,v in pairs(self.runeCompDataArr) do
			oldColor = RuneConfiger.getRuneColor( v:getItemCode()) 
			oldConfig = RuneConfiger.getRuneConfig( v:getItemCode() )
			break
		end
	end
    if not oldColor then
    	return true
    end
	local color =  RuneConfiger.getRuneColor( itemCode )
	if color >=4 then
		if oldColor == color then
			local config = RuneConfiger.getRuneConfig( itemCode )
			if oldConfig.itemId == config.itemId then
				return true
			end
			return false
		else
			return false
		end
	else
		return  true
	end
	
end



function RuneSystemModel:checkRuneCompCurColor( itemCode )
	local color = false
	if self.runeCompDataArr then
		for k,v in pairs(self.runeCompDataArr) do
			color =  RuneConfiger.getRuneColor( v:getItemCode()) --前面的颜色
			break
		end
	end
    local color2 = RuneConfiger.getRuneColor( itemCode)
    if not color then
    	return true,color
    end
    if color and color==color2 then
        return true,color
    end
    return false
end


function RuneSystemModel:setCurBjRuneID( id )
	if  id and tonumber(id)>0 then
		self.curBjRuneID = tonumber(id)
	end
end

function RuneSystemModel:getCurBjRuneID(  )
	return self.curBjRuneID 
end

function RuneSystemModel:check_RunePageOpen( id )
	for k,v in pairs(self.allRunePages) do
		if v.id == id then
			return true,v
		end
	end
	return false,nil
end

function  RuneSystemModel:getRuleAllLevel( id )
	local allLevel = 0
	local data = {}
	for k,v in pairs(self.allRunePages) do
		if v.id == id then
			data = v
			break
		end
	end
	if data.blue and #data.blue>0 then
       for i,v in ipairs(data.blue) do
           allLevel = allLevel + RuneConfiger.getRuneLevel( v.itemCode )
       end
	end

	if data.green and #data.green>0 then
       for i,v in ipairs(data.green) do
           allLevel = allLevel + RuneConfiger.getRuneLevel( v.itemCode )
       end
	end

	if data.red and #data.red>0 then
       for i,v in ipairs(data.red) do
           allLevel = allLevel + RuneConfiger.getRuneLevel( v.itemCode )
       end
	end
	
	if data.black and #data.black>0 then
       for i,v in ipairs(data.black) do
           allLevel = allLevel + RuneConfiger.getRuneLevel( v.itemCode )
       end
	end
    return allLevel
end

function RuneSystemModel:checkHadRunes( id)
	local data = {}
	for k,v in pairs(self.allRunePages) do
		if v.id == id then
			data = v
			break
		end
	end

	if data.blue and #data.blue>0 then
       for i,v in ipairs(data.blue) do
           if v.itemCode~=0 then
           	  return true
           end
       end
	end

	if data.green and #data.green>0 then
       for i,v in ipairs(data.green) do
           if v.itemCode~=0 then
           	  return true
           end
       end
	end

	if data.red and #data.red>0 then
       for i,v in ipairs(data.red) do
           if v.itemCode~=0 then
           	  return true
           end
       end
	end
	
	if data.black and #data.black>0 then
       for i,v in ipairs(data.black) do
           if v.itemCode~=0 then
           	  return true
           end
       end
	end

	return false
end

function RuneSystemModel:getRunesMaxLevelAndId( ... )
	local level = 0 
	local id = 0
    for k,v in pairs(self.allRunePages) do
        if level<self:getRuleAllLevel(v.id) then
        	id = v.id
        end
		level = math.max(level,self:getRuleAllLevel(v.id)) 
	end
	return level,id
end

function RuneSystemModel:getcurPageSkills(id)
    for k,v in pairs(self.allRunePages) do
		if v.id == id then
			return v.skills
		end
	end
end

--获得符文总属性
function RuneSystemModel:getRuleAllPros(id)
	local prosArr = {}
    
	local function checkProArr( proTab )
		for k,v in pairs(prosArr) do
			if v.id == proTab.id then
				v.value = v.value+ proTab.value
				return true
			end
		end
		table.insert(prosArr,proTab)
		return false
	end

	local data = {}
	for k,v in pairs(self.allRunePages) do
		if v.id == id then
			data = v
			break
		end
	end
    if data.blue and #data.blue>0 then
       for i,v in ipairs(data.blue) do
           if v.attr and #v.attr>0 then
           	  for i2,v2 in ipairs(v.attr) do
           	  	 checkProArr(TableUtil.DeepCopy(v2))
           	  end
           end
       end
	end

	if data.green and #data.green>0 then
       for i,v in ipairs(data.green) do
           if v.attr and #v.attr>0 then
           	  for i2,v2 in ipairs(v.attr) do
           	  	 checkProArr(TableUtil.DeepCopy(v2))
           	  end
           end
       end
	end

	if data.red and #data.red>0 then
       for i,v in ipairs(data.red) do
           if v.attr and #v.attr>0 then
           	  for i2,v2 in ipairs(v.attr) do
           	  	 checkProArr(TableUtil.DeepCopy(v2))
           	  end
           end
       end
	end

	if data.black and #data.black>0 then
       for i,v in ipairs(data.black) do
           if v.attr and #v.attr>0 then
           	  for i2,v2 in ipairs(v.attr) do
           	  	 checkProArr(TableUtil.DeepCopy(v2))
           	  end
           end
       end
	end

	return prosArr
end

function RuneSystemModel:init()

end

function RuneSystemModel:setAllRunePages(data)
	self.allRunePages = data
	-- printTable(1,"服务器符文数据到达",self.allRunePages)
	self:checkRuneRedDot()
	Dispatcher.dispatchEvent(EventType.update_RuneServerData) --更新显示层
end

function RuneSystemModel:getAllRunePages(  )
	return self.allRunePages
end

function RuneSystemModel:getRunePagesById( id )
	for k,v in pairs(self.allRunePages) do
		if v.id == id then
			return v
		end
	end
	return nil
end

--获取当前的符文英雄
function RuneSystemModel:getCurRuneEquipHero(  )
	local data = self:getRunePagesById(self.curBjRuneID)
	if data and data.equipHero then
		return data.equipHero
	else
		 if not data then
		 	return nil
		 elseif not data.equipHero then
		 	data.equipHero = {} --服务器让做兼容
		 end
		 return data.equipHero
	end
end

function RuneSystemModel:checkHeroHadEquip( uuid)
	local allRuneData = self:getAllRunePages()
	for k,v in pairs(allRuneData) do
		if v and v.equipHero then
			local key = false
			for ek,ev in pairs(v.equipHero) do
				if ev.uuid == uuid then --英雄存在
	                return v.name
				end
			end
		end
	end
	return nil
end

--接收英雄被删除
function RuneSystemModel:cardDeleteEvent(uuid)
	local allRuneData = self:getAllRunePages()
	for k,v in pairs(allRuneData) do
		if v and v.equipHero then
			local key = false
			for ek,ev in pairs(v.equipHero) do
				if ev.uuid == uuid then --英雄存在
	                ev.uuid=""
				end
			end
		end
	end
	self:checkRuneRedDot()
end

function RuneSystemModel:setCurRuneEquipHero( equipData )
	-- printTable(1,"setCurRuneEquipHero 设置数据",equipData)
	local data = self:getRunePagesById(self.curBjRuneID)
	if data and data.equipHero then
		printTable(1,data.equipHero)
		-- if equipData.id ~= self.curBjRuneID then
		-- 	RollTips.show("符文页数据不对应 出错")
		-- 	return
		-- end
		local key = false
		for k,v in pairs(data.equipHero) do
			if v.pos == equipData.pos then
				--位置已经存在数据
                key = k
			end
		end
		if key then
           data.equipHero[key] = equipData
		else
			table.insert(data.equipHero,equipData)
		end
	end
	self:checkRuneRedDot()
end

function RuneSystemModel:getEquipHeroByPos( pos )
	local data = self:getRunePagesById(self.curBjRuneID)
	if data and data.equipHero then
		for k,v in pairs(data.equipHero) do
			if v.pos == pos then
				return v
			end
		end
	end
	return nil

end



--自动寻找下一个可以装配的符文格子
function RuneSystemModel:checkNextCanEquip( ... )
	local curRuneData = self:getCurSelectRuneData()
	local colorArr = {1,2,3,4} 
	if curRuneData then
		--存在 先寻找当前颜色下一个格子
		local color = curRuneData.type
		local pageData = self:getRunePagesById(curRuneData.id)
		local data = {}
        if color == 1 then
			data = pageData.blue
		elseif color == 2 then
			data = pageData.red
		elseif color == 3 then
			data = pageData.green
		elseif color == 4 then
			data = pageData.black
		end
		table.remove(colorArr,color)
		--data这里必然存在 至少有当前格子
    	for i,v in ipairs(data) do
    		if v.itemCode == 0 then
    			return color,v.id
    		end
    	end
        
        color = colorArr[1]
        if color == 1 then
			data = pageData.blue
		elseif color == 2 then
			data = pageData.red
		elseif color == 3 then
			data = pageData.green
		elseif color == 4 then
			data = pageData.black
		end
        for i,v in ipairs(colorArr) do
			if v == color then
				table.remove(colorArr,i)
			end
		end
		if data and #data>0 then
			for i,v in ipairs(data) do
	    		if v.itemCode == 0 then
	    			return color,v.id
	    		end
	    	end
		end
        
        --不分出方法了 执行了一次没太大必要 直接复制
		color = colorArr[1]
        if color == 1 then
			data = pageData.blue
		elseif color == 2 then
			data = pageData.red
		elseif color == 3 then
			data = pageData.green
		end
		for i,v in ipairs(colorArr) do
			if v == color then
				table.remove(colorArr,i)
			end
		end
		
		if data and #data>0 then
			for i,v in ipairs(data) do
	    		if v.itemCode == 0 then
	    			return color,v.id
	    		end
	    	end
		end
		return nil,nil
	end
end



function RuneSystemModel:insertDataToRunePages( data,index )
	-- table.insert(self.allRunePages,index,data)
	self.allRunePages[index] = data
	Dispatcher.dispatchEvent(EventType.update_RuneServerData) --更新显示层
end

--前端维护符文页整个数据块
function RuneSystemModel:updateDataToRunePages( data )
	for k,v in pairs(self.allRunePages) do
		if v.id == data.id then
			 self.allRunePages[k] = data
			 self:checkRuneRedDot()
			 Dispatcher.dispatchEvent(EventType.update_RuneServerData) --更新显示层
			break
		end
	end
end


--前端维护符文数据 skills name 
function RuneSystemModel:setRuneArrDataName( id,arrName,arrVal )
	if (not id) or (not arrName) or (not arrVal) then
		print(1,"设置数值不对 不能修改数据")
		return 
	end
	for k,v in pairs(self.allRunePages) do
		if v.id == id then
			if self.allRunePages[id] then
				if self.allRunePages[id][arrName] then
					self.allRunePages[id][arrName] = arrVal
					self:checkRuneRedDot()
				end 
			end
			break
		end
	end
end

--前端维护符文位置数据 
function RuneSystemModel:setRunePageRuneColor(id,type,index,runeColor)
	if (not id) or (not type) or (not type) or (not runeColor) then
		print(1,"设置数值不对 不能修改数据")
		return 
	end
	for k,v in pairs(self.allRunePages) do
		if v.id == id then
			if type == 1 then
				table.insert(v.blue,runeColor)
			elseif type == 2 then
				table.insert(v.red,runeColor)
			elseif type == 3 then
				table.insert(v.green,runeColor)
			elseif type == 4 then
				table.insert(v.black,runeColor)
			end
			self:checkRuneRedDot()
			Dispatcher.dispatchEvent(EventType.update_RuneServerData) --更新显示层
			break
		end
	end
end

--
function RuneSystemModel:updateRunePageRuneColor( id,type,index,runeColor )
	print(1,"updateRunePageRuneColor")
	if (not id) or (not type) or (not type) or (not runeColor) then
		print(1,"设置数值不对 不能修改数据")
		return 
	end
	for k,v in pairs(self.allRunePages) do
		if v.id == id then
			if type == 1 then
                for k1,v1 in pairs(v.blue) do
                	if v1.id == index then
                		self.allRunePages[k].blue[k1] = TableUtil.Clone(runeColor)
                		break
                	end
                end
			elseif type == 2 then
				for k1,v1 in pairs(v.red) do
                	if v1.id == index then
                		self.allRunePages[k].red[k1] = TableUtil.Clone(runeColor)
                		break
                	end
                end
			elseif type == 3 then
				for k1,v1 in pairs(v.green) do
                	if v1.id == index then
                		self.allRunePages[k].green[k1] = TableUtil.Clone(runeColor)
                		break
                	end
                end
			elseif type == 4 then
				for k1,v1 in pairs(v.black) do
                	if v1.id == index then
                		self.allRunePages[k].black[k1] = TableUtil.Clone(runeColor)
                		break
                	end
                end
			end
			Dispatcher.dispatchEvent(EventType.rune_changeSmallPage,{status=1,page=type})
			Dispatcher.dispatchEvent(EventType.update_RuneServerData)
			-- Dispatcher.dispatchEvent(EventType.update_smallPage)
			break
		end
	end
	self:checkRuneRedDot()
	
end

--检测合成中 给占用掉的道具
function RuneSystemModel:checkCompoundData(  )
	for k,v in pairs(self.runeCompDataArr) do
		local uuid = v:getUuid()
		local code = v:getItemCode()
		local temp = ModelManager.PackModel:getRuneBag():getItemByUuid( code,uuid )
		if not temp then
			self.runeCompDataArr[k] = nil
		end
	end
end

function RuneSystemModel:getComposeByID( itemID )
	if DynamicConfigData.t_Rune[itemID] then
		if DynamicConfigData.t_Rune[itemID].compose1  then
			return DynamicConfigData.t_Rune[itemID].compose1
		end
	end
	print(1,"策划配置有问题")
	return nil
end

--获取符文背包数据
function RuneSystemModel:getRunePackByType( color,pageIndex)
	local data = ModelManager.PackModel:getRuneBag():sort_bagDatas()
	if color == 0 then --全部
		if pageIndex == 3 then --重置的全部栏目
			--去除综合符文
			local tempData = {}
			tempData = TableUtil.deepcopyForkeyValue(data,tempData)
			for i = #tempData, 1,-1 do
				if RuneConfiger.getRuneColor(tempData[i]:getItemCode()) == 4 then
					table.remove( tempData,i)
				end
			end
			data = tempData
			table.sort( data, function(a,b)
				local runeAttrs1 = a:getItemSPecialData().rune.attrs
				local runeAttrs2 = b:getItemSPecialData().rune.attrs
				local level_1 = RuneConfiger.getRuneLevel( a:getItemCode())
				local level_2 = RuneConfiger.getRuneLevel( b:getItemCode())
				if level_1 == level_2 then
					local color_1 = RuneConfiger.getRuneColor( a:getItemCode() )
					local color_2 = RuneConfiger.getRuneColor( b:getItemCode() )
					if color_1 == 4 then color_1 = 0 end
					if color_2 == 4 then color_2 = 0 end
					if color_1 == color_2 then
						for i = 1, #runeAttrs1 do
							if runeAttrs1[i].id==runeAttrs2[i].id then
								if i+1<= #runeAttrs1 then
									return runeAttrs1[i+1].id>runeAttrs2[i+1].id
								else
									return false
								end
							else
								return runeAttrs1[1].id>runeAttrs2[1].id
							end
						end
					else
						return color_1< color_2
					end
				else
					return level_1>level_2
				end
			end )
			return data
		elseif pageIndex == 2 then --合成的栏目
				-- 1、优先排序高级符文，3级>2级>1级
				-- 2、同等级下，然后按照类型，防御符文>攻击符文>辅助符文
				-- 3、同等级同类型下，按照属性条目排序，多个条目的，从第一条开始对比排序，依次对比排完，和符文重置界面的排序逻辑一致。
				table.sort( data, function(a,b)
					local level1 = RuneConfiger.getRuneLevel( a:getItemCode())
					local level2 = RuneConfiger.getRuneLevel( b:getItemCode())
					if level1 == level2 then
						local color_1 = RuneConfiger.getRuneColor( a:getItemCode() )
						local color_2 = RuneConfiger.getRuneColor( b:getItemCode() )
						if color_1 == 4 then color_1 = 0 end
						if color_2 == 4 then color_2 = 0 end
						if color_1 == color_2 then
							local itemID1 = a:getItemCode()
							local itemID2 = b:getItemCode()
							if itemID1 == itemID2 then
								local runeAttrs1 = a:getItemSPecialData().rune.attrs
								local runeAttrs2 = b:getItemSPecialData().rune.attrs
								for i = 1, #runeAttrs1 do
									if runeAttrs2[i] and runeAttrs1[i].id==runeAttrs2[i].id then
										if i+1<= #runeAttrs1 then
											return runeAttrs1[i+1].id<runeAttrs2[i+1].id
										else
											return false
										end
									else
										return runeAttrs2[i] and runeAttrs1[1].id<runeAttrs2[1].id or false
									end
								end
							else
								return itemID1<itemID2
							end
						else
							return color_1< color_2
						end
					else
						return level1>level2
					end
				end )
				return data
		else
			return data
		end
	end

	local rData = {}
	for k,v in pairs(data) do
		local color_t = RuneConfiger.getRuneColor( v:getItemCode() )
		if color_t == color then
			table.insert(rData,v)
		end
	end

	if pageIndex ==2 or  pageIndex ==0 then --符文合成页面
		-- 1、优先排序高级符文，3级>2级>1级
		-- 2、同等级下，然后按照类型，防御符文>攻击符文>辅助符文
		-- 3、同等级同类型下，按照属性条目排序，多个条目的，从第一条开始对比排序，依次对比排完，和符文重置界面的排序逻辑一致。
		table.sort( rData, function(a,b)
			local level1 = RuneConfiger.getRuneLevel( a:getItemCode())
			local level2 = RuneConfiger.getRuneLevel( b:getItemCode())
			if level1 == level2 then
				local color_1 = RuneConfiger.getRuneColor( a:getItemCode() )
				local color_2 = RuneConfiger.getRuneColor( b:getItemCode() )
				if color_1 == color_2 then
					local itemID1 = a:getItemCode()
					local itemID2 = b:getItemCode()
					if itemID1 == itemID2 then
						local runeAttrs1 = a:getItemSPecialData().rune.attrs
						local runeAttrs2 = b:getItemSPecialData().rune.attrs
						for i = 1, #runeAttrs1 do
							if runeAttrs1[i].id==runeAttrs2[i].id then
								if i+1<= #runeAttrs1 then
									return runeAttrs1[i+1].id<runeAttrs2[i+1].id
								else
									return false
								end
							else
								return runeAttrs1[1].id<runeAttrs2[1].id
							end
						end
					else
						return itemID1<itemID2
					end
				else
					return color_1< color_2
				end
			else
				return level1>level2
			end
		end )
	elseif pageIndex ==3 then --重置页
		table.sort( rData, function(a,b)
			local runeAttrs1 = a:getItemSPecialData().rune.attrs
			local runeAttrs2 = b:getItemSPecialData().rune.attrs
			local level_1 = RuneConfiger.getRuneLevel( a:getItemCode())
			local level_2 = RuneConfiger.getRuneLevel( b:getItemCode())
			if level_1 == level_2 then
				for i = 1, #runeAttrs1 do
					if runeAttrs1[i].id==runeAttrs2[i].id then
						if i+1<= #runeAttrs1 then
							return runeAttrs1[i+1].id<runeAttrs2[i+1].id
						else
							return false
						end
					else
						return runeAttrs1[1].id<runeAttrs2[1].id
					end
				end
			else
				return level_1>level_2
			end
		end )
		return rData
	else
		table.sort( rData, function(a,b)
		    return RuneConfiger.getRuneLevel( a:getItemCode())>RuneConfiger.getRuneLevel( b:getItemCode())
	    end )
	end
	
	return rData
end

return RuneSystemModel
