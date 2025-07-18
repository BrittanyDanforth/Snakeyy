-- VFXManager: Handles creation of visual effects with graphics mode support
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local VFXManager = {}

-- Cache for effect templates to avoid recreating them
local effectTemplates = {}

-- Graphics mode configurations
local GRAPHICS_SETTINGS = {
	High = {
		orbGlow = true,
		orbParticles = true,
		particleCount = 20,
		lightingEnabled = true,
		glowBrightness = 2,
		glowRange = 8,
	},
	Medium = {
		orbGlow = true,
		orbParticles = true,
		particleCount = 10,
		lightingEnabled = true,
		glowBrightness = 1.5,
		glowRange = 6,
	},
	Low = {
		orbGlow = false,
		orbParticles = false,
		particleCount = 0,
		lightingEnabled = false,
		glowBrightness = 0,
		glowRange = 0,
	}
}

-- Helper to get graphics mode for a player (defaults to "High")
local function getGraphicsModeForPlayer(player)
	if not player then return "High" end
	local mode = player:GetAttribute("GraphicsMode")
	if mode == "Low" or mode == "Medium" then
		return mode
	end
	return "High"
end

-- Get graphics settings
function VFXManager.getGraphicsSettings(mode)
	return GRAPHICS_SETTINGS[mode] or GRAPHICS_SETTINGS.High
end

-- Creates a template for the orb collection particle effect.
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

	emitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 170, 0))
	emitter.LightEmission = settings.lightingEnabled and 1 or 0.5
	
	if graphicsMode == "High" then
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
	else -- Medium
		emitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(1, 0.8)
		})
		emitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(1, 1)
		})
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
		local settings = GRAPHICS_SETTINGS[graphicsMode]
		emitter:Emit(settings.particleCount)
	end

	-- Clean up the effect from the workspace after it has finished playing.
	task.delay(emitter.Lifetime.Max + 0.1, function()
		effect:Destroy()
	end)
end

-- Handle graphics mode changes
local SetGraphicsModeEvent = ReplicatedStorage:FindFirstChild("SetGraphicsMode")
if SetGraphicsModeEvent then
	if game:GetService("RunService"):IsServer() then
		SetGraphicsModeEvent.OnServerEvent:Connect(function(player, mode)
			if GRAPHICS_SETTINGS[mode] then
				player:SetAttribute("GraphicsMode", mode)
			end
		end)
	end
end

-- Snake VFX Configuration with EXTREME effects
local skinVFXConfigs = {
	["Dragon Lord"] = {
		headGlow = {color = Color3.fromRGB(255, 85, 0), brightness = 15, range = 25},
		segmentGlow = {color = Color3.fromRGB(255, 128, 0), brightness = 8, range = 15},
		particles = {
			texture = "rbxasset://textures/particles/fire_main.dds",
			color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 0)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 100, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 50, 0))
			}),
			rate = 100,
			lifetime = NumberRange.new(1, 3),
			speed = NumberRange.new(5, 15),
			size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 2),
				NumberSequenceKeypoint.new(0.5, 4),
				NumberSequenceKeypoint.new(1, 0)
			})
		},
		trail = {
			color = ColorSequence.new(Color3.fromRGB(255, 150, 0), Color3.fromRGB(255, 50, 0)),
			lifetime = 2,
			minLength = 0,
			widthScale = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 3),
				NumberSequenceKeypoint.new(0.5, 2),
				NumberSequenceKeypoint.new(1, 0)
			})
		}
	},
	["VIP"] = {
		headGlow = {color = Color3.fromRGB(255, 215, 0), brightness = 20, range = 30},
		segmentGlow = {color = Color3.fromRGB(255, 223, 0), brightness = 10, range = 20},
		particles = {
			texture = "rbxasset://textures/particles/sparkles_main.dds",
			color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 0)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 223, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 200, 0))
			}),
			rate = 150,
			lifetime = NumberRange.new(2, 4),
			speed = NumberRange.new(10, 20),
			size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.3, 3),
				NumberSequenceKeypoint.new(1, 0)
			})
		},
		trail = {
			color = ColorSequence.new(Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 200, 0)),
			lifetime = 3,
			minLength = 0,
			widthScale = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 4),
				NumberSequenceKeypoint.new(0.5, 3),
				NumberSequenceKeypoint.new(1, 0)
			})
		},
		aura = true -- Special VIP aura effect
	},
	["Neon Viper"] = {
		headGlow = {color = Color3.fromRGB(0, 255, 255), brightness = 18, range = 28},
		segmentGlow = {color = Color3.fromRGB(0, 200, 255), brightness = 12, range = 18},
		particles = {
			texture = "rbxasset://textures/particles/smoke_main.dds",
			color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 0, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 0, 255))
			}),
			rate = 120,
			lifetime = NumberRange.new(1.5, 3.5),
			speed = NumberRange.new(8, 18),
			size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1.5),
				NumberSequenceKeypoint.new(0.4, 3.5),
				NumberSequenceKeypoint.new(1, 0)
			})
		},
		trail = {
			color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 0, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 255))
			}),
			lifetime = 2.5,
			minLength = 0,
			widthScale = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 3.5),
				NumberSequenceKeypoint.new(0.5, 2.5),
				NumberSequenceKeypoint.new(1, 0)
			})
		},
		electricity = true -- Special electric effect
	},
	["Crystal Serpent"] = {
		headGlow = {color = Color3.fromRGB(255, 0, 255), brightness = 16, range = 24},
		segmentGlow = {color = Color3.fromRGB(200, 0, 255), brightness = 10, range = 16},
		particles = {
			texture = "rbxasset://textures/particles/sparkles_main.dds",
			color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 255)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 0, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 200))
			}),
			rate = 80,
			lifetime = NumberRange.new(2, 4),
			speed = NumberRange.new(3, 8),
			size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 2),
				NumberSequenceKeypoint.new(0.5, 3),
				NumberSequenceKeypoint.new(1, 0)
			})
		},
		crystal = true -- Special crystalline effect
	},
	["Rainbow"] = {
		headGlow = {color = Color3.fromRGB(255, 255, 255), brightness = 25, range = 35},
		segmentGlow = {color = Color3.fromRGB(255, 255, 255), brightness = 15, range = 25},
		rainbow = true -- Special rainbow effect with curved beams
	}
}

