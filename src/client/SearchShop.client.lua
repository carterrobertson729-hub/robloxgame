--!strict
-- Shows how many searches you have and the Robux search packs, with the real odds.
-- Display only: purchases are granted by the server after Roblox confirms them.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemData = require(ReplicatedStorage.Shared.ItemData)
local Settings = require(ReplicatedStorage.Shared.Settings)
local dataUpdate = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DataUpdate") :: RemoteEvent

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "SearchShop"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function round(obj: GuiObject, radius: number)
	Instance.new("UICorner", obj).CornerRadius = UDim.new(0, radius)
end

local label = Instance.new("TextLabel")
label.Size = UDim2.fromOffset(190, 40)
label.Position = UDim2.fromOffset(182, 16)
label.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
label.BackgroundTransparency = 0.1
label.BorderSizePixel = 0
label.Font = Enum.Font.GothamBold
label.TextSize = 16
label.TextColor3 = Color3.new(1, 1, 1)
label.Text = "Searches: -"
label.Parent = gui
round(label, 10)

local moreButton = Instance.new("TextButton")
moreButton.Size = UDim2.fromOffset(190, 40)
moreButton.Position = UDim2.fromOffset(182, 64)
moreButton.BackgroundColor3 = Color3.fromRGB(190, 120, 30)
moreButton.BorderSizePixel = 0
moreButton.Font = Enum.Font.GothamBold
moreButton.TextSize = 16
moreButton.TextColor3 = Color3.new(1, 1, 1)
moreButton.Text = "More Searches"
moreButton.Parent = gui
round(moreButton, 10)

local shop = Instance.new("Frame")
shop.AnchorPoint = Vector2.new(0.5, 0.5)
shop.Position = UDim2.fromScale(0.5, 0.5)
shop.Size = UDim2.fromOffset(460, 470)
shop.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
shop.BorderSizePixel = 0
shop.Visible = false
shop.Parent = gui
round(shop, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextColor3 = Color3.new(1, 1, 1)
title.Text = "More Searches"
title.Parent = shop

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(32, 32)
close.Position = UDim2.new(1, -40, 0, 6)
close.BackgroundColor3 = Color3.fromRGB(120, 50, 50)
close.BorderSizePixel = 0
close.Font = Enum.Font.GothamBold
close.TextSize = 18
close.TextColor3 = Color3.new(1, 1, 1)
close.Text = "X"
close.Parent = shop
round(close, 8)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 22)
status.Position = UDim2.fromOffset(10, 40)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.TextColor3 = Color3.fromRGB(255, 190, 80)
status.Text = ""
status.Parent = shop

local function oddsText(luck: number): string
	local parts = {}
	for _, entry in ItemData.rarityWeights(luck) do
		table.insert(parts, string.format("%s %.1f%%", entry.Rarity.Name, entry.Chance * 100))
	end
	return table.concat(parts, "  |  ")
end

local y = 70
for _, pack in Settings.SearchPacks do
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -20, 0, 62)
	button.Position = UDim2.fromOffset(10, y)
	button.BackgroundColor3 = Color3.fromRGB(60, 90, 140)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.TextSize = 16
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Parent = shop
	round(button, 10)
	if pack.ProductId == 0 then
		button.Text = string.format("%s: %d searches, +%d%% luck  -  Coming soon", pack.Name, pack.Searches, pack.Luck * 100)
		button.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
	else
		button.Text = string.format("%s: %d searches, +%d%% luck  -  R$%d", pack.Name, pack.Searches, pack.Luck * 100, pack.Robux)
	end
	button.Activated:Connect(function()
		if pack.ProductId == 0 then
			status.Text = "This pack is not available yet."
			return
		end
		MarketplaceService:PromptProductPurchase(player, pack.ProductId)
	end)
	y += 70
end

local odds = Instance.new("TextLabel")
odds.Size = UDim2.new(1, -20, 0, 170)
odds.Position = UDim2.fromOffset(10, y)
odds.BackgroundTransparency = 1
odds.Font = Enum.Font.Gotham
odds.TextSize = 13
odds.TextWrapped = true
odds.TextXAlignment = Enum.TextXAlignment.Left
odds.TextYAlignment = Enum.TextYAlignment.Top
odds.TextColor3 = Color3.fromRGB(200, 200, 210)
odds.Parent = shop

local lines = { "Chance of each rarity per search:", "Free searches: " .. oddsText(Settings.Finding.BaseLuck) }
for _, pack in Settings.SearchPacks do
	table.insert(lines, pack.Name .. ": " .. oddsText(pack.Luck))
end
odds.Text = table.concat(lines, "\n\n")

moreButton.Activated:Connect(function()
	shop.Visible = not shop.Visible
	status.Text = ""
end)
close.Activated:Connect(function()
	shop.Visible = false
end)

dataUpdate.OnClientEvent:Connect(function(data)
	label.Text = string.format("Free: %d/%d   Bonus: %d", data.FreeSearches, Settings.Finding.FreeSearchesPerDay, data.BonusSearches)
end)
