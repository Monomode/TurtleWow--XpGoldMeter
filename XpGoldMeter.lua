-- Minimal test for Turtle WoW 1.12
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
  print("|cff33ff99XpGoldMeter test loaded!|r")
end)
