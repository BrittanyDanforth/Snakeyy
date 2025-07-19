-- MULTIPLAYER-COMPATIBLE GRAPHICS MODE UPDATES FOR ORBSPAWNER

-- 1. ADD THIS AFTER YOUR CONFIG SECTION:

-- Get player's graphics mode (CLIENT ONLY)
local function getPlayerGraphicsMode()
	-- Only works on client
	if RunService:IsClient() then
		local localPlayer = Players.LocalPlayer
		if localPlayer then
			return localPlayer:GetAttribute("GraphicsMode") or "High"
		end
	end
	return "High"
end

-- Update config based on graphics mode (CLIENT ONLY)
local function updateConfigForGraphicsMode()
	-- Only update on client
	if not RunService:IsClient() then return end
	
	local mode = getPlayerGraphicsMode()
	
	if mode == "Low" then
		ORB_MAX = 400
		RENDER_DISTANCE = 75
		FAR_DISTANCE = 150
		FADE_DISTANCE = 25
		LOD_UPDATE_RATE = 0.2
		-- Note: Don't change spawn interval on client
	elseif mode == "Medium" then
		ORB_MAX = 600
		RENDER_DISTANCE = 125
		FAR_DISTANCE = 250
		FADE_DISTANCE = 40
		LOD_UPDATE_RATE = 0.15
	else -- High
		ORB_MAX = 850
		RENDER_DISTANCE = 150
		FAR_DISTANCE = 300
		FADE_DISTANCE = 50
		LOD_UPDATE_RATE = 0.1
	end
end

-- 2. REPLACE createSafeOrb WITH THIS MULTIPLAYER VERSION:

local function createSafeOrb(position, value, name, color, material)
	local orb = Instance.new("Part")
	orb.Name = name or "Orb"
	orb.Shape = Enum.PartType.Ball
	orb.Size = Vector3.new(0.1, 0.1, 0.1)  -- Start tiny
	orb.Anchored = true
	orb.CanCollide = false
	orb.Color = color or Color3.new(1, 1, 0)
	orb.Position = position
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	orb.Transparency = 1  -- Start invisible
	
	-- SERVER: Always use high quality materials
	if RunService:IsServer() then
		orb.Material = material or Enum.Material.ForceField
	else
		-- CLIENT: Apply graphics mode optimizations
		local mode = getPlayerGraphicsMode()
		
		if mode == "Low" then
			orb.Material = Enum.Material.SmoothPlastic
		elseif mode == "Medium" then
			orb.Material = Enum.Material.Neon
		else
			orb.Material = material or Enum.Material.ForceField
		end
	end
	
	orb.Parent = Workspace

	local val = Instance.new("NumberValue")
	val.Name = "Value"
	val.Value = value or 10
	val.Parent = orb

	-- SERVER: Always create lights (clients will handle visibility)
	-- CLIENT: Only create if graphics mode allows
	if RunService:IsServer() or getPlayerGraphicsMode() ~= "Low" then
		local light = Instance.new("PointLight")
		light.Parent = orb
		light.Color = orb.Color
		light.Brightness = 0
		light.Range = 0
		light.Enabled = false  -- Start disabled
	end

	-- Initialize as hidden
	orbStates[orb] = {state = "hidden", fade = 0}

	return orb
end

-- 3. REPLACE applyOrbLOD WITH THIS MULTIPLAYER VERSION:

