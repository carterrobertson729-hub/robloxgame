--!strict
-- Handles searching sourcing spots. The server rolls the item and owns the inventory.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Settings = require(ReplicatedStorage.Shared.Settings)
local ItemRoller = require(ServerScriptService.Server.ItemRoller)
local PlayerData = require(ServerScriptService.Server.PlayerData)

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
		FindService.notify(player, { Full = true })
		return
	end

	local item = ItemRoller.roll()
	table.insert(data.Inventory, item)
	FindService.notify(player, item)
end

function FindService.notify(player: Player, payload: any)
	local remote = ReplicatedStorage.Remotes.ItemFound
	remote:FireClient(player, payload)
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
	local remotes = Instance.new("Folder")
	remotes.Name = "Remotes"
	remotes.Parent = ReplicatedStorage
	local found = Instance.new("RemoteEvent")
	found.Name = "ItemFound"
	found.Parent = remotes

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
