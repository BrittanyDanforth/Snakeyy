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

-- Create AMAZING rainbow effect with curved light beams
local function createRainbowEffect(part, isHead)
	local effects = {}
	
	-- Create multiple beam attachments in a circle
	local beamCount = isHead and 8 or 4
	local radius = isHead and 2 or 1.5
	
	for i = 1, beamCount do
		local angle = (i - 1) * (math.pi * 2 / beamCount)
		
		-- Create attachment on the part
		local att1 = Instance.new("Attachment")
		att1.Position = Vector3.new(
			math.cos(angle) * radius,
			0,
			math.sin(angle) * radius
		)
		att1.Parent = part
		
		-- Create floating attachment above
		local floatPart = Instance.new("Part")
		floatPart.Name = "RainbowFloat"..i
		floatPart.Size = Vector3.new(0.1, 0.1, 0.1)
		floatPart.Transparency = 1
		floatPart.CanCollide = false
		floatPart.CanQuery = false
		floatPart.CanTouch = false
		floatPart.Anchored = true
		floatPart.Parent = part.Parent
		
		local att2 = Instance.new("Attachment")
		att2.Parent = floatPart
		
		-- Create the beam
		local beam = Instance.new("Beam")
		beam.Attachment0 = att1
		beam.Attachment1 = att2
		beam.Width0 = isHead and 2 or 1
		beam.Width1 = 0.1
		beam.CurveSize0 = 10
		beam.CurveSize1 = -10
		beam.FaceCamera = true
		beam.Segments = 20
		beam.LightEmission = 1
		beam.LightInfluence = 0
		beam.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.8),
			NumberSequenceKeypoint.new(0.5, 0.3),
			NumberSequenceKeypoint.new(1, 1)
		})
		
		-- Rainbow color sequence
		beam.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),      -- Red
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 165, 0)), -- Orange
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255, 0)), -- Yellow
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),    -- Green
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 255, 255)), -- Cyan
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(130, 0, 255)), -- Purple
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))     -- Magenta
		})
		
		beam.Parent = part
		
		table.insert(effects, {
			beam = beam,
			att1 = att1,
			att2 = att2,
			floatPart = floatPart,
			baseAngle = angle,
			index = i
		})
	end
	
	-- Add rainbow particle ring
	if isHead then
		local ringAttachment = Instance.new("Attachment")
		ringAttachment.Parent = part
		
		local ringEmitter = Instance.new("ParticleEmitter")
		ringEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		ringEmitter.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.8, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
		})
		ringEmitter.Lifetime = NumberRange.new(2, 3)
		ringEmitter.Rate = 100
		ringEmitter.Speed = NumberRange.new(0, 0)
		ringEmitter.VelocityInheritance = 0
		ringEmitter.EmissionDirection = Enum.NormalId.Top
		ringEmitter.SpreadAngle = Vector2.new(0, 0)
		ringEmitter.LightEmission = 1
		ringEmitter.LightInfluence = 0
		ringEmitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.1, 2),
			NumberSequenceKeypoint.new(0.5, 3),
			NumberSequenceKeypoint.new(1, 0)
		})
		ringEmitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.2, 0),
			NumberSequenceKeypoint.new(0.8, 0),
			NumberSequenceKeypoint.new(1, 1)
		})
		ringEmitter.ZOffset = -2
		ringEmitter.Parent = ringAttachment
		
		table.insert(effects, {emitter = ringEmitter, attachment = ringAttachment})
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
			elseif effect.beam and effect.floatPart then
				-- Animate rainbow beams
				local baseAngle = effect.baseAngle
				local index = effect.index
				
				-- Make beams rotate and wave
				local rotSpeed = 0.5
				local waveHeight = 8
				local waveSpeed = 2
				local radius = 5
				
				local currentAngle = baseAngle + (time * rotSpeed)
				local height = math.sin(time * waveSpeed + index) * waveHeight + 10
				
				-- Update float part position relative to the beam's parent part
				if effect.beam.Parent then
					local partPos = effect.beam.Parent.Position
					effect.floatPart.CFrame = CFrame.new(
						partPos.X + math.cos(currentAngle) * radius,
						partPos.Y + height,
						partPos.Z + math.sin(currentAngle) * radius
					)
				end
				
				-- Animate beam properties
				local colorShift = (time * 0.5 + index * 0.2) % 1
				effect.beam.CurveSize0 = math.sin(time * 3 + index) * 15 + 10
				effect.beam.CurveSize1 = -math.sin(time * 3 + index + math.pi) * 15 - 10
				
				-- Pulse the width
				local widthPulse = math.sin(time * 4 + index * 0.5) * 0.3 + 1
				effect.beam.Width0 = (effect.beam.Parent == model:FindFirstChild("SnakeHead") and 2 or 1) * widthPulse
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
		if effect.beam then effect.beam:Destroy() end
		if effect.att1 then effect.att1:Destroy() end
		if effect.att2 then effect.att2:Destroy() end
		if effect.floatPart then effect.floatPart:Destroy() end
		if effect.emitter then effect.emitter:Destroy() end
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