-- Helper function to create glow effect
local function createGlowEffect(part, config)
	-- Main point light
	local pointLight = Instance.new("PointLight")
	pointLight.Color = config.color
	pointLight.Brightness = config.brightness
	pointLight.Range = config.range
	pointLight.Shadows = true
	pointLight.Parent = part
	
	-- Extra glow with SurfaceLight for more intensity
	local surfaceLight = Instance.new("SurfaceLight")
	surfaceLight.Color = config.color
	surfaceLight.Brightness = config.brightness * 0.5
	surfaceLight.Range = config.range * 0.7
	surfaceLight.Face = Enum.NormalId.Front
	surfaceLight.Parent = part
	
	-- SelectionBox for outline glow
	local selectionBox = Instance.new("SelectionBox")
	selectionBox.Adornee = part
	selectionBox.Color3 = config.color
	selectionBox.LineThickness = 0.15
	selectionBox.Transparency = 0.3
	selectionBox.Parent = part
	
	return {pointLight = pointLight, surfaceLight = surfaceLight, selectionBox = selectionBox}
end

-- Create extreme particle emitter
local function createParticleEmitter(part, config)
	local attachment = Instance.new("Attachment")
	attachment.Parent = part
	
	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = config.texture
	emitter.Color = config.color
	emitter.Lifetime = config.lifetime
	emitter.Rate = config.rate
	emitter.Speed = config.speed
	emitter.SpreadAngle = Vector2.new(360, 360)
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter.VelocityInheritance = 0.3
	emitter.LightEmission = 1
	emitter.LightInfluence = 0
	emitter.Size = config.size or NumberSequence.new(2)
	emitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.7, 0.3),
		NumberSequenceKeypoint.new(1, 1)
	})
	emitter.ZOffset = 2
	emitter.Parent = attachment
	
	return {attachment = attachment, emitter = emitter}
end

-- Create trail effect
local function createTrailEffect(part1, part2, config)
	local att1 = Instance.new("Attachment")
	att1.Parent = part1
	
	local att2 = Instance.new("Attachment")
	att2.Parent = part2
	
	local trail = Instance.new("Trail")
	trail.Attachment0 = att1
	trail.Attachment1 = att2
	trail.Color = config.color
	trail.Lifetime = config.lifetime
	trail.MinLength = config.minLength
	trail.WidthScale = config.widthScale
	trail.LightEmission = 1
	trail.LightInfluence = 0
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.5, 0.2),
		NumberSequenceKeypoint.new(1, 1)
	})
	trail.Parent = part1
	
	return {attachment1 = att1, attachment2 = att2, trail = trail}
end

