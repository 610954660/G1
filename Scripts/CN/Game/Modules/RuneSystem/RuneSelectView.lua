--Name : RuneSelectView.lua
--Author : generated by FairyGUI
--Date : 2020-6-6
--Desc : 英雄符文选择界面

local RuneSelectView,Super = class("RuneSelectView", Window)
local  RuneConfiger = require "Game.Modules.RuneSystem.RuneConfiger"
function RuneSelectView:ctor()
	--LuaLog("RuneSelectView ctor")
	self._packName = "RuneSystem"
	self._compName = "RuneSelectView"
	self.curRuneData = false
	self.curRuneId = self._args.runeId
	self._rootDepth = LayerDepth.PopWindow
	
end

function RuneSelectView:_initEvent( )
	
end

function RuneSelectView:_initVM( )
	local vmRoot = self
	local viewNode = self.view
	---Do not modify following code--------
	--{vmFields}:RuneSystem.RuneSelectView
		vmRoot.allLevel = viewNode:getChildAutoType("$allLevel")--text
		vmRoot.proList = viewNode:getChildAutoType("$proList")--list
		vmRoot.list = viewNode:getChildAutoType("$list")--list
		vmRoot.skillList = viewNode:getChildAutoType("$skillList")--list
	--{vmFieldsEnd}:RuneSystem.RuneSelectView
	--Do not modify above code-------------
end

function RuneSelectView:_initUI( )
	self:_initVM()

    self.proList:setItemRenderer(function ( index,obj )
		local pdata = self.proList._dataTemplate
		obj:getChildAutoType("title"):setText(Desc["common_fightAttr"..pdata[index+1].id])
		obj:getChildAutoType("titleVal"):setText("+"..GMethodUtil:getFightAttrName(pdata[index+1].id,pdata[index+1].value))
	end)

    self.skillList:setItemRenderer(function (index,obj)
    	 obj:removeClickListener(100)
    	 local itemSkillObj = obj:getChildAutoType("itemSkillCell")
    	 local skillId = self.skillList._dataTemplate[index+1]
         local statusCtrl = obj:getController("statusCtrl")

     	statusCtrl:setSelectedIndex(1)
        local iconLoader = itemSkillObj:getChildAutoType("iconLoader")
        local selectFrameImg = itemSkillObj:getChildAutoType("selectFrameImg")
        local __levelLabel = itemSkillObj:getChildAutoType("lv")
        local lockCtrl = itemSkillObj:getController("lockCtrl")
        selectFrameImg:setVisible(false)
        __levelLabel:setVisible(false)
        --暂时使用被动技能
        -- local skillInfo = DynamicConfigData.t_skill[skillId]
        local skillInfo = DynamicConfigData.t_passiveSkill[skillId]
        if skillInfo then
            local skillurl = ModelManager.CardLibModel:getItemIconByskillId(skillInfo.icon)
            iconLoader:setURL(skillurl)
            end
        obj:addClickListener(function( ... )
            -- ViewManager.open("ItemTips", {codeType = CodeType.SKILL, id = skillId,btnShow = false})
            --printTable(1,skillInfo)
            ViewManager.open("ItemTips", {codeType = CodeType.PASSIVE_SKILL, id = skillId,data = skillInfo,btnShow = false})
        end,100)
    end)

    local data = ModelManager.RuneSystemModel:getAllRunePages(  )
    self.list:setItemRenderer(function (index,obj)
    	local id  = index+1
    	local configData = self.config[id]
    	local flag,serverData = ModelManager.RuneSystemModel:check_RunePageOpen(configData.id)
    	if flag then --已解锁
    		if configData.id == self.curRuneId then
    			obj:getController("statusCtrl"):setSelectedIndex(4)
	    	else
	    		obj:getController("statusCtrl"):setSelectedIndex(3)
	    	end
	    	local level = ModelManager.RuneSystemModel:getRuleAllLevel(configData.id)
	    	print(1,level)
	    	obj:getChildAutoType("level"):setText(level)
            if serverData.name=="" then
                obj:getChildAutoType("name"):setText(Desc.Rune_txt4..id)
            else
                obj:getChildAutoType("name"):setText(serverData.name)
            end
    	else
    		obj:getController("statusCtrl"):setSelectedIndex(5)
    		obj:getChildAutoType("name"):setText(Desc.Rune_txt4..id)
    	end

    	obj:getChildAutoType("btn_use"):removeClickListener(1)
    	obj:getChildAutoType("btn_use"):addClickListener(function( ... )
    		local params = {}
			params.hreoUuid = self._args.herouuid
			params.pageId = configData.id
			--printTable(1,params)
			params.onSuccess = function (res )
			    --printTable(1,"请求更换成功服务器数据=",res)
		    	if res.ret ==0 then
		    		RollTips.show(Desc.Rune_txt15)
		    		CardLibModel:setHeroRunePageByUid(res.hreoUuid,res.pageId)
		    		-- Dispatcher.dispatchEvent(EventType.update_HeroRuneShow)
		    		ViewManager.close("RuneSelectView")
		    	end
			end
			RPCReq.Rune_HeroChooseRune(params, params.onSuccess)
    	end,1)

    	obj:removeClickListener(100)
    	obj:addClickListener(function( ... )
    		if not data[index+1] then
    			RollTips.show(Desc.Rune_txt16)
    			return
    		end
            self.curRuneData = data[index+1]
            self:updateShow()
        end,100)

        if id == self.curRuneId then
        	self.curRuneData = data[index+1]
    		obj:setSelected(true)
    		self:updateShow()
    	end

    end)

    self.data = ModelManager.RuneSystemModel:getAllRunePages()
    self.config = RuneConfiger.getRunePageOpenConfig()
    self.list:setData(self.config) 
end

--更新右边
function RuneSelectView:updateShow( ... )
	-- printTable(1,self.curRuneData)
    -- do return end
	local level = RuneSystemModel:getRuleAllLevel(self.curRuneData.id)
	self.allLevel:setText(level)

	local attr = RuneSystemModel:getRuleAllPros(self.curRuneData.id)
	self.proList:setData(attr)
	local tempSkill = TableUtil.DeepCopy(self.curRuneData.skills)
	for k,v in pairs(tempSkill) do
		if v ==0 then
			table.remove(tempSkill,k)
		end
	end
	self.skillList:setData(tempSkill)
end


return RuneSelectView