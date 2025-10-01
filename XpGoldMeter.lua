-- XpGoldOverlay.lua
local frame = CreateFrame("Frame", "XpGoldOverlay", UIParent)
frame:ClearAllPoints()
frame:SetWidth(200)
frame:SetHeight(50)
frame:SetPoint("CENTER", 0, -180)

-- Create the text
frame.text = frame:CreateFontString("Status", "LOW", "GameFontNormal")
frame.text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
frame.text:ClearAllPoints()
frame.text:SetAllPoints(frame)
frame.text:SetPoint("CENTER", 0, 0)
frame.text:SetFontObject(GameFontWhite)

-- Make it movable
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

-- Initialize tracking variables
local startXP = UnitXP("player")
local startMoney = GetMoney()
local startTime = GetTime()

-- Update the text every frame
frame:SetScript("OnUpdate", function()
    local elapsed = GetTime() - startTime
    if elapsed <= 0 then elapsed = 1 end -- avoid div/0

    local currentXP = UnitXP("player")
    local currentMoney = GetMoney()

    local xpGained = currentXP - startXP
    local moneyGained = currentMoney - startMoney

    local xpPerHour = xpGained / elapsed * 3600
    local moneyPerHour = moneyGained / elapsed * 3600

    local gold = floor(moneyPerHour / 10000)
    local silver = floor((moneyPerHour % 10000) / 100)
    local copper = floor(moneyPerHour % 100)

    frame.text:SetText(string.format("XP/hr: %.0f  Gold/hr: %dG %dS %dC", xpPerHour, gold, silver, copper))
end)

-- Print loaded message
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function()
    print("|cff33ff99XpGoldOverlay loaded!|r")
end)
