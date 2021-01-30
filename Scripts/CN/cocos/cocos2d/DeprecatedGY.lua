_G.kccLabelShadowNone = -1
_G.kccLabelShadowRound = 0
_G.kccLabelShadowOneSide = 1   
_G.kccLabelShadowBlend = 2   

_G.FRSimpleButtonNormal = 1 
_G.FRSimpleButtonSelected  = 2
_G.FRSimpleButtonDisabled  = 4

_G.kTextInputKeyBoardReturnKeyTypeDone = 0
_G.kTextInputKeyBoardReturnKeyTypeGo = 1
_G.kTextInputKeyBoardReturnKeyTypeGoogle = 2
_G.kTextInputKeyBoardReturnKeyTypeJoin = 3
_G.kTextInputKeyBoardReturnKeyTypeNext = 4
_G.kTextInputKeyBoardReturnKeyTypeRoute = 5
_G.kTextInputKeyBoardReturnKeyTypeSearch = 6
_G.kTextInputKeyBoardReturnKeyTypeSend = 7
_G.kTextInputKeyBoardReturnKeyTypeYahoo = 8
_G.kTextInputKeyBoardReturnKeyTypeEmergencyCall = 9


_G.kTextInputKeyBoardTypeASCIICapable = 0
_G.kTextInputKeyBoardTypeNumbersAndPunctuation = 1
_G.kTextInputKeyBoardTypeURL = 2
_G.kTextInputKeyBoardTypeNumberPad = 3
_G.kTextInputKeyBoardTypePhonePad = 4
_G.kTextInputKeyBoardTypeNamePhonePad = 5
_G.kTextInputKeyBoardTypeEmailAddress = 6
_G.kTextInputKeyBoardTypeDecimalPad = 7
_G.kTextInputKeyBoardTypeTwitter = 8


_G.kFRScrollPolicyAuto = 0
_G.kFRScrollPolicyOn = 1
_G.kFRScrollPolicyOff = 2

_G.kFRHAlignmentTop = 0
_G.kFRHAlignmentMedium = 1
_G.kFRHAlignmentBottom = 2
    
_G.kFRVAlignmentLeft = 0
_G.kFRVAlignmentCenter = 1
_G.kFRVAlignmentRight = 2

_G.kFRCreationPolicyAuto = 0
_G.kFRCreationPolicyAll = 1


_G.kFRTabBarDirectionHorizontal = 0
_G.kFRTabBarDirectionVertical = 1


_G.kFRAccordionModeCreateAll = 0
_G.kFRAccordionModeCreateDynamic = 1


_G.kFRAccordionShowPinned = 0
_G.kFRAccordionShowAdjust = 1

_G.kFRNumericKeyOne = 0
_G.kFRNumericKeyTwo = 1
_G.kFRNumericKeyThere = 2
_G.kFRNumericKeyFour = 3
_G.kFRNumericKeyFive = 4
_G.kFRNumericKeySix = 5
_G.kFRNumericKeySeven = 6
_G.kFRNumericKeyEight = 7
_G.kFRNumericKeyNine = 8
_G.kFRNumericKeyBackspace = 9
_G.kFRNumericKeyZero = 10
_G.kFRNumericKeyClear = 11

_G.kFRGraySpriteDirectionHorizontal = 0
_G.kFRGraySpriteDirectionVertical = 1


_G.FRControlStateNormal = 1
_G.FRControlStateSelected = 2
_G.FRControlStateDisabled = 4


_G.kNotConnected = 0
_G.kWiFi = 1
_G.kWWAN = 2


_G.kPayTypeDefault = 0
_G.kPayTypeAlipayQuick = 1
_G.kPayTypeAlipayWap = 2
_G.kPayTypeUnionPay = 3
_G.kPayTypeChinaMobile = 4
_G.kPayTypeChinaTelecom = 5
_G.kPayTypeChinaUnicom = 6
    
_G.kSinaWeibo = 0
_G.kTencentWeibo = 1
_G.kWeixinFriend = 2
_G.kWeixinChat = 3
    
    
_G.kTextureSubfixInvalid = 0
_G.kTextureSubfixPVRCCZ = 1
_G.kTextureSubfixRGD = 2

_G.kTypeBackClicked = 1
_G.kTypeMenuClicked = 2
_G.kTypeKeyBoard = 3

