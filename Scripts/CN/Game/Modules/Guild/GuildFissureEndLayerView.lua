local GuildFissureEndLayerView, Super = class("GuildFissureEndLayerView", Window)
local ItemCell = require "Game.UI.Global.ItemCell"

function GuildFissureEndLayerView:ctor()
    self._packName = "Guild"
    self._compName = "GuildFissureEndLayerView"

    self._rootDepth = LayerDepth.Window
    self.txt_limitcount = false
    self.pg_exp = false
    self.img_box = false
    self.list_reward = false
    self.com_moveItem = false
    self.img_reward=false
 
    self.curBoxIdex = 1
    self.updateTimeId = false
    self.com_moveItemPos = false
    self.animationState = false
end

function GuildFissureEndLayerView:_initUI()
 
    self.progressBar = self.view:getChildAutoType("progressBar")
    self.bossLoder = self.view:getChildAutoType("bossLoder")
    self.txt1 = self.view:getChildAutoType("txt1")
    self.dwLoader = self.view:getChildAutoType("dwLoader")
    self.dwtxt = self.view:getChildAutoType("dwtxt")
    self.txt2 = self.view:getChildAutoType("txt2")
    self.txt3 = self.view:getChildAutoType("txt3")
    self.isNewCtrl = self.view:getController("isNewCtrl")
    self.hertCtrl = self.view:getController("hertCtrl")
    self.fightVal = self.view:getChildAutoType("fightVal")
    self:initInfo()
end

function GuildFissureEndLayerView:initInfo()
   -- printTable(1,"self._args.data",self._args.data)
   local info= self._args.data;
   local bossData= GuildModel:getCylfBossData()
   printTable(1,bossData)
   local rankLevel = 0
   local maxDamage = 0
   if not info.rankLevel then --如果没有下发段位 从以前数据拿
      rankLevel = bossData.rankLevel
   else
      rankLevel =  info.rankLevel 
   end
   if info.damage > bossData.maxDamage then --伤害比之前高
       self.isNewCtrl:setSelectedIndex(1)
       maxDamage = info.damage
   else
    self.isNewCtrl:setSelectedIndex(0)
     maxDamage = bossData.maxDamage
   end
   local nextRankDamage = 0
   if info.nextRankDamage then
      nextRankDamage = info.nextRankDamage
   else
    nextRankDamage = bossData.nextRankDamage
   end
   local bossHp = 0
   local fightValArr =  GuildModel:getFightSceenNeed(  )
   for i=1,#fightValArr do
      if info.damage <=fightValArr[i] then
        bossHp = fightValArr[i]
        break
      end
   end
   self.progressBar:setMax(bossHp)
   self.progressBar:setValue(info.damage)
   self.fightVal:setText(info.damage)
   self.bossLoder:setURL(PathConfiger.getBossHead(info.bossConfig.bossHead))
   --本轮最高输出
   self.txt1:setText(maxDamage)
   if rankLevel <=0 then
    self.hertCtrl:setSelectedIndex(1)
   else
       self.hertCtrl:setSelectedIndex(0)
       local url = PathConfiger.getBossDw(rankLevel)
       self.dwLoader:setURL(url)

       local rankConfig = GuildModel:getBossRankConfigByIndexs(bossData.levelId,rankLevel )
       self.dwtxt:setText(rankConfig.rankName)
       --输出达到
       local str = string.format(Desc.guild_checkStr39,nextRankDamage)
       self.txt2:setText(str)
       --可晋升
        if rankLevel==1 then
            rankLevel = 1
            local str = string.format(Desc.guild_checkStr36,info.rankNum)
            self.txt2:setText(str)
            self.txt3:setText("")
        else
           rankLevel = rankLevel - 1
           local nextRankConfig = GuildModel:getBossRankConfigByIndexs(bossData.levelId,rankLevel )
           str = string.format(Desc.guild_checkStr40,nextRankConfig.rankName)
           self.txt3:setText(str)
        end
   end

end



function GuildFissureEndLayerView:_initEvent(...)
end

function GuildFissureEndLayerView:_exit()

end

return GuildFissureEndLayerView
