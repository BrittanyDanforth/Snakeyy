-- SMOOTH SLITHER.IO MOVEMENT REVAMP FOR CHARACTERSETUP
-- Replace the heartbeat connection (around line 655) with this:

local heartbeatConn
heartbeatConn = RunService.Heartbeat:Connect(function(dt)
	if not isActive or not rootPart.Parent then return end

	updateCounter = updateCounter + 1
	
	-- Get current state
	local isBoosting = humanoid.WalkSpeed > 16.1
	local currentPos = rootPart.Position
	local currentCFrame = rootPart.CFrame
	local lookVector = currentCFrame.LookVector
	
	-- SMOOTH HEAD POSITIONING
	local headOffset = lookVector * 2.5 -- Slightly ahead of root
	local headPos = currentPos + headOffset + Vector3.new(0, 0.5, 0) -- Slight lift
	
	if headParts.head and headParts.head.Parent then
		-- Smooth head rotation
		local targetCFrame = CFrame.lookAt(headPos, headPos + lookVector)
		headParts.head.CFrame = headParts.head.CFrame:Lerp(targetCFrame, 0.8)
	end
	
	-- IMPROVED POSITION TRACKING
	-- Only add to history if we've moved enough
	local lastPoint = positionHistory[1] or {position = currentPos, lookVector = lookVector}
	local moveDist = (currentPos - lastPoint.position).Magnitude
	
	if moveDist > 0.1 then -- Minimum movement threshold
		-- Add position to history
		table.insert(positionHistory, 1, {
			position = currentPos,
			lookVector = lookVector,
			time = tick()
		})
		
		-- Limit history size
		if #positionHistory > currentLength * 3 then
			table.remove(positionHistory)
		end
	end
	
	-- SMOOTH SEGMENT FOLLOWING
	for i = 1, currentLength do
		local segment = segments[i]
		if segment and segment.Parent then
			-- Calculate target position based on smooth curve
			local baseDelay = i * 1.8 -- Increased for less bunching
			local historyIndex = math.min(math.floor(baseDelay), #positionHistory)
			
			if positionHistory[historyIndex] then
				local targetData = positionHistory[historyIndex]
				
				-- Calculate ideal position with proper spacing
				local idealSpacing = activeConfig.SegmentSpacing
				local prevSegPos = (i == 1) and headPos or segments[i-1].Position
				
				-- Direction from previous segment
				local toPrev = (prevSegPos - segment.Position).Unit
				if toPrev.Magnitude > 0 then
					-- Target position maintains spacing
					local targetPos = prevSegPos - toPrev * idealSpacing
					
					-- Blend with history position for smooth curves
					local historyPos = targetData.position
					local blendedPos = targetPos:Lerp(historyPos, 0.3)
					
					-- Smooth movement with different speeds for boost/normal
					local moveSpeed = isBoosting and 0.95 or 0.85
					segment.Position = segment.Position:Lerp(blendedPos, moveSpeed)
					
					-- Face direction of movement
					if i < currentLength then
						local nextSeg = segments[i + 1]
						if nextSeg and nextSeg.Parent then
							segment.CFrame = CFrame.lookAt(segment.Position, nextSeg.Position)
						end
					end
				else
					-- Fallback to history position
					segment.Position = segment.Position:Lerp(targetData.position, 0.7)
				end
			end
		end
	end
	
	-- VFX and other updates...
	-- (Keep the rest of the function as is)
end)

-- ADDITIONAL IMPROVEMENTS:

-- 1. Better segment spacing calculation
local function maintainSegmentSpacing()
	for i = 2, currentLength do
		local segment = segments[i]
		local prevSegment = segments[i-1]
		
		if segment and prevSegment and segment.Parent and prevSegment.Parent then
			local distance = (segment.Position - prevSegment.Position).Magnitude
			
			-- If too close, push apart
			if distance < activeConfig.SegmentSpacing * 0.8 then
				local direction = (segment.Position - prevSegment.Position).Unit
				if direction.Magnitude > 0 then
					segment.Position = prevSegment.Position + direction * activeConfig.SegmentSpacing
				end
			end
		end
	end
end

-- 2. Smooth turning for less choppy movement
local function smoothTurning(lookVector, targetLookVector, smoothness)
	return lookVector:Lerp(targetLookVector, smoothness).Unit
end

-- 3. Anti-gap algorithm
local function preventGaps()
	for i = 1, currentLength - 1 do
		local segment = segments[i]
		local nextSegment = segments[i + 1]
		
		if segment and nextSegment and segment.Parent and nextSegment.Parent then
			local gap = (nextSegment.Position - segment.Position).Magnitude
			
			-- If gap is too large, interpolate
			if gap > activeConfig.SegmentSpacing * 1.5 then
				local midPoint = segment.Position:Lerp(nextSegment.Position, 0.5)
				nextSegment.Position = nextSegment.Position:Lerp(midPoint, 0.3)
			end
		end
	end
end