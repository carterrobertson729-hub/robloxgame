--!strict
-- Sends a player their cash and inventory so the UI can show it. One-way: the client never writes.

local ServerScriptService = game:GetService("ServerScriptService")
local PlayerData = require(ServerScriptService.Server.PlayerData)
local Net = require(ServerScriptService.Server.Net)

local Sync = {}

function Sync.push(player: Player)
	local data = PlayerData.get(player)
	if not data then
		return
	end
	Net.event("DataUpdate"):FireClient(player, { Cash = data.Cash, Inventory = data.Inventory })
end

function Sync.init()
	-- The client asks once when its UI is ready; data may still be loading, so wait briefly.
	Net.event("RequestData").OnServerEvent:Connect(function(player: Player)
		for _ = 1, 20 do
			if PlayerData.get(player) then
				break
			end
			task.wait(0.5)
		end
		Sync.push(player)
	end)
end

return Sync
