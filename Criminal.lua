if(select(2, UnitClass('player')) ~= 'ROGUE') then return end

local addon = ...

local button = CreateFrame('Button', addon, UIParent, 'SecureActionButtonTemplate, AutoCastShineTemplate')
local macro = '/cast %s\n/use %s %s'
local spell = GetSpellInfo(1804)

local LOCKED_SKILL = ERR_USE_LOCKED_WITH_SPELL_KNOWN_SI:gsub('%%s', (GetSpellInfo(1810))):gsub('%%d', '%(.*%)')

local function ScanTooltip(text)
	for index = 1, GameTooltip:NumLines() do
		if(string.match(_G['GameTooltipTextLeft'..index]:GetText(), text)) then
			return true
		end
	end
end

local function Clickable()
	return not InCombatLockdown() and IsAltKeyDown()
end

local function Disperse(self)
	if(InCombatLockdown()) then
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
	else
		self:Hide()
		self:ClearAllPoints()
		AutoCastShine_AutoCastStop(self)
	end
end

function button:MODIFIER_STATE_CHANGED(event, key)
	if(self:IsShown() and (key == 'LALT' or key == 'RALT')) then
		Disperse(self)
	end
end

function button:PLAYER_REGEN_ENABLED(event)
	self:UnregisterEvent(event)
	Disperse(self)
end

GameTooltip:HookScript('OnTooltipSetItem', function(self)
	local item = self:GetItem()
	if(item and Clickable()) then
		if(ScanTooltip(LOCKED) and ScanTooltip(LOCKED_SKILL)) then
			local bag, slot = GetMouseFocus():GetParent(), GetMouseFocus()

			if(GetContainerItemInfo(bag:GetID(), slot:GetID())) then
				button:SetAttribute('macrotext', string.format(macro, spell, slot:GetParent():GetID(), slot:GetID()))
			elseif(slot:GetName() == 'TradeRecipientItem7ItemButton') then
				button:SetAttribute('macrotext', string.format('/cast %s', spell))
			end

			button:SetAllPoints(slot)
			button:Show()
			AutoCastShine_AutoCastStart(button, 0, 1, 1)
		end
	end
end)

do
	button:SetScript('OnLeave', Disperse)
	button:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
	button:SetFrameStrata('DIALOG')
	button:RegisterEvent('MODIFIER_STATE_CHANGED')
	button:RegisterForClicks('LeftButtonUp')
	button:SetAttribute('*type*', 'macro')
	button:Hide()

	for _, sparks in pairs(button.sparkles) do
		sparks:SetHeight(sparks:GetHeight() * 3)
		sparks:SetWidth(sparks:GetWidth() * 3)
	end
end
