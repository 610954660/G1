--键盘功能控制器
--added by xhd
local KeyboardController,Super = class("KeyboardController", Controller)

function KeyboardController:ctor()
    self.__capSceneSprite = false
end

function KeyboardController:init( ... )
    self:__registerKeyboardEvent()
end

local i = 1
local ctrlPress = false
local altPress = false
local snapshotTable = false
local textureSnapshotTable = false
function KeyboardController:__registerKeyboardEvent( ... )
    if not (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 or CC_TARGET_PLATFORM == CC_PLATFORM_MAC) then
        return
    end

    local  function  onKeyPressed( keyCode,event )
        print(69,"onKeyReleased",keyCode,event)
		
		if keyCode == 14 or keyCode == 15 then
			ctrlPress = true
		end
		
		if keyCode == 16 or keyCode == 17 then
			altPress = true
		end
		
        if keyCode == cc.KeyCode.KEY_F4 then
            reloadLua()
        end
		
		if keyCode == cc.KeyCode.KEY_F1 then
           -- ViewManager.open("GMView")
            ViewManager.open("CardTestView")
		end
        if keyCode == cc.KeyCode.KEY_F2 then
            --ViewManager.open("GMView")
			
			GMView.staticCall("open")
		end
		
		if keyCode == cc.KeyCode.KEY_BACK then
			GMModel:closeLastView()
		end
		
		if keyCode == cc.KeyCode.KEY_F3 then
			GMModel:findChangeLua(true)
		end

		if keyCode == cc.KeyCode.KEY_P then
			if altPress then
				if  ScriptType == ScriptTypeLua and not __IS_RELEASE__ and CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
					print(0,'LuaPerfect: try')
					local _, LuaDebuggee = pcall(require, 'LuaDebuggee')

					if LuaDebuggee and LuaDebuggee.StartDebug then
						if LuaDebuggee.StartDebug('127.0.0.1', 9826) then
							print(0,'LuaPerfect: Successfully connected to debugger!')
						else
							package.loaded["LuaDebuggee"] = nil
							print(0,'LuaPerfect: Failed to connect debugger!')
						end
					else
						print(0,'LuaPerfect: Check documents at: https://luaperfect.net')
					end
				end
			end
		end
		
		if keyCode == cc.KeyCode.KEY_C then
			if altPress then
				if not snapshotTable then
				  collectgarbage("collect")
				  print(__PRINT_TYPE__,"开始快照")
				  snapshotTable = snapshot()
				else
				  print(__PRINT_TYPE__,"结束快照")
				  collectgarbage("collect")
				  snapshot("snapshotTable",snapshotTable)
				  snapshotTable = nil
				end
			end
		end
		
		if keyCode == cc.KeyCode.KEY_X then
			
			if altPress then
				if not textureSnapshotTable then
					textureSnapshotTable = true
					ModelManager.PlayerModel.menCache  = {}
					local str = cc.Director:getInstance():getTextureCache():getCachedTextureInfo()
					print(__PRINT_TYPE__,"生成纹理快照")
					local list = string.split(str, "\n")
					for _,v in ipairs(list) do
						local info = string.split(v, "\"")
						if info[2] then
							ModelManager.PlayerModel.menCache[info[2]] = info[3]
						end
					end
				else
					cc.Director:getInstance():purgeCachedData()
					UIPackageManager.clearUnusedAssets(true)
					display.removeUnusedSpriteFrames()
					cc.Texture2D:printTextureInfo()
					print(__PRINT_TYPE__,"=========texture add ============")
					local str = cc.Director:getInstance():getTextureCache():getCachedTextureInfo()
					local list = string.split(str, "\n")
					for _,v in ipairs(list) do
						local info = string.split(v, "\"")
						if info[2] and not ModelManager.PlayerModel.menCache[info[2]] then
							print(__PRINT_TYPE__, info[2],info[3])
						--else
						--	print(1, "====", info[2],info[3])
						end
					end
					print(__PRINT_TYPE__,"=========texture add end============")
					textureSnapshotTable = false
				end
			end
		end
		
		if keyCode == cc.KeyCode.KEY_F6 then
			FlowManager.backToLogin()
		end
		
		

        if keyCode == cc.KeyCode.KEY_F9 then
            --开启全屏截图。
            if self.__capSceneSprite then
               self.__capSceneSprite:removeFromParent() 
               self.__capSceneSprite = false
               return
            end
            local view = ViewManager.getParentLayer(LayerDepth.UIEffect)
            if false then 
                local renderTexture = cc.RenderTexture:create(display.width,display.height)
                local runningScene = cc.Director:getInstance():getRunningScene()
                renderTexture:beginWithClear(0,0,0,0)
                renderTexture:setKeepMatrix(true)
                runningScene:visit()
                renderTexture:endToLua()
                
                self.__capSceneSprite = cc.SpriteCaptureFB:create()
                --self.__capSceneSprite = cc.Sprite:createWithTexture(renderTexture:getSprite():getTexture())
                if false then
                    --新方法
                    local shaderKey = "guassian_blur"
                    local glProgramCache = cc.GLProgramCache:getInstance()
                    local glProgram  = glProgramCache:getGLProgram(shaderKey)
                    if not glProgram then
                        local vertex = require "Game.Shaders.GaussianBlurVert"
                        local fragment = require "Game.Shaders.GaussianBlurFrag"

                        glProgram = cc.GLProgram:createWithByteArrays(vertex , fragment)
                        if not glProgram then return end
                        glProgramCache:addGLProgram(glProgram, shaderKey)
                    end
                    local state = cc.GLProgramState:create(glProgram)
                    state:setUniformVec2("unit_matrix", {x = 1/display.width,y = 1/display.height})
                    state:setUniformFloat("blurRaius", 9)
                    state:setUniformFloat("sampleNum", 4)
                    self.__capSceneSprite:setGLProgramState(state)
                end

                self.__capSceneSprite:setTag(111222)
                self.__capSceneSprite:setScale(0.4)
                self.__capSceneSprite:setPosition(display.width,-display.height/2)
                self.__capSceneSprite:setContentSize(display.width,display.height)
            else
                if true then
                    i = i + 1
                    local renderTexture = cc.RenderTexture:create(display.width,display.height)
                    --print(15,"display.width,display.height:",size.width,size.height)
                    -- local runningScene = cc.Director:getInstance():getRunningScene()
                    -- renderTexture:beginWithClear(0,0,0,0)
                    -- renderTexture:setKeepMatrix(true)
                    -- runningScene:visit()
                    -- renderTexture:endToLua()
                    -- self.__capSceneSprite = cc.Sprite:createWithTexture(renderTexture:getSprite():getTexture())
                    renderTexture:newImageGY(true)
                    --image:saveToFile("./aaa.png",true)
                        --cc.Director:getInstance():getTextureCache():removeUnusedTextures()
                        --cc.Director:getInstance():getTextureCache():addImage(image,"aaa")

                    --self.__capSceneSprite = cc.Sprite:createWithTexture(renderTexture:getSprite():getTexture())--
                    --self.__capSceneSprite = cc.Sprite:create()
                    --renderTexture:getSprite():setContentSize(display.width,display.height)
                    self.__capSceneSprite = renderTexture
                    --self.__capSceneSprite:setTexture(renderTexture:getSprite():getTexture())
                    --self.__capSceneSprite:setScaleY(-1)
                    --self.__capSceneSprite:setScaleX(0.5)
                    -- self.__capSceneSprite:setScaleX(1)
                    --self.__capSceneSprite:setScale(1)
                    --self.__capSceneSprite:setContentSize()
                    --self.__capSceneSprite:setSpriteFrame(renderTexture:getSprite():getSpriteFrame())
                    self.__capSceneSprite:setPosition(display.width/2,-display.height/2)
                else
                    local textureKey = "testSceneCapture"
                    local runningScene = cc.Director:getInstance():getRunningScene()
                    local image = cc.utils:captureNode(runningScene)
                    local textureCache = cc.Director:getInstance():getTextureCache()
                    local texture = textureCache:getTextureForKey(textureKey)
                    --注意这里这个texture并没有回收的。
                    if not texture then
                        texture = textureCache:addImage(image,textureKey)
                    else
                        texture:initWithImage(image)
                    end
                    self.__capSceneSprite = cc.Sprite:createWithTexture(texture)
                    --self.__capSceneSprite:setScale(0.4)
                    --self.__capSceneSprite:setPosition(display.width/2,-display.height/2)
                end
            end
            view:displayObject():addChild(self.__capSceneSprite)
        end
		
		--下面的是测试代码
		GMModel:doTest(keyCode)
    end

    local function onKeyReleased(keyCode, event)
		if keyCode == 14 or keyCode == 15 then
			ctrlPress = false
		end
		
		if keyCode == 16 or keyCode == 17 then
			altPress = false
		end
    end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)
    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    dispatcher:addEventListenerWithFixedPriority(listener, 1)
    self.__eventListener1 = listener

end
function KeyboardController:clear()
    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    if self.__eventListener1 then
        dispatcher:removeEventListener(self.__eventListener1)
        self.__eventListener1 = false
    end
end


return KeyboardController
