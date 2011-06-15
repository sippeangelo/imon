if (not imon.cf.actionbars.enabled) then return end

local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")

local BAR_TEXTURE = LSM:Fetch("statusbar", "Minimalist")

local function CreateBG(self, r, g, b)
	local bg = self:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(BAR_TEXTURE)
	bg:SetVertexColor(r, g, b)
end

local imonBar1 = CreateFrame("Frame", "imonBar1", UIParent, "SecureHandlerStateTemplate")
imonBar1:SetSize(32 * 12, 32)
imonBar1:SetPoint("BOTTOMLEFT", 0, 0)
--CreateBG(imonBar1, 1, 1, 1)

local imonBar2 = CreateFrame("Frame", "imonBar2", UIParent)
imonBar2:SetSize(32 * 12, 32)
imonBar2:SetPoint("BOTTOMLEFT", imonBar1, "BOTTOMRIGHT", 0, 0)
--CreateBG(imonBar2, 1, 1, 0)

local imonBar3 = CreateFrame("Frame", "imonBar3", UIParent)
imonBar3:SetSize(32 * 12, 32)
imonBar3:SetPoint("BOTTOMLEFT", imonBar2, "BOTTOMRIGHT", 0, 0)
--CreateBG(imonBar3, 1, 0, 0)

local imonBar4 = CreateFrame("Frame", "imonBar4", UIParent)
imonBar4:SetSize(32 * 12, 32)
imonBar4:SetPoint("BOTTOMLEFT", imonBar3, "BOTTOMRIGHT", 0, 0)
--CreateBG(imonBar4, 0, 0, 1)

local imonBar5 = CreateFrame("Frame", "imonBar5", UIParent)
imonBar5:SetSize(32 * 12, 32)
imonBar5:SetPoint("BOTTOMLEFT", imonBar4, "BOTTOMRIGHT", 0, 0)
--CreateBG(imonBar5, 0, 1, 1)