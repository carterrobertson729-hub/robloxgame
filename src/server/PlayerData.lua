--!strict
-- Loads and saves each player's data. Retries on failure and never overwrites with empty data.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Settings = require(ReplicatedStorage.Shared.Settings)

local store = DataStoreService:GetDataStore(Settings.DataStoreName)

local PlayerData = {}
local profiles: { [Player]: any } = {}
local loadFailed: { [Player]: boolean } = {}

local function defaultData()
	return {
		Cash = Settings.Player.StartingCash,
		Inventory = {}, -- list of item tables from ItemRoller.roll
	}
end

local function withRetry(fn: () -> any): (boolean, any)
	local ok, result
	for attempt = 1, 4 do
		ok, result = pcall(fn)
		if ok then
			return true, result
		end
		task.wait(2 ^ attempt)
	end
	return false, result
end

function PlayerData.load(player: Player)
	local key = "Player_" .. player.UserId
	local ok, data = withRetry(function()
		return store:GetAsync(key)
	end)
	if not player.Parent then
		return
	end
	if not ok then
		-- Play with temporary data but never save it, so a real save is not overwritten.
		loadFailed[player] = true
		profiles[player] = defaultData()
		warn("Data load failed for", player.Name)
		return
	end
	profiles[player] = data or defaultData()
end

function PlayerData.save(player: Player)
	local data = profiles[player]
	if not data or loadFailed[player] then
		return
	end
	withRetry(function()
		store:SetAsync("Player_" .. player.UserId, data)
	end)
end

function PlayerData.get(player: Player)
	return profiles[player]
end

function PlayerData.release(player: Player)
	PlayerData.save(player)
	profiles[player] = nil
	loadFailed[player] = nil
end

function PlayerData.init()
	Players.PlayerAdded:Connect(PlayerData.load)
	Players.PlayerRemoving:Connect(PlayerData.release)
	for _, p in Players:GetPlayers() do
		task.spawn(PlayerData.load, p)
	end
	game:BindToClose(function()
		for _, p in Players:GetPlayers() do
			task.spawn(PlayerData.save, p)
		end
		task.wait(3)
	end)
	-- Autosave every 2 minutes.
	task.spawn(function()
		while true do
			task.wait(120)
			for _, p in Players:GetPlayers() do
				task.spawn(PlayerData.save, p)
			end
		end
	end)
end

return PlayerData
