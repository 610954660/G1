--added by wyang
--查看玩家信息符文页
local ViewPlayerRuneBoard = class("ViewPlayerRuneBoard",BindView)
local ItemConfiger = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
local  RuneConfiger = require "Game.Modules.RuneSystem.RuneConfiger"
function ViewPlayerRuneBoard:ctor(view,noClick)
	self.view = view
	self.view:addEventListener(FUIEventType.Exit,function(context) self:__onExit()  end);
end

function ViewPlayerRuneBoard:init( ... )
	self.prosList = self.view:getChildAutoType("prosList")
	self.skillList = self.view:getChildAutoType("skillList")
	self.list_hero = self.view:getChildAutoType("list_hero")
	self.skillName = self.view:getChildAutoType("skillName")
    self.skillTxt = self.view:getChildAutoType("skillTxt")
	
	self.data = false
	self.groupData = false
	self.arrayData = false
	self.attrData = false
	self.skillData = false
	
	self.selectedIndex = 1
	
	
	self:initPanel()
end


function ViewPlayerRuneBoard:initPanel( ... )
	
	--所有符文属性叠加
	self.list_hero:setItemRenderer(function (index,obj)
		local heroInfo = self.arrayData[index + 1]
		local heroCell = obj:getChildAutoType("heroCell")
		local cardItem = BindManager.bindHeroCell(heroCell)
		cardItem:setBaseData(heroInfo)	
		if index + 1 == self.selectedIndex then
			obj:getController("c1"):setSelectedIndex(1)
			obj:setTouchable(false)
			self:updatePage(self.data[index + 1])
		else
			obj:getController("c1"):setSelectedIndex(0)
			obj:setTouchable(true)
		end
		
		obj:removeClickListener()
		obj:addClickListener(function()
			self.selectedIndex  = index + 1
			self.list_hero:setNumItems(#self.arrayData)
		end, 100)
    end)

	--所有符文属性叠加
	self.prosList:setItemRenderer(function (index,obj)
		    local data = self.attrData[index+1]
            obj:getChildAutoType("title"):setText(Desc["common_fightAttr"..data.id])
			obj:getChildAutoType("titleVal"):setText("+"..GMethodUtil:getFightAttrName(data.id,data.value))
			if data.id < 100 or RuneConfiger.isHightAttr(data.id) then
				obj:getChildAutoType("title"):setColor(cc.c3b(0xff, 0xA4, 0x43))
				obj:getChildAutoType("titleVal"):setColor(cc.c3b(0xff, 0xA4, 0x43))
			else
				obj:getChildAutoType("title"):setColor(ColorUtil.textColor.white)
				obj:getChildAutoType("titleVal"):setColor(ColorUtil.textColor.white)
			end
    end)
    --符文技能list
    self.skillList:setItemRenderer(function (index,obj)
    	obj:removeClickListener(100)
    	local skillId = self.skillData[index+1]
		local iconLoader = obj:getChildAutoType("iconLoader")
        if skillId ~= 0 then
            local skillInfo = DynamicConfigData.t_passiveSkill[skillId]
            if skillInfo then
                local skillurl = ModelManager.CardLibModel:getItemIconByskillId(skillInfo.icon)
                iconLoader:setURL(skillurl)
            end
		else
			iconLoader:setURL(nil)
        end
	end)
end

function ViewPlayerRuneBoard:updatePage(runeData)
	if runeData then
		local runeLevel = runeData.level
		self.attrData = runeData.attr
		self.skillData = runeData.skills
		self.view:getChildAutoType("allLevel"):setText(runeLevel)
		for _,v in ipairs(self.attrData) do
			v.isHigh = (v.id < 100 or RuneConfiger.isHightAttr(v.id)) and 1 or 0
		end
		TableUtil.sortByMap(self.attrData, {{key = "isHigh",asc = true}, {key = "id",asc = false}})
		self.view:getChildAutoType("prosList"):setData(self.attrData)
		

		self.skillData = self.skillData or {}
		if not  (#self.skillData>0) then
			table.insert(self.skillData,0)
		end
		self.skillList:setData(self.skillData)
		if self.skillData[1] and self.skillData[1]~=0 then
			self.view:getController("statusCtrl"):setSelectedIndex(1)
			local skillInfo = DynamicConfigData.t_passiveSkill[self.skillData[1]]
			self.skillName:setText(skillInfo.name)
			self.skillTxt:setText(skillInfo.desc)
		else
			self.view:getController("statusCtrl"):setSelectedIndex(0)
		end
	else
		self.view:getChildAutoType("allLevel"):setText(0)
		self.skillData = {0}
		self.skillList:setData(self.skillData)
		self.view:getController("statusCtrl"):setSelectedIndex(0)
	end
end


function ViewPlayerRuneBoard:setData(arrayData, runeData)
	self.arrayData = arrayData
	self.data = runeData
	self.list_hero:setNumItems(#arrayData)
end

--退出操作 在close执行之前 
function ViewPlayerRuneBoard:__onExit()
     print(086,"ViewPlayerRuneBoard __onExit")
--   self:_exit() --执行子类重写
   --[[self:clearEventListeners()
   for k,v in pairs(self.baseCtlView) do
   		v:__onExit()
   end--]]
end

return ViewPlayerRuneBoard