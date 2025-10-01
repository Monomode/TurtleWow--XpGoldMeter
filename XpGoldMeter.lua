-- XpGoldMeter.lua
local frame = CreateFrame("Frame", "XpGoldMeterFrame", UIParent)
frame:SetSize(200, 60)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})

-- Font strings
local xpText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
xpText:SetPoint("TOP", frame, "TOP", 0, -10)
local goldText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
goldText:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)

-- Session tracking
local sessionXP = 0
local sessionMoney = 0
local startTime = 0

local function UpdateDisplay()
    local elapsed = math.max(GetTime() - startTime, 1)
    local xpPerHour = sessionXP / elapsed * 3600
    local moneyPerHour = sessionMoney / elapsed * 3600

    xpText:SetText(string.format("XP/hr: %.0f | Session: %d", xpPerHour, sessionXP))
    goldText:SetText(string.format("Gold/hr: %.2f | Session: %.2f", moneyPerHour/10000, sessionMoney/10000))
end

-- Event handling
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_XP_UPDATE")
eventFrame:RegisterEvent("PLAYER_MONEY")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
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

-- Slash command
SLASH_XPGOLD1 = "/xpgold"
SlashCmdList["XPGOLD"] = function(msg)
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end
