--!strict
-- Washing machines. Use a machine once to load dirty clothes, again after the timer to collect them.
-- Jobs are stored in the player's data with a finish time, so they survive leaving and rejoining.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Settings = require(ReplicatedStorage.Shared.Settings)
local PlayerData = require(ServerScriptService.Server.PlayerData)
local Net = require(ServerScriptService.Server.Net)
local Sync = require(ServerScriptService.Server.Sync)

local WashService = {}

local lastUse: { [Player]: number } = {}

local function onWasher(player: Player, machineId: string)
	local now = os.clock()
	if now - (lastUse[player] or 0) < Settings.Washing.PromptCooldown then
		return
	end
	lastUse[player] = now

	local data = PlayerData.get(player)
	if not data then
		return
	end
	data.Washing = data.Washing or {}
	local jobs = data.Washing
	local inventory = data.Inventory
	local job = jobs[machineId]

	if job then
		local remaining = job.DoneAt - os.time()
		if remaining > 0 then
			Net.notice(player, "Still washing... " .. remaining .. "s left", "info")
			return
		end
		if #inventory + #job.Items > Settings.Player.InventoryLimit then
			Net.notice(player, "Bag too full to collect. Sell something first.", "bad")
			return
		end
		for _, item in job.Items do
			item.Washed = true
			table.insert(inventory, item)
		end
		local count = #job.Items
		jobs[machineId] = nil
		Net.notice(player, "Collected " .. count .. " clean item(s)", "good")
		Sync.push(player)
		return
	end

	local loaded = {}
	local i = 1
	while i <= #inventory and #loaded < Settings.Washing.MachineCapacity do
		if inventory[i].Washed then
			i += 1
		else
			table.insert(loaded, table.remove(inventory, i))
		end
	end
	if #loaded == 0 then
		Net.notice(player, "Nothing dirty to wash", "info")
		return
	end
	jobs[machineId] = { Items = loaded, DoneAt = os.time() + Settings.Washing.SecondsPerLoad }
	Net.notice(player, "Washing " .. #loaded .. " item(s)... " .. Settings.Washing.SecondsPerLoad .. "s", "info")
	Sync.push(player)
end

local function setupMachine(station: Model)
	local body = station.PrimaryPart
	if not body then
		return
	end
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Use"
	prompt.ObjectText = "Washing Machine"
	prompt.HoldDuration = 0.5
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = body
	prompt.Triggered:Connect(function(player: Player)
		onWasher(player, station.Name)
	end)
end

function WashService.init()
	Players.PlayerRemoving:Connect(function(p)
		lastUse[p] = nil
	end)
	local stations = workspace:WaitForChild("Store"):WaitForChild("Stations")
	for _, station in stations:GetChildren() do
		if station:GetAttribute("Station") == "Washer" then
			setupMachine(station :: Model)
		end
	end
end

return WashService
