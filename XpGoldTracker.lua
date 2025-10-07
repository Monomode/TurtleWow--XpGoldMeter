-- Session tracking
local startXP   = UnitXP("player")
local lastXP    = startXP
local startGold = GetMoney()
local startTime = time()
local totalGainedXP = 0
local totalGainedGold = 0



-- Reset function
local function ResetSession()
    startLevel = UnitLevel("player")   -- Reset start level as well
    
    startXP    = UnitXP("player")
    lastXP           = startXP
    startGold  = GetMoney()
    startTime  = time()
    totalGainedXP    = 0
    totalGainedGold  = 0
    
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
    -- Variables
    local currentXP = UnitXP("player")
    local currentGold = GetMoney()

       -- XP tracking logic
    if currentXP > lastXP then
        -- Gained XP since last check
        local delta = currentXP - lastXP
        totalGainedXP = totalGainedXP + delta
    elseif currentXP < lastXP then
        -- XP dropped (e.g. level up): don't subtract, just reset lastXP reference
        -- This way, we don't count negative XP or reset the total
        lastXP = currentXP
    end

    -- Always update lastXP after checking
    lastXP = currentXP

    -- Time
    local elapsedTime = time() - startTime
        
    -- Calculate rates
    local gainedGold = (GetMoney() - startGold) / 10000  -- gold in gold units
    local xpPerHour   = (totalGainedXP / elapsedTime) * 3600
    local goldPerHour = (totalGainedGold / elapsedTime) * 3600
        
    -- Time
    local hours   = math.floor(elapsedTime / 3600)
    local minutes = math.floor((elapsedTime - hours * 3600) / 60)
    local seconds = elapsedTime - (hours * 3600) - (minutes * 60)
    local timeString = string.format("%02d:%02d:%02d", hours, minutes, seconds)
        
    -- Show 0 if nothing gained or too early
    if elapsedTime < 1 or (totalGainedXP  <= 0 and gainedGold <= 0) then
        frame.text:SetText("XP/hour: 0\nGold/hour: 0\nTotal XP: 0\nTotal Gold: 0\nTime: " .. timeString)
        return
    end

    -- Display per-hour rates and total gained
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
