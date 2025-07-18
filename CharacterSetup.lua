--[[
ULTRA-SMOOTH & HIGH-PERFORMANCE SLITHER.IO SNAKE SYSTEM V5.1 - LAG FIXED WITH SKIN SYSTEM
- Fixed segment pooling to remove segments from workspace
- Added periodic cleanup for orphaned segments
- Optimized memory management
- ENHANCED: Full skin system integration with proper attribute monitoring
- ENHANCED: Real-time skin changes without breaking movement or performance
- ENHANCED: Automatic skin application on spawn and skin changes
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Helper function to get table keys (moved up to be available)
local function getTableKeys(tbl)
	local keys = {}
	for k, _ in pairs(tbl or {}) do
		table.insert(keys, tostring(k))
	end
	return keys
end

-- ENHANCED: Direct SnakeSkins loading from server module
local SnakeSkins = nil
local function loadSnakeSkins()
	-- Try direct server module first
	local success, result = pcall(function()
		return require(script.Parent:WaitForChild("SnakeSkinsData", 2))
	end)

	if success and result then
		SnakeSkins = result
		print("✅ SnakeSkins loaded directly from server module with", #getTableKeys(result), "skins")
		for name, _ in pairs(result) do
			print("  - Found skin:", name)
		end
		return
	else
		warn("❌ Failed to load SnakeSkinsData:", tostring(result))
	end

	-- Fallback to ReplicatedStorage
	success, result = pcall(function()
		local module = ReplicatedStorage:WaitForChild("SnakeSkins", 2)
		if module then
			return require(module)
		end
	end)

	if success and result then
		SnakeSkins = result
		print("✅ SnakeSkins loaded from ReplicatedStorage")
	else
		warn("❌ Failed to load SnakeSkins from any source")
		SnakeSkins = {}
	end
end

-- Load skins immediately and retry if needed
loadSnakeSkins()
task.spawn(function()
	for i = 1, 5 do
		if SnakeSkins and next(SnakeSkins) then 
			print("✅ SnakeSkins loaded with", #getTableKeys(SnakeSkins), "skins")
			break 
		end
		task.wait(2)
		print("⏳ Retrying SnakeSkins load, attempt", i + 1)
		loadSnakeSkins()
	end
end)

-- Fast aliases
local Vector3new = Vector3.new
local CFramenew = CFrame.new
local CFramelookAt = CFrame.lookAt
local mathMin = math.min
local mathMax = math.max
local mathFloor = math.floor
local taskSpawn = task.spawn
local taskWait = task.wait
