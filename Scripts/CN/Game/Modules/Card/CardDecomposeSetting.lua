---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by:
-- Date: 2020-01-11 17:15:22
---------------------------------------------------------------------
local CardDecomposeSetting, Super = class("CardDecomposeSetting", Window)
local band = bit.band
local lshift = bit.lshift
function CardDecomposeSetting:ctor()
    self._packName = "CardSystem"
    self._compName = "CardDecomposeSetting"
	self._rootDepth = LayerDepth.PopWindow
    self.faceList = false
    self.chooseData = false
end

function CardDecomposeSetting:_initUI()
    local viewRoot = self.view
    self.choose1 = viewRoot:getChild("checkBox1")
    self.choose2 = viewRoot:getChild("checkBox2")
    self.choose3 = viewRoot:getChild("checkBox3")
    local chooseData = ModelManager.CardLibModel.cardDecomPoseSetting
    self.chooseData = clone(chooseData)
    local chooseData1 = self:GetBitByIndex(chooseData, 1)
    local chooseData2 = self:GetBitByIndex(chooseData, 2)
	local chooseData3 = self:GetBitByIndex(chooseData, 3)
	printTable(8, "??????????????>>>>>>",chooseData1,chooseData2,chooseData3)
    self.choose1:setSelected(chooseData1 >= 1)
    self.choose2:setSelected(chooseData2 >= 1)
    self.choose3:setSelected(chooseData3 >= 1)
    -- local info = self:SetBitByIndex(1, 2, 0)
    -- local info1 = self:SetBitByIndex(1, 2, 1)
    -- printTable(8, ">>>>>>>>>>>>>?????", info, info1)
    self:bindEvent()
end

-- 获取数字的二进制形式的某个位的值，index从1开始
function CardDecomposeSetting:GetBitByIndex(num, index)
    local b = bit.lshift(1, (index - 1))
    return bit.band(num, b)
end

-- 设置数字某个位的值，index从1开始，v: 0或1
function CardDecomposeSetting:SetBitByIndex(num, index, v)
    local b = bit.lshift(1, (index - 1))
    if v > 0 then
        num = bit.bor(num, b)
    else
        b = bit.bnot(b)
        num = bit.band(num, b)
    end
    return num
end

function CardDecomposeSetting:bindEvent()
    local btnExit = self.view:getChild("btn_exit")
    btnExit:addClickListener(
        function()
            self.chooseData = 0
            ViewManager.close("CardDecomposeSetting")
        end
    )

    local btnSure = self.view:getChild("btn_sure")
    btnSure:addClickListener(
        function()
            printTable(8, "??????????????>>>>>>", self.chooseData)
            ModelManager.CardLibModel:setAutoDecompose(self.chooseData)
            ViewManager.close("CardDecomposeSetting")
        end
    )

    self.choose1:addClickListener(
        function()
            local chooseData = self:GetBitByIndex(self.chooseData, 1)
            printTable(8, "??????????????1", chooseData)
            if chooseData == 0 then
                chooseData = self:SetBitByIndex(self.chooseData, 1, 1)
            else
                chooseData = self:SetBitByIndex(self.chooseData, 1, 0)
            end
            self.chooseData = bit.band(7, chooseData)
            printTable(8, "??????????????2", self.chooseData)
        end
    )
    self.choose2:addClickListener(
        function()
            local chooseData1 = self:GetBitByIndex(self.chooseData, 2)
            printTable(8, "??????????????3", chooseData1)
            if chooseData1 == 0 then
                chooseData1 = self:SetBitByIndex(self.chooseData, 2, 1)
            else
                chooseData1 = self:SetBitByIndex(self.chooseData, 2, 0)
            end
            self.chooseData = bit.band(7, chooseData1)
            printTable(8, "??????????????4", self.chooseData)
        end
    )
    self.choose3:addClickListener(
        function()
            local chooseData2 = self:GetBitByIndex(self.chooseData, 3)
            printTable(8, "??????????????5", chooseData2)
            if chooseData2 == 0 then
                chooseData2 = self:SetBitByIndex(self.chooseData, 3, 1)
            else
                chooseData2 = self:SetBitByIndex(self.chooseData, 3, 0)
            end
            self.chooseData = bit.band(7, chooseData2)
            printTable(8, "??????????????6", self.chooseData)
        end
    )
end

function CardDecomposeSetting:_enter()
end

function CardDecomposeSetting:_exit()
    self.chooseData = 0
end

return CardDecomposeSetting
