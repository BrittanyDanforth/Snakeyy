-- VFXManager: Enhanced with comprehensive graphics mode support
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local VFXManager = {}

-- Cache for effect templates to avoid recreating them
local effectTemplates = {}

-- Graphics mode configurations
local GRAPHICS_SETTINGS = {
	High = {
		-- Full effects
		orbGlow = true,
		orbParticles = true,
		particleCount = 20,
		lightingEnabled = true,
		shadowsEnabled = true,
		materialQuality = Enum.Material.ForceField,
		orbTransparency = 0,
		glowBrightness = 2,
		glowRange = 8,
	},
	Medium = {
		-- Reduced effects
		orbGlow = true,
		orbParticles = true,
		particleCount = 10,
		lightingEnabled = true,
		shadowsEnabled = false,
		materialQuality = Enum.Material.Neon,
		orbTransparency = 0.1,
		glowBrightness = 1.5,
		glowRange = 6,
	},
	Low = {
		-- Minimal effects
		orbGlow = false,
		orbParticles = false,
		particleCount = 0,
		lightingEnabled = false,
		shadowsEnabled = false,
		materialQuality = Enum.Material.SmoothPlastic,
		orbTransparency = 0.2,
		glowBrightness = 0,
		glowRange = 0,
	}
}

-- Helper to get graphics mode for a player (defaults to "High")
local function getGraphicsModeForPlayer(player)
	if not player then return "High" end
	local mode = player:GetAttribute("GraphicsMode")
	if GRAPHICS_SETTINGS[mode] then
		return mode
	end
	return "High"
end

-- Get graphics settings for a mode
function VFXManager.getGraphicsSettings(mode)
	return GRAPHICS_SETTINGS[mode] or GRAPHICS_SETTINGS.High
end

-- Apply graphics mode to the game environment
function VFXManager.applyGraphicsMode(player, mode)
	local settings = GRAPHICS_SETTINGS[mode] or GRAPHICS_SETTINGS.High
	
	-- Apply lighting changes for the player
	if player == Players.LocalPlayer then
		-- Client-side lighting adjustments
		if settings.shadowsEnabled then
			Lighting.GlobalShadows = true
			Lighting.ShadowSoftness = 0.5
		else
			Lighting.GlobalShadows = false
		end
		
		-- Adjust ambient lighting for performance
		if mode == "Low" then
			Lighting.Brightness = 2
			Lighting.EnvironmentDiffuseScale = 0.5
			Lighting.EnvironmentSpecularScale = 0.5
		elseif mode == "Medium" then
			Lighting.Brightness = 1.5
			Lighting.EnvironmentDiffuseScale = 0.75
			Lighting.EnvironmentSpecularScale = 0.75
		else
			Lighting.Brightness = 1
			Lighting.EnvironmentDiffuseScale = 1
			Lighting.EnvironmentSpecularScale = 1
		end
	end
end

-- Creates a template for the orb collection particle effect based on graphics mode
local function createOrbEffectTemplate(graphicsMode)
	local settings = GRAPHICS_SETTINGS[graphicsMode] or GRAPHICS_SETTINGS.High
	
	if not settings.orbParticles then
		-- No particles in low graphics mode
		return nil
	end
	
	local key = "OrbCollect_" .. graphicsMode
	if effectTemplates[key] then
		return effectTemplates[key]:Clone()
	end

	local attachment = Instance.new("Attachment")
	local emitter = Instance.new("ParticleEmitter")
	emitter.Parent = attachment

	-- Adjust particle settings based on graphics mode
	emitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 170, 0))
	emitter.LightEmission = settings.lightingEnabled and 1 or 0.5
	
	if graphicsMode == "High" then
		-- High quality particles
		emitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(0.5, 1.5),
			NumberSequenceKeypoint.new(1, 1)
		})
		emitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.7, 0.5),
			NumberSequenceKeypoint.new(1, 1)
		})
		emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	else
		-- Simplified particles for medium mode
		emitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(1, 0.8)
		})
		emitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(1, 1)
		})
		emitter.Texture = "" -- Use default particle
	end
	
	emitter.Speed = NumberRange.new(5, 10)
	emitter.Lifetime = NumberRange.new(0.3, 0.6)
	emitter.Rate = 0
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter.Shape = Enum.ParticleEmitterShape.Sphere
	emitter.SpreadAngle = Vector2.new(360, 360)
	emitter.ZOffset = 1

	effectTemplates[key] = attachment
	return attachment:Clone()
