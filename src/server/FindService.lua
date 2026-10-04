--!strict
-- Handles searching sourcing spots. The server rolls the item and owns the inventory.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Settings = require(ReplicatedStorage.Shared.Settings)
local ItemRoller = require(ServerScriptService.Server.ItemRoller)
local PlayerData = require(ServerScriptService.Server.PlayerData)
local Net = require(ServerScriptService.Server.Net)
local Sync = require(ServerScriptService.Server.Sync)
local Searches = require(ServerScriptService.Server.Searches)

local FindService = {}

local lastSearch: { [Player]: number } = {}

local function onSearch(player: Player)
	local now = os.clock()
	if now - (lastSearch[player] or 0) < Settings.Finding.CooldownSeconds then
		return
	end
	local data = PlayerData.get(player)
	if not data then
		return
	end
	lastSearch[player] = now

	if #data.Inventory >= Settings.Player.InventoryLimit then
		Net.event("ItemFound"):FireClient(player, { Full = true })
		return
	end

	local allowed, luck = Searches.consume(data)
	if not allowed then
		Net.event("ItemFound"):FireClient(player, { NoSearches = true })
		Sync.push(player)
		return
	end

	local item = ItemRoller.roll(luck)
	table.insert(data.Inventory, item)
	Net.event("ItemFound"):FireClient(player, item)
	Sync.push(player)
end

local function setupSpot(spot: Model)
	local body = spot.PrimaryPart
	if not body then
		return
	end
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Search"
	prompt.ObjectText = "Donation Bin"
	prompt.HoldDuration = 1
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = body
	prompt.Triggered:Connect(onSearch)
end

function FindService.init()
	Net.event("ItemFound") -- make sure it exists before clients look for it

	Players.PlayerRemoving:Connect(function(p)
		lastSearch[p] = nil
	end)

	local stations = workspace:WaitForChild("Store"):WaitForChild("Stations")
	for _, station in stations:GetChildren() do
		if station:GetAttribute("Station") == "Sourcing" then
			setupSpot(station :: Model)
		end
	end
end

return FindService
