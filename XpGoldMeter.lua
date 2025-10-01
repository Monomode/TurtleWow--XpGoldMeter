-- XpGoldMeter.lua
local frame = CreateFrame("Frame", "XpGoldMeterFrame", UIParent)
frame:SetWidth(180)
frame:SetHeight(40)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

-- Text for display
frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.text:SetAllPoints(frame)
frame.text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
frame.text:SetJustifyH("CENTER")

-- Session tracking
local sessionXP = 0
local sessionMoney = 0
local startTime = 0

-- Update function
local function UpdateDisplay()
    local elapsed = math.max(GetTime() - startTime, 1)
    local xpPerHour = sessionXP / elapsed * 3600
    local goldPerHour = sessionMoney / elapsed * 3600 / 10000
    frame.text:SetText(string.format("XP/hr: %.0f  Gold/hr: %.2f", xpPerHour, goldPerHour))
end

-- Event handling
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
        sessionXP = UnitXP("player") or sessionXP
        UpdateDisplay()
    elseif event == "PLAYER_MONEY" then
        sessionMoney = GetMoney() or sessionMoney
        UpdateDisplay()
    end
end)

-- Movable
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetScript("OnMouseDown", function(self)
    if IsControlKeyDown() then
        self:StartMoving()
    end
end)
frame:SetScript("OnMouseUp", function(self)
    self:StopMovingOrSizing()
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
