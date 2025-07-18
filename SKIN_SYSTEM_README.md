# Snake Skins System V2.0 - Complete Documentation

## Overview
The Snake Skins System has been completely revamped to ensure all skins work properly across all categories. This includes proper support for VIP Elite skins, pricing systems, and visual effects.

## Skin Categories

### 1. **Classic Skins** (Free/Low Cost)
- **Classic** - The original green snake (Free)
- Basic skins available to all players

### 2. **Featured Skins** (Hot & Trending)
- **Arctic** - Ice cold frost effects (750 coins)
- **Emerald** - Precious green gemstone (1000 coins)
- **Void** - Darkness incarnate (1250 coins)

### 3. **Premium Skins** (Enhanced Effects)
- **Lava Red** - Burning crimson fire (150 coins)
- **Ocean Blue** - Deep as the ocean (100 coins)
- **Electric Purple** - Electric energy flows (500 coins)
- **Shadow** - Lurk in the shadows (800 coins)
- **Galaxy** - Born from distant galaxies (1500 coins)
- **Cyberpunk** - From the digital future (2000 coins)
- **Rainbow Prism** - All colors of the rainbow (2000 coins)

### 4. **VIP Elite Skins** (Robux Only)
- **VIP Diamond** - Shine like a diamond! (299 Robux)
  - White/Diamond colors with sparkle effects
  - Larger size (3.5x3.5x3.5 head)
  - Enhanced glow (3.5 intensity, 12 range)
  
- **VIP Inferno** - Burn with VIP flames! (399 Robux)
  - Orange/Fire colors with fire VFX
  - Larger size and enhanced effects
  - Fire particles on head
  
- **VIP Cosmic** - Harness cosmic power! (499 Robux)
  - Purple/Cosmic colors with galaxy VFX
  - Maximum glow effects (4.5 intensity, 18 range)
  - Galaxy particle effects

### 5. **Special Skins** (Limited Edition)
- **Golden** - Pure gold luxury! (10000 coins)
- **Dragon Lord** - Breathe fire like a dragon! (5000 coins)

### 6. **Gamepass Skins** (Power-Ups)
- **Lightning** - Strike with lightning speed! (Gamepass required)
  - Includes lightning VFX effects

## Technical Improvements

### 1. **Complete Skin Data Structure**
Every skin now includes all required fields:
- `HeadColor` - Color3 value for the head
- `BodyColors` - Array of Color3 values for body segments
- `HeadSize` - Vector3 for head dimensions
- `SegmentSize` - Vector3 for body segment dimensions
- `SegmentSpacing` - Number for segment spacing
- `HeadMaterial` - Enum.Material for head appearance
- `BodyMaterial` - Enum.Material for body appearance
- `GlowIntensity` - Number for glow brightness
- `GlowRange` - Number for glow radius
- `Description` - String describing the skin

### 2. **Flexible Pricing System**
Skins can now have multiple pricing options:
- `Price` - Cost in coins (nil for non-coin skins)
- `RobuxPrice` - Cost in Robux (for VIP skins)
- `GamepassId` - Required gamepass ID (for gamepass skins)
- `Special` - Boolean flag for limited edition skins

### 3. **Visual Effects (VFX) System**
Enhanced skins can include VFX:
```lua
VFX = {
    Type = "Fire",  -- Types: Fire, Frost, Lightning, Sparkle, Galaxy
    Color = Color3.fromRGB(255, 100, 0),
    SecondaryColor = Color3.fromRGB(255, 200, 0),  -- Optional
    ParticleTexture = "rbxasset://..."  -- Optional
}
```

### 4. **Skin Validation**
The `SkinValidator.lua` script ensures:
- All required fields are present
- Data types are correct (Color3, Vector3, etc.)
- At least one pricing method is defined
- VFX configurations are valid

### 5. **Unified Skin System**
The `UnifiedSkinSystem` handles:
- Automatic skin loading from SnakeSkinsData
- Proper name mapping between client and server
- Support for all purchase types (coins, Robux, gamepass)
- Real-time skin application and changes

## Usage Guide

### Adding New Skins
1. Add the skin data to `SnakeSkinsData.lua`:
```lua
["Your Skin Name"] = {
    HeadColor = Color3.fromRGB(255, 0, 0),
    BodyColors = {
        Color3.fromRGB(200, 0, 0),
        Color3.fromRGB(255, 0, 0),
        -- Add 3-5 colors for body pattern
    },
    HeadSize = Vector3.new(3, 3, 3),
    SegmentSize = Vector3.new(2.5, 2.5, 2.5),
    SegmentSpacing = 2.2,
    HeadMaterial = Enum.Material.ForceField,
    BodyMaterial = Enum.Material.Neon,
    GlowIntensity = 2.0,
    GlowRange = 6,
    Price = 500,  -- Or RobuxPrice/GamepassId
    Description = "Your skin description!"
}
```

2. Add to the appropriate category in ShopUI
3. Update the SKIN_NAME_MAP in UnifiedSkinSystem if needed
4. Run SkinValidator to ensure it's properly configured

### Troubleshooting

**Skin shows as "nil" or can't be bought:**
- Check that the skin exists in SnakeSkinsData.lua
- Verify pricing is set (Price, RobuxPrice, or GamepassId)
- Run SkinValidator to check for configuration errors

**Skin doesn't apply when selected:**
- Ensure skin name mapping is correct in UnifiedSkinSystem
- Check that CharacterSetup is loading SnakeSkinsData properly
- Verify the skin has all required visual properties

**VFX not showing:**
- Check that VFX configuration has a valid Type
- Ensure VFX colors and textures are properly defined
- Verify CharacterSetup's applyVFX function is working

## Best Practices

1. **Always validate new skins** using SkinValidator.lua
2. **Use consistent naming** between client and server
3. **Test all purchase methods** (coins, Robux, gamepass)
4. **Keep VFX lightweight** to prevent lag
5. **Document special features** in the skin description

## Future Enhancements

- [ ] Animated skins with changing colors
- [ ] Seasonal/event-based skins
- [ ] Custom particle effects per segment
- [ ] Skin trading system
- [ ] Skin preview in 3D before purchase

---

*Last Updated: [Current Date]*
*Version: 2.0*