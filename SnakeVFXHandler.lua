--[[
	SNAKE VFX HANDLER
	Adds epic visual effects to skins based on their tier
	Works with existing skins without modifying them
]]

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local SnakeVFXHandler = {}

-- VFX Configuration per skin
local VFX_CONFIG = {
	-- BASIC TIER (no effects)
	["Default"] = nil,
	
	-- CLASSIC TIER (simple effects)
	["Crimson"] = {
		trail = {
			color = ColorSequence.new(Color3.fromRGB(255, 0, 0)),
			lifetime = 0.5,
			transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.5, 0.3),
				NumberSequenceKeypoint.new(1, 1)
			})
		}
	},
	
	["Arctic"] = {
		particles = {
			texture = "rbxasset://textures/particles/smoke_main.dds",
			color = ColorSequence.new(Color3.fromRGB(200, 230, 255)),
			rate = 10,
			lifetime = NumberRange.new(1, 2),
			speed = NumberRange.new(2),
			emissionDirection = Enum.NormalId.Top
		}
	},
	
	["Emerald"] = {
		sparkles = {
			color = Color3.fromRGB(0, 255, 0),
			rate = 5
		}
	},
	
	["Golden"] = {
		sparkles = {
			color = Color3.fromRGB(255, 215, 0),
			rate = 15
		},
		aura = {
			color = Color3.fromRGB(255, 215, 0),
			size = 1.2
		}
	},
	
	-- PREMIUM TIER (advanced effects)
	["Void"] = {
		blackHole = {
			suckRadius = 10,
			darkParticles = true
		},
		trail = {
			color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(100, 0, 100)),
			lifetime = 1,
			width = NumberSequence.new(3, 0)
		}
	},
	
	["Plasma"] = {
		energyOrbs = {
			count = 3,
			color = Color3.fromRGB(255, 0, 255),
			radius = 5,
			speed = 2
		},
		electricField = {
			color = Color3.fromRGB(255, 0, 255),
			intensity = 2
		}
	},
	
	["Lightning"] = {
		lightningBolts = {
			frequency = 0.5,
			color = Color3.fromRGB(255, 255, 0),
			range = 8
		},
		electricParticles = {
			rate = 50,
			color = ColorSequence.new(Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 255, 255))
		}
	},
	
	["Toxic"] = {
		poisonCloud = {
			color = Color3.fromRGB(0, 255, 0),
			transparency = 0.5,
			damage = false -- visual only
		},
		bubbles = {
			color = Color3.fromRGB(0, 255, 0),
			rate = 20
		}
	},
	
	["Phoenix"] = {
		fireWings = {
			size = 10,
			color = Color3.fromRGB(255, 100, 0)
		},
		fireParticles = {
			rate = 100,
			color = ColorSequence.new(Color3.fromRGB(255, 100, 0), Color3.fromRGB(255, 0, 0))
		},
		rebornEffect = true
	},
	
	-- VIP TIER (insane effects)
	["VIP Diamond"] = {
		crystalShards = {
			count = 8,
			floating = true,
			rotation = true
		},
		rainbowAura = {
			pulse = true,
			size = 2
		},
		sparkleStorm = {
			rate = 100,
			colors = "rainbow"
		}
	},
	
	["VIP Inferno"] = {
		fireStorm = {
			radius = 15,
			damage = false
		},
		lavaTrail = {
			burning = true,
			lifetime = 3
		},
		demonWings = {
			size = 15,
			animated = true
		}
	},
	
	["VIP Nebula"] = {
		galaxyOrbit = {
			planets = 5,
			stars = 20,
			rotation = true
		},
		portalEffect = {
			size = 8,
			destination = "space"
		},
		cosmicDust = {
			rate = 50
		}
	},
	
	-- SPECIAL TIER (unique effects)
	["Rainbow"] = {
		rainbowTrail = {
			animated = true,
			width = 5
		},
		colorWave = {
			speed = 2,
			intensity = 1
		},
		prismEffect = true
	},
	
	["Quantum"] = {
		phaseShift = {
			frequency = 1,
			dimensions = 3
		},
		hologram = {
			copies = 3,
			offset = 2
		},
		glitchEffect = true
	}
}

-- Active VFX storage
local activeVFX = {}

