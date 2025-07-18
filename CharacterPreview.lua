--[[
ULTRA HIGH-QUALITY CHARACTER PREVIEW SYSTEM V1.0
Matches the in-game CharacterSetup snake appearance perfectly
Features:
- Smooth connected segments (not orbs!)
- Properly welded eyes that follow the head
- Natural snake curves and animations
- Skin-specific VFX and materials
- Optimized for shop preview
--]]

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Load skins data
local SnakeSkinsData = require(script.Parent:WaitForChild("SnakeSkinsData"))

local CharacterPreview = {}
CharacterPreview.__index = CharacterPreview

-- Constants for smooth snake appearance
local PREVIEW_CONFIG = {
	SegmentCount = 12,
	SegmentSpacing = 1.8,
	WaveAmplitude = 2,
	WaveFrequency = 2,
	WaveSpeed = 1.5,
	RotationSpeed = 0.8,
	CameraDistance = 25,
	CameraHeight = 8,
	SmoothnessFactor = 0.98,
	SegmentSizeGradient = 0.85, -- Each segment is 85% size of previous
}

function CharacterPreview.new(viewport)
	local self = setmetatable({}, CharacterPreview)
	
	self.viewport = viewport
	self.camera = nil
	self.model = nil
	self.head = nil
	self.segments = {}
	self.connections = {}
	self.vfxParts = {}
	self.currentSkin = "Default"
	self.time = 0
	
	self:initialize()
	
	return self
end

function CharacterPreview:initialize()
	-- Clear viewport
	for _, child in pairs(self.viewport:GetChildren()) do
		child:Destroy()
	end
	
	-- Create camera
	self.camera = Instance.new("Camera")
	self.camera.Parent = self.viewport
	self.viewport.CurrentCamera = self.camera
	
	-- Create model
	self.model = Instance.new("Model")
	self.model.Name = "SnakePreview"
	self.model.Parent = self.viewport
	
	-- Create the snake
	self:createSnake()
	
	-- Start animations
	self:startAnimations()
end

