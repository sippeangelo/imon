if (not imon.cf.actionbars.enabled) then return end

local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")
local BAR_TEXTURE = LSM:Fetch("statusbar", "Minimalist")

-- Returns the action button name and the bar it belongs to
function GetActionButton(index)
	if (index >= 1 and index <= 12) then
		return _G["ActionButton" .. index], _G["imonBar1"], nil
	elseif (index >= 25 and index <= 36) then
		return _G["MultiBarRightButton" .. index - 24], _G["imonBar2"], _G["MultiBarBottomLeft"]
	elseif (index >= 37 and index <= 48) then
		return _G["MultiBarLeftButton" .. index - 36], _G["imonBar3"], _G["MultiBarBottomRight"]
	elseif (index >= 49 and index <= 60) then
		return _G["MultiBarBottomRightButton" .. index - 48], _G["imonBar4"], _G["MultiBarRight"]
	elseif (index >= 61 and index <= 72) then
		return _G["MultiBarBottomLeftButton" .. index - 60], _G["imonBar5"], _G["MultiBarLeft"]
	end
end

-- Actionbar container frame
local f = CreateFrame("Frame", "imonActionbars", UIParent)
f:SetHeight(33)
f:SetWidth(1920)
f:SetPoint("BOTTOMLEFT", 0, 0)
--local bg = f:CreateTexture(nil, "BACKGROUND")
--bg:SetAllPoints()
--bg:SetTexture(BAR_TEXTURE)
--bg:SetVertexColor(r, g, b)

-- Style all buttons
function StyleButton(self)
	local Name = self:GetName()
	local Border = _G[Name .. "Border"]
	local Icon = _G[Name .. "Icon"]
	
	self:SetNormalTexture("")
 	self:SetSize(32, 32)	
	
	Border:Hide()
	Border = function() end
	
	-- Expand the icons to remove ugly rounded borders
	Icon:SetTexCoord(.08, .92, .08, .92)
	--Icon:SetPoint("TOPLEFT", Button, 1, -1)
	--Icon:SetPoint("BOTTOMRIGHT", Button, -1, 1)	
	
	if not _G[Name.."Panel"] then
		local panel = CreateFrame("Frame", Name .. "Panel", self)

		panel:SetHeight(32)
		panel:SetWidth(32)
		
		panel:SetPoint("CENTER", self, "CENTER", 0, 0)
		
		panel:SetFrameStrata(self:GetFrameStrata())
		panel:SetFrameLevel(self:GetFrameLevel() - 1)
		
		panel.texture = panel:CreateTexture()
		panel.texture:SetTexture(0, 0, 0, 0.4)
		panel.texture:SetAllPoints(panel)
		
		--Button:SetParent(panel)
	end	
end
hooksecurefunc("ActionButton_Update", StyleButton)

-- Move and parent buttons
do
	-- Bar 1
	--[[for i = 1, 12 do
		local button = _G["ActionButton" .. i]
		button:ClearAllPoints()
		button:SetParent(imonBar1)
		if i == 1 then
			button:SetPoint("LEFT", 0, 0)
		else
			local prev = _G["ActionButton" .. i-1]
			button:SetPoint("LEFT", prev, "RIGHT", 0, 0)
		end
	end]]--

	-- Bar 1 - 5
	for i = 1, 72 do
		local button, bar, blizz_bar = GetActionButton(i)
		if (button ~= nil) then
			button:ClearAllPoints()
			
			-- Main action bar doesn't have a parent - parent buttons to imonBar1
			-- All other action buttons have a blizzard bar parent - parent blizzard bar to imonActionbars
			if (blizz_bar ~= nil) then
				blizz_bar:SetParent(imonActionbars)
			else
				button:SetParent(bar)
			end
			
			-- First button point is relative to it's bar (modulus ninja! :D)
			if (math.fmod(i, 12) == 1) then
				button:SetPoint("LEFT", bar, "LEFT", 0, 0)
				print(i .. " goes on ".. bar:GetName())
			else
				local prev = GetActionButton(i-1)
				button:SetPoint("LEFT", prev, "RIGHT", 0, 0)
			end
		end
	end

end