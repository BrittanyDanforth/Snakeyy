-- ULTRA SMOOTH SLITHER.IO PREVIEW SYSTEM V2.0
-- Perfectly matches in-game CharacterSetup appearance
-- No more orbs - smooth connected snake body!

local RunService = game:GetService("RunService")

local CharacterPreview = {}

-- Configuration for ultra-smooth snake
local CONFIG = {
	SEGMENT_COUNT = 15,
	SEGMENT_SPACING = 1.2, -- Closer segments for smoother look
	HEAD_SIZE = Vector3.new(3, 3, 3),
	SEGMENT_SIZE = Vector3.new(2.8, 2.8, 2.8), -- Slightly smaller than head
	SIZE_REDUCTION = 0.95, -- Each segment 95% size of previous
	CAMERA_DISTANCE = 20,
	CAMERA_HEIGHT = 8,
	ROTATION_SPEED = 0.5,
	WAVE_AMPLITUDE = 1.5,
	WAVE_SPEED = 2,
	FOLLOW_SPEED = 0.85, -- High value for smooth following
}

function CharacterPreview.create(viewport, skinData)
	if not viewport then return end
	
	-- Clear viewport
	for _, child in pairs(viewport:GetChildren()) do
		child:Destroy()
	end
	
	-- Create camera
	local camera = Instance.new("Camera")
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	
	-- Create model
	local model = Instance.new("Model")
	model.Name = "SnakePreview"
	model.Parent = viewport
	
	-- Default skin if none provided
	local skin = skinData or {
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
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = CONFIG.HEAD_SIZE
	head.Shape = Enum.PartType.Ball
	head.Material = skin.HeadMaterial
	head.Color = skin.HeadColor
	head.TopSurface = Enum.SurfaceType.Smooth
	head.BottomSurface = Enum.SurfaceType.Smooth
	head.CanCollide = false
	head.Anchored = true
	head.Position = Vector3.new(0, 0, -10)
	head.Parent = model
	
	-- Head glow
	local headGlow = Instance.new("PointLight")
	headGlow.Brightness = skin.GlowIntensity * 1.5
	headGlow.Range = skin.GlowRange * 1.5
	headGlow.Color = skin.HeadColor
	headGlow.Parent = head
	
	-- Create eyes
	local function createEye(xOffset)
		local eye = Instance.new("Part")
		eye.Size = Vector3.new(0.6, 0.6, 0.6)
		eye.Shape = Enum.PartType.Ball
		eye.Material = Enum.Material.Neon
		eye.Color = Color3.fromRGB(255, 255, 255)
		eye.CanCollide = false
		eye.Anchored = true
		eye.Parent = model
		
		local pupil = Instance.new("Part")
		pupil.Size = Vector3.new(0.3, 0.3, 0.3)
		pupil.Shape = Enum.PartType.Ball
		pupil.Material = Enum.Material.Neon
		pupil.Color = Color3.fromRGB(0, 0, 0)
		pupil.CanCollide = false
		pupil.Anchored = true
		pupil.Parent = model
		
		return eye, pupil
	end
	
	local leftEye, leftPupil = createEye(-0.6)
	local rightEye, rightPupil = createEye(0.6)
	
	-- Create body segments
	local segments = {}
	local currentSize = CONFIG.SEGMENT_SIZE
	
	for i = 1, CONFIG.SEGMENT_COUNT do
		local segment = Instance.new("Part")
		segment.Name = "Segment" .. i
		segment.Size = currentSize
		segment.Shape = Enum.PartType.Ball
		segment.Material = skin.BodyMaterial
		segment.TopSurface = Enum.SurfaceType.Smooth
		segment.BottomSurface = Enum.SurfaceType.Smooth
		segment.CanCollide = false
		segment.Anchored = true
		segment.Parent = model
		
		-- Color pattern
		local colorIndex = ((i - 1) % #skin.BodyColors) + 1
		segment.Color = skin.BodyColors[colorIndex]
		
		-- Segment glow
		local glow = Instance.new("PointLight")
		glow.Brightness = skin.GlowIntensity
		glow.Range = skin.GlowRange
		glow.Color = segment.Color
		glow.Parent = segment
		
		-- Store segment data
		table.insert(segments, {
			part = segment,
			offset = Vector3.new(0, 0, -i * CONFIG.SEGMENT_SPACING),
			size = currentSize,
			colorIndex = colorIndex
		})
		
		-- Reduce size for taper effect
		currentSize = currentSize * CONFIG.SIZE_REDUCTION
	end
	
	-- Animation variables
	local time = 0
	local rotationConnection
	local segmentPositions = {}
	
	-- Initialize segment positions
	for i, seg in ipairs(segments) do
		segmentPositions[i] = head.Position + seg.offset
		seg.part.Position = segmentPositions[i]
	end
	
	-- Main animation loop
	rotationConnection = RunService.Heartbeat:Connect(function(dt)
		time = time + dt
		
		-- Camera rotation
		local camAngle = time * CONFIG.ROTATION_SPEED
		camera.CFrame = CFrame.lookAt(
			head.Position + Vector3.new(
				math.sin(camAngle) * CONFIG.CAMERA_DISTANCE,
				CONFIG.CAMERA_HEIGHT,
				math.cos(camAngle) * CONFIG.CAMERA_DISTANCE
			),
			head.Position
		)
		
		-- Head movement (subtle wave)
		head.Position = Vector3.new(
			math.sin(time * CONFIG.WAVE_SPEED) * CONFIG.WAVE_AMPLITUDE,
			0,
			-10
		)
		
		-- Update eyes to follow head
		leftEye.Position = head.Position + Vector3.new(-0.6, 0.5, 0.8)
		rightEye.Position = head.Position + Vector3.new(0.6, 0.5, 0.8)
		leftPupil.Position = leftEye.Position + Vector3.new(0, 0, -0.2)
		rightPupil.Position = rightEye.Position + Vector3.new(0, 0, -0.2)
		
		-- Smooth segment following (slither.io style)
		local prevPos = head.Position
		for i, seg in ipairs(segments) do
			-- Calculate target position based on previous segment
			local targetPos = prevPos - (prevPos - seg.part.Position).Unit * CONFIG.SEGMENT_SPACING
			
			-- Smooth interpolation for natural movement
			seg.part.Position = seg.part.Position:Lerp(targetPos, CONFIG.FOLLOW_SPEED)
			
			-- Add slight wave motion
			local waveOffset = math.sin(time * CONFIG.WAVE_SPEED - i * 0.3) * 0.3
			seg.part.Position = seg.part.Position + Vector3.new(waveOffset, 0, 0)
			
			prevPos = seg.part.Position
		end
	end)
	
	-- Store references
	CharacterPreview.currentModel = model
	CharacterPreview.currentHead = head
	CharacterPreview.currentSegments = segments
	CharacterPreview.rotationConnection = rotationConnection
	
	return model
end

function CharacterPreview.update(skinName, skinData)
	if not CharacterPreview.currentModel then return end
	
	local skin = skinData or {
		HeadColor = Color3.fromRGB(76, 217, 100),
		BodyColors = {Color3.fromRGB(60, 180, 80)},
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
	}
	
	-- Update head
	if CharacterPreview.currentHead then
		CharacterPreview.currentHead.Color = skin.HeadColor
		CharacterPreview.currentHead.Material = skin.HeadMaterial
		
		local light = CharacterPreview.currentHead:FindFirstChild("PointLight")
		if light then
			light.Color = skin.HeadColor
		end
	end
	
	-- Update segments
	if CharacterPreview.currentSegments then
		for i, seg in ipairs(CharacterPreview.currentSegments) do
			local colorIndex = seg.colorIndex
			if skin.BodyColors and skin.BodyColors[colorIndex] then
				seg.part.Color = skin.BodyColors[colorIndex]
				seg.part.Material = skin.BodyMaterial
				
				local light = seg.part:FindFirstChild("PointLight")
				if light then
					light.Color = seg.part.Color
				end
			end
		end
	end
end

function CharacterPreview.destroy()
	if CharacterPreview.rotationConnection then
		CharacterPreview.rotationConnection:Disconnect()
	end
	
	if CharacterPreview.currentModel then
		CharacterPreview.currentModel:Destroy()
	end
	
	CharacterPreview.currentModel = nil
	CharacterPreview.currentHead = nil
	CharacterPreview.currentSegments = nil
	CharacterPreview.rotationConnection = nil
end

-- Additional helper functions
function CharacterPreview.startRotation()
	-- Compatibility function (rotation already handled in create)
end

function CharacterPreview.startVFXAnimations()
	-- Compatibility function (can add VFX here if needed)
end

function CharacterPreview.startBodyWave()
	-- Compatibility function (wave already handled in create)
end

return CharacterPreview