local function applyOrbLOD(orb, state, fadeValue)
	if not orb or not orb.Parent then return end

	local currentState = orbStates[orb] or {state = "hidden", fade = 0}
	
	-- CLIENT ONLY: Get graphics mode
	local mode = "High"
	if RunService:IsClient() then
		mode = getPlayerGraphicsMode()
	end

	-- Skip if state hasn't changed significantly
	if currentState.state == state and math.abs(currentState.fade - fadeValue) < 0.1 then
		return
	end

	orbStates[orb] = {state = state, fade = fadeValue}

	-- Cancel existing tween
	if orbTweens[orb] then
		orbTweens[orb]:Cancel()
		orbTweens[orb] = nil
	end

	-- Calculate target properties
	local targetSize = Vector3.new(1,1,1) * (MIN_ORB_SIZE + (MAX_ORB_SIZE - MIN_ORB_SIZE) * fadeValue)
	local baseTransparency = (RunService:IsClient() and mode == "Low") and 0.2 or 0
	local targetTransparency = baseTransparency + (1 - baseTransparency) * (1 - fadeValue)

	-- Apply based on state
	if state == "hidden" then
		orb.Transparency = 1
		orb.Size = Vector3.new(0.1, 0.1, 0.1)
		local light = orb:FindFirstChild("PointLight")
		if light then light.Enabled = false end
	else
		local light = orb:FindFirstChild("PointLight")
		if light then 
			if RunService:IsClient() and mode == "Low" then
				light.Enabled = false
			else
				light.Enabled = fadeValue > 0.1
				light.Brightness = (RunService:IsClient() and mode == "Medium" and 1.5 or 2) * fadeValue
				light.Range = (RunService:IsClient() and mode == "Medium" and 6 or 8) * fadeValue
			end
		end

		-- CLIENT: Simpler animations for low graphics mode
		if RunService:IsClient() and mode == "Low" then
			-- Instant changes, no tweening
			orb.Size = targetSize
			orb.Transparency = targetTransparency
		else
			-- Smooth tween for server/medium/high graphics
			local tweenDuration = (RunService:IsClient() and mode == "Medium") and 0.2 or 0.3
			local tweenInfo = TweenInfo.new(
				tweenDuration,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			)

			local tween = TweenService:Create(orb, tweenInfo, {
				Size = targetSize,
				Transparency = targetTransparency
			})

			orbTweens[orb] = tween
			tween:Play()

			-- Pop-in effect only for high graphics on client
			if RunService:IsClient() and mode == "High" and currentState.state == "hidden" and state ~= "hidden" then
				orb.Size = Vector3.new(0.1, 0.1, 0.1)
				local popTween = TweenService:Create(orb, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = targetSize
				})
				orbTweens[orb] = popTween
				popTween:Play()
			end
		end
	end
end

-- 4. UPDATE createOrbCollectVFX:

local function createOrbCollectVFX(pos, color)
	-- VFXManager handles client/server separation
	VFXManager.playOrbCollectVFX(pos, RunService:IsClient() and Players.LocalPlayer or nil)
end

-- 5. ADD CLIENT-ONLY GRAPHICS MODE LISTENER:

if RunService:IsClient() then
	-- Initialize config on client startup
	updateConfigForGraphicsMode()
	
	-- Listen for graphics mode changes
	Players.LocalPlayer.AttributeChanged:Connect(function(attr)
		if attr == "GraphicsMode" then
			updateConfigForGraphicsMode()
			print("[Client] Graphics mode changed to:", getPlayerGraphicsMode())
			
			-- Update all existing orbs with new graphics settings
			for orb, _ in pairs(orbStates) do
				if orb and orb.Parent then
					-- Update material
					local mode = getPlayerGraphicsMode()
					if mode == "Low" then
						orb.Material = Enum.Material.SmoothPlastic
						-- Remove light if it exists
						local light = orb:FindFirstChild("PointLight")
						if light then
							light:Destroy()
						end
					elseif mode == "Medium" then
						orb.Material = Enum.Material.Neon
					else
						orb.Material = Enum.Material.ForceField
					end
				end
			end
		end
	end)
end

-- 6. UPDATE MODULE EXPORTS:

OrbSpawner.setGraphicsMode = function(mode)
	if RunService:IsClient() then
		local SetGraphicsModeEvent = ReplicatedStorage:FindFirstChild("SetGraphicsMode")
		if SetGraphicsModeEvent then
			SetGraphicsModeEvent:FireServer(mode)
		end
	end
end