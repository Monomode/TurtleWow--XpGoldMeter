-- Session tracking
local startXP = UnitXP("player")
local startGold = GetMoney()
local startTime = time()
local elapsed = time() - startTime
if elapsed <= 0 then elapsed = 1 end

-- XP/hr
local gainedXP = UnitXP("player") - startXP
local xpPerHour = (gainedXP / elapsed) * 3600

-- Gold/hr
local gainedGold = GetMoney() - startGold
local gold = floor(gainedGold / 10000)

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
frame:SetScript("OnUpdate", function()
  this.text:SetText("XP/hour: \nGold: ")
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
