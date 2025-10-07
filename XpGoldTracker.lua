lootFrame:SetScript("OnEvent", function()
    if not trackingEnabled then return end

    if event ~= "CHAT_MSG_LOOT" 
       and event ~= "CHAT_MSG_COMBAT_SELF_ITEMS" 
       and event ~= "CHAT_MSG_COMBAT_LOOT" then
        return
    end

    local msg = arg1
    if not msg then return end

    -- Extract item name and quantity (supports [Item] and stack xN formats)
    local itemName, quantity = string.match(msg, "You receive loot: %[([^%]]+)%]x(%d+)%." )
    if not itemName then
        itemName = string.match(msg, "You receive loot: %[([^%]]+)%]%." )
        quantity = 1
    end
    quantity = tonumber(quantity) or 1

    if not itemName then return end

    -- Convert to SellValues key formats (1.12 DB often uses names, not itemIDs)
    local value = 0

    if SellValues and SellValues[itemName] then
        value = SellValues[itemName] * quantity
    else
        -- Some DBs use lowercase keys or itemID strings
        local itemID = string.match(msg, "item:%d+")
        if itemID and SellValues[itemID] then
            value = SellValues[itemID] * quantity
        end
    end

    if value > 0 then
        totalLootValue = totalLootValue + value
        totalLootedItems = totalLootedItems + quantity

        DEFAULT_CHAT_FRAME:AddMessage(
            string.format("|cff33ff99LootTracker:|r Added %s (x%d) worth %.2fg",
                itemName, quantity, value / 10000)
        )
    end
end)
