--!strict
-- Small helpers for showing numbers.

local Format = {}

-- 12500 -> "$12,500"
function Format.cash(amount: number): string
	local text = tostring(math.floor(amount))
	local withCommas = text:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	if withCommas:sub(1, 1) == "," then
		withCommas = withCommas:sub(2)
	end
	return "$" .. withCommas
end

return Format
