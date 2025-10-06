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
    startLevel = UnitLevel("player")
    
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

    -- XP tracking logic
    if currentXP > lastXP then
        totalGainedXP = totalGainedXP + (currentXP - lastXP)
    elseif currentXP < lastXP then
        lastXP = currentXP -- ignore negative changes (level up)
    end

    -- Gold tracking logic
    if currentGold > lastGold then
        totalGainedGold = totalGainedGold + (currentGold - lastGold)
    elseif currentGold < lastGold then
        lastGold = currentGold -- ignore decreases
    end

    -- Always update references
    lastXP = currentXP
    lastGold = currentGold

    -- Time
    local elapsedTime = time() - startTime
    if elapsedTime < 1 then elapsedTime = 1 end

    -- Convert to gold units
    local totalGoldInGold = totalGainedGold / 10000

    -- Calculate per hour rates
    local xpPerHour   = (totalGainedXP / elapsedTime) * 3600
    local goldPerHour = (totalGoldInGold / elapsedTime) * 3600

    -- Time string
    local hours   = math.floor(elapsedTime / 3600)
    local minutes = math.floor((elapsedTime % 3600) / 60)
    local seconds = elapsedTime % 60
    local timeString = string.format("%02d:%02d:%02d", hours, minutes, seconds)

    -- Show 0 if nothing gained
    if totalGainedXP <= 0 and totalGainedGold <= 0 then
        frame.text:SetText("XP/hour: 0\nGold/hour: 0\nTotal XP: 0\nTotal Gold: 0\nTime: " .. timeString)
        return
    end

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
frame:SetScript("OnMouseUp", function() frame:StopMovingOrSizing(); frame:SetUserPlaced(true) end)


-- Slash command to reset session
SLASH_XPGOLD1 = "/xpgold"
SlashCmdList["XPGOLD"] = function(msg)
    msg = msg or ""
    if string.lower(msg) == "reset" then
        ResetSession()
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldTracker:|r Use /xpgold reset to reset XP & Gold tracking.")
    end
end


-- Confirmation
DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldTracker loaded!|r")
