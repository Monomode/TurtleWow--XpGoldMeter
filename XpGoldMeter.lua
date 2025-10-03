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
frame.text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")-- Session tracking
local startXP   = UnitXP("player")
local startGold = GetMoney()
local startTime = time()

-- Reset function
local function ResetSession()
    startXP   = UnitXP("player")
    startGold = GetMoney()
    startTime = time()
    print("|cff33ff99XpGoldMeter: Session reset!|r")
end

-- Frame
local frame = CreateFrame("Frame", "XpGoldOverlay", UIParent)
frame:SetWidth(140)
frame:SetHeight(40)
frame:SetPoint("CENTER", 0, -205)

frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
frame.text:SetAllPoints(frame)

-- Update loop
frame:SetScript("OnUpdate", function()
    local elapsedTime = time() - startTime
    if elapsedTime <= 0 then elapsedTime = 1 end

    local gainedXP   = UnitXP("player") - startXP
    local gainedGold = (GetMoney() - startGold) / 10000

    local xpPerHour = 0
    local goldPerHour = 0
    if gainedXP > 0 then
        xpPerHour = (gainedXP / elapsedTime) * 3600
    end
    if gainedGold > 0 then
        goldPerHour = (gainedGold / elapsedTime) * 3600
    end

    this.text:SetText(string.format("XP/hour: %.0f\nGold/hour: %.2f", xpPerHour, goldPerHour))
end)

-- Draggable frame
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetScript("OnMouseDown", function() this:StartMoving() end)
frame:SetScript("OnMouseUp", function() this:StopMovingOrSizing(); this:SetUserPlaced(true) end)

-- Slash command to reset session
SLASH_XPGOLD1 = "/xpgold"
SlashCmdList["XPGOLD"] = function(msg)
    msg = msg:lower()
    if msg == "reset" then
        ResetSession()
    else
        print("|cff33ff99XpGoldMeter:|r Use /xpgold reset to reset XP & Gold tracking.")
    end
end

-- Confirmation
print("|cff33ff99XpGoldMeter loaded!|r")

frame.text:ClearAllPoints()
frame.text:SetAllPoints(frame)
frame.text:SetPoint("CENTER", 0, 0)
frame.text:SetFontObject(GameFontWhite)
frame:SetScript("OnUpdate", function()
    local elapsedTime = time() - startTime
    if elapsedTime <= 0 then elapsedTime = 1 end

    local gainedXP   = UnitXP("player") - startXP
    local gainedGold = (GetMoney() - startGold) / 10000

    -- Show 0 until gains happen
    if gainedXP <= 0 and gainedGold <= 0 then
        this.text:SetText("XP/hour: 0\nGold/hour: 0")
        return
    end

    local xpPerHour  = (gainedXP / elapsedTime) * 3600
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
