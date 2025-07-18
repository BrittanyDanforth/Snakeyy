-- CharacterPreview Module
-- Handles snake preview rendering with VFX support

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local CharacterPreview = {}
CharacterPreview.__index = CharacterPreview

-- Configuration
local CONFIG = {
	SEGMENT_COUNT = 30,
	SEGMENT_SPACING = 15.5,
	HEAD_SIZE = Vector3.new(3, 3, 3),
	SEGMENT_SIZE = Vector3.new(2.5, 2.5, 2.5),
	SIZE_REDUCTION = 0.98,
	CAMERA_DISTANCE = 45,
	CAMERA_HEIGHT = 20,
	CAMERA_FOV = 70,
	ROTATION_SPEED = 0.5,
	SLITHER_SPEED = 0.8,
	SNAKE_RADIUS = 10,
	SNAKE_CENTER_Z = -10,
	DELAY_MULTIPLIER = 3.5
}

function CharacterPreview.new(viewport, skinData)
	local self = setmetatable({}, CharacterPreview)
	
	self.viewport = viewport
	self.skinData = skinData or {}
	self.model = nil
	self.head = nil
	self.segments = {}
	self.camera = nil
	self.worldModel = nil
	self.connections = {}
	self.vfxEffects = {}
	self.positionHistory = {}
	self.historyTimer = 0
	self.time = 0
	
	self:initialize()
	
	return self
end

function CharacterPreview:initialize()
	-- Clear viewport
	self.viewport:ClearAllChildren()
	
	-- Create WorldModel for proper rendering
	self.worldModel = Instance.new("WorldModel")
	self.worldModel.Parent = self.viewport
	
	-- Set viewport properties
	self.viewport.Ambient = Color3.new(0.3, 0.3, 0.3)
	self.viewport.LightColor = Color3.new(1, 1, 1)
	self.viewport.LightDirection = Vector3.new(-1, -1, -1).Unit
	
	-- Create camera
	self.camera = Instance.new("Camera")
	self.camera.FieldOfView = CONFIG.CAMERA_FOV
	self.camera.CameraType = Enum.CameraType.Scriptable
	self.viewport.CurrentCamera = self.camera
	self.camera.Parent = self.viewport
	
	-- Create model
	self.model = Instance.new("Model")
	self.model.Name = "SnakePreview"
	self.model.Parent = self.worldModel
	
	-- Create snake
	self:createSnake()
	
	-- Start animation
	self:startAnimation()
end

