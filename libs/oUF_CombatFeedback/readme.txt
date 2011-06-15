This is an addon that adds CombatFeedback to the oUF unitframes.

It will display +100 on the frame when someone gets healed for 100 and -100 when someone gets damaged.
It will also display block, miss etc.

To use this in your oUF layout you will need a CombatFeedbackText member on your oUF unit object (self):

	local cbft = self:CreateFontString(nil, "OVERLAY")
	cbft:SetPoint("CENTER", self, "CENTER")
	cbft:SetFontObject(GameFontNormal)
	self.CombatFeedbackText = cbft
	
Note: this usually places the CombatFeedbackText below the statusbars etc, so you might want to do:
	local cbft = hpbar:CreateFontString(nil, "OVERLAY")
where hpbar is your hitpoints bar.

The combattext fades in and out when the damage happens, you can control the fading on a per unitframe basis by setting the .maxAlpha member
on the CombatFeedbackText string:

	self.CombatFeedbackText.maxAlpha = .8
	
The default value is .6

You can ignore messages on a per unitframe basis using the following:

	self.CombatFeedbackText.ignoreImmune = true -- ignore 'immune' reports
	self.CombatFeedbackText.ignoreDamage = true -- ignore damage hits, blocks, misses, parries etc.
	self.CombatFeedbackText.ignoreHeal = true -- ignore heals 
	self.CombatFeedbackText.ignoreEnergize = true -- ignore energize events
	self.CombatFeedbackText.ignoreOther = true  -- ignore everything else

The default will show everything.

You can change the colors by setting a .colors table on the CombatFeedbackText.

The default colors table is:

local colors = {
	STANDARD		= { 1, 1, 1 }, -- color for everything not in the list below
	-- damage colors
	IMMUNE			= { 1, 1, 1 },
	DAMAGE			= { 1, 0, 0 },
	CRUSHING		= { 1, 0, 0 },
	CRITICAL		= { 1, 0, 0 },
	GLANCING		= { 1, 0, 0 },
	ABSORB			= { 1, 1, 1 },
	BLOCK			= { 1, 1, 1 },
	RESIST			= { 1, 1, 1 },
	MISS			= { 1, 1, 1 },
	-- heal colors
	HEAL			= { 0, 1, 0 },
	CRITHEAL		= { 0, 1, 0 },
	-- energize colors
	ENERGIZE		= { 0.41, 0.8, 0.94 },
	CRITENERGIZE	= { 0.41, 0.8, 0.94 },
}

You can override one or more:

self.CombatFeedbackText.colors = {
	DAMAGE = {0,1,1},
	CRITHEAL = {0,0,1},
}


Enjoy

-Ammo 