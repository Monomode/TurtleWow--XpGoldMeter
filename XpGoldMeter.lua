-- XpGoldMeter.lua
local frame = CreateFrame("Frame", "XpGoldMeterFrame", UIParent)
frame:SetWidth(200)
frame:SetHeight(50)
frame:SetPoint("CENTER", 0, 0)

-- Font strings
frame.xpText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.xpText:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
frame.xpText:SetAllPoints(frame)
frame.xpText:SetPoint("TOP", frame, "TOP", 0, -5)

frame.goldText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.goldText:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
frame.goldText:SetAllPoints(frame)
frame.goldText:SetPoint("BOTTOM", frame, "BOTTOM", 0, 5)

-- Session tracking
local sessionXP = 0
local sessionMoney = 0
local startTime = 0

-- Update display
local function UpdateDisplay()
    local elapsed = math.max(GetTime() - startTime, 1)
    local xpPerHour = sessionXP / elapsed * 3600
    local moneyPerHour = sessionMoney / elapsed * 3600

    frame.xpText:SetText(string.format("XP/hr: %.0f | Session: %d", xpPerHour, sessionXP))
    frame.goldText:SetText(string.format("Gold/hr: %.2f | Session: %.2f", moneyPerHour/10000, sessionMoney/10000))
end

-- Event frame
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_XP_UPDATE")
eventFrame:RegisterEvent("PLAYER_MONEY")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        sessionXP = UnitXP("player") or 0
        sessionMoney = GetMoney() or 0
        startTime = GetTime()
        print("|cff33ff99XpGoldMeter loaded!|r")
        UpdateDisplay()
    elseif event == "PLAYER_XP_UPDATE" then
        local newXP = UnitXP("player") or 0
        local diff = newXP - sessionXP
        if diff < 0 then diff = 0 end
        sessionXP = sessionXP + diff
        UpdateDisplay()
    elseif event == "PLAYER_MONEY" then
        local money = GetMoney() or 0
        local diff = money - sessionMoney
        if diff < 0 then diff = 0 end
        sessionMoney = sessionMoney + diff
        UpdateDisplay()
    end
end)

-- Movable frame
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and IsControlKeyDown() then
        self:StartMoving()
    end
end)

frame:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
        self:StopMovingOrSizing()
        self:SetUserPlaced(true)
    end
end)

-- Slash command
SLASH_XPGOLD1 = "/xpgold"
SlashCmdList["XPGOLD"] = function(msg)
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end
