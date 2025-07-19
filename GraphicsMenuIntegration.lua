-- ADD THIS TO YOUR SLITHERIOMENU WHERE THE GRAPHICS BUTTON IS:

-- At the top with other requires:
local SetGraphicsModeEvent = ReplicatedStorage:WaitForChild("SetGraphicsMode")

-- For your graphics button click handler:
-- (Replace YOUR_GRAPHICS_BUTTON with whatever you named it)

local currentMode = localPlayer:GetAttribute("GraphicsMode") or "High"
local modes = {"Low", "Medium", "High"}
local modeIndex = table.find(modes, currentMode) or 3

YOUR_GRAPHICS_BUTTON.MouseButton1Click:Connect(function()
    -- Cycle to next mode
    modeIndex = modeIndex % 3 + 1
    local newMode = modes[modeIndex]
    
    -- Update button text
    YOUR_GRAPHICS_BUTTON.Text = "Graphics: " .. newMode
    
    -- Send to server
    SetGraphicsModeEvent:FireServer(newMode)
    
    -- Optional: Add visual feedback
    local originalColor = YOUR_GRAPHICS_BUTTON.BackgroundColor3
    YOUR_GRAPHICS_BUTTON.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    wait(0.2)
    YOUR_GRAPHICS_BUTTON.BackgroundColor3 = originalColor
end)

-- Update button text on startup
YOUR_GRAPHICS_BUTTON.Text = "Graphics: " .. currentMode

-- Update when attribute changes
localPlayer.AttributeChanged:Connect(function(attr)
    if attr == "GraphicsMode" then
        local mode = localPlayer:GetAttribute("GraphicsMode") or "High"
        YOUR_GRAPHICS_BUTTON.Text = "Graphics: " .. mode
        modeIndex = table.find(modes, mode) or 3
    end
end)