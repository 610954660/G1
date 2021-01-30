---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: 
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local FGUIUtil = require "Game.Utils.FGUIUtil"
local CardTestView,Super = class("CardTestView", Window)
local DataCheckUtil = require "Game.Utils.DataCheckUtil"
function CardTestView:ctor()
    self._packName = "Test"
	self._compName = "p_test"
	self.CardConItem=false--卡牌阶级图片显示
	self._updateTimeId = false
	self.showCtrl = false
	self.packViewArr = false
	
	self._oneKeyAction = {
			{ type = 1, params = {2,1,99999999999}},
			{ type = 1, params = {2,2,99999999999}},
			{ type = 3, params = {200}},
			{ type = 1, params = {3,10000023,1000}},
			{ type = 1, params = {3,10000024,1000}},
			{ type = 1, params = {3,10000006,100000000}},
			{ type = 1, params = {3,10000007,1000000}},
			{ type = 2, params = {1,2,1,1,1}},
			{ type = 1, params = {4,15001,10,200}},
			{ type = 1, params = {4,15002,1,200}},
			{ type = 1, params = {4,15003,1,200}},
			{ type = 1, params = {4,15004,1,200}},
			{ type = 1, params = {4,15005,1,200}},
			{ type = 1, params = {4,15006,1,200}},
			
			
		}

	self._addHeroAction = {
			{ type = 1, params = {4,15001,6,200}},
			{ type = 1, params = {4,15003,50,1}},
			{ type = 1, params = {4,15004,50,1}},
			{ type = 1, params = {4,15005,50,1}},
			{ type = 1, params = {4,15006,50,1}},
			{ type = 1, params = {4,15006,50,1}},
			
			
			
		}
	self._clientBtnInfo = {
		{name="一键备号", action="oneKey"},
		{name="加英雄", action="addHero"},
		{name="内存镜像", action="mirror"},
		{name="强制回收", action="recycle"},
		{name="查看增量", action="showAdd"},
		{name="打印红点数据", action="printRed"},
		{name="包体引用", action="packRef"},
		{name="显示立绘框", action="lihuiDebugMode"},
	}
end    