_G.kOrientationLeftOver = _G.kCCTransitionOrientationLeftOver
_G.kOrientationRightOver = _G.kCCTransitionOrientationRightOver
_G.kOrientationUpOver =  _G.kCCTransitionOrientationUpOver
_G.kOrientationDownOver = _G.kCCTransitionOrientationDownOver


_G.CCTOUCHBEGAN = "began"
_G.CCTOUCHMOVED = "moved"
_G.CCTOUCHENDED = "ended"

-- --[[
--     改名接口
-- --]]
-- local function deprecatedTip(old_name,new_name)
--     print("\n********** \n"..old_name.." was deprecated please use ".. new_name .. " instead.\n**********")
-- end

-- --类名修改

-- local DeprecatedClass = {}

-- function DeprecatedClass.CCMutableString()
--     deprecatedTip("CCMutableString","MutableString")
--     return MutableString
-- end
-- _G["CCMutableString"] = DeprecatedClass.CCMutableString()

-- --CCNotificationCenter
-- function DeprecatedClass.CCNotificationCenter()
--     deprecatedTip("CCNotificationCenter","cc.__NotificationCenter")
--     return cc.__NotificationCenter
-- end
-- _G["CCNotificationCenter"] = DeprecatedClass.CCNotificationCenter()

-- local CCNotificationCenterDeprecated = { }
-- function CCNotificationCenterDeprecated.sharedNotificationCenter(self)
--     deprecatedTip("CCNotificationCenter:sharedNotificationCenter","CCNotificationCenter:getInstance")
--     return self:getInstance()
-- end
-- rawset(CCNotificationCenter,"sharedNotificationCenter",CCNotificationCenterDeprecated.sharedNotificationCenter)

-- --cc.Ref
-- local RefDeprecated = {}
-- function RefDeprecated.retainCount(self)
--     deprecatedTip("Ref:retainCount","Ref:getReferenceCount")
--     return self:getReferenceCount()
-- end
-- rawset(cc.Ref,"retainCount", RefDeprecated.retainCount)

-- --cc.ResourceManager
-- local TextureManagerDeprecated = {}
-- function TextureManagerDeprecated.sharedTextureManager()
--     deprecatedTip("cc.ResourceManager:sharedTextureManager","cc.ResourceManager:getInstance")
--     return cc.ResourceManager:getInstance()
-- end
-- rawset(cc.ResourceManager,"sharedTextureManager", TextureManagerDeprecated.sharedTextureManager)


-- --CCFileUtils
-- local CCFileUtilsDeprecated = {}
-- function CCFileUtilsDeprecated.getWriteablePath(self)
--     deprecatedTip("CCFileUtils:getWriteablePath","CCFileUtils:getWritablePath")
--     return self:getWritablePath()
-- end
-- rawset(CCFileUtils,"getWriteablePath",CCFileUtilsDeprecated.getWriteablePath)
-- function CCFileUtilsDeprecated.fullPathFromRelativePath(self,filename)
--     deprecatedTip("CCFileUtils:fullPathFromRelativePath","CCFileUtils:fullPathForFilename")
--     return self:fullPathForFilename(filename)
-- end
-- rawset(CCFileUtils,"fullPathFromRelativePath",CCFileUtilsDeprecated.fullPathFromRelativePath)

-- --CCNode
-- local CCNodeDeprecated = { }
-- function CCNodeDeprecated.setPositionLua(self,p)
--     deprecatedTip("CCNode:setPositionLua","CCNode:setPosition")
--     return self:setPosition(p)
-- end
-- rawset(CCNode,"setPositionLua",CCNodeDeprecated.setPositionLua)

-- function CCNodeDeprecated.setTouchPenetrate(self,p)
--     deprecatedTip("CCNode:setTouchPenetrate","delete the code")
--     return nil
-- end
-- rawset(CCNode, "setTouchPenetrate",CCNodeDeprecated.setTouchPenetrate)

-- function CCNodeDeprecated.setTouchPriority(self,p)
--     deprecatedTip("CCNode:setTouchPriority","delete the code")
--     return nil
-- end
-- rawset(CCNode, "setTouchPriority",CCNodeDeprecated.setTouchPriority)


