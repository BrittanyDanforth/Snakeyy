-- Quick Fix for Shop System
-- Place this in StarterPlayerScripts

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- Wait a bit for everything to load
task.wait(2)

-- Load ShopUI module
local ShopUI = require(ReplicatedStorage:WaitForChild("ShopUI"))

-- Make it globally accessible
_G.ShopUI = ShopUI

-- Initialize the shop
print("🏪 Initializing Shop...")
local success, err = pcall(function()
	ShopUI.init()
end)

if success then
	print("✅ Shop initialized successfully!")
	print("💡 Press F to open the shop")
else
	warn("❌ Failed to initialize shop:", err)
end

-- Also make sure the shop GUI is created but hidden
task.wait(1)
if ShopUI.init then
	local gui = ShopUI.init()
	if gui then
		gui.Enabled = false
		print("✅ Shop GUI created and ready")
	end
end