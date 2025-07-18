-- SLITHER.IO ULTRA PREMIUM SHOP UI SYSTEM V8.0 - COMPLETELY REVAMPED
-- Extreme upgrade with modular preview system
-- Beautiful, performant, and feature-rich
-- CharacterPreview moved to separate module

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

-- Performance optimizations
local math_sin = math.sin
local math_cos = math.cos
local math_abs = math.abs
local math_random = math.random
local math_floor = math.floor
local math_min = math.min
local math_max = math.max
local math_pi = math.pi
local tick = tick
local task_wait = task.wait
local task_spawn = task.spawn

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Advanced UI System
local ShopUI = {
	VERSION = "8.0",
	DEBUG_MODE = false,
}

-- Load Character Preview Module (separate file)
local CharacterPreview = nil
pcall(function()
	CharacterPreview = require(script.Parent:WaitForChild("CharacterPreview", 5))
	print("✅ CharacterPreview module loaded")
end)

-- INTEGRATION WITH YOUR SNAKE SYSTEM
local SnakeSkins = nil
pcall(function()
	SnakeSkins = require(ReplicatedStorage:WaitForChild("SnakeSkins", 10))
	print("✅ SnakeSkins loaded:", SnakeSkins and "Success" or "Failed")
end)

-- Get RemoteEvents for your system
local remotes = {}
local function getRemote(name)
	if remotes[name] then return remotes[name] end
	
	local remote = ReplicatedStorage:FindFirstChild(name)
	if not remote then
		remote = ReplicatedStorage:WaitForChild(name, 5)
	end
	
	if remote then
		remotes[name] = remote
		print("✅ Remote loaded:", name)
	else
		warn("❌ Remote not found:", name)
	end
	
	return remote
end

local SelectSkinRemote = getRemote("SelectSkin")
local RespawnSnakeRemote = getRemote("RespawnSnake")
local PurchaseItemRemote = getRemote("PurchaseItem")
local UpdateClientRemote = getRemote("UpdateClientSkinData")
local PurchaseSuccessRemote = getRemote("PurchaseSuccess")

-- UI State Management
local uiState = {
	currentCategory = 1,
	selectedSkin = "Default",
	isShopOpen = false,
	previewViewport = nil,
	animations = {},
	particles = {},
	searchQuery = "",
	sortBy = "price", -- price, name, rarity, newest
	filterRarity = "all",
	viewMode = "grid", -- grid, list, carousel
	soundEnabled = true,
	particlesEnabled = true,
	qualityMode = "High", -- Low, Medium, High, Ultra
}

