-- Session tracking
local startXP = UnitXP("player")
local startGold = GetMoney()
local startTime = time()

local frame = CreateFrame("Frame", "XpGoldOverlay", UIParent)
frame:ClearAllPoints()
frame:SetWidth(115)
frame:SetHeight(25)
frame:SetPoint("CENTER", 0, -205)
frame.text = frame:CreateFontString("Status", "LOW", "GameFontNormal")
frame.text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
frame.text:ClearAllPoints()
frame.text:SetAllPoints(frame)
frame.text:SetPoint("CENTER", 0, 0)
frame.text:SetFontObject(GameFontWhite)
frame:SetScript("OnUpdate", function(self, elapsed)
    local currentXP = UnitXP("player") - startXP
    local currentGold = (GetMoney() - startGold) / 10000
    local elapsedTime = time() - startTime
    if elapsedTime <= 0 then elapsedTime = 1 end

    local xpPerHour = (currentXP / elapsedTime) * 3600
    self.text:SetText(string.format("XP/hour: %.0f\nGold: %.2f", xpPerHour, currentGold))
end)

frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetScript("OnMouseDown",function()
  this:StartMoving()
end)

frame:SetScript("OnMouseUp",function()
  this:StopMovingOrSizing()
  this:SetUserPlaced(true)
end)

-- Simple print to chat to confirm AddOn is loaded
print("|cff33ff99XpGoldMeter loaded!|r")
