-- XpGoldOverlay.lua

-- Global frame to prevent garbage collection
XpGoldOverlay = CreateFrame("Frame", "XpGoldOverlay", UIParent)
XpGoldOverlay:SetSize(200, 50)
XpGoldOverlay:SetPoint("CENTER", UIParent, "CENTER", 0, -180)

-- Font string
XpGoldOverlay.text = XpGoldOverlay:CreateFontString(nil, "OVERLAY", "GameFontNormal")
XpGoldOverlay.text:SetAllPoints()
XpGoldOverlay.text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
XpGoldOverlay.text:SetFontObject(GameFontWhite)
XpGoldOverlay.text:SetText("Initializing...")

-- Make movable
XpGoldOverlay:SetMovable(true)
XpGoldOverlay:EnableMouse(true)
XpGoldOverlay:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and IsControlKeyDown() then
        self:StartMoving()
    end
end)
XpGoldOverlay:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
        self:StopMovingOrSizing()
        self:SetUserPlaced(true)
    end
end)

-- Tracking variables
local startXP, startMoney, startTime = 0, 0, 0

-- Event frame
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function(self, event)
    startXP = UnitXP("player") or 0
    startMoney = GetMoney() or 0
    startTime = GetTime()

    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldOverlay loaded!|r")

    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)

-- OnUpdate: update overlay
XpGoldOverlay:SetScript("OnUpdate", function(self, elapsed)
    if startTime == 0 then return end

    local now = GetTime()
    local elapsedTime = now - startTime
    if elapsedTime <= 0 then elapsedTime = 1 end

    local xpGained = (UnitXP("player") or 0) - startXP
    local moneyGained = (GetMoney() or 0) - startMoney

    local xpPerHour = xpGained / elapsedTime * 3600
    local moneyPerHour = moneyGained / elapsedTime * 3600

    local gold = floor(moneyPerHour / 10000)
    local silver = floor((moneyPerHour % 10000) / 100)
    local copper = floor(moneyPerHour % 100)

    self.text:SetText(string.format(
        "XP/hr: %.0f\nGold/hr: %dG %dS %dC",
        xpPerHour, gold, silver, copper
    ))
end)
