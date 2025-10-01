-- XpGoldMeter (Turtle WoW 1.12)
-- Tracks XP/hr and Gold/hr and session totals.
-- Drop into Interface/AddOns/XpGoldMeter/XpGoldMeter.lua

local addon = "XpGoldMeter"
local XPGM = {}

-- session tracking
XPGM.startTime = 0
XPGM.prevXP = 0
XPGM.prevXPMax = 0
XPGM.prevLevel = 0
XPGM.xpGained = 0

XPGM.prevMoney = 0
XPGM.moneyGained = 0

-- Create display frame (will be shown on PLAYER_LOGIN)
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
frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
frame:Hide()

frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
frame.title:SetPoint("TOP", 0, -6)
frame.title:SetText("XP & Gold Meter")

frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.text:SetPoint("TOPLEFT", 10, -28)
frame.text:SetJustifyH("LEFT")
frame.text:SetWidth(frame:GetWidth() - 20)

-- Toggle/reset slash commands (define globally so user can type even before event)
SLASH_XPGOLD1 = "/xpgold"
SLASH_XPGOLD2 = "/xpgm"
SlashCmdList["XPGOLD"] = function(msg)
  msg = msg and strlower(msg) or ""
  if msg == "reset" then
    -- reset session
    XPGM.startTime = GetTime()
    XPGM.prevXP = UnitXP("player") or 0
    XPGM.prevXPMax = UnitXPMax("player") or 0
    XPGM.prevLevel = UnitLevel("player") or 0
    XPGM.xpGained = 0
    XPGM.prevMoney = GetMoney() or 0
    XPGM.moneyGained = 0
    print("|cff00ff00XpGoldMeter: session reset.|r")
  else
    if frame:IsShown() then frame:Hide() else frame:Show() end
  end
end

-- helper: format copper -> g s c
local function FormatGSC(copper)
  copper = math.floor(copper or 0)
  local g = math.floor(copper / 10000)
  local s = math.floor((copper % 10000) / 100)
  local c = copper % 100
  return string.format("%dg %ds %dc", g, s, c)
end

-- event handler frame
local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_LOGIN")
ev:RegisterEvent("PLAYER_XP_UPDATE")
ev:RegisterEvent("PLAYER_MONEY")

-- Keep an update accumulator to refresh text at a reasonable interval
local updateAccumulator = 0
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

ev:SetScript("OnEvent", function(self, event, ...)
  if event == "PLAYER_LOGIN" then
    -- initialize baseline values
    XPGM.startTime = GetTime()
    XPGM.prevXP = UnitXP("player") or 0
    XPGM.prevXPMax = UnitXPMax("player") or 0
    XPGM.prevLevel = UnitLevel("player") or 0
    XPGM.xpGained = 0

    XPGM.prevMoney = GetMoney() or 0
    XPGM.moneyGained = 0

    frame:Show()
    print("|cff33ff99XpGoldMeter loaded.|r /xpgold to toggle, /xpgold reset to reset session.")
    return
  end

  if event == "PLAYER_XP_UPDATE" then
    -- This event may fire for player XP changes
    local currXP = UnitXP("player") or 0
    local currXPMax = UnitXPMax("player") or 0
    local currLevel = UnitLevel("player") or 0

    local diff = currXP - (XPGM.prevXP or 0)
    if diff >= 0 then
      XPGM.xpGained = (XPGM.xpGained or 0) + diff
    else
      -- level-up happened: previous level remaining + current xp
      -- use prevXPMax (stored from previous state) to compute remaining xp in previous level
      local prevMax = (XPGM.prevXPMax or currXPMax) -- fallback
      local carried = (prevMax - (XPGM.prevXP or 0))
      if carried < 0 then carried = 0 end
      XPGM.xpGained = (XPGM.xpGained or 0) + carried + currXP
    end

    -- update prev trackers
    XPGM.prevXP = currXP
    XPGM.prevXPMax = currXPMax
    XPGM.prevLevel = currLevel
    return
  end

  if event == "PLAYER_MONEY" then
    local currMoney = GetMoney() or 0
    local diff = currMoney - (XPGM.prevMoney or 0)
    if diff ~= 0 then
      -- add positive or negative changes (if you spend money, session money decreases)
      XPGM.moneyGained = (XPGM.moneyGained or 0) + diff
      XPGM.prevMoney = currMoney
    end
    return
  end
end)

-- Use OnUpdate to refresh displayed numbers every 1 second
frame:SetScript("OnUpdate", function(self, elapsed)
  updateAccumulator = updateAccumulator + elapsed
  if updateAccumulator >= 1 then
    UpdateDisplay()
    updateAccumulator = 0
  end
end)
