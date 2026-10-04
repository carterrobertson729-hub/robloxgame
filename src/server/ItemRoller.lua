--!strict
-- Rolls a random clothing item. Server only: the client must never decide what it finds.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemData = require(ReplicatedStorage.Shared.ItemData)
local Settings = require(ReplicatedStorage.Shared.Settings)

local ItemRoller = {}

type Weighted = { Weight: number }

local function pickWeighted<T>(list: { T & Weighted }, rng: Random): T & Weighted
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

-- Luck makes rarer tiers more likely by shrinking the weight of the commonest tier.
local function rarityList(luck: number)
	if luck <= 0 then
		return ItemData.Rarities
	end
	local adjusted = {}
	for i, r in ItemData.Rarities do
		local weight = r.Weight
		if i == 1 then
			weight = math.max(1, weight - luck * 10)
		end
		adjusted[i] = { Name = r.Name, Weight = weight, Source = r }
	end
	return adjusted
end

local rng = Random.new()

function ItemRoller.roll(luck: number?)
	luck = luck or Settings.Finding.BaseLuck
	local list = rarityList(luck :: number)
	local picked = pickWeighted(list, rng)
	local rarity = (picked :: any).Source or picked
	local condition = pickWeighted(ItemData.Conditions, rng)
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
