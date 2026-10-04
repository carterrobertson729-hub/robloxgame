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
	BaseLuck = 0, -- luck upgrades add to this
}

Settings.Washing = {
	SecondsPerLoad = 8,
	MachineCapacity = 3,
}

Settings.Player = {
	StartingCash = 50,
	InventoryLimit = 20,
}

Settings.DataStoreName = "PlayerData_v1"

return Settings
