-- ADVANCED SNAKE PREVIEW SYSTEM V7.0
-- Ultra-smooth slither.io style preview with proper segment shapes and eye attachment
-- Designed for maximum visual quality and performance

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local AdvancedSnakePreview = {}

-- Configuration for ultra-smooth appearance
local PREVIEW_CONFIG = {
	-- Segment configuration for proper slither.io look
	SEGMENT_COUNT = 12,
	SEGMENT_SIZE_HEAD = Vector3.new(3.2, 3.2, 3.2),
	SEGMENT_SIZE_BODY = Vector3.new(2.8, 2.8, 2.8),
	SEGMENT_SIZE_TAIL = Vector3.new(1.8, 1.8, 1.8),
	SEGMENT_SPACING = 2.0,
	
	-- Smooth curves and animation
	WAVE_AMPLITUDE = 2.5,
	WAVE_FREQUENCY = 0.8,
	WAVE_SPEED = 2.0,
	ROTATION_SPEED = 0.3,
	
	-- Eye configuration
	EYE_SIZE = Vector3.new(0.7, 0.7, 0.7),
	PUPIL_SIZE = Vector3.new(0.3, 0.3, 0.3),
	EYE_OFFSET_X = 0.65,
	EYE_OFFSET_Y = 0.6,
	EYE_OFFSET_Z = 0.9,
	
	-- Visual quality
	SMOOTHNESS_FACTOR = 0.95,
	GLOW_PULSE_SPEED = 1.5,
	MATERIAL_HEAD = Enum.Material.ForceField,
	MATERIAL_BODY = Enum.Material.Neon,
}

-- Create smooth segment with proper shape
local function createSmoothSegment(index, size, color, material)
	local segment = Instance.new("Part")
	segment.Name = "Segment" .. index
	segment.Shape = Enum.PartType.Ball
	segment.Material = material
	segment.Size = size
	segment.Color = color
	segment.TopSurface = Enum.SurfaceType.Smooth
	segment.BottomSurface = Enum.SurfaceType.Smooth
	segment.Anchored = true
	segment.CanCollide = false
	segment.CanQuery = false
	segment.CanTouch = false
	
	-- Add glow effect
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 2
	pointLight.Range = 8
	pointLight.Color = color
	pointLight.Parent = segment
	
	-- Add selection box for outline
	local selectionBox = Instance.new("SelectionBox")
	selectionBox.Adornee = segment
	selectionBox.Color3 = Color3.new(1, 1, 1)
	selectionBox.LineThickness = 0.02
	selectionBox.Transparency = 0.7
	selectionBox.Parent = segment
	
	return segment
end

-- Create eye with proper attachment
local function createEye(name, parent)
	local eye = Instance.new("Part")
	eye.Name = name
	eye.Shape = Enum.PartType.Ball
	eye.Material = Enum.Material.Neon
	eye.Size = PREVIEW_CONFIG.EYE_SIZE
	eye.Color = Color3.new(1, 1, 1)
	eye.Anchored = false
	eye.CanCollide = false
	eye.CanQuery = false
	eye.CanTouch = false
	eye.Parent = parent
	
	-- Create pupil
	local pupil = Instance.new("Part")
	pupil.Name = name .. "Pupil"
	pupil.Shape = Enum.PartType.Ball
	pupil.Material = Enum.Material.Neon
	pupil.Size = PREVIEW_CONFIG.PUPIL_SIZE
	pupil.Color = Color3.new(0, 0, 0)
	pupil.Anchored = false
	pupil.CanCollide = false
	pupil.CanQuery = false
	pupil.CanTouch = false
	pupil.Parent = parent
	
	-- Weld eye to head
	local eyeWeld = Instance.new("WeldConstraint")
	eyeWeld.Part0 = parent
	eyeWeld.Part1 = eye
	eyeWeld.Parent = parent
	
	-- Weld pupil to eye
	local pupilWeld = Instance.new("WeldConstraint")
	pupilWeld.Part0 = eye
	pupilWeld.Part1 = pupil
	pupilWeld.Parent = eye
	
	return eye, pupil, eyeWeld, pupilWeld
end

