--	///////////////////////////////////////////////////////////////////////////////////////////
--
--	TameTheBeastWithin v@project-version@
--	Author: SLOKnightfall

--	TameTheBeastWithin: 
--	///////////////////////////////////////////////////////////////////////////////////////////


local _G = _G
if not (select(2, _G.UnitRace("player")) == "Worgen") then return end

TameTheBeastWithin = LibStub("AceAddon-3.0"):NewAddon("TameTheBeastWithin","AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TameTheBeastWithin", silent)
local private = {}

local playerClass = select(3, _G.UnitClass("player"))
local TWO_FORMS = GetSpellInfo(68996)
local updateForm = false
local inCombat = false
local druid_Delay = false

local modelFrame = _G.CreateFrame("PlayerModel")
local ModelFileIDs = { [1000764]="Human Female", [1011653]="Human Male" }

local btn = _G.CreateFrame("Button", "TTBI_BUTTON", UIParent, "SecureActionButtonTemplate")
btn:SetAttribute("type", "spell")
btn:SetAttribute("unit", "player")
btn:SetAttribute("spell", TWO_FORMS)
btn:SetScript("PreClick", function() private.PreClick() end )
btn:SetScript("PostClick", function() private.PostClick() end )


--Default Settings
local defaults = {
	profile = {
		['*']  = false,
		enable = true,
		customEmote = L.DEFAULT_EMOTE,
		customText = L.DEFAULT_TEXT,
		keybinding = "BUTTON1",
	}
}

--Ace3 Menu Settings
local options = {
	name = "TameTheBeastWithin",
	handler = TameTheBeastWithin,
	type = 'group',
	args = {
		settings = {
			name = "Settings",
			handler = TameTheBeastWithin,
			type = 'group',
			order = 0,
			args = {
				enable = {
					name = L.ENABLE,
					type = "toggle",
					set = function(info,val) TameTheBeastWithin.db.profile.enable = val end,
					get = function(info) return TameTheBeastWithin.db.profile.enable end,
					order = 1,
					width = "full",
				},
				playEmote = {
					name = L.EMOTE,
					type = "toggle",
					set = function(info,val) TameTheBeastWithin.db.profile.playEmote = val end,
					get = function(info) return TameTheBeastWithin.db.profile.playEmote end,
					order = 1,
					width = "full",
				},
				customEmote = {
					name = "",
					type = "input",
					set = function(info,val) TameTheBeastWithin.db.profile.customEmote = val end,
					get = function(info) return TameTheBeastWithin.db.profile.customEmote end,
					order = 2,
					width = "full",
				},
				sayText = {
					name = L.TEXT,
					type = "toggle",
					set = function(info,val) TameTheBeastWithin.db.profile.sayText = val end,
					get = function(info) return TameTheBeastWithin.db.profile.sayText end,
					order = 3,
					width = "full",
				},
				customText = {
					name = "",
					type = "input",
					set = function(info,val) TameTheBeastWithin.db.profile.customText = val end,
					get = function(info) return TameTheBeastWithin.db.profile.customText end,
					order = 4,
					width = "full",
				},
				sheathWeapon = {
					name = L.SHEATH_WEAPON,
					type = "toggle",
					set = function(info,val) TameTheBeastWithin.db.profile.sheathWeapon = val end,
					get = function(info) return TameTheBeastWithin.db.profile.sheathWeapon end,
					order = 5,
					width = "full",
				},
				keyBinding = {
					name = L.KEYBIND,
					type = "keybinding",
					set = function(info,val) TameTheBeastWithin.db.profile.keybinding = val end,
					get = function(info) return TameTheBeastWithin.db.profile.keybinding end,
					order = 5,
					width = "full",
				},
			},
		},
	},
}


---Ace based addon initilization
---------
function TameTheBeastWithin:OnInitialize()
---------
	self.db = LibStub("AceDB-3.0"):New("TameTheBeastWithinDB", defaults)
	options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("TameTheBeastWithin", options)

	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("TameTheBeastWithin", "TameTheBeastWithin")

	--self.db.RegisterCallback(self, "OnProfileChanged", "ChangeProfile")
	--self.db.RegisterCallback(self, "OnProfileCopied", "ChangeProfile")
	--self.db.RegisterCallback(self, "OnProfileReset", "ResetProfile")
	--self.db.RegisterCallback(self, "OnNewProfile", "ResetProfile")
end


---------
function TameTheBeastWithin:OnEnable()
---------
  	--Link local lists to profile data
	--GlobalPrefs = self.db.profile.GlobalPrefs or {}

	TameTheBeastWithin:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEvent")
	TameTheBeastWithin:RegisterEvent("PLAYER_REGEN_ENABLED", "OnEvent")
	TameTheBeastWithin:RegisterEvent("UPDATE_SHAPESHIFT_FORM", "OnEvent")
end


---------
function TameTheBeastWithin:OnEvent(event, arg1, ...)
---------
	if event == "PLAYER_REGEN_DISABLED" then
		updateForm = true

	elseif (event == "PLAYER_REGEN_ENABLED"  or event == "UPDATE_SHAPESHIFT_FORM") and TameTheBeastWithin.db.profile.enable then
		local inCombat = InCombatLockdown()
		if not inCombat and updateForm then private.CheckForm() end	
	end
end


---------
local function SetBindings()
---------
	SetOverrideBindingClick(btn, true, TameTheBeastWithin.db.profile.keybinding, btn:GetName())
	updateForm = false
end


local form = 0
---------
function private.CheckForm()
---------
	--druid check
	if playerClass == 11 then
		form = GetShapeshiftForm()
	else
		form = 0
	end

	if form == 0 then
		druid_Delay = false

		if updateForm == false then
			ClearOverrideBindings(btn)
			return
		else
			modelFrame:SetUnit("player")

			local modelName = modelFrame:GetModelFileID()
			if ModelFileIDs[modelName] == nil then
			-- You are in Worgen Form
				SetBindings()

			else
			-- You are in Human Form
				ClearOverrideBindings(btn)
				updateForm = false
			end
		end

	else
	--Delay due to being in shape shift form
		druid_Delay = true
		--print("Druid Form Delay")
	end
end


---------
function private.PreClick()
---------
	if TameTheBeastWithin.db.profile.sheathWeapon then
	--print("S")
	ToggleSheath()
	end

end


---------
function private.PostClick()
---------
	private.CheckForm()

	if TameTheBeastWithin.db.profile.playEmote then
		SendChatMessage(TameTheBeastWithin.db.profile.customEmote ,"EMOTE")
	end

	if TameTheBeastWithin.db.profile.sayText then
		SendChatMessage(TameTheBeastWithin.db.profile.customText ,"SAY")
	end
end