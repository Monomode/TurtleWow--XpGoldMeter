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
-- Update every frame
frame:SetScript("OnUpdate", function()
    local elapsedTime = time() - startTime
    if elapsedTime <= 0 then elapsedTime = 1 end

    -- XP tracking
    local gainedXP   = UnitXP("player") - startXP
    local xpPerHour  = (gainedXP / elapsedTime) * 3600

    -- Gold tracking (copper → gold)
    local gainedGold = (GetMoney() - startGold) / 10000
    local goldPerHour = (gainedGold / elapsedTime) * 3600

    this.text:SetText(string.format("XP/hour: %.0f\nGold/hour: %.2f", xpPerHour, goldPerHour))
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
