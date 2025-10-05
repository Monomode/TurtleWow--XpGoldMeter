-- Session tracking
local startXP   = UnitXP("player")
local lastXP    = startXP
local startGold = GetMoney()
local lastGold  = startGold
local startTime = time()
local totalGainedXP   = 0
local totalGainedGold = 0


-- Reset function
local function ResetSession()
    startXP   = UnitXP("player")
    lastXP    = startXP
    startGold = GetMoney()
    lastGold  = startGold
    startTime = time()
    totalGainedXP   = 0
    totalGainedGold = 0

    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldTracker: Session reset!|r")
end


-- Create frame
local frame = CreateFrame("Frame", "XpGoldOverlay", UIParent)
frame:SetSize(180, 75)
frame:SetPoint("CENTER", 0, -220)

-- Font string
frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
frame.text:SetAllPoints(frame)


-- Update loop
frame:SetScript("OnUpdate", function()
    local currentXP   = UnitXP("player")
    local currentGold = GetMoney()

    -- XP tracking
    if currentXP > lastXP then
        local delta = currentXP - lastXP
        totalGainedXP = totalGainedXP + delta
    elseif currentXP < lastXP then
        -- Ignore XP loss or level-up rollover
        lastXP = currentXP
    end

    -- Gold tracking
    if currentGold > lastGold then
        local goldDelta = currentGold - lastGold
        totalGainedGold = totalGainedGold + goldDelta
    end

    -- Always update references
    lastXP = currentXP
    lastGold = currentGold

    -- Time tracking
    local elapsedTime = time() - startTime
    if elapsedTime < 1 then elapsedTime = 1 end

    -- Convert copper to gold
    local totalGoldInGold = totalGainedGold / 10000

    -- Calculate rates
    local xpPerHour   = (totalGainedXP / elapsedTime) * 3600
    local goldPerHour = (totalGoldInGold / elapsedTime) * 3600

    -- Format time
    local hours   = math.floor(elapsedTime / 3600)
    local minutes = math.floor((elapsedTime % 3600) / 60)
    local seconds = elapsedTime % 60
    local timeString = string.format("%02d:%02d:%02d", hours, minutes, seconds)

    -- Display text
    frame.text:SetText(string.format(
        "XP/hour: %.0f\nGold/hour: %.2f\nTotal XP: %d\nTotal Gold: %.2f\nTime: %s",
        xpPerHour, goldPerHour, totalGainedXP, totalGoldInGold, timeString
    ))
end)


-- Draggable frame
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetScript("OnMouseDown", function() frame:StartMoving() end)
frame:SetScript("OnMouseUp", function()
    frame:StopMovingOrSizing()
    frame:SetUserPlaced(true)
end)


-- Slash command to reset session
SLASH_XPGOLD1 = "/xpgold"
SlashCmdList["XPGOLD"] = function(msg)
    msg = msg and string.lower(msg) or ""
    if msg == "reset" then
        ResetSession()
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldTracker:|r Use /xpgold reset to reset XP & Gold tracking.")
    end
end


-- Confirmation
DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldTracker loaded!|r")
