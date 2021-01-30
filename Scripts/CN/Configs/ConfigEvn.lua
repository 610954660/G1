---------------------------------------------------------------------
-- Win (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-01-08 20:19:24
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class ConfigEvn
local StaticConfigData=require "Configs.StaticConfigs"

GameDef = setmetatable({},{__index = function (t,k)
			local tb = require (string.format("Configs.GameDef.%s",k))
			rawset(t,k,tb)
			return tb
		end})
package.loaded["GameDef"] = GameDef

DynamicConfigData = setmetatable({},{
			__index = function (t,k)
				assert(not StaticConfigData[k],"DynamicConfigData")
				local tb = nil
				xpcall(function ()
					tb = require (string.format("Configs.Generate.%s",k))
					rawset(t,k,tb)
				end,__G__TRACKBACK__)
				
				if not __IS_RELEASE__ then
					local d = debug.getinfo(2, "S")
					local w=d and d.what or "C"
					if w == "main" or w == "C" then
						error("assign DynamicConfigData to lua chunk is not allowed '"..n.."'", 2)
					end
				end
				return tb	
			--__mode = "v",
          end,__mode = "v"})
ConfigData = setmetatable({},{
			__index = function (t,k)
				assert(StaticConfigData[k],"DynamicConfigData")
				local tb = require (string.format("Configs.Generate.%s",k))
				rawset(t,k,tb)
				return tb
			--__mode = "v",
	     end})
