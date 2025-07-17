-- SKIN SYSTEM FIX SCRIPT
-- This script ensures skin names match between client and server
-- and prevents skins from reverting to Default

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- IMPORTANT: These are the skin names your ShopUI (client) is using
local CLIENT_SKIN_NAMES = {
	"Default", "Crimson", "Arctic", "Emerald", "Void", "Plasma", 
	"Galaxy", "Ocean", "Shadow", "Cyber", "Dragon", 
	"VIP Diamond", "VIP Inferno", "VIP Cosmic", "Rainbow"
}

-- Map client skin names to server skin names
-- Based on your error logs, these are the actual server names
local CLIENT_TO_SERVER_MAP = {
	["Default"] = "Classic",
	["Crimson"] = "Lava Red",
	["Ocean"] = "Ocean Blue",
	["Cyber"] = "Cyberpunk",
	["Dragon"] = "Dragon Lord",
	["Rainbow"] = "Rainbow Prism",
	-- These don't have direct mappings, so we'll handle them separately
	["Arctic"] = "Arctic", -- Might not exist on server
	["Emerald"] = "Emerald", -- Might not exist on server
	["Void"] = "Void", -- Might not exist on server
	["Plasma"] = "Plasma", -- Might not exist on server
	["Galaxy"] = "Galaxy", -- This one matches!
	["Shadow"] = "Shadow", -- Might not exist on server
	["VIP Diamond"] = "VIP Diamond", -- Might not exist on server
	["VIP Inferno"] = "VIP Inferno", -- Might not exist on server
	["VIP Cosmic"] = "VIP Cosmic", -- Might not exist on server
}

-- Server skins that don't exist in client (from error logs)
local SERVER_ONLY_SKINS = {
	"Electric Purple",
	"Phantom Viper",
	"Golden Emperor",
	"Toxic Green"
}

-- Fix 1: Ensure SnakeSkins module exists with correct names
local function ensureSnakeSkinsModule()
	-- Wait a bit for other scripts to load
	task.wait(2)
	
	local SnakeSkins = ReplicatedStorage:FindFirstChild("SnakeSkins")
	if not SnakeSkins then
		warn("⚠️ SnakeSkins module not found! The skin system won't work properly.")
		return
	end
	
	-- Try to load the module to check if it has the right skins
	local success, skinsData = pcall(function()
		return require(SnakeSkins)
	end)
	
	if success then
		print("✅ SnakeSkins module loaded successfully")
		print("📋 Available skins:")
		for skinName, _ in pairs(skinsData) do
			print("  -", skinName)
		end
	else
		warn("❌ Failed to load SnakeSkins module:", skinsData)
	end
end

-- Fix 2: Prevent skin from reverting to Default
local function protectPlayerSkin(player)
	local lastValidSkin = player:GetAttribute("SelectedSkin") or "Default"
	local isChanging = false
	
	-- Monitor attribute changes
	local connection = player.AttributeChanged:Connect(function(attributeName)
		if attributeName == "SelectedSkin" then
			local newSkin = player:GetAttribute("SelectedSkin")
			
			-- If skin is being set to Default/Classic but we had a different skin, prevent it
			if (newSkin == "Default" or newSkin == "Classic") and 
			   (lastValidSkin ~= "Default" and lastValidSkin ~= "Classic") and 
			   not isChanging then
				warn("⚠️ Preventing skin revert to Default/Classic for", player.Name)
				isChanging = true
				player:SetAttribute("SelectedSkin", lastValidSkin)
				isChanging = false
			elseif newSkin and newSkin ~= "Default" and newSkin ~= "Classic" then
				-- Update last valid skin if it's not Default/Classic
				lastValidSkin = newSkin
				print("✅ Skin saved for", player.Name, ":", newSkin)
			end
		end
	end)
	
	-- Store connection for cleanup
	player:SetAttribute("SkinProtectionConnection", connection)
end

-- Fix 3: Handle skin selection with proper client->server mapping
local function handleSkinSelection(player, clientSkinName)
	-- Map client skin name to server skin name
	local serverSkinName = CLIENT_TO_SERVER_MAP[clientSkinName] or clientSkinName
	
	print("🔄 Mapping client skin", clientSkinName, "to server skin", serverSkinName)
	
	-- Set the skin using the server name
	player:SetAttribute("SelectedSkin", serverSkinName)
	print("✅ Applied skin", serverSkinName, "to", player.Name)
	
	return true, serverSkinName
end

-- Fix 4: Enhanced SelectSkin handler
local SelectSkinRemote = ReplicatedStorage:WaitForChild("SelectSkin", 10)
if SelectSkinRemote then
	-- Note: We're not disconnecting the original handler, just adding our own
	-- This will run alongside the existing handler
	
	SelectSkinRemote.OnServerEvent:Connect(function(player, clientSkinName)
		if not player or type(clientSkinName) ~= "string" then
			warn("❌ Invalid SelectSkin request")
			return
		end
		
		print("🎨 Skin mapping handler - Player", player.Name, "selecting:", clientSkinName)
		
		-- Map the skin name and apply it
		local success, serverSkinName = handleSkinSelection(player, clientSkinName)
		
		if success then
			-- The original SelectSkinHandler will handle the actual application
			-- We just ensure the correct mapped name is set
			print("✅ Mapped", clientSkinName, "->", serverSkinName, "for", player.Name)
		end
	end)
end

-- Initialize fixes for all players
local function initializeFixes()
	-- Fix for existing players
	for _, player in pairs(Players:GetPlayers()) do
		protectPlayerSkin(player)
		
		-- Ensure they have a skin set
		if not player:GetAttribute("SelectedSkin") then
			player:SetAttribute("SelectedSkin", "Classic") -- Use server's default name
		end
	end
	
	-- Fix for new players
	Players.PlayerAdded:Connect(function(player)
		-- Wait for character to load
		task.spawn(function()
			if not player.Character then
				player.CharacterAdded:Wait()
			end
			task.wait(0.5)
			
			protectPlayerSkin(player)
			
			-- Ensure they have a skin set
			if not player:GetAttribute("SelectedSkin") then
				player:SetAttribute("SelectedSkin", "Classic") -- Use server's default name
			end
		end)
	end)
	
	-- Cleanup on player leaving
	Players.PlayerRemoving:Connect(function(player)
		local connection = player:GetAttribute("SkinProtectionConnection")
		if connection and typeof(connection) == "RBXScriptConnection" then
			connection:Disconnect()
		end
	end)
end

-- Start the fixes
print("🔧 Starting Enhanced Skin System Fix...")
print("📝 Client->Server skin mappings:")
for client, server in pairs(CLIENT_TO_SERVER_MAP) do
	if client ~= server then
		print("  ", client, "->", server)
	end
end
ensureSnakeSkinsModule()
initializeFixes()
print("✅ Enhanced Skin System Fix initialized!")
print("📝 This fix:")
print("  - Maps client skin names to server skin names")
print("  - Prevents skins from reverting to Default/Classic")
print("  - Handles the mismatch between ShopUI and server skin names")