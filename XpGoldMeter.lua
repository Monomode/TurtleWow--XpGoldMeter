-- XPGoldMeter - Turtle WoW 1.12 Addon
-- Tracks XP/hour and Gold/hour (including silver/copper).
-- Toggle display with /xpmeter

local XPGoldMeter = {}
XPGoldMeter.startTime = GetTime()
XPGoldMeter.startXP = UnitXP("player")
XPGoldMeter.startMoney = GetMoney()

-- Frame setup
local f = CreateFrame("Frame", "XPGoldMeterFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
f:SetSize(200, 60)
f:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
f:SetBackdrop({
  bgFile = "Interface/Tooltips/UI-Tooltip-Background",
  edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
  tile = true, tileSize = 8, edgeSize = 8,
})
f:SetBackdropColor(0, 0, 0, 0.7)
f:EnableMouse(true)
f:SetMovable(true)
f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart", f.StartMoving)
f:SetScript("OnDragStop", f.StopMovingOrSizing)

f.text = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
f.text:SetPoint("TOPLEFT", 10, -10)
f.text:SetJustifyH("LEFT")

-- Reset function
local function ResetMeter()
  XPGoldMeter.startTime = GetTime()
  XPGoldMeter.startXP = UnitXP("player")
  XPGoldMeter.startMoney = GetMoney()
end

-- Slash command
SLASH_XPGOLDMETER1 = "/xpmeter"
SlashCmdList["XPGOLDMETER"] = function(msg)
  if msg == "reset" then
    ResetMeter()
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00XPGoldMeter reset.|r")
  else
    if f:IsShown() then f:Hide() else f:Show() end
  end
end

-- Helper to format money into G/S/C
local function FormatMoney(copper)
  local g = floor(copper / 10000)
  local s = floor((copper % 10000) / 100)
  local c = copper % 100
  return string.format("%dg %ds %dc", g, s, c)
end

-- Update frame text
f:SetScript("OnUpdate", function(self, elapsed)
  local elapsedTime = (GetTime() - XPGoldMeter.startTime) / 3600 -- hours
  if elapsedTime <= 0 then return end

  local gainedXP = UnitXP("player") - XPGoldMeter.startXP
  local gainedMoney = GetMoney() - XPGoldMeter.startMoney

  local xpPerHour = gainedXP / elapsedTime
  local goldPerHour = gainedMoney / elapsedTime

  local txt = string.format(
    "XP/hr: %.0f\nGold/hr: %s",
    xpPerHour,
    FormatMoney(goldPerHour)
  )

  f.text:SetText(txt)
end)

-- Show at login
f:Show()
