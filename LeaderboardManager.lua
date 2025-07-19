-- LEADERBOARD MANAGER SERVER SCRIPT
-- Location: ServerScriptService > LeaderboardManager

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Create or get the remote event
local LeaderboardUpdated = ReplicatedStorage:FindFirstChild("LeaderboardUpdated")
if not LeaderboardUpdated then
	LeaderboardUpdated = Instance.new("RemoteEvent")
	LeaderboardUpdated.Name = "LeaderboardUpdated"
	LeaderboardUpdated.Parent = ReplicatedStorage
end

-- Store player data
local playerData = {}
local updateInterval = 1 -- Update every second
local lastUpdate = 0

-- Function to get player's snake length
local function getPlayerLength(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local length = leaderstats:FindFirstChild("Length")
		if length then
			return length.Value
		end
	end
	return 0
end

-- Function to update player data
local function updatePlayerData(player)
	local length = getPlayerLength(player)
	playerData[player.Name] = {
		Player = player.Name,
		Score = length,
		UserId = player.UserId
	}
end

-- Function to send leaderboard update to all players
local function broadcastLeaderboard()
	local leaderboardData = {}
	
	-- Collect all player data
	for playerName, data in pairs(playerData) do
		table.insert(leaderboardData, data)
	end
	
	-- Sort by score (descending)
	table.sort(leaderboardData, function(a, b)
		return a.Score > b.Score
	end)
	
	-- Send to all players
	LeaderboardUpdated:FireAllClients(leaderboardData)
end

-- Update loop
RunService.Heartbeat:Connect(function()
	if tick() - lastUpdate >= updateInterval then
		lastUpdate = tick()
		
		-- Update all player data
		for _, player in pairs(Players:GetPlayers()) do
			updatePlayerData(player)
		end
		
		-- Broadcast updated leaderboard
		broadcastLeaderboard()
	end
end)

-- Handle player joining
Players.PlayerAdded:Connect(function(player)
	-- Wait for character and leaderstats
	player.CharacterAdded:Connect(function(character)
		wait(0.5) -- Give time for snake to initialize
		updatePlayerData(player)
		broadcastLeaderboard()
	end)
	
	-- Also listen for length changes
	local leaderstats = player:WaitForChild("leaderstats", 5)
	if leaderstats then
		local length = leaderstats:WaitForChild("Length", 5)
		if length then
			length:GetPropertyChangedSignal("Value"):Connect(function()
				updatePlayerData(player)
				-- Don't broadcast immediately, let the update loop handle it
			end)
		end
	end
end)

-- Handle player leaving
Players.PlayerRemoving:Connect(function(player)
	playerData[player.Name] = nil
	broadcastLeaderboard()
end)

-- Initial broadcast
wait(1)
broadcastLeaderboard()

print("✅ Leaderboard Manager initialized!")