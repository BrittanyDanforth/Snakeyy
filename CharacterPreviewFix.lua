-- FIXED CHARACTER PREVIEW - CONSISTENT RENDERING
-- This version will look the same on all PCs regardless of FPS

local RunService = game:GetService("RunService")

-- Create a fixed preview update
local function fixCharacterPreview()
	-- Find the CharacterPreview module
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local CharacterPreview = require(ReplicatedStorage:WaitForChild("CharacterPreview"))
	
	-- Store the original startAnimations function
	local originalStartAnimations = CharacterPreview.startAnimations
	
	-- Override with FPS-independent version
	CharacterPreview.startAnimations = function(self)
		-- Disconnect any existing connection
		if self.animationConnection then
			self.animationConnection:Disconnect()
		end
		
		local targetFPS = 60 -- Target 60 FPS for calculations
		local accumulator = 0
		
		-- Main update loop with delta time compensation
		self.animationConnection = RunService.Heartbeat:Connect(function(dt)
			-- Accumulate time for consistent updates
			accumulator = accumulator + dt
			
			-- Fixed timestep updates
			while accumulator >= 1/targetFPS do
				accumulator = accumulator - 1/targetFPS
				local fixedDt = 1/targetFPS
				
				self.time = self.time + fixedDt
				
				-- Animate head movement
				local headAngle = self.time * 0.8 -- PREVIEW_CONFIG.MOVEMENT_SPEED
				local figure8 = math.sin(headAngle * 2)
				self.head.Position = Vector3.new(
					math.cos(headAngle) * 30 * (1 + figure8 * 0.3),
					10 + math.sin(headAngle * 2) * 5,
					math.sin(headAngle) * 30 * (1 - figure8 * 0.3)
				)
				
				-- Update position history
				table.insert(self.positionHistory, 1, self.head.Position)
				if #self.positionHistory > 55 then
					table.remove(self.positionHistory)
				end
			end
			
			-- Visual updates (can happen every frame)
			-- Update eyes
			for _, eyeData in ipairs(self.eyes) do
				local eye = eyeData.eye
				local pupil = eyeData.pupil
				
				local headLookDir = Vector3.new(0, 0, -1)
				if #self.positionHistory > 2 then
					local velocity = (self.head.Position - self.positionHistory[3])
					if velocity.Magnitude > 0.1 then
						headLookDir = velocity.Unit
					end
				end
				
				local rightVector = headLookDir:Cross(Vector3.new(0, 1, 0)).Unit
				local upVector = rightVector:Cross(headLookDir).Unit
				local headCFrame = CFrame.fromMatrix(self.head.Position, rightVector, upVector, -headLookDir)
				
				eye.CFrame = headCFrame * CFrame.new(eyeData.offsetX, 1.5, -3.5)
				pupil.CFrame = eye.CFrame * CFrame.new(0, 0, -0.5)
			end
			
			-- FIXED segment animation with consistent speed
			for i, segment in ipairs(self.segments) do
				local historyIndex = math.floor(i * 1.1) + 1
				if self.positionHistory[historyIndex] then
					local segmentWave = math.sin(self.time * 2 + i * 0.2) * 0.5
					local targetPos = self.positionHistory[historyIndex] + Vector3.new(0, segmentWave, 0)
					
					-- Use fixed lerp speed that accounts for varying framerates
					local lerpSpeed = 1 - math.exp(-10 * dt) -- This gives consistent speed regardless of FPS
					segment.Position = segment.Position:Lerp(targetPos, lerpSpeed)
				end
			end
			
			-- Camera updates
			local cameraAngle = self.time * 0.3
			local snakeCenter = Vector3.new(0, 10, 0)
			
			local cameraX = math.sin(cameraAngle) * 100
			local cameraZ = math.cos(cameraAngle) * 70
			local cameraY = 30 + math.sin(cameraAngle * 2) * 10
			
			local cameraPos = snakeCenter + Vector3.new(cameraX, cameraY, cameraZ)
			self.camera.CFrame = CFrame.lookAt(cameraPos, snakeCenter)
		end)
		
		table.insert(self.connections, self.animationConnection)
	end
end

-- Apply the fix when this script runs
fixCharacterPreview()

return fixCharacterPreview