if (not imon.cf.actionbars.enabled) then return end

local bar = imonBar1

local Page = {
	["DRUID"] = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
	["WARRIOR"] = "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;",
	["PRIEST"] = "[bonusbar:1] 7;",
	["ROGUE"] = "[bonusbar:1] 7; [form:3] 7;",
	["DEFAULT"] = "[bonusbar:5] 11; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;",
}

local function GetBar()
	local condition = Page["DEFAULT"]
	local class = "DRUID"
	local page = Page[class]
	if page then
		condition = condition .. " " .. page
	end
	condition = condition .. " 1"
	return condition
end

bar:RegisterEvent("PLAYER_LOGIN")
bar:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		-- Shapeshift actionbars
		for i = 1, 12 do
			self:SetFrameRef("ActionButton" .. i, _G["ActionButton" .. i])
		end	
		self:SetAttribute("_onstate-page", [[ 
			for i = 1, 12 do
				local button = self:GetFrameRef("ActionButton" .. i)
				button:SetAttribute("actionpage", tonumber(newstate))
			end
		]])
		RegisterStateDriver(self, "page", GetBar())
	end
end)