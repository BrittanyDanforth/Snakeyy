-- Put this in ServerScriptService to create the RemoteEvent
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create SetGraphicsMode event if it doesn't exist
if not ReplicatedStorage:FindFirstChild("SetGraphicsMode") then
	local event = Instance.new("RemoteEvent")
	event.Name = "SetGraphicsMode"
	event.Parent = ReplicatedStorage
	print("Created SetGraphicsMode RemoteEvent")
end

-- Handle graphics mode changes from clients
local SetGraphicsModeEvent = ReplicatedStorage:WaitForChild("SetGraphicsMode")
SetGraphicsModeEvent.OnServerEvent:Connect(function(player, mode)
	-- Validate the mode
	if mode == "Low" or mode == "Medium" or mode == "High" then
		player:SetAttribute("GraphicsMode", mode)
		print(player.Name .. " changed graphics mode to: " .. mode)
	end
end)