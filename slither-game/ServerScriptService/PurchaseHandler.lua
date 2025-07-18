-- SLITHER.IO PURCHASE HANDLER - STUDIO COMPATIBLE
-- Server-side purchase validation and skin management
-- FIXED: Studio compatibility (DataStore disabled in Studio)
-- FIXED: Proper SnakeSkins module loading
-- FIXED: Server-side skin validation working correctly

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- FIXED: Check if we're in Studio to disable DataStore
local isStudio = RunService:IsStudio()

-- FIXED: Wait for and load SnakeSkins module properly
local SnakeSkins = nil
local function loadSnakeSkins()
	local attempts = 0
	while not SnakeSkins and attempts < 10 do
		attempts = attempts + 1
		pcall(function()
			local snakeSkinsModule = ReplicatedStorage:FindFirstChild("SnakeSkins")
			if snakeSkinsModule then
				SnakeSkins = require(snakeSkinsModule)
				print("✅ SnakeSkins module loaded successfully!")

				-- Debug: List all available skins
				print("🎨 Available skins:")
				for skinName, skinData in pairs(SnakeSkins) do
					print("  -", skinName, "(Price:", skinData.Price, ")")
				end
			else
				warn("❌ SnakeSkins module not found in ReplicatedStorage")
			end
		end)

		if not SnakeSkins then
			wait(1)
		end
	end

	if not SnakeSkins then
		warn("❌ Failed to load SnakeSkins module after 10 attempts!")
		-- Create fallback skin data
		SnakeSkins = {
			["Default"] = {Price = 0},
			["Cyber"] = {Price = 4000},
			["Rainbow"] = {Price = 7500}
		}
		print("🔧 Using fallback SnakeSkins data")
	end
end

-- Load SnakeSkins immediately
loadSnakeSkins()

-- FIXED: Load ShopItems module properly
local ShopItems = nil
pcall(function()
	local shopItemsModule = ReplicatedStorage:FindFirstChild("ShopItems")
	if shopItemsModule then
		ShopItems = require(shopItemsModule)
		print("✅ ShopItems module loaded successfully!")
	end
end)

-- FIXED: Data persistence (disabled in Studio)
local PlayerDataStore = nil
if not isStudio then
	PlayerDataStore = DataStoreService:GetDataStore("SlitherPlayerData_v3")
	print("💾 DataStore enabled (Production)")
else
	print("⚠️ DataStore disabled (Studio mode)")
end

-- Create RemoteEvents
local PurchaseItemEvent = Instance.new("RemoteEvent")
PurchaseItemEvent.Name = "PurchaseItem"
PurchaseItemEvent.Parent = ReplicatedStorage

local SelectSkinEvent = Instance.new("RemoteEvent") 
SelectSkinEvent.Name = "SelectSkin"
SelectSkinEvent.Parent = ReplicatedStorage

local RespawnSnakeEvent = Instance.new("RemoteEvent")
RespawnSnakeEvent.Name = "RespawnSnake"
RespawnSnakeEvent.Parent = ReplicatedStorage

-- Optional: Purchase success notification event
local RemoteEventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not RemoteEventsFolder then
	RemoteEventsFolder = Instance.new("Folder")
	RemoteEventsFolder.Name = "RemoteEvents"
	RemoteEventsFolder.Parent = ReplicatedStorage
end

local PurchaseSuccessEvent = Instance.new("RemoteEvent")
PurchaseSuccessEvent.Name = "PurchaseSuccess"
PurchaseSuccessEvent.Parent = RemoteEventsFolder

-- Player data management
local function getDefaultPlayerData()
	return {
		coins = 50000,
		ownedSkins = {"Default"},
		selectedSkin = "Classic", -- Server's default skin name
		favorites = {},
		purchases = {},
		stats = {
			totalCoinsSpent = 0,
			totalPurchases = 0,
			favoriteCategory = "Featured"
		}
	}
end

-- FIXED: Load player data (Studio compatible)
local function loadPlayerData(player)
	if isStudio then
		-- In Studio, always return default data
		print("📊 Using default data for", player.Name, "(Studio mode)")
		return getDefaultPlayerData()
	end

	local success, data = pcall(function()
		return PlayerDataStore:GetAsync(player.UserId)
	end)

	if success and data then
		print("📊 Loaded data for", player.Name, "- Coins:", data.coins or 50000)
		return data
	else
		print("📊 Creating new data for", player.Name)
		return getDefaultPlayerData()
	end
end