-- Create floating orbs effect
local function createFloatingOrbs(character, config)
	local orbs = {}
	local connections = {}
	
	for i = 1, config.count do
		local orb = Instance.new("Part")
		orb.Name = "EnergyOrb"
		orb.Size = Vector3.new(1, 1, 1)
		orb.Shape = Enum.PartType.Ball
		orb.Material = Enum.Material.Neon
		orb.Color = config.color
		orb.CanCollide = false
		orb.Anchored = true
		orb.Parent = workspace
		
		local light = Instance.new("PointLight")
		light.Color = config.color
		light.Brightness = 2
		light.Range = 5
		light.Parent = orb
		
		table.insert(orbs, orb)
	end
	
	-- Orbit animation
	local connection = RunService.Heartbeat:Connect(function()
		local head = character:FindFirstChild("Head")
		if not head then return end
		
		local time = tick() * config.speed
		for i, orb in ipairs(orbs) do
			local angle = (i - 1) * (math.pi * 2 / config.count) + time
			local x = math.cos(angle) * config.radius
			local z = math.sin(angle) * config.radius
			local y = math.sin(time + i) * 2
			
			orb.Position = head.Position + Vector3.new(x, y, z)
		end
	end)
	
	table.insert(connections, connection)
	return orbs, connections
end

-- Create aura effect
local function createAura(character, config)
	local head = character:FindFirstChild("Head")
	if not head then return end
	
	local aura = Instance.new("SelectionBox")
	aura.Name = "Aura"
	aura.Adornee = head
	aura.Color3 = config.color
	aura.LineThickness = 0.1
	aura.Transparency = 0.5
	aura.Parent = head
	
	if config.size then
		-- Scale the aura with tweening
		TweenService:Create(aura, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
			LineThickness = 0.1 * config.size
		}):Play()
	end
	
	return aura
end

-- Create lightning effect
local function createLightningEffect(character, config)
	local connections = {}
	
	local connection = RunService.Heartbeat:Connect(function()
		if math.random() < config.frequency then
			local head = character:FindFirstChild("Head")
			if not head then return end
			
			-- Create lightning bolt
			local bolt = Instance.new("Part")
			bolt.Name = "LightningBolt"
			bolt.Size = Vector3.new(0.5, config.range, 0.5)
			bolt.Material = Enum.Material.Neon
			bolt.Color = config.color
			bolt.CanCollide = false
			bolt.Anchored = true
			bolt.Position = head.Position + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
			bolt.Parent = workspace
			
			-- Quick flash
			TweenService:Create(bolt, TweenInfo.new(0.1), {
				Transparency = 1,
				Size = Vector3.new(2, config.range, 2)
			}):Play()
			
			Debris:AddItem(bolt, 0.2)
		end
	end)
	
	table.insert(connections, connection)
	return connections
end

-- Main function to apply VFX to a snake
function SnakeVFXHandler.ApplyVFX(character, skinName)
	-- Clean up existing VFX
	SnakeVFXHandler.RemoveVFX(character)
	
	local config = VFX_CONFIG[skinName]
	if not config then return end
	
	local vfx = {
		parts = {},
		connections = {},
		effects = {}
	}
	
	-- Apply different effects based on config
	if config.trail then
		-- Trail effect handled by character movement
	end
	
	if config.particles then
		local head = character:FindFirstChild("Head")
		if head then
			local emitter = Instance.new("ParticleEmitter")
			emitter.Texture = config.particles.texture
			emitter.Color = config.particles.color
			emitter.Rate = config.particles.rate
			emitter.Lifetime = config.particles.lifetime
			emitter.Speed = config.particles.speed
			emitter.EmissionDirection = config.particles.emissionDirection
			emitter.Parent = head
			table.insert(vfx.effects, emitter)
		end
	end
	
	if config.sparkles then
		local head = character:FindFirstChild("Head")
		if head then
			local sparkle = Instance.new("Sparkles")
			sparkle.SparkleColor = config.sparkles.color
			sparkle.Enabled = true
			sparkle.Parent = head
			table.insert(vfx.effects, sparkle)
		end
	end
	
	if config.aura then
		local aura = createAura(character, config.aura)
		if aura then
			table.insert(vfx.effects, aura)
		end
	end
	
	if config.energyOrbs then
		local orbs, connections = createFloatingOrbs(character, config.energyOrbs)
		vfx.parts = orbs
		for _, conn in ipairs(connections) do
			table.insert(vfx.connections, conn)
		end
	end
	
	if config.lightningBolts then
		local connections = createLightningEffect(character, config.lightningBolts)
		for _, conn in ipairs(connections) do
			table.insert(vfx.connections, conn)
		end
	end
	
	-- Store VFX for cleanup
	activeVFX[character] = vfx
end

-- Remove VFX from a snake
function SnakeVFXHandler.RemoveVFX(character)
	local vfx = activeVFX[character]
	if not vfx then return end
	
	-- Clean up parts
	for _, part in ipairs(vfx.parts) do
		part:Destroy()
	end
	
	-- Disconnect connections
	for _, connection in ipairs(vfx.connections) do
		connection:Disconnect()
	end
	
	-- Remove effects
	for _, effect in ipairs(vfx.effects) do
		effect:Destroy()
	end
	
	activeVFX[character] = nil
end

-- Update VFX (for animations)
function SnakeVFXHandler.UpdateVFX(character)
	-- Update any animated VFX here
end

return SnakeVFXHandler