-- function CCNodeDeprecated.removeFromParentAndCleanup(self,cleanup)
--     deprecatedTip("CCNode:removeFromParentAndCleanup","CCNode:removeFromParent")
--     return self:removeFromParent(cleanup)
-- end
-- rawset(CCNode, "removeFromParentAndCleanup",CCNodeDeprecated.removeFromParentAndCleanup)

-- function CCNodeDeprecated.removeAllChildrenWithCleanup(self,cleanup)
--     deprecatedTip("CCNode:removeAllChildrenWithCleanup","CCNode:removeAllChildren")
--     return self:removeAllChildren(cleanup)
-- end
-- rawset(CCNode, "removeAllChildrenWithCleanup",CCNodeDeprecated.removeAllChildrenWithCleanup)

-- function CCNodeDeprecated.getZOrder(self)
--     deprecatedTip("CCNode:getZOrder","CCNode:getLocalZOrder")
--     return self:getLocalZOrder()
-- end
-- rawset(CCNode, "getZOrder",CCNodeDeprecated.getZOrder)

-- function CCNodeDeprecated.pauseSchedulerAndActions(self)
--     deprecatedTip("CCNode:pauseSchedulerAndActions","CCNode:pause")
--     return self:pause()
-- end
-- rawset(CCNode, "pauseSchedulerAndActions",CCNodeDeprecated.pauseSchedulerAndActions)

-- function CCNodeDeprecated.resumeSchedulerAndActions(self)
--     deprecatedTip("CCNode:resumeSchedulerAndActions","CCNode:resume")
--     return self:resume()
-- end
-- rawset(CCNode, "resumeSchedulerAndActions",CCNodeDeprecated.resumeSchedulerAndActions)

-- --CCSprite
-- local CCSpriteDeprecated = {}
-- function CCSpriteDeprecated.setDisplayFrame(self,frame)
--     deprecatedTip("CCSprite:setDisplayFrame","CCSprite:setSpriteFrame")
--     return self:setSpriteFrame(frame)
-- end
-- rawset(CCSprite, "setDisplayFrame",CCSpriteDeprecated.setDisplayFrame)

-- function CCSpriteDeprecated.setFlipX(self,isFilpX)
--     deprecatedTip("CCSprite:setFlipX","CCSprite:setFlippedX")
--     return self:setFlippedX(isFilpX)
-- end
-- rawset(CCSprite, "setFlipX",CCSpriteDeprecated.setFlipX)

-- function CCSpriteDeprecated.isFlipX(self)
--     deprecatedTip("CCSprite:isFlipX","CCSprite:isFlippedX")
--     return self:isFlippedX()
-- end
-- rawset(CCSprite, "isFlipX",CCSpriteDeprecated.isFlipX)

-- function CCSpriteDeprecated.setFlipY(self,isFilpY)
--     deprecatedTip("CCSprite:setFlipY","CCSprite:setFlippedY")
--     return self:setFlippedY(isFilpY)
-- end
-- rawset(CCSprite, "setFlipY",CCSpriteDeprecated.setFlipY)

-- function CCSpriteDeprecated.isFlipY(self)
--     deprecatedTip("CCSprite:isFlipY","CCSprite:isFlippedY")
--     return self:isFlippedY()
-- end
-- rawset(CCSprite, "isFlipY",CCSpriteDeprecated.isFlipY)

-- -- CCCallFuncLua
-- local FRCallFuncLuaDeprecated = {}
-- CCCallFuncLua={}
-- function FRCallFuncLuaDeprecated.create(self,handle,dict)
--     deprecatedTip("CCCallFuncLua:create","cc.CallFunc:create")
--     if dict == nil  then   
--         return cc.CallFunc:create(handle)
--     end
--     return cc.CallFunc:create(handle,dict)
-- end
-- rawset(CCCallFuncLua,"create", FRCallFuncLuaDeprecated.create)

