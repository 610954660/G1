-- --
-- local Scale9Sprite = ccui.Scale9Sprite

-- function Scale9Sprite:setShaderWhiteEnabled(...)
--     self:getSprite():setShaderWhiteEnabled(...)
-- end

-- function Scale9Sprite:setShaderWhiteEnabled(...)
--     self:getSprite():setShaderWhiteEnabled(...)
-- end

-- function Scale9Sprite:setShaderWhiteRate(...)
--     self:getSprite():setShaderWhiteRate(...)
-- end

-- function Scale9Sprite:setDiscolored(...)
--     self:getSprite():setDiscolored(...)
-- end

-- function Scale9Sprite:setHSB(...)
--     self:getSprite():setHSB(...)    
-- end

-- function Scale9Sprite:setEffectOutLine(...)
--     self:getSprite():setEffectOutLine(...)  
-- end

-- function Scale9Sprite:setEffectOutGlow(...)
--     self:getSprite():setEffectOutGlow(...)  
-- end

--
local Button = ccui.Button
function Button:setShaderWhiteEnabled(...)
    self:getNormalRenderer():setShaderWhiteEnabled(...)
    self:getClickedRenderer():setShaderWhiteEnabled(...)
    -- self:getDisableRenderer():setShaderWhiteEnabled(...)
end

function Button:setShaderWhiteEnabled(...)
    self:getNormalRenderer():setShaderWhiteEnabled(...)
    self:getClickedRenderer():setShaderWhiteEnabled(...)
    -- self:getDisableRenderer():setShaderWhiteEnabled(...)
end

function Button:setShaderWhiteRate(...)
    self:getNormalRenderer():setShaderWhiteRate(...)
    self:getClickedRenderer():setShaderWhiteRate(...)
    -- self:getDisableRenderer():setShaderWhiteRate(...)
end

function Button:setDiscolored(...)
    self:getNormalRenderer():setDiscolored(...)
    self:getClickedRenderer():setDiscolored(...)
    -- self:getDisableRenderer():setDiscolored(...)
end

function Button:setHSB(...)
    self:getNormalRenderer():setHSB(...)    
    self:getClickedRenderer():setHSB(...)   
    -- self:getDisableRenderer():setHSB(...)   
end

function Button:setEffectOutLine(...)
    self:getNormalRenderer():setEffectOutLine(...)  
    self:getClickedRenderer():setEffectOutLine(...) 
    -- self:getDisableRenderer():setEffectOutLine(...) 
end

function Button:setEffectOutGlow(...)
    self:getNormalRenderer():setEffectOutGlow(...)  
    self:getClickedRenderer():setEffectOutGlow(...) 
    -- self:getDisableRenderer():setEffectOutGlow(...) 
end

local ImageView = ccui.ImageView
function ImageView:setDiscolored(isDiscolored)
    local scale9 = tolua.cast(self:getVirtualRenderer(),"ccui.Scale9Sprite")
    scale9:setState(isDiscolored and 1 or 0)
end

function ImageView:isDiscolored(...)
    local scale9 = tolua.cast(self:getVirtualRenderer(),"ccui.Scale9Sprite")
    return scale9:getState() == 1
end

function ImageView:setShaderWhiteEnabled(...)
    local scale9 = tolua.cast(self:getVirtualRenderer(), "ccui.Scale9Sprite")
    scale9:setShaderWhiteEnabled(...)
end

function ImageView:setInvert(...)
    local scale9 = tolua.cast(self:getVirtualRenderer(), "ccui.Scale9Sprite")
    return scale9:setInvert(...)
end