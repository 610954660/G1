--Name : LoginAwardModel.lua
--Author : generated by FairyGUI
--Date : 2020-4-24
--Desc : 


local LoginAwardModel = class("LoginAwardModel", BaseModel)
local growthType = 1
function LoginAwardModel:ctor()
   self.growthData = false
end

function LoginAwardModel:init()

end

function LoginAwardModel:loginPlayerDataFinish(  )
	local flag = ModuleUtil.hasModuleOpen(ModuleId.DailySign.id)
	if not flag then
		return
	end
	--为了红点 初始化时主动请求
	local params = {}
    params.onSuccess = function (res )
      -- printTable(1,"每日数据",res)
      local data = res.data
      --每天
      for k,v in pairs(data.recvList) do
      	 if v.recvState == 1 then 
      	 	RedManager.updateValue("V_SIGN",true)
      	 	break
      	 end
      	 if table.maxn(data.recvList) == v.dayIndex then --当天
      	 	--再次充值
		      if data.recharge and v.recvState==2  then --再次领取 但未充值
		      	RedManager.updateValue("V_SIGN",true)
		      end
      	 end
      end
      --累积
      local count = 0
	  if data and data.recvList then
	  	for k,v in pairs(data.recvList) do
	    	if v.recvState == 2 or v.recvState == 3 then
	    		count = count +1
	    	end
	    end
	  end
	  local Awardconfig2 = DynamicConfigData.t_DailyLoginCReward[data.recvType]
      for k,v in pairs(Awardconfig2) do
      	  if count>=v.count and data.countRecvMap and not data.countRecvMap[k]  then
              RedManager.updateValue("V_SIGN",true)
              break
      	  end
      end
    end
    RPCReq.Welfare_DailyLogin_InfoReq(params, params.onSuccess)
end


function LoginAwardModel:makeWindowTab(  )
	local data = {}
	

	local temp =  {
		page = "DailySignView",
		btData = {
			title = Desc.LoginAward_Text1,
			icon = "ui://kl096bohtipj36",
			icondown = "ui://kl096bohtipj37",
		},
		red = "V_SIGN", --红点名称
		bg = "loginaward_sign_bg.jpg",
		mid = ModuleId.DailySign.id
	}
	table.insert(data,temp)

	if (ModuleUtil.hasModuleOpen(ModuleId.MonthlyCard.id)) then
		local temp =  {
			page = "MonthlyCardView",
			btData = {
				title = Desc.LoginAward_Text2,
				icon = "ui://kl096bohuw6q4e",
				icondown = "ui://kl096bohuw6q4f",
			},
			red = "V_MONTHLYCARD",
			bg = "loginaward_card.jpg",
			mid = ModuleId.MonthlyCard.id
		}

		table.insert(data,temp)
	end
	
	if (not self.growthData) or (not self.growthData.isFinish) then
		local temp =  {
	        page = "GrowthFundView",
	        btData = {
	            title = Desc.LoginAward_Text3,
	            icon = "ui://kl096bohtipj2j",
	            icondown = "ui://kl096bohtipj25",
	        },
	        red = "V_GROWTH", --红点名称
	        bg = "loginaward_czjj.jpg",
	        mid = ModuleId.GrowthFund.id
		}
		table.insert(data,temp)
	end 
  
	if not AgentConfiger.isAudit() then
		local temp =  {
			page = "ActivationCodeView",
			btData = {
				title = Desc.LoginAward_Text4,
				icon = "ui://kl096bohtipj2p",
				icondown = "ui://kl096bohtipj2q",
			},
			bg = "loginaward_code.jpg",
			mid = ModuleId.ActivationCode.id
		}
		table.insert(data,temp)
	end
	local openList={}
	for i = 1, #data, 1 do
		local configInfo=data[i]
		if configInfo.mid==ModuleId.DailySign.id or configInfo.mid==ModuleId.MonthlyCard.id then
            local tips=ModuleUtil.moduleOpen(configInfo.mid,false)
            if tips==true then--前端开启了该功能
                table.insert( openList, configInfo)
			end
        else
            table.insert( openList, configInfo)
        end
	end
    return openList
end

function LoginAwardModel:setGrowthData( data )
   self.growthData = data[growthType]
   self:check_redDot()
   Dispatcher.dispatchEvent("update_Growth")
end

--检测红点
function LoginAwardModel:check_redDot( ... )
	local isShow = false
	if self.growthData.isBuy then
	   for i,v in ipairs(self.growthData.state) do
	   	  print(1,i,v)
	   	  if v == 3 or v == 2 then
	   	  	 isShow = true
	   	  	 break
	   	  end
	   end
	end
	RedManager.updateValue("V_GROWTH",isShow)
end

function LoginAwardModel:getGrowthData( )
    return self.growthData
end

--获取成长基金配置
function LoginAwardModel:getGrowthConfig( type )
	return DynamicConfigData.t_GrowCoinConfig[type]
end

function LoginAwardModel:getGrowthMianConfig( type )
	return DynamicConfigData.t_GrowCoinMianConfig[type]
end

return LoginAwardModel