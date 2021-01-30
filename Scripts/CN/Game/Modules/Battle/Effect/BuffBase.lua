---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: lijiejian
-- Date: 2020-06-20 17:17:08
---------------------------------------------------------------------
-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File
---@class buffBase

local BuffBase = class("BuffBase")

function BuffBase:ctor(index,HeroCell)
    self.buffList={}--所有buff
	self.buffFXs={}
	self.buffIDs={}--所有buffId
	self.index=index
	self.heroCell=HeroCell
	self.HungParent=self.heroCell.view:getParent()
end
--更新buff处理
--添加Buff
--id 是位置id
function BuffBase:addBuff(buffs,addFXFun)
	if buffs ~= nil then
		for k , buffData in pairs(buffs) do
			self.buffIDs[ buffData.id ] = buffData.buffId
			local buffCount = 0
			if self.buffList[ buffData.buffId ] then
				buffCount = self.buffList[ buffData.buffId ].buffCount
			end
			if buffCount == nil then buffCount = 0 end
			buffData.buffCount = buffCount + 1
			self.buffList[ buffData.buffId ] = buffData
			--处理buff特效关系
			local buff=DynamicConfigData.t_buff[buffData.buffId]
			if buff then
				--如果有多个的话，这里需要做遍历处理
				local tipCount=0
				local effName = buff.specialEffects[1]
				local effCount = self.buffFXs[ effName ]
				--printTable(521 , "Buff信息 " , buffInfo , effCount)
				if effCount == nil then
					effCount = 0
				end
				if effCount==0 then
					--这里处理循环特效逻辑，buff触发时的单次表现特效，可以放在逻辑外
					if addFXFun then
						addFXFun(buffData)
					else
						SkillManager.addbuffFx( self.index , buffData )
					end
				end
				if effName then
					self.buffFXs[ effName ] = effCount +1
				end
				--buff.buffTipsRes="fy_down"
				if buff.buffTipsRes~="" and not self.heroCell.isSub then
					tipCount=tipCount+1
					self:showBuffTips(tipCount,buff.buffTipsRes)
				end


			end
		end
	end

end



function BuffBase:refeashBuff(buffs) 
	for k , buffData in pairs(buffs) do
		if self.buffList[ buffData.buffId ] then
			self.buffList[ buffData.buffId ].round=buffData.round
		end
	end
end



function BuffBase:addConnectBuff(id,connectId,buffs)
	local toTarget=BattleModel:getHeroItemById(connectId)
	toTarget.buffBase:addBuff(clone(buffs),function (buffData)
			--被连接的buff不需要添加特效
		end)
	self:addBuff(buffs,function (buffData)
		    --创建链接型特效
			--SkillManager.addConnectFx(self.index,buffData)
	end)
end


--移除buff
function BuffBase:removeBuff(buffs)
	-- printTable(5230 , "移除Buff ： " , id ,self.__buffData )

	if buffs ~= nil then
		for k,buffIndex in pairs(buffs) do
			local buffId = self.buffIDs[ buffIndex ]
			local buff=DynamicConfigData.t_buff[buffId]

			if buffId==nil then
				break;
			end
			local buffCount = 0
			if self.buffList[ buffId ] then
				buffCount = self.buffList[ buffId ].buffCount
			end
			buffCount = buffCount - 1

			if buffCount <=0 then
				self.buffList[ buffId ] = nil
			elseif self.buffList[ buffId ] then
				self.buffList[ buffId ].buffCount = buffCount
			end
			if buff then
				--如果有多个的话，这里需要做遍历处理
				
				local effName = buff.specialEffects[1]
				local effCount = self.buffFXs[effName]
				if effCount==nil then
					effCount=0
				end
				--移除buff时，去处理buff特效逻辑
				if effCount>0 then effCount = effCount-1 end
				--if id ==111 and effName==10053 then
				--print(52100,effCount,buff.buffId,"effCount 移除")
				--end
				if  effCount <=0 then
					SkillManager.removeBuffFx(self.index,effName,buff.boneStyle)
				end
				if effName then
					self.buffFXs[effName] = effCount
				end

			end

		end
	end
end


function BuffBase:showBuffTips(tipCount,buffTipsRes)
	local tipHungPos=self.heroCell:getModelHungPos()
	if tipHungPos==false then
		return
	end
	local buffTip= FGUIUtil.createObjectFromURL("Battle",'buffTipsRes')--普通伤害
	self.HungParent:addChild(buffTip)
	local offsetX=80*self.heroCell.goWrapParent:getScaleX()
	
	buffTip:setPosition(tipHungPos.x+0*(tipCount-1)+offsetX,tipHungPos.y-50-0*(tipCount-1))
	buffTip:setIcon(PathConfiger.getBuffDes(buffTipsRes))
	buffTip:setSortingOrder(30)
	buffTip:getTransition("t_hp"):play(function(context)
			buffTip:removeFromParent()
	end)
end


function BuffBase:getBuff()
   return self.buffList
end

function BuffBase:setBuff(buffList)
	self.buffList=buffList
end

----替补上场时，交换buff位置
----toIdx          1:integer          #替补位置
----preIdx         2:integer          #自己
function BuffBase:exchangeBuff(toIdx)
	
	local toTarget=BattleModel:getHeroItemById(toIdx)
	local toList = clone(toTarget.buffBase:getBuff())
	if toTarget.buffBase then
		toTarget.buffBase:setBuff(clone(self.buffList))
	end
	for k,buff in pairs(self.buffList) do
			SkillManager.removeBuffFx(self.index,buff)
	end
	self.buffList={}
	self:addBuff(toList)
	Dispatcher.dispatchEvent(EventType.battle_buffUpdate  , {index=toIdx} )
	
end

--角色死亡时，清理相关位置buff数据
function BuffBase:resetBuff()
	-- self.__buffData[ id ] = nil
end


return BuffBase