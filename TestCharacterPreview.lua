-- Test script for the new CharacterPreview module
local CharacterPreview = require(script.Parent:WaitForChild("CharacterPreview"))

-- Create a test viewport
local testViewport = Instance.new("ViewportFrame")
testViewport.Size = UDim2.new(0.5, 0, 0.5, 0)
testViewport.Position = UDim2.new(0.25, 0, 0.25, 0)
testViewport.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
testViewport.BorderSizePixel = 0
testViewport.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui", 5) or Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)

-- Create preview
print("Creating CharacterPreview...")
local preview = CharacterPreview.new(testViewport)

-- Test skin updates
wait(2)
print("Testing skin: VIP Diamond")
preview:updateSkin("VIP Diamond")

wait(3)
print("Testing skin: VIP Inferno")
preview:updateSkin("VIP Inferno")

wait(3)
print("Testing skin: VIP Cosmic")
preview:updateSkin("VIP Cosmic")

wait(3)
print("Testing skin: Default")
preview:updateSkin("Default")

-- Clean up after 15 seconds
wait(5)
print("Destroying preview...")
preview:destroy()
testViewport:Destroy()
print("Test complete!")