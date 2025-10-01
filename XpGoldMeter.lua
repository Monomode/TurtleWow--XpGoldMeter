-- XpGoldMeter for Turtle WoW (1.12)
-- Tracks XP/hr and Gold/hr with session totals.

local XPGM = {}
XPGM.startTime = 0
XPGM.xpGained = 0
XPGM.moneyGained = 0
XPGM.prevXP = 0
XPGM.prevXPMax = 0
XPGM.prevLevel = 0
XPGM.prevMoney = 0

-- Main frame
local frame = CreateFrame("Frame", "XPGoldMeterFrame", UIParent)
frame:SetWidth(260)
frame:SetHeight(90)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 180)
frame:SetBackdrop({
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true, tileSize = 16, edgeSize = 16,
  insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
frame:SetBackdropColor(0,0,0,0.75)

frame:EnableMouse(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
frame.title:SetPoint("TOP", 0, -6)
frame.title:SetText("XP & Gold Meter")

frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.text:SetPoint("TOPLEFT", 10, -28)
frame.text:SetJustifyH("LEFT")
frame.text:SetWidth(frame:GetWidth() - 20)

-- Helpers
local function FormatGSC(copper)
  copper = math.floor(copper or 0)
  local g = math.floor(copper / 10000)
  local s = math.floor((copper % 10000) / 100)
  local c = copper % 100
  return string.format("%dg %ds %dc", g, s, c)
end

local function UpdateDisplay()
  local now = GetTime()
  local elapsed = now - (XPGM.startTime or now)
  if elapsed <= 0 then elapsed = 1 end
  local hours = elapsed / 3600

  local xpPerHour = math.floor((XPGM.xpGained / hours) + 0.5)
  local moneyPerHourCopper = math.floor((XPGM.moneyGained / hours) + 0.5)

  local moneyPerHourText = FormatGSC(moneyPerHourCopper)
  local sessionMoneyText = FormatGSC(XPGM.moneyGained)
  local sessionXP = XPGM.xpGained

  frame.text:SetText(string.format(
    "XP/hr: %s\nGold/hr: %s\n\nSession XP: %d\nSession Gold: %s",
    tostring(xpPerHour), moneyPerHourText, sessionXP, sessionMoneyText
  ))
end

-- Slash commands
SLASH_XPGOLD1 = "/xpgold"
SLASH_XPGOLD2 = "/xpgm"
SlashCmdList["XPGOLD"] = function(msg)
  msg = msg and strlower(msg) or ""
  if msg == "reset" then
    XPGM.startTime = GetTime()
    XPGM.xpGained = 0
    XPGM.moneyGained = 0
    XPGM.prevXP = UnitXP("player") or 0
    XPGM.prevXPMax = UnitXPMax("player") or 0
    XPGM.prevLevel = UnitLevel("player") or 0
    XPGM.prevMoney = GetMoney() or 0
    print("|cff00ff00XpGoldMeter: Session reset.|r")
  else
    if frame:IsShown() then frame:Hide() else frame:Show() end
  end
end

-- Event frame
local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_LOGIN")
ev:RegisterEvent("PLAYER_XP_UPDATE")
ev:RegisterEvent("PLAYER_MONEY")

ev:SetScript("OnEvent", function(self, event, ...)
  if event == "PLAYER_LOGIN" then
    -- Initialize
    XPGM.startTime = GetTime()
    XPGM.prevXP = UnitXP("player") or 0
    XPGM.prevXPMax = UnitXPMax("player") or 0
    XPGM.prevLevel = UnitLevel("player") or 0
    XPGM.prevMoney = GetMoney() or 0

    frame:Show()
    print("|cff33ff99XpGoldMeter loaded!|r Type /xpgold to toggle, /xpgold reset to reset.")
    return
  end

  if event == "PLAYER_XP_UPDATE" then
    local currXP = UnitXP("player") or 0
    local currXPMax = UnitXPMax("player") or 0

    local diff = currXP - (XPGM.prevXP or 0)
    if diff >= 0 then
      XPGM.xpGained = XPGM.xpGained + diff
    else
      local prevMax = (XPGM.prevXPMax or currXPMax)
      local carried = (prevMax - (XPGM.prevXP or 0))
      if carried < 0 then carried = 0 end
      XPGM.xpGained = XPGM.xpGained + carried + currXP
    end

    XPGM.prevXP = currXP
    XPGM.prevXPMax = currXPMax
    return
  end

  if event == "PLAYER_MONEY" then
    local currMoney = GetMoney() or 0
    local diff = currMoney - (XPGM.prevMoney or 0)
    XPGM.moneyGained = XPGM.moneyGained + diff
    XPGM.prevMoney = currMoney
    return
  end
end)

-- Update display every second
frame:SetScript("OnUpdate", function(self, elapsed)
  self.accum = (self.accum or 0) + elapsed
  if self.accum >= 1 then
    UpdateDisplay()
    self.accum = 0
  end
end)
