--!strict
-- Every tuning number in the game lives here. Change numbers here, never in other scripts.

local Settings = {}

Settings.Selling = {
	-- Fraction of an item's value the player receives.
	InPersonMultiplier = 0.7,
	OnlineMultiplier = 1.2,

	-- Seconds until a sale happens.
	InPersonSeconds = { Min = 5, Max = 45 },
	-- Online wait is BaseSeconds * the rarity's OnlineWaitScale.
	OnlineBaseSeconds = 120,
}

Settings.Finding = {
	CooldownSeconds = 1.5, -- minimum time between searches per player
	FreeSearchesPerDay = 3, -- resets once per UTC day
	-- Luck is a bonus to the weight of every rarity above Common: 0.25 = +25%.
	BaseLuck = 0, -- luck upgrades add to this
}

-- Robux search packs. Carter picks the numbers. Robux is only the label shown in the game;
-- the real price is set on the Creator Hub when you create the Developer Product.
-- ProductId 0 = not created yet (the button shows "Coming soon").
Settings.SearchPacks = {
	{ Id = "small", Name = "Small Pack", ProductId = 0, Robux = 25, Searches = 5, Luck = 0.10 },
	{ Id = "medium", Name = "Medium Pack", ProductId = 0, Robux = 75, Searches = 20, Luck = 0.25 },
	{ Id = "large", Name = "Large Pack", ProductId = 0, Robux = 199, Searches = 60, Luck = 0.50 },
}

Settings.Washing = {
	SecondsPerLoad = 8,
	MachineCapacity = 3, -- items per load
	PromptCooldown = 0.5,
}

Settings.Player = {
	StartingCash = 50,
	InventoryLimit = 20,
}

Settings.DataStoreName = "PlayerData_v1"

return Settings
