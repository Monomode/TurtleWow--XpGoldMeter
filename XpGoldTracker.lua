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

-- Ensure the SellValue database is initialized -- Added for loot tracking
if SellValue_InitializeDB then
    SellValue_InitializeDB()
end

-- Added for loot tracking
local totalLootValue = 0
local totalLootedItems = 0

-- Added for loot tracking
local lootFrame = CreateFrame("Frame")
lootFrame:RegisterEvent("CHAT_MSG_LOOT")
lootFrame:RegisterEvent("CHAT_MSG_COMBAT_SELF_ITEMS")
lootFrame:RegisterEvent("CHAT_MSG_COMBAT_LOOT")


lootFrame:SetScript("OnEvent", function()
    -- Use old-style event globals: event, arg1, arg2, ...
    if not trackingEnabled then return end

    -- Debug check
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99DEBUG:|r Event fired: " .. tostring(event) .. " msg=" .. tostring(arg1))

    -- Only handle loot events
    if event ~= "CHAT_MSG_LOOT" 
       and event ~= "CHAT_MSG_COMBAT_SELF_ITEMS" 
       and event ~= "CHAT_MSG_COMBAT_LOOT" then
        return
    end

    local msg = arg1
    if not msg then return end

    -- Extract item link and quantity (works for both linked and plain text items)
    local itemLink, quantity = string.match(msg, "You receive loot: (.+)x(%d+)%." )
    if not itemLink then
        itemLink = string.match(msg, "You receive loot: (.+)%." )
        quantity = 1
    end
    quantity = tonumber(quantity) or 1

    if not itemLink then return end

    local itemID = string.match(itemLink, "item:%d+")
    local value = 0

    if itemID and SellValues and SellValues[itemID] then
        value = SellValues[itemID] * quantity
    elseif SellValues and SellValues[itemLink] then
        value = SellValues[itemLink] * quantity
    end

    if value > 0 then
        totalLootValue = totalLootValue + value
        totalLootedItems = totalLootedItems + quantity
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99LootTracker:|r Added " .. itemLink .. " (x" .. quantity .. ") worth " .. string.format("%.2fg", value / 10000))
    end
end)


-- Reset function
local function ResetSession()
    startLevel = UnitLevel("player")
    startXP    = UnitXP("player")
    lastXP     = startXP
    startGold  = GetMoney()
    startTime  = time()
    totalGainedXP    = 0
    totalGainedGold  = 0

    -- Added for loot tracking
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
frame:SetHeight(115) -- Slightly taller to fit Profit/hr line -- Added for loot tracking
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
        local delta = currentXP - lastXP
        totalGainedXP = totalGainedXP + delta
    elseif currentXP < lastXP then
        lastXP = currentXP
    end

    lastXP = currentXP

    -- Time
    local elapsedTime = time() - startTime
    if elapsedTime <= 0 then elapsedTime = 1 end  -- Prevent divide-by-zero

    -- Calculate rates
    local gainedGold = (currentGold - startGold) / 10000  -- convert copper to gold
    local xpPerHour   = (totalGainedXP / elapsedTime) * 3600
    local goldPerHour = (gainedGold / elapsedTime) * 3600

    -- Added for loot tracking
    local totalLootGold = totalLootValue / 10000
    local lootPerHour = (totalLootGold / elapsedTime) * 3600

    -- Added for combined profit/hour
    local profitPerHour = goldPerHour + lootPerHour
        
    -- Time
    local hours   = math.floor(elapsedTime / 3600)
    local minutes = math.floor((elapsedTime - hours * 3600) / 60)
    local seconds = elapsedTime - (hours * 3600) - (minutes * 60)
    local timeString = string.format("%02d:%02d:%02d", hours, minutes, seconds)
        
    -- Show 0 if nothing gained or too early
    if elapsedTime < 1 or (totalGainedXP <= 0 and gainedGold <= 0 and totalLootGold <= 0) then
        frame.text:SetText("XP/hour: 0\nGold/hour: 0\nLoot/hr: 0\nProfit/hr: 0\nTotal XP: 0\nTotal Gold: 0\nLoot Value: 0\nTime: " .. timeString)
        return
    end

    -- Display per-hour rates and total gained
    frame.text:SetText(string.format(
        "XP/hour: %.0f\nGold/hour: %.2f\nLoot/hr: %.2f\nProfit/hr: %.2f\nTotal XP: %d\nTotal Gold: %.2f\nLoot Value: %.2f\nTime: %s",
        xpPerHour, goldPerHour, lootPerHour, profitPerHour, totalGainedXP, gainedGold, totalLootGold, timeString
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
