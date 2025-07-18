-- ADD THIS TO YOUR ORBSPAWNER FOR EXTREME GRAPHICS MODES THAT ACTUALLY WORK

-- 1. REPLACE YOUR CONFIG SECTION WITH THIS DYNAMIC ONE:

local ORB_SPAWN_INTERVAL = 0.5
local ORB_MAX = 850
local UPGRADE_ORB_CHANCE = 0.13

-- EXTREME LOD settings that ACTUALLY change based on graphics
local RENDER_DISTANCE = 150
local FAR_DISTANCE = 300
local FADE_DISTANCE = 50
local MIN_ORB_SIZE = 0.3
local MAX_ORB_SIZE = 2.0
local LOD_UPDATE_RATE = 0.1

-- Graphics mode detection
local function getPlayerGraphicsMode()
	if RunService:IsClient() then
		local localPlayer = Players.LocalPlayer
		if localPlayer then
			return localPlayer:GetAttribute("GraphicsMode") or "High"
		end
	end
	return "High"
end

-- EXTREME config changes for performance
local function updateConfigForGraphicsMode()
	if not RunService:IsClient() then return end
	
	local mode = getPlayerGraphicsMode()
	print("[EXTREME GRAPHICS] Mode changed to:", mode)
	
	if mode == "Low" then
		-- POTATO MODE - EXTREME PERFORMANCE
		ORB_MAX = 200  -- WAY fewer orbs
		RENDER_DISTANCE = 50  -- VERY short view distance
		FAR_DISTANCE = 75
		FADE_DISTANCE = 15
		MIN_ORB_SIZE = 0.8  -- Bigger minimum size
		MAX_ORB_SIZE = 1.5  -- Smaller max size
		LOD_UPDATE_RATE = 0.5  -- Update 5x slower
	elseif mode == "Medium" then
		-- BALANCED MODE
		ORB_MAX = 500
		RENDER_DISTANCE = 100
		FAR_DISTANCE = 200
		FADE_DISTANCE = 35
		MIN_ORB_SIZE = 0.5
		MAX_ORB_SIZE = 1.8
		LOD_UPDATE_RATE = 0.2
	else -- High
		-- ULTRA MODE - ALL EFFECTS
		ORB_MAX = 850
		RENDER_DISTANCE = 150
		FAR_DISTANCE = 300
		FADE_DISTANCE = 50
		MIN_ORB_SIZE = 0.3
		MAX_ORB_SIZE = 2.0
		LOD_UPDATE_RATE = 0.1
	end
end

-- 2. REPLACE createSafeOrb WITH THIS EXTREME VERSION:

local function createSafeOrb(position, value, name, color, material)
	local orb = Instance.new("Part")
	orb.Name = name or "Orb"
	orb.Shape = Enum.PartType.Ball
	orb.Size = Vector3.new(0.1, 0.1, 0.1)
	orb.Anchored = true
	orb.CanCollide = false
	orb.Color = color or Color3.new(1, 1, 0)
	orb.Position = position
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	orb.Transparency = 1
	
	-- EXTREME MATERIAL CHANGES FOR PERFORMANCE
	if RunService:IsClient() then
		local mode = getPlayerGraphicsMode()
		
		if mode == "Low" then
			-- POTATO MODE - NO FANCY MATERIALS
			orb.Material = Enum.Material.SmoothPlastic
			orb.CastShadow = false  -- No shadows!
			-- Make orbs more visible without glow
			orb.Color = color:Lerp(Color3.new(1,1,1), 0.3)  -- Brighter colors
		elseif mode == "Medium" then
			orb.Material = Enum.Material.Neon
			orb.CastShadow = false
		else
			orb.Material = material or Enum.Material.ForceField
			orb.CastShadow = true
		end
	else
		-- Server always uses high quality
		orb.Material = material or Enum.Material.ForceField
	end
	
	orb.Parent = Workspace

	local val = Instance.new("NumberValue")
	val.Name = "Value"
	val.Value = value or 10
	val.Parent = orb

	-- EXTREME LIGHT HANDLING
	if RunService:IsServer() then
		-- Server always creates lights
		local light = Instance.new("PointLight")
		light.Parent = orb
		light.Color = orb.Color
		light.Brightness = 0
		light.Range = 0
		light.Enabled = false
		light.Shadows = true  -- Server has shadows
	elseif getPlayerGraphicsMode() ~= "Low" then
		-- Client only creates lights for Medium/High
		local light = Instance.new("PointLight")
		light.Parent = orb
		light.Color = orb.Color
		light.Brightness = 0
		light.Range = 0
		light.Enabled = false
		light.Shadows = false  -- No shadows on client
	end
	-- LOW MODE GETS NO LIGHTS AT ALL!

	orbStates[orb] = {state = "hidden", fade = 0}
	return orb
