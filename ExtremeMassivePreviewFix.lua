--[[
EXTREME MASSIVE PREVIEW FIX FOR REAL GAME
This completely revamps the preview to be HUGE in published games
The issue: ViewportFrames render differently in real games vs Studio
Solution: Use extreme scaling and positioning tricks
]]

-- MASSIVE PREVIEW CONFIG - EXTREME VERSION
local EXTREME_PREVIEW_CONFIG = {
	-- INSANE SIZES
	SEGMENT_COUNT = 60,
	SEGMENT_SPACING = 8, -- HUGE gaps
	HEAD_SIZE = Vector3.new(25, 25, 25), -- GIGANTIC
	SEGMENT_SIZE = Vector3.new(20, 20, 20), -- MASSIVE
	SIZE_REDUCTION = 0.99, -- Almost no reduction
	
	-- Camera positioning for massive snake
	CAMERA_DISTANCE = 200,
	CAMERA_HEIGHT = 80,
	CAMERA_FOV = 120, -- Max FOV
	
	-- Movement
	MOVEMENT_RADIUS = 50,
	MOVEMENT_SPEED = 0.5,
	WAVE_HEIGHT = 10,
	
	-- Eye config
	EYE_SIZE = Vector3.new(5, 5, 5),
	EYE_SPACING = 3,
	EYE_FORWARD = -7,
	EYE_UP = 3,
}

