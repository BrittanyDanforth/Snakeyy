--[[
ULTRA HIGH-QUALITY CHARACTER PREVIEW SYSTEM V2.0 - MASSIVE SIZE FIX
Completely overhauled for visibility in published games
Features:
- HUGE snake with many segments for better visibility
- WorldModel rendering for proper display in real game
- Optimized segment following with position history
- Perfect eye positioning that stays with head
- Zero lag with efficient calculations
--]]

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterPreview = {}
CharacterPreview.__index = CharacterPreview

-- Get skins data from parent module
local SnakeSkinsData = nil

function CharacterPreview.setSkinData(skinData)
	SnakeSkinsData = skinData
end

-- MASSIVELY INCREASED SIZES FOR REAL GAME VISIBILITY
local PREVIEW_CONFIG = {
	SEGMENT_COUNT = 30,           -- Way more segments for bigger snake
	SEGMENT_SPACING = 2.5,        -- Much bigger spacing
	HEAD_SIZE = Vector3.new(6, 6, 6),         -- Double the head size
	SEGMENT_SIZE = Vector3.new(5.5, 5.5, 5.5), -- Much bigger segments
	SIZE_REDUCTION = 0.98,        -- Gradual size reduction
	CAMERA_DISTANCE = 50,         -- Camera pulled way back
	CAMERA_HEIGHT = 15,           -- Higher camera
	CAMERA_FOV = 70,             -- Wide FOV
	ORBIT_SPEED = 0.5,           -- Slower orbit
	MOVEMENT_RADIUS = 15,        -- Larger movement area
	MOVEMENT_SPEED = 1,          -- Movement speed
	POSITION_HISTORY_SIZE = 35,  -- More history for smoother following
	EYE_SIZE = Vector3.new(1.2, 1.2, 1.2),    -- Bigger eyes
	EYE_SPACING = 0.7,           -- Eye horizontal spacing
	EYE_FORWARD = -1.8,          -- Eye forward offset
	EYE_UP = 0.7,                -- Eye vertical offset
}

function CharacterPreview.new(viewport)
	local self = setmetatable({}, CharacterPreview)
	
	self.viewport = viewport
	self.camera = nil
	self.worldModel = nil
	self.model = nil
	self.head = nil
	self.segments = {}
	self.eyes = {}
	self.connections = {}
	self.vfxParts = {}
	self.currentSkin = "Default"
	self.time = 0
	self.positionHistory = {}
	
	self:initialize()
	
	return self
end

function CharacterPreview:initialize()
	-- Clear viewport
	for _, child in pairs(self.viewport:GetChildren()) do
		if child:IsA("WorldModel") or child:IsA("Camera") then
			child:Destroy()
		end
	end
	
	-- Create WorldModel for proper rendering in published game
	self.worldModel = Instance.new("WorldModel")
	self.worldModel.Parent = self.viewport
	
	-- Set viewport properties for best rendering
	self.viewport.Ambient = Color3.new(0.7, 0.7, 0.7)
	self.viewport.LightColor = Color3.new(1, 1, 1)
	self.viewport.LightDirection = Vector3.new(-1, -1, -1)
	
	-- Create camera with proper FOV
	self.camera = Instance.new("Camera")
	self.camera.FieldOfView = PREVIEW_CONFIG.CAMERA_FOV
	self.camera.Parent = self.viewport
	self.viewport.CurrentCamera = self.camera
	
	-- Create model inside WorldModel
	self.model = Instance.new("Model")
	self.model.Name = "SnakePreview"
	self.model.Parent = self.worldModel
	
	-- Create the snake
	self:createSnake()
	
	-- Start animations
	self:startAnimations()
end

