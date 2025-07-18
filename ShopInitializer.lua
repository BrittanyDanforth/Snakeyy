-- Shop Initializer Script
-- This script ensures the shop system is properly initialized when the game starts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer

-- Wait for character to ensure everything is loaded
localPlayer.CharacterAdded:Connect(function(character)
	wait(1) -- Give time for other systems to load
	
	-- Check if ShopUI is available
	if _G.ShopUI then
		print("🏪 Initializing Shop System...")
		
		-- Create the shop (this will make it available for ShopManager)
		_G.ShopUI.Create()
		
		-- Close it immediately so it doesn't show on spawn
		wait(0.1)
		if _G.ShopUI.close then
			_G.ShopUI.close()
		end
		
		print("✅ Shop System initialized and ready!")
		print("💡 Press F to open the shop")
	else
		warn("❌ ShopUI not found in _G")
	end
end)

-- Also initialize on first run if character already exists
if localPlayer.Character then
	wait(2) -- Wait for systems to load
	if _G.ShopUI then
		print("🏪 Initializing Shop System (character already exists)...")
		_G.ShopUI.Create()
		wait(0.1)
		if _G.ShopUI.close then
			_G.ShopUI.close()
		end
		print("✅ Shop System initialized and ready!")
	end
end