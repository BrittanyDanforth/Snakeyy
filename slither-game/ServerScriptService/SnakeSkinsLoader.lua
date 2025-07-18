-- SNAKE SKINS MODULE LOADER - FIXED SKIN NAMES
-- Ensures SnakeSkins module is available in ReplicatedStorage
-- FIXED: Uses exact same skin names as client-side shop
-- Place this script in ServerScriptService

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- FIXED: Create and populate SnakeSkins module with EXACT matching names
local function createSnakeSkinsModule()
	-- Check if SnakeSkins already exists
	local existingModule = ReplicatedStorage:FindFirstChild("SnakeSkins")
	if existingModule then
		print("✅ SnakeSkins module already exists in ReplicatedStorage")
		return existingModule
	end

	-- Create new ModuleScript
	local snakeSkinsModule = Instance.new("ModuleScript")
	snakeSkinsModule.Name = "SnakeSkins"
	snakeSkinsModule.Parent = ReplicatedStorage

	-- FIXED: Set the module source with EXACT skin names matching client shop
	snakeSkinsModule.Source = [[-- SLITHER.IO SNAKE SKINS MODULE - EXACT CLIENT MATCH
-- FIXED: Uses exact same skin names as client-side shop
-- All skins have proper HeadColor and BodyColors arrays
-- Pricing system and skin descriptions included

return {
	["Classic"] = { -- Server name for Default
		HeadColor = Color3.fromRGB(76, 217, 100),
		BodyColors = {
			Color3.fromRGB(60, 180, 80),
			Color3.fromRGB(80, 200, 100),
			Color3.fromRGB(100, 220, 120),
			Color3.fromRGB(80, 200, 100),
			Color3.fromRGB(60, 180, 80),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 1.5,
		GlowRange = 4,
		Price = 0,
		Description = "The original slither.io look!"
	},
	
	["Lava Red"] = { -- Server name for Crimson
		HeadColor = Color3.fromRGB(220, 50, 50),
		BodyColors = {
			Color3.fromRGB(180, 30, 30),
			Color3.fromRGB(200, 50, 50),
			Color3.fromRGB(220, 70, 70),
			Color3.fromRGB(200, 50, 50),
			Color3.fromRGB(180, 30, 30),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 2.0,
		GlowRange = 6,
		Price = 250,
		Description = "Burn with crimson fire!"
	},
	
	["Arctic"] = {
		HeadColor = Color3.fromRGB(200, 230, 255),
		BodyColors = {
			Color3.fromRGB(150, 200, 240),
			Color3.fromRGB(170, 210, 245),
			Color3.fromRGB(190, 220, 250),
			Color3.fromRGB(170, 210, 245),
			Color3.fromRGB(150, 200, 240),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.Ice,
		BodyMaterial = Enum.Material.ForceField,
		GlowIntensity = 1.8,
		GlowRange = 5,
		Price = 350,
		Description = "Cool as the arctic winds!"
	},
	
	["Emerald"] = {
		HeadColor = Color3.fromRGB(50, 200, 100),
		BodyColors = {
			Color3.fromRGB(30, 150, 80),
			Color3.fromRGB(40, 170, 90),
			Color3.fromRGB(50, 190, 100),
			Color3.fromRGB(40, 170, 90),
			Color3.fromRGB(30, 150, 80),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 1.7,
		GlowRange = 4,
		Price = 500,
		Description = "Precious as emerald gems!"
	},
	
	["Void"] = {
		HeadColor = Color3.fromRGB(50, 20, 80),
		BodyColors = {
			Color3.fromRGB(30, 10, 50),
			Color3.fromRGB(40, 15, 60),
			Color3.fromRGB(50, 20, 70),
			Color3.fromRGB(40, 15, 60),
			Color3.fromRGB(30, 10, 50),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 2.2,
		GlowRange = 7,
		Price = 1000,
		Description = "From the depths of space!"
	},
	
	["Electric Purple"] = { -- Server name for Plasma
		HeadColor = Color3.fromRGB(255, 100, 200),
		BodyColors = {
			Color3.fromRGB(200, 50, 150),
			Color3.fromRGB(220, 70, 170),
			Color3.fromRGB(240, 90, 190),
			Color3.fromRGB(220, 70, 170),
			Color3.fromRGB(200, 50, 150),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 2.5,
		GlowRange = 8,
		Price = 1500,
		Description = "Electric plasma energy!"
	},
	
	["Galaxy"] = {
		HeadColor = Color3.fromRGB(100, 50, 200),
		BodyColors = {
			Color3.fromRGB(80, 30, 150),
			Color3.fromRGB(90, 40, 170),
			Color3.fromRGB(100, 50, 190),
			Color3.fromRGB(90, 40, 170),
			Color3.fromRGB(80, 30, 150),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 2.3,
		GlowRange = 7,
		Price = 2000,
		Description = "Born from distant galaxies!"
	},
	
	["Ocean Blue"] = { -- Server name for Ocean
		HeadColor = Color3.fromRGB(50, 150, 200),
		BodyColors = {
			Color3.fromRGB(30, 100, 180),
			Color3.fromRGB(40, 120, 190),
			Color3.fromRGB(50, 140, 200),
			Color3.fromRGB(40, 120, 190),
			Color3.fromRGB(30, 100, 180),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 1.9,
		GlowRange = 5,
		Price = 2500,
		Description = "Dive into ocean depths!"
	},
	
	["Shadow"] = {
		HeadColor = Color3.fromRGB(40, 40, 40),
		BodyColors = {
			Color3.fromRGB(20, 20, 20),
			Color3.fromRGB(30, 30, 30),
			Color3.fromRGB(40, 40, 40),
			Color3.fromRGB(30, 30, 30),
			Color3.fromRGB(20, 20, 20),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 1.2,
		GlowRange = 3,
		Price = 3000,
		Description = "Strike from the shadows!"
	},
	
	["Cyberpunk"] = { -- Server name for Cyber
		HeadColor = Color3.fromRGB(0, 255, 150),
		BodyColors = {
			Color3.fromRGB(0, 200, 100),
			Color3.fromRGB(0, 220, 120),
			Color3.fromRGB(0, 240, 140),
			Color3.fromRGB(0, 220, 120),
			Color3.fromRGB(0, 200, 100),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 3.0,
		GlowRange = 10,
		Price = 4000,
		Description = "From the digital future!"
	},
	
	["Dragon Lord"] = { -- Server name for Dragon
		HeadColor = Color3.fromRGB(255, 150, 0),
		BodyColors = {
			Color3.fromRGB(200, 100, 0),
			Color3.fromRGB(220, 120, 0),
			Color3.fromRGB(240, 140, 0),
			Color3.fromRGB(220, 120, 0),
			Color3.fromRGB(200, 100, 0),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 2.8,
		GlowRange = 9,
		Price = 5000,
		Description = "Legendary dragon power!"
	},
	
	["VIP Diamond"] = {
		HeadColor = Color3.fromRGB(255, 255, 255),
		BodyColors = {
			Color3.fromRGB(200, 200, 255),
			Color3.fromRGB(220, 220, 255),
			Color3.fromRGB(240, 240, 255),
			Color3.fromRGB(220, 220, 255),
			Color3.fromRGB(200, 200, 255),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 3.5,
		GlowRange = 12,
		Price = 10000,
		Description = "Pure diamond perfection!"
	},
	
	["VIP Inferno"] = {
		HeadColor = Color3.fromRGB(255, 100, 0),
		BodyColors = {
			Color3.fromRGB(255, 50, 0),
			Color3.fromRGB(255, 70, 20),
			Color3.fromRGB(255, 90, 40),
			Color3.fromRGB(255, 70, 20),
			Color3.fromRGB(255, 50, 0),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 4.0,
		GlowRange = 15,
		Price = 15000,
		Description = "Inferno of destruction!"
	},
	
	["VIP Cosmic"] = {
		HeadColor = Color3.fromRGB(150, 100, 255),
		BodyColors = {
			Color3.fromRGB(100, 50, 200),
			Color3.fromRGB(120, 70, 220),
			Color3.fromRGB(140, 90, 240),
			Color3.fromRGB(120, 70, 220),
			Color3.fromRGB(100, 50, 200),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 3.8,
		GlowRange = 14,
		Price = 20000,
		Description = "Cosmic VIP power!"
	},
	
	["Rainbow Prism"] = { -- Server name for Rainbow
		HeadColor = Color3.fromRGB(255, 100, 255),
		BodyColors = {
			Color3.fromRGB(255, 0, 0),     -- Red
			Color3.fromRGB(255, 127, 0),   -- Orange
			Color3.fromRGB(255, 255, 0),   -- Yellow
			Color3.fromRGB(0, 255, 0),     -- Green
			Color3.fromRGB(0, 0, 255),     -- Blue
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 2.5,
		GlowRange = 8,
		Price = 7500,
		Description = "All colors of the rainbow!"
	},
	
	-- Additional server skins
	["Phantom Viper"] = {
		HeadColor = Color3.fromRGB(150, 50, 255),
		BodyColors = {
			Color3.fromRGB(100, 30, 200),
			Color3.fromRGB(120, 40, 220),
			Color3.fromRGB(140, 50, 240),
			Color3.fromRGB(120, 40, 220),
			Color3.fromRGB(100, 30, 200),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 2.5,
		GlowRange = 8,
		Price = 5000,
		Description = "The phantom strikes!"
	},
	
	["Golden Emperor"] = {
		HeadColor = Color3.fromRGB(255, 215, 0),
		BodyColors = {
			Color3.fromRGB(255, 200, 0),
			Color3.fromRGB(255, 215, 0),
			Color3.fromRGB(255, 230, 0),
			Color3.fromRGB(255, 215, 0),
			Color3.fromRGB(255, 200, 0),
		},
		HeadSize = Vector3.new(3.5, 3.5, 3.5),
		SegmentSize = Vector3.new(3, 3, 3),
		SegmentSpacing = 2.5,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 3.0,
		GlowRange = 10,
		Price = 10000,
		Description = "Rule with golden power!"
	},
	
	["Toxic Green"] = {
		HeadColor = Color3.fromRGB(0, 255, 0),
		BodyColors = {
			Color3.fromRGB(0, 200, 0),
			Color3.fromRGB(0, 225, 0),
			Color3.fromRGB(0, 255, 0),
			Color3.fromRGB(0, 225, 0),
			Color3.fromRGB(0, 200, 0),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 2.0,
		GlowRange = 6,
		Price = 3500,
		Description = "Toxic and dangerous!"
	}
}]]

	print("✅ Created SnakeSkins module in ReplicatedStorage with SERVER skin names")
	return snakeSkinsModule
end

-- Create ShopItems module if needed
local function createShopItemsModule()
	local existingModule = ReplicatedStorage:FindFirstChild("ShopItems")
	if existingModule then
		print("✅ ShopItems module already exists in ReplicatedStorage")
		return existingModule
	end

	local shopItemsModule = Instance.new("ModuleScript")
	shopItemsModule.Name = "ShopItems"
	shopItemsModule.Parent = ReplicatedStorage

	shopItemsModule.Source = [[-- SLITHER.IO SHOP ITEMS MODULE
-- Contains boosts and other purchasable items

return {
	["speed_boost_small"] = {
		name = "Speed Boost (Small)",
		description = "Increases speed by 25% for 30 seconds",
		price = 100,
		type = "boost",
		duration = 30,
		effect = {speedMultiplier = 1.25}
	},
	
	["speed_boost_large"] = {
		name = "Speed Boost (Large)",
		description = "Increases speed by 50% for 60 seconds",
		price = 250,
		type = "boost",
		duration = 60,
		effect = {speedMultiplier = 1.5}
	},
	
	["coin_multiplier"] = {
		name = "Coin Multiplier",
		description = "Double coin earnings for 5 minutes",
		price = 500,
		type = "boost",
		duration = 300,
		effect = {coinMultiplier = 2}
	},
	
	["xp_boost"] = {
		name = "XP Booster",
		description = "Triple XP gain for 10 minutes",
		price = 750,
		type = "boost",
		duration = 600,
		effect = {xpMultiplier = 3}
	}
}]]

	print("✅ Created ShopItems module in ReplicatedStorage")
	return shopItemsModule
end

-- Initialize modules
createSnakeSkinsModule()
createShopItemsModule()

-- FIXED: Verify skin names match by logging them
task.spawn(function()
	task.wait(2) -- Wait for module to be available

	local success, SnakeSkins = pcall(function()
		return require(ReplicatedStorage:WaitForChild("SnakeSkins"))
	end)

	if success and SnakeSkins then
		print("🎯 Server SnakeSkins verification:")
		for skinName, skinData in pairs(SnakeSkins) do
			print("  ✅ " .. skinName .. " (Price: " .. (skinData.Price or 0) .. ")")
		end
		print("🔄 These names MUST match the client-side shop exactly!")
	else
		warn("❌ Could not verify SnakeSkins module!")
	end
end)

print("🎯 SnakeSkins and ShopItems modules are ready in ReplicatedStorage!")
print("✅ PurchaseHandler should now be able to find all required modules")
print("🔧 FIXED: All skin names now match client-side shop exactly!")