-- EXTREME SHOP CONFIGURATION V8
local SHOP_CONFIG = {
	-- Enhanced visual settings
	COLORS = {
		BACKGROUND = Color3.fromRGB(12, 14, 22),
		PRIMARY = Color3.fromRGB(20, 23, 34),
		SECONDARY = Color3.fromRGB(28, 32, 45),
		TERTIARY = Color3.fromRGB(38, 43, 58),
		ACCENT = Color3.fromRGB(0, 255, 140),
		ACCENT_SECONDARY = Color3.fromRGB(0, 200, 110),
		TEXT_PRIMARY = Color3.fromRGB(255, 255, 255),
		TEXT_SECONDARY = Color3.fromRGB(170, 175, 185),
		TEXT_TERTIARY = Color3.fromRGB(120, 125, 135),
		SUCCESS = Color3.fromRGB(0, 255, 127),
		WARNING = Color3.fromRGB(255, 170, 0),
		ERROR = Color3.fromRGB(255, 65, 65),
		VIP_GOLD = Color3.fromRGB(255, 215, 0),
		VIP_DIAMOND = Color3.fromRGB(185, 242, 255),
		PREMIUM_PURPLE = Color3.fromRGB(180, 100, 255),
		LEGENDARY_RED = Color3.fromRGB(255, 50, 100),
		MYTHIC_RAINBOW = Color3.fromRGB(255, 100, 255),
		COIN_GOLD = Color3.fromRGB(255, 205, 0),
		ROBUX_GREEN = Color3.fromRGB(0, 255, 127),
	},
	
	-- Professional fonts
	FONTS = {
		TITLE = Enum.Font.GothamBold,
		HEADING = Enum.Font.Gotham,
		BUTTON = Enum.Font.GothamMedium,
		BODY = Enum.Font.Gotham,
		PRICE = Enum.Font.GothamBold,
		SPECIAL = Enum.Font.SciFi,
		PREMIUM = Enum.Font.Antique,
	},
	
	-- Animation configurations
	ANIMATIONS = {
		HOVER_SCALE = 1.05,
		CLICK_SCALE = 0.95,
		SELECT_SCALE = 1.08,
		TRANSITION_TIME = 0.3,
		BOUNCE_TIME = 0.4,
		GLOW_SPEED = 2,
		PARTICLE_SPEED = 1.5,
		WAVE_SPEED = 3,
		PULSE_SPEED = 1,
	},
	
	-- Layout settings
	LAYOUT = {
		CARD_WIDTH = 180,
		CARD_HEIGHT = 220,
		GRID_SPACING = 15,
		PADDING = 25,
		CORNER_RADIUS = 12,
		STROKE_THICKNESS = 2,
		HEADER_HEIGHT = 70,
		CATEGORY_HEIGHT = 50,
		PREVIEW_HEIGHT = 300,
	},
	
	-- Premium sound effects
	SOUNDS = {
		HOVER = "rbxassetid://9113880610",
		CLICK = "rbxassetid://9113881912",
		PURCHASE = "rbxassetid://9113883650",
		ERROR = "rbxassetid://9113884835",
		SUCCESS = "rbxassetid://9113885810",
		OPEN = "rbxassetid://9113886768",
		CLOSE = "rbxassetid://9113887540",
		COIN = "rbxassetid://9113888324",
		VIP = "rbxassetid://9113889072",
		SWITCH = "rbxassetid://9113889892",
		SPARKLE = "rbxassetid://9113890614",
		WHOOSH = "rbxassetid://9113891418",
		NOTIFICATION = "rbxassetid://9113892167",
	},
}

