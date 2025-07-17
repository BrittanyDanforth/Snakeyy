local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local success, ShopUI = pcall(function()
    return require(ReplicatedStorage:WaitForChild("ShopUI"))
end)

if not success or type(ShopUI) ~= "table" then
    warn("❌ ShopUI ModuleScript could not be loaded or did not return a table.")
    return
end

if typeof(ShopUI.Show) == "function" then
    ShopUI.Show()
else
    warn("❌ ShopUI ModuleScript does not have a Show() function. Please add a Show() function to display the UI.")
end

