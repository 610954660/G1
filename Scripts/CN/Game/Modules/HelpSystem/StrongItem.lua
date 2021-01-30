

local StrongItem, Super = class("StrongItem", BindView);

-- type 0 我要变强 1 常见问题 2 推荐阵容
function StrongItem:ctor(view, type)
    self.type = type;

    self.baseHeight = false;
    self.alpha = false;

    self.strongTitle = false;
    self.strongIcon = false;

    self.txt_title = false;
    self.txt_desc = false;
    self.txt_teamName = false;
    self.loader_strongIcon = false;
    self.progressBar = false;
    self.list_hero = false;
    self.list_heroItem = {};
    self.txt_count =false
    self.txt_changjiandesc = false
    self.btn_goto = false;
    self.btn_open = false;
end

function StrongItem:_initUI()
    self.baseHeight = self.view:getChild("base"):getHeight();
    self.alpha = self.view:getChild("alpha");
    self.txt_count = self.view:getChild("txt_count"); 
    self.txt_changjiandesc = self.view:getChild("txt_changjiandesc"); 
    self.txt_title = self.view:getChild("Title");
    self.txt_desc = self.view:getChild("desc");
    self.txt_teamName = self.view:getChild("teamName");

    self.strongTitle = self.view:getChild("strongTitle");
    self.strongIcon = self.view:getChild("strongIcon");

    self.loader_strongIcon = self.view:getChild("strongIcon");
    self.progressBar = self.view:getChild("prog");
    self.btn_goto = self.view:getChild("btn_goto");
    self.btn_open = self.view:getChild("btn_open");

    self.list_hero = self.view:getChild("list_hero");

    local ctrl1 = self.view:getController("c1");
    ctrl1:setSelectedIndex(self.type);
    local ctrl2 = self.view:getController("c2");
    ctrl2:setSelectedIndex(0);
    self.view:setHeight(self.baseHeight);
end

function StrongItem:_initEvent()
    -- 点击展开
    self.btn_open:addClickListener(function ()
        local ctrl = self.view:getController("c2");
        if (ctrl:getSelectedIndex() == 0) then
            self.view:setHeight(self.alpha:getHeight());
        else
            self.view:setHeight(self.baseHeight);
        end
        ctrl:setSelectedIndex(1 - ctrl:getSelectedIndex());
    end)

    -- 推荐阵容英雄列表
    self.list_hero:setItemRenderer(function (idx, obj)
        self.list_heroItem[idx + 1] = BindManager.bindCardCell(obj);
    end)
end

function StrongItem:setIndex(idx)
    if (self.type == 0) then
        self:initWithStrong(idx);
    elseif (self.type == 1) then
        self:initWithQuestion(idx);
    elseif (self.type == 2) then
        self:initWithRecom(idx);
    end
end

-- 我要变强
function StrongItem:initWithStrong(idx)
    local conf = DynamicConfigData.t_Stronger[idx];
    if (conf) then
        self.strongTitle:setText(conf.name);
        self.strongIcon:setIcon(PathConfiger.getStronger(conf.icon));
        self.txt_title:setText(conf.desr);
        local min, max = 0, 0;
        if (idx == 1) then
            min, max = HelpSystemModel:getHeroSelfAndMaxByType("level");
        elseif (idx == 2) then
            min, max = HelpSystemModel:getHeroSelfAndMaxByType("stage");
        elseif (idx == 3) then
            min, max = HelpSystemModel:getHeroSelfAndMaxByType("star");
        elseif (idx == 4) then
            min, max = HelpSystemModel:getHeroSelfAndMaxByType("passiveSkill");
        elseif (idx == 5) then
            min, max = HelpSystemModel:getHeroSelfAndMaxByType("equip");
        elseif (idx == 6) then
            min, max = HelpSystemModel:getHeroSelfAndMaxByType("guildSkill");
        elseif (idx == 7) then
            min, max = HelpSystemModel:getHeroSelfAndMaxByType("rune");
        end
        self.progressBar:setValue(min);
        self.progressBar:setMax(max);
        self.btn_goto:removeClickListener(22);
        self.btn_goto:addClickListener(function ()
            if (conf.module == 17 or conf.module == 52 or conf.module == 14 or conf.module == 15) then -- 跳转特性特殊处理
                -- ModelManager.CardLibModel:setCardsByCategory(0)
                local heroInfo = HelpSystemModel.myHeroList[HelpSystemModel.selected]
                -- printTable(1, heroInfo);
                -- ModelManager.CardLibModel.curCardStepInfo = heroInfo
               -- ModelManager.CardLibModel.curCardStepInfo = ModelManager.CardLibModel:getHeroByUid(heroInfo.uuid)
			    ModelManager.CardLibModel:setChooseUid(heroInfo.uuid)
				-- ModelManager.CardLibModel:setCarByPosInfo(heroInfo.code,heroInfo.uuid, HelpSystemModel.selected);
            end
            if (conf.module == ModuleId.Guild_Skill.id and not GuildModel.guildHave) then
                ModuleUtil.openModule(ModuleId.Guild, true);
                return;
            end
            ModuleUtil.openModule(conf.module, true);
        end, 22)
    end
end

-- 常见问题
function StrongItem:initWithQuestion(idx)
    local conf = DynamicConfigData.t_Problem[idx];
    if (conf) then
        self.txt_changjiandesc:setText(conf.title);
        self.txt_count:setText(idx);
        self.txt_desc:setText(conf.desr);
    end
end

-- 推荐
function StrongItem:initWithRecom(idx)
    local conf = DynamicConfigData.t_BattleArray[idx];
    if (conf) then
        self.txt_teamName:setText(conf.name);
        self.txt_desc:setText(conf.desr);
        local arr = {};
        for i = 1, 6 do
            local d = conf["array"..i];
            if (type(d) == "number" and d > 0) then
                arr[d] = {idx = i, code = d};
            end
        end
        -- 展示英雄图鉴配置
        local heroList = {};
        for _, heroArr in pairs(DynamicConfigData.t_HeroTotems) do
            for _, d in pairs(heroArr) do
                local c = arr[d.hero]
                if (c) then
                    heroList[c.idx] = d;
                end
            end
        end
        self.list_hero:setNumItems(#heroList);
        for idx, val in ipairs(heroList) do
            local item = self.list_heroItem[idx]
            item:setData(val.hero, true);
            item:setLevel(-1)
            item.view:removeClickListener();
            item.view:addClickListener(function ()
                local info = {index = idx,heroId = val.hero,heroList = heroList};
                ViewManager.open("HeroInfoView", info);
            end)
        end
    end
end

return StrongItem;