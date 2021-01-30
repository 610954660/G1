
-- added by zn
-- 问卷调查

local TimeLib = require "Game.Utils.TimeLib";
local ActivityMap = require "Game.Modules.Activity.ActivityMap"
local QuesSurveyView, Super = class("QuesSurveyView", Window);

function QuesSurveyView:ctor()
    self._packName = "QuestionnaireSurvey";
    self._compName = "QuesSurveyView";
    self.btn_next = false;
    self.btn_getAward = false;
    self.btn_start = false;
    self.list_ques = false;
    self.list_quesCell = {};
    self.txt_quesTitle = false;
    self.txt_input = false;
    self.bg_paper = false;
    self.txt_countDown = false;
    self.list_award = false;
    self.timer = false;
    self.selectionType = false; -- 1 单选 2 多选
end

function QuesSurveyView:_initUI()
    self.bg_paper = self.view:getChild("bg_paper");
    self.bg_paper:setIcon(PathConfiger.getBg("quesSurvey_paper.png"));

    self.txt_countDown = self.view:getChild("txt_countdown");
    local times = QuesSurveyModel.endTime - ServerTimeModel:getServerTime();
    if (times > 0) then
        local function formatTime(_time)
            -- 报错兼容
            if ((tolua.isnull(self.txt_countDown)) or (not self.txt_countDown.setText)) then
                if (self.timer) then
                    TimeLib.clearCountDown(self.timer);
                    self.timer = false;
                end
                return;
            end
            if (_time > 3600 * 24) then
                self.txt_countDown:setText(StringUtil.formatTime(_time, "d", Desc.common_TimeDesc))
            else
                self.txt_countDown:setText(StringUtil.formatTime(_time, "h", Desc.common_TimeDesc2))
            end
        end
        formatTime(times);
        -- 开倒计时
        self.timer = TimeLib.newCountDown(times, function (time)
            formatTime(time);
        end, function ()
            self.txt_countDown:setText(Desc.common_txt2)
        end, false, false, false);
    else 
        self.txt_countDown:setText(Desc.common_txt2);
    end

    self.btn_next = self.view:getChild("btn_next");
    self.btn_getAward = self.view:getChild("btn_getAward");
    self.btn_start = self.view:getChild("btn_start");
    self.txt_quesTitle = self.view:getChild("txt_quesTitle");
    self.txt_input = self.view:getChild("txt_input");
    

    self.list_ques = self.view:getChild("list_ques");
    self.list_ques:setItemRenderer(function (idx, obj)
        self.list_quesCell[idx + 1] = obj;
    end)

    self.list_award = self.view:getChild("list_award");
    self.list_award:setVirtual();
    self.list_award:setItemRenderer(function (idx, obj)
        local data = QuesSurveyModel.reward[idx + 1];
        local cell = BindManager.bindItemCell(obj);
        cell:setData(data.code, data.amount, data.type);
    end)
    if (QuesSurveyModel.reward) then
        self.list_award:setNumItems(#QuesSurveyModel.reward);
    end

    self:upBtnStatus();
end

function QuesSurveyView:_initEvent()
    self.btn_start:addClickListener(function ()
        if (QuesSurveyModel.endTime < ServerTimeModel:getServerTime()) then
            RollTips.show(Desc.common_txt3);
            return;
        end
        self.view:getController("c2"):setSelectedIndex(1);
        self:showQuestion();
    end)

    self.btn_next:addClickListener(function ()
        if self:saveInputText() then
            QuesSurveyModel:nextQues();
        end
    end)

    self.btn_getAward:addClickListener(function ()
        if (self:saveInputText() and not QuesSurveyModel.answerList or not QuesSurveyModel.answerList[QuesSurveyModel.curQuestion]) then
            if (not QuesSurveyModel:nextQues()) then
                return;
            end
        end

        RPCReq.Activity_QuestionnaireSurvey_GetQuesReward({}, function ()
            local data = {
                show = 1,
                reward = QuesSurveyModel.reward
            }
            ViewManager.open("AwardShowView",data);
            ViewManager.close("QuesSurveyView");
            ViewManager.close(ActivityMap.ActivityFrame[QuesSurveyView.mainActiveId]);
        end);
        
    end)
end

-- 更新题目显示
function QuesSurveyView:QuestionnaireSurvey_upData()
    self:upBtnStatus();
end

-- 切换按钮的显示
function QuesSurveyView: upBtnStatus()
    local isFinal = QuesSurveyModel:isFinalQues();
    local ctrl = self.view:getController("c2");
    if (not QuesSurveyModel.answerList or #QuesSurveyModel.answerList == 0) then
        ctrl:setSelectedIndex(0);
        return;
    elseif QuesSurveyModel.rewardStatus then
        ctrl:setSelectedIndex(3);
    elseif (isFinal == true) then
        ctrl:setSelectedIndex(2);
    else
        ctrl:setSelectedIndex(1);
    end
    self:showQuestion();
end

function QuesSurveyView:showQuestion()
    local ctrl = self.view:getController("c1")
    local data = QuesSurveyModel:getCurQues();
    QuesSurveyModel:resetSelected();
    local quesType, ctrlIdx = QuesSurveyModel:getQuesType();
    ctrl:setSelectedIndex(ctrlIdx);

    -- 题目
    self.txt_quesTitle:setText(QuesSurveyModel:getQuesTitle());

    -- 选项
    if (quesType == 1) then -- 单选
        local length = data.needExtra == 1 and (#data.allAnswer + 1) or #data.allAnswer;
        self.selectionType = data.numMax > 1 and 2 or 1;
        self.list_ques:clearSelection();
        self.list_quesCell = {};
        self.list_ques:setNumItems(length);
        for idx in ipairs(self.list_quesCell) do
            if idx <= #data.allAnswer then
                self:upQuesCell(idx, data.allAnswer[idx].answer);
            else
                self:upQuesCell(idx, data.content_text, true);
            end
        end
    elseif (quesType == 2) then -- 问答
        self.txt_input:setText("");
        local num = data.charNum == 0 and 999 or data.charNum
        self.txt_input:setMaxLength(num);
    end
end

-- 更新选项
function QuesSurveyView:upQuesCell(idx, quesStr, showInput)
    showInput = showInput == nil and false or showInput;
    
    local cell = self.list_quesCell[idx];
    local ctrl = cell:getController("c1");
    local check = cell:getChild("check");
    local btnCtrl = check:getController('button');
    btnCtrl:setSelectedIndex(0);
    local txt_desc = false;
    if (not showInput) then
        ctrl:setSelectedIndex(0);
        txt_desc = cell:getChild("txt_desc");
    else
        ctrl:setSelectedIndex(1);
        txt_desc = cell:getChild("txt_inputdesc");
    end
    txt_desc:setText(quesStr);
    local size = txt_desc:displayObject():getContentSize()
    local height = size.height + 12;
    if (txt_desc:getText() == "") then
        height = height + 29;
    end
    cell:setHeight(height);
    check:setHeight(height);
    check:setWidth(txt_desc:displayObject():getPositionX() + size.width);
    local input = cell:getChild("txt_input")
    input:setText("");

    check:removeClickListener();
    cell:removeClickListener();
    check:addClickListener(function ()
        if (self.selectionType == 1) then -- 单选
            if (QuesSurveyModel:select(idx)) then
                self.list_ques:setSelectedIndex(idx - 1);
                -- self.list_ques:addSelection(idx - 1, false);
            end
        else -- 多选
            if (QuesSurveyModel:isSelected(idx)) then
                QuesSurveyModel:unselect(idx);
                self.list_ques:removeSelection(idx - 1);
            elseif (QuesSurveyModel:select(idx)) then
                self.list_ques:addSelection(idx - 1, false);
            end
        end
    end);
end

function QuesSurveyView:saveInputText()
    local data = QuesSurveyModel:getCurQues();
    local quesType = QuesSurveyModel:getQuesType();
    local txt = false;
    if (quesType == 1) then -- 单选
        local length = data.needExtra == 1 and (#data.allAnswer + 1) or #data.allAnswer;
        local cell = self.list_quesCell[length];
        if (data.needExtra == 1 and cell:getChild("check"):getController('button'):getSelectedIndex() == 1) then
            txt = cell:getChild("txt_input"):getText();
            if (txt == "") then
                RollTips.show(Desc.quesSurvey_empty);
                return false;
            elseif (string.find(txt, " ", 1) ~= nil) then
                RollTips.show(Desc.quesSurvey_haveEmpty);
                return false;
            end
        end
    elseif (quesType == 2) then -- 问答
        txt = self.txt_input:getText();
    end
    QuesSurveyModel.content_txt = txt;
    return true;
    -- LuaLogE("===================================== 答题文本", txt);
end

function QuesSurveyView:__onExit()
    if (self.timer) then
        TimeLib.clearCountDown(self.timer);
        self.timer = false;
    end
    Super.__onExit(self);
end

return QuesSurveyView;