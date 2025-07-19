-- OrbGraphicsClient: Handles client-side orb rendering based on graphics mode
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Graphics configurations
local GRAPHICS_CONFIG = {
	Low = {
		material = Enum.Material.SmoothPlastic,
		removeGlow = true,
		hideFarOrbs = true,
		hideDistance = 50,
	},
	Medium = {
		material = Enum.Material.Neon,
		removeGlow = false,
		hideFarOrbs = true,
		hideDistance = 100,
	},
	High = {
		material = Enum.Material.ForceField,
		removeGlow = false,
		hideFarOrbs = false,
		hideDistance = 200,
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
			light:Destroy()
		else
			light.Shadows = false
			light.Brightness = mode == "High" and 2 or 1
			light.Range = mode == "High" and 8 or 4
		end
	end
	
	-- Make orbs more visible without glow in low mode
	if mode == "Low" and orb.Material == Enum.Material.SmoothPlastic then
		orb.Color = orb.Color:Lerp(Color3.new(1,1,1), 0.3)
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
		-- Wait for Value to be added
		task.wait(0.1)
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

-- Hide far orbs based on mode
local lastUpdate = 0
RunService.Heartbeat:Connect(function()
	local now = tick()
	if now - lastUpdate < 0.5 then return end -- Update every 0.5 seconds
	lastUpdate = now
	
	local mode = LocalPlayer:GetAttribute("GraphicsMode") or "High"
	local config = GRAPHICS_CONFIG[mode]
	
	if not config.hideFarOrbs then return end
	
	local character = LocalPlayer.Character
	if not character then return end
	
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end
	
	local playerPos = humanoidRootPart.Position
	
	-- Check distance to all orbs
	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj:IsA("Part") and obj.Name == "Orb" and obj:FindFirstChild("Value") then
			local distance = (obj.Position - playerPos).Magnitude
			
			if distance > config.hideDistance then
				-- Far orb - make more transparent
				obj.Transparency = 0.7
			else
				-- Near orb - normal transparency
				obj.Transparency = 0
			end
		end
	end
end)

-- Initial update
updateAllOrbs()

print("[OrbGraphicsClient] Loaded - Graphics mode support active!")