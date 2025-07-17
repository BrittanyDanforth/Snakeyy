-- DEBUG SCRIPT: Identify actual skin names
-- Run this temporarily to see what skin names your server is using

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for modules to load
task.wait(3)

print("🔍 === SKIN NAME DEBUG ===")

-- Check SnakeSkins module
local SnakeSkins = ReplicatedStorage:FindFirstChild("SnakeSkins")
if SnakeSkins then
	local success, skins = pcall(function()
		return require(SnakeSkins)
	end)
	
	if success then
		print("✅ SnakeSkins module found. Available skins:")
		for skinName, skinData in pairs(skins) do
			print("  -", skinName, "(Price:", skinData.Price or "N/A", ")")
		end
	else
		print("❌ Failed to load SnakeSkins module:", skins)
	end
else
	print("❌ SnakeSkins module not found in ReplicatedStorage")
end

print("\n📝 Based on your error logs, your server expects these skin names:")
print("  - Ocean Blue (not Ocean)")
print("  - Galaxy ✓")
print("  - Electric Purple (not found in client)")
print("  - Classic (not Default)")
print("  - Phantom Viper (not found in client)")
print("  - Lava Red (not Crimson)")
print("  - Cyberpunk (not Cyber)")
print("  - Dragon Lord (not Dragon)")
print("  - Rainbow Prism (not Rainbow)")
print("  - Golden Emperor (not found in client)")
print("  - Toxic Green (not found in client)")

print("\n🔧 To fix this:")
print("1. Update your server's SnakeSkins module to use the same names as the client")
print("2. OR update the SKIN_NAME_MAP in SkinSystemFix.lua")
print("3. OR update your ShopUI to use the server's skin names")

print("\n⚠️ This is a debug script - disable or delete it after debugging!")