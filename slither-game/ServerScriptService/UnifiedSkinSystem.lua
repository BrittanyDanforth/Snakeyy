-- UNIFIED SKIN SYSTEM
-- Handles all skin operations in one place to prevent conflicts

print("🚀 UnifiedSkinSystem starting up...")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Skin name mappings (client -> server)
local SKIN_NAME_MAP = {
	["Default"] = "Classic",
	["Crimson"] = "Lava Red",
	["Arctic"] = "Arctic", -- Same name
	["Emerald"] = "Emerald", -- Same name
	["Void"] = "Void", -- Same name
	["Plasma"] = "Electric Purple",
	["Galaxy"] = "Galaxy", -- Same name
	["Ocean"] = "Ocean Blue",
	["Shadow"] = "Shadow", -- Same name
	["Cyber"] = "Cyberpunk",
	["Dragon"] = "Dragon Lord",
	["VIP Diamond"] = "VIP Diamond", -- Same name
	["VIP Inferno"] = "VIP Inferno", -- Same name
	["VIP Cosmic"] = "VIP Cosmic", -- Same name
	["Rainbow"] = "Rainbow Prism"
}

-- Reverse mapping (server -> client)
local REVERSE_MAP = {}
for client, server in pairs(SKIN_NAME_MAP) do
	REVERSE_MAP[server] = client
end

-- Get or create RemoteEvents
local function getOrCreateRemote(name)
	local remote = ReplicatedStorage:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = ReplicatedStorage
		print("✅ Created", name, "RemoteEvent")
	end
	return remote
end

local PurchaseItemRemote = getOrCreateRemote("PurchaseItem")
local SelectSkinRemote = getOrCreateRemote("SelectSkin")
local UpdateClientRemote = getOrCreateRemote("UpdateClientSkinData")
local PurchaseSuccessRemote = getOrCreateRemote("PurchaseSuccess")

-- Load SnakeSkins module
local SnakeSkins = nil
pcall(function()
	SnakeSkins = require(ReplicatedStorage:WaitForChild("SnakeSkins", 5))
end)

-- Player data storage
local PlayerData = {}

-- Get default player data
local function getDefaultData()
	return {
		coins = 50000,
		ownedSkins = {"Default"},
		selectedSkin = "Classic",
		clientSelectedSkin = "Default"
	}
end

-- Initialize player
local function initializePlayer(player)
	print("🎮 Initializing player:", player.Name)
	
	-- Get or create data
	local data = PlayerData[player] or getDefaultData()
	PlayerData[player] = data
	
	-- Create leaderstats
	local leaderstats = player:FindFirstChild("leaderstats") or Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	
	local coins = leaderstats:FindFirstChild("Coins") or Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = data.coins
	coins.Parent = leaderstats
	
	-- Set attributes
	player:SetAttribute("Coins", data.coins)
	player:SetAttribute("SelectedSkin", data.selectedSkin)
	player:SetAttribute("ClientSelectedSkin", data.clientSelectedSkin)
	player:SetAttribute("OwnedSkinsJSON", HttpService:JSONEncode(data.ownedSkins))
	
	-- Send initial data to client
	UpdateClientRemote:FireClient(player, {
		coins = data.coins,
		ownedSkins = data.ownedSkins,
		selectedSkin = data.clientSelectedSkin
	})
	
	print("✅ Player initialized with skin:", data.clientSelectedSkin)
end

-- Handle skin purchase
local function handlePurchase(player, itemName)
	if not itemName or not itemName:match("^skin_") then return end
	
	local skinName = itemName:sub(6) -- Remove "skin_" prefix
	local serverSkinName = SKIN_NAME_MAP[skinName] or skinName
	
	print("💰 Purchase request:", skinName, "->", serverSkinName)
	
	-- Check if skin exists
	if not SnakeSkins or not SnakeSkins[serverSkinName] then
		warn("❌ Skin not found:", serverSkinName)
		return
	end
	
	local data = PlayerData[player]
	if not data then return end
	
	-- Check if already owned
	if table.find(data.ownedSkins, skinName) then
		warn("❌ Already owned:", skinName)
		return
	end
	
	-- Check price
	local skinData = SnakeSkins[serverSkinName]
	local price = skinData.Price or 0
	
	if data.coins < price then
		warn("❌ Not enough coins:", data.coins, "<", price)
		return
	end
	
	-- Process purchase
	data.coins = data.coins - price
	table.insert(data.ownedSkins, skinName)
	
	-- Update player
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local coinsValue = leaderstats:FindFirstChild("Coins")
		if coinsValue then
			coinsValue.Value = data.coins
		end
	end
	
	player:SetAttribute("Coins", data.coins)
	player:SetAttribute("OwnedSkinsJSON", HttpService:JSONEncode(data.ownedSkins))
	
	-- Notify client
	PurchaseSuccessRemote:FireClient(player, skinName)
	UpdateClientRemote:FireClient(player, {
		coins = data.coins,
		ownedSkins = data.ownedSkins,
		selectedSkin = data.clientSelectedSkin
	})
	
	print("✅ Purchased:", skinName, "for", price, "coins")
end

-- Handle skin selection
local function handleSkinSelection(player, skinName)
	if not skinName then return end
	
	local data = PlayerData[player]
	if not data then return end
	
	-- Check ownership
	if not table.find(data.ownedSkins, skinName) then
		warn("❌ Skin not owned:", skinName)
		return
	end
	
	local serverSkinName = SKIN_NAME_MAP[skinName] or skinName
	
	-- Update data
	data.selectedSkin = serverSkinName
	data.clientSelectedSkin = skinName
	
	-- Set attributes
	player:SetAttribute("SelectedSkin", serverSkinName)
	player:SetAttribute("ClientSelectedSkin", skinName)
	
	-- Update client
	UpdateClientRemote:FireClient(player, {
		coins = data.coins,
		ownedSkins = data.ownedSkins,
		selectedSkin = skinName
	})
	
	print("✅ Selected skin:", skinName, "->", serverSkinName)
end

-- Connect events
PurchaseItemRemote.OnServerEvent:Connect(handlePurchase)
SelectSkinRemote.OnServerEvent:Connect(handleSkinSelection)

Players.PlayerAdded:Connect(initializePlayer)
Players.PlayerRemoving:Connect(function(player)
	PlayerData[player] = nil
end)

-- Initialize existing players
for _, player in Players:GetPlayers() do
	initializePlayer(player)
end

print("✅ Unified Skin System loaded")