end

-- 3. REPLACE applyOrbLOD WITH EXTREME VERSION:

local function applyOrbLOD(orb, state, fadeValue)
	if not orb or not orb.Parent then return end

	local currentState = orbStates[orb] or {state = "hidden", fade = 0}
	local mode = RunService:IsClient() and getPlayerGraphicsMode() or "High"

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

	-- EXTREME SIZE AND TRANSPARENCY DIFFERENCES
	local sizeMultiplier = 1
	local transparencyOffset = 0
	
	if mode == "Low" then
		sizeMultiplier = 0.7  -- Smaller orbs in low mode
		transparencyOffset = 0.3  -- More transparent
	elseif mode == "Medium" then
		sizeMultiplier = 0.85
		transparencyOffset = 0.1
	end

	local targetSize = Vector3.new(1,1,1) * (MIN_ORB_SIZE + (MAX_ORB_SIZE - MIN_ORB_SIZE) * fadeValue) * sizeMultiplier
	local targetTransparency = transparencyOffset + (1 - transparencyOffset) * (1 - fadeValue)

	-- Apply based on state
	if state == "hidden" then
		orb.Transparency = 1
		orb.Size = Vector3.new(0.1, 0.1, 0.1)
		local light = orb:FindFirstChild("PointLight")
		if light then light.Enabled = false end
	else
		-- EXTREME LIGHT HANDLING
		local light = orb:FindFirstChild("PointLight")
		if light then 
			if RunService:IsClient() then
				if mode == "Low" then
					-- NO LIGHTS IN LOW MODE - EXTREME PERFORMANCE
					light:Destroy()
				elseif mode == "Medium" then
					-- REDUCED LIGHTS
					light.Enabled = fadeValue > 0.3  -- Only enable for closer orbs
					light.Brightness = 1 * fadeValue
					light.Range = 4 * fadeValue
					light.Shadows = false
				else -- High
					-- FULL LIGHTS
					light.Enabled = fadeValue > 0.1
					light.Brightness = 2 * fadeValue
					light.Range = 8 * fadeValue
					light.Shadows = false  -- Still no shadows for performance
				end
			end
		end

		-- EXTREME ANIMATION DIFFERENCES
		if RunService:IsClient() then
			if mode == "Low" then
				-- NO ANIMATIONS AT ALL - INSTANT CHANGES
				orb.Size = targetSize
				orb.Transparency = targetTransparency
			elseif mode == "Medium" then
				-- FAST SIMPLE ANIMATIONS
				local tween = TweenService:Create(orb, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
					Size = targetSize,
					Transparency = targetTransparency
				})
				orbTweens[orb] = tween
				tween:Play()
			else -- High
				-- FULL SMOOTH ANIMATIONS
				local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tween = TweenService:Create(orb, tweenInfo, {
					Size = targetSize,
					Transparency = targetTransparency
				})
				orbTweens[orb] = tween
				tween:Play()

				-- Pop effect only in high mode
				if currentState.state == "hidden" and state ~= "hidden" then
					orb.Size = Vector3.new(0.1, 0.1, 0.1)
					local popTween = TweenService:Create(orb, 
						TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
						{Size = targetSize}
					)
					orbTweens[orb] = popTween
					popTween:Play()
				end
			end
		else
			-- Server always does full animations
			local tween = TweenService:Create(orb, TweenInfo.new(0.3), {
				Size = targetSize,
				Transparency = targetTransparency
			})
			orbTweens[orb] = tween
			tween:Play()
		end
	end
