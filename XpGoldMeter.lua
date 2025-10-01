-- XpGoldOverlay.lua
local frame = CreateFrame("Frame", "XpGoldOverlayFrame", UIParent)
frame:SetSize(200, 40)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
frame:Show()

-- Background
frame.bg = frame:CreateTexture(nil, "BACKGROUND")
frame.bg:SetAllPoints(frame)
frame.bg:SetColorTexture(0, 0, 0, 0.5)

-- Text
frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.text:SetAllPoints(frame)
frame.text:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
frame.text:SetJustifyH("CENTER")
frame.text:SetText("XP/hr: 0  Gold/hr: 0")

-- Session variables
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
        print("|cff33ff99XpGoldOverlay loaded!|r")
        UpdateDisplay()
    elseif event == "PLAYER_XP_UPDATE" then
        sessionXP = UnitXP("player") or sessionXP
        UpdateDisplay()
    elseif event == "PLAYER_MONEY" then
        sessionMoney = GetMoney() or sessionMoney
        UpdateDisplay()
    end
end)

-- Movable overlay
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

-- Slash command to toggle
SLASH_XPGOLD1 = "/xpgold"
SlashCmdList["XPGOLD"] = function(msg)
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end
