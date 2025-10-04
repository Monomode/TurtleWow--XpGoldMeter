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
frame:SetPoint("CENTER", 0, -220)

-- Font string
frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
frame.text:SetAllPoints(frame)

-- Update loop
frame:SetScript("OnUpdate", function()
    local elapsedTime = time() - startTime

    local gainedXP   = UnitXP("player") - startXP
    local gainedGold = (GetMoney() - startGold) / 10000  -- gold in gold units

    -- Show 0 if nothing gained or too early
    if elapsedTime < 1 or (gainedXP <= 0 and gainedGold <= 0) then
        frame.text:SetText("XP/hour: 0\nGold/hour: 0\nTotal XP: 0\nTotal Gold: 0")
        return
    end

    -- Calculate rates
    local xpPerHour   = (gainedXP > 0) and (gainedXP / elapsedTime * 3600) or 0
    local goldPerHour = (gainedGold > 0) and (gainedGold / elapsedTime * 3600) or 0

    local hours   = math.floor(elapsedTime / 3600)
    local minutes = math.floor((elapsedTime % 3600) / 60)
    local seconds = elapsedTime % 60
    local timeStr = string.format("%02d:%02d:%02d", hours, minutes, seconds)

    -- Display per-hour rates and total gained
    frame.text:SetText(string.format(
        "XP/hour: %.0f\nGold/hour: %.2f\nTotal XP: %d\nTotal Gold: %.2f\nTime: %s",
        xpPerHour, goldPerHour, gainedXP, gainedGold, elapsedTime
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
