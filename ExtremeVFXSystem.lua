-- EXTREME VFX SYSTEM V7.0
-- Ultra-custom visual effects for premium skins
-- Designed for maximum visual impact

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local ExtremeVFX = {}

-- Create custom green aura effect
function ExtremeVFX.CreateGreenAura(character, intensity)
	local rootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	if not rootPart then return end
	
	-- Main aura attachment
	local attachment = Instance.new("Attachment")
	attachment.Name = "GreenAuraAttachment"
	attachment.Parent = rootPart
	
	-- Particle emitter for green energy
	local aura = Instance.new("ParticleEmitter")
	aura.Name = "GreenAura"
	aura.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	aura.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(50, 200, 50)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 0))
	}
	aura.LightEmission = 1
	aura.LightInfluence = 0
	aura.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.1, intensity),
		NumberSequenceKeypoint.new(0.5, intensity * 1.5),
		NumberSequenceKeypoint.new(1, 0)
	}
	aura.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.2, 0.3),
		NumberSequenceKeypoint.new(0.8, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	}
	aura.Lifetime = NumberRange.new(1, 2)
	aura.Rate = 50 * intensity
	aura.Speed = NumberRange.new(2, 5)
	aura.VelocityInheritance = 0.3
	aura.SpreadAngle = Vector2.new(360, 360)
	aura.Parent = attachment
	
	-- Energy rings
	for i = 1, 3 do
		local ring = Instance.new("Part")
		ring.Name = "AuraRing" .. i
		ring.Size = Vector3.new(0.2, 0.2, 0.2)
		ring.Shape = Enum.PartType.Ball
		ring.Material = Enum.Material.Neon
		ring.Color = Color3.fromRGB(0, 255, 0)
		ring.Anchored = true
		ring.CanCollide = false
		ring.CanQuery = false
		ring.CanTouch = false
		ring.Parent = character
		
		-- Animate ring
		local connection
		connection = RunService.Heartbeat:Connect(function()
			if not ring.Parent then
				connection:Disconnect()
				return
			end
			
			local time = tick()
			local radius = 3 + i * 1.5
			local angle = time * (2 + i * 0.5) + (i * math.pi * 2 / 3)
			local height = math.sin(time * 2 + i) * 0.5
			
			ring.CFrame = rootPart.CFrame * CFrame.new(
				math.cos(angle) * radius,
				height,
				math.sin(angle) * radius
			)
			
			-- Pulse effect
			local scale = 1 + math.sin(time * 5 + i) * 0.2
			ring.Size = Vector3.new(0.2, 0.2, 0.2) * scale
		end)
	end
	
	return aura
end

-- Create electric effect
function ExtremeVFX.CreateElectricEffect(character, color)
	local head = character:FindFirstChild("Head") or character.PrimaryPart
	if not head then return end
	
	-- Create lightning bolts
	local bolts = {}
	for i = 1, 5 do
		local bolt = Instance.new("Part")
		bolt.Name = "ElectricBolt" .. i
		bolt.Size = Vector3.new(0.2, 3, 0.2)
		bolt.Material = Enum.Material.Neon
		bolt.Color = color or Color3.fromRGB(255, 255, 0)
		bolt.Anchored = true
		bolt.CanCollide = false
		bolt.CanQuery = false
		bolt.CanTouch = false
		bolt.Transparency = 1
		bolt.Parent = character
		
		table.insert(bolts, bolt)
	end
	
	-- Animate bolts
	local connection
	connection = RunService.Heartbeat:Connect(function()
		if not head.Parent then
			connection:Disconnect()
			return
		end
		
		for i, bolt in ipairs(bolts) do
			-- Random chance to show bolt
			if math.random() < 0.1 then
				bolt.Transparency = 0
				
				-- Random position around head
				local angle = math.random() * math.pi * 2
				local distance = 2 + math.random() * 2
				local startPos = head.Position + Vector3.new(
					math.cos(angle) * distance,
					math.random() * 3,
					math.sin(angle) * distance
				)
				
				-- Random end position
				local endAngle = angle + (math.random() - 0.5) * math.pi
				local endDistance = 3 + math.random() * 3
				local endPos = head.Position + Vector3.new(
					math.cos(endAngle) * endDistance,
					math.random() * 3 - 5,
					math.sin(endAngle) * endDistance
				)
				
				-- Position bolt
				bolt.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -(startPos - endPos).Magnitude / 2)
				bolt.Size = Vector3.new(0.2, 0.2, (startPos - endPos).Magnitude)
				
				-- Fade out
				TweenService:Create(bolt, TweenInfo.new(0.2), {
					Transparency = 1
				}):Play()
			end
		end
	end)
	
	return bolts
end

