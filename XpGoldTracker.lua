-- XP & Gold Tracker (Turtle WoW / Vanilla 1.12 compatible)
-- Tracks XP/hour and Gold/hour

-- Session tracking
local startXP   = UnitXP("player")
local startGold = GetMoney()
local startTime = time()

-- Track last XP to detect increases only
local lastXP        = startXP
local totalGainedXP = 0

-- Reset function
local function ResetSession()
    startXP        = UnitXP("player")
    startGold      = GetMoney()
    startTime      = time()
    lastXP         = startXP
    totalGainedXP  = 0
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldTracker: Session reset!|r")
end

-- Create frame
local frame = CreateFrame("Frame", "XpGoldOverlay", UIParent)
frame:SetWidth(180)
frame:SetHeight(75)
frame:SetPoint("CENTER", 0, -220)

-- Font string
frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
frame.text:SetAllPoints(frame)

-- Update loop
frame:SetScript("OnUpdate", function()
    local currentXP   = UnitXP("player")
    local currentGold = GetMoney()
    local elapsedTime = time() - startTime
    if elapsedTime <= 0 then elapsedTime = 1 end

    -- XP gain logic (ignore negative changes)
    local diff = currentXP - lastXP
    if diff > 0 then
        totalGainedXP = totalGainedXP + diff
    end
    lastXP = currentXP

    -- Gold gain (may go up or down — down is fine to track)
    local gainedGold = (currentGold - startGold) / 10000  -- copper → gold

    -- Rates
    local xpPerHour   = (totalGainedXP / elapsedTime) * 3600
    local goldPerHour = (gainedGold / elapsedTime) * 3600

    -- Time format
    local hours   = math.floor(elapsedTime / 3600)
    local minutes = math.floor((elapsedTime % 3600) / 60)
    local seconds = math.floor(elapsedTime % 60)
    local timeString = string.format("%02d:%02d:%02d", hours, minutes, seconds)

    -- Display
    frame.text:SetText(string.format(
        "XP/hour: %.0f\nGold/hour: %.2f\nTotal XP: %d\nTotal Gold: %.2f\nTime: %s",
        xpPerHour, goldPerHour, totalGainedXP, gainedGold, timeString
    ))
end)

-- Draggable frame
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetScript("OnMouseDown", function() frame:StartMoving() end)
frame:SetScript("OnMouseUp", function() frame:StopMovingOrSizing(); frame:SetUserPlaced(true) end)

-- Slash command
SLASH_XPGOLD1 = "/xpgold"
SlashCmdList["XPGOLD"] = function(msg)
    msg = string.lower(msg or "")
    if msg == "reset" then
        ResetSession()
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldTracker:|r Use /xpgold reset to reset the session.")
    end
end

DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldTracker loaded!|r")
