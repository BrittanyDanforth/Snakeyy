-- ENHANCED LEADERBOARD UI - SLITHER.IO STYLE
-- Location: StarterPlayer > StarterPlayerScripts > EnhancedLeaderboard
-- Supports 13 players max with sick top 3 effects

-- Services
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

-- Hide default playerlist
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

-- Local Player
local localPlayer = Players.LocalPlayer

-- Mobile detection
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Performance settings
local UPDATE_INTERVAL = 0.5 -- Faster updates for competitive feel
local MAX_PLAYERS = 13 -- Server max
local lastUpdateTime = 0

-- Helper function
local function create(instanceType, properties)
	local inst = Instance.new(instanceType)
	for prop, value in properties do
		inst[prop] = value
	end
	return inst
end

-- Main GUI
local leaderboardGui = create("ScreenGui", {
	Name = "SlitherLeaderboard",
	Parent = localPlayer:WaitForChild("PlayerGui"),
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
})

-- Get safe area
local topBarHeight = GuiService:GetGuiInset()

-- Main container with glass effect
local container = create("Frame", {
	Name = "Container",
	Parent = leaderboardGui,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -15, 0, topBarHeight.Y + 10),
	Size = UDim2.new(0, 320, 0, 550), -- Taller for 13 players
	BackgroundColor3 = Color3.fromRGB(15, 15, 25),
	BackgroundTransparency = 0.1,
	BorderSizePixel = 0,
})

-- Glass effect
create("UICorner", { Parent = container, CornerRadius = UDim.new(0, 16) })
local containerStroke = create("UIStroke", { 
	Parent = container, 
	Color = Color3.fromRGB(255, 255, 255), 
	Transparency = 0.9, 
	Thickness = 1 
})

-- Gradient background
local bgGradient = create("UIGradient", {
	Parent = container,
	Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 40)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
	},
	Rotation = 90
})

-- Header with glow
local header = create("Frame", {
	Name = "Header",
	Parent = container,
	Size = UDim2.new(1, 0, 0, 60),
	BackgroundColor3 = Color3.fromRGB(20, 20, 35),
	BorderSizePixel = 0,
})

create("UICorner", { Parent = header, CornerRadius = UDim.new(0, 16) })

-- Fix bottom corners
local headerFix = create("Frame", {
	Parent = header,
	Size = UDim2.new(1, 0, 0, 20),
	Position = UDim2.new(0, 0, 1, -20),
	BackgroundColor3 = Color3.fromRGB(20, 20, 35),
	BorderSizePixel = 0,
})

-- Animated title
local title = create("TextLabel", {
	Name = "Title",
	Parent = header,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	Font = Enum.Font.FredokaOne,
	Text = "🏆 LEADERBOARD",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextSize = 24,
	TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
	TextStrokeTransparency = 0.5,
})

-- Content area
local content = create("ScrollingFrame", {
	Name = "Content",
	Parent = container,
	Position = UDim2.new(0, 10, 0, 70),
	Size = UDim2.new(1, -20, 1, -80),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 4,
	ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255),
	ScrollBarImageTransparency = 0.5,
	CanvasSize = UDim2.new(0, 0, 0, 0),
})

create("UIListLayout", {
	Parent = content,
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 6),
})

