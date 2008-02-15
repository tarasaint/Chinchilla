local VERSION = tonumber(("$Revision$"):match("%d+"))

local Chinchilla = Chinchilla
local Chinchilla_Ping = Chinchilla:NewModule("Ping", "LibRockEvent-1.0")
local self = Chinchilla_Ping
if Chinchilla.revision < VERSION then
	Chinchilla.version = "1.0r" .. VERSION
	Chinchilla.revision = VERSION
	Chinchilla.date = ("$Date$"):match("%d%d%d%d%-%d%d%-%d%d")
end
local L = Rock("LibRockLocale-1.0"):GetTranslationNamespace("Chinchilla")

Chinchilla_Ping.desc = L["Show who last pinged the minimap"]

function Chinchilla_Ping:OnInitialize()
	self.db = Chinchilla:GetDatabaseNamespace("Ping")
	Chinchilla:SetDatabaseNamespaceDefaults("Ping", "profile", {
		chat = false,
		scale = 1,
		point = "TOP",
		relpoint = "TOP",
		background = {
			TOOLTIP_DEFAULT_BACKGROUND_COLOR.r,
			TOOLTIP_DEFAULT_BACKGROUND_COLOR.g,
			TOOLTIP_DEFAULT_BACKGROUND_COLOR.b,
			1
		},
		border = {
			TOOLTIP_DEFAULT_COLOR.r,
			TOOLTIP_DEFAULT_COLOR.g,
			TOOLTIP_DEFAULT_COLOR.b,
			1
		},
		textColor = {
			0.8,
			0.8,
			0.6,
			1
		}
	})
end

local frame
function Chinchilla_Ping:OnEnable()
	if not frame then
		frame = CreateFrame("Frame", "Chinchilla_Ping_Frame", MiniMapPing) -- anchor to MiniMapPing so that it hides/shows based on MiniMapPing
		frame:SetBackdrop({
			bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
			edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
			tile = true,
			tileSize = 16,
			edgeSize = 16,
			insets = {
				left = 4,
				right = 4,
				top = 4,
				bottom = 4
			}
		})
		frame:SetWidth(1)
		frame:SetHeight(1)
		local text = frame:CreateFontString(frame:GetName() .. "_FontString", "ARTWORK", "GameFontNormalSmall")
		frame.text = text
		text:SetPoint("CENTER")
	end
	frame:Show()
	self:AddEventListener("MINIMAP_PING")
end

function Chinchilla_Ping:OnDisable()
	frame:Hide()
end

local allowNextPlayerPing = false
function Chinchilla_Ping:MINIMAP_PING(ns, event, unit)
	if UnitIsUnit("player", unit) and not allowNextPlayerPing then
		frame:Hide()
		return
	end
	allowNextPlayerPing = false
	
	local name, server = UnitName(unit)
	if server and server ~= "" then
		name = name .. '-' .. server
	end
	local _, class = UnitClass(unit)
	local color = RAID_CLASS_COLORS[class]

	if self.db.profile.chat then
		DEFAULT_CHAT_FRAME:AddMessage(L["Minimap pinged by %s"]:format(("|cff%02x%02x%02x%s|r"):format(color.r*255, color.g*255, color.b*255, name)))
		return
	end
	frame:Show()
	
	frame.text:SetText(L["Ping by %s"]:format(("|cff%02x%02x%02x%s|r"):format(color.r*255, color.g*255, color.b*255, name)))
	frame:SetScale(self.db.profile.scale)
	frame:SetFrameLevel(MinimapCluster:GetFrameLevel()+5)
	frame:SetWidth(frame.text:GetWidth() + 12)
	frame:SetHeight(frame.text:GetHeight() + 12)
	frame.text:SetTextColor(unpack(self.db.profile.textColor))
	frame:SetBackdropColor(unpack(self.db.profile.background))
	frame:SetBackdropBorderColor(unpack(self.db.profile.border))
	frame:ClearAllPoints()
	frame:SetPoint(self.db.profile.point, Minimap, self.db.profile.relpoint)
end

Chinchilla_Ping:AddChinchillaOption({
	name = L["Ping"],
	desc = Chinchilla_Ping.desc,
	type = 'group',
	args = {
		test = {
			name = L["Test"],
			desc = L["Show a test ping"],
			type = 'execute',
			func = function()
				allowNextPlayerPing = true
				Minimap:PingLocation(0, 0)
			end,
			order = -1,
		},
		chat = {
			name = L["Show in chat"],
			desc = L["Show who pinged in chat instead of in a frame on the minimap."],
			type = 'boolean',
			get = function()
				return self.db.profile.chat
			end,
			set = function(value)
				self.db.profile.chat = value
			end
		},
		scale = {
			name = L["Size"],
			desc = L["Set the size of the ping display."],
			type = 'range',
			min = 0.25,
			max = 4,
			step = 0.01,
			bigStep = 0.05,
			isPercent = true,
			get = function()
				return self.db.profile.scale
			end,
			set = function(value)
				self.db.profile.scale = value
			end,
			hidden = function()
				return self.db.profile.chat
			end
		},
		background = {
			name = L["Background"],
			desc = L["Set the background color"],
			type = 'color',
			hasAlpha = true,
			get = function()
				return unpack(self.db.profile.background)
			end,
			set = function(r, g, b, a)
				local t = self.db.profile.background
				t[1] = r
				t[2] = g
				t[3] = b
				t[4] = a
			end,
			hidden = function()
				return self.db.profile.chat
			end
		},
		border = {
			name = L["Border"],
			desc = L["Set the border color"],
			type = 'color',
			hasAlpha = true,
			get = function()
				return unpack(self.db.profile.border)
			end,
			set = function(r, g, b, a)
				local t = self.db.profile.border
				t[1] = r
				t[2] = g
				t[3] = b
				t[4] = a
			end,
			hidden = function()
				return self.db.profile.chat
			end
		},
		textColor = {
			name = L["Text"],
			desc = L["Set the text color"],
			type = 'color',
			hasAlpha = true,
			get = function()
				return unpack(self.db.profile.textColor)
			end,
			set = function(r, g, b, a)
				local t = self.db.profile.textColor
				t[1] = r
				t[2] = g
				t[3] = b
				t[4] = a
			end,
			hidden = function()
				return self.db.profile.chat
			end
		},
		position = {
			name = L["Position"],
			desc = L["Set the position of the ping indicator"],
			type = 'choice',
			choices = {
				["BOTTOM;BOTTOM"] = L["Bottom, inside"],
				["TOP;BOTTOM"] = L["Bottom, outside"],
				["TOP;TOP"] = L["Top, inside"],
				["BOTTOM;TOP"] = L["Top, outside"],
				["TOPLEFT;TOPLEFT"] = L["Top-left"],
				["BOTTOMLEFT;BOTTOMLEFT"] = L["Bottom-left"],
				["TOPRIGHT;TOPRIGHT"] = L["Top-right"],
				["BOTTOMRIGHT;BOTTOMRIGHT"] = L["Bottom-right"]
			},
			get = function()
				return self.db.profile.point .. ";" .. self.db.profile.relpoint
			end,
			set = function(value)
				self.db.profile.point, self.db.profile.relpoint = value:match("(.*);(.*)")
			end,
			hidden = function()
				return self.db.profile.chat
			end
		}
	}
})
