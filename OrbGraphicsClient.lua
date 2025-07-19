-- OrbGraphicsClient: Put this LocalScript in StarterPlayer > StarterPlayerScripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- Wait for character
LocalPlayer.CharacterAdded:Wait()

-- Graphics configurations
local GRAPHICS_CONFIG = {
	Low = {
		material = Enum.Material.SmoothPlastic,
		removeGlow = true,
		maxDistance = 80,  -- Only close orbs show
		transparency = 0,
	},
	Medium = {
		material = Enum.Material.Neon,
		removeGlow = true,  -- NO GLOW in medium
		maxDistance = 120,  -- Medium view distance
		transparency = 0,
	},
	High = {
		material = Enum.Material.Neon,  -- Keep default neon, NOT ForceField
		removeGlow = false,  -- Full glow
		maxDistance = 200,  -- Orbs show farther
		transparency = 0,
	}
}

-- Apply graphics settings to an orb
local function applyGraphicsToOrb(orb, mode)
	local config = GRAPHICS_CONFIG[mode] or GRAPHICS_CONFIG.High
	
	-- Update material
	orb.Material = config.material
	orb.CastShadow = mode == "High"
	
	-- Handle glow
	local light = orb:FindFirstChild("PointLight")
	if light then
		if config.removeGlow then
			light.Enabled = false
			light.Brightness = 0
		else
			light.Enabled = true
			light.Shadows = false
			light.Brightness = mode == "High" and 2 or 1
			light.Range = mode == "High" and 8 or 4
		end
	end
	
	-- Make orbs brighter in low mode for visibility
	if mode == "Low" then
		local originalColor = orb:GetAttribute("OriginalColor")
		if not originalColor then
			orb:SetAttribute("OriginalColor", orb.Color)
			originalColor = orb.Color
		end
		orb.Color = originalColor:Lerp(Color3.new(1,1,1), 0.4)
	else
		local originalColor = orb:GetAttribute("OriginalColor")
		if originalColor then
			orb.Color = originalColor
		end
	end
end

-- Update all orbs when graphics mode changes
local function updateAllOrbs()
	local mode = LocalPlayer:GetAttribute("GraphicsMode") or "High"
	print("[OrbGraphicsClient] Updating all orbs to", mode, "mode")
	
	-- Find all orbs in workspace
	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj:IsA("Part") and obj.Name == "Orb" and obj:FindFirstChild("Value") then
			applyGraphicsToOrb(obj, mode)
		end
	end
end

-- Watch for new orbs
Workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("Part") and obj.Name == "Orb" then
		-- Wait a frame for Value to be added
		RunService.Heartbeat:Wait()
		if obj:FindFirstChild("Value") then
			local mode = LocalPlayer:GetAttribute("GraphicsMode") or "High"
			applyGraphicsToOrb(obj, mode)
		end
	end
end)

-- Update when graphics mode changes
LocalPlayer.AttributeChanged:Connect(function(attr)
	if attr == "GraphicsMode" then
		updateAllOrbs()
	end
end)

-- Distance-based hiding for performance
local lastUpdate = 0
RunService.Heartbeat:Connect(function()
	local now = tick()
	if now - lastUpdate < 0.2 then return end -- Update 5 times per second
	lastUpdate = now
	
	local mode = LocalPlayer:GetAttribute("GraphicsMode") or "High"
	local config = GRAPHICS_CONFIG[mode]
	
	local character = LocalPlayer.Character
	if not character then return end
	
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
	if not humanoidRootPart then return end
	
	local playerPos = humanoidRootPart.Position
	
	-- Check distance to all orbs
	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj:IsA("Part") and obj.Name == "Orb" and obj:FindFirstChild("Value") then
			local distance = (obj.Position - playerPos).Magnitude
			
			if distance > config.maxDistance then
				-- Far orb - COMPLETELY HIDE IT
				obj.Transparency = 1
				obj.Size = Vector3.new(0.1, 0.1, 0.1) -- Make tiny too
				local light = obj:FindFirstChild("PointLight")
				if light then 
					light.Enabled = false 
					light.Brightness = 0
				end
			else
				-- Near orb - show it normally
				obj.Transparency = config.transparency
				
				-- Restore normal size if it was hidden
				local value = obj:FindFirstChild("Value")
				if value and obj.Size.X < 1 then
					-- Restore to normal orb size based on value
					local baseSize = math.clamp(value.Value / 10, 0.5, 2)
					obj.Size = Vector3.new(baseSize, baseSize, baseSize)
				end
				
				local light = obj:FindFirstChild("PointLight")
				if light then
					if config.removeGlow then
						light.Enabled = false
						light.Brightness = 0
					else
						light.Enabled = true
						light.Brightness = 2
						light.Range = 8
					end
				end
			end
		end
	end
end)

-- Initial update after a short delay
task.wait(1)
updateAllOrbs()

print("[OrbGraphicsClient] Loaded - Graphics mode support active!")