-- Main creation function
function AdvancedSnakePreview.Create(viewport, skinData)
	local model = Instance.new("Model")
	model.Name = "AdvancedSnakePreview"
	
	-- Camera setup
	local camera = Instance.new("Camera")
	camera.CFrame = CFrame.new(0, 8, -25) * CFrame.Angles(math.rad(-15), 0, 0)
	camera.FieldOfView = 60
	viewport.CurrentCamera = camera
	
	-- Create segments with size gradient
	local segments = {}
	local colors = skinData.BodyColors or {Color3.fromRGB(76, 217, 100)}
	
	for i = 1, PREVIEW_CONFIG.SEGMENT_COUNT do
		local t = (i - 1) / (PREVIEW_CONFIG.SEGMENT_COUNT - 1)
		local size = PREVIEW_CONFIG.SEGMENT_SIZE_HEAD:Lerp(PREVIEW_CONFIG.SEGMENT_SIZE_TAIL, t)
		local colorIndex = ((i - 1) % #colors) + 1
		local color = colors[colorIndex]
		
		local material = i == 1 and PREVIEW_CONFIG.MATERIAL_HEAD or PREVIEW_CONFIG.MATERIAL_BODY
		local segment = createSmoothSegment(i, size, color, material)
		
		if i == 1 then
			-- Special treatment for head
			segment.Color = skinData.HeadColor or Color3.fromRGB(76, 217, 100)
			segment.Size = skinData.HeadSize or PREVIEW_CONFIG.SEGMENT_SIZE_HEAD
			
			-- Create eyes with proper attachment
			local leftEye, leftPupil = createEye("LeftEye", segment)
			local rightEye, rightPupil = createEye("RightEye", segment)
			
			-- Position eyes relative to head
			leftEye.CFrame = segment.CFrame * CFrame.new(-PREVIEW_CONFIG.EYE_OFFSET_X, PREVIEW_CONFIG.EYE_OFFSET_Y, PREVIEW_CONFIG.EYE_OFFSET_Z)
			rightEye.CFrame = segment.CFrame * CFrame.new(PREVIEW_CONFIG.EYE_OFFSET_X, PREVIEW_CONFIG.EYE_OFFSET_Y, PREVIEW_CONFIG.EYE_OFFSET_Z)
			
			-- Position pupils
			leftPupil.CFrame = leftEye.CFrame * CFrame.new(0, 0, -0.2)
			rightPupil.CFrame = rightEye.CFrame * CFrame.new(0, 0, -0.2)
			
			-- Store references
			segment:SetAttribute("HasEyes", true)
			model:SetAttribute("LeftEye", leftEye)
			model:SetAttribute("RightEye", rightEye)
			model:SetAttribute("LeftPupil", leftPupil)
			model:SetAttribute("RightPupil", rightPupil)
		end
		
		segment.Parent = model
		segments[i] = segment
	end
	
	model.PrimaryPart = segments[1]
	model.Parent = viewport
	
	-- Store data for animations
	model:SetAttribute("SegmentCount", PREVIEW_CONFIG.SEGMENT_COUNT)
	AdvancedSnakePreview.Model = model
	AdvancedSnakePreview.Segments = segments
	AdvancedSnakePreview.Camera = camera
	
	-- Start animations
	AdvancedSnakePreview.StartAnimation(skinData)
	
	return model, segments, camera
end

-- Smooth wave animation
function AdvancedSnakePreview.StartAnimation(skinData)
	if AdvancedSnakePreview.AnimationConnection then
		AdvancedSnakePreview.AnimationConnection:Disconnect()
	end
	
	local startTime = tick()
	
	AdvancedSnakePreview.AnimationConnection = RunService.Heartbeat:Connect(function()
		local elapsed = tick() - startTime
		local segments = AdvancedSnakePreview.Segments
		
		if not segments or #segments == 0 then return end
		
		-- Smooth rotation
		local rotationAngle = elapsed * PREVIEW_CONFIG.ROTATION_SPEED
		
		-- Update each segment with smooth wave motion
		for i, segment in ipairs(segments) do
			if segment and segment.Parent then
				local t = (i - 1) / (#segments - 1)
				
				-- Calculate smooth wave position
				local waveOffset = math.sin(elapsed * PREVIEW_CONFIG.WAVE_SPEED - t * math.pi * 2) * PREVIEW_CONFIG.WAVE_AMPLITUDE
				local heightOffset = math.sin(elapsed * PREVIEW_CONFIG.WAVE_SPEED * 0.7 - t * math.pi) * 0.5
				
				-- Smooth curve formation
				local x = math.sin(rotationAngle + t * math.pi * 0.5) * (10 - t * 5)
				local y = heightOffset + (i - 1) * 0.1
				local z = -i * PREVIEW_CONFIG.SEGMENT_SPACING + waveOffset
				
				-- Apply smooth interpolation
				local targetCFrame = CFrame.new(x, y, z)
				segment.CFrame = segment.CFrame:Lerp(targetCFrame, PREVIEW_CONFIG.SMOOTHNESS_FACTOR)
				
				-- Pulse glow effect
				local light = segment:FindFirstChild("PointLight")
				if light then
					light.Brightness = 2 + math.sin(elapsed * PREVIEW_CONFIG.GLOW_PULSE_SPEED + t * math.pi) * 0.5
				end
				
				-- Update selection box transparency
				local selectionBox = segment:FindFirstChild("SelectionBox")
				if selectionBox then
					selectionBox.Transparency = 0.7 + math.sin(elapsed * 2 + t * math.pi) * 0.2
				end
			end
		end
	end)
end

-- Update skin
function AdvancedSnakePreview.UpdateSkin(skinData)
	if not AdvancedSnakePreview.Segments then return end
	
	local colors = skinData.BodyColors or {Color3.fromRGB(76, 217, 100)}
	
	for i, segment in ipairs(AdvancedSnakePreview.Segments) do
		if segment and segment.Parent then
			if i == 1 then
				-- Update head
				segment.Color = skinData.HeadColor or Color3.fromRGB(76, 217, 100)
				segment.Material = skinData.HeadMaterial or PREVIEW_CONFIG.MATERIAL_HEAD
			else
				-- Update body
				local colorIndex = ((i - 2) % #colors) + 1
				segment.Color = colors[colorIndex]
				segment.Material = skinData.BodyMaterial or PREVIEW_CONFIG.MATERIAL_BODY
			end
			
			-- Update glow
			local light = segment:FindFirstChild("PointLight")
			if light then
				light.Color = segment.Color
				light.Range = skinData.GlowRange or 8
			end
		end
	end
end

-- Cleanup
function AdvancedSnakePreview.Destroy()
	if AdvancedSnakePreview.AnimationConnection then
		AdvancedSnakePreview.AnimationConnection:Disconnect()
		AdvancedSnakePreview.AnimationConnection = nil
	end
	
	if AdvancedSnakePreview.Model then
		AdvancedSnakePreview.Model:Destroy()
		AdvancedSnakePreview.Model = nil
	end
	
	AdvancedSnakePreview.Segments = nil
	AdvancedSnakePreview.Camera = nil
end

return AdvancedSnakePreview