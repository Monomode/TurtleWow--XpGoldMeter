--[[ 
XpGoldMeter (Turtle WoW Addon)
==============================
Author: Monomoy

Tracks XP/hour and Gold/hour on Turtle WoW (1.12).

Features:
- Movable window shows current XP/hour and Gold/hour.
- Tracks both per-session rate and total session gain.
- Slash command `/xpgold` toggles the frame.
- Interface automatically loads on login.
]]

local XpGoldMeter = {}
XpGoldMeter.startTime = 0
XpGoldMeter.xpGained = 0
XpGoldMeter.goldGained = 0
XpGoldMeter.silverGained = 0
XpGoldMeter.copperGained = 0
XpGoldMeter.startXP = 0
XpGoldMeter.startMoney = 0

-- Main frame
local f = CreateFrame("Frame", "XpGoldMeterFrame", UIParent)
f:SetSize(220, 100)
f:SetPoint("CENTER")
f:SetBackdrop({
  bgFile = "Interface/Tooltips/UI-Tooltip-Background",
  edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
  tile = true, tileSize = 16, edgeSize = 16,
  insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
f:SetBackdropColor(0, 0, 0, 0.7)
f:EnableMouse(true)
f:SetMovable(true)
f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart", f.StartMoving)
f:SetScript("OnDragStop", f.StopMovingOrSizing)

-- Display text
f.text = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
f.text:SetPoint("TOPLEFT", 10, -10)
f.text:SetJustifyH("LEFT")

-- Slash command
SLASH_XPGOLDMETER1 = "/xpgold"
SlashCmdList["XPGOLDMETER"] = function()
  if f:IsShown() then f:Hide() else f:Show() end
end

-- Event frame
local ef = CreateFrame("Frame")
ef:RegisterEvent("PLAYER_LOGIN")
ef:RegisterEvent("PLAYER_XP_UPDATE")
ef:RegisterEvent("PLAYER_MONEY")

ef:SetScript("OnEvent", function(self, event, ...)
  if event == "PLAYER_LOGIN" then
    -- initialize values
    XpGoldMeter.startTime = GetTime()
    XpGoldMeter.startXP = UnitXP("player")
    XpGoldMeter.startMoney = GetMoney()
    f:Show() -- ensure frame is visible on login

  elseif event == "PLAYER_XP_UPDATE" then
    local currentXP = UnitXP("player")
    XpGoldMeter.xpGained = currentXP - XpGoldMeter.startXP
    if XpGoldMeter.xpGained < 0 then
      -- leveled up, reset baseline
      XpGoldMeter.startXP = currentXP
      XpGoldMeter.xpGained = 0
    end

  elseif event == "PLAYER_MONEY" then
    local currentMoney = GetMoney()
    local diff = currentMoney - XpGoldMeter.startMoney
    if diff > 0 then
      local g = math.floor(diff / 10000)
      local s = math.floor((diff % 10000) / 100)
      local c = diff % 100
      XpGoldMeter.goldGained = g
      XpGoldMeter.silverGained = s
      XpGoldMeter.copperGained = c
    end
  end
end)

-- OnUpdate: refresh display
f:SetScript("OnUpdate", function()
  local elapsed = GetTime() - XpGoldMeter.startTime
  if elapsed <= 0 then return end

  local xpPerHour = (XpGoldMeter.xpGained / elapsed) * 3600
  local moneyPerHour = ((XpGoldMeter.goldGained*10000 + XpGoldMeter.silverGained*100 + XpGoldMeter.copperGained) / elapsed) * 3600

  local g = math.floor(moneyPerHour / 10000)
  local s = math.floor((moneyPerHour % 10000) / 100)
  local c = math.floor(moneyPerHour % 100)

  f.text:SetText(string.format(
    "XP/hr: %.0f\nGold/hr: %dg %ds %dc\nSession XP: %d\nSession Gold: %dg %ds %dc",
    xpPerHour,
    g, s, c,
    XpGoldMeter.xpGained,
    XpGoldMeter.goldGained, XpGoldMeter.silverGained, XpGoldMeter.copperGained
  ))
end)