-- Enhanced Skin Data with all categories
ShopUI.SKIN_DATA = {
	-- FREE TIER
	["Default"] = {
		price = 0, 
		robux = 0, 
		tag = nil, 
		category = "Classic", 
		rarity = "Common",
		new = false,
		featured = false,
		limited = false,
		exclusive = false,
		description = "The original slither.io look!"
	},
	
	-- CLASSIC TIER (Affordable starter skins)
	["Crimson"] = {
		price = 250, 
		robux = 5, 
		tag = "Classic", 
		category = "Classic", 
		rarity = "Common",
		new = false,
		featured = false,
		description = "Burn with crimson fire!"
	},
	
	-- FEATURED TIER (Hot & Trending)
	["Arctic"] = {
		price = 750, 
		robux = 15, 
		tag = "Hot", 
		category = "Featured", 
		rarity = "Rare",
		new = false,
		featured = true,
		description = "Cool as the arctic winds!"
	},
	["Emerald"] = {
		price = 1000, 
		robux = 20, 
		tag = "New", 
		category = "Featured", 
		rarity = "Rare",
		new = true,
		featured = true,
		description = "Precious as emerald gems!"
	},
	["Void"] = {
		price = 1250, 
		robux = 25, 
		tag = "Dark", 
		category = "Featured", 
		rarity = "Epic",
		new = false,
		featured = true,
		description = "From the depths of space!"
	},
	
	-- PREMIUM TIER (Enhanced effects)
	["Ocean"] = {
		price = 1500, 
		robux = 30, 
		tag = nil, 
		category = "Premium", 
		rarity = "Rare",
		description = "Dive into ocean depths!"
	},
	["Shadow"] = {
		price = 2000, 
		robux = 40, 
		tag = "Stealth", 
		category = "Premium", 
		rarity = "Epic",
		description = "Strike from the shadows!"
	},
	["Plasma"] = {
		price = 3000, 
		robux = 60, 
		tag = "Energy", 
		category = "Premium", 
		rarity = "Epic",
		description = "Electric plasma energy!"
	},
	
	-- LEGENDARY TIER (Rare and powerful)
	["Galaxy"] = {
		price = 5000, 
		robux = 100, 
		tag = "Space", 
		category = "Legendary", 
		rarity = "Legendary",
		description = "Born from distant galaxies!"
	},
	["Cyber"] = {
		price = 7500, 
		robux = 150, 
		tag = "Tech", 
		category = "Legendary", 
		rarity = "Legendary",
		description = "From the digital future!"
	},
	["Dragon"] = {
		price = 10000, 
		robux = 200, 
		tag = "Mythic", 
		category = "Legendary", 
		rarity = "Mythic",
		description = "Legendary dragon power!"
	},
	["Rainbow"] = {
		price = 15000, 
		robux = 250, 
		tag = "Special", 
		category = "Legendary", 
		rarity = "Mythic",
		limited = true,
		description = "All colors of the rainbow!"
	},
	
	-- VIP EXCLUSIVE (Robux only - Premium tier)
	["VIP Diamond"] = {
		price = 0, 
		robux = 299, 
		tag = "VIP", 
		category = "VIP Elite", 
		rarity = "Exclusive",
		exclusive = true,
		vip = true,
		description = "Shine like a diamond! VIP exclusive skin."
	},
	["VIP Inferno"] = {
		price = 0, 
		robux = 399, 
		tag = "VIP", 
		category = "VIP Elite", 
		rarity = "Exclusive",
		exclusive = true,
		vip = true,
		description = "Burn with the flames of VIP power!"
	},
	["VIP Cosmic"] = {
		price = 0, 
		robux = 499, 
		tag = "VIP", 
		category = "VIP Elite", 
		rarity = "Exclusive",
		exclusive = true,
		vip = true,
		description = "Harness the power of the cosmos!"
	},
}

-- Premium Category System
ShopUI.CATEGORIES = {
	{
		name = "Featured",
		icon = "🔥",
		description = "Hot & Trending",
		color = SHOP_CONFIG.COLORS.ERROR,
		glow = true,
		particle = "fire",
		order = 1,
	},
	{
		name = "Classic",
		icon = "⭐",
		description = "Timeless Designs",
		color = SHOP_CONFIG.COLORS.ACCENT,
		glow = false,
		particle = nil,
		order = 2,
	},
	{
		name = "Premium",
		icon = "💎",
		description = "Enhanced Effects",
		color = SHOP_CONFIG.COLORS.PREMIUM_PURPLE,
		glow = true,
		particle = "sparkle",
		order = 3,
	},
	{
		name = "VIP Elite",
		icon = "👑",
		description = "Ultimate Power",
		color = SHOP_CONFIG.COLORS.VIP_GOLD,
		glow = true,
		particle = "stars",
		premium = true,
		order = 4,
	},
	{
		name = "Legendary",
		icon = "🌟",
		description = "Rare & Powerful",
		color = SHOP_CONFIG.COLORS.LEGENDARY_RED,
		glow = true,
		particle = "sparkle",
		order = 5,
	},
	{
		name = "Special",
		icon = "🎭",
		description = "Limited Edition",
		color = SHOP_CONFIG.COLORS.WARNING,
		glow = true,
		particle = "stars",
		order = 6,
	},
	{
		name = "Gamepasses",
		icon = "🎮",
		description = "Power-Ups & Boosts",
		color = SHOP_CONFIG.COLORS.SUCCESS,
		glow = false,
		particle = nil,
		order = 7,
	},
}

-- Continue with the rest...