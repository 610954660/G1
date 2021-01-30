local PveStarTempleArea = class("PveStarTempleArea")
local starTempleGrid = require("Game.Modules.PveStarTemple.PveStarTempleGrid")

function PveStarTempleArea:ctor(params)
    self.index = params.index
    self.areaObj = params.obj
    self.gridList = {}
    self.areaData = false
    self.layer = false
    self.config = params.config

    for i = 1,self.config.count do
        local grid = self.areaObj:getChildAutoType(i)
        table.insert(self.gridList,starTempleGrid.new({obj = grid,index = i,areaIndex = self.index,isBoss = i == self.config.bossIndex}))
    end
end

function PveStarTempleArea:updateData(areaData,layer)
    self.areaData = areaData
    self.layer = layer

    for i = 1,self.config.count do
        local gridData = nil
        local isWin = false
        isWin = self.areaData.win or false	
        if areaData.event then
            for k,v in pairs(areaData.event) do
                if v.pos == i then
                    gridData = v
                    break
                end
            end
        end
		print(086,gridData)

		if areaData.event and areaData.event[i] then
			self.gridList[i]:updateData(areaData.event[i],isWin,self.layer)
		else
			self.gridList[i]:updateData(nil,isWin,self.layer)
		end
    end

    print(33,"更新区域"..self.index,self.areaData.win)
end

function PveStarTempleArea:handleAuto()
    local ret = {}
    for i = 1,self.config.count do
        local info = self.gridList[i]:handleAuto()
        if info ~= nil then
            table.insert(ret,info)
        end
    end
    return ret
end

function PveStarTempleArea:clear()
    for i = 1,self.config.count do
        self.gridList[i]:clear()
    end

    self.index = false
    self.areaObj = false
    self.gridList = false
    self.areaData = false
    self.layer = false
    self.config = false
end

return PveStarTempleArea