-- local toluaDeprecated = {}
-- local __cast = tolua.cast
-- function toluaDeprecated.cast(object,typeStr)
--     if typeStr == "CCNode" then
--         deprecatedTip("tolua.cast(_,\"CCNode\")","tolua.cast(_,\"cc.Node\")")
--         return tolua.cast(object,"cc.Node")
--     elseif typeStr == "CCSprite" then
--         deprecatedTip("tolua.cast(_,\"CCSprite\")","tolua.cast(_,\"cc.Sprite\")")
--         return tolua.cast(object,"cc.Sprite")
--     elseif typeStr == "CCLayer" then
--         deprecatedTip("tolua.cast(_,\"CCLayer\")","tolua.cast(_,\"cc.Layer\")")
--         return tolua.cast(object,"cc.Layer")
--     elseif typeStr == "CCObject" then
--         deprecatedTip("tolua.cast(_,\"CCObject\")","tolua.cast(_,\"cc.Ref\")")
--         return tolua.cast(object,"cc.Ref")
--     elseif typeStr == "CCScrollView" then
--         deprecatedTip("tolua.cast(_,\"CCScrollView\")","tolua.cast(_,\"cc.ScrollView\")")
--         return tolua.cast(object,"cc.ScrollView")
--     elseif typeStr == "CCLabelBMFont" then
--         deprecatedTip("tolua.cast(_,\"CCLabelBMFont\")","tolua.cast(_,\"cc.LabelBMFont\")")
--         return tolua.cast(object,"cc.LabelBMFont")
--     else
--         return __cast(object,typeStr)
--     end
-- end
-- rawset(tolua,"cast",toluaDeprecated.cast)

-- local FRTabBarDeprecated = {}
-- function FRTabBarDeprecated.getArrayOfButton(self)
--     deprecatedTip("FRTabBar:getArrayOfButton","FRTabBar:getButtons")
--     return self:getButtons()
-- end
-- rawset(FRTabBar,"getArrayOfButton",FRTabBarDeprecated.getArrayOfButton)


-- local FRImageDeprecated = {}
-- function FRImageDeprecated.setFlippedX(self,isFlip)
--     deprecatedTip("FRImage:setFlippedX","FRImage:setFlipX")
--     return self:setFlipX(isFlip)
-- end
-- rawset(FRImage,"setFlippedX",FRImageDeprecated.setFlippedX)

-- function FRImageDeprecated.setFlippedY(self,isFlip)
--     deprecatedTip("FRImage:setFlippedY","FRImage:setFlipY")
--     return self:setFlipY(isFlip)
-- end
-- rawset(FRImage,"setFlippedY",FRImageDeprecated.setFlippedY)
-- --[[
--     C++上封装的基本类型
-- --]]
-- -- CCString
-- local StringDefinition = {
--     __className__ = "CCString",
--     __value__ = "",
-- }
-- _G.CCString = StringDefinition

-- function StringDefinition:create(string)
--     local ccstring = {}
--     local mt = { __index = StringDefinition }
--     setmetatable(ccstring, mt)
--     ccstring.__value__ = string
--     return ccstring
-- end

-- function StringDefinition:getCString()
--     return self.__value__
-- end

-- -- CCBool
-- local BoolDefinition = {
--     __className__ = "CCBool",
--     __value__ = false,
-- }
-- _G.CCBool = BoolDefinition

-- function BoolDefinition:create(boolean)
--     local ccbool = {}
--     local mt = { __index = BoolDefinition }
--     setmetatable(ccbool, mt)
--     ccbool.__value__ = boolean
--     return ccbool
-- end

-- function BoolDefinition:getValue()
--     return self.__value__
-- end

-- -- CCDouble
-- local DoubleDefinition = {
--     __className__ = "CCDouble",
--     __value__ = 0,
-- }
-- _G.CCDouble = DoubleDefinition

-- function DoubleDefinition:create(double)
--     local ccdouble = {}
--     local mt = { __index = DoubleDefinition }
--     setmetatable(ccdouble, mt)
--     ccdouble.__value__ = double
--     return ccdouble
-- end

-- function DoubleDefinition:getValue()
--     return self.__value__
-- end

-- -- CCFloat
-- local FloatDefinition = {
--     __className__ = "CCFloat",
--     __value__ = 0,
-- }
-- _G.CCFloat = FloatDefinition

-- function FloatDefinition:create(float)
--     local ccfloat = {}
--     local mt = { __index = FloatDefinition }
--     setmetatable(ccfloat, mt)
--     ccfloat.__value__ = float
--     return ccfloat
-- end

-- function FloatDefinition:getValue()
--     return self.__value__
-- end

-- -- CCInteger
-- local IntegerDefinition = {
--     __className__ = "CCInteger",
--     __value__ = 0,
-- }
-- _G.CCInteger = IntegerDefinition

