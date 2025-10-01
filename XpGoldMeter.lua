-- SimpleTextOverlay.lua
local frame = CreateFrame("Frame", "SimpleTextOverlay", UIParent)
frame:SetSize(200, 50)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

-- Create the font string (white text)
frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.text:SetFont(STANDARD_TEXT_FONT, 16, "OUTLINE")
frame.text:SetPoint("CENTER", frame, "CENTER", 0, 0)
frame.text:SetText("Overlay Loaded!")

-- Make it movable
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and IsAltKeyDown() then
        self:StartMoving()
    end
end)
frame:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
        self:StopMovingOrSizing()
        self:SetUserPlaced(true)
    end
end)

-- Print a message in chat on login
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    print("|cff33ff99SimpleTextOverlay loaded!|r")
end)
