-- LEADERBOARD SERVER SCRIPT
-- Location: ServerScriptService > LeaderboardServer
-- Works with your existing leaderboard UI

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Get the existing RemoteEvent
local LeaderboardUpdated = ReplicatedStorage:WaitForChild("LeaderboardUpdated")

-- Configuration
local UPDATE_INTERVAL = 1 -- Update every second
local lastUpdate = 0

-- Function to collect and send leaderboard data
local function updateLeaderboard()
	local leaderboardData = {}
	
	-- Collect all player scores
	for _, player in pairs(Players:GetPlayers()) do
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local length = leaderstats:FindFirstChild("Length")
			if length then
				table.insert(leaderboardData, {
					Player = player.Name,
					Score = length.Value,
					UserId = player.UserId
				})
			end
		end
	end
	
	-- Sort by score (highest first)
	table.sort(leaderboardData, function(a, b)
		return a.Score > b.Score
	end)
	
	-- Send to all clients
	LeaderboardUpdated:FireAllClients(leaderboardData)
end

-- Update loop
RunService.Heartbeat:Connect(function()
	if tick() - lastUpdate >= UPDATE_INTERVAL then
		lastUpdate = tick()
		updateLeaderboard()
	end
end)

-- Update when players join/leave
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		wait(0.5) -- Wait for snake to initialize
		updateLeaderboard()
	end)
end)

Players.PlayerRemoving:Connect(function()
	updateLeaderboard()
end)

print("✅ Leaderboard Server initialized!")
print("📊 Sending updates every", UPDATE_INTERVAL, "seconds")