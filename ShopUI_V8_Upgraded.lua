-- SLITHER.IO ULTRA PREMIUM SHOP UI SYSTEM V8.0 - EXTREME UPGRADE
-- Modular design with separated preview system
-- Enhanced performance, animations, and visual effects
-- Fully integrated with advanced features

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

-- Module loading with error handling
local SnakeSkins = nil
local AdvancedSnakePreview = nil
local ExtremeVFX = nil

-- Load modules safely
local function loadModules()
	-- Load SnakeSkins
	local success, result = pcall(function()
		return require(ReplicatedStorage:WaitForChild("SnakeSkins", 10))
	end)
	if success then
		SnakeSkins = result
		print("✅ SnakeSkins loaded successfully")
	else
		warn("❌ Failed to load SnakeSkins:", result)
	end
	
	-- Load AdvancedSnakePreview (will be in StarterPlayerScripts)
	success, result = pcall(function()
		return require(script.Parent:WaitForChild("AdvancedSnakePreview", 10))
	end)
	if success then
		AdvancedSnakePreview = result
		print("✅ AdvancedSnakePreview loaded successfully")
	else
		warn("❌ Failed to load AdvancedSnakePreview:", result)
	end
	
	-- Load ExtremeVFX if available
	success, result = pcall(function()
		return require(ReplicatedStorage:WaitForChild("ExtremeVFX", 5))
	end)
	if success then
		ExtremeVFX = result
		print("✅ ExtremeVFX loaded successfully")
	end
end

-- Enhanced RemoteEvent handling
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

-- Initialize remotes
local SelectSkinRemote = getRemote("SelectSkin")
local RespawnSnakeRemote = getRemote("RespawnSnake")
local PurchaseItemRemote = getRemote("PurchaseItem")
local UpdateClientRemote = getRemote("UpdateClientSkinData")

-- EXTREME SHOP CONFIGURATION V8
local SHOP_CONFIG = {
	-- Enhanced visual settings
	COLORS = {
		BACKGROUND = Color3.fromRGB(15, 17, 25),
		PRIMARY = Color3.fromRGB(25, 28, 38),
		SECONDARY = Color3.fromRGB(35, 40, 52),
		TERTIARY = Color3.fromRGB(45, 52, 65),
		ACCENT = Color3.fromRGB(100, 255, 150),
		TEXT_PRIMARY = Color3.fromRGB(255, 255, 255),
		TEXT_SECONDARY = Color3.fromRGB(180, 185, 195),
		SUCCESS = Color3.fromRGB(0, 255, 127),
		WARNING = Color3.fromRGB(255, 180, 0),
		ERROR = Color3.fromRGB(255, 75, 75),
		VIP_GOLD = Color3.fromRGB(255, 215, 0),
		PREMIUM_PURPLE = Color3.fromRGB(180, 100, 255),
		LEGENDARY_RED = Color3.fromRGB(255, 50, 100),
	},
	
	-- Enhanced fonts
	FONTS = {
		TITLE = Enum.Font.GothamBold,
		HEADING = Enum.Font.Gotham,
		BUTTON = Enum.Font.GothamMedium,
		BODY = Enum.Font.Gotham,
		PRICE = Enum.Font.GothamBold,
		SPECIAL = Enum.Font.SciFi,
	},
	
	-- Animation settings
	ANIMATIONS = {
		HOVER_SCALE = 1.05,
		CLICK_SCALE = 0.95,
		TRANSITION_TIME = 0.3,
		BOUNCE_TIME = 0.4,
		GLOW_SPEED = 2,
		PARTICLE_SPEED = 1.5,
	},
	
	-- Layout settings
	LAYOUT = {
		CARD_WIDTH = 160,
		CARD_HEIGHT = 200,
		GRID_SPACING = 12,
		PADDING = 20,
		CORNER_RADIUS = 12,
		STROKE_THICKNESS = 2,
	},
	
	-- Sound effects
	SOUNDS = {
		HOVER = "rbxassetid://12221984",
		CLICK = "rbxassetid://12221990",
		PURCHASE = "rbxassetid://12221996",
		ERROR = "rbxassetid://12222005",
		SUCCESS = "rbxassetid://12222019",
		OPEN = "rbxassetid://12222024",
		CLOSE = "rbxassetid://12222030",
		COIN = "rbxassetid://12222035",
		VIP = "rbxassetid://12222040",
	},
}