function CharacterPreview:createSnake()
	local skin = self.skinData["Default"] or {
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
		GlowRange = 6,
	}
	
	-- Create head
	self.head = Instance.new("Part")
	self.head.Name = "Head"
	self.head.Size = skin.HeadSize or CONFIG.HEAD_SIZE
	self.head.Shape = Enum.PartType.Ball
	self.head.Material = skin.HeadMaterial
	self.head.Color = skin.HeadColor
	self.head.CanCollide = false
	self.head.Anchored = true
	self.head.Position = Vector3.new(0, 0, CONFIG.SNAKE_CENTER_Z)
	self.head.Parent = self.model
	
	-- Head glow
	local headGlow = Instance.new("PointLight")
	headGlow.Brightness = skin.GlowIntensity * 1.5
	headGlow.Range = skin.GlowRange * 1.5
	headGlow.Color = skin.HeadColor
	headGlow.Parent = self.head
	
	-- Create eyes
	self:createEyes()
	
	-- Create segments
	local currentSize = CONFIG.SEGMENT_SIZE
	for i = 1, CONFIG.SEGMENT_COUNT do
		local segment = Instance.new("Part")
		segment.Name = "Segment" .. i
		segment.Size = currentSize
		segment.Shape = Enum.PartType.Ball
		segment.Material = skin.BodyMaterial
		segment.CanCollide = false
		segment.Anchored = true
		segment.Parent = self.model
		
		-- Initial position
		segment.Position = self.head.Position + Vector3.new(0, 0, -i * CONFIG.SEGMENT_SPACING * 3)
		
		-- Color pattern
		local colorIndex = ((i - 1) % #skin.BodyColors) + 1
		segment.Color = skin.BodyColors[colorIndex]
		
		-- Segment glow
		local glow = Instance.new("PointLight")
		glow.Brightness = skin.GlowIntensity
		glow.Range = skin.GlowRange
		glow.Color = segment.Color
		glow.Parent = segment
		
		table.insert(self.segments, {
			part = segment,
			colorIndex = colorIndex,
			size = currentSize
		})
		
		currentSize = currentSize * CONFIG.SIZE_REDUCTION
	end
end

function CharacterPreview:createEyes()
	local function createEye(xOffset)
		local eye = Instance.new("Part")
		eye.Size = Vector3.new(0.6, 0.6, 0.6)
		eye.Shape = Enum.PartType.Ball
		eye.Material = Enum.Material.Neon
		eye.Color = Color3.fromRGB(255, 255, 255)
		eye.CanCollide = false
		eye.Anchored = true
		eye.Parent = self.model
		
		local eyeGlow = Instance.new("PointLight")
		eyeGlow.Brightness = 8
		eyeGlow.Range = 40
		eyeGlow.Color = Color3.fromRGB(255, 255, 255)
		eyeGlow.Parent = eye
		
		local pupil = Instance.new("Part")
		pupil.Size = Vector3.new(0.3, 0.3, 0.3)
		pupil.Shape = Enum.PartType.Ball
		pupil.Material = Enum.Material.Neon
		pupil.Color = Color3.fromRGB(0, 0, 0)
		pupil.CanCollide = false
		pupil.Anchored = true
		pupil.Parent = self.model
		
		return eye, pupil
	end
	
	self.leftEye, self.leftPupil = createEye(-0.6)
	self.rightEye, self.rightPupil = createEye(0.6)
end

function CharacterPreview:startAnimation()
	local connection = RunService.Heartbeat:Connect(function(dt)
		self.time = self.time + dt
		
		-- Camera rotation
		local camAngle = self.time * CONFIG.ROTATION_SPEED
		local focusPoint = Vector3.new(0, 0, CONFIG.SNAKE_CENTER_Z)
		
		self.camera.CFrame = CFrame.lookAt(
			focusPoint + Vector3.new(
				math.sin(camAngle) * CONFIG.CAMERA_DISTANCE,
				CONFIG.CAMERA_HEIGHT,
				math.cos(camAngle) * CONFIG.CAMERA_DISTANCE
			),
			focusPoint
		)
		
		-- Snake movement (infinity pattern)
		local moveTime = self.time * CONFIG.SLITHER_SPEED
		local t = moveTime * 2
		local scale = CONFIG.SNAKE_RADIUS
		
		local headX = scale * math.sin(t) / (1 + math.cos(t)^2)
		local headZ = scale * math.sin(t) * math.cos(t) / (1 + math.cos(t)^2)
		local waveOffset = math.sin(moveTime * 3) * 3
		headX = headX + waveOffset
		local headY = math.sin(moveTime * 2) * 1
		
		local finalPos = Vector3.new(headX, headY, headZ)
		
		-- Look direction
		local futureT = (moveTime + 0.1) * 2
		local futureX = scale * math.sin(futureT) / (1 + math.cos(futureT)^2) + math.sin((moveTime + 0.1) * 3) * 3
		local futureZ = scale * math.sin(futureT) * math.cos(futureT) / (1 + math.cos(futureT)^2)
		local futureY = math.sin((moveTime + 0.1) * 2) * 1
		
		self.head.CFrame = CFrame.lookAt(finalPos, Vector3.new(futureX, futureY, futureZ))
		
		-- Position eyes
		local eyeHeight = 0.6
		local eyeForward = -1.4
		local eyeSeparation = 0.55
		
		self.leftEye.CFrame = self.head.CFrame * CFrame.new(-eyeSeparation, eyeHeight, eyeForward)
		self.rightEye.CFrame = self.head.CFrame * CFrame.new(eyeSeparation, eyeHeight, eyeForward)
		self.leftPupil.CFrame = self.leftEye.CFrame * CFrame.new(0, 0, -0.25)
		self.rightPupil.CFrame = self.rightEye.CFrame * CFrame.new(0, 0, -0.25)
		
		-- Update position history
		self.historyTimer = self.historyTimer + dt
		if self.historyTimer >= 1/60 then
			self.historyTimer = self.historyTimer - 1/60
			table.insert(self.positionHistory, 1, self.head.Position)
			
			local maxHistory = CONFIG.SEGMENT_COUNT * 10
			if #self.positionHistory > maxHistory then
				table.remove(self.positionHistory)
			end
		end
		
		-- Animate segments
		for i, seg in ipairs(self.segments) do
			local delay = i * CONFIG.DELAY_MULTIPLIER
			local historyIndex = math.floor(delay)
			historyIndex = math.clamp(historyIndex, 1, #self.positionHistory)
			
			if self.positionHistory[historyIndex] then
				local targetPos = self.positionHistory[historyIndex]
				local currentPos = seg.part.Position
				local frameIndependentLerp = 1 - math.exp(-8 * dt)
				local newPos = currentPos:Lerp(targetPos, frameIndependentLerp)
				seg.part.Position = newPos
				
				if i > 1 then
					local prevSeg = self.segments[i-1].part
					local direction = (prevSeg.Position - newPos).Unit
					if direction.Magnitude > 0 then
						seg.part.CFrame = CFrame.lookAt(newPos, prevSeg.Position)
					end
				end
			end
		end
	end)
	
	table.insert(self.connections, connection)
end

function CharacterPreview:updateSkin(skinName)
	local skin = self.skinData[skinName] or self.skinData["Default"]
	if not skin then return end
	
	-- Update head
	if self.head then
		self.head.Color = skin.HeadColor
		self.head.Material = skin.HeadMaterial or Enum.Material.ForceField
		
		local light = self.head:FindFirstChild("PointLight")
		if light then
			light.Color = skin.HeadColor
			light.Brightness = (skin.GlowIntensity or 2) * 1.5
		end
	end
	
	-- Update segments
	for i, seg in ipairs(self.segments) do
		local colorIndex = seg.colorIndex
		if skin.BodyColors and skin.BodyColors[colorIndex] then
			seg.part.Color = skin.BodyColors[colorIndex]
			seg.part.Material = skin.BodyMaterial or Enum.Material.Neon
			
			local light = seg.part:FindFirstChild("PointLight")
			if light then
				light.Color = seg.part.Color
				light.Brightness = skin.GlowIntensity or 2
			end
		end
	end
	
	-- Clear existing VFX
	self:clearVFX()
	
	-- Apply new VFX if available
	self:applyVFX(skinName)
end

function CharacterPreview:applyVFX(skinName)
	-- This is where VFX would be applied
	-- For now, keeping it simple and clean
	-- VFX can be added later as needed
end

function CharacterPreview:clearVFX()
	for _, effect in ipairs(self.vfxEffects) do
		if effect then
			effect:Destroy()
		end
	end
	self.vfxEffects = {}
end

function CharacterPreview:destroy()
	self:clearVFX()
	
	for _, connection in ipairs(self.connections) do
		connection:Disconnect()
	end
	
	if self.model then
		self.model:Destroy()
	end
	
	if self.worldModel then
		self.worldModel:Destroy()
	end
end

return CharacterPreview