-- Session tracking
local startXP, startGold, startTime = nil, nil, nil
local running = false  -- is the tracker running

-- Helper to format seconds as HH:MM:SS
local function FormatTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    if h > 0 then
        return string.format("%dh %02dm %02ds", h, m, s)
    elseif m > 0 then
        return string.format("%dm %02ds", m, s)
    else
        return string.format("%ds", s)
    end
end

-- Helper to format gold as g/s/c
local function FormatGold(amount)
    local g = math.floor(amount)
    local s = math.floor((amount - g) * 100)
    local c = math.floor(((amount - g) * 100 - s) * 100)
    return string.format("%dg %ds %dc", g, s, c)
end

-- Reset function
local function ResetSession()
    startXP   = UnitXP("player")
    startGold = GetMoney()
    startTime = time()
    running = true
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldMeter: Session reset!|r")
end

-- Stop function
local function StopSession()
    running = false
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldMeter: Session stopped!|r")
end

-- Start function
local function StartSession()
    if not startXP then
        ResetSession()
    else
        running = true
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldMeter: Session started!|r")
    end
end

-- Create frame
local frame = CreateFrame("Frame", "XpGoldOverlay", UIParent)
frame:SetWidth(200)
frame:SetHeight(60)
frame:SetPoint("CENTER", 0, -205)

-- Font string
frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
frame.text:SetAllPoints(frame)

-- Update loop
frame:SetScript("OnUpdate", function()
    if not running then return end

    -- Initialize session on first tick
    if not startXP then
        startXP   = UnitXP("player")
        startGold = GetMoney()
        startTime = time()
        frame.text:SetText("XP/hour: 0\nGold/hour: 0\nTotal XP: 0\nTotal Gold: 0\nTime: 0s")
        return
    end

    local elapsedTime = time() - startTime
    if elapsedTime <= 0 then elapsedTime = 1 end

    local gainedXP   = UnitXP("player") - startXP
    local gainedGold = (GetMoney() - startGold) / 10000  -- gold in gold units

    -- Show 0 until actual gains happen
    if gainedXP <= 0 and gainedGold <= 0 then
        frame.text:SetText("XP/hour: 0\nGold/hour: 0\nTotal XP: 0\nTotal Gold: 0\nTime: "..FormatTime(elapsedTime))
        return
    end

    -- Calculate per-hour rates
    local xpPerHour   = (gainedXP / elapsedTime) * 3600
    local goldPerHour = (gainedGold / elapsedTime) * 3600

    -- Update frame
    frame.text:SetText(string.format(
        "XP/hour: %.0f\nGold/hour: %s\nTotal XP: %d\nTotal Gold: %s\nTime: %s",
        xpPerHour, FormatGold(goldPerHour), gainedXP, FormatGold(gainedGold), FormatTime(elapsedTime)
    ))
end)

-- Draggable frame
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetScript("OnMouseDown", function() frame:StartMoving() end)
frame:SetScript("OnMouseUp", function() frame:StopMovingOrSizing(); frame:SetUserPlaced(true) end)

-- Slash commands
SLASH_XPGOLD1 = "/xpgold"
SlashCmdList["XPGOLD"] = function(msg)
    msg = msg or ""
    msg = string.lower(msg)
    if msg == "reset" then
        ResetSession()
    elseif msg == "start" then
        StartSession()
    elseif msg == "stop" then
        StopSession()
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldMeter:|r Commands: /xpgold start | stop | reset")
    end
end

-- Confirmation
DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldMeter loaded!|r")