function CharacterPreview:createSnake()
	-- Default skin data
	local defaultSkin = {
		HeadColor = Color3.fromRGB(76, 217, 100),
		BodyColors = {
			Color3.fromRGB(60, 180, 80),
			Color3.fromRGB(80, 200, 100),
			Color3.fromRGB(100, 220, 120),
			Color3.fromRGB(80, 200, 100),
			Color3.fromRGB(60, 180, 80),
		},
		HeadSize = PREVIEW_CONFIG.HEAD_SIZE,
		SegmentSize = PREVIEW_CONFIG.SEGMENT_SIZE,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 2,
		GlowRange = 8,
	}
	
	local skinData = (SnakeSkinsData and SnakeSkinsData[self.currentSkin]) or defaultSkin
	
	-- Create massive head
	local head = Instance.new("Part")
	head.Name = "SnakeHead"
	head.Size = skinData.HeadSize or PREVIEW_CONFIG.HEAD_SIZE
	head.Material = skinData.HeadMaterial or Enum.Material.ForceField
	head.Color = skinData.HeadColor
	head.Shape = Enum.PartType.Ball
	head.CanCollide = false
	head.Anchored = true
	head.TopSurface = Enum.SurfaceType.Smooth
	head.BottomSurface = Enum.SurfaceType.Smooth
	head.Position = Vector3.new(0, 5, 0)
	head.Parent = self.model
	
	-- Enhanced head glow for visibility
	local headLight = Instance.new("PointLight")
	headLight.Color = skinData.HeadColor
	headLight.Brightness = (skinData.GlowIntensity or 2) * 2
	headLight.Range = (skinData.GlowRange or 8) * 2
	headLight.Parent = head
	
	-- Create bigger eyes
	local function createEye(name, offsetX)
		local eye = Instance.new("Part")
		eye.Name = name
		eye.Size = PREVIEW_CONFIG.EYE_SIZE
		eye.Material = Enum.Material.Neon
		eye.Color = Color3.fromRGB(255, 255, 255)
		eye.Shape = Enum.PartType.Ball
		eye.CanCollide = false
		eye.Anchored = true
		eye.Parent = self.model
		
		-- Create pupil
		local pupil = Instance.new("Part")
		pupil.Name = name .. "Pupil"
		pupil.Size = PREVIEW_CONFIG.EYE_SIZE * 0.4
		pupil.Material = Enum.Material.Neon
		pupil.Color = Color3.fromRGB(0, 0, 0)
		pupil.Shape = Enum.PartType.Ball
		pupil.CanCollide = false
		pupil.Anchored = true
		pupil.Parent = self.model
		
		table.insert(self.eyes, {eye = eye, pupil = pupil, offsetX = offsetX})
		return eye, pupil
	end
	
	createEye("LeftEye", -PREVIEW_CONFIG.EYE_SPACING)
	createEye("RightEye", PREVIEW_CONFIG.EYE_SPACING)
	
	self.head = head
	self.model.PrimaryPart = head
	
	-- Initialize position history with starting positions
	local startPos = head.Position
	for i = 1, PREVIEW_CONFIG.POSITION_HISTORY_SIZE do
		table.insert(self.positionHistory, startPos - Vector3.new(0, 0, i * PREVIEW_CONFIG.SEGMENT_SPACING * 0.5))
	end
	
	-- Create many large body segments
	local currentSize = skinData.SegmentSize or PREVIEW_CONFIG.SEGMENT_SIZE
	
	for i = 1, PREVIEW_CONFIG.SEGMENT_COUNT do
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
		
		-- Add glow to segments for visibility
		local segmentLight = Instance.new("PointLight")
		segmentLight.Color = segment.Color
		segmentLight.Brightness = 1
		segmentLight.Range = 6
		segmentLight.Parent = segment
		
		-- Position in a line initially
		segment.Position = startPos - Vector3.new(0, 0, i * PREVIEW_CONFIG.SEGMENT_SPACING)
		
		table.insert(self.segments, segment)
		
		-- Reduce size gradually
		currentSize = currentSize * PREVIEW_CONFIG.SIZE_REDUCTION
	end
	
	-- Apply VFX if the skin has them
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
		
		-- Animate head in a large circular path
		local headAngle = self.time * PREVIEW_CONFIG.MOVEMENT_SPEED
		self.head.Position = Vector3.new(
			math.cos(headAngle) * PREVIEW_CONFIG.MOVEMENT_RADIUS,
			5 + math.sin(headAngle * 2) * 2,
			math.sin(headAngle) * PREVIEW_CONFIG.MOVEMENT_RADIUS
		)
		
		-- Update position history
		table.insert(self.positionHistory, 1, self.head.Position)
		if #self.positionHistory > PREVIEW_CONFIG.POSITION_HISTORY_SIZE then
			table.remove(self.positionHistory)
		end
		
		-- Update eyes to stay with head
		for _, eyeData in ipairs(self.eyes) do
			local eye = eyeData.eye
			local pupil = eyeData.pupil
			
			-- Position eyes relative to head facing direction
			local headLookDir = self.head.CFrame.LookVector
			if #self.positionHistory > 1 then
				local velocity = (self.head.Position - self.positionHistory[2]).Unit
				if velocity.Magnitude > 0 then
					headLookDir = velocity
				end
			end
			
			local headCFrame = CFrame.lookAt(self.head.Position, self.head.Position + headLookDir)
			eye.CFrame = headCFrame * CFrame.new(eyeData.offsetX, PREVIEW_CONFIG.EYE_UP, PREVIEW_CONFIG.EYE_FORWARD)
			pupil.CFrame = eye.CFrame * CFrame.new(0, 0, -0.3)
		end
		
		-- Animate segments using position history
		for i, segment in ipairs(self.segments) do
			local historyIndex = math.min(i + 1, #self.positionHistory)
			if self.positionHistory[historyIndex] then
				segment.Position = self.positionHistory[historyIndex]
			end
		end
		
		-- Update camera to orbit around snake center
		local cameraAngle = self.time * PREVIEW_CONFIG.ORBIT_SPEED
		local snakeCenter = self.head.Position
		local cameraPos = snakeCenter + Vector3.new(
			math.sin(cameraAngle) * PREVIEW_CONFIG.CAMERA_DISTANCE,
			PREVIEW_CONFIG.CAMERA_HEIGHT,
			math.cos(cameraAngle) * PREVIEW_CONFIG.CAMERA_DISTANCE
		)
		self.camera.CFrame = CFrame.lookAt(cameraPos, snakeCenter)
		
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
	self.currentSkin = skinName
	
	-- Get skin data or use default
	local skinData = nil
	if SnakeSkinsData and SnakeSkinsData[skinName] then
		skinData = SnakeSkinsData[skinName]
	else
		-- Use default colors if skin not found
		skinData = {
			HeadColor = Color3.fromRGB(76, 217, 100),
			BodyColors = {
				Color3.fromRGB(60, 180, 80),
				Color3.fromRGB(80, 200, 100),
				Color3.fromRGB(100, 220, 120),
				Color3.fromRGB(80, 200, 100),
				Color3.fromRGB(60, 180, 80),
			},
			HeadMaterial = Enum.Material.ForceField,
			BodyMaterial = Enum.Material.Neon,
			GlowIntensity = 2,
			GlowRange = 8,
		}
	end
	
	-- Update head
	self.head.Color = skinData.HeadColor
	self.head.Material = skinData.HeadMaterial or Enum.Material.ForceField
	
	-- Update head light
	local headLight = self.head:FindFirstChild("PointLight")
	if headLight then
		headLight.Color = skinData.HeadColor
		headLight.Brightness = (skinData.GlowIntensity or 2) * 2
	end
	
	-- Update eyes
	for _, eyeData in ipairs(self.eyes) do
		local eye = eyeData.eye
		local pupil = eyeData.pupil
		
		eye.Color = Color3.fromRGB(255, 255, 255)
		eye.Material = Enum.Material.Neon
		
		pupil.Color = Color3.fromRGB(0, 0, 0)
		pupil.Material = Enum.Material.Neon
		
		eye.CFrame = self.head.CFrame * CFrame.new(eyeData.offsetX, PREVIEW_CONFIG.EYE_UP, PREVIEW_CONFIG.EYE_FORWARD)
		pupil.CFrame = eye.CFrame * CFrame.new(0, 0, -0.2)
	end
	
	-- Update segments
	for i, segment in ipairs(self.segments) do
		local colorIndex = ((i - 1) % #skinData.BodyColors) + 1
		
		segment.Color = skinData.BodyColors[colorIndex]
		segment.Material = skinData.BodyMaterial or Enum.Material.Neon
		
		-- Update segment light
		local light = segment:FindFirstChild("PointLight")
		if light then
			light.Color = segment.Color
			light.Brightness = 1
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
	self.worldModel = nil
	self.model = nil
	self.head = nil
	self.segments = {}
	self.eyes = {}
	self.vfxParts = {}
	self.positionHistory = {}
end

return CharacterPreview