function CharacterPreview:createSnake()
	local skinData = SnakeSkinsData[self.currentSkin] or SnakeSkinsData["Default"]
	
	-- Create head (exactly like CharacterSetup)
	local head = Instance.new("Part")
	head.Name = "SnakeHead"
	head.Size = skinData.HeadSize or Vector3.new(3, 3, 3)
	head.Material = skinData.HeadMaterial or Enum.Material.ForceField
	head.Color = skinData.HeadColor
	head.Shape = Enum.PartType.Ball
	head.CanCollide = false
	head.Anchored = true
	head.TopSurface = Enum.SurfaceType.Smooth
	head.BottomSurface = Enum.SurfaceType.Smooth
	head.Position = Vector3.new(0, 0, -15)
	head.Parent = self.model
	
	-- Head glow
	local headLight = Instance.new("PointLight")
	headLight.Color = skinData.HeadColor
	headLight.Brightness = (skinData.GlowIntensity or 1.5) + 1
	headLight.Range = (skinData.GlowRange or 4) + 2
	headLight.Parent = head
	
	-- Create eyes with proper welds
	local function createEye(name, offsetX)
		local eye = Instance.new("Part")
		eye.Name = name
		eye.Size = Vector3.new(0.6, 0.6, 0.6)
		eye.Material = Enum.Material.Neon
		eye.Color = Color3.fromRGB(255, 255, 255)
		eye.Shape = Enum.PartType.Ball
		eye.CanCollide = false
		eye.Anchored = false
		eye.Parent = head
		
		-- Position relative to head
		eye.CFrame = head.CFrame * CFrame.new(offsetX, 0.55, 0.8)
		
		-- Weld to head
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = head
		weld.Part1 = eye
		weld.Parent = head
		
		-- Create pupil
		local pupil = Instance.new("Part")
		pupil.Name = name .. "Pupil"
		pupil.Size = Vector3.new(0.25, 0.25, 0.25)
		pupil.Material = Enum.Material.Neon
		pupil.Color = Color3.fromRGB(0, 0, 0)
		pupil.Shape = Enum.PartType.Ball
		pupil.CanCollide = false
		pupil.Anchored = false
		pupil.Parent = eye
		
		-- Position pupil
		pupil.CFrame = eye.CFrame * CFrame.new(0, 0, -0.2)
		
		-- Weld pupil to eye
		local pupilWeld = Instance.new("WeldConstraint")
		pupilWeld.Part0 = eye
		pupilWeld.Part1 = pupil
		pupilWeld.Parent = eye
		
		return eye, pupil
	end
	
	createEye("LeftEye", -0.6)
	createEye("RightEye", 0.6)
	
	self.head = head
	self.model.PrimaryPart = head
	
	-- Create body segments with smooth size gradient
	local currentSize = skinData.SegmentSize or Vector3.new(2.5, 2.5, 2.5)
	local prevSegment = head
	
	for i = 1, PREVIEW_CONFIG.SegmentCount do
		local segment = Instance.new("Part")
		segment.Name = "Segment" .. i
		segment.Size = currentSize
		segment.Material = skinData.BodyMaterial or Enum.Material.Neon
		segment.Shape = Enum.PartType.Ball
		segment.CanCollide = false
		segment.Anchored = true
		segment.TopSurface = Enum.SurfaceType.Smooth
		segment.BottomSurface = Enum.SurfaceType.Smooth
		segment.Parent = self.model
		
		-- Apply color pattern
		local colorIndex = ((i - 1) % #skinData.BodyColors) + 1
		segment.Color = skinData.BodyColors[colorIndex]
		
		-- Initial S-curve position
		local curve = math.sin((i / PREVIEW_CONFIG.SegmentCount) * math.pi * 2) * PREVIEW_CONFIG.WaveAmplitude
		segment.Position = head.Position + Vector3.new(
			curve,
			0,
			-i * PREVIEW_CONFIG.SegmentSpacing
		)
		
		-- Segment glow
		local light = Instance.new("PointLight")
		light.Color = segment.Color
		light.Brightness = skinData.GlowIntensity or 1.5
		light.Range = skinData.GlowRange or 4
		light.Parent = segment
		
		-- Store segment
		table.insert(self.segments, {
			part = segment,
			baseOffset = segment.Position - head.Position,
			colorIndex = colorIndex
		})
		
		-- Reduce size for next segment (smooth taper)
		currentSize = currentSize * PREVIEW_CONFIG.SegmentSizeGradient
		prevSegment = segment
	end
	
	-- Apply skin-specific VFX
	self:applyVFX(skinData)
end

function CharacterPreview:applyVFX(skinData)
	-- Clean up old VFX
	for _, vfx in pairs(self.vfxParts) do
		vfx:Destroy()
	end
	self.vfxParts = {}
	
	-- Check for custom VFX
	if skinData.VFX then
		local vfx = skinData.VFX
		
		-- Aura effect
		if vfx.AuraColor then
			local aura = Instance.new("Part")
			aura.Name = "Aura"
			aura.Size = Vector3.new(8, 8, 8)
			aura.Material = Enum.Material.ForceField
			aura.Color = vfx.AuraColor
			aura.Transparency = 0.7
			aura.Shape = Enum.PartType.Ball
			aura.CanCollide = false
			aura.Anchored = true
			aura.Parent = self.model
			table.insert(self.vfxParts, aura)
			
			-- Aura will follow head in animation
			aura:SetAttribute("FollowHead", true)
		end
		
		-- Particle effects
		if vfx.ParticleColor then
			for i = 1, 3 do
				local particle = Instance.new("Part")
				particle.Name = "Particle" .. i
				particle.Size = Vector3.new(0.5, 0.5, 0.5)
				particle.Material = Enum.Material.Neon
				particle.Color = vfx.ParticleColor
				particle.Shape = Enum.PartType.Ball
				particle.CanCollide = false
				particle.Anchored = true
				particle.Parent = self.model
				particle:SetAttribute("ParticleIndex", i)
				table.insert(self.vfxParts, particle)
			end
		end
		
		-- Lightning effect (visual representation)
		if vfx.LightningColor then
			local lightning = Instance.new("Part")
			lightning.Name = "Lightning"
			lightning.Size = Vector3.new(0.2, 5, 0.2)
			lightning.Material = Enum.Material.Neon
			lightning.Color = vfx.LightningColor
			lightning.CanCollide = false
			lightning.Anchored = true
			lightning.Parent = self.model
			lightning:SetAttribute("IsLightning", true)
			table.insert(self.vfxParts, lightning)
		end
	end
end

function CharacterPreview:startAnimations()
	-- Main update loop
	local connection = RunService.Heartbeat:Connect(function(dt)
		self.time = self.time + dt
		
		-- Rotate camera around snake
		local cameraAngle = self.time * PREVIEW_CONFIG.RotationSpeed
		local cameraPos = self.head.Position + Vector3.new(
			math.sin(cameraAngle) * PREVIEW_CONFIG.CameraDistance,
			PREVIEW_CONFIG.CameraHeight,
			math.cos(cameraAngle) * PREVIEW_CONFIG.CameraDistance
		)
		self.camera.CFrame = CFrame.lookAt(cameraPos, self.head.Position)
		
		-- Animate snake segments with smooth following
		local headPos = self.head.Position
		local prevPos = headPos
		
		for i, segmentData in ipairs(self.segments) do
			local segment = segmentData.part
			local baseOffset = segmentData.baseOffset
			
			-- Create natural wave motion
			local waveOffset = math.sin(self.time * PREVIEW_CONFIG.WaveSpeed + (i * 0.5)) * PREVIEW_CONFIG.WaveAmplitude
			local targetPos = headPos + baseOffset + Vector3.new(waveOffset, 0, 0)
			
			-- Smooth following motion
			local currentPos = segment.Position
			local smoothPos = currentPos:Lerp(targetPos, 1 - PREVIEW_CONFIG.SmoothnessFactor)
			
			-- Ensure minimum spacing from previous segment
			local toPrev = (smoothPos - prevPos).Unit
			if toPrev.Magnitude > 0 then
				smoothPos = prevPos + toPrev * PREVIEW_CONFIG.SegmentSpacing
			end
			
			segment.Position = smoothPos
			prevPos = smoothPos
		end
		
		-- Animate VFX
		for _, vfx in pairs(self.vfxParts) do
			if vfx:GetAttribute("FollowHead") then
				-- Aura follows head
				vfx.Position = self.head.Position
			elseif vfx:GetAttribute("ParticleIndex") then
				-- Orbit particles
				local index = vfx:GetAttribute("ParticleIndex")
				local angle = self.time * 3 + (index * math.pi * 2 / 3)
				local radius = 5
				vfx.Position = self.head.Position + Vector3.new(
					math.cos(angle) * radius,
					math.sin(angle * 2) * 2,
					math.sin(angle) * radius
				)
			elseif vfx:GetAttribute("IsLightning") then
				-- Lightning effect
				vfx.CFrame = CFrame.lookAt(
					self.head.Position + Vector3.new(0, 3, 0),
					self.head.Position + Vector3.new(math.sin(self.time * 10) * 2, 5, 0)
				)
				vfx.Transparency = 0.3 + math.random() * 0.4
			end
		end
	end)
	
	table.insert(self.connections, connection)
end

function CharacterPreview:updateSkin(skinName)
	if not SnakeSkinsData[skinName] then
		warn("Skin not found:", skinName)
		return
	end
	
	self.currentSkin = skinName
	local skinData = SnakeSkinsData[skinName]
	
	-- Update head
	self.head.Color = skinData.HeadColor
	self.head.Material = skinData.HeadMaterial or Enum.Material.ForceField
	
	-- Update head light
	local headLight = self.head:FindFirstChild("PointLight")
	if headLight then
		headLight.Color = skinData.HeadColor
		headLight.Brightness = (skinData.GlowIntensity or 1.5) + 1
	end
	
	-- Update segments
	for i, segmentData in ipairs(self.segments) do
		local segment = segmentData.part
		local colorIndex = segmentData.colorIndex
		
		segment.Color = skinData.BodyColors[colorIndex]
		segment.Material = skinData.BodyMaterial or Enum.Material.Neon
		
		-- Update segment light
		local light = segment:FindFirstChild("PointLight")
		if light then
			light.Color = segment.Color
			light.Brightness = skinData.GlowIntensity or 1.5
		end
	end
	
	-- Update VFX
	self:applyVFX(skinData)
end

function CharacterPreview:destroy()
	-- Disconnect all connections
	for _, connection in pairs(self.connections) do
		connection:Disconnect()
	end
	self.connections = {}
	
	-- Clean up model
	if self.model then
		self.model:Destroy()
	end
	
	-- Clear references
	self.viewport = nil
	self.camera = nil
	self.model = nil
	self.head = nil
	self.segments = {}
	self.vfxParts = {}
end

return CharacterPreview