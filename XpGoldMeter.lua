-- Session tracking
local startXP   = UnitXP("player")
local startGold = GetMoney()
local startTime = time()

-- Reset function
local function ResetSession()
    startXP   = UnitXP("player")
    startGold = GetMoney()
    startTime = time()
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldMeter: Session reset!|r")
end

-- Create frame
local frame = CreateFrame("Frame", "XpGoldOverlay", UIParent)
frame:SetWidth(160)
frame:SetHeight(40)
frame:SetPoint("CENTER", 0, -205)

-- Font string
frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
frame.text:SetAllPoints(frame)

-- Update loop
frame:SetScript("OnUpdate", function()
    local elapsedTime = time() - startTime
    if elapsedTime <= 0 then elapsedTime = 1 end

    local gainedXP   = UnitXP("player") - startXP
    local gainedGold = (GetMoney() - startGold) / 10000

    -- Start rates at 0 until gains happen
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
    msg = msg or ""  -- make sure msg is not nil
    if msg:lower() == "reset" then
        ResetSession()
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldMeter:|r Use /xpgold reset to reset XP & Gold tracking.")
    end
end

-- Confirmation
DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldMeter loaded!|r")
