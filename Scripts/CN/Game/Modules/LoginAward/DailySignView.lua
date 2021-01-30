--Name : DailySignView.lua
--Author : generated by FairyGUI
--Date : 2020-4-24
--Desc : --每日签到 add by xiehande

local DailySignView,Super = class("DailySignView", View)
local ItemCell = require "Game.UI.Global.ItemCell"
function DailySignView:ctor()
	--LuaLog("DailySignView ctor")
	self._packName = "LoginAward"
	self._compName = "DailySignView"
	--self._rootDepth = LayerDepth.Window
	self.data = {}
  self.Awardconfig = false
  self.Awardconfig2 = false
  self.count = 0
end

function DailySignView:_initEvent( )
  self.list1:setItemRenderer(function(index,obj)
        local itemcellObj = obj:getChildAutoType("itemCell")
        local itemcell = BindManager.bindItemCell(itemcellObj)
        local itemData = ItemsUtil.createItemData({data =self.Awardconfig[index+1].rewardList[1]})
        itemcell:setItemData(itemData)
          local statusTxt = obj:getChildAutoType("statusTxt")
          if index+1<10 then
            statusTxt:setText(string.format(Desc.login_txt2,index+1))
          else
            statusTxt:setText(string.format(Desc.login_txt1,index+1))
          end
          
          itemcellObj:removeClickListener(100)
          itemcellObj:addClickListener(function( ... )
            itemcell:onClickCell()
          end,100)
          local statusCtrl = obj:getController("statusCtrl")
          local getBtn = obj:getChildAutoType("getBtn")

          if self.data.recvList[index+1] then
            local sdata = self.data.recvList[index+1]
            if sdata.dayIndex == index+1 then 
              if sdata.recvState == 1 then --可領取
                statusCtrl:setSelectedIndex(1)
                itemcellObj:setTouchable(false)
                getBtn:setTouchable(true)
              elseif sdata.recvState == 3 then --完全领取
                statusCtrl:setSelectedIndex(2)
                itemcellObj:setTouchable(true)
                getBtn:setTouchable(false)
              else  --再次领取
                if table.maxn(self.data.recvList) == sdata.dayIndex then --当天
                    if not self.data.recharge and self.data.recvList[index+1].recvState==2  then --再次领取 但未充值
                        statusCtrl:setSelectedIndex(3) 
                    else
                      statusCtrl:setSelectedIndex(4)
                    end
                    itemcellObj:setTouchable(false)
                    getBtn:setTouchable(true)
                else
                    statusCtrl:setSelectedIndex(2)
                    itemcellObj:setTouchable(true)
                    getBtn:setTouchable(false)
                end
              end
            end
          else
            getBtn:setTouchable(false)
            statusCtrl:setSelectedIndex(0)
          end

          getBtn:removeClickListener(100)
          getBtn:addClickListener(function( ... )
            print(1,"被点击")
            --没有充值 并且领过一次
            if not self.data.recharge and self.data.recvList[index+1].recvState==2  then
               local info = {}
                info.text = Desc.DailySign_Text1
                info.type = "yes_no"
                info.mask = true
                info.yesText = Desc.DailySign_Text2
                info.onYes = function()
                   ModuleUtil.openModule(ModuleId.DailyGiftBag.id)
                end
                Alert.show(info)
                    return
            end
            local params = {}
            params.dayIndex = index+1
            params.onSuccess = function (res )
              -- printTable(1,res)
              self.data = res.data
  			      if tolua.isnull(self.view) then return end
              self:update_DailySignPanel()
            end
            RPCReq.Welfare_DailyLogin_RewardReq(params, params.onSuccess)
          end,100)

  end)
  self.list1:setVirtual()

  self.list2:setItemRenderer(function(index,obj)
        local itemcellObj = obj:getChildAutoType("itemCell")
        local itemcell = BindManager.bindItemCell(itemcellObj)
        local itemData = ItemsUtil.createItemData({data =self.Awardconfig2[index+1].rewardList[1]})
        itemcell:setItemData(itemData)
          local dayNum = obj:getChildAutoType("dayNum")
          dayNum:setText(self.Awardconfig2[index+1].count)
          itemcellObj:removeClickListener(100)
          itemcellObj:addClickListener(function( ... )
            itemcell:onClickCell()
          end,100)
          local statusCtrl = obj:getController("statusCtrl")
          local getBtn = obj:getChildAutoType("getBtn")
          if self.data.countRecvMap and #self.data.countRecvMap>0 then
              local sdata = self.data.countRecvMap[index+1]
              if sdata and sdata.recvState then
                statusCtrl:setSelectedIndex(2)
                getBtn:setTouchable(false)
              else
                if self.count>= self.Awardconfig2[index+1].count then
                  statusCtrl:setSelectedIndex(1)
                  getBtn:setTouchable(true)
                end
              end
          else
          if self.count>= self.Awardconfig2[index+1].count then
              statusCtrl:setSelectedIndex(1)
              getBtn:setTouchable(true)
            else
              getBtn:setTouchable(false)
                statusCtrl:setSelectedIndex(0)
            end
          end
          getBtn:removeClickListener(100)
          getBtn:addClickListener(function( ... )
            local params = {}
            params.index = index + 1
        params.onSuccess = function (res )
           self.data = res.data
			     if tolua.isnull(self.view) then return end
           self:update_DailySignPanel()
        end
        RPCReq.Welfare_DailyLogin_RewardCountReq(params, params.onSuccess)
          end,100)

  end)
  self.list2:setVirtual()

	local params = {}
	params.onSuccess = function (res )
	   -- printTable(1,res)
	   self.data = res.data
		if tolua.isnull(self.view) then return end
	   self:update_DailySignPanel()
	end
	RPCReq.Welfare_DailyLogin_InfoReq(params, params.onSuccess)
