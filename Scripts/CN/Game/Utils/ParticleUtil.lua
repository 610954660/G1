---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-05-14 23:02:05
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class ParticleUtil
local ParticleUtil = {}

local effectPath="Effect"
local _pcFxList={}

--local particle=cc.ParticleSmoke:create()
--local particle=cc.ParticleSnow:create()
--local particle=cc.ParticleFireworks:create()
--local particle=cc.ParticleGalaxy:create()
--local particle=cc.ParticleSpiral:create()


--创建自定义粒子特效
function ParticleUtil.createParticleObj(parent, pos,splistName,path)
	if not path then path = effectPath end
	local particle=cc.ParticleSystemQuad:create(string.format("%s%s.plist", path.."/", splistName))
	local particleObj = fgui.GObject:create()
	particleObj:displayObject():addChild(particle)
	parent:addChild(particleObj)
	particleObj:setPosition(pos.x,pos.y)
	return  particleObj,particle
end


function ParticleUtil.removeParticleObj(splistName)
	if _pcFxList[splistName] then
		_pcFxList[splistName]:release()
		_pcFxList[splistName] = nil
	end
end
function ParticleUtil.hideParticleObj(splistName)
	if _pcFxList[splistName] then
		_pcFxList[splistName].particle:stopSystem()
		_pcFxList[splistName]:setVisible(false)
	end
end




--创建常驻粒子
function ParticleUtil.residentParticle(splistName,parent,pos)
	local particleObj= false
	if _pcFxList[splistName]==nil then
		local particle=false
		if splistName=="particle_View" then
			 particle=cc.ParticleRain:create()
		else
			 particle=cc.ParticleSystemQuad:create(string.format("%s%s.plist", effectPath.."/", splistName))
		end
		local particleObj = fgui.GObject:create()
		particleObj:setTouchable(false)
		particleObj:setPivot(1,1)
		particle:setAnchorPoint({x=1,y=1})
		particleObj:displayObject():addChild(particle)
		particleObj:retain()
		particleObj.particle=particle
		_pcFxList[splistName]=particleObj
    end
	parent:addChild(_pcFxList[splistName])
	if pos==nil then
		_pcFxList[splistName]:setPosition(0,720)
	else
		_pcFxList[splistName]:setPosition(pos.x,pos.y)
		_pcFxList[splistName]:setVisible(true)
		_pcFxList[splistName].particle:resetSystem()
	end

	return  _pcFxList[splistName]
end



--stopSystem 和 resetSystem

function ParticleUtil.retainParticle(splistName)
	if _pcFxList[splistName] then
		local view = ViewManager.getLayerTopWindow(LayerDepth.Window) 
		if view==nil then
			_pcFxList[splistName]:release()
			_pcFxList[splistName] = nil
			return 
		end
		if  view.window._showParticle then
			view.window.view:addChild(_pcFxList[splistName])
		end
	end
end



return ParticleUtil