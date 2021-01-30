
local BaseModel = require "Game.FMVC.Core.BaseModel"
local RechargeModel = class("RechargeModel", BaseModel)

function RechargeModel:ctor()
	print(33,"RechargeModel ctor")
	self.chargeList = false
	self.lastGetTime = -1
	self.rechargeStat = false
end

function RechargeModel:init()

end

--获取首充金额
function RechargeModel:getFirstChargeMoney()
	return ModelManager.PlayerModel:getStatByType(GameDef.StatType.FirstRmb) or 0
end

--获取当天充值金额
function RechargeModel:getDailyTotalChargeMoney()
	return ModelManager.PlayerModel:getDailyStatByType(GameDef.StatType.ChargeRmb) or 0
end

--获取总充值金额
function RechargeModel:getTotalChargeMoney()
	return ModelManager.PlayerModel:getStatByType(GameDef.StatType.ChargeRmb) or 0
end

function RechargeModel:updateRechargeStat(stat)
	self.rechargeStat = stat or {}
end

function RechargeModel:getRechargeTimes(money)
	return self.rechargeStat[money] and self.rechargeStat[money].times or 0
end

--获取直购透传参数
function RechargeModel:getDirectBuyParam(rechargeType, id,price, name, showName,uid)
	--{"superclass":"9","subclass":"6","name":"特惠礼包","price":"6","showName1":"我是后台名字","uid":"1"}
	local strFormat = '{"superclass":"%s","subclass":"%s","name":"%s","price":"%s","showName1":"%s","uid":"%s"}'
	
	return string.format(strFormat, rechargeType, id, name, price, showName,uid or "")
	--[[if uid then
		return string.format('%s#%s%s#%s',rechargeType, id,uid,showName)
	else
        return string.format('%s#%s#%s',rechargeType, id,showName)
	end--]]
end

function RechargeModel:getChargeData()
	local chargeList = {}
	if self.chargeList then
		for _,v in ipairs(self.chargeList) do
			if v.type == "1" then
				v.money = tonumber(v.money)
				table.insert(chargeList, v)
			end
		end
	end
	return chargeList
end

function RechargeModel:getChargeList(onSuccess)
	if self.lastGetTime == -1 or (cc.millisecondNow() - self.lastGetTime) > 60000 then --一分钟内就不向后台获取了
		self.lastGetTime = cc.millisecondNow()
		local params = {}
		params.onSuccess = function(result)
			if result then
				--调用成功
				self.chargeList = result
				if onSuccess ~= nil then
					onSuccess()
				end
			end
		end
		PHPUtil.getRechargeInfo(params)
	else
		if onSuccess ~= nil then
			onSuccess()
		end
	end
end

--直购
function RechargeModel:directBuy(c_price, rechargeType, giftId, giftName,uid, showName)
	self:checkRealPrice(c_price,giftId,rechargeType,function(price)
		if not __IS_RELEASE__ and (not giftName or not showName or giftName == "" or showName == "") then
			error(DescAuto[278]) -- [278]="直购必须传入礼包名字、后台显示名字"
		end
		
		if not __IS_RELEASE__ and price == 0 then
			error("直购金额不能为0")
		end
		if __SDK_LOGIN__ then
			--getDirectBuyParam(rechargeType, id,price, name, showName,uid,)
			ModelManager.RechargeModel:doPay(price, showName or giftName or Desc.recharge_directBuyGift, ModelManager.RechargeModel:getDirectBuyParam(rechargeType, giftId,c_price, giftName, showName, uid),nil,rechargeType,true)
		else
			RollTips.show(DescAuto[279]..giftName..DescAuto[280]..showName) -- [279]="内网版本使用外挂模拟直购--" -- [280]=" 后台名字:"
			local info = {
				type =tonumber(27);--0:integer		#func
				value1=tonumber(rechargeType),
				value2=tonumber(price),
				value3=tonumber(giftId),
				value4=tonumber(uid),
				msg="",	--	#备用
			}
			local success = function()
				RollTips.show(DescAuto[281]..giftName..DescAuto[280]..showName) -- [281]="模拟直购成功（限内网版本）--" -- [280]=" 后台名字:"
				Dispatcher.dispatchEvent(EventType.buyGift_Success,rechargeType,price)
			end
	
			local errFun = function()
				RollTips.show(DescAuto[282]) -- [282]="模拟直购失败（限内网版本）"
			end
			RPCReq.Test_Cmd(info,success,errFun,nil,true)
		end
	end)
end

--充值
--giveGold充值送的钻石（仅内网用外挂时有效）
function RechargeModel:doPay(money, productName, extendData, giveGold,rechargeType, isDirectBuy)
	print(69, "========", extendData)
	if __SDK_LOGIN__ then
		local payHandler = function()
			local platform = 1	
			if self.chargeList then
				--TableUtil.sortByMap( self.chargeList, { {key="money",asc=true}} )
				for _,setting in ipairs(self.chargeList) do
					if tonumber(money) == tonumber(setting.money) then
						SDKUtil.pay(setting['productId'], isDirectBuy and 0 or setting.gold, productName,setting['money'], extendData)
						Dispatcher.dispatchEvent(EventType.buyGift_Success,rechargeType,money)
						return
					end
				end
			end
			RollTips.show(Desc.recharge_noSetting)
		end
		if not self.chargeList then
			self:getChargeList(payHandler)
		else
			payHandler()
		end
	else
		RollTips.show(DescAuto[283]) -- [283]="内网版本使用外挂模拟充值"
		local info = {
			type =tonumber(27);--0:integer		#func
			value1=tonumber(0),
			value2=tonumber(money),
			value3=tonumber(giveGold),
			msg="",	--	#备用
		}
		local success = function()
			RollTips.show(DescAuto[284]) -- [284]="模拟充值成功（限内网版本）"
			Dispatcher.dispatchEvent(EventType.buyGift_Success,rechargeType,money)
		end

		local errFun = function()
			RollTips.show(DescAuto[285]) -- [285]="模拟充值失败（限内网版本）"
		end
		RPCReq.Test_Cmd(info,success,errFun,nil,true)
	end
	
end

function RechargeModel:checkRealPrice(c_money,giftId,rType,callBack)
		print(0,"checkRealPrice ",c_money,giftId,rType)
	RPCReq.Activity_QueryGiftPrice({id = giftId,rechargeType = rType},function(data)
		printTable(0,"Activity_QueryGiftPrice ",data)
		if data.price == c_money then
			callBack(data.price)
		elseif data.price == -1 then
			RollTips.show(Desc.recharge_noSetting)	
		else
			local info = {}
			info.text = Desc.recharge_changeMoney:format(data.price)
			info.type = "yes_no"
			info.onYes = function()
				callBack(data.price)
			end
			Alert.show(info)		
		end
	end)
end

return RechargeModel
