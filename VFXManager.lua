-- VFXManager: Handles creation of visual effects for orbs and snakes
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local VFXManager = {}

-- Cache for effect templates to avoid recreating them
local effectTemplates = {}
local activeVFX = {}

-- Helper to get graphics mode for a player (defaults to "High")
local function getGraphicsModeForPlayer(player)
	if not player then return "High" end
	local mode = player:GetAttribute("GraphicsMode")
	if mode == "Low" then
		return "Low"
	end
	return "High"
end

-- Creates a template for the orb collection particle effect.
-- This is more efficient than creating a new one from scratch every time.
local function createOrbEffectTemplate(graphicsMode)
	if graphicsMode == "Low" then
		-- No glow effect in low graphics mode
		return nil
	end
	if effectTemplates.OrbCollect then
		return effectTemplates.OrbCollect:Clone()
	end

	local attachment = Instance.new("Attachment")
	local emitter = Instance.new("ParticleEmitter")
	emitter.Parent = attachment

	emitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 170, 0))
	emitter.LightEmission = 1
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
	emitter.Speed = NumberRange.new(5, 10)
	emitter.Lifetime = NumberRange.new(0.3, 0.6)
	emitter.Rate = 0 -- We will emit them all at once using :Emit()
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter.Shape = Enum.ParticleEmitterShape.Sphere
	emitter.SpreadAngle = Vector2.new(360, 360)
	emitter.ZOffset = 1

	effectTemplates.OrbCollect = attachment
	return attachment:Clone()
end

-- Plays the orb collection VFX at a given world position for a specific player (or all if nil)
function VFXManager.playOrbCollectVFX(position, player)
	local graphicsMode = getGraphicsModeForPlayer(player)
	local effect = createOrbEffectTemplate(graphicsMode)
	if not effect then
		return -- No effect in low graphics mode
	end
	effect.Parent = workspace
	effect.WorldPosition = position
	
	local emitter = effect:FindFirstChildOfClass("ParticleEmitter")
	if emitter then
		emitter:Emit(20) -- Emit a burst of 20 particles
	end

	-- Clean up the effect from the workspace after it has finished playing.
	task.delay(emitter.Lifetime.Max + 0.1, function()
		effect:Destroy()
	end)
end