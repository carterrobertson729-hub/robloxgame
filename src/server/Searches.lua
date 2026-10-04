--!strict
-- Search allowance: a few free searches per day, plus paid searches that carry their own luck.
-- Stored in player data: FreeUsed, FreeDay, Bonus = { { Count, Luck }, ... }

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Settings = require(ReplicatedStorage.Shared.Settings)

local Searches = {}

local function today(): number
	return os.time() // 86400
end

function Searches.freeLeft(data: any): number
	if data.FreeDay ~= today() then
		data.FreeDay = today()
		data.FreeUsed = 0
	end
	return math.max(0, Settings.Finding.FreeSearchesPerDay - data.FreeUsed)
end

function Searches.bonusTotal(data: any): number
	local total = 0
	for _, entry in data.Bonus do
		total += entry.Count
	end
	return total
end

-- Uses one search. Returns whether one was available and the luck to roll with.
function Searches.consume(data: any): (boolean, number)
	if Searches.freeLeft(data) > 0 then
		data.FreeUsed += 1
		return true, Settings.Finding.BaseLuck
	end
	local entry = data.Bonus[1]
	if entry then
		entry.Count -= 1
		local luck = entry.Luck
		if entry.Count <= 0 then
			table.remove(data.Bonus, 1)
		end
		return true, luck
	end
	return false, 0
end

function Searches.grant(data: any, count: number, luck: number): any
	local entry = { Count = count, Luck = luck }
	table.insert(data.Bonus, entry)
	return entry
end

function Searches.revoke(data: any, entry: any)
	local i = table.find(data.Bonus, entry)
	if i then
		table.remove(data.Bonus, i)
	end
end

return Searches
