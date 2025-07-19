# CharacterPreview V2 - High-Quality Snake Preview System

## Overview
Created a completely new CharacterPreview module that matches the in-game CharacterSetup quality, replacing the old orb-like preview with a smooth, professional snake appearance.

## Key Improvements

### 1. **Smooth Connected Segments**
- No more floating orbs! Segments flow naturally like a real snake
- Size gradient from head to tail (each segment 85% size of previous)
- Smooth following motion with 98% smoothness factor
- Proper segment spacing maintained

### 2. **Properly Welded Eyes**
- Eyes use WeldConstraints to stay attached to the head
- No more floating eyes!
- Pupils welded to eyes for perfect tracking
- Matches CharacterSetup's eye implementation exactly

### 3. **Natural Snake Animation**
- Smooth wave motion along the body
- Segments follow each other naturally
- S-curve positioning for realistic snake shape
- Configurable wave amplitude, frequency, and speed

### 4. **Enhanced VFX System**
- Skin-specific VFX automatically applied
- Aura effects that follow the head
- Orbiting particle effects
- Lightning effects for premium skins
- All VFX properly cleaned up on skin change

### 5. **Camera System**
- Smooth rotating camera around the snake
- Optimal viewing angle and distance
- Always focused on the snake head

### 6. **Modular Design**
- Standalone module that can be reused
- Clean OOP structure with proper cleanup
- Easy to integrate with any UI system
- Proper memory management

## Technical Details

### Configuration
```lua
PREVIEW_CONFIG = {
    SegmentCount = 12,
    SegmentSpacing = 1.8,
    WaveAmplitude = 2,
    WaveFrequency = 2,
    WaveSpeed = 1.5,
    RotationSpeed = 0.8,
    CameraDistance = 25,
    CameraHeight = 8,
    SmoothnessFactor = 0.98,
    SegmentSizeGradient = 0.85
}
```

### Usage
```lua
-- Create preview
local preview = CharacterPreview.new(viewport)

-- Update skin
preview:updateSkin("VIP Diamond")

-- Clean up
preview:destroy()
```

### Integration with ShopUI
- Seamless drop-in replacement
- Maintains backward compatibility
- All existing ShopUI calls work without modification

## Visual Improvements
1. **Head**: Proper size and material from skin data
2. **Body**: Smooth color patterns, not random orbs
3. **Eyes**: Stay attached, look professional
4. **Glow**: Proper PointLight effects matching skin colors
5. **VFX**: Extreme effects for VIP skins as requested

## Performance
- Optimized update loop using Heartbeat
- Efficient lerping for smooth motion
- Proper cleanup prevents memory leaks
- Minimal CPU usage

This new CharacterPreview system delivers the high-quality, professional appearance you wanted - matching the in-game snake exactly!