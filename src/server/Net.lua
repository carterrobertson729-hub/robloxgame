--!strict
-- Creates the RemoteEvents the client listens to. Clients only display; the server decides.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local folder = Instance.new("Folder")
folder.Name = "Remotes"
folder.Parent = ReplicatedStorage

local Net = {}

local events: { [string]: RemoteEvent } = {}

function Net.event(name: string): RemoteEvent
	local existing = events[name]
	if existing then
		return existing
	end
	local e = Instance.new("RemoteEvent")
	e.Name = name
	e.Parent = folder
	events[name] = e
	return e
end

-- Short message shown at the bottom of the player's screen. Kind: "info" | "good" | "bad"
function Net.notice(player: Player, text: string, kind: string?)
	Net.event("Notice"):FireClient(player, text, kind or "info")
end

return Net
