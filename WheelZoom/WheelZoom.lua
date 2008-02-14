local VERSION = tonumber(("$Revision$"):match("%d+"))

local Chinchilla = Chinchilla
local Chinchilla_WheelZoom = Chinchilla:NewModule("WheelZoom")
local self = Chinchilla_WheelZoom
if Chinchilla.revision < VERSION then
	Chinchilla.version = "1.0r" .. VERSION
	Chinchilla.revision = VERSION
	Chinchilla.date = ("$Date$"):match("%d%d%d%d%-%d%d%-%d%d")
end
local L = Chinchilla:L("Chinchilla_WheelZoom")

Chinchilla_WheelZoom.desc = L["Use the mouse wheel to zoom in and out on the minimap."]

function Chinchilla_WheelZoom:OnInitialize()
	self.db = Chinchilla:GetDatabaseNamespace("WheelZoom")
	Chinchilla:SetDatabaseNamespaceDefaults("WheelZoom", "profile", {
	})
end

local frame
function Chinchilla_WheelZoom:OnEnable()
	if not frame then
		frame = CreateFrame("Frame", "Chinchilla_WheelZoom_Frame", Minimap)
		frame:SetAllPoints(Minimap)
		frame:SetScript("OnMouseWheel", function(this, change)
			if change > 0 then
				Minimap_ZoomIn()
			else
				Minimap_ZoomOut()
			end
		end)
	end
	frame:EnableMouseWheel(true)
end

function Chinchilla_WheelZoom:OnDisable()
	frame:EnableMouseWheel(false)
end

Chinchilla_WheelZoom:AddChinchillaOption({
	name = L["Wheel zoom"],
	desc = Chinchilla_WheelZoom.desc,
	type = 'group',
	args = {
	}
})
