--[[
Client Compatibility: World of Warcraft 1.12 (Vanilla / Turtle WoW)
Lua Version: Embedded Lua 5.0.2 (Pre–Lua 5.1)
This addon is designed for the original World of Warcraft 1.12 client.
]]

-- Session tracking
local startXP   = UnitXP("player")
local lastXP    = startXP
local startGold = GetMoney()
local startTime = time()
local totalGainedXP = 0
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
    if not trackingEnabled then return end

    if event ~= "CHAT_MSG_LOOT" 
       and event ~= "CHAT_MSG_COMBAT_SELF_ITEMS" 
       and event ~= "CHAT_MSG_COMBAT_LOOT" then
        return
    end

    local msg = arg1
    if not msg then return end

    -- Extract item name and quantity (supports [Item] and stack xN formats) -- Updated
    local itemName, quantity = string.match(msg, "You receive loot: %[([^%]]+)%]x(%d+)%." )
    if not itemName then
        itemName = string.match(msg, "You receive loot: %[([^%]]+)%]%." )
        quantity = 1
    end
    quantity = tonumber(quantity) or 1
    if not itemName then return end

    local value = 0
    if SellValues and SellValues[itemName] then
        value = SellValues[itemName] * quantity
    else
        local itemID = string.match(msg, "item:%d+")
        if itemID and SellValues[itemID] then
            value = SellValues[itemID] * quantity
        end
    end

    if value > 0 then
        totalLootValue = totalLootValue + value
        totalLootedItems = totalLootedItems + quantity
        -- Optional debug:
        -- DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99LootTracker:|r Added " .. itemName .. " (x" .. quantity .. ") worth " .. string.format("%.2fg", value / 10000))
    end
end)

-- Reset function
local function ResetSession()
    startLevel = UnitLevel("player")
    startXP    = UnitXP("player")
    lastXP     = startXP
    startGold  = GetMoney()
    startTime  = time()
    totalGainedXP = 0
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
frame:SetHeight(100)
frame:SetPoint("CENTER", 0, -220)

-- Font string
frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
frame.text:SetAllPoints(frame)

-- Update loop
frame:SetScript("OnUpdate", function()
    if not trackingEnabled then return end
        
    local currentXP   = UnitXP("player")
    local currentGold = GetMoney()
        
    -- XP tracking logic
    if currentXP > lastXP then
        totalGainedXP = totalGainedXP + (currentXP - lastXP)
    elseif currentXP < lastXP then
        lastXP = currentXP
    end
    lastXP = currentXP

    -- Time
    local elapsedTime = time() - startTime
    if elapsedTime <= 0 then elapsedTime = 1 end  -- Prevent divide-by-zero

    -- Gold + Loot combined profit calculations -- Modified
    local gainedGold = (currentGold - startGold)
    local totalProfitCopper = gainedGold + totalLootValue
    local totalProfitGold = totalProfitCopper / 10000
    local profitPerHour = (totalProfitGold / elapsedTime) * 3600

    local xpPerHour = (totalGainedXP / elapsedTime) * 3600
        
    -- Time display
    local hours   = math.floor(elapsedTime / 3600)
    local minutes = math.floor((elapsedTime - hours * 3600) / 60)
    local seconds = elapsedTime - (hours * 3600) - (minutes * 60)
    local timeString = string.format("%02d:%02d:%02d", hours, minutes, seconds)
        
    if elapsedTime < 1 or (totalGainedXP <= 0 and totalProfitCopper <= 0) then
        frame.text:SetText("XP/hour: 0\nProfit/hour: 0\nTotal XP: 0\nTotal Profit: 0\nTime: " .. timeString)
        return
    end

    -- Display combined profit stats -- Modified
    frame.text:SetText(string.format(
        "XP/hour: %.0f\nProfit/hour: %.2f\nTotal XP: %d\nTotal Profit: %.2f\nTime: %s",
        xpPerHour, profitPerHour, totalGainedXP, totalProfitGold, timeString
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

DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99XpGoldMeter loaded!|r")
