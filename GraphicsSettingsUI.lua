-- Graphics Settings UI - Place in StarterPlayerScripts
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Get RemoteEvent
local SetGraphicsModeEvent = ReplicatedStorage:WaitForChild("SetGraphicsMode")

-- Create UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GraphicsSettings"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main button
local settingsButton = Instance.new("TextButton")
settingsButton.Name = "SettingsButton"
settingsButton.Size = UDim2.new(0, 40, 0, 40)
settingsButton.Position = UDim2.new(1, -50, 0, 10)
settingsButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
settingsButton.Text = "⚙️"
settingsButton.TextScaled = true
settingsButton.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = settingsButton

-- Settings panel
local settingsPanel = Instance.new("Frame")
settingsPanel.Name = "SettingsPanel"
settingsPanel.Size = UDim2.new(0, 200, 0, 150)
settingsPanel.Position = UDim2.new(1, -210, 0, 10)
settingsPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
settingsPanel.Visible = false
settingsPanel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 12)
panelCorner.Parent = settingsPanel

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Graphics Settings"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Parent = settingsPanel

-- Graphics mode buttons
local modes = {"Low", "Medium", "High"}
local currentMode = player:GetAttribute("GraphicsMode") or "High"

for i, mode in ipairs(modes) do
	local button = Instance.new("TextButton")
	button.Name = mode .. "Button"
	button.Size = UDim2.new(0.8, 0, 0, 30)
	button.Position = UDim2.new(0.1, 0, 0, 30 + (i * 35))
	button.BackgroundColor3 = currentMode == mode and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
	button.Text = mode
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextScaled = true
	button.Font = Enum.Font.SourceSans
	button.Parent = settingsPanel
	
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 6)
	buttonCorner.Parent = button
	
	button.MouseButton1Click:Connect(function()
		-- Update UI
		for _, btn in pairs(settingsPanel:GetChildren()) do
			if btn:IsA("TextButton") and btn.Name:match("Button$") then
				btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			end
		end
		button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		
		-- Send to server
		SetGraphicsModeEvent:FireServer(mode)
		currentMode = mode
		
		-- Show confirmation
		button.Text = mode .. " ✓"
		wait(1)
		button.Text = mode
	end)
end

-- Toggle panel
local panelOpen = false
settingsButton.MouseButton1Click:Connect(function()
	panelOpen = not panelOpen
	settingsPanel.Visible = panelOpen
	
	if panelOpen then
		settingsPanel.Position = UDim2.new(1, -210, 0, -150)
		local tween = TweenService:Create(settingsPanel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, -210, 0, 10)
		})
		tween:Play()
	end
end)

-- Update button colors when attribute changes
player.AttributeChanged:Connect(function(attr)
	if attr == "GraphicsMode" then
		local newMode = player:GetAttribute("GraphicsMode") or "High"
		for _, btn in pairs(settingsPanel:GetChildren()) do
			if btn:IsA("TextButton") and btn.Name:match("Button$") then
				local btnMode = btn.Name:gsub("Button", "")
				btn.BackgroundColor3 = btnMode == newMode and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
			end
		end
	end
end)

print("Graphics Settings UI loaded - Click the gear icon to change graphics mode!")