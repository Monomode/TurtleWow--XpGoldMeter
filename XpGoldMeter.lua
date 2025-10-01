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

-- Create a frame to handle events
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(self, event)
    startXP = UnitXP("player")
    startMoney = GetMoney()
    startTime = GetTime()

    -- Loaded message
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldOverlay loaded!|r")
end)

-- Update overlay every frame
overlayFrame:SetScript("OnUpdate", function()
    if startTime == 0 then return end -- wait until login event initializes

    local elapsed = GetTime() - startTime
    if elapsed <= 0 then elapsed = 1 end

    local xpGained = UnitXP("player") - startXP
    local moneyGained = GetMoney() - startMoney

    local xpPerHour = xpGained / elapsed * 3600
    local moneyPerHour = moneyGained / elapsed * 3600

    local gold = floor(moneyPerHour / 10000)
    local silver = floor((moneyPerHour % 10000) / 100)
    local copper = floor(moneyPerHour % 100)

    overlayFrame.text:SetText(string.format("XP/hr: %.0f  Gold/hr: %dG %dS %dC", xpPerHour, gold, silver, copper))
end)