-- Function to create the EXTREME preview
function CreateExtremePreview(viewport, skinName)
	-- CRITICAL: Clear and setup viewport properly
	viewport:ClearAllChildren()
	
	-- FORCE viewport settings
	viewport.BackgroundTransparency = 0
	viewport.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
	viewport.Ambient = Color3.new(1, 1, 1) -- MAX ambient
	viewport.LightColor = Color3.new(1, 1, 1)
	viewport.LightDirection = Vector3.new(-1, -1, -1).Unit
	viewport.ImageColor3 = Color3.new(1, 1, 1)
	viewport.ImageTransparency = 0
	
	-- Create WorldModel with specific properties
	local worldModel = Instance.new("WorldModel")
	worldModel.Name = "SnakeWorldModel"
	worldModel.Parent = viewport
	
	-- Create a base part to establish scale reference
	local basePlate = Instance.new("Part")
	basePlate.Name = "ScaleReference"
	basePlate.Size = Vector3.new(500, 1, 500)
	basePlate.Position = Vector3.new(0, -50, 0)
	basePlate.Transparency = 1
	basePlate.Anchored = true
	basePlate.CanCollide = false
	basePlate.Parent = worldModel
	
	-- Create camera with extreme settings
	local camera = Instance.new("Camera")
	camera.Name = "PreviewCamera"
	camera.CameraType = Enum.CameraType.Scriptable
	camera.FieldOfView = EXTREME_PREVIEW_CONFIG.CAMERA_FOV
	camera.Focus = CFrame.new(0, 0, 0)
	camera.CFrame = CFrame.new(0, EXTREME_PREVIEW_CONFIG.CAMERA_HEIGHT, EXTREME_PREVIEW_CONFIG.CAMERA_DISTANCE) * CFrame.Angles(-0.3, 0, 0)
	viewport.CurrentCamera = camera
	camera.Parent = viewport
	
	-- Create model for snake
	local model = Instance.new("Model")
	model.Name = "GiantSnake"
	model.Parent = worldModel
	
	-- Get skin data (default for now)
	local skin = {
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
	}
	
	-- Create MASSIVE head with multiple light sources
	local head = Instance.new("Part")
	head.Name = "MassiveHead"
	head.Size = EXTREME_PREVIEW_CONFIG.HEAD_SIZE
	head.Shape = Enum.PartType.Ball
	head.Material = skin.HeadMaterial
	head.Color = skin.HeadColor
	head.TopSurface = Enum.SurfaceType.Smooth
	head.BottomSurface = Enum.SurfaceType.Smooth
	head.CanCollide = false
	head.Anchored = true
	head.Position = Vector3.new(0, 0, 0)
	head.Parent = model
	
	-- MULTIPLE light sources for maximum visibility
	local headLight1 = Instance.new("PointLight")
	headLight1.Brightness = 10
	headLight1.Range = 60
	headLight1.Color = skin.HeadColor
	headLight1.Parent = head
	
	local headLight2 = Instance.new("SpotLight")
	headLight2.Brightness = 10
	headLight2.Range = 80
	headLight2.Angle = 180
	headLight2.Face = Enum.NormalId.Front
	headLight2.Color = skin.HeadColor
	headLight2.Parent = head
	
	-- Add SelectionBox for extra visibility
	local headOutline = Instance.new("SelectionBox")
	headOutline.Adornee = head
	headOutline.Color3 = skin.HeadColor
	headOutline.LineThickness = 0.1
	headOutline.Transparency = 0.5
	headOutline.Parent = head
	
	-- Create HUGE eyes with glow
	local function createMassiveEye(xOffset)
		local eye = Instance.new("Part")
		eye.Size = EXTREME_PREVIEW_CONFIG.EYE_SIZE
		eye.Shape = Enum.PartType.Ball
		eye.Material = Enum.Material.Neon
		eye.Color = Color3.fromRGB(255, 255, 255)
		eye.CanCollide = false
		eye.Anchored = true
		eye.Parent = model
		
		-- Eye super glow
		local eyeLight = Instance.new("PointLight")
		eyeLight.Brightness = 5
		eyeLight.Range = 20
		eyeLight.Color = Color3.fromRGB(255, 255, 255)
		eyeLight.Parent = eye
		
		-- Pupil
		local pupil = Instance.new("Part")
		pupil.Size = EXTREME_PREVIEW_CONFIG.EYE_SIZE * 0.4
		pupil.Shape = Enum.PartType.Ball
		pupil.Material = Enum.Material.Neon
		pupil.Color = Color3.fromRGB(0, 0, 0)
		pupil.CanCollide = false
		pupil.Anchored = true
		pupil.Parent = model
		
		return eye, pupil
	end
	
	local leftEye, leftPupil = createMassiveEye(-EXTREME_PREVIEW_CONFIG.EYE_SPACING)
	local rightEye, rightPupil = createMassiveEye(EXTREME_PREVIEW_CONFIG.EYE_SPACING)
	
	-- Create MASSIVE segments
	local segments = {}
	local currentSize = EXTREME_PREVIEW_CONFIG.SEGMENT_SIZE
	
	for i = 1, EXTREME_PREVIEW_CONFIG.SEGMENT_COUNT do
		local segment = Instance.new("Part")
		segment.Name = "MassiveSegment" .. i
		segment.Size = currentSize
		segment.Shape = Enum.PartType.Ball
		segment.Material = skin.BodyMaterial
		segment.CanCollide = false
		segment.Anchored = true
		segment.TopSurface = Enum.SurfaceType.Smooth
		segment.BottomSurface = Enum.SurfaceType.Smooth
		segment.Parent = model
		
		-- Color pattern
		local colorIndex = ((i - 1) % #skin.BodyColors) + 1
		segment.Color = skin.BodyColors[colorIndex]
		
		-- BRIGHT segment lights
		local segLight = Instance.new("PointLight")
		segLight.Brightness = 5
		segLight.Range = 40
		segLight.Color = segment.Color
		segLight.Parent = segment
		
		-- Add outline for visibility
		if i % 5 == 0 then -- Every 5th segment
			local outline = Instance.new("SelectionBox")
			outline.Adornee = segment
			outline.Color3 = segment.Color
			outline.LineThickness = 0.05
			outline.Transparency = 0.7
			outline.Parent = segment
		end
		
		-- Position in a spread pattern
		segment.Position = Vector3.new(
			i * EXTREME_PREVIEW_CONFIG.SEGMENT_SPACING * 0.5,
			0,
			-i * EXTREME_PREVIEW_CONFIG.SEGMENT_SPACING
		)
		
		table.insert(segments, {
			part = segment,
			index = i,
			baseSize = currentSize
		})
		
		currentSize = currentSize * EXTREME_PREVIEW_CONFIG.SIZE_REDUCTION
	end
	
	-- Position history for smooth movement
	local positionHistory = {}
	for i = 1, EXTREME_PREVIEW_CONFIG.SEGMENT_COUNT + 10 do
		table.insert(positionHistory, Vector3.new(0, 0, -i * 2))
	end
	
	-- Animation variables
	local time = 0
	local connection
	
	-- EXTREME animation loop
	connection = game:GetService("RunService").Heartbeat:Connect(function(dt)
		time = time + dt
		
		-- Move head in large figure-8 pattern
		local angle = time * EXTREME_PREVIEW_CONFIG.MOVEMENT_SPEED
		local figure8 = math.sin(angle * 2)
		
		head.Position = Vector3.new(
			math.cos(angle) * EXTREME_PREVIEW_CONFIG.MOVEMENT_RADIUS * (1 + figure8 * 0.4),
			math.sin(angle * 2) * EXTREME_PREVIEW_CONFIG.WAVE_HEIGHT,
			math.sin(angle) * EXTREME_PREVIEW_CONFIG.MOVEMENT_RADIUS * (1 - figure8 * 0.4)
		)
		
		-- Update position history
		table.insert(positionHistory, 1, head.Position)
		if #positionHistory > EXTREME_PREVIEW_CONFIG.SEGMENT_COUNT + 10 then
			table.remove(positionHistory)
		end
		
		-- Update eyes to face forward
		local lookDir = Vector3.new(0, 0, -1)
		if #positionHistory > 3 then
			local vel = (head.Position - positionHistory[3])
			if vel.Magnitude > 0.1 then
				lookDir = vel.Unit
			end
		end
		
		local headCFrame = CFrame.lookAt(head.Position, head.Position + lookDir)
		leftEye.CFrame = headCFrame * CFrame.new(-EXTREME_PREVIEW_CONFIG.EYE_SPACING, EXTREME_PREVIEW_CONFIG.EYE_UP, EXTREME_PREVIEW_CONFIG.EYE_FORWARD)
		rightEye.CFrame = headCFrame * CFrame.new(EXTREME_PREVIEW_CONFIG.EYE_SPACING, EXTREME_PREVIEW_CONFIG.EYE_UP, EXTREME_PREVIEW_CONFIG.EYE_FORWARD)
		leftPupil.CFrame = leftEye.CFrame * CFrame.new(0, 0, -1)
		rightPupil.CFrame = rightEye.CFrame * CFrame.new(0, 0, -1)
		
		-- Update segments with position history
		for i, seg in ipairs(segments) do
			local histIndex = math.min(i * 1.2 + 1, #positionHistory)
			if positionHistory[histIndex] then
				-- Add wave motion
				local wave = math.sin(time * 2 + i * 0.1) * 2
				seg.part.Position = positionHistory[histIndex] + Vector3.new(0, wave, 0)
				
				-- Pulse effect for visibility
				local pulse = 1 + math.sin(time * 3 + i * 0.2) * 0.1
				seg.part.Size = seg.baseSize * pulse
			end
		end
		
		-- Dynamic camera that shows the whole snake
		local camAngle = time * 0.2
		local camDistance = EXTREME_PREVIEW_CONFIG.CAMERA_DISTANCE + math.sin(time * 0.5) * 20
		
		camera.CFrame = CFrame.new(
			math.sin(camAngle) * camDistance,
			EXTREME_PREVIEW_CONFIG.CAMERA_HEIGHT + math.sin(time * 0.3) * 10,
			math.cos(camAngle) * camDistance * 0.8
		) * CFrame.Angles(-0.4, 0, 0)
		
		camera.Focus = CFrame.new(0, 0, 0)
	end)
	
	-- Return cleanup function
	return function()
		if connection then
			connection:Disconnect()
		end
		if model then
			model:Destroy()
		end
	end
end

return CreateExtremePreview