-- Create spiral energy effect
function ExtremeVFX.CreateSpiralEnergy(character, colors)
	local rootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	if not rootPart then return end
	
	local spirals = {}
	
	for i = 1, 3 do
		local attachment = Instance.new("Attachment")
		attachment.Name = "SpiralAttachment" .. i
		attachment.Parent = rootPart
		
		-- Create beam spiral
		local attachment2 = Instance.new("Attachment")
		attachment2.Name = "SpiralEnd" .. i
		attachment2.Parent = rootPart
		
		local beam = Instance.new("Beam")
		beam.Name = "SpiralBeam" .. i
		beam.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		beam.TextureSpeed = 3
		beam.Width0 = 1
		beam.Width1 = 0.5
		beam.Color = ColorSequence.new(colors[i] or colors[1])
		beam.LightEmission = 1
		beam.LightInfluence = 0
		beam.Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(1, 0.8)
		}
		beam.Attachment0 = attachment
		beam.Attachment1 = attachment2
		beam.Parent = rootPart
		
		-- Animate spiral
		local connection
		connection = RunService.Heartbeat:Connect(function()
			if not beam.Parent then
				connection:Disconnect()
				return
			end
			
			local time = tick()
			local angle = time * 3 + (i * math.pi * 2 / 3)
			local radius = 2 + math.sin(time * 2) * 0.5
			local height = math.sin(time * 4 + i) * 3
			
			attachment.Position = Vector3.new(0, -2, 0)
			attachment2.Position = Vector3.new(
				math.cos(angle) * radius,
				height,
				math.sin(angle) * radius
			)
			
			-- Curve the beam
			beam.CurveSize0 = math.sin(time * 5) * 2
			beam.CurveSize1 = -math.sin(time * 5 + math.pi) * 2
		end)
		
		table.insert(spirals, {beam = beam, connection = connection})
	end
	
	return spirals
end

-- Create custom fire effect
function ExtremeVFX.CreateCustomFire(character, colors)
	local rootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	if not rootPart then return end
	
	local fires = {}
	
	-- Create multiple fire emitters
	for i = 1, 5 do
		local attachment = Instance.new("Attachment")
		attachment.Name = "FireAttachment" .. i
		attachment.Position = Vector3.new(
			(math.random() - 0.5) * 2,
			(math.random() - 0.5) * 2,
			(math.random() - 0.5) * 2
		)
		attachment.Parent = rootPart
		
		local fire = Instance.new("ParticleEmitter")
		fire.Name = "CustomFire" .. i
		fire.Texture = "rbxasset://textures/particles/fire_main.dds"
		fire.Color = ColorSequence.new(colors[1], colors[2] or colors[1])
		fire.LightEmission = 1
		fire.LightInfluence = 0.2
		fire.Size = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.1, 1.5),
			NumberSequenceKeypoint.new(0.9, 2),
			NumberSequenceKeypoint.new(1, 0)
		}
		fire.Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.1, 0.2),
			NumberSequenceKeypoint.new(0.9, 0.5),
			NumberSequenceKeypoint.new(1, 1)
		}
		fire.Lifetime = NumberRange.new(0.5, 1)
		fire.Rate = 30
		fire.Speed = NumberRange.new(5, 10)
		fire.SpreadAngle = Vector2.new(30, 30)
		fire.Acceleration = Vector3.new(0, 10, 0)
		fire.Parent = attachment
		
		table.insert(fires, fire)
	end
	
	return fires
end

-- Apply VFX based on skin type
function ExtremeVFX.ApplyToSnake(character, skinName, skinData)
	local vfxParts = {}
	
	-- Default effects
	local aura = ExtremeVFX.CreateGreenAura(character, 1)
	table.insert(vfxParts, aura)
	
	-- Skin-specific effects
	if skinName:match("VIP Diamond") then
		-- Diamond sparkles
		local sparkles = ExtremeVFX.CreateSpiralEnergy(character, {
			Color3.fromRGB(255, 255, 255),
			Color3.fromRGB(200, 200, 255),
			Color3.fromRGB(255, 200, 255)
		})
		for _, s in ipairs(sparkles) do
			table.insert(vfxParts, s)
		end
		
	elseif skinName:match("VIP Inferno") then
		-- Fire effects
		local fires = ExtremeVFX.CreateCustomFire(character, {
			Color3.fromRGB(255, 100, 0),
			Color3.fromRGB(255, 200, 0)
		})
		for _, f in ipairs(fires) do
			table.insert(vfxParts, f)
		end
		
	elseif skinName:match("VIP Cosmic") then
		-- Galaxy effects
		local cosmic = ExtremeVFX.CreateSpiralEnergy(character, {
			Color3.fromRGB(150, 100, 255),
			Color3.fromRGB(100, 150, 255),
			Color3.fromRGB(200, 100, 255)
		})
		for _, c in ipairs(cosmic) do
			table.insert(vfxParts, c)
		end
		
	elseif skinName:match("Electric") or skinName:match("Lightning") then
		-- Electric effects
		local bolts = ExtremeVFX.CreateElectricEffect(character, skinData.HeadColor)
		for _, b in ipairs(bolts) do
			table.insert(vfxParts, b)
		end
	end
	
	return vfxParts
end

-- Cleanup function
function ExtremeVFX.CleanupEffects(vfxParts)
	for _, part in ipairs(vfxParts or {}) do
		if typeof(part) == "Instance" then
			part:Destroy()
		elseif type(part) == "table" then
			if part.connection then
				part.connection:Disconnect()
			end
			if part.beam then
				part.beam:Destroy()
			end
		end
	end
end

return ExtremeVFX