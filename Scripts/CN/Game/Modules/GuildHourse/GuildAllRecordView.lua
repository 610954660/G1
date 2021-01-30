--Date :2020-12-09
--Author : added by xhd
--Desc : 记录

local GuildAllRecordView,Super = class("GuildAllRecordView", Window)

function GuildAllRecordView:ctor()
	--LuaLog("GuildAllRecordView ctor")
	self._packName = "GuildHourse"
	self._compName = "GuildAllRecordView"
	self._rootDepth = LayerDepth.PopWindow
	self.data = self._args.data
	-- print(1,"答應所有")
	-- printTable(1,self.data)
	self.dayData = {}
	self.mapData = {}
end


function GuildAllRecordView:tidyData()
	self.data = TableUtil.sortBy(self.data, "timeMs", false)
	local lastDay = ""
	for i,v in ipairs(self.data) do
		local day = TimeLib.msToString( v.timeMs, "%Y-%m-%d" )
		if day ~= lastDay then
			table.insert(self.dayData,day) 
			lastDay = day
			self.mapData[lastDay] = {}
			table.insert(self.mapData[lastDay],v) 
		else
			table.insert(self.mapData[lastDay],v) 
		end
		
	end
	-- printTable(1,self.mapData)
end

function GuildAllRecordView:_initEvent( )
	
end

function GuildAllRecordView:_initVM( )
	local viewNode = self.view
	---Do not modify following code--------
	--{autoFields}:GuildHourse.GuildAllRecordView
	self.blackbg = viewNode:getChildAutoType('blackbg')--GLabel
	self.frame = viewNode:getChildAutoType('frame')--GLabel
	self.recordList = viewNode:getChildAutoType('recordList')--GList
	--{autoFieldsEnd}:GuildHourse.GuildAllRecordView
	--Do not modify above code-------------
end

function GuildAllRecordView:tidyTextShow( data )
	local str = ""
	str  = data.name or Desc.activity_txt43
	if data.opType == GameDef.GuildPackOpType.playerAdd then
		str  = string.format( "[color=#1988c8]%s[/color]%s",str,Desc.activity_txt44)
	elseif data.opType == GameDef.GuildPackOpType.SysAdd then
		str  = string.format( "[color=#1988c8]%s[/color]%s",str,Desc.activity_txt45)
	elseif data.opType == GameDef.GuildPackOpType.Remove then
		str  = string.format( "[color=#1988c8]%s[/color]%s",str,Desc.activity_txt46)
	elseif data.opType == GameDef.GuildPackOpType.TimeOut then
		str  =  string.format( "[color=#1988c8]%s[/color]%s",str,Desc.activity_txt47)
	end
	local str2 = ""
	for i,v in ipairs(data.items) do
		local color = ItemConfiger.getQualityByCode(data.items[i].code)
		local colorStr = ColorUtil.getItemColorStr(color)
		local itemName = ItemConfiger.getItemNameByCode(data.items[i].code)
		str2 = string.format( "%s[color=%s]%s%s%d%s",str2,colorStr,itemName,"*",data.items[i].amount,"[/color]<br>")
	end
	return str,str2
end

function GuildAllRecordView:_initUI( )
	self:_initVM()
	self:tidyData()
	self.recordList:setVirtual()
    self.recordList:setItemRenderer(function (index,obj)
		local titleTime = obj:getChildAutoType("titleTime")
		titleTime:setText(self.dayData[index+1])
		local dayList = obj:getChildAutoType("dayList")
		local data = self.mapData[self.dayData[index+1]]
		dayList:setItemRenderer(function (index,obj)
			local cellData = data[index+1]
			local timelab = obj:getChildAutoType("timelab")
			timelab:setText(TimeLib.showHMS(cellData.timeMs/1000))
			local namelab = obj:getChildAutoType("namelab")
			local detail = obj:getChildAutoType("detail")
			local txt,txt2 = self:tidyTextShow(cellData)
			namelab:setText(txt)
			detail:setText(txt2)
		end)
		dayList:setNumItems(#data)
		dayList:resizeToFit(#data)
	end)
	self.recordList:setNumItems(#self.dayData)
end




return GuildAllRecordView