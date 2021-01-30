
-- added by wyz
-- 精灵合成

local ItemConfiger       = require "Game.ConfigReaders.ItemConfiger" --道具配置读取器
local ElvesSyntheticView = class("ElvesSyntheticView",Window)

local __RANDOM_MIN = 10000077   -- 随机碎片的Code范围
local __RANDOM_MAX = 10000078


function ElvesSyntheticView:ctor()
    self._packName = "ElvesSystem"
    self._compName = "ElvesSyntheticView"
    self._rootDepth = LayerDepth.PopWindow

    self._AddNum    = 1     -- 合成个数
    self.btn_ok     = false 
    self.itemCell   = false
    self.itemName   = false
    self.txt_num    = false

    self._hasNum = false
    self._needNum = false
end

function ElvesSyntheticView:_initUI()
    self.btn_ok     = self.view:getChildAutoType("btn_ok")
    self.itemCell   = self.view:getChildAutoType("itemCell")
    self.itemName   = self.view:getChildAutoType("itemName")
    self.txt_num    = self.view:getChildAutoType("txt_num")
end


function ElvesSyntheticView:_initEvent()
    local data = self._args
    local __data  = data.__data
    local __itemInfo = data.__itemInfo
    local comCode = __data.code

    local itemData = DynamicConfigData.t_ElfCombine[__data.code]
    local randomCtrl = self.view:getController("randomCtrl")

    if comCode >= __RANDOM_MIN and comCode <= __RANDOM_MAX then
        randomCtrl:setSelectedIndex(1)
        self._hasNum = __data.amount
        self._needNum = 0
        if itemData then
            self._needNum = itemData.amount
        end
        local maxNum= math.floor( self._hasNum/self._needNum) 
        self._AddNum=maxNum
    else
        randomCtrl:setSelectedIndex(0)
    end


    local reqInfo = {
        itemCode = comCode,
        amount = self._AddNum ,
        -- bagType = GameDef.BagType.Elf,
    }
    printTable(8848,">>>data>>",data)
    local elvesName  = ItemConfiger.getItemNameByCode(__itemInfo.icon)
    self.btn_ok:addClickListener(function()
        RPCReq.Elf_Component(reqInfo,function(res)
            print(8848,">>>>> ".. elvesName .. ">>合成成功>>>>>>") 
            printTable(8848,">>>res>>",res)
            -- RollTips.show(string.format(Desc.ElvesSystem_elvesSynthetic,elvesName))
            ModelManager.ElvesSystemModel.summonElves = res.elf or {}
            ModelManager.ElvesSystemModel.summonReward = res.summon or {}
            ModelManager.ElvesSystemModel.summonElvesNum = #ModelManager.ElvesSystemModel.summonElves
            if ModelManager.ElvesSystemModel.summonElvesNum > 0 then
                ViewManager.open("ElvesGetView",{type = 1})
            elseif #ModelManager.ElvesSystemModel.summonReward > 0 then
                RollTips.showReward(ModelManager.ElvesSystemModel.summonReward)
                ModelManager.ElvesSystemModel.summonReward = {}
            end
            -- ViewManager.open("ElvesGetView",{type = 2,elfId = __itemInfo.icon})
            ViewManager.close("ElvesSyntheticView")
        end)
    end)

    local itemCell  = BindManager.bindItemCell(self.itemCell)
    itemCell:setData(__data.code,__data.amount)

    self.itemName:setText(__itemInfo.name)

    local addpoint = self.view:getChild("addpoint")
    addpoint:addClickListener(
        function(...)
			self._AddNum=self._AddNum+1
			local maxNum= math.floor( self._hasNum/self._needNum  ) 
			if self._AddNum >=maxNum then
				self._AddNum=maxNum;
				RollTips.show(DescAuto[41]) -- [41]='达到最大数量'
			end
			self:showTextNum();
        end
	)
	local subpoint = self.view:getChild("subpoint")
    subpoint:addClickListener(
		function(...)
			self._AddNum=self._AddNum-1
            if self._AddNum<=1 then
				self._AddNum=1;
				RollTips.show(DescAuto[42]) -- [42]='达到最小数量'
			end
			self:showTextNum();
        end
    )

    local btnmax = self.view:getChild("btn_max")
    btnmax:addClickListener(
        function(...)
            local maxNum= math.floor( self._hasNum/self._needNum  ) 
            self._AddNum=maxNum;
            if self._AddNum >=maxNum then
				self._AddNum=maxNum;
				RollTips.show(DescAuto[41]) -- [41]='达到最大数量'
			end
			self:showTextNum();
        end
    )

    self:showTextNum()
end

function ElvesSyntheticView:showTextNum()
    self.txt_num:setText(self._AddNum)
end

return ElvesSyntheticView