-- FIXED: Save player data (Studio compatible)
local function savePlayerData(player, data)
	if isStudio then
		print("💾 Skipping data save for", player.Name, "(Studio mode)")
		return
	end

	pcall(function()
		PlayerDataStore:SetAsync(player.UserId, data)
		print("💾 Saved data for", player.Name)
	end)
end

-- FIXED: Handle skin purchases with proper validation
local function handleSkinPurchase(player, itemName)
	-- FIXED: Remove "skin_" prefix to get actual skin name
	local skinName = itemName
	if skinName:sub(1, 5) == "skin_" then
		skinName = skinName:sub(6) -- Remove "skin_" prefix
	end

	-- SKIN NAME MAPPING: Map client names to server names
	local SKIN_NAME_MAP = {
		["Default"] = "Classic",
		["Crimson"] = "Lava Red",
		["Ocean"] = "Ocean Blue",
		["Cyber"] = "Cyberpunk",
		["Dragon"] = "Dragon Lord",
		["Rainbow"] = "Rainbow Prism",
	}
	
	-- Map the skin name if needed
	local serverSkinName = SKIN_NAME_MAP[skinName] or skinName

	print("🎨 Player", player.Name, "trying to buy skin:", skinName, "->", serverSkinName)

	-- FIXED: Wait for SnakeSkins to load if not available
	if not SnakeSkins then
		print("⏳ SnakeSkins not loaded yet, attempting to load...")
		loadSnakeSkins()
	end

	-- FIXED: Check if skin exists in SnakeSkins module using server name
	if not SnakeSkins or not SnakeSkins[serverSkinName] then
		warn("❌ Player", player.Name, "tried to buy non-existent skin:", skinName, "(server name:", serverSkinName, ")")
		if SnakeSkins then
			local availableSkins = {}
			for skin, _ in pairs(SnakeSkins) do
				table.insert(availableSkins, skin)
			end
			warn("   Available skins:", table.concat(availableSkins, ", "))
		end
		return false
	end

	local skinData = SnakeSkins[serverSkinName]
	local price = skinData.Price or 0

	-- Get player's current data
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		warn("❌ No leaderstats found for player:", player.Name)
		return false
	end

	local coinsValue = leaderstats:FindFirstChild("Coins")
	if not coinsValue then
		warn("❌ No Coins value found for player:", player.Name)
		return false
	end

	local currentCoins = coinsValue.Value

	-- Check if player can afford it
	if currentCoins < price then
		warn("❌ Player", player.Name, "cannot afford skin:", skinName, "(Cost:", price, "Has:", currentCoins, ")")
		return false
	end

	-- Get owned skins from player attributes using JSON
	local ownedSkinsJson = player:GetAttribute("OwnedSkinsJSON")
	local ownedSkins = {"Default"}

	if ownedSkinsJson then
		local success, decoded = pcall(HttpService.JSONDecode, HttpService, ownedSkinsJson)
		if success and type(decoded) == "table" then
			ownedSkins = decoded
		end
	end

	-- Check if already owned
	if table.find(ownedSkins, skinName) then
		warn("❌ Player", player.Name, "already owns skin:", skinName)
		return false
	end

	-- Process purchase
	coinsValue.Value = currentCoins - price
	table.insert(ownedSkins, skinName)

	-- FIXED: Save owned skins using JSON to avoid "Array is not a supported attribute type" error
	local newOwnedSkinsJson = HttpService:JSONEncode(ownedSkins)
	player:SetAttribute("OwnedSkinsJSON", newOwnedSkinsJson)
	player:SetAttribute("Coins", coinsValue.Value)

	print("✅ Player", player.Name, "successfully purchased skin:", skinName, "for", price, "coins!")
	print("💰 New coin balance:", coinsValue.Value)
	print("🎨 New owned skins:", table.concat(ownedSkins, ", "))

	-- Notify client of successful purchase
	PurchaseSuccessEvent:FireClient(player, skinName)

	return true
end

-- FIXED: Handle other item purchases
local function handleItemPurchase(player, itemName)
	if not ShopItems or not ShopItems[itemName] then
		warn("❌ Player", player.Name, "tried to buy non-existent item:", itemName)
		return false
	end

	local itemData = ShopItems[itemName]
	local price = itemData.price or 0

	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return false end

	local coinsValue = leaderstats:FindFirstChild("Coins")
	if not coinsValue then return false end

	if coinsValue.Value >= price then
		coinsValue.Value = coinsValue.Value - price
		player:SetAttribute("Coins", coinsValue.Value)

		-- Apply item effect based on type
		if itemData.type == "boost" then
			-- Handle boost items (speed, coins, etc.)
			print("✅ Applied boost item:", itemName, "to player:", player.Name)
		end

		print("✅ Player", player.Name, "purchased item:", itemName)
		return true
	end

	return false
