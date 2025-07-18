# Robux Purchase & Economy System

## Overview
The shop now supports both coin and Robux purchases for premium skins. Players start with 100 coins and can earn more through gameplay.

## Currency System

### Starting Balance
- New players start with **100 coins** (changed from 50,000)
- Coins are displayed with proper formatting (e.g., "1,234" instead of "1234")

### Earning Coins
- Players earn **1 coin** for every 5 segments they grow
- Coins are automatically saved to the player's data

### Coin Display
- Coins appear in the shop header with a money bag icon (💰)
- Coins also appear in the Roblox leaderboard for easy viewing

## Skin Pricing

### Coin-Only Skins (Basic)
- **Crimson**: 250 coins
- **Arctic**: 350 coins  
- **Emerald**: 500 coins
- **Void**: 1,000 coins

### Dual Currency Skins (Premium)
These skins can be purchased with either coins OR Robux:

- **Plasma**: 1,500 coins or 25 Robux
- **Galaxy**: 2,000 coins or 35 Robux
- **Ocean**: 2,500 coins or 45 Robux
- **Shadow**: 3,000 coins or 50 Robux
- **Cyber**: 4,000 coins or 75 Robux
- **Dragon**: 5,000 coins or 99 Robux
- **Rainbow**: 7,500 coins or 125 Robux

### VIP Skins
- **VIP Diamond**: 10,000 coins or 149 Robux
- **VIP Inferno**: 15,000 coins or 199 Robux
- **VIP Cosmic**: 20,000 coins or 299 Robux

## Shop UI Changes

### Skin Cards
- Skins with Robux options show both prices: "💰 1,500 or R$ 25"
- Clean, modern display with proper spacing

### Purchase Buttons
- **Coin Purchase**: Blue "BUY WITH COINS" button
- **Robux Purchase**: Green "R$ 25" button (shows actual Robux price)
- Buttons are intelligently positioned based on available options

### Visual Feedback
- Coin purchases show yellow flash effect
- Robux purchases show green flash effect
- Smooth animations for all interactions

## Implementation Notes

### For Developers
1. **Robux Purchases**: Currently using a placeholder system. In production:
   - Create Developer Products in Roblox for each Robux price point
   - Implement proper ProcessReceipt handling in UnifiedSkinSystem
   - Add receipt validation and error handling

2. **Data Storage**: 
   - Coins stored as player attribute
   - Synchronized between client and server
   - Displayed in leaderstats

3. **Security**:
   - All purchases validated server-side
   - Coin deduction happens on server
   - Client shows optimistic updates

## Future Enhancements
- Daily login bonuses
- Coin rewards for eliminating other players
- Special events with bonus coins
- Coin gift system between friends
- Battle pass with exclusive skins