-- function IntegerDefinition:create(integer)
--     local ccinteger = {}
--     local mt = { __index = IntegerDefinition }
--     setmetatable(ccinteger, mt)
--     ccinteger.__value__ = integer
--     return ccfloat
-- end

-- function IntegerDefinition:getValue()
--     return self.__value__
-- end

-- local function convertToLuaValue(value)
--     local ret
--     if type(value) == "table" then
--         if value.__className__ == "CCString" or
--            value.__className__ == "CCBool" or
--            value.__className__ == "CCDouble" or
--            value.__className__ == "CCFloat" or
--            value.__className__ == "CCInteger" then
--             ret = value.__value__
--         else
--             assert("wrong value")
--         end
--     else
--         ret = value
--     end
--     return ret
-- end

-- --[[
--     Array Lua实现
-- --]]

-- local ArrayLuaDefinition = {
--     __className__ = "Array",
--     __capacity__ = 0,
-- }
-- _G.CCArray = ArrayLuaDefinition

-- local CC_INVALID_INDEX = -1        --错误索引
-- local DEFAULT_CAPACITY = 7         --默认容量

-- local function isArray(array)
--     if type(array) == "table" and array.__className__ == "Array" and array.__isInstance__ then
--         return true
--     else
--         return false
--     end
-- end

-- local function isObject(object)
--     if type(object) == "number" or type(object) == "string" or type(object) == "boolean" or type(object) == "table" or (type(object) == "userdata" and tolua.cast(object,"cc.Ref")) ~= nil then
--         return true
--     else
--         return false
--     end
-- end

-- local function isAvailableIndexOfArray(array,index)
--     if type(index) ~= "number" or not isArray(array) then
--         return false
--     elseif index < 0 or index > #array - 1 then
--         return false
--     end
--     return true
-- end

-- local function doubleCapacity(array)
--     if isArray(array) then
--         array.__capacity__ = array.__capacity__ * 2
--     end
-- end

-- function ArrayLuaDefinition:create()
--     local array = {   

--     }
--     --第一级元表，封装私有属性的读取和更新
--     local mt1 = {}
--     mt1.__index = {
--         __capacity__ = DEFAULT_CAPACITY,
--         __isInstance__ = true,
--     }
--     mt1.__newindex = function(t,k,v)
--         if rawget(mt1.__index,k) then
--             rawset(mt1.__index,k,v)
--         else
--             rawset(t,k,v)
--         end
--     end
--     setmetatable(array,mt1)
--     --第二级元表，继承共有方法
--     local mt2 = {}
--     mt2.__index = ArrayLuaDefinition
--     setmetatable(mt1.__index,mt2)
--     return array
-- end

-- function ArrayLuaDefinition:createWithObject(object)
--     local array = ArrayLuaDefinition:create()
--     if isObject(object) then
--         table.insert(array,object)
--     end
--     return array
-- end

-- function ArrayLuaDefinition:retain()
-- end

-- function ArrayLuaDefinition:release()
-- end

-- function ArrayLuaDefinition:createWithArray(otherArray)
--     local array = ArrayLuaDefinition:create()
--     if isArray(otherArray) then
--         for k,v in ipairs(otherArray) do
--             if isObject(v) then
--                 array:addObject(v)
--             end
--         end
--     end
--     return array
-- end

-- function ArrayLuaDefinition:createWithCapacity(capacity)
--     local array = ArrayLuaDefinition:create()
--     if type(capacity) == "number" and capacity > 0 then
--         array.__capacity__ = capacity
--     end
--     return array
-- end

-- function ArrayLuaDefinition:count()
--     if isArray(self) then
--         return #self
--     end
-- end

-- function ArrayLuaDefinition:capacity()
--     if isArray(self) then
--         return self.__capacity__
--     end
-- end

-- function ArrayLuaDefinition:indexOfObject(object)
--    if isArray(self) then
--         for k,v in ipairs(self) do
--             if v == object then
--                 return k
--             end
--         end
--     end
--     return CC_INVALID_INDEX
-- end 

-- function ArrayLuaDefinition:objectAtIndex(index)
--     if isArray(self) and isAvailableIndexOfArray(self,index) then
--         index = index + 1
--         return self[index]
--     end
-- end

