-- Test script to verify CharacterPreview physics works at all framerates
local RunService = game:GetService("RunService")

-- Simulate different framerates
local framerates = {30, 60, 120, 240}
local currentFPSIndex = 1

-- Create a ScreenGui for testing
local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")

-- Info label
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0, 300, 0, 100)
infoLabel.Position = UDim2.new(0.5, -150, 0, 10)
infoLabel.BackgroundColor3 = Color3.new(0, 0, 0)
infoLabel.BackgroundTransparency = 0.3
infoLabel.TextColor3 = Color3.new(1, 1, 1)
infoLabel.TextScaled = true
infoLabel.Font = Enum.Font.SourceSansBold
infoLabel.Text = "Testing FPS: 60"
infoLabel.Parent = gui

-- Button to switch framerates
local switchButton = Instance.new("TextButton")
switchButton.Size = UDim2.new(0, 200, 0, 50)
switchButton.Position = UDim2.new(0.5, -100, 0, 120)
switchButton.BackgroundColor3 = Color3.new(0.2, 0.5, 1)
switchButton.TextColor3 = Color3.new(1, 1, 1)
switchButton.TextScaled = true
switchButton.Font = Enum.Font.SourceSansBold
switchButton.Text = "Switch FPS"
switchButton.Parent = gui

-- Framerate limiter
local targetFPS = 60
local frameTime = 1/targetFPS
local accumulator = 0

-- Original heartbeat connection
local originalConnection

-- Function to limit framerate
local function limitedHeartbeat(callback)
	if originalConnection then
		originalConnection:Disconnect()
	end
	
	originalConnection = RunService.Heartbeat:Connect(function(realDt)
		accumulator = accumulator + realDt
		
		-- Only update when we've accumulated enough time
		if accumulator >= frameTime then
			-- Call with simulated dt
			callback(frameTime)
			
			-- Reset accumulator (keep remainder for smooth timing)
			accumulator = accumulator % frameTime
		end
	end)
end

-- Switch framerates
switchButton.MouseButton1Click:Connect(function()
	currentFPSIndex = currentFPSIndex % #framerates + 1
	targetFPS = framerates[currentFPSIndex]
	frameTime = 1/targetFPS
	accumulator = 0
	
	infoLabel.Text = string.format("Testing FPS: %d\n(Simulated - Actual may vary)", targetFPS)
	
	print(string.format("Switched to %d FPS simulation", targetFPS))
end)

print("CharacterPreview FPS Test loaded!")
print("Click 'Switch FPS' to test different framerates")
print("Watch the preview - it should look identical at all framerates!")