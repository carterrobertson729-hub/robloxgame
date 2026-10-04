--!strict
-- Rolls a random clothing item. Server only: the client must never decide what it finds.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemData = require(ReplicatedStorage.Shared.ItemData)
local Settings = require(ReplicatedStorage.Shared.Settings)

local ItemRoller = {}

local rng = Random.new()

local function pickWeighted(list: { any }): any
	local total = 0
	for _, entry in list do
		total += entry.Weight
	end
	local roll = rng:NextNumber() * total
	for _, entry in list do
		roll -= entry.Weight
		if roll <= 0 then
			return entry
		end
	end
	return list[#list]
end

function ItemRoller.roll(luck: number?)
	local rarity = pickWeighted(ItemData.rarityWeights(luck or Settings.Finding.BaseLuck)).Rarity
	local condition = pickWeighted(ItemData.Conditions)
	local brand = ItemData.Brands[rng:NextInteger(1, #ItemData.Brands)]
	local cloth = ItemData.Clothes[rng:NextInteger(1, #ItemData.Clothes)]

	local value = cloth.BaseValue * rarity.ValueScale * condition.ValueMultiplier * brand.Prestige

	return {
		ClothId = cloth.Id,
		BrandId = brand.Id,
		Rarity = rarity.Name,
		Condition = condition.Name,
		Washed = false,
		Value = math.max(1, math.floor(value + 0.5)),
	}
end

return ItemRoller