-- Enhanced player data management
ShopUI.playerData = {
	coins = 0,
	gems = 0,
	ownedSkins = {},
	favoriteSkins = {},
	currentSkin = "Default",
	settings = {
		soundEnabled = true,
		particlesEnabled = true,
		qualityMode = "High",
	},
	stats = {
		totalPurchases = 0,
		totalSpent = 0,
		favoriteCategory = "Featured",
	},
}

-- Advanced sound system
local soundCache = {}
local function playSound(soundName, volume, pitch)
	if not ShopUI.playerData.settings.soundEnabled then return end
	
	local soundId = SHOP_CONFIG.SOUNDS[soundName]
	if not soundId then return end
	
	local sound = soundCache[soundName]
	if not sound then
		sound = Instance.new("Sound")
		sound.SoundId = soundId
		sound.Volume = volume or 0.5
		sound.Pitch = pitch or 1
		sound.Parent = playerGui
		soundCache[soundName] = sound
	end
	
	sound.Volume = volume or 0.5
	sound.Pitch = pitch or 1
	sound:Play()
end

-- Advanced UI creation helpers
local function createCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or SHOP_CONFIG.LAYOUT.CORNER_RADIUS)
	corner.Parent = parent
	return corner
end

local function createStroke(parent, color, thickness, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or SHOP_CONFIG.COLORS.ACCENT
	stroke.Thickness = thickness or SHOP_CONFIG.LAYOUT.STROKE_THICKNESS
	stroke.Transparency = transparency or 0
	stroke.Parent = parent
	return stroke
end

local function createGradient(parent, colors, rotation)
	local gradient = Instance.new("UIGradient")
	gradient.Color = colors or ColorSequence.new{
		ColorSequenceKeypoint.new(0, SHOP_CONFIG.COLORS.PRIMARY),
		ColorSequenceKeypoint.new(1, SHOP_CONFIG.COLORS.SECONDARY)
	}
	gradient.Rotation = rotation or 90
	gradient.Parent = parent
	return gradient
end

local function createGlow(parent, color, size)
	local glow = Instance.new("ImageLabel")
	glow.Name = "Glow"
	glow.Size = UDim2.new(1 + size, 0, 1 + size, 0)
	glow.Position = UDim2.new(-size/2, 0, -size/2, 0)
	glow.BackgroundTransparency = 1
	glow.Image = "rbxassetid://5028857084"
	glow.ImageColor3 = color or SHOP_CONFIG.COLORS.ACCENT
	glow.ImageTransparency = 0.8
	glow.ZIndex = parent.ZIndex - 1
	glow.Parent = parent
	return glow
end

-- Particle system for premium effects
local function createParticles(parent, particleType)
	if not ShopUI.playerData.settings.particlesEnabled then return end
	
	local attachment = Instance.new("Attachment")
	attachment.Parent = parent
	
	local emitter = Instance.new("ParticleEmitter")
	emitter.Parent = attachment
	
	if particleType == "sparkle" then
		emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		emitter.Rate = 10
		emitter.Lifetime = NumberRange.new(1, 2)
		emitter.Speed = NumberRange.new(1, 3)
		emitter.SpreadAngle = Vector2.new(180, 180)
		emitter.Color = ColorSequence.new(SHOP_CONFIG.COLORS.ACCENT)
		emitter.LightEmission = 1
	elseif particleType == "fire" then
		emitter.Texture = "rbxasset://textures/particles/fire_main.dds"
		emitter.Rate = 20
		emitter.Lifetime = NumberRange.new(0.5, 1)
		emitter.Speed = NumberRange.new(3, 5)
		emitter.SpreadAngle = Vector2.new(30, 30)
		emitter.Color = ColorSequence.new(Color3.fromRGB(255, 100, 0))
		emitter.LightEmission = 1
	elseif particleType == "stars" then
		emitter.Texture = "rbxasset://textures/particles/star_outline.dds"
		emitter.Rate = 5
		emitter.Lifetime = NumberRange.new(2, 3)
		emitter.Speed = NumberRange.new(0.5, 1)
		emitter.SpreadAngle = Vector2.new(360, 360)
		emitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
		emitter.LightEmission = 1
	end
	
	return emitter
end

-- This is where CharacterPreview would have been
-- Now it's handled by AdvancedSnakePreview module

-- Continue with the rest of ShopUI...