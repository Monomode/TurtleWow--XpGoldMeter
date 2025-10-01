-- SimpleTestOverlay.lua
local frame = CreateFrame("Frame", "SimpleTestOverlay", UIParent)
frame:SetSize(200, 50)  -- Width, Height
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
frame:Show()

-- Background so we can see it
frame.bg = frame:CreateTexture(nil, "BACKGROUND")
frame.bg:SetAllPoints(frame)
frame.bg:SetColorTexture(0, 0, 0, 0.5)  -- Semi-transparent black

-- Text
frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.text:SetAllPoints(frame)
frame.text:SetFont(STANDARD_TEXT_FONT, 16, "OUTLINE")
frame.text:SetJustifyH("CENTER")
frame.text:SetText("Overlay Loaded!")

-- Print a message on login
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    print("|cff33ff99SimpleTestOverlay loaded!|r")
end)