end

-- 4. ADD EXTREME CLIENT-SIDE HANDLING:

if RunService:IsClient() then
	-- Initialize on startup
	updateConfigForGraphicsMode()
	
	-- EXTREME ORB UPDATES WHEN MODE CHANGES
	Players.LocalPlayer.AttributeChanged:Connect(function(attr)
		if attr == "GraphicsMode" then
			updateConfigForGraphicsMode()
			
			local mode = getPlayerGraphicsMode()
			print("[EXTREME] Updating all orbs to", mode, "mode")
			
			-- UPDATE ALL EXISTING ORBS
			for orb, state in pairs(orbStates) do
				if orb and orb.Parent then
					-- Update material
					if mode == "Low" then
						orb.Material = Enum.Material.SmoothPlastic
						orb.CastShadow = false
						-- Brighten color for visibility
						local originalColor = orb.Color
						orb.Color = originalColor:Lerp(Color3.new(1,1,1), 0.3)
						
						-- DESTROY ALL LIGHTS
						local light = orb:FindFirstChild("PointLight")
						if light then
							light:Destroy()
						end
					elseif mode == "Medium" then
						orb.Material = Enum.Material.Neon
						orb.CastShadow = false
						
						-- Create light if missing
						if not orb:FindFirstChild("PointLight") then
							local light = Instance.new("PointLight")
							light.Parent = orb
							light.Color = orb.Color
							light.Brightness = 1
							light.Range = 4
							light.Enabled = false
							light.Shadows = false
						end
					else -- High
						orb.Material = Enum.Material.ForceField
						orb.CastShadow = true
						
						-- Create light if missing
						if not orb:FindFirstChild("PointLight") then
							local light = Instance.new("PointLight")
							light.Parent = orb
							light.Color = orb.Color
							light.Brightness = 2
							light.Range = 8
							light.Enabled = false
							light.Shadows = false
						end
					end
					
					-- Force LOD update
					local currentState = orbStates[orb]
					if currentState then
						applyOrbLOD(orb, currentState.state, currentState.fade)
					end
				end
			end
			
			-- REMOVE EXTRA ORBS IN LOW MODE
			if mode == "Low" and #orbs > ORB_MAX then
				print("[EXTREME] Removing", #orbs - ORB_MAX, "orbs for performance")
				for i = #orbs, ORB_MAX + 1, -1 do
					local orb = orbs[i]
					if orb and orb.Parent then
						removeOrb(orb)
						orb:Destroy()
					end
				end
			end
		end
	end)
	
	-- EXTREME LOD UPDATE OPTIMIZATION
	local lastLODUpdate = 0
	RunService.Heartbeat:Connect(function()
		local now = tick()
		local mode = getPlayerGraphicsMode()
		
		-- Update less frequently in low mode
		local updateRate = mode == "Low" and 0.5 or LOD_UPDATE_RATE
		
		if now - lastLODUpdate < updateRate then return end
		lastLODUpdate = now
		
		-- Skip some orbs in low mode for performance
		local skipRate = mode == "Low" and 2 or 1
		
		local viewPositions = getAllViewingPositions()
		if #viewPositions == 0 then return end
		
		for i = 1, #orbs, skipRate do
			local orb = orbs[i]
			if orb and orb.Parent then
				local state, fade = calculateOrbLOD(orb, viewPositions)
				applyOrbLOD(orb, state, fade)
			end
		end
	end)
end

-- 5. MODIFY createOrbCollectVFX FOR PERFORMANCE:

local function createOrbCollectVFX(pos, color)
	if RunService:IsClient() then
		local mode = getPlayerGraphicsMode()
		if mode == "Low" then
			-- NO VFX IN LOW MODE
			return
		end
	end
	
	-- Normal VFX for medium/high
	VFXManager.playOrbCollectVFX(pos, RunService:IsClient() and Players.LocalPlayer or nil)
end