-- Create VIP aura effect
local function createAuraEffect(part)
	local auraAttachment = Instance.new("Attachment")
	auraAttachment.Parent = part
	
	-- Golden aura particles
	local aura = Instance.new("ParticleEmitter")
	aura.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	aura.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
	aura.Lifetime = NumberRange.new(2, 4)
	aura.Rate = 200
	aura.Speed = NumberRange.new(0, 2)
	aura.SpreadAngle = Vector2.new(360, 360)
	aura.VelocityInheritance = 0
	aura.EmissionDirection = Enum.NormalId.Top
	aura.LightEmission = 1
	aura.LightInfluence = 0
	aura.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.1, 4),
		NumberSequenceKeypoint.new(1, 6)
	})
	aura.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.2, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	})
	aura.ZOffset = -1
	aura.Parent = auraAttachment
	
	return {attachment = auraAttachment, emitter = aura}
end

-- Create electric effect for Neon Viper
local function createElectricEffect(part)
	local electricAttachment = Instance.new("Attachment")
	electricAttachment.Parent = part
	
	-- Electric sparks
	local sparks = Instance.new("ParticleEmitter")
	sparks.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparks.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 255))
	})
	sparks.Lifetime = NumberRange.new(0.1, 0.5)
	sparks.Rate = 300
	sparks.Speed = NumberRange.new(10, 30)
	sparks.SpreadAngle = Vector2.new(360, 360)
	sparks.VelocityInheritance = 0
	sparks.EmissionDirection = Enum.NormalId.Top
	sparks.LightEmission = 1
	sparks.LightInfluence = 0
	sparks.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.5, 1),
		NumberSequenceKeypoint.new(1, 0)
	})
	sparks.Drag = 5
	sparks.Parent = electricAttachment
	
	return {attachment = electricAttachment, emitter = sparks}
end

-- Create AMAZING rainbow effect optimized for ViewportFrames
local function createRainbowEffect(part, isHead)
	local effects = {}
	
	-- VIEWPORT-FRIENDLY APPROACH: Use colored parts instead of beams
	if isHead then
		-- Create rainbow aura using colored neon parts
		local auraCount = 12
		for i = 1, auraCount do
			local angle = (i - 1) * (math.pi * 2 / auraCount)
			local hue = (i - 1) / auraCount
			
			-- Create glowing orb
			local orb = Instance.new("Part")
			orb.Name = "RainbowOrb"..i
			orb.Size = Vector3.new(1.5, 1.5, 1.5)
			orb.Shape = Enum.PartType.Ball
			orb.Material = Enum.Material.Neon
			orb.Color = Color3.fromHSV(hue, 1, 1)
			orb.Transparency = 0.3
			orb.CanCollide = false
			orb.CanQuery = false
			orb.CanTouch = false
			orb.Anchored = true
			orb.Parent = part.Parent
			
			-- Position in circle around head
			local radius = 3
			orb.Position = part.Position + Vector3.new(
				math.cos(angle) * radius,
				0,
				math.sin(angle) * radius
			)
			
			-- Add glow
			local glow = Instance.new("PointLight")
			glow.Color = orb.Color
			glow.Brightness = 5
			glow.Range = 10
			glow.Parent = orb
			
			table.insert(effects, {
				orb = orb,
				baseAngle = angle,
				index = i,
				hue = hue,
				radius = radius
			})
		end
		
		-- Add central rainbow particles
		local centralAttachment = Instance.new("Attachment")
		centralAttachment.Parent = part
		
		local rainbow = Instance.new("ParticleEmitter")
		rainbow.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		rainbow.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 165, 0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(130, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
		})
		rainbow.Lifetime = NumberRange.new(1, 2)
		rainbow.Rate = 200
		rainbow.Speed = NumberRange.new(5, 10)
		rainbow.SpreadAngle = Vector2.new(360, 360)
		rainbow.VelocityInheritance = 0
		rainbow.EmissionDirection = Enum.NormalId.Top
		rainbow.LightEmission = 1
		rainbow.LightInfluence = 0
		rainbow.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(0.5, 2),
			NumberSequenceKeypoint.new(1, 0)
		})
		rainbow.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.7, 0.3),
			NumberSequenceKeypoint.new(1, 1)
		})
		rainbow.ZOffset = 1
		rainbow.Parent = centralAttachment
		
		table.insert(effects, {emitter = rainbow, attachment = centralAttachment})
		
		-- Add rainbow selection box for extra glow
		local selection = Instance.new("SelectionBox")
		selection.Adornee = part
		selection.Color3 = Color3.fromRGB(255, 255, 255)
		selection.LineThickness = 0.3
		selection.Transparency = 0
		selection.SurfaceTransparency = 0.8
		selection.Parent = part
		
		table.insert(effects, {selectionBox = selection})
	else
		-- For segments, just add rainbow particles
		local attachment = Instance.new("Attachment")
		attachment.Parent = part
		
		local particles = Instance.new("ParticleEmitter")
		particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		particles.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
		})
		particles.Lifetime = NumberRange.new(0.5, 1)
		particles.Rate = 50
		particles.Speed = NumberRange.new(2, 4)
		particles.SpreadAngle = Vector2.new(180, 180)
		particles.LightEmission = 1
		particles.Size = NumberSequence.new(1)
		particles.Parent = attachment
		
		table.insert(effects, {emitter = particles, attachment = attachment})
	end
	
	return effects
