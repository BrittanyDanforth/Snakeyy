-- SERVER SCRIPT: SelectSkin RemoteEvent Handler - FIXED VERSION
-- This handles skin changes from the shop UI and applies them to the snake system
-- FIXED: Prevents skin from reverting to Default by not respawning immediately

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

-- FIXED: Handle skin selection without immediate respawn
SelectSkinRemote.OnServerEvent:Connect(function(player, skinName)
	if not player or type(skinName) ~= "string" then
		print("❌ Invalid SelectSkin request from:", player and player.Name or "unknown")
		return
	end

	print("🎨 Player", player.Name, "selected skin:", skinName)

	-- Set the SelectedSkin attribute
	player:SetAttribute("SelectedSkin", skinName)

	-- FIXED: Update existing snake without respawning
	local character = player.Character
	if character then
		-- Check if the player has an active snake in the global system
		if _G.PlayerSnakes and _G.PlayerSnakes[player] then
			local snake = _G.PlayerSnakes[player]
			if snake and snake.updateSkin then
				-- Update the skin without respawning
				print("🎨 Updating skin for existing snake")
				snake.updateSkin()
				print("✅ Skin", skinName, "applied to", player.Name, "without respawn")
				return -- Don't respawn!
			end
		end

		-- Only respawn if there's no active snake or updateSkin failed
		print("⚠️ No active snake found, will apply skin on next spawn")
	else
		-- If no character, just set the attribute - the skin will apply when they spawn
		print("✅ Skin", skinName, "set for", player.Name, "- will apply on next spawn")
	end
end)

-- Handle respawn requests (kept separate for when actual respawn is needed)
RespawnSnakeRemote.OnServerEvent:Connect(function(player)
	if not player then return end
	print("🔄 Respawning", player.Name)
	player:LoadCharacter()
end)

print("🐍 SelectSkin server handler ready! (Fixed version)")
print("🎮 Players can now change skins without respawning!")
print("✅ This prevents the skin revert issue")
