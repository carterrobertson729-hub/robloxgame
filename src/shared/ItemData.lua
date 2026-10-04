--!strict
-- Content definitions. Add clothes, brands, or rarities here; no game logic needs to change.
-- All brands are invented. Never use a real brand name.

local ItemData = {}

-- Weight = how often this rarity is rolled. Higher = more common.
ItemData.Rarities = {
	{ Name = "Common", Emoji = "⚪", Weight = 600, ValueScale = 1, OnlineWaitScale = 1, Color = Color3.fromRGB(180, 180, 180) },
	{ Name = "Uncommon", Emoji = "🟢", Weight = 250, ValueScale = 2.5, OnlineWaitScale = 1.5, Color = Color3.fromRGB(90, 200, 90) },
	{ Name = "Rare", Emoji = "🔵", Weight = 110, ValueScale = 7, OnlineWaitScale = 2.5, Color = Color3.fromRGB(70, 130, 255) },
	{ Name = "Epic", Emoji = "🟣", Weight = 35, ValueScale = 20, OnlineWaitScale = 4, Color = Color3.fromRGB(170, 70, 255) },
	{ Name = "Legendary", Emoji = "🟡", Weight = 5, ValueScale = 75, OnlineWaitScale = 7, Color = Color3.fromRGB(255, 180, 30) },
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

local function findBy(list: { any }, key: string, value: any): any
	for _, entry in list do
		if entry[key] == value then
			return entry
		end
	end
	return nil
end

function ItemData.getRarity(name: string): any
	return findBy(ItemData.Rarities, "Name", name)
end

function ItemData.getBrand(id: string): any
	return findBy(ItemData.Brands, "Id", id)
end

function ItemData.getCloth(id: string): any
	return findBy(ItemData.Clothes, "Id", id)
end

-- Rarity weights with luck applied. Used by the server to roll and by the client to show the
-- real odds (Roblox requires odds to be shown for paid random items). Luck = 0.25 means +25%
-- weight on every rarity above Common.
function ItemData.rarityWeights(luck: number): { any }
	local list = {}
	local total = 0
	for i, r in ItemData.Rarities do
		local weight = r.Weight * (i == 1 and 1 or (1 + luck))
		total += weight
		list[i] = { Rarity = r, Weight = weight, Chance = 0 }
	end
	for _, entry in list do
		entry.Chance = entry.Weight / total
	end
	return list
end

-- "NorthPeak Hoodie"
function ItemData.displayName(item: any): string
	local brand = ItemData.getBrand(item.BrandId)
	local cloth = ItemData.getCloth(item.ClothId)
	return (brand and brand.Name or item.BrandId) .. " " .. (cloth and cloth.Name or item.ClothId)
end

return ItemData
