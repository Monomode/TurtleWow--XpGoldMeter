--[[
Client Compatibility: World of Warcraft 1.12 (Vanilla / Turtle WoW)
Lua Version: Embedded Lua 5.0.2 (Pre–Lua 5.1)
This addon is designed for the original World of Warcraft 1.12 client,
which uses an embedded Lua 5.0.2 interpreter. This differs from modern
WoW (Burning Crusade and beyond), which use Lua 5.1+.

As such, several modern Lua language features are **not available** or
behave differently. Any code written for 1.12 must take these into account.
]]

-- Session tracking
local startXP   = UnitXP("player")
local lastXP    = startXP
local startGold = GetMoney()
local startTime = time()
local totalGainedXP = 0
local totalGainedGold = 0
local trackingEnabled = true

-- Ensure the SellValue database is initialized
if SellValue_InitializeDB then
    SellValue_InitializeDB()
end

local totalLootValue = 0
local totalLootedItems = 0

local lootFrame = CreateFrame("Frame")
lootFrame:RegisterEvent("CHAT_MSG_LOOT")

lootFrame:SetScript("OnEvent", function(_, event, msg)
    if not trackingEnabled or event ~= "CHAT_MSG_LOOT" then return end

    -- Extract item link and quantity
    local itemLink, quantity = string.match(msg, "You receive loot: (.+)x(%d+)%." )
    if not itemLink then
        itemLink = string.match(msg, "You receive loot: (.+)%." )
        quantity = 1
    end
    quantity = tonumber(quantity) or 1

    if itemLink then
        local itemID = string.match(itemLink, "item:%d+")
        if itemID and SellValues and SellValues[itemID] then
            local value = SellValues[itemID] * quantity
            totalLootValue = totalLootValue + value
            totalLootedItems = totalLootedItems + quantity
        end
    end
end)


-- Reset function
local function ResetSession()
    startLevel = UnitLevel("player")
    startXP    = UnitXP("player")
    lastXP           = startXP
    startGold  = GetMoney()
    startTime  = time()
    totalGainedXP    = 0
    totalGainedGold  = 0
    totalLootValue = 0
    totalLootedItems = 0

    
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldTracker: Session reset!|r")
end

-- Start/stop tracking
local function StartTracking()
    if trackingEnabled then
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldTracker:|r Already running.")
        return
    end
    trackingEnabled = true
    if not startXP then ResetSession() end
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldTracker:|r Tracking started.")
end

local function StopTracking()
    if not trackingEnabled then
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldTracker:|r Already stopped.")
        return
    end
    trackingEnabled = false
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldTracker:|r Tracking paused.")
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
    if not trackingEnabled then return end
        
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
    local gainedGold = (GetMoney() - startGold) / 10000  -- convert to gold (from copper)
    local xpPerHour   = (totalGainedXP / elapsedTime) * 3600
    local goldPerHour = (gainedGold / elapsedTime) * 3600

    -- Added for loot tracking
    local totalLootGold = totalLootValue / 10000
    local lootPerHour = (totalLootGold / elapsedTime) * 3600
        
    -- Time
    local hours   = math.floor(elapsedTime / 3600)
    local minutes = math.floor((elapsedTime - hours * 3600) / 60)
    local seconds = elapsedTime - (hours * 3600) - (minutes * 60)
    local timeString = string.format("%02d:%02d:%02d", hours, minutes, seconds)
        
    -- Show 0 if nothing gained or too early
    if elapsedTime < 1 or (totalGainedXP  <= 0 and gainedGold <= 0) then
        frame.text:SetText("XP/hour: 0\nGold/hour: 0\nLoot/hr: %.2f\nTotal XP: 0\nTotal Gold: 0\nTime: " .. timeString)
        return
    end

    -- Display per-hour rates and total gained
    frame.text:SetText(string.format(
        "XP/hour: %.0f\nGold/hour: %.2f\nLoot/hr: %.2f\nTotal XP: %d\nTotal Gold: %.2f\nTime: %s",
        xpPerHour, goldPerHour, lootPerHour, totalGainedXP, gainedGold, timeString
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
    elseif msg == "start" then
        StartTracking()
    elseif msg == "stop" then
        StopTracking()
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldTracker:|r Use /xpgold start, /xpgold stop, or /xpgold reset.")
    end
end

-- Confirmation
DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldMeter loaded!|r")