end

function DailySignView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:LoginAward.DailySignView
		vmRoot.list2 = viewNode:getChildAutoType("$list2")--list
		vmRoot.weekVal = viewNode:getChildAutoType("$weekVal")--text
		vmRoot.btn_help = viewNode:getChildAutoType("$btn_help")--Button
		vmRoot.txt2 = viewNode:getChildAutoType("$txt2")--text
		vmRoot.daycount = viewNode:getChildAutoType("$daycount")--text
		vmRoot.list1 = viewNode:getChildAutoType("$list1")--list
		vmRoot.txt1 = viewNode:getChildAutoType("$txt1")--text
		vmRoot.dayVal = viewNode:getChildAutoType("$dayVal")--text
	--{vmFieldsEnd}:LoginAward.DailySignView
	--Do not modify above code-------------
end

function DailySignView:_initUI()
	self:_initVM()
	self.btn_help:addClickListener(function()
		RollTips.showHelp(Desc.help_dailySignTitle, Desc.help_dailySign)
	end)
end

function DailySignView:loginSign_updateEvent( _,params)
	self.data = params.data
	--printTable(1,self.data)
	self:update_DailySignPanel()
end

function DailySignView:update_DailySignPanel(  )
   --更新红点
   RedManager.updateValue("V_SIGN",false)
   for k,v in pairs(self.data.recvList) do
       if v.recvState == 1 then 
        RedManager.updateValue("V_SIGN",true)
        break
       end
       if table.maxn(self.data.recvList) == v.dayIndex then --当天
          --再次充值
          if self.data.recharge and v.recvState==2  then --再次领取 但未充值
            RedManager.updateValue("V_SIGN",true)
          end
       end
   end

    local count = 0
    if self.data and self.data.recvList then
      for k,v in pairs(self.data.recvList) do
        if v.recvState == 2 or v.recvState == 3 then
          count = count +1
        end
      end
    end
    local Awardconfig2 = DynamicConfigData.t_DailyLoginCReward[self.data.recvType]
    for k,v in pairs(Awardconfig2) do
        if count>=v.count and self.data.countRecvMap and not self.data.countRecvMap[k]  then
            RedManager.updateValue("V_SIGN",true)
            break
        end
    end

	--更新日期显示
	local monCtrl = self.view:getController("monCtrl")
	local month = TimeLib.getMonth()
	if monCtrl then
		monCtrl:setSelectedIndex(month-1)
	end
	self.dayVal:setText(TimeLib.getDay())
	self.weekVal:setText(TimeLib.getCurWeekDayShow())
    
  --更新星座     --更新事宜
  if self.data and self.data.zodiacId then
  	 local str = DynamicConfigData.t_DailyLoginZDC[self.data.zodiacId].zodiac
  	 self.txt1:setText(str or "")
  	 str = DynamicConfigData.t_DailyLoginLE[self.data.luckEventId].name
  	 self.txt2:setText(str or "")
  end
  self.count = 0
  if self.data and self.data.recvList then
  	for k,v in pairs(self.data.recvList) do
    	if v.recvState == 2 or v.recvState == 3 then
    		self.count = self.count +1
    	end
    end
  end
   

    --更新累积天数
  self.daycount:setText(self.count)
  local daysNum = TimeLib.getThisMoneyAllDay(  )
  self.Awardconfig = DynamicConfigData.t_DailyLoginReward[self.data.recvType]
	self.list1:setNumItems(daysNum)
   
   --更新累积签到列表
  self.Awardconfig2 = DynamicConfigData.t_DailyLoginCReward[self.data.recvType]
	self.list2:setNumItems(#self.Awardconfig2)

end


return DailySignView