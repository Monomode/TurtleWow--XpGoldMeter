-- Session tracking
local startXP   = UnitXP("player")
local startGold = GetMoney()
local startTime = time()

-- Reset function
local function ResetSession()
    startXP    = UnitXP("player")
    startGold  = GetMoney()
    startLevel = UnitLevel("player")   -- Reset start level as well
    startTime  = time()
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldTracker: Session reset!|r")
end

-- Create frame
local frame = CreateFrame("Frame", "XpGoldOverlay", UIParent)
frame:SetWidth(180)
frame:SetHeight(50)
frame:SetPoint("CENTER", 0, -205)

-- Font string
frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
frame.text:SetAllPoints(frame)

-- Update loop
frame:SetScript("OnUpdate", function()
    local elapsedTime = time() - startTime

    -- XP calculation across levels
    local currentXP = UnitXP("player")
    local maxXP     = UnitXPMax("player")
    local levelDiff = UnitLevel("player") - startLevel
    local gainedXP  = (levelDiff * maxXP) + (currentXP - startXP)

    -- Gold calculation
    local gainedGold = (GetMoney() - startGold) / 10000

    if elapsedTime < 1 or (gainedXP <= 0 and gainedGold <= 0) then
        frame.text:SetText("XP/hour: 0\nGold/hour: 0\nTotal XP: 0\nTotal Gold: 0")
        return
    end

    local xpPerHour   = (gainedXP > 0) and (gainedXP / elapsedTime * 3600) or 0
    local goldPerHour = (gainedGold ~= 0) and (gainedGold / elapsedTime * 3600) or 0

    frame.text:SetText(string.format(
        "XP/hour: %.0f\nGold/hour: %.2f\nTotal XP: %d\nTotal Gold: %.2f",
        xpPerHour, goldPerHour, gainedXP, gainedGold
    ))
end)

-- Draggable frame
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetScript("OnMouseDown", function() frame:StartMoving() end)
frame:SetScript("OnMouseUp", function() frame:StopMovingOrSizing(); frame:SetUserPlaced(true) end)

-- Slash command to reset session
SLASH_XPGOLD1 = "/xpgold"
SlashCmdList["XPGOLD"] = function(msg)
    msg = msg or ""
    if string.lower(msg) == "reset" then
        ResetSession()
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldMeter:|r Use /xpgold reset to reset XP & Gold tracking.")
    end
end

-- Confirmation
DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldMeter loaded!|r")
