-- LEADERBOARD UI CLIENT SCRIPT
-- Location: StarterPlayer > StarterPlayerScripts > LeaderboardUI

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for the remote event
local LeaderboardUpdated = ReplicatedStorage:WaitForChild("LeaderboardUpdated")

-- Create the leaderboard GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LeaderboardGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main leaderboard frame
local leaderboardFrame = Instance.new("Frame")
leaderboardFrame.Name = "LeaderboardFrame"
leaderboardFrame.Size = UDim2.new(0, 300, 0, 400)
leaderboardFrame.Position = UDim2.new(1, -20, 0, 20) -- Top right corner
leaderboardFrame.AnchorPoint = Vector2.new(1, 0)
leaderboardFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
leaderboardFrame.BackgroundTransparency = 0.1
leaderboardFrame.BorderSizePixel = 0
leaderboardFrame.Parent = screenGui

-- Add gradient for style
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 50)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
}
gradient.Rotation = 90
gradient.Parent = leaderboardFrame

-- Add corner rounding
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = leaderboardFrame

-- Add shadow/stroke
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(60, 60, 80)
stroke.Thickness = 2
stroke.Transparency = 0.5
stroke.Parent = leaderboardFrame

-- Title
local titleFrame = Instance.new("Frame")
titleFrame.Name = "TitleFrame"
titleFrame.Size = UDim2.new(1, 0, 0, 50)
titleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
titleFrame.BackgroundTransparency = 0.3
titleFrame.BorderSizePixel = 0
titleFrame.Parent = leaderboardFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleFrame

-- Fix title corner (only round top)
local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 12)
titleFix.Position = UDim2.new(0, 0, 1, -12)
titleFix.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
titleFix.BackgroundTransparency = 0.3
titleFix.BorderSizePixel = 0
titleFix.Parent = titleFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🏆 LEADERBOARD"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = titleFrame

-- Create scrolling frame for entries
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "LeaderboardScroll"
scrollFrame.Size = UDim2.new(1, -10, 1, -60)
scrollFrame.Position = UDim2.new(0, 5, 0, 55)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = leaderboardFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = scrollFrame

-- Store player entries
local playerEntries = {}

-- Function to create a player entry
local function createPlayerEntry(rank, playerName, score, isLocalPlayer)
	local entryFrame = Instance.new("Frame")
	entryFrame.Name = "Entry_" .. playerName
	entryFrame.Size = UDim2.new(1, -10, 0, 40)
	entryFrame.BackgroundColor3 = isLocalPlayer and Color3.fromRGB(80, 120, 200) or Color3.fromRGB(45, 45, 60)
	entryFrame.BackgroundTransparency = isLocalPlayer and 0.2 or 0.5
	entryFrame.BorderSizePixel = 0
	
	local entryCorner = Instance.new("UICorner")
	entryCorner.CornerRadius = UDim.new(0, 8)
	entryCorner.Parent = entryFrame
	
	-- Add glow for local player
	if isLocalPlayer then
		local glow = Instance.new("UIStroke")
		glow.Color = Color3.fromRGB(100, 150, 255)
		glow.Thickness = 2
		glow.Transparency = 0.3
		glow.Parent = entryFrame
	end
	
	-- Rank label
	local rankLabel = Instance.new("TextLabel")
	rankLabel.Name = "Rank"
	rankLabel.Size = UDim2.new(0, 40, 1, 0)
	rankLabel.Position = UDim2.new(0, 5, 0, 0)
	rankLabel.BackgroundTransparency = 1
	rankLabel.Text = "#" .. rank
	rankLabel.TextColor3 = rank <= 3 and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(200, 200, 200)
	rankLabel.TextScaled = true
	rankLabel.Font = Enum.Font.SourceSansBold
	rankLabel.Parent = entryFrame
	
	-- Add crown emoji for top 3
	if rank == 1 then
		rankLabel.Text = "👑"
	elseif rank == 2 then
		rankLabel.Text = "🥈"
	elseif rank == 3 then
		rankLabel.Text = "🥉"
	end
	
	-- Player name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "PlayerName"
	nameLabel.Size = UDim2.new(0.5, -50, 1, 0)
	nameLabel.Position = UDim2.new(0, 50, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = playerName
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.SourceSans
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = entryFrame
	
	-- Score/Length
	local scoreLabel = Instance.new("TextLabel")
	scoreLabel.Name = "Score"
	scoreLabel.Size = UDim2.new(0.5, -10, 1, 0)
	scoreLabel.Position = UDim2.new(0.5, 0, 0, 0)
	scoreLabel.BackgroundTransparency = 1
	scoreLabel.Text = tostring(score) .. " 🐍"
	scoreLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
	scoreLabel.TextScaled = true
	scoreLabel.Font = Enum.Font.SourceSansBold
	scoreLabel.TextXAlignment = Enum.TextXAlignment.Right
	scoreLabel.Parent = entryFrame
	
	return entryFrame
end

-- Function to update leaderboard
local function updateLeaderboard(leaderboardData)
	-- Clear old entries
	for _, entry in pairs(playerEntries) do
		entry:Destroy()
	end
	playerEntries = {}
	
	-- Sort by score
	table.sort(leaderboardData, function(a, b)
		return a.Score > b.Score
	end)
	
	-- Create new entries
	for i, data in ipairs(leaderboardData) do
		if i <= 10 then -- Show top 10
			local isLocalPlayer = data.Player == player.Name
			local entry = createPlayerEntry(i, data.Player, data.Score, isLocalPlayer)
			entry.LayoutOrder = i
			entry.Parent = scrollFrame
			table.insert(playerEntries, entry)
			
			-- Animate entry appearance
			entry.Position = UDim2.new(1, 0, 0, 0)
			entry:TweenPosition(
				UDim2.new(0, 5, 0, 0),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quart,
				0.3 + (i * 0.05),
				true
			)
		end
	end
	
	-- Update canvas size
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end

-- Connect to remote event
LeaderboardUpdated.OnClientEvent:Connect(updateLeaderboard)

-- Add smooth fade in
leaderboardFrame.Position = UDim2.new(1, 100, 0, 20)
leaderboardFrame:TweenPosition(
	UDim2.new(1, -20, 0, 20),
	Enum.EasingDirection.Out,
	Enum.EasingStyle.Quart,
	0.5,
	true
)

-- Optional: Add a glow/pulse effect to the title
local titleGlow = Instance.new("PointLight")
spawn(function()
	while true do
		for i = 0, 1, 0.01 do
			titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255):Lerp(Color3.fromRGB(255, 220, 100), math.sin(i * math.pi))
			wait(0.03)
		end
	end
end)