end

-- Plays the orb collection VFX at a given world position
function VFXManager.playOrbCollectVFX(position, player)
	local graphicsMode = getGraphicsModeForPlayer(player)
	local settings = GRAPHICS_SETTINGS[graphicsMode]
	
	-- Skip VFX entirely in low graphics mode
	if not settings.orbParticles then
		return
	end
	
	local effect = createOrbEffectTemplate(graphicsMode)
	if not effect then
		return
	end
	
	effect.Parent = workspace
	effect.WorldPosition = position
	
	local emitter = effect:FindFirstChildOfClass("ParticleEmitter")
	if emitter then
		emitter:Emit(settings.particleCount)
	end

	-- Clean up the effect
	task.delay(emitter and emitter.Lifetime.Max + 0.1 or 1, function()
		effect:Destroy()
	end)
end

-- Create optimized orb based on graphics settings
function VFXManager.createOptimizedOrb(baseOrb, player)
	local mode = getGraphicsModeForPlayer(player)
	local settings = GRAPHICS_SETTINGS[mode]
	
	-- Apply material and transparency
	baseOrb.Material = settings.materialQuality
	baseOrb.Transparency = settings.orbTransparency
	
	-- Handle glow/lighting
	local light = baseOrb:FindFirstChild("PointLight")
	if light then
		if settings.orbGlow then
			light.Enabled = true
			light.Brightness = settings.glowBrightness
			light.Range = settings.glowRange
		else
			light.Enabled = false
		end
	elseif settings.orbGlow then
		-- Create light if needed and settings allow
		light = Instance.new("PointLight")
		light.Parent = baseOrb
		light.Color = baseOrb.Color
		light.Brightness = settings.glowBrightness
		light.Range = settings.glowRange
	end
	
	return baseOrb
end

-- Get render distances based on graphics mode
function VFXManager.getRenderDistances(mode)
	if mode == "Low" then
		return {
			render = 75,   -- Much shorter render distance
			far = 150,     -- Reduced far distance
			fade = 25,     -- Shorter fade distance
			updateRate = 0.2  -- Less frequent updates
		}
	elseif mode == "Medium" then
		return {
			render = 125,
			far = 250,
			fade = 40,
			updateRate = 0.15
		}
	else -- High
		return {
			render = 150,
			far = 300,
			fade = 50,
			updateRate = 0.1
		}
	end
end

-- Handle graphics mode changes
local SetGraphicsModeEvent = ReplicatedStorage:FindFirstChild("SetGraphicsMode")
if SetGraphicsModeEvent then
	-- Server-side listener
	if game:GetService("RunService"):IsServer() then
		SetGraphicsModeEvent.OnServerEvent:Connect(function(player, mode)
			if GRAPHICS_SETTINGS[mode] then
				player:SetAttribute("GraphicsMode", mode)
				print("Set graphics mode for", player.Name, "to", mode)
			end
		end)
	else
		-- Client-side: Apply graphics mode when it changes
		Players.LocalPlayer.AttributeChanged:Connect(function(attr)
			if attr == "GraphicsMode" then
				local mode = Players.LocalPlayer:GetAttribute("GraphicsMode") or "High"
				VFXManager.applyGraphicsMode(Players.LocalPlayer, mode)
			end
		end)
	end
end

return VFXManager