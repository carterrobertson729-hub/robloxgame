--!strict
-- Content definitions. Add clothes, brands, or rarities here; no game logic needs to change.
-- All brands are invented. Never use a real brand name.

local ItemData = {}

-- Weight = how often this rarity is rolled. Higher = more common.
ItemData.Rarities = {
	{ Name = "Common", Weight = 600, ValueScale = 1, OnlineWaitScale = 1, Color = Color3.fromRGB(180, 180, 180) },
	{ Name = "Uncommon", Weight = 250, ValueScale = 2.5, OnlineWaitScale = 1.5, Color = Color3.fromRGB(90, 200, 90) },
	{ Name = "Rare", Weight = 110, ValueScale = 7, OnlineWaitScale = 2.5, Color = Color3.fromRGB(70, 130, 255) },
	{ Name = "Epic", Weight = 35, ValueScale = 20, OnlineWaitScale = 4, Color = Color3.fromRGB(170, 70, 255) },
	{ Name = "Legendary", Weight = 5, ValueScale = 75, OnlineWaitScale = 7, Color = Color3.fromRGB(255, 180, 30) },
}

-- ValueMultiplier applies to the item's base value after the roll.
ItemData.Conditions = {
	{ Name = "Worn", Weight = 30, ValueMultiplier = 0.6 },
	{ Name = "Used", Weight = 45, ValueMultiplier = 0.85 },
	{ Name = "Good", Weight = 20, ValueMultiplier = 1.0 },
	{ Name = "Like New", Weight = 5, ValueMultiplier = 1.4 },
}

-- Invented placeholder brands. Final names are an open decision for Carter.
ItemData.Brands = {
	{ Id = "northpeak", Name = "NorthPeak", Prestige = 1.3 },
	{ Id = "swiftstride", Name = "SwiftStride", Prestige = 1.2 },
	{ Id = "denimworks", Name = "Denim & Works", Prestige = 1.0 },
	{ Id = "velvetlane", Name = "Velvet Lane", Prestige = 1.5 },
	{ Id = "plainthread", Name = "Plain Thread", Prestige = 0.8 },
}

-- BaseValue is in cash at Common/Good/Prestige 1.0. Placeholder numbers to tune after playtesting.
ItemData.Clothes = {
	{ Id = "tee", Name = "T-Shirt", BaseValue = 6 },
	{ Id = "longsleeve", Name = "Long Sleeve", BaseValue = 8 },
	{ Id = "hoodie", Name = "Hoodie", BaseValue = 14 },
	{ Id = "jeans", Name = "Jeans", BaseValue = 12 },
	{ Id = "cargo", Name = "Cargo Pants", BaseValue = 13 },
	{ Id = "jacket", Name = "Jacket", BaseValue = 20 },
	{ Id = "sneakers", Name = "Sneakers", BaseValue = 18 },
	{ Id = "cap", Name = "Cap", BaseValue = 5 },
	{ Id = "dress", Name = "Dress", BaseValue = 15 },
	{ Id = "windbreaker", Name = "Windbreaker", BaseValue = 16 },
}

return ItemData
