-- XpGoldOverlay.lua
local overlayFrame = CreateFrame("Frame", "XpGoldOverlay", UIParent)
overlayFrame:SetSize(200, 50)
overlayFrame:SetPoint("CENTER", 0, -180)

overlayFrame.text = overlayFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
overlayFrame.text:SetAllPoints()
overlayFrame.text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
overlayFrame.text:SetFontObject(GameFontWhite)

overlayFrame:SetMovable(true)
overlayFrame:EnableMouse(true)
overlayFrame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and IsControlKeyDown() then
        self:StartMoving()
    end
end)
overlayFrame:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
        self:StopMovingOrSizing()
        self:SetUserPlaced(true)
    end
end)

-- Tracking variables
local startXP, startMoney, startTime = 0, 0, 0

-- Use a persistent frame for events
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function(self, event)
    -- Initialize tracking
    startXP = UnitXP("player") or 0
    startMoney = GetMoney() or 0
    startTime = GetTime()

    -- Loaded message (guaranteed to appear)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldOverlay loaded!|r")

    -- Unregister the event so it only runs once
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)

-- Update overlay every frame
overlayFrame:SetScript("OnUpdate", function(self, elapsed)
    if startTime == 0 then return end -- wait until login event initializes

    local currentTime = GetTime()
    local elapsedTime = currentTime - startTime
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