function CardTestView:_initUI()
	local errInfo =GameDef.TestTypeDict;
	printTable(5,"卡牌阶级请求返回yfyf",errInfo)
	if not errInfo then		
		return
	end
	local viewRoot = self.view
	 local listBtn=viewRoot:getChild("list_btn");
	listBtn:setVirtual()

	self.showCtrl = self.view:getController("showCtrl")
	self.winCount = self.view:getChildAutoType("winCount")
	self.packList = self.view:getChildAutoType("packList")
	
	 self.CardConItem=viewRoot:getChild("com_title");
	self.btn_search =  self.CardConItem:getChildAutoType("btn_search")
	self.txt_search =  self.CardConItem:getChildAutoType("txt_search")
	 listBtn:setItemRenderer(function(index,obj)
				obj:removeClickListener()--池子里面原来的事件注销掉
				obj:addClickListener(function(context)
					self.showCtrl:setSelectedIndex(0)
					self:showComItem(errInfo[index+1],index+1);
				end)
				local value=errInfo[index+1];
				local title=obj:getChild('title')
				title:setText(value.desc) ;
				if index==0 then
					self:showComItem(value,index+1);
				end
			end
		)
	local len = #errInfo
	listBtn:setNumItems(len);
	
	 local listBtn2=viewRoot:getChild("list_btn2");
	listBtn2:setVirtual()
	 listBtn2:setItemRenderer(function(index,obj)
				local value=self._clientBtnInfo[index+1];
				obj:removeClickListener()--池子里面原来的事件注销掉
				obj:addClickListener(function(context)
					self:clientHandler(value.action);
				end)
				
				local title=obj:getChild('title')
				title:setText(value.name) ;
			end
		)
	listBtn2:setNumItems(#self._clientBtnInfo);

	self.packList:setVirtual()
	self.packList:setItemRenderer(function( index,obj )
		local packName = obj:getChildAutoType("packName")
		local packNum = obj:getChildAutoType("packNum")
		packName:setText(self.packViewArr[index+1].pname)
		packNum:setText(self.packViewArr[index+1].count)
	end)
	
	
	local txt_openDate = self.view:getChildAutoType("txt_openDate")
	local time = ServerTimeModel:getOpenDateTime()
	local timerStr = StringUtil.formatTime(time, "y")
	txt_openDate:setText("开服时间："..timerStr)
	
	self.btn_search:addClickListener(function()  
		local searhTest =  self.txt_search:getText()
		if searhTest ~= "" then
			
			local allBtn = listBtn:getChildren()
			for _,v in pairs(allBtn) do
				local titleStr = v:getChild('title'):getText()
				if string.find(titleStr, searhTest) then
					v:getChildAutoType("img_red"):setVisible(true)
				else
					v:getChildAutoType("img_red"):setVisible(false)
				end
			end
		end
	end)
		
		
	
	local txt_serverTime = self.view:getChildAutoType("txt_serverTime")
	
	local num = 1
	local updateServerTime = function ()
		local time = ServerTimeModel:getServerTime()
		local timerStr = StringUtil.formatTime(time, "y")
		txt_serverTime:setText("服务器时间："..timerStr)
	end
	
	self._updateTimeId  = Scheduler.schedule(function()
		updateServerTime()
	end,1)
	updateServerTime()
end



function CardTestView:showComItem(data,typeCode)
	if typeCode == 16 then
		DataCheckUtil.checkData()
		return 
	end
	printTable(5,"卡牌阶级请求返回yfyf",data)
	local txtDesc= self.CardConItem:getChild('txt_desc');
	txtDesc:setText(data.text);
	local txtName= self.CardConItem:getChild('txtName');
	txtName:setText(data.desc);
	for i = 1, 4, 1 do
		local parmeInfo= data['parme'..i];
		local txt1= self.CardConItem:getChild('txt_str'..i);
		local txt2=self.CardConItem:getChild('txt_value'..i);
		if parmeInfo.name then
			txt1:setText(parmeInfo.name);
		else
			txt1:setText('');
		end
		if parmeInfo.value then
			txt2:setText(parmeInfo.value);
		else
			txt2:setText(0);
		end
	end
	local btnSend= self.CardConItem:getChildAutoType("btn_send");
	btnSend:removeClickListener();
	btnSend:addClickListener(function ( ... )
		local temp={};
		for i = 1, 4, 1 do
			local txt2=self.CardConItem:getChild('txt_value'..i);
			local textInfo=txt2:getText();
			temp[i]=textInfo;
		end
		temp['type']=typeCode;
		printTable(5,"卡牌升级请求返回",temp)
		local info ={
			value1=1
		}
		--RPCReq.Test_BroadcastMsg(info)
       	ModelManager.CardLibModel:sendProtocol(temp)
    end)
end


function CardTestView:clientHandler(action)
	if action == "oneKey" then
		for _,v in pairs(self._oneKeyAction) do
			local temp={};
			temp['type']=v.type;
			temp[1] = v.params[1]
			temp[2] = v.params[2]
			temp[3] = v.params[3]
			temp[4] = v.params[4]
			ModelManager.CardLibModel:sendProtocol(temp)
		end
	elseif action == "addHero" then
		local i = 0
		for _,v in pairs(self._addHeroAction) do
			Scheduler.scheduleOnce(0.5 * i, function()
				local temp={};
				i = i + 1
				temp['type']=v.type;
				temp[1] = v.params[1]
				temp[2] = v.params[2]
				temp[3] = v.params[3]
				temp[4] = v.params[4]
				ModelManager.CardLibModel:sendProtocol(temp)
		end)
		end
	elseif action == "mirror" then
		ModelManager.PlayerModel.menCache  = {}
		local str = cc.Director:getInstance():getTextureCache():getCachedTextureInfo()
		print(1,str)
		local list = string.split(str, "\n")
		for _,v in ipairs(list) do
			local info = string.split(v, "\"")
			if info[2] then
				ModelManager.PlayerModel.menCache[info[2]] = info[3]
				-- print(1, info[2],info[3])
			end
		end
	elseif action == "showAdd" then
		display.removeUnusedSpriteFrames()
		print(__PRINT_TYPE__,"=========texture add ============")
		local str = cc.Director:getInstance():getTextureCache():getCachedTextureInfo()
		local list = string.split(str, "\n")
		for _,v in ipairs(list) do
			local info = string.split(v, "\"")
			if info[2] and not ModelManager.PlayerModel.menCache[info[2]] then
				print(__PRINT_TYPE__, info[2],info[3])
			--else
			--	print(1, "====", info[2],info[3])
			end
		end
		print(__PRINT_TYPE__,"=========texture add end============")
	elseif action == "recycle" then
		display.removeUnusedSpriteFrames()
		--local str = cc.Director:getInstance():getTextureCache():getCachedTextureInfo()
		--print(1, str)
	elseif action == "printRed" then
		RedManager.printDebug()
	elseif action == "lihuiDebugMode" then
		ModelManager.PlayerModel.lihuiDebugMode = true
	elseif action =="packRef" then
		self.showCtrl:setSelectedIndex(1)
		local count = ViewManager.getWindowCount()
		self.packViewArr = ViewManager.getAllPackageCount()
        self.winCount:setText(count)
        self.packList:setData(self.packViewArr)
	end
end



function CardTestView:_enter()

end

function CardTestView:_exit()
	Scheduler.unschedule(self._updateTimeId)
end

return CardTestView