-- Player entry template
local function createPlayerEntry(rank, playerName, score, isLocal)
	local entry = create("Frame", {
		Name = "Entry_" .. playerName,
		Size = UDim2.new(1, -8, 0, 36),
		BackgroundColor3 = Color3.fromRGB(25, 25, 40),
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
	})
	
	create("UICorner", { Parent = entry, CornerRadius = UDim.new(0, 10) })
	
	-- Special effects for top 3
	if rank <= 3 then
		local glowStroke = create("UIStroke", {
			Parent = entry,
			Thickness = 2,
			Transparency = 0.3,
		})
		
		-- Animated glow colors
		if rank == 1 then
			-- GOLD CHAMPION
			entry.BackgroundColor3 = Color3.fromRGB(50, 40, 20)
			glowStroke.Color = Color3.fromRGB(255, 215, 0)
			
			-- Sparkle effect
			spawn(function()
				while entry.Parent do
					glowStroke.Transparency = 0.2 + math.sin(tick() * 3) * 0.3
					wait()
				end
			end)
			
		elseif rank == 2 then
			-- SILVER
			entry.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
			glowStroke.Color = Color3.fromRGB(192, 192, 192)
			glowStroke.Transparency = 0.4
			
		elseif rank == 3 then
			-- BRONZE
			entry.BackgroundColor3 = Color3.fromRGB(40, 30, 25)
			glowStroke.Color = Color3.fromRGB(205, 127, 50)
			glowStroke.Transparency = 0.5
		end
	end
	
	-- Highlight local player
	if isLocal then
		local localStroke = create("UIStroke", {
			Parent = entry,
			Color = Color3.fromRGB(100, 200, 255),
			Thickness = 2,
			Transparency = 0.5,
		})
		entry.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
	end
	
	-- Rank display
	local rankLabel = create("TextLabel", {
		Name = "Rank",
		Parent = entry,
		Size = UDim2.new(0, 40, 1, 0),
		Position = UDim2.new(0, 5, 0, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.FredokaOne,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 18,
		TextStrokeTransparency = 0.5,
		TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
	})
	
	-- Special rank displays
	if rank == 1 then
		rankLabel.Text = "👑"
		rankLabel.TextSize = 24
	elseif rank == 2 then
		rankLabel.Text = "🥈"
		rankLabel.TextSize = 22
	elseif rank == 3 then
		rankLabel.Text = "🥉"
		rankLabel.TextSize = 20
	else
		rankLabel.Text = "#" .. rank
		rankLabel.Font = Enum.Font.GothamBold
		rankLabel.TextSize = 16
		rankLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	end
	
	-- Player name
	local nameLabel = create("TextLabel", {
		Name = "PlayerName",
		Parent = entry,
		Size = UDim2.new(0.5, -50, 1, 0),
		Position = UDim2.new(0, 50, 0, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = playerName,
		TextColor3 = rank <= 3 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200),
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	
	-- Score with snake emoji
	local scoreLabel = create("TextLabel", {
		Name = "Score",
		Parent = entry,
		Size = UDim2.new(0.5, -10, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = tostring(score) .. " 🐍",
		TextColor3 = rank <= 3 and Color3.fromRGB(255, 220, 100) or Color3.fromRGB(150, 255, 150),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Right,
	})
	
	return entry
end

-- Player entries storage
local playerEntries = {}

-- Optimized update function
local function updateLeaderboard()
	local currentTime = tick()
	if currentTime - lastUpdateTime < UPDATE_INTERVAL then return end
	lastUpdateTime = currentTime
	
	-- Collect all players
	local playersData = {}
	for _, player in pairs(Players:GetPlayers()) do
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local length = leaderstats:FindFirstChild("Length")
			if length then
				table.insert(playersData, {
					player = player,
					name = player.Name,
					score = length.Value or 0
				})
			end
		end
	end
	
	-- Sort by score
	table.sort(playersData, function(a, b)
		return a.score > b.score
	end)
	
	-- Clear old entries
	for _, entry in pairs(playerEntries) do
		entry:Destroy()
	end
	playerEntries = {}
	
	-- Create entries for all players (up to 13)
	for i = 1, math.min(#playersData, MAX_PLAYERS) do
		local data = playersData[i]
		local isLocal = data.player == localPlayer
		local entry = createPlayerEntry(i, data.name, data.score, isLocal)
		entry.LayoutOrder = i
		entry.Parent = content
		
		-- Animate entry appearance
		entry.Position = UDim2.new(1, 0, 0, 0)
		entry:TweenPosition(
			UDim2.new(0, 0, 0, 0),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Back,
			0.3 + (i * 0.02),
			true
		)
		
		table.insert(playerEntries, entry)
	end
	
	-- Update canvas size
	content.CanvasSize = UDim2.new(0, 0, 0, #playerEntries * 42)
end

-- Animate title
spawn(function()
	while leaderboardGui.Parent do
		for i = 0, 1, 0.01 do
			title.TextColor3 = Color3.fromRGB(255, 255, 255):Lerp(Color3.fromRGB(255, 220, 100), math.sin(i * math.pi * 2) * 0.5 + 0.5)
			wait(0.03)
		end
	end
end)

-- Update loop
RunService.Heartbeat:Connect(updateLeaderboard)

-- Initial update
updateLeaderboard()

-- Fade in animation
container.Position = UDim2.new(1, 100, 0, topBarHeight.Y + 10)
container:TweenPosition(
	UDim2.new(1, -15, 0, topBarHeight.Y + 10),
	Enum.EasingDirection.Out,
	Enum.EasingStyle.Back,
	0.5,
	true
)

print("🎮 Enhanced Slither.io Leaderboard Loaded!")
print("👑 Top 3 with special effects!")
print("🐍 Supports up to 13 players!")