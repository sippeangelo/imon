local oUF = imonoUF
local cf = imon.cf
local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")

local function Create(uf)
	-------------------------------------------
	-- HEALTH
	-------------------------------------------
	-- Container
	local Health = CreateFrame("Frame", nil, uf)
	Health:SetSize(BAR_WIDTH, HEALTH_HEIGHT)
	Health:SetPoint("TOP", uf, "TOP", 0, 0)

		-- Bar
		local bar = CreateFrame("StatusBar", nil, Health)
		bar:SetStatusBarTexture(BAR_TEXTURE)
		bar:SetAllPoints()
		--bar:SetPoint("TOP", Health, "TOP", 0, 0)
		--bar:SetSize(BAR_WIDTH, HEALTH_HEIGHT)
		bar.frequentUpdates = true
		bar.colorTapped = true
		bar.colorClass = true
		bar.colorReaction = true
		bar.colorDisconnected = true
		
		-- Background
		local background = bar:CreateTexture(nil, "BORDER")
		background:SetAllPoints()
		background:SetTexture(BAR_TEXTURE)
		bar.bg = background
		bar.bg.multiplier = 0.4
		
		-- Name text
		local name = bar:CreateFontString(nil, "OVERLAY")
		name:SetFontObject("imon_text")
		name:SetJustifyH("LEFT")
		name:SetPoint("LEFT", bar, "LEFT", 4, 0)
		name.frequentUpdates = 0.1
		uf:Tag(name, "[imon:name]")
		
		-- Health text
		local text = bar:CreateFontString(nil, "OVERLAY")
		text:SetFontObject("imon_text")
		text:SetJustifyH("RIGHT")
		text:SetPoint("RIGHT", bar, "RIGHT", -4, 0)
		text.frequentUpdates = true
		uf:Tag(text, "[imon:health]")
end

imon:RegisterModule("health", Create)