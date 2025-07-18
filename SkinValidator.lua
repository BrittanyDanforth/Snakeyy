-- SKIN VALIDATOR
-- Validates all skins in SnakeSkinsData to ensure they have proper configurations

local SnakeSkinsData = require(script.Parent:WaitForChild("SnakeSkinsData"))

-- Required fields for all skins
local REQUIRED_FIELDS = {
	"HeadColor",
	"BodyColors",
	"HeadSize",
	"SegmentSize",
	"SegmentSpacing",
	"HeadMaterial",
	"BodyMaterial",
	"GlowIntensity",
	"GlowRange",
	"Description"
}

-- Optional fields
local OPTIONAL_FIELDS = {
	"Price",        -- For coin purchases
	"RobuxPrice",   -- For Robux purchases
	"GamepassId",   -- For gamepass skins
	"Special",      -- For special/limited skins
	"VFX"          -- For visual effects
}

local function validateColor(color, skinName, fieldName)
	if typeof(color) ~= "Color3" then
		warn("❌", skinName, "-", fieldName, "is not a Color3!")
		return false
	end
	return true
end

local function validateVector3(vector, skinName, fieldName)
	if typeof(vector) ~= "Vector3" then
		warn("❌", skinName, "-", fieldName, "is not a Vector3!")
		return false
	end
	return true
end

local function validateSkin(skinName, skinData)
	local isValid = true
	
	print("\n🔍 Validating skin:", skinName)
	
	-- Check required fields
	for _, field in ipairs(REQUIRED_FIELDS) do
		if skinData[field] == nil then
			warn("❌", skinName, "- Missing required field:", field)
			isValid = false
		end
	end
	
	-- Validate HeadColor
	if skinData.HeadColor and not validateColor(skinData.HeadColor, skinName, "HeadColor") then
		isValid = false
	end
	
	-- Validate BodyColors
	if skinData.BodyColors then
		if type(skinData.BodyColors) ~= "table" then
			warn("❌", skinName, "- BodyColors is not a table!")
			isValid = false
		elseif #skinData.BodyColors < 1 then
			warn("❌", skinName, "- BodyColors is empty!")
			isValid = false
		else
			for i, color in ipairs(skinData.BodyColors) do
				if not validateColor(color, skinName, "BodyColors[" .. i .. "]") then
					isValid = false
				end
			end
		end
	end
	
	-- Validate sizes
	if skinData.HeadSize and not validateVector3(skinData.HeadSize, skinName, "HeadSize") then
		isValid = false
	end
	if skinData.SegmentSize and not validateVector3(skinData.SegmentSize, skinName, "SegmentSize") then
		isValid = false
	end
	
	-- Validate materials
	if skinData.HeadMaterial and typeof(skinData.HeadMaterial) ~= "EnumItem" then
		warn("❌", skinName, "- HeadMaterial is not an Enum.Material!")
		isValid = false
	end
	if skinData.BodyMaterial and typeof(skinData.BodyMaterial) ~= "EnumItem" then
		warn("❌", skinName, "- BodyMaterial is not an Enum.Material!")
		isValid = false
	end
	
	-- Validate numbers
	if skinData.SegmentSpacing and type(skinData.SegmentSpacing) ~= "number" then
		warn("❌", skinName, "- SegmentSpacing is not a number!")
		isValid = false
	end
	if skinData.GlowIntensity and type(skinData.GlowIntensity) ~= "number" then
		warn("❌", skinName, "- GlowIntensity is not a number!")
		isValid = false
	end
	if skinData.GlowRange and type(skinData.GlowRange) ~= "number" then
		warn("❌", skinName, "- GlowRange is not a number!")
		isValid = false
	end
	
	-- Validate pricing
	local hasPrice = false
	if skinData.Price ~= nil then
		if type(skinData.Price) ~= "number" or skinData.Price < 0 then
			warn("❌", skinName, "- Invalid Price:", skinData.Price)
			isValid = false
		else
			hasPrice = true
			print("  💰 Coin price:", skinData.Price)
		end
	end
	
	if skinData.RobuxPrice ~= nil then
		if type(skinData.RobuxPrice) ~= "number" or skinData.RobuxPrice < 0 then
			warn("❌", skinName, "- Invalid RobuxPrice:", skinData.RobuxPrice)
			isValid = false
		else
			hasPrice = true
			print("  💎 Robux price:", skinData.RobuxPrice)
		end
	end
	
	if skinData.GamepassId ~= nil then
		if type(skinData.GamepassId) ~= "number" then
			warn("❌", skinName, "- Invalid GamepassId:", skinData.GamepassId)
			isValid = false
		else
			hasPrice = true
			print("  🎮 Gamepass ID:", skinData.GamepassId)
		end
	end
	
	-- At least one pricing method should be available (or it's the default skin)
	if not hasPrice and skinName ~= "Classic" then
		warn("⚠️", skinName, "- No pricing method defined (Price, RobuxPrice, or GamepassId)")
	end
	
	-- Validate VFX if present
	if skinData.VFX then
		if type(skinData.VFX) ~= "table" then
			warn("❌", skinName, "- VFX is not a table!")
			isValid = false
		else
			if not skinData.VFX.Type then
				warn("❌", skinName, "- VFX missing Type!")
				isValid = false
			end
			print("  ✨ Has VFX:", skinData.VFX.Type)
		end
	end
	
	if isValid then
		print("✅", skinName, "- Valid!")
	else
		print("❌", skinName, "- Has errors!")
	end
	
	return isValid
end

-- Main validation
local function validateAllSkins()
	print("=== SKIN VALIDATION REPORT ===")
	print("Total skins:", #SnakeSkinsData)
	
	local validSkins = 0
	local invalidSkins = 0
	local skinsByCategory = {
		Coins = {},
		Robux = {},
		Gamepass = {},
		Free = {},
		Special = {}
	}
	
	for skinName, skinData in pairs(SnakeSkinsData) do
		if validateSkin(skinName, skinData) then
			validSkins = validSkins + 1
			
			-- Categorize skins
			if skinData.Special then
				table.insert(skinsByCategory.Special, skinName)
			elseif skinData.RobuxPrice then
				table.insert(skinsByCategory.Robux, skinName)
			elseif skinData.GamepassId then
				table.insert(skinsByCategory.Gamepass, skinName)
			elseif skinData.Price and skinData.Price > 0 then
				table.insert(skinsByCategory.Coins, skinName)
			else
				table.insert(skinsByCategory.Free, skinName)
			end
		else
			invalidSkins = invalidSkins + 1
		end
	end
	
	print("\n=== SUMMARY ===")
	print("✅ Valid skins:", validSkins)
	print("❌ Invalid skins:", invalidSkins)
	
	print("\n=== CATEGORIES ===")
	print("🆓 Free skins:", #skinsByCategory.Free, "-", table.concat(skinsByCategory.Free, ", "))
	print("💰 Coin skins:", #skinsByCategory.Coins, "-", table.concat(skinsByCategory.Coins, ", "))
	print("💎 Robux skins:", #skinsByCategory.Robux, "-", table.concat(skinsByCategory.Robux, ", "))
	print("🎮 Gamepass skins:", #skinsByCategory.Gamepass, "-", table.concat(skinsByCategory.Gamepass, ", "))
	print("⭐ Special skins:", #skinsByCategory.Special, "-", table.concat(skinsByCategory.Special, ", "))
end

-- Run validation
validateAllSkins()

return true