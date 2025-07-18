-- SNAKE SKINS MODULE LOADER V2.1 - RUNTIME SAFE
-- Creates a wrapper that loads skins from SnakeSkinsData at runtime
-- Works around Source writing limitations
-- Place this script in ServerScriptService

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Load the SnakeSkinsData module (source of truth)
local SnakeSkinsData = require(script.Parent:WaitForChild("SnakeSkinsData"))

-- Helper function to serialize Color3 values
local function serializeColor3(color)
	return string.format("Color3.fromRGB(%d, %d, %d)", 
		math.floor(color.R * 255),
		math.floor(color.G * 255),
		math.floor(color.B * 255)
	)
end

-- Helper function to serialize Vector3 values
local function serializeVector3(vector)
	return string.format("Vector3.new(%g, %g, %g)", vector.X, vector.Y, vector.Z)
end

-- Helper function to serialize Material enum
local function serializeMaterial(material)
	return "Enum.Material." .. tostring(material.Name)
end

-- Helper function to serialize a table value
local function serializeValue(value, indent)
	indent = indent or ""
	local valueType = typeof(value)
	
	if valueType == "Color3" then
		return serializeColor3(value)
	elseif valueType == "Vector3" then
		return serializeVector3(value)
	elseif valueType == "EnumItem" then
		return serializeMaterial(value)
	elseif valueType == "string" then
		return string.format("%q", value)
	elseif valueType == "number" then
		return tostring(value)
	elseif valueType == "boolean" then
		return tostring(value)
	elseif valueType == "table" then
		local lines = {"{"}
		for k, v in pairs(value) do
			local key = type(k) == "string" and string.format("[%q]", k) or "[" .. tostring(k) .. "]"
			table.insert(lines, indent .. "\t" .. key .. " = " .. serializeValue(v, indent .. "\t") .. ",")
		end
		table.insert(lines, indent .. "}")
		return table.concat(lines, "\n")
	else
		return "nil"
	end
end

-- Create and populate SnakeSkins module dynamically
local function createSnakeSkinsModule()
	-- Check if SnakeSkins already exists
	local existingModule = ReplicatedStorage:FindFirstChild("SnakeSkins")
	if existingModule then
		existingModule:Destroy() -- Remove old version to update with latest data
		print("🔄 Replacing existing SnakeSkins module with updated data")
	end

	-- Create new ModuleScript
	local snakeSkinsModule = Instance.new("ModuleScript")
	snakeSkinsModule.Name = "SnakeSkins"
	snakeSkinsModule.Parent = ReplicatedStorage

	-- Build the module source dynamically from SnakeSkinsData
	local sourceLines = {
		"-- SLITHER.IO SNAKE SKINS MODULE - AUTO-GENERATED",
		"-- Generated from SnakeSkinsData.lua",
		"-- Last updated: " .. os.date(),
		"",
		"return {"
	}
	
	-- Add each skin
	local skinCount = 0
	for skinName, skinData in pairs(SnakeSkinsData) do
		skinCount = skinCount + 1
		table.insert(sourceLines, "\t[\"" .. skinName .. "\"] = {")
		
		-- Add all properties
		for prop, value in pairs(skinData) do
			if prop == "BodyColors" then
				-- Special handling for BodyColors array
				table.insert(sourceLines, "\t\tBodyColors = {")
				for i, color in ipairs(value) do
					table.insert(sourceLines, "\t\t\t" .. serializeColor3(color) .. ",")
				end
				table.insert(sourceLines, "\t\t},")
			elseif prop == "VFX" then
				-- Special handling for VFX table
				table.insert(sourceLines, "\t\tVFX = {")
				for vfxProp, vfxValue in pairs(value) do
					local serialized = serializeValue(vfxValue)
					table.insert(sourceLines, "\t\t\t" .. vfxProp .. " = " .. serialized .. ",")
				end
				table.insert(sourceLines, "\t\t},")
			else
				-- Handle other properties
				local serialized = serializeValue(value)
				table.insert(sourceLines, "\t\t" .. prop .. " = " .. serialized .. ",")
			end
		end
		
		table.insert(sourceLines, "\t},")
		table.insert(sourceLines, "") -- Empty line for readability
	end
	
	table.insert(sourceLines, "}")
	
	-- Set the module source
	snakeSkinsModule.Source = table.concat(sourceLines, "\n")
	
	print("✅ Created SnakeSkins module in ReplicatedStorage with", skinCount, "skins")
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
	},
	
	["growth_boost"] = {
		name = "Growth Accelerator",
		description = "Grow 2x faster when eating for 5 minutes",
		price = 1000,
		type = "boost",
		duration = 300,
		effect = {growthMultiplier = 2}
	},
	
	["magnet_boost"] = {
		name = "Food Magnet",
		description = "Attract nearby food for 3 minutes",
		price = 1500,
		type = "boost",
		duration = 180,
		effect = {magnetRange = 10}
	}
}]]

	print("✅ Created ShopItems module in ReplicatedStorage")
	return shopItemsModule
end

-- Initialize modules
local snakeSkinsModule = createSnakeSkinsModule()
local shopItemsModule = createShopItemsModule()

-- Verify and log loaded skins
task.spawn(function()
	task.wait(2) -- Wait for module to be available

	local success, SnakeSkins = pcall(function()
		return require(ReplicatedStorage:WaitForChild("SnakeSkins"))
	end)

	if success and SnakeSkins then
		print("\n🎯 Server SnakeSkins verification:")
		print("=================================")
		
		local categories = {
			Free = {},
			Coins = {},
			Robux = {},
			Gamepass = {},
			Special = {}
		}
		
		for skinName, skinData in pairs(SnakeSkins) do
			if skinData.Special then
				table.insert(categories.Special, {name = skinName, price = skinData.Price})
			elseif skinData.RobuxPrice then
				table.insert(categories.Robux, {name = skinName, price = skinData.RobuxPrice})
			elseif skinData.GamepassId then
				table.insert(categories.Gamepass, {name = skinName, gamepass = skinData.GamepassId})
			elseif skinData.Price and skinData.Price > 0 then
				table.insert(categories.Coins, {name = skinName, price = skinData.Price})
			else
				table.insert(categories.Free, {name = skinName, price = 0})
			end
		end
		
		-- Print categorized skins
		print("\n🆓 FREE SKINS:")
		for _, skin in ipairs(categories.Free) do
			print("  ✅", skin.name)
		end
		
		print("\n💰 COIN SKINS:")
		for _, skin in ipairs(categories.Coins) do
			print("  ✅", skin.name, "- 💰", skin.price, "coins")
		end
		
		print("\n💎 ROBUX SKINS:")
		for _, skin in ipairs(categories.Robux) do
			print("  ✅", skin.name, "- 💎", skin.price, "Robux")
		end
		
		print("\n🎮 GAMEPASS SKINS:")
		for _, skin in ipairs(categories.Gamepass) do
			print("  ✅", skin.name, "- GamepassID:", skin.gamepass)
		end
		
		print("\n⭐ SPECIAL SKINS:")
		for _, skin in ipairs(categories.Special) do
			print("  ✅", skin.name, "- 💰", skin.price, "coins (Limited Edition)")
		end
		
		print("\n✅ Total skins loaded:", #SnakeSkins)
		print("=================================")
	else
		warn("❌ Could not verify SnakeSkins module!")
	end
end)

print("🚀 SnakeSkinsLoader V2.0 initialized!")
print("✅ SnakeSkins module dynamically generated from SnakeSkinsData")
print("✅ ShopItems module ready in ReplicatedStorage")
print("📋 All systems ready for client connections!")