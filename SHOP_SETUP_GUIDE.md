# Slither.io Shop System Setup Guide

## File Locations

### Client Scripts (StarterPlayer > StarterPlayerScripts)
Place these files in StarterPlayerScripts:
- `ShopUI.lua` - Main shop interface
- `CharacterPreview.lua` - High-quality snake preview system
- `ShopManager.lua` - Shop data management
- `ShopInitializer.lua` - Ensures shop loads properly (optional)

### Shared Modules (ReplicatedStorage)
Place these files in ReplicatedStorage:
- `SnakeSkinsData.lua` - Skin database
- `ExtremeVFXSystem.lua` - VFX effects system

### Server Scripts (ServerScriptService)
- `CharacterSetup.lua` - Snake character system
- `UnifiedSkinSystem` - Server-side skin management

## Setup Steps

1. **Place all files in their correct locations**

2. **Ensure RemoteEvents exist in ReplicatedStorage:**
   - `SelectSkin` - For skin selection
   - `RespawnSnake` - For respawning with new skin

3. **The shop will auto-initialize when:**
   - Player joins the game
   - ShopUI script runs
   - Creates hidden GUI for ShopManager to find

4. **To open the shop:**
   - Press `F` key (default binding)
   - Or call `_G.ShopUI.open()` from console/script
   - Or from your menu: `_G.ShopUI.Show()`

## Troubleshooting

### "Shop system not loaded yet"
**Solution**: The shop is still initializing. It auto-creates after ~1-2 seconds of joining.

### "No shop found - Shop Manager will wait"
**Solution**: This is normal on startup. ShopManager waits for ShopUI to create the GUI.

### CharacterPreview not working
**Solution**: Ensure `CharacterPreview.lua` is in the same folder as `ShopUI.lua`.

### Preview shows orbs instead of smooth snake
**Solution**: Make sure you're using the new `CharacterPreview.lua` module, not the old inline code.

## Integration with Your Menu

To integrate with your existing Slither.io menu:

```lua
-- In your menu script
local function openShop()
    if _G.ShopUI then
        _G.ShopUI.open()
    else
        print("Shop not loaded yet")
    end
end

-- Connect to your shop button
shopButton.MouseButton1Click:Connect(openShop)
```

## Features

- **Automatic Initialization**: Shop creates itself on game start
- **Data Persistence**: ShopManager saves player data
- **High-Quality Preview**: New CharacterPreview module with smooth snakes
- **VIP Skins**: Fixed pricing display (no more "nil")
- **Keyboard Shortcut**: Press F to toggle shop

## Testing

1. Join your game
2. Wait 2-3 seconds for initialization
3. Press F to open shop
4. Check console for initialization messages:
   - "🏪 Pre-creating shop GUI for ShopManager..."
   - "✅ Shop GUI created and ready for ShopManager"
   - "✅ Shop Manager initialized successfully!"

The shop system is now fully integrated and will work seamlessly with your Slither.io game!