-- function ArrayLuaDefinition:lastObject()
--     if isArray(self) then
--         return self[#self]
--     end    
-- end

-- function ArrayLuaDefinition:randomObject()
--     if isArray(self) then
--         local randomIndex = math.random(1,#self)
--         return self[randomIndex]
--     end
-- end

-- function ArrayLuaDefinition:isEqualToArray(otherArray)
--     if isArray(self) and isArray(otherArray) then
--         if #table ~= #otherArray then
--             return false
--         end
--         for k,v in ipairs(table) do
--             if v ~= otherArray[k] then
--                 return false
--             end
--         end
--         return true
--     end
--     return false
-- end

-- function ArrayLuaDefinition:addObject(object)
--     if isArray(self) and isObject(object) then
--         if #self == self.__capacity__ then
--             doubleCapacity(self)
--         end
--         --if object.retain then
--         --    object:retain()
--         --end
--         table.insert(self, convertToLuaValue(object))
--     end
-- end

-- function ArrayLuaDefinition:insertObject(object,index)
--     if isArray(self) and isObject(object) and isAvailableIndexOfArray(self,index) then
--         index = index + 1
--         if #self == self.__capacity__ then
--             doubleCapacity(self)
--         end
--         for i=#self,index,-1 do
--             self[i+1]=self[i]
--         end
--         self[index] = convertToLuaValue(object)
--     end
-- end

-- function ArrayLuaDefinition:removeObjectAtIndex(index,bReleaseObj)
--     if isArray(self) and isAvailableIndexOfArray(self,index) then
--         index = index + 1
--         -- if type(bReleaseObj) ~= "boolean" then
--         --     bReleaseObj = true
--         -- end
--         -- local obj = self[index]
--         -- if bReleaseObj and obj.release then
--         --     obj:release()
--         -- end
--         for i=index+1,#self do
--             self[i-1]=self[i]
--         end
--         self[#self] = nil
--     end
-- end

-- function ArrayLuaDefinition.removeAllObjects(self)
--     if isArray(self) then
--         while(#self ~= 0) do
--             ArrayLuaDefinition.removeObjectAtIndex(self,0,true)
--         end
--     end
-- end

-- function ArrayLuaDefinition.exchangeObjectAtIndex(self,index1,index2)
--     if isArray(self) and isAvailableIndexOfArray(self,index1) and isAvailableIndexOfArray(self,index2) then
--         index1 = index1 + 1
--         index2 = index2 + 1
--         local temp = self[index1]
--         self[index1] = self[index2]
--         self[index2] = temp
--     end
-- end

-- function ArrayLuaDefinition.replaceObjectAtIndex(self,index,object,bReleaseObj)
--     ArrayLuaDefinition.insertObject(self,object,index)
--     ArrayLuaDefinition.removeObjectAtIndex(self,index,bReleaseObj)
-- end

-- function ArrayLuaDefinition.setObjectAtIndex(self,index,newObj,bReleaseObj)
--     if isArray(self) and isAvailableIndexOfArray(self,index1) and isObject(newObj) then
--         -- if type(bReleaseObj) ~= "boolean" then
--         --     bReleaseObj = true
--         -- end
--         -- local oldObj = self[index]
--         -- if bReleaseObj and oldObj.release then
--         --     oldObj:release()
--         -- end
--         index = index + 1
--         self[index] = convertToLuaValue(newObj)
--     end
-- end

-- --[[
--     Dictionary Lua实现
-- --]]
-- local DictType = {
--     kDictUnknown = 0,
--     kDictStr = 1,
--     kDictInt = 2,
-- }

-- local function isDictionary(dict)
--     if type(dict) == "table" and dict.__className__ == "Dictionary" and dict.__isInstance__ then
--         return true
--     else
--         return false
--     end
-- end

-- local function isProperKeyType(dict, key)
--     if not isDictionary(dict) then
--         return false
--     elseif type(key) == "string" then
--         return dict.__dictType__ == DictType.kDictStr or dict.__dictType__ == DictType.kDictUnknown
--     elseif type(key) == "number" then
--         return dict.__dictType__ == DictType.kDictInt or dict.__dictType__ == DictType.kDictUnknown
--     else
--         return false
--     end
-- end

-- local function setUsingDictType(dict,key)
--     if type(key) == "string" then
--         dict.__dictType__ = DictType.kDictStr
--     elseif type(key) == "number" then
--         dict.__dictType__ = DictType.kDictInt
--     else
--         dict.__dictType__ = DictType.kDictUnknown
--     end
-- end

-- local DictionaryLuaDefinition = {
--     __className__ = "Dictionary",
-- }
-- _G.CCDictionary = DictionaryLuaDefinition


-- function DictionaryLuaDefinition:create()
--     local dict = {

--     }
--     --第一级元表，封装私有属性的读取和更新
--     local mt1 = {}
--     mt1.__index = {
--         __isInstance__ = true,
--         __dictType__ = DictType.kDictUnknown,
--         __num__ = 0,
--     }
--     mt1.__newindex = function(t,k,v)
--         if rawget(mt1.__index,k) then
--             rawset(mt1.__index,k,v)
--         else
--             rawset(t,k,v)
--         end
--     end
--     setmetatable(dict,mt1)
--     --第二级元表，继承共有方法
--     local mt2 = {}
--     mt2.__index = DictionaryLuaDefinition
--     setmetatable(mt1.__index,mt2)
--     return dict 
-- end

-- function DictionaryLuaDefinition:count()
--     if isDictionary(self) then
--         return self.__num__
--     end
-- end

-- function DictionaryLuaDefinition:setObject(object,key)
--     if isDictionary(self) and isObject(object) and isProperKeyType(self,key) then
--         if self.__dictType__ == DictType.kDictUnknown then
--             setUsingDictType(self,key)
--         end
--         if self[key] == nil then
--             self.__num__ = self.__num__ + 1
--         end
--         self[key] = convertToLuaValue(object)
--     end
-- end

-- function DictionaryLuaDefinition:objectForKey(key)
--     if isDictionary(self) and isProperKeyType(self,key) then
--         return self[key]
--     end 
-- end

-- function DictionaryLuaDefinition:removeObjectForKey(key)
--     if isDictionary(self) and isProperKeyType(self,key) then
--         if self[key] ~= nil then
--             self.__num__ = self.__num__ - 1
--         end     
--         self[key] = nil
--     end
-- end

-- function DictionaryLuaDefinition:removeAllObjects()
--     if isDictionary(self) then
--         for k,_ in pairs(self) do
--             if k ~= "__isInstance__" and k ~= "__dictType__" and k ~= "__num__" then
--                 self[k] = nil
--             end
--         end 
--         self.__num__ = 0
--     end
-- end

-- function frBezierConfig( endPosition, controlPoint_1, controlPoint_2)
--     return {controlPoint_1, controlPoint_2, endPosition}
-- end

-- -- FRHBox & FRVBox
-- local FRHBoxDeprecated = {}
-- function FRHBoxDeprecated.createWithArray(self, items, hAlign, vAlign, gap, padding)
--     deprecatedTip("FRHBox:createWithArray","FRHBox:createWithVector")
--     return self:createWithVector(items, hAlign, vAlign, gap, padding)
-- end
-- rawset(FRHBox, "createWithArray", FRHBoxDeprecated.createWithArray)

-- local FRVBoxDeprecated = {}
-- function FRVBoxDeprecated.createWithArray(self, items, hAlign, vAlign, gap, padding)
--     deprecatedTip("FRVBox:createWithArray","FRVBox:createWithVector")
--     return self:createWithVector(items, hAlign, vAlign, gap, padding)
-- end
-- rawset(FRVBox, "createWithArray", FRVBoxDeprecated.createWithArray)

-- -- local function __ccpoint(x, y)
-- --     deprecatedTip("CCPoint","cc.p")
-- --     return cc.p(x, y)
-- -- end
-- -- rawset(_G,"CCPoint",__ccpoint)



-- local FRArrayDeprecated = {}

-- local _FRArray_objectAtIndex = FRArray.objectAtIndex

-- function FRArrayDeprecated.objectAtIndex(self, index)
--     if index < 0 or index >= self:count() then 
--         return nil
--     end
--     return _FRArray_objectAtIndex(self, index)
-- end
-- rawset(FRArray, "objectAtIndex", FRArrayDeprecated.objectAtIndex)

-- function escape(w)
--     local pattern="[^%w%d%.%-%*]"  
--     local s=string.gsub(w,pattern,function(c)  
--         local c=string.format("_%02X",string.byte(c))  
--         return c  
--     end)
--     return s  
-- end  

-- --临时修复UserDefault保存问题
-- local UserDefaultDeprecated = {}

-- -- --bool
-- local _UserDefault_setBoolForKey = cc.UserDefault.setBoolForKey
-- function UserDefaultDeprecated.setBoolForKey(self, key, value )
--     return _UserDefault_setBoolForKey(self, escape(key), value)
-- end
-- rawset(cc.UserDefault, "setBoolForKey", UserDefaultDeprecated.setBoolForKey)

-- local _UserDefault_getBoolForKey = cc.UserDefault.getBoolForKey
-- function UserDefaultDeprecated.getBoolForKey(self, key, deval)
--     if deval then 
--         return _UserDefault_getBoolForKey(self, escape(key), deval)
--     else
--         return _UserDefault_getBoolForKey(self, escape(key))
--     end
-- end
-- rawset(cc.UserDefault, "getBoolForKey", UserDefaultDeprecated.getBoolForKey)

-- -- --int
-- local _UserDefault_setIntegerForKey = cc.UserDefault.setIntegerForKey
-- function UserDefaultDeprecated.setIntegerForKey(self, key, value )
--     return _UserDefault_setIntegerForKey(self, escape(key), value)
-- end
-- rawset(cc.UserDefault, "setIntegerForKey", UserDefaultDeprecated.setIntegerForKey)

-- local _UserDefault_getIntegerForKey = cc.UserDefault.getIntegerForKey
-- function UserDefaultDeprecated.getIntegerForKey(self, key, deval)
--     if deval then
--         return _UserDefault_getIntegerForKey(self, escape(key), deval)
--     else
--         return _UserDefault_getIntegerForKey(self, escape(key))
--     end
-- end
-- rawset(cc.UserDefault, "getIntegerForKey", UserDefaultDeprecated.getIntegerForKey)

-- -- --float
-- local _UserDefault_setFloatForKey = cc.UserDefault.setFloatForKey
-- function UserDefaultDeprecated.setFloatForKey(self, key, value )
--     return _UserDefault_setFloatForKey(self, escape(key), value)
-- end
-- rawset(cc.UserDefault, "setFloatForKey", UserDefaultDeprecated.setFloatForKey)

-- local _UserDefault_getFloatForKey = cc.UserDefault.getFloatForKey
-- function UserDefaultDeprecated.getFloatForKey(self, key, deval)
--     if deval then
--         return  _UserDefault_getFloatForKey(self, escape(key), deval)
--     else
--         return  _UserDefault_getFloatForKey(self, escape(key))
--     end
-- end
-- rawset(cc.UserDefault, "getFloatForKey", UserDefaultDeprecated.getFloatForKey)


-- -- --double
-- local _UserDefault_setDoubleForKey = cc.UserDefault.setDoubleForKey
-- function UserDefaultDeprecated.setDoubleForKey(self, key, value )
    
--     return _UserDefault_setDoubleForKey(self, escape(key), value)
-- end
-- rawset(cc.UserDefault, "setDoubleForKey", UserDefaultDeprecated.setDoubleForKey)

-- local _UserDefault_getDoubleForKey = cc.UserDefault.getDoubleForKey
-- function UserDefaultDeprecated.getDoubleForKey(self, key, deval)
--     if deval then
--        return  _UserDefault_getDoubleForKey(self, escape(key), deval)
--     else
--         return  _UserDefault_getDoubleForKey(self, escape(key))
--     end
-- end
-- rawset(cc.UserDefault, "getDoubleForKey", UserDefaultDeprecated.getDoubleForKey)

-- --string
-- local _UserDefault_setStringForKey = cc.UserDefault.setStringForKey
-- function UserDefaultDeprecated.setStringForKeyDeprecated(self, key, value )
--     return _UserDefault_setStringForKey(self, escape(key), value)
-- end
-- rawset(cc.UserDefault, "setStringForKey", UserDefaultDeprecated.setStringForKeyDeprecated)

-- local _UserDefault_getStringForKey = cc.UserDefault.getStringForKey
-- function UserDefaultDeprecated.getStringForKeyDeprecated(self, key, deval)
--     if deval then
--         return _UserDefault_getStringForKey(self, escape(key), deval)
--     else
--         return _UserDefault_getStringForKey(self, escape(key))
--     end
-- end
-- rawset(cc.UserDefault, "getStringForKey", UserDefaultDeprecated.getStringForKeyDeprecated)
