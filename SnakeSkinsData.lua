-- SNAKE SKINS DATA
-- Direct server-side access to skin configurations

local SnakeSkinsData = {
	["Classic"] = {
		HeadColor = Color3.fromRGB(76, 217, 100),
		BodyColors = {
			Color3.fromRGB(60, 180, 80),
			Color3.fromRGB(80, 200, 100),
			Color3.fromRGB(100, 220, 120),
			Color3.fromRGB(80, 200, 100),
			Color3.fromRGB(60, 180, 80),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 1.5,
		GlowRange = 4,
		Price = 0,
		Description = "The original slither.io look!"
	},

	["Lava Red"] = {
		HeadColor = Color3.fromRGB(220, 50, 50),
		BodyColors = {
			Color3.fromRGB(180, 30, 30),
			Color3.fromRGB(200, 50, 50),
			Color3.fromRGB(220, 70, 70),
			Color3.fromRGB(200, 50, 50),
			Color3.fromRGB(180, 30, 30),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 2.0,
		GlowRange = 6,
		Price = 150,
		Description = "Burn with crimson fire!"
	},

	["Ocean Blue"] = {
		HeadColor = Color3.fromRGB(50, 150, 200),
		BodyColors = {
			Color3.fromRGB(30, 100, 180),
			Color3.fromRGB(40, 120, 190),
			Color3.fromRGB(50, 140, 200),
			Color3.fromRGB(40, 120, 190),
			Color3.fromRGB(30, 100, 180),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 1.8,
		GlowRange = 5,
		Price = 100,
		Description = "Deep as the ocean!"
	},

	["Cyberpunk"] = {
		HeadColor = Color3.fromRGB(0, 255, 150),
		BodyColors = {
			Color3.fromRGB(0, 200, 100),
			Color3.fromRGB(0, 225, 125),
			Color3.fromRGB(0, 255, 150),
			Color3.fromRGB(0, 225, 125),
			Color3.fromRGB(0, 200, 100),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 2.5,
		GlowRange = 8,
		Price = 2000,
		Description = "From the digital future!"
	},

	["Rainbow Prism"] = {
		HeadColor = Color3.fromRGB(255, 100, 255),
		BodyColors = {
			Color3.fromRGB(255, 0, 0),     -- Red
			Color3.fromRGB(255, 165, 0),   -- Orange
			Color3.fromRGB(255, 255, 0),   -- Yellow
			Color3.fromRGB(0, 255, 0),     -- Green
			Color3.fromRGB(0, 0, 255),     -- Blue
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 2.5,
		GlowRange = 8,
		Price = 2000,
		Description = "All colors of the rainbow!"
	},

	["Electric Purple"] = {
		HeadColor = Color3.fromRGB(255, 100, 200),
		BodyColors = {
			Color3.fromRGB(200, 50, 150),
			Color3.fromRGB(225, 75, 175),
			Color3.fromRGB(255, 100, 200),
			Color3.fromRGB(225, 75, 175),
			Color3.fromRGB(200, 50, 150),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 2.2,
		GlowRange = 7,
		Price = 500,
		Description = "Electric energy flows through you!"
	},

	["Dragon Lord"] = {
		HeadColor = Color3.fromRGB(255, 150, 0),
		BodyColors = {
			Color3.fromRGB(200, 100, 0),
			Color3.fromRGB(225, 125, 0),
			Color3.fromRGB(255, 150, 0),
			Color3.fromRGB(225, 125, 0),
			Color3.fromRGB(200, 100, 0),
		},
		HeadSize = Vector3.new(3.5, 3.5, 3.5),
		SegmentSize = Vector3.new(3, 3, 3),
		SegmentSpacing = 2.5,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 3.0,
		GlowRange = 10,
		Price = 5000,
		Description = "Breathe fire like a dragon!"
	},

	-- Add all other skins here...
	["Galaxy"] = {
		HeadColor = Color3.fromRGB(100, 50, 255),
		BodyColors = {
			Color3.fromRGB(50, 0, 150),
			Color3.fromRGB(75, 25, 200),
			Color3.fromRGB(100, 50, 255),
			Color3.fromRGB(75, 25, 200),
			Color3.fromRGB(50, 0, 150),
		},
		HeadSize = Vector3.new(3, 3, 3),
		SegmentSize = Vector3.new(2.5, 2.5, 2.5),
		SegmentSpacing = 2.2,
		HeadMaterial = Enum.Material.ForceField,
		BodyMaterial = Enum.Material.Neon,
		GlowIntensity = 2.0,
		GlowRange = 6,
		Price = 1500,
		Description = "Born from distant galaxies!"
	},
}

return SnakeSkinsData