end

-- Apply VFX to snake preview
function VFXManager.ApplySnakePreviewVFX(model, skinName)
	print("🎨 VFXManager.ApplySnakePreviewVFX called for:", skinName)
	
	-- Remove any existing VFX first
	VFXManager.RemoveSnakeVFX(model)
	
	local config = skinVFXConfigs[skinName]
	if not config then
		print("❌ No VFX config found for skin:", skinName)
		return -- No VFX for this skin
	end
	
	print("✅ Found VFX config for:", skinName)
	
	local vfxData = {
		glowEffects = {},
		particleEffects = {},
		trailEffects = {},
		specialEffects = {}
	}
	
	-- Apply to head
	local head = model:FindFirstChild("Head") or model:FindFirstChild("SnakeHead")
	print("🐍 Looking for head, found:", head)
	if head and config.headGlow then
		local glowEffect = createGlowEffect(head, config.headGlow)
		table.insert(vfxData.glowEffects, glowEffect)
		
		if config.particles then
			local particleEffect = createParticleEmitter(head, config.particles)
			table.insert(vfxData.particleEffects, particleEffect)
		end
		
		-- Special effects
		if config.aura then
			local auraEffect = createAuraEffect(head)
			table.insert(vfxData.specialEffects, auraEffect)
		end
		
		if config.electricity then
			local electricEffect = createElectricEffect(head)
			table.insert(vfxData.specialEffects, electricEffect)
		end
		
		if config.rainbow then
			print("🌈 Creating rainbow effect for head!")
			local rainbowEffects = createRainbowEffect(head, true)
			print("🌈 Created", #rainbowEffects, "rainbow effects")
			for _, effect in ipairs(rainbowEffects) do
				table.insert(vfxData.specialEffects, effect)
			end
		end
	end
	
	-- Apply to segments with trail effects
	local segments = {}
	for _, child in ipairs(model:GetChildren()) do
		if child:IsA("BasePart") and child.Name:match("Segment") then
			table.insert(segments, child)
		end
	end
	
	-- Sort segments by index
	table.sort(segments, function(a, b)
		local indexA = tonumber(a.Name:match("%d+")) or 0
		local indexB = tonumber(b.Name:match("%d+")) or 0
		return indexA < indexB
	end)
	
	-- Apply effects to segments
	for i, segment in ipairs(segments) do
		if config.segmentGlow then
			-- Reduce glow intensity for segments further back
			local glowConfig = {
				color = config.segmentGlow.color,
				brightness = config.segmentGlow.brightness * (1 - (i / #segments) * 0.5),
				range = config.segmentGlow.range * (1 - (i / #segments) * 0.3)
			}
			local glowEffect = createGlowEffect(segment, glowConfig)
			table.insert(vfxData.glowEffects, glowEffect)
		end
		
		-- Add trails between segments
		if config.trail and i > 1 then
			local prevSegment = segments[i - 1]
			local trailEffect = createTrailEffect(prevSegment, segment, config.trail)
			table.insert(vfxData.trailEffects, trailEffect)
		end
		
		-- Add particles to some segments
		if config.particles and i % 3 == 0 then -- Every 3rd segment
			local particleConfig = {
				texture = config.particles.texture,
				color = config.particles.color,
				rate = config.particles.rate * 0.3, -- Less particles on segments
				lifetime = config.particles.lifetime,
				speed = config.particles.speed,
				size = config.particles.size
			}
			local particleEffect = createParticleEmitter(segment, particleConfig)
			table.insert(vfxData.particleEffects, particleEffect)
		end
		
		-- Add rainbow beams to some segments
		if config.rainbow and i % 5 == 1 then -- Every 5th segment
			local rainbowEffects = createRainbowEffect(segment, false)
			for _, effect in ipairs(rainbowEffects) do
				table.insert(vfxData.specialEffects, effect)
			end
		end
	end
	
	-- Store VFX data for later removal
	activeVFX[model] = vfxData
	
	-- Start update loop for animated effects
	if config.aura or config.electricity or config.rainbow then
		VFXManager.StartVFXAnimation(model, skinName)
	end
end

-- Animate VFX effects
function VFXManager.StartVFXAnimation(model, skinName)
	local connection
	local config = skinVFXConfigs[skinName]
	
	connection = RunService.Heartbeat:Connect(function()
		if not model.Parent then
			connection:Disconnect()
			return
		end
		
		local vfxData = activeVFX[model]
		if not vfxData then
			connection:Disconnect()
			return
		end
		
		local time = tick()
		
		-- Animate special effects
		for _, effect in ipairs(vfxData.specialEffects) do
			if effect.emitter then
				-- Pulse effect for aura/electric
				local pulse = math.sin(time * 2) * 0.5 + 0.5
				effect.emitter.Rate = effect.emitter.Rate * (0.8 + pulse * 0.4)
			elseif effect.orb then
				-- Animate rainbow orbs
				local baseAngle = effect.baseAngle
				local index = effect.index
				
				-- Make orbs rotate and pulse
				local rotSpeed = 1
				local pulseSpeed = 3
				local verticalSpeed = 2
				
				local currentAngle = baseAngle + (time * rotSpeed)
				local pulse = math.sin(time * pulseSpeed + index * 0.5) * 0.3 + 1
				local verticalOffset = math.sin(time * verticalSpeed + index * 0.3) * 2
				
				-- Update orb position
				if effect.orb.Parent then
					local centerPart = effect.orb.Parent:FindFirstChild("Head") or effect.orb.Parent:FindFirstChild("SnakeHead")
					if centerPart then
						local radius = effect.radius * pulse
						effect.orb.Position = centerPart.Position + Vector3.new(
							math.cos(currentAngle) * radius,
							verticalOffset,
							math.sin(currentAngle) * radius
						)
						
						-- Animate color through rainbow
						local hue = (effect.hue + time * 0.5) % 1
						effect.orb.Color = Color3.fromHSV(hue, 1, 1)
						
						-- Update glow color
						local glow = effect.orb:FindFirstChild("PointLight")
						if glow then
							glow.Color = effect.orb.Color
							glow.Brightness = 5 + math.sin(time * 4 + index) * 2
						end
						
						-- Pulse size
						effect.orb.Size = Vector3.new(1.5, 1.5, 1.5) * pulse
					end
				end
			elseif effect.selectionBox then
				-- Animate selection box rainbow
				local hue = (time * 0.3) % 1
				effect.selectionBox.Color3 = Color3.fromHSV(hue, 1, 1)
			end
		end
	end)
	
	-- Store connection for cleanup
	if not activeVFX[model] then
		activeVFX[model] = {}
	end
	activeVFX[model].animationConnection = connection
end

-- Remove VFX from snake
function VFXManager.RemoveSnakeVFX(model)
	local vfxData = activeVFX[model]
	if not vfxData then return end
	
	-- Stop animation
	if vfxData.animationConnection then
		vfxData.animationConnection:Disconnect()
	end
	
	-- Remove glow effects
	for _, effect in ipairs(vfxData.glowEffects or {}) do
		if effect.pointLight then effect.pointLight:Destroy() end
		if effect.surfaceLight then effect.surfaceLight:Destroy() end
		if effect.selectionBox then effect.selectionBox:Destroy() end
	end
	
	-- Remove particle effects
	for _, effect in ipairs(vfxData.particleEffects or {}) do
		if effect.attachment then effect.attachment:Destroy() end
	end
	
	-- Remove trail effects
	for _, effect in ipairs(vfxData.trailEffects or {}) do
		if effect.attachment1 then effect.attachment1:Destroy() end
		if effect.attachment2 then effect.attachment2:Destroy() end
		if effect.trail then effect.trail:Destroy() end
	end
	
	-- Remove special effects
	for _, effect in ipairs(vfxData.specialEffects or {}) do
		if effect.attachment then effect.attachment:Destroy() end
		if effect.orb then effect.orb:Destroy() end
		if effect.emitter then effect.emitter:Destroy() end
		if effect.selectionBox then effect.selectionBox:Destroy() end
	end
	
	activeVFX[model] = nil
end

-- Check if a skin has VFX
function VFXManager.SkinHasVFX(skinName)
	return skinVFXConfigs[skinName] ~= nil
end

-- Get VFX config for a skin
function VFXManager.GetSkinVFXConfig(skinName)
	return skinVFXConfigs[skinName]
end

return VFXManager