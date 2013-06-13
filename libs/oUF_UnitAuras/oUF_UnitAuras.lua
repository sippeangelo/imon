local _, ns = ...
local oUF = oUF or ns.oUF

local function AlignToEachOther(t)
	local alignto = nil

	for k,v in pairs(t) do
		if (v:IsVisible()) then
			if (alignto ~= nil) then
				v:SetPoint("LEFT", alignto, "RIGHT")
			end
			
			alignto = v
		end
	end
end

local Update = function(self, event, unit)
	if(self.unit ~= unit) then return end

	local UnitAuras = self.UnitAuras
	if (UnitAuras) then
		if(UnitAuras.PreUpdate) then UnitAuras:PreUpdate(unit) end
	
		for _,aura in pairs({"Power Word: Shield", "Renew", "Prayer of Mending"}) do
			local _, _, icon, _, _, duration, expires = UnitAura(unit, aura)
		
			if (icon ~= nil) then
				if (UnitAuras.Icons[aura] == nil) then
					UnitAuras.Icons[aura] = UnitAuras:CreateTexture(nil, "OVERLAY")
					UnitAuras.Icons[aura]:SetSize(20, 20)
					UnitAuras.Icons[aura]:SetPoint("CENTER", UnitAuras, "CENTER")
					UnitAuras.Icons[aura]:SetTexture(icon)
					
					UnitAuras.Icons[aura].Cooldown = CreateFrame("Cooldown", nil, UnitAuras)
					UnitAuras.Icons[aura].Cooldown:SetSize(20, 20)
					UnitAuras.Icons[aura].Cooldown:SetPoint("CENTER", UnitAuras.Icons[aura], "CENTER")
					UnitAuras.Icons[aura].Cooldown:SetReverse(true)
					
				end	

				UnitAuras.Icons[aura]:Show()
				UnitAuras.Icons[aura].Cooldown:Show()
				UnitAuras.Icons[aura].Cooldown:SetCooldown(expires - duration, duration)
			else
				if (UnitAuras.Icons[aura]) then
					UnitAuras.Icons[aura]:Hide()
					UnitAuras.Icons[aura].Cooldown:Hide()
				end
			end
			
			AlignToEachOther(UnitAuras.Icons)	
		end

		if(UnitAuras.PostUpdate) then UnitAuras:PostUpdate(unit) end
	end
end

local ForceUpdate = function(element)
	return Update(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local Enable = function(self)
	if (self.UnitAuras) then
		self:RegisterEvent("UNIT_AURA", Update)

		local UnitAuras = self.UnitAuras
		if (UnitAuras) then
			UnitAuras.__owner = self
			UnitAuras.ForceUpdate = ForceUpdate
			UnitAuras.Icons = {}
		end

		return true
	end
end

local Disable = function(self)
	if(self.UnitAuras) then
		self:UnregisterEvent("UNIT_AURA", Update)
	end
end

oUF:AddElement("UnitAuras", Update, Enable, Disable)
