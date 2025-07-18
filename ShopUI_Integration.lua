-- ShopUI Integration with External CharacterPreview
-- This shows how to integrate the standalone CharacterPreview module

-- At the top of your ShopUI, replace the built-in CharacterPreview with:
local CharacterPreview = require(game.ReplicatedStorage:WaitForChild("CharacterPreview"))

-- Create a preview instance when shop opens
local previewInstance = nil

-- When creating the shop UI:
function createShopPreview(viewport, skinData)
	-- Destroy old preview if exists
	if previewInstance then
		previewInstance:destroy()
		previewInstance = nil
	end
	
	-- Create new preview
	previewInstance = CharacterPreview.new(viewport, skinData)
	
	return previewInstance
end

-- When updating the preview for a new skin:
function updatePreview(skinName)
	if previewInstance then
		previewInstance:updateSkin(skinName)
	end
end

-- When closing the shop:
function cleanupPreview()
	if previewInstance then
		previewInstance:destroy()
		previewInstance = nil
	end
end

-- In your ShopUI, replace these sections:

-- OLD:
-- CharacterPreview.create(ShopUI.uiElements.viewport)
-- NEW:
-- previewInstance = createShopPreview(ShopUI.uiElements.viewport, SnakeSkinsData)

-- OLD:
-- CharacterPreview.update(skinName)
-- NEW:
-- updatePreview(skinName)

-- OLD:
-- CharacterPreview.destroy()
-- NEW:
-- cleanupPreview()