-- SERVER SCRIPT: SelectSkin RemoteEvent Handler
-- This handles skin changes from the shop UI and applies them to the snake system

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create or get the SelectSkin RemoteEvent
local SelectSkinRemote = ReplicatedStorage:FindFirstChild("SelectSkin")
if not SelectSkinRemote then
	SelectSkinRemote = Instance.new("RemoteEvent")
	SelectSkinRemote.Name = "SelectSkin"
	SelectSkinRemote.Parent = ReplicatedStorage
	print("✅ Created SelectSkin RemoteEvent")
end

-- Create or get the RespawnSnake RemoteEvent (if it doesn't exist)
local RespawnSnakeRemote = ReplicatedStorage:FindFirstChild("RespawnSnake")
if not RespawnSnakeRemote then
	RespawnSnakeRemote = Instance.new("RemoteEvent")
	RespawnSnakeRemote.Name = "RespawnSnake"
	RespawnSnakeRemote.Parent = ReplicatedStorage
	print("✅ Created RespawnSnake RemoteEvent")
end

-- Handle skin selection
SelectSkinRemote.OnServerEvent:Connect(function(player, skinName)
	if not player or type(skinName) ~= "string" then
		print("❌ Invalid SelectSkin request from:", player and player.Name or "unknown")
		return
	end

	print("🎨 Player", player.Name, "selected skin:", skinName)

	-- Set the SelectedSkin attribute
	player:SetAttribute("SelectedSkin", skinName)

	-- If the player has a character, update their snake
	local character = player.Character
	if character then
		-- Check if the player has an active snake in the global system
		if _G.PlayerSnakes and _G.PlayerSnakes[player] then
			local snake = _G.PlayerSnakes[player]
			if snake and snake.cleanup then
				-- Clean up old snake
				print("🔄 Cleaning up old snake for", player.Name)
				snake.cleanup()
			end
		end

		-- Small delay to ensure cleanup is complete
		task.wait(0.1)

		-- Respawn the character to apply the new skin
		print("🔄 Respawning", player.Name, "with new skin:", skinName)
		player:LoadCharacter()
	else
		-- If no character, just set the attribute - the skin will apply when they spawn
		print("✅ Skin", skinName, "set for", player.Name, "- will apply on next spawn")
	end
end)

-- Handle respawn requests
RespawnSnakeRemote.OnServerEvent:Connect(function(player)
	if not player then return end
	print("🔄 Respawning", player.Name)
	player:LoadCharacter()
end)

print("🐍 SelectSkin server handler ready!")
print("🎮 Players can now change skins through the shop!")
