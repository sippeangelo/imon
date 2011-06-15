--------------
-- raid.lua --
--------------

local oUF = imonoUF
local cf = imon.cf
local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")

local BAR_TEXTURE = LSM:Fetch("statusbar", "Minimalist")
local BAR_WIDTH = 220
local HEALTH_HEIGHT = 34
local POWER_HEIGHT = 9
local SPACING_HEIGHT = 5
local AURA_SIZE = (HEALTH_HEIGHT + POWER_HEIGHT - 1) / 2



imon.oUF.Raid = {}

-- Unit menu
imon.oUF.Raid.menu = function(self)
	local unit = self.unit:sub(1, -2)
	local cunit = self.unit:gsub("(.)", string.upper, 1)
	
	-- Swap menus in vehicle
	if self == oUF_player and cunit=="Vehicle" then cunit = "Player" end
	if self == oUF_pet and cunit=="Player" then cunit = "Pet" end

	if(unit == "party" or unit == "partypet") then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor", 0, 0)
	elseif(_G[cunit.."FrameDropDown"]) then
		ToggleDropDownMenu(1, nil, _G[cunit.."FrameDropDown"], "cursor", 0, 0)
	end
end

imon.oUF.Raid.Health_Override = function(self, event, unit, powerType)
	if(self.unit ~= unit or (event == 'UNIT_POWER' and powerType ~= 'HAPPINESS')) then return end
	local health = self.Health
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	
	local disconnected = not UnitIsConnected(unit)
	health:SetMinMaxValues(0, max)

	if(disconnected) then
		health:SetValue(max)
	else
		health:SetValue(min)
	end

	health.disconnected = disconnected

	local r, g, b, t
	if(not UnitIsConnected(unit)) then
		t = self.colors.disconnected
	else
		-- Start coloring red from 50% hp down
		local percentage = min / (max / 2)
		local _, class = UnitClass(unit)
		if (class) then
			r, g, b = self.ColorGradient(percentage, 1,0,0, unpack(self.colors.class[class]))
		end
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if(b) then
		health:SetStatusBarColor(r, g, b)

		local bg = health.bg
		if(bg) then local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end
end

imon.oUF.SharedParty = function(self, unit)
	self.colors.power["MANA"] = { 68/255, 138/255, 231/255 }
	self.menu = imon.oUF.Raid.menu
	self:RegisterForClicks("AnyDown")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	self:SetSize(BAR_WIDTH, HEALTH_HEIGHT + POWER_HEIGHT + SPACING_HEIGHT)
	
	self.Range = {
		insideAlpha = 1,
		outsideAlpha = 0.6
	}
	
	-- Health bar
	local hpBar = CreateFrame("StatusBar", nil, self)
	hpBar:SetStatusBarTexture(BAR_TEXTURE)
	hpBar:SetSize(BAR_WIDTH, HEALTH_HEIGHT)
	hpBar:SetPoint("TOP", self, "TOP", 0, 0)
	hpBar.frequentUpdates = true
	hpBar.colorTapped = true
	hpBar.colorClass = true
	hpBar.colorReaction = true
	hpBar.colorDisconnected = true	
	self.Health = hpBar
	--self.Health.Override = imon.oUF.Raid.Health_Override
	--[[self.Health.PostUpdate = function(health, unit, min, max)
		local _, class = UnitClass(unit)
		if (class) then
			r, g, b = self.ColorGradient(min / max, 1,0,0, unpack(self.colors.class[class]))
			health:SetStatusBarColor(r, g, b)

			local bg = health.bg
			if(bg) then local mu = bg.multiplier or 1
				bg:SetVertexColor(r * mu, g * mu, b * mu)
			end
		end
	end]]--
	
	local hpBG = hpBar:CreateTexture(nil, "BORDER")
	hpBG:SetAllPoints()
	hpBG:SetTexture(BAR_TEXTURE)	
	hpBar.bg = hpBG
	hpBar.bg.multiplier = 0.5
	
	-- Power bar
	local powBar = CreateFrame("StatusBar", nil, self)
	powBar:SetStatusBarTexture(BAR_TEXTURE)
	powBar:SetSize(BAR_WIDTH, POWER_HEIGHT)
	powBar:SetPoint("TOP", hpBar, "BOTTOM", 0, 0)
	--powBar:SetBackdropColor(0, 0, 0, 0.9)
	powBar.frequentUpdates = true
	powBar.colorPower = true
	powBar.colorDisconnected = true
	self.Power = powBar
	
	local powBG = powBar:CreateTexture(nil, "BORDER")
	powBG:SetAllPoints()
	powBG:SetTexture(BAR_TEXTURE)	
	powBar.bg = powBG
	powBar.bg.multiplier = 0.4
	
	-- Debuffs
	local debuffs = CreateFrame("Frame", nil, self)
	debuffs:SetPoint("TOPLEFT", self, "TOPRIGHT", 1, 0)
	debuffs:SetSize((AURA_SIZE) * 3, 100)
	self.Debuffs = debuffs
	self.Debuffs.num = 6
	self.Debuffs.showType = true
	self.Debuffs.initialAnchor = "TOPLEFT"
	self.Debuffs.size = AURA_SIZE
	self.Debuffs.spacing = 1
	self.Debuffs["growth-y"] = "DOWN"
	
	self.Debuffs.PostCreateIcon = function(debuffs, button)
		-- UGLY BORDERS
		button.icon:SetTexCoord(.08, .92, .08, .92)
		
		-- Reverse cooldown spiral
		button.cd:SetReverse(true)
	end
	
	-- Role
	local role = hpBar:CreateTexture(nil, "OVERLAY")
	role:SetSize(16, 16)
	role:SetPoint("LEFT", hpBar, "LEFT", 4, 0)
	self.LFDRole = role
	
	-- Unit name text
	local name = hpBar:CreateFontString(nil, "OVERLAY")
	name:SetFontObject("imon_text")
	name:SetJustifyH("LEFT")
	name:SetPoint("LEFT", role, "RIGHT", 4, 0)
	name.frequentUpdates = 0.1
	self:Tag(name, "[imon:name]")
	
	-- Unit health text (deficit)
	local hpText = hpBar:CreateFontString(nil, "OVERLAY")
	hpText:SetFontObject("imon_text")
	hpText:SetFont(LSM:Fetch("font", "Arial Narrow"), 20)
	hpText:SetJustifyH("RIGHT")
	hpText:SetPoint("RIGHT", hpBar, "RIGHT", -4, 0)
	hpText.frequentUpdates = 0.1
	self:Tag(hpText, "[imon:group:health]")
	
	-- Buff water text
	local bufftext = hpBar:CreateFontString(nil, "OVERLAY")
	bufftext:SetFontObject("imon_text")
	bufftext:SetJustifyH("LEFT")
	bufftext:SetPoint("CENTER", hpBar, "CENTER", 0, 0)
	self:Tag(bufftext, "[imon:missingbuffs]")
	
	-- Dynamic placement of role icon relative to name text
	local f = CreateFrame("Frame")
	f:RegisterEvent("PLAYER_ROLES_ASSIGNED")
	f:RegisterEvent("PARTY_MEMBERS_CHANGED")
	f:SetScript("OnEvent", function(self, event, ...)
		if (event == "PLAYER_ROLES_ASSIGNED" or event == "PARTY_MEMBERS_CHANGED") then
			if (role:IsVisible()) then
				role:SetPoint("LEFT", hpBar, "LEFT", 4, 0)
				name:SetPoint("LEFT", role, "RIGHT", 4, 0)
			else
				name:SetPoint("LEFT", hpBar, "LEFT", 4, 0)
			end
		end
	end)
end

oUF:RegisterStyle("imonRaid", imon.oUF.SharedParty)
oUF:Factory(function(self)
	oUF:SetActiveStyle("imonRaid")
	
	local raid = self:SpawnHeader("oUF_imonRaid", nil, "raid,party", --"custom [@raid26,exists] hide;show"
		"showParty", true, 
		"showPlayer", true, 
		"showRaid", true, 
		"groupFilter", "1,2,3,4,5,6,7,8", 
		"groupingOrder", "1,2,3,4,5,6,7,8", 
		"groupBy", "GROUP", 
		"yOffset", 0
	)
	raid:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 20, -175)	
end)