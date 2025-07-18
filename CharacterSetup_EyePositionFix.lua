-- FIX FOR CHARACTERSETUP EYE POSITIONING
-- The issue: Eyes are positioned at fixed coordinates regardless of head size
-- This fix scales eye positions based on the actual head size

-- In CharacterSetup.lua, find the createHead function around line 300-400
-- Replace the eye creation lines (around line 377-378) with:

-- Calculate eye positions based on head size
local headScale = config.HeadSize.X / 3 -- 3 is the default head size
local eyeX = 0.6 * headScale -- Scale X position
local eyeY = 0.55 * headScale -- Scale Y position
local eyeZ = 0.8 * headScale -- Scale Z position

local leftEye, leftEyeWeld = createEye("LeftEye", Vector3new(-eyeX, eyeY, eyeZ), headPart)
local rightEye, rightEyeWeld = createEye("RightEye", Vector3new(eyeX, eyeY, eyeZ), headPart)

-- ALTERNATIVE FIX: Normalize all skin head sizes
-- If you don't want to modify CharacterSetup, you can fix the skin data instead
-- Change all skins with HeadSize = 3.5 back to 3.0:

local skinsToFix = {
	["Dragon Lord"] = true,
	["Frost Serpent"] = true,
	["Blood Moon"] = true,
	["Gamma Burst"] = true,
	-- Add any other skins with 3.5 head size
}

-- In SnakeSkinsData.lua, change these skins to:
-- HeadSize = Vector3.new(3, 3, 3),
-- SegmentSize = Vector3.new(2.5, 2.5, 2.5),