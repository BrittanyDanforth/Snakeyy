--[[
ULTRA HIGH-QUALITY CHARACTER PREVIEW SYSTEM V3.0 - EXTREME SIZE FIX
MASSIVE OVERHAUL for maximum visibility in published games
Features:
- EXTREMELY LARGE snake that's impossible to miss
- 50 segments for massive presence
- WorldModel with enhanced rendering
- Zero lag with optimized calculations
- Perfect for real Roblox game visibility
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

-- EXTREME SIZES FOR MAXIMUM VISIBILITY
local PREVIEW_CONFIG = {
	SEGMENT_COUNT = 50,           -- MASSIVE amount of segments
	SEGMENT_SPACING = 4,          -- HUGE spacing between segments
	HEAD_SIZE = Vector3.new(12, 12, 12),      -- GIGANTIC head
	SEGMENT_SIZE = Vector3.new(10, 10, 10),   -- HUGE starting segment size
	SIZE_REDUCTION = 0.985,       -- Very gradual size reduction
	CAMERA_DISTANCE = 100,        -- Camera WAY back
	CAMERA_HEIGHT = 30,           -- Much higher camera
	CAMERA_FOV = 90,             -- Maximum FOV for wide view
	ORBIT_SPEED = 0.3,           -- Slow smooth orbit
	MOVEMENT_RADIUS = 30,        -- MASSIVE movement circle
	MOVEMENT_SPEED = 0.8,        -- Good movement speed
	POSITION_HISTORY_SIZE = 55,  -- More history than segments
	EYE_SIZE = Vector3.new(2.5, 2.5, 2.5),    -- HUGE eyes
	EYE_SPACING = 1.5,           -- Wide eye spacing
	EYE_FORWARD = -3.5,          -- Eyes forward on head
	EYE_UP = 1.5,                -- Eyes up position
	WAVE_HEIGHT = 5,             -- Vertical wave motion
	SNAKE_HEIGHT = 10,           -- Base height off ground
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
	-- Clear viewport completely
	self.viewport:ClearAllChildren()
	
	-- Create WorldModel FIRST for proper rendering
	self.worldModel = Instance.new("WorldModel")
	self.worldModel.Parent = self.viewport
	
	-- Enhanced viewport lighting
	self.viewport.Ambient = Color3.new(0.8, 0.8, 0.8)
	self.viewport.LightColor = Color3.new(1, 1, 1)
	self.viewport.LightDirection = Vector3.new(-1, -1, -1).Unit
	self.viewport.ImageColor3 = Color3.new(1, 1, 1)
	self.viewport.ImageTransparency = 0
	
	-- Create camera with maximum FOV
	self.camera = Instance.new("Camera")
	self.camera.FieldOfView = PREVIEW_CONFIG.CAMERA_FOV
	self.camera.CameraType = Enum.CameraType.Scriptable
	self.viewport.CurrentCamera = self.camera
	self.camera.Parent = self.viewport
	
	-- Create model inside WorldModel
	self.model = Instance.new("Model")
	self.model.Name = "SnakePreview"
	self.model.Parent = self.worldModel
	
	-- Create the massive snake
	self:createSnake()
	
	-- Start animations
	self:startAnimations()
end

function CharacterPreview:createSnake()
	-- Default skin with enhanced visibility
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
		GlowIntensity = 3,
		GlowRange = 15,
	}
	
	local skinData = (SnakeSkinsData and SnakeSkinsData[self.currentSkin]) or defaultSkin
	
	-- Create GIGANTIC head
	local head = Instance.new("Part")
	head.Name = "SnakeHead"
	head.Size = PREVIEW_CONFIG.HEAD_SIZE
	head.Material = skinData.HeadMaterial or Enum.Material.ForceField
	head.Color = skinData.HeadColor
	head.Shape = Enum.PartType.Ball
	head.CanCollide = false
	head.Anchored = true
	head.TopSurface = Enum.SurfaceType.Smooth
	head.BottomSurface = Enum.SurfaceType.Smooth
	head.Position = Vector3.new(0, PREVIEW_CONFIG.SNAKE_HEIGHT, 0)
	head.Parent = self.model
	
	-- SUPER bright head glow
	local headLight = Instance.new("PointLight")
	headLight.Color = skinData.HeadColor
	headLight.Brightness = 5
	headLight.Range = 30
	headLight.Parent = head
	
	-- Also add a SurfaceLight for extra visibility
	local surfaceLight = Instance.new("SurfaceLight")
	surfaceLight.Color = skinData.HeadColor
	surfaceLight.Brightness = 3
	surfaceLight.Range = 20
	surfaceLight.Face = Enum.NormalId.Front
	surfaceLight.Parent = head
	
	-- Create MASSIVE eyes
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
		
		-- Eye glow
		local eyeLight = Instance.new("PointLight")
		eyeLight.Color = Color3.fromRGB(255, 255, 255)
		eyeLight.Brightness = 2
		eyeLight.Range = 10
		eyeLight.Parent = eye
		
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
	
	-- Initialize position history with a long trail
	local startPos = head.Position
	for i = 1, PREVIEW_CONFIG.POSITION_HISTORY_SIZE do
		local offset = i * PREVIEW_CONFIG.SEGMENT_SPACING * 0.8
		table.insert(self.positionHistory, startPos - Vector3.new(offset * 0.5, 0, offset))
	end
	
	-- Create MANY MASSIVE body segments
	local currentSize = PREVIEW_CONFIG.SEGMENT_SIZE
	
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
		
		-- BRIGHT glow on every segment
		local segmentLight = Instance.new("PointLight")
		segmentLight.Color = segment.Color
		segmentLight.Brightness = 2
		segmentLight.Range = 15
		segmentLight.Parent = segment
		
		-- Initial position in a spread out line
		segment.Position = startPos - Vector3.new(
			i * PREVIEW_CONFIG.SEGMENT_SPACING * 0.5,
			0,
			i * PREVIEW_CONFIG.SEGMENT_SPACING
		)
		
		table.insert(self.segments, segment)
		
		-- Very gradual size reduction for massive snake
		currentSize = currentSize * PREVIEW_CONFIG.SIZE_REDUCTION
	end
	
	-- Apply enhanced VFX
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
		
		-- MASSIVE Aura effect
		if vfx.AuraColor then
			local aura = Instance.new("Part")
			aura.Name = "Aura"
			aura.Size = Vector3.new(20, 20, 20)
			aura.Material = Enum.Material.ForceField
			aura.Color = vfx.AuraColor
			aura.Transparency = 0.5
			aura.Shape = Enum.PartType.Ball
			aura.CanCollide = false
			aura.Anchored = true
			aura.Parent = self.model
			table.insert(self.vfxParts, aura)
			
			aura:SetAttribute("FollowHead", true)
		end
		
		-- Larger particle effects
		if vfx.ParticleColor then
			for i = 1, 5 do
				local particle = Instance.new("Part")
				particle.Name = "Particle" .. i
				particle.Size = Vector3.new(2, 2, 2)
				particle.Material = Enum.Material.Neon
				particle.Color = vfx.ParticleColor
				particle.Shape = Enum.PartType.Ball
				particle.CanCollide = false
				particle.Anchored = true
				particle.Parent = self.model
				particle:SetAttribute("ParticleIndex", i)
				
				-- Particle glow
				local pLight = Instance.new("PointLight")
				pLight.Color = vfx.ParticleColor
				pLight.Brightness = 3
				pLight.Range = 10
				pLight.Parent = particle
				
				table.insert(self.vfxParts, particle)
			end
		end
		
		-- Bigger lightning effect
		if vfx.LightningColor then
			local lightning = Instance.new("Part")
			lightning.Name = "Lightning"
			lightning.Size = Vector3.new(1, 15, 1)
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
		
		-- Animate head in a large circular path with figure-8 motion
		local headAngle = self.time * PREVIEW_CONFIG.MOVEMENT_SPEED
		local figure8 = math.sin(headAngle * 2)
		self.head.Position = Vector3.new(
			math.cos(headAngle) * PREVIEW_CONFIG.MOVEMENT_RADIUS * (1 + figure8 * 0.3),
			PREVIEW_CONFIG.SNAKE_HEIGHT + math.sin(headAngle * 2) * PREVIEW_CONFIG.WAVE_HEIGHT,
			math.sin(headAngle) * PREVIEW_CONFIG.MOVEMENT_RADIUS * (1 - figure8 * 0.3)
		)
		
		-- Update position history for smooth following
		table.insert(self.positionHistory, 1, self.head.Position)
		if #self.positionHistory > PREVIEW_CONFIG.POSITION_HISTORY_SIZE then
			table.remove(self.positionHistory)
		end
		
		-- Update eyes to stay with head and look forward
		for _, eyeData in ipairs(self.eyes) do
			local eye = eyeData.eye
			local pupil = eyeData.pupil
			
			-- Calculate head movement direction
			local headLookDir = Vector3.new(0, 0, -1) -- Default forward
			if #self.positionHistory > 2 then
				local velocity = (self.head.Position - self.positionHistory[3])
				if velocity.Magnitude > 0.1 then
					headLookDir = velocity.Unit
				end
			end
			
			-- Create proper head orientation
			local rightVector = headLookDir:Cross(Vector3.new(0, 1, 0)).Unit
			local upVector = rightVector:Cross(headLookDir).Unit
			local headCFrame = CFrame.fromMatrix(self.head.Position, rightVector, upVector, -headLookDir)
			
			-- Position eyes with proper offsets
			eye.CFrame = headCFrame * CFrame.new(eyeData.offsetX, PREVIEW_CONFIG.EYE_UP, PREVIEW_CONFIG.EYE_FORWARD)
			pupil.CFrame = eye.CFrame * CFrame.new(0, 0, -0.5)
		end
		
		-- Animate segments using position history with smooth interpolation
		for i, segment in ipairs(self.segments) do
			local historyIndex = math.floor(i * 1.1) + 1 -- Spread segments more
			if self.positionHistory[historyIndex] then
				-- Add slight wave motion to each segment
				local segmentWave = math.sin(self.time * 2 + i * 0.2) * 0.5
				local targetPos = self.positionHistory[historyIndex] + Vector3.new(0, segmentWave, 0)
				
				-- Smooth interpolation
				segment.Position = segment.Position:Lerp(targetPos, 0.3)
			end
		end
		
		-- Dynamic camera that follows the snake
		local cameraAngle = self.time * PREVIEW_CONFIG.ORBIT_SPEED
		local snakeCenter = Vector3.new(0, PREVIEW_CONFIG.SNAKE_HEIGHT, 0) -- Focus on center area
		
		-- Camera moves in an elliptical orbit
		local cameraX = math.sin(cameraAngle) * PREVIEW_CONFIG.CAMERA_DISTANCE
		local cameraZ = math.cos(cameraAngle) * PREVIEW_CONFIG.CAMERA_DISTANCE * 0.7
		local cameraY = PREVIEW_CONFIG.CAMERA_HEIGHT + math.sin(cameraAngle * 2) * 10
		
		local cameraPos = snakeCenter + Vector3.new(cameraX, cameraY, cameraZ)
		self.camera.CFrame = CFrame.lookAt(cameraPos, snakeCenter)
		
		-- Animate VFX
		for _, vfx in pairs(self.vfxParts) do
			if vfx:GetAttribute("FollowHead") then
				-- Aura follows head with pulsing effect
				vfx.Position = self.head.Position
				vfx.Size = Vector3.new(20, 20, 20) + Vector3.new(1, 1, 1) * math.sin(self.time * 3) * 5
				vfx.Transparency = 0.3 + math.sin(self.time * 2) * 0.2
			elseif vfx:GetAttribute("ParticleIndex") then
				-- Orbit particles in a larger radius
				local index = vfx:GetAttribute("ParticleIndex")
				local angle = self.time * 2 + (index * math.pi * 2 / 5)
				local radius = 15
				local height = math.sin(angle * 3) * 5
				vfx.Position = self.head.Position + Vector3.new(
					math.cos(angle) * radius,
					height,
					math.sin(angle) * radius
				)
				-- Pulsing particles
				vfx.Size = Vector3.new(2, 2, 2) + Vector3.new(1, 1, 1) * math.sin(self.time * 5 + index) * 0.5
			elseif vfx:GetAttribute("IsLightning") then
				-- Dynamic lightning effect
				local lightningOffset = math.sin(self.time * 10) * 10
				vfx.CFrame = CFrame.lookAt(
					self.head.Position + Vector3.new(lightningOffset, 10, 0),
					self.head.Position + Vector3.new(-lightningOffset, -5, 0)
				)
				vfx.Transparency = 0.2 + math.random() * 0.3
				vfx.Size = Vector3.new(1 + math.random() * 0.5, 15, 1 + math.random() * 0.5)
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
	self.head.Size = PREVIEW_CONFIG.HEAD_SIZE -- Always use massive size
	
	-- Update head light
	local headLight = self.head:FindFirstChild("PointLight")
	if headLight then
		headLight.Color = skinData.HeadColor
		headLight.Brightness = 5
		headLight.Range = 30
	end
	
	-- Update surface light
	local surfaceLight = self.head:FindFirstChild("SurfaceLight")
	if surfaceLight then
		surfaceLight.Color = skinData.HeadColor
		surfaceLight.Brightness = 3
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