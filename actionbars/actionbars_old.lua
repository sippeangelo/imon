-- Hide blizzard stuff
do
	local elements = {
		MainMenuBar, MainMenuBarArtFrame, BonusActionBarFrame, VehicleMenuBar,
		PossessBarFrame, PetActionBarFrame, 
		ShapeshiftBarLeft, ShapeshiftBarMiddle, ShapeshiftBarRight,
	}
	for _, element in pairs(elements) do
		if element:GetObjectType() == "Frame" then
			element:UnregisterAllEvents()
		end
		element:Hide()
		element:SetAlpha(0)
	end
	elements = nil
end

local Page = {
	["DRUID"] = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
	["WARRIOR"] = "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;",
	["PRIEST"] = "[bonusbar:1] 7;",
	["ROGUE"] = "[bonusbar:1] 7; [form:3] 7;",
	["DEFAULT"] = "[bonusbar:5] 11; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;",
}

local function GetBar()
	local condition = Page["DEFAULT"]
	local class = T.myclass
	local page = Page[class]
	if page then
		condition = condition.." "..page
	end
	condition = condition.." 1"
	return condition
end

-- Actionbar background
local f = CreateFrame("Frame", "imon_Actionbars", UIParent)
f:SetFrameLevel(7)
f:SetHeight(32)
f:SetWidth(1920)
--f:SetFrameStrata("HIGH") -- Shouldn't be needed when parented to UIParent?
--f:SetPoint("BOTTOMLEFT", nil, "BOTTOMLEFT", 0, -32)
--[[
f.texture = f:CreateTexture()
f.texture:SetTexture(0, 0, 0, 0.7)
f.texture:SetAllPoints(f)
]]--
f:SetPoint("BOTTOMLEFT", 0, 0)
--f:SetAlpha(0.4)

function round(number, decimals)
    return tonumber((("%%.%df"):format(decimals)):format(number))
end

--imon.actionbars.gcd = nil
local gcd = nil

f:SetScript("OnUpdate", function(self, elapsed)
	cX, cY = GetCursorPosition()
	
	-- Figure out gcd
	--[[if (gcd == nil) then
		-- Find an ability on cooldown
		for i=1,120 do
			local start, duration, enable = GetActionCooldown(i)
			-- Global cooldown is always between 1 and 1.5 seconds
			if (duration >= 1 and duration <= 1.5 and enable == 1) then
				--print("A" .. i .. ": " .. start .. " " .. duration .. " " .. enable)
				-- Find another spell that started at the same time with the same cooldown
				for j=1,120 do
					if (j ~= i) then
						local start2, duration2, enable2 = GetActionCooldown(j)
						--print("B" .. j .. ": " .. start2 .. "?" .. start .. " " .. duration2 .. " " .. enable2)
						if (start == start2 and duration == duration2) then
							gcd = duration
							print("Captured GCD: " .. gcd)
							break
						else
							print("Non-gcd cooldown: " .. duration)
						end
					end
				end
			end
			
			if (gcd ~= nil) then
				break
			end
		end
	end--]]
	
	-- Figure out GCD by looking at a spell with 1.5 sec cast time (Scorch)
	local tgcd = gcd;
	_, _, _, _, _, _, gcd, _, _ = GetSpellInfo(2948)
	gcd = gcd / 1000 -- To seconds
	gcd = round(gcd, 2)
	if (gcd < 1) then
		gcd = 1
	end
	if (tgcd ~= gcd) then
		print("New GCD: " .. gcd)
	end
	
	-- Handle fading the button in/out depending on combat state and ability cooldowns
	for i=1,120 do
		local start, duration, enable = GetActionCooldown(i)
		
		duration = round(duration, 2)
		
		if (duration > 0 and enable == 1) then
			--print("On cooldown " .. i)
		end	
	
		local button = GetActionButton(i)
		
		if (button ~= nil) then 
			if (InCombatLockdown()) then
				if (button:GetAlpha() == 0) then
					button:SetAlpha(0.4)
				elseif (cY <= 32 and button:GetAlpha() ~= 1) then
					button:SetAlpha(1)
				elseif (button:GetAlpha() > 0.4) then
					button:SetAlpha(button:GetAlpha() - 0.05)
				end
			else
				if (cY > 32 and button:GetAlpha() ~= 0) then
					button:SetAlpha(button:GetAlpha() - 0.05)
				elseif (cY <= 32 and button:GetAlpha() ~= 1) then
					button:SetAlpha(1)
				end
			end
		
			-- Display abilities on cooldown without transparency
			--local start, duration, enable = GetActionCooldown(i)
			local alpha = button:GetAlpha()
			
			if (duration > 0 and duration ~= gcd and enable == 1 and alpha ~= 1) then
				button:SetAlpha(1)

				-- I want to know if the rounding goes south
				local difference = duration - gcd
				if (difference < 0) then
					difference = difference * -1
				end
				if (difference <= 0.01) then
					error("GCD filter rounding error!")
				end
			end
			

		end
	end
end)

f:Show()

function GetActionButton(index)
	if (index >= 1 and index <= 12) then
		return  _G["ActionButton" .. index]
	elseif (index >= 25 and index <= 36) then
		return  _G["MultiBarRightButton" .. index - 24]
	elseif (index >= 37 and index <= 48) then
		return  _G["MultiBarLeftButton" .. index - 36]
	elseif (index >= 49 and index <= 60) then
		return  _G["MultiBarBottomRightButton" .. index - 48]
	elseif (index >= 61 and index <= 72) then
		return  _G["MultiBarBottomLeftButton" .. index - 60]
	end
end

-- Actionbar hoverzone
--[[
f = CreateFrame("Frame", "imon_ActionbarsHoverzone", UIParent)
f:SetFrameLevel(10)
f:SetSize(imon_Actionbars:GetSize())
f:SetPoint("BOTTOMLEFT", 0, 0)

f.texture = f:CreateTexture()
f.texture:SetTexture(255, 255, 0, 0)
f.texture:SetAllPoints(f)

f:SetScript("OnEnter", function(self, motion)
	imon_Actionbars:SetAlpha(1)
end)

f:SetScript("OnLeave", function(self, motion)
	imon_Actionbars:SetAlpha(0.4)
end)

f:Show()

f:EnableMouse(false)

]]--

imon.debug.actionbars = f


-- /run DoFunStuffLol()
function DoFunStuffLol()
	
	
	-- Bar 1
	local button
	for i = 1, 12 do
		button = _G["ActionButton"..i]
		--button:SetSize(32, 32)
		button:ClearAllPoints()
		button:SetParent(imon_Actionbars)
		if i == 1 then
			button:SetPoint("LEFT", imon_Actionbars, 0, 0)
		else
			local previous = _G["ActionButton"..i-1]
			button:SetPoint("LEFT", previous, "RIGHT", 0, 0)
		end
	end
	
	-- Bar 2
	MultiBarBottomLeft:SetParent(imon_Actionbars)
	for i=1, 12 do
		local b = _G["MultiBarBottomLeftButton" .. i]
		local b2 = _G["MultiBarBottomLeftButton" .. i-1]
		b:ClearAllPoints()
		--b:SetParent(imon_Actionbars)
		if i == 1 then
			b:SetPoint("LEFT", ActionButton12, "RIGHT", 0, 0)
		else
			b:SetPoint("LEFT", b2, "RIGHT", 0, 0)
		end
	end
	
	-- Bar 3
	MultiBarBottomRight:SetParent(imon_Actionbars)
	for i=1, 12 do
		local b = _G["MultiBarBottomRightButton" .. i]
		local b2 = _G["MultiBarBottomRightButton" .. i-1]
		b:ClearAllPoints()
		--b:SetParent(imon_Actionbars)
		if i == 1 then
			b:SetPoint("LEFT", MultiBarBottomLeftButton12, "RIGHT", 0, 0)
		else
			b:SetPoint("LEFT", b2, "RIGHT", 0, 0)
		end
	end

	-- Bar 4
	MultiBarRight:SetParent(imon_Actionbars)
	for i=1, 12 do
		local b = _G["MultiBarRightButton" .. i]
		local b2 = _G["MultiBarRightButton" .. i-1]
		b:ClearAllPoints()
		--b:SetParent(imon_Actionbars)
		if i == 1 then
			b:SetPoint("LEFT", MultiBarBottomRightButton12, "RIGHT", 0, 0)
		else
			b:SetPoint("LEFT", b2, "RIGHT", 0, 0)
		end
	end
	
	-- Bar 5
	MultiBarLeft:SetParent(imon_Actionbars)
	for i=1, 12 do
		local b = _G["MultiBarLeftButton" .. i]
		local b2 = _G["MultiBarLeftButton" .. i-1]
		b:ClearAllPoints()
		--b:SetParent(imon_Actionbars)
		if i == 1 then
			b:SetPoint("LEFT", MultiBarRightButton12, "RIGHT", 0, 0)
		else
			b:SetPoint("LEFT", b2, "RIGHT", 0, 0)
		end
	end	
end
DoFunStuffLol()

function style(self)
	local name = self:GetName()
	local action = self.action
	local Button = self
	local Icon = _G[name.."Icon"]
	local Count = _G[name.."Count"]
	local Flash	 = _G[name.."Flash"]
	local HotKey = _G[name.."HotKey"]
	local Border  = _G[name.."Border"]
	local Btname = _G[name.."Name"]
	local normal  = _G[name.."NormalTexture"]

	Flash:SetTexture("")
	Button:SetNormalTexture("")
 	Button:SetSize(32, 32)	
	Button:SetAlpha(0)
	
	Border:Hide()
	Border = function() end
	
	if not _G[name.."Panel"] then
		local panel = CreateFrame("Frame", name .. "Panel", self)

		panel:SetHeight(32)
		panel:SetWidth(32)
		
		panel:SetPoint("CENTER", self, "CENTER", 0, 0)
		
		panel:SetFrameStrata(self:GetFrameStrata())
		panel:SetFrameLevel(self:GetFrameLevel() - 1)
		
		panel.texture = panel:CreateTexture()
		panel.texture:SetTexture(0, 0, 0, 0.4)
		panel.texture:SetAllPoints(panel)
		
		--Button:SetParent(panel)
		
		Icon:SetTexCoord(.08, .92, .08, .92)
		Icon:SetPoint("TOPLEFT", Button, 1, -1)
		Icon:SetPoint("BOTTOMRIGHT", Button, -1, 1)
	end
	
	--Count:ClearAllPoints()
	--Count:SetPoint("BOTTOMRIGHT", 0, 2)
	--Count:SetFont(TukuiCF["media"].font, 12, "OUTLINE")
 
	if (imon.cf.actionbars.showname == false) then
		Btname:SetText("")
		Btname:Hide()
		Btname.Show = function() end
	end
 
	--[[
	if not _G[name.."Panel"] then
		self:SetWidth(32)
		self:SetHeight(32)
 
		local panel = CreateFrame("Frame", name.."Panel", self)
		TukuiDB.CreatePanel(panel, TukuiDB.buttonsize, TukuiDB.buttonsize, "CENTER", self, "CENTER", 0, 0)
 
		panel:SetFrameStrata(self:GetFrameStrata())
		panel:SetFrameLevel(self:GetFrameLevel() - 1)
 
		Icon:SetTexCoord(.08, .92, .08, .92)
		Icon:SetPoint("TOPLEFT", Button, TukuiDB.Scale(2), TukuiDB.Scale(-2))
		Icon:SetPoint("BOTTOMRIGHT", Button, TukuiDB.Scale(-2), TukuiDB.Scale(2))
	end
	

	HotKey:ClearAllPoints()
	HotKey:SetPoint("TOPRIGHT", 0, TukuiDB.Scale(-3))
	HotKey:SetFont(TukuiCF["media"].font, 12, "OUTLINE")
	HotKey.ClearAllPoints = TukuiDB.dummy
	HotKey.SetPoint = TukuiDB.dummy
	
	
	if not TukuiCF["actionbar"].hotkey == true then
		HotKey:SetText("")
		HotKey:Hide()
		HotKey.Show = TukuiDB.dummy
	end
			]]--

 
	--[[if normal then
		normal:ClearAllPoints()
		normal:SetPoint("TOPLEFT")
		normal:SetPoint("BOTTOMRIGHT")
	end]]--
	
	local hover = Button:CreateTexture("frame", nil, self) -- hover
	hover:SetTexture(1,1,1,0.3)
	hover:SetHeight(Button:GetHeight())
	hover:SetWidth(Button:GetWidth())
	hover:SetPoint("TOPLEFT",Button,2,-2)
	hover:SetPoint("BOTTOMRIGHT",Button,-2,2)
	Button:SetHighlightTexture(hover)

	local pushed = Button:CreateTexture("frame", nil, self) -- pushed
	pushed:SetTexture(0.9,0.8,0.1,0.3)
	pushed:SetHeight(Button:GetHeight())
	pushed:SetWidth(Button:GetWidth())
	pushed:SetPoint("TOPLEFT",Button,2,-2)
	pushed:SetPoint("BOTTOMRIGHT",Button,-2,2)
	Button:SetPushedTexture(pushed)
 
	local checked = Button:CreateTexture("frame", nil, self) -- checked
	checked:SetTexture(0,1,0,0.3)
	checked:SetHeight(Button:GetHeight())
	checked:SetWidth(Button:GetWidth())
	checked:SetPoint("TOPLEFT",Button,2,-2)
	checked:SetPoint("BOTTOMRIGHT",Button,-2,2)
	Button:SetCheckedTexture(checked)
end
hooksecurefunc("ActionButton_Update", style)

--[[local f = CreateFrame("Frame",nil,UIParent)
f:SetFrameStrata("BACKGROUND")
f:SetWidth(128) -- Set these to whatever height/width is needed 
f:SetHeight(64) -- for your Texture

local t = f:CreateTexture(nil,"BACKGROUND")
t:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Factions.blp")
t:SetAllPoints(f)
f.texture = t

f:SetPoint("CENTER",0,0)
f:Show()]]--


print("Loaded actionbars lololol")