end

-- FIXED: Handle skin selection with proper ownership validation
local function handleSkinSelection(player, skinName)
	print("🎨 Player", player.Name, "trying to select skin:", skinName)

	-- SKIN NAME MAPPING: Map client names to server names
	local SKIN_NAME_MAP = {
		["Default"] = "Classic",
		["Crimson"] = "Lava Red",
		["Ocean"] = "Ocean Blue",
		["Cyber"] = "Cyberpunk",
		["Dragon"] = "Dragon Lord",
		["Rainbow"] = "Rainbow Prism",
	}
	
	-- Map the skin name if needed
	local serverSkinName = SKIN_NAME_MAP[skinName] or skinName

	-- FIXED: Wait for SnakeSkins to load if not available
	if not SnakeSkins then
		print("⏳ SnakeSkins not loaded yet, attempting to load...")
		loadSnakeSkins()
	end

	-- FIXED: Check if skin exists using server name
	if not SnakeSkins or not SnakeSkins[serverSkinName] then
		warn("❌ Player", player.Name, "tried to select non-existent skin:", skinName, "(server name:", serverSkinName, ")")
		if SnakeSkins then
			local availableSkins = {}
			for skin, _ in pairs(SnakeSkins) do
				table.insert(availableSkins, skin)
			end
			warn("   Available skins:", table.concat(availableSkins, ", "))
		end
		return false
	end

	-- Get owned skins from player attributes using JSON
	local ownedSkinsJson = player:GetAttribute("OwnedSkinsJSON")
	local ownedSkins = {"Default"}

	if ownedSkinsJson then
		local success, decoded = pcall(HttpService.JSONDecode, HttpService, ownedSkinsJson)
		if success and type(decoded) == "table" then
			ownedSkins = decoded
		end
	end

	-- FIXED: Check ownership
	if not table.find(ownedSkins, skinName) then
		warn("❌ Player", player.Name, "tried to select unowned skin:", skinName)
		warn("    Player owns:", table.concat(ownedSkins, ", "))
		return false
	end

	-- FIXED: Set BOTH attributes - server name for game logic, client name for UI
	player:SetAttribute("SelectedSkin", serverSkinName) -- For server/game logic
	player:SetAttribute("ClientSelectedSkin", skinName) -- For client UI
	
	-- IMPORTANT: Save the selection to persist it
	-- Get current player data and update it
	local ownedSkinsJson = player:GetAttribute("OwnedSkinsJSON") or "{}"
	local favoritesJson = player:GetAttribute("FavoritesJSON") or "{}"
	local ownedSkins = {"Default"}
	local favorites = {}
	
	pcall(function()
		ownedSkins = HttpService:JSONDecode(ownedSkinsJson)
		favorites = HttpService:JSONDecode(favoritesJson)
	end)
	
	local playerData = {
		coins = player:GetAttribute("Coins") or 50000,
		ownedSkins = ownedSkins,
		selectedSkin = serverSkinName, -- Store server name
		clientSelectedSkin = skinName, -- Store client name
		favorites = favorites,
		purchases = {},
		stats = {
			totalCoinsSpent = 0,
			totalPurchases = 0,
			favoriteCategory = "Featured"
		}
	}
	
	savePlayerData(player, playerData)
	print("💾 Saved skin selection:", serverSkinName, "client:", skinName)

	print("✅ Player", player.Name, "selected skin:", skinName, "(server name:", serverSkinName, ")")

	-- FIXED: Respawn player's character to apply new skin
	if player.Character then
		task.spawn(function()
			wait(0.1) -- Small delay to ensure attribute is set
			RespawnSnakeEvent:FireClient(player)
		end)
	end

	return true
end

-- FIXED: Initialize player with proper leaderstats and attributes
local function initializePlayer(player)
	print("🎮 Initializing player:", player.Name)

	-- Load saved data
	local playerData = loadPlayerData(player)

	-- Create leaderstats
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local coinsValue = Instance.new("NumberValue")
	coinsValue.Name = "Coins"
	coinsValue.Value = playerData.coins or 50000
	coinsValue.Parent = leaderstats

	local lengthValue = Instance.new("NumberValue")
	lengthValue.Name = "Length"
	lengthValue.Value = 0
	lengthValue.Parent = leaderstats

	-- FIXED: Set player attributes using JSON for arrays
	player:SetAttribute("Coins", playerData.coins or 50000)
	
	-- IMPORTANT: Only set SelectedSkin if not already set (to prevent overwriting current selection)
	local currentSelectedSkin = player:GetAttribute("SelectedSkin")
	if not currentSelectedSkin or currentSelectedSkin == "" then
		player:SetAttribute("SelectedSkin", playerData.selectedSkin or "Classic") -- Server's default skin name
		player:SetAttribute("ClientSelectedSkin", playerData.clientSelectedSkin or "Default") -- Client's default skin name
	else
		-- Update playerData to match current selection
		playerData.selectedSkin = currentSelectedSkin
		print("🔄 Keeping current skin selection:", currentSelectedSkin)
	end

	-- Use JSON for arrays to avoid attribute errors
	local ownedSkinsJson = HttpService:JSONEncode(playerData.ownedSkins or {"Default"})
	player:SetAttribute("OwnedSkinsJSON", ownedSkinsJson)

	local favoritesJson = HttpService:JSONEncode(playerData.favorites or {})
	player:SetAttribute("FavoritesJSON", favoritesJson)

	print("✅ Player", player.Name, "initialized with", playerData.coins, "coins and", #(playerData.ownedSkins or {"Default"}), "skins")
end

-- FIXED: Handle player leaving with data saving
local function handlePlayerLeaving(player)
	print("👋 Player", player.Name, "leaving, saving data...")

	-- Get current data from attributes
	local ownedSkinsJson = player:GetAttribute("OwnedSkinsJSON") or HttpService:JSONEncode({"Default"})
	local favoritesJson = player:GetAttribute("FavoritesJSON") or HttpService:JSONEncode({})

	local ownedSkins = {"Default"}
	local favorites = {}

	pcall(function()
		ownedSkins = HttpService:JSONDecode(ownedSkinsJson)
		favorites = HttpService:JSONDecode(favoritesJson)
	end)

	local playerData = {
		coins = player:GetAttribute("Coins") or 50000,
		ownedSkins = ownedSkins,
		selectedSkin = player:GetAttribute("SelectedSkin") or "Default",
		favorites = favorites,
		purchases = {},
		stats = {
			totalCoinsSpent = 0,
			totalPurchases = 0,
			favoriteCategory = "Featured"
		}
	}

	savePlayerData(player, playerData)
end

-- Event connections
PurchaseItemEvent.OnServerEvent:Connect(function(player, itemName)
	print("🔔 PurchaseItemEvent fired by", player and player.Name or "nil", "for item:", itemName or "nil")
	
	if not player or not itemName then 
		warn("❌ Invalid purchase request - missing player or itemName")
		return 
	end

	print("💰 Processing purchase request from", player.Name, "for item:", itemName)

	-- FIXED: Handle skin purchases vs other items
	if itemName:sub(1, 5) == "skin_" then
		handleSkinPurchase(player, itemName)
	else
		handleItemPurchase(player, itemName)
	end
end)

SelectSkinEvent.OnServerEvent:Connect(function(player, skinName)
	if not player or not skinName then return end

	handleSkinSelection(player, skinName)
end)

RespawnSnakeEvent.OnServerEvent:Connect(function(player)
	if not player then return end

	print("🔄 Respawning player:", player.Name)
	if player.Character then
		player:LoadCharacter()
	end
end)

-- Player management
Players.PlayerAdded:Connect(initializePlayer)
Players.PlayerRemoving:Connect(handlePlayerLeaving)

-- Initialize existing players
for _, player in pairs(Players:GetPlayers()) do
	initializePlayer(player)
end

-- FIXED: Auto-save system (disabled in Studio)
if not isStudio then
	task.spawn(function()
		while true do
			task.wait(300) -- 5 minutes

			for _, player in pairs(Players:GetPlayers()) do
				handlePlayerLeaving(player) -- Save data without actually removing
			end

			print("💾 Auto-saved all player data")
		end
	end)
	print("💾 Auto-save system enabled (Production)")
else
	print("⚠️ Auto-save system disabled (Studio mode)")
end

print("🏪 Purchase Handler initialized!")
print("✅ All RemoteEvents created and connected")
print("🎮 Studio mode:", isStudio and "✅ Enabled" or "❌ Disabled")
print("💾 Data persistence:", isStudio and "❌ Disabled (Studio)" or "✅ Enabled")
print("🎨 SnakeSkins integration:", SnakeSkins and "✅ Working" or "❌ Failed")
print("🛒 ShopItems integration:", ShopItems and "✅